"""Authorized continuation of an existing reviewed pilot, never a production publisher.
Frozen Phase 0 remains the schema/transition/predicate authority. Original source,
normalized pixels, recipe and diagnostic history are only read, never reprocessed.
Early reviews bind a direct human conversation decision; they are NOT a credential.
"""
from pathlib import Path
from datetime import datetime,timezone
import copy,json,io,sys,subprocess,importlib.metadata
from PIL import Image
from willicat_asset_factory_phase0.contracts import (canonical,sha,projection_hash,
    validate_manifest,transition_allowed,load_contract,scopes_permitted,production_ready)
from willicat_asset_factory_phase0.filesystem import bundle_receipt,check_bundle
from willicat_asset_factory_phase0.timing import compile_timing
from .store import Store
from .pipeline import measure,structural,DURATIONS
from .diagnostics import numeric_strings,occlusion
VERSION='canonical-tree-continuation-1'
PREFIX='assets/first_party/tree_pilot_v1/'
ATTEMPT='DEV_DIAGNOSTIC_tree_5e47090652224f75a183823ebc8581cc'
SOURCE_HASH='1428fdbe34eb90c819905f7ec4c2f985391c862c8c0510fe6018efca4ec6ba5a'
RIGHTS_REVISION='tree-pilot-canonical-dev-authorization-v1'
POLICY_VERSION='tree-pilot-v1-exact-observation-calibration-1'
PINNED=['profile_id','asset_id','asset_version','attempt_id','job_id','request_id','family_id','style_family_id','template','style_calibration','world_authority','registration','source','normalized','animation']

def now():return datetime.now(timezone.utc).isoformat().replace('+00:00','Z')
def ref(store,path,evidence_id=None):
    return {'evidence_id':evidence_id or path.replace('/','_'),'artifact_ref':path,'sha256':sha(store.read(path))}
def review(m,gate,role,evidence,notes):
    return dict(schema_version='1',gate=gate,owner_role=role,timestamp=now(),
        **{k:m[k] for k in ['asset_id','asset_version','attempt_id']},result='passed',evidence=evidence,notes=notes)
def validator(id,gate,evidence):
    return dict(validator_id=id,validator_version=VERSION,gate=gate,result='passed',evidence=evidence)
def confirm_pins(original,current):
    if any(original[k]!=current[k] for k in PINNED):raise ValueError('reviewed contract changed')
def check_refs(value,artifacts):
    if isinstance(value,dict):
        if set(value)=={'evidence_id','artifact_ref','sha256'}:
            if value['artifact_ref'] not in artifacts or sha(artifacts[value['artifact_ref']])!=value['sha256']:raise ValueError('evidence identity mismatch')
        else:
            for v in value.values():check_refs(v,artifacts)
    elif isinstance(value,list):
        for v in value:check_refs(v,artifacts)

def approved_observations(store,m,grant):
    """The human accepted this exact observation set, not a numerical family limit."""
    if m['attempt_id']!=ATTEMPT or m['source']['files'][0]['sha256']!=SOURCE_HASH:raise PermissionError('human decision does not cover this pilot')
    for container in ['source','normalized']:
        for row in m[container]['files']:
            if sha(store.read(row['path']))!=row['sha256']:raise ValueError('approved source/normalized bytes changed')
    if grant.get('decisions')!={'technical_animation':'approved','pilot_motion_calibration':'approved','art_lead':'approved'}:raise PermissionError('required human decisions absent')
    if grant['attempt_id']!=m['attempt_id'] or grant['reviewed_manifest_hash']!=sha(store.read('human_hold_manifest.json')):raise PermissionError('decision does not bind reviewed manifest')
    if grant['measurement_hash']!=sha(store.read('evidence/development_motion_evidence.json')) or grant['diagnostic_proof_hash']!=sha(store.read('evidence/diagnostic_runtime_proof.json')):raise PermissionError('reviewed evidence changed')
    if grant['animation_hash']!=sha(canonical(m['animation'])):raise PermissionError('reviewed motion changed')
    if grant['source_files']!=m['source']['files'] or grant['normalized_files']!=m['normalized']['files']:raise PermissionError('review input identity changed')
    frames=[Image.open(io.BytesIO(store.read(f'normalized/frames/{i:02}.png'))).convert('RGBA') for i in range(len(DURATIONS))]
    atlas=Image.open(io.BytesIO(store.read('normalized/tree.png'))).convert('RGBA')
    if any(f.tobytes()!=atlas.crop(tuple([i*512,0,(i+1)*512,640])).tobytes() for i,f in enumerate(frames)):raise ValueError('frame/atlas mismatch')
    measurements=measure(frames)
    if canonical(measurements)!=store.read('evidence/development_motion_evidence.json'):raise ValueError('measured behavior differs from accepted observations')
    if m['animation']['durations_ms']!=DURATIONS:raise ValueError('approved timing changed')
    if structural(frames,json.loads(store.read('evidence/template.json')))['result']!='PASS':raise ValueError('structural regression')
    return measurements

class Continuation:
    def __init__(self,repo,root):
        self.repo=Path(repo);self.store=Store(root,repo)
        self.original=json.loads(self.store.read('human_hold_manifest.json'));validate_manifest(self.original)
        self.m=copy.deepcopy(self.original)
    def append_stage(self,next_m):
        confirm_pins(self.original,next_m)
        if not transition_allowed(self.m,next_m,RIGHTS_REVISION,self.store.artifacts(),{}):raise PermissionError('frozen adjacent transition refused')
        self.store.json('canonical/journal/'+next_m['lifecycle_stage']+'.json',next_m)
        self.m=copy.deepcopy(next_m)
    def resume(self,decision_path,grant):
        measurements=approved_observations(self.store,self.m,grant)
        decision=self.store.once('canonical/evidence/human_decision.txt',Path(decision_path).read_bytes())
        binding=self.store.json('canonical/evidence/human_decision_binding.json',dict(grant,decision=decision,
            trust_source='Direct explicit human message in this task; role reviews only; NOT authenticated production approval',
            production_authorized=False))
        calibration=self.store.json('canonical/evidence/pilot_calibration.json',{
            'policy_version':POLICY_VERSION,'scope':'this exact pilot and reviewed attempt only',
            'accepted_measurement_hash':grant['measurement_hash'],'accepted_observations':measurements,
            'asset_id':self.m['asset_id'],'asset_version':self.m['asset_version'],'attempt_id':ATTEMPT,
            'source_files':grant['source_files'],'normalized_files':grant['normalized_files'],
            'animation_hash':grant['animation_hash'],'human_decision':binding,
            'global_profile_state':'CANDIDATE_REQUIRES_CALIBRATION','global_tolerances_established':False,
            'machine_policy':'Exact accepted-observation identity and structural lock assertions; no new inequalities or global thresholds'})
        measured=self.store.json('canonical/evidence/motion_measurement_recheck.json',{'result':'passed','exact_reviewed_measurements_reproduced':True,'measurement':ref(self.store,'evidence/development_motion_evidence.json'),'pilot_calibration':calibration})
        self.m['disposition']='current'
        for e in self.m['rights_evaluations']:
            e['decision_revision']=RIGHTS_REVISION
            for assessment in e['assessments']:
                if assessment['outcome']=='permitted':assessment['evidence']+=[binding]
        rights=self.store.json('canonical/evidence/rights_action_binding.json',{'rights_decision_revision':RIGHTS_REVISION,'evaluations':self.m['rights_evaluations'],'basis':'Existing original first-party DEV rights plus current explicit canonical candidate/proof authorization; no production grant','decision':binding})
        self.m['provenance_evidence']+=[binding,rights]
        self.store.json('canonical/journal/resumed_structurally_validated.json',self.m)
        motion=review(self.m,'motion','technical_animator',[binding,calibration,measured,ref(self.store,'evidence/diagnostic_runtime_proof.json')],
            'Human explicitly approved exact source/motion and this pilot calibration. Conversation evidence is not a production signature.')
        motion['criteria_results']=[{'criterion_id':c,'result':'passed'} for c in load_contract('tree_profile')['required_motion_criteria']]
        self.store.json('canonical/evidence/technical_animation_review.json',motion)
        n=copy.deepcopy(self.m);n['lifecycle_stage']='motion_validated';n['motion_review']=motion;n['gates']['motion']={'status':'passed','record':motion}
        n['motion_policy_results']=[{'criterion_id':c,'kind':'CALIBRATED_VALUE','policy_version':POLICY_VERSION,'result':'passed','evidence':[calibration,measured]} for c in load_contract('tree_profile')['required_motion_policy_criteria']]
        for id in ['V-MOTION-MEASURE','V-MOTION-POLICY']:n['validator_results'][id]=validator(id,'motion',[calibration,measured])
        self.append_stage(n)
        visual=review(self.m,'visual','art_lead',[binding,ref(self.store,'evidence/style_calibration.json'),ref(self.store,'evidence/DEV_DIAGNOSTIC/actor_depth_contact_sheet.png')],
            'Human explicitly approved this exact tree visual revision under WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1; production publication not authorized.')
        self.store.json('canonical/evidence/art_lead_review.json',visual)
        n=copy.deepcopy(self.m);n['lifecycle_stage']='visual_qa';n['visual_review']=visual;n['gates']['visual']={'status':'passed','record':visual};self.append_stage(n)
        n=copy.deepcopy(self.m);n['lifecycle_stage']='preview';n['preview_evidence']=[ref(self.store,p,id) for p,id in [('evidence/root_baseline_overlay.png','root_baseline_overlay'),('evidence/scene_speed_loop.apng','scene_speed_loop'),('evidence/DEV_DIAGNOSTIC/actor_depth_contact_sheet.png','actor_before_behind_tree')]];self.append_stage(n)
        return self.m
    def compile(self):
        validate_manifest(self.m);confirm_pins(self.original,self.m);check_refs(self.m,self.store.artifacts())
        if self.m['lifecycle_stage']!='preview' or any(self.m['gates'][g]['status']!='passed' for g in ['structural','motion','visual']):raise PermissionError('canonical compile prerequisites absent')
        if not scopes_permitted(self.m,'candidate_compile',RIGHTS_REVISION):raise PermissionError('candidate compile rights blocked')
        binding=json.loads(self.store.read('canonical/evidence/human_decision_binding.json'));approved_observations(self.store,self.original,binding)
        if (self.store.root/'canonical/bundle').exists():raise FileExistsError('compile once: bundle already exists')
        oldprefix='assets/__DEV_DIAGNOSTIC_tree_pilot_v1__/'
        files={PREFIX+'tree.png':self.store.read('normalized/tree.png'),PREFIX+'shadow.png':self.store.read('normalized/shadow.png')}
        # Existing tested visual recipe; change only namespace, scene/clip display names.
        files[PREFIX+'tree_visual.tscn']=self.store.read('diagnostic_bundle/'+oldprefix+'tree_visual.tscn').decode().replace(oldprefix,PREFIX).replace('DEV_DIAGNOSTIC_TreeVisual','TreePilotVisual').replace('dev_wind','wind').encode()
        files[PREFIX+'tree_frames.tres']=compile_timing('res://'+PREFIX+'tree.png',self.m['animation']['frame_map'],self.m['animation']['durations_ms']).replace('diagnostic_nonuniform','wind').encode()
        files[PREFIX+'registration.json']=canonical({'registration':self.m['registration'],'world_authority_projection_hash':self.m['world_authority']['world_authority_projection_hash'],'template':self.m['template']})
        files[PREFIX+'rights_reference.json']=self.store.read('canonical/evidence/rights_action_binding.json')
        def params(p):return dict(line.split('=',1) for line in p.read_text().split('[params]\n',1)[1].splitlines() if '=' in line)
        policy={'policy_version':'godot-texture-import-1','tree_params':params(self.repo/'assets/first_party/storybook_mini_pack_001/normalized/tree_gentle_breeze.png.import'),'shadow_params':params(self.repo/'assets/first_party/storybook_mini_pack_001/normalized/contact_shadow.png.import'),'renderer':'gl_compatibility','texture_filter':'inherited_gameplay_default','speed_scale':'1','custom_speed':'1'}
        files[PREFIX+'import_policy.json']=canonical(policy)
        env={'python':sys.version,'dependencies':{k:importlib.metadata.version(k) for k in ['Pillow','numpy','jsonschema']},'godot':subprocess.check_output(['/Applications/Godot.app/Contents/MacOS/Godot','--version'],text=True).strip()}
        receipt={'recipe_version':VERSION,'compiler_code_hash':sha(Path(__file__).read_bytes()),'frozen_timing_code_hash':sha((self.repo/'tools/willicat_asset_factory_phase0/timing.py').read_bytes()),'git_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=self.repo,text=True).strip(),'environment':env,'environment_hash':sha(canonical(env)),'normalized_toolchain_fingerprint_hash':sha(canonical(self.m['normalized']['toolchain_fingerprint'])),'source_hash':SOURCE_HASH,'normalized_file_hashes':self.m['normalized']['files'],'compiled_outputs':[{'path':k,'sha256':sha(v)} for k,v in sorted(files.items())],'operation':'Copy approved PNGs and deterministically compile Godot resources once; no normalization, new pixels or source generation'}
        files[PREFIX+'compiler_receipt.json']=canonical(receipt)
        for k,v in files.items():self.store.once('canonical/bundle/'+k,v)
        root=self.store.root/'canonical/bundle'
        bundle=bundle_receipt(root,[{'logical_path':'res://'+k,'member_path':k} for k in sorted(files)],sha(files[PREFIX+'registration.json']),sha(files[PREFIX+'rights_reference.json']),sha(canonical(self.m['normalized']['toolchain_fingerprint'])))
        bundle_ref=self.store.json('canonical/candidate_bundle_receipt.json',bundle);h=check_bundle(root,bundle)
        n=copy.deepcopy(self.m);n['lifecycle_stage']='prefab';n['requested_action']='candidate_compile';n['candidate_bundle']={'candidate_bundle_hash':h,'receipt_ref':bundle_ref['artifact_ref'],'logical_prefab_path':'res://'+PREFIX+'tree_visual.tscn'};self.append_stage(n)
        return h
    def load_prefab(self):self.m=json.loads(self.store.read('canonical/journal/prefab.json'));validate_manifest(self.m);confirm_pins(self.original,self.m)
    def collect(self,project,captures):
        self.load_prefab();project=Path(project);captures=Path(captures)
        if any(Path('/private/tmp') not in p.resolve().parents or p.is_symlink() for p in [project,captures]):raise ValueError('isolated proof required')
        if not scopes_permitted(self.m,'integration_proof',RIGHTS_REVISION):raise PermissionError('proof rights blocked')
        bundle=json.loads(self.store.read('canonical/candidate_bundle_receipt.json'));h=check_bundle(self.store.root/'canonical/bundle',bundle)
        # check_bundle intentionally rejects cache/extra files; check exact mapped members in project instead.
        parity=all(sha((project/r['path']).read_bytes())==r['sha256'] for r in bundle['members'])
        before=json.loads((captures/'authority_before.json').read_text());after=json.loads((captures/'authority_after.json').read_text());obs=json.loads((captures/'canonical_runtime_observations.json').read_text());log=(captures/'run.log').read_text()
        if obs.get('scope')!='canonical_integration_proof' or obs.get('candidate_bundle_hash')!=h:raise ValueError('actual canonical proof identity absent')
        expected=self.m['world_authority']['world_authority_projection_hash'];front=occlusion(captures,'front');behind=occlusion(captures,'behind')
        samples=obs['registration_samples'];moving=[r for r in obs['actor_trace'] if any(r['actor_velocity'])]
        policy=json.loads(self.store.read('canonical/bundle/'+PREFIX+'import_policy.json'))
        def params(name):return dict(line.split('=',1) for line in (project/(PREFIX+name+'.png.import')).read_text().split('[params]\n',1)[1].splitlines() if '=' in line)
        effective={'tree_params':params('tree'),'shadow_params':params('shadow')}
        suppression=json.loads((project/'proxy_suppression.json').read_text())
        proxy_clean=all(Image.open(project/r['logical_path'].removeprefix('res://')).getchannel('A').getbbox() is None for r in suppression['rows'])
        checks={'bundle_parity':parity and h==self.m['candidate_bundle']['candidate_bundle_hash'],'authority_projection_preserved':projection_hash(before)==projection_hash(after)==expected,'actual_compiled_prefab_instantiated':obs['compiled_prefab_instantiated'],'effective_import_settings':all(effective[k]==policy[k] for k in effective),'runtime_import_observations':all(obs['runtime_import_checks'].values()),'timing':obs['exact_timing_weights_ms']==self.m['animation']['durations_ms'],'full_animation_playback':len(set(r['frame'] for r in obs['frame_change_observations']))==len(DURATIONS),'stable_root_sprite_shadow':bool(samples) and all(r==samples[0] for r in samples),'moving_actor':bool(moving),'front_and_behind':any(r['actor_behind_tree'] for r in moving) and any(not r['actor_behind_tree'] for r in moving),'rendered_depth':front['actor_visible_pixels']>0 and behind['actor_occluded_pixels']>0 and float(behind['nonzero_actor_pixel_fraction'])<float(front['nonzero_actor_pixel_fraction']),'routes':len(obs['routes'])==11 and all(r['success'] for r in obs['routes']),'trunk_obstruction':all(obs['collision_checks'].values()),'proxy_pixels_suppressed':proxy_clean,'no_runtime_errors':not any(s in log for s in ['ERROR:','SCRIPT ERROR:','Assertion failed']),'actual_viewport':obs['captured_frames']>0}
        if not all(checks.values()):raise ValueError('canonical proof failure: '+str({k:v for k,v in checks.items() if not v}))
        evidence=[]
        for p in sorted(captures.iterdir()):
            if p.is_file():evidence.append(self.store.once('canonical/evidence/runtime/'+p.name,p.read_bytes()))
        evidence.append(self.store.once('canonical/evidence/runtime/proxy_suppression.json',(project/'proxy_suppression.json').read_bytes()))
        proof=self.store.json('canonical/evidence/canonical_integration_proof.json',{'scope':'canonical_integration_proof','result':'passed','candidate_bundle_hash':h,'runtime_proof_bundle_hash':h,'authority_projection_hash':expected,'checks':checks,'effective_import_params':effective,'front_pixel_comparison':front,'behind_pixel_comparison':behind,'evidence':evidence,'runtime_runner_hash':sha((project/'CANONICAL_tree_proof.gd').read_bytes()),'cache_is_source_of_truth':False,'production_publication':False})
        runtime=review(self.m,'runtime','runtime_validator',[proof],'Fresh native Godot proof exercised exact immutable candidate at intended logical res:// paths; no source recompilation or production write.')
        self.store.json('canonical/evidence/runtime_review.json',runtime)
        n=copy.deepcopy(self.m);n['lifecycle_stage']='runtime_validated';n['requested_action']='integration_proof';n['gates']['runtime']={'status':'passed','record':runtime};n['runtime_proof']={'runtime_proof_bundle_hash':h,'authority_projection_hash':expected,'record':runtime}
        for id in ['V-WORLD-INTEGRITY','V-BUNDLE-PARITY']:n['validator_results'][id]=validator(id,'runtime',[proof])
        self.append_stage(n)
        # Stop before catalog/human_approved: user requested compile and proof only.
        status={'stage':self.m['lifecycle_stage'],'attempt_id':ATTEMPT,'candidate_bundle_hash':h,'runtime_proof_bundle_hash':h,'parity':'passed','rights_revision':RIGHTS_REVISION,'rights_candidate_compile':scopes_permitted(self.m,'candidate_compile',RIGHTS_REVISION),'rights_integration_proof':scopes_permitted(self.m,'integration_proof',RIGHTS_REVISION),'rights_publish':scopes_permitted(self.m,'publish',RIGHTS_REVISION),'derived_production_ready':production_ready(self.m,{}, {},self.store.artifacts()),'production_predicate_context':'Protected production ledger/credentials absent: frozen predicate fails closed; no eligible context fabricated','production':'blocked','final_authenticated_human_approval':'absent','next_step':'Review canonical evidence; separately authorize production rights and provision protected approval/publisher requirements before any publication'}
        self.store.json('canonical/result.json',status)
        self.store.pointer('current_canonical.json',ref(self.store,'canonical/journal/runtime_validated.json'))
        return status
