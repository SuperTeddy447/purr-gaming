"""TEST FIXTURE — NOT PRODUCTION TRUST ROOT. Synthetic decisions are never asset approvals."""
from pathlib import Path
import base64,copy,json,os,subprocess,tempfile,unittest
from willicat_asset_factory_phase0.contracts import *
from willicat_asset_factory_phase0.filesystem import *
from willicat_asset_factory_phase0.timing import compile_timing

E=Path(os.environ['PHASE0_EVIDENCE_DIR'])

def sign(payload,key,d):
    (d/'payload').write_bytes(canonical(payload))
    subprocess.run(['/usr/bin/openssl','dgst','-sha256','-sign',str(key),'-sigopt','rsa_padding_mode:pss','-sigopt','rsa_pss_saltlen:32','-sigopt','rsa_mgf1_md:sha256','-out',str(d/'signature'),str(d/'payload')],check=True,capture_output=True)
    return {'payload':payload,'signed_payload_hash':sha(canonical(payload)),'signature':base64.b64encode((d/'signature').read_bytes()).decode(),'algorithm':'RSA-PSS-SHA256-MGF1SHA256-SALT32'}

class ContractProof(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp=tempfile.TemporaryDirectory(prefix='TEST_FIXTURE_NOT_PRODUCTION_TRUST_ROOT_');d=Path(cls.tmp.name);cls.d=d
        cls.key=d/'TEST_ONLY_private.pem'
        subprocess.run(['/usr/bin/openssl','genrsa','-out',str(cls.key),'3072'],check=True,capture_output=True)
        pub=subprocess.check_output(['/usr/bin/openssl','rsa','-in',str(cls.key),'-pubout'],stderr=subprocess.DEVNULL,text=True)
        cls.trust={'revision':'TEST_TRUST_1','credentials':{'TEST_ONLY_key':{'public_key_pem':pub,'principal':'TEST_ONLY_reviewer','roles':['final_human_reviewer'],'state':'active','test_fixture':True}}}
        cls.files={};cls.evs=[]
        def ev(id,data=b'TEST FIXTURE EVIDENCE ONLY'):
            path='fixtures/'+id+'.json';cls.files[path]=data
            x={'evidence_id':id,'artifact_ref':path,'sha256':sha(data)};cls.evs.append(x);return x
        diag=ev('motion_loop');rights=ev('rights');style=ev('style');invalidate=ev('invalidation')
        for id in load_contract('tree_profile')['required_review_evidence']:ev(id)
        def review(g,role):return {'schema_version':'1','gate':g,'owner_role':role,'timestamp':'2026-09-30T00:00:00Z','asset_id':'TEST_ONLY_tree','asset_version':'TEST_ONLY_1','attempt_id':'TEST_ONLY_attempt','result':'passed','evidence':[diag],'notes':'TEST FIXTURE ONLY; no real asset or human decision','tool_version':'TEST_TOOL_1'}
        m={'schema_version':'phase0-tree-1','profile_id':'animated_environment.tree.phase0.v1','request_id':'TEST_ONLY_request','job_id':'TEST_ONLY_job','attempt_id':'TEST_ONLY_attempt','asset_id':'TEST_ONLY_tree','asset_version':'TEST_ONLY_1','category':'animated_environment','family_id':'TEST_ONLY','style_family_id':'TEST_ONLY_style','lifecycle_stage':'human_approved','disposition':'current','requested_action':'publish','provenance_evidence':[rights],'rights_evaluations':[],'gates':{},'invalidation':{'blocking_dependencies':[]},'template':{'id':'TEST_ONLY_template','version':'1'},'style_calibration':{'id':'TEST_ONLY_style','version':'1','status':'approved','evidence':[style]}}
        p=project(json.loads((E/'authority_snapshot.json').read_text()));ph=sha(canonical(p))
        m['world_authority']={'world_authority_ref':'TEST_ONLY_copy_of_Home','world_authority_file_hash':'1'*64,'dependency_hashes':[{'path':'TEST_ONLY_scene','sha256':'1'*64}],'projection_recipe_version':'tree-authority-1','world_authority_projection_hash':ph,'projection':p}
        # Geometry registration fixture is explicitly synthetic; not a new Home/template measurement.
        m['registration']={'source_canvas_px':[512,640],'pivot_px':['256','600'],'floor_baseline_px':'600','root_contact_ref':'TEST_ONLY_GameplayRoot','shadow_ref':'TEST_ONLY_Shadow','world_units_per_source_px':'0.4','attachment_ref':'VisualRoot'}
        cls.files['source.bin']=b'TEST_ONLY_SOURCE';cls.files['normalized.bin']=b'TEST_ONLY_NORMALIZED'
        src={'path':'source.bin','sha256':sha(cls.files['source.bin'])};norm={'path':'normalized.bin','sha256':sha(cls.files['normalized.bin'])}
        m['source']={'source_asset_version':'TEST_ONLY_1','files':[src],'authorization_evidence':[rights]}
        fingerprint={'factory_code_hash':'1'*64,'forge_code_hash':'2'*64,'recipe_version':'TEST_ONLY_recipe','environment_hash':'3'*64,'tool_versions':[{'tool':'TEST_ONLY','version':'1'}],'source_file_hash':src['sha256'],'decoded_pixel_hash':'4'*64,'output_hashes':[norm]}
        m['normalized']={'files':[norm],'toolchain_fingerprint':fingerprint}
        m['animation']={'motion_class':'ambient_sway','motion_intent':'TEST_ONLY foliage sway','frame_map':[{'frame_id':str(i),'atlas_rect_px':[i*512,0,512,640]} for i in range(4)],'durations_ms':[100,300,150,450],'timing_intent':'authored_arc','loop_mode':'loop','rest_frame':0,'root_lock':True,'baseline_lock':True,'transform_policy':{'whole_sprite_scale':'forbidden'},'silhouette_motion_policy':'foliage_led','loop_seam_policy':{'requirement':'required','policy_ref':'TEST_ONLY_CALIBRATION_1'},'phase_policy':'offset_by_instance','interruptible':True}
        for g in load_contract('lifecycle')['gate_ids']:
            r=review(g,{'motion':'technical_animator','visual':'art_lead','human':'final_human_reviewer'}.get(g,'TEST_ONLY_validator'))
            if g=='motion':r['criteria_results']=[{'criterion_id':id,'result':'passed'} for id in load_contract('tree_profile')['required_motion_criteria']]
            m['gates'][g]={'status':'passed','record':r};ev('review_'+g,canonical(r))
        m['motion_review']=m['gates']['motion']['record'];m['visual_review']=m['gates']['visual']['record']
        m['motion_policy_results']=[{'criterion_id':id,'kind':'CALIBRATED_VALUE','policy_version':'TEST_ONLY_CALIBRATION_1','result':'passed','evidence':[diag]} for id in load_contract('tree_profile')['required_motion_policy_criteria']]
        for action in ['publish','rollback']:
            scopes=load_contract('rights_actions')['actions'][action]
            m['rights_evaluations'].append({'action':action,'required_scopes':scopes,'decision_revision':'TEST_RIGHTS_1','assessments':[{'scope':s,'outcome':'permitted','evidence':[rights]} for s in scopes],'result':'passed'})
        m['validator_results']={}
        for gate in ['structural','motion','runtime']:
            for id in load_contract('tree_profile')['required_validators'][gate]:
                record={'validator_id':id,'validator_version':'TEST_ONLY_1','gate':gate,'result':'passed','evidence':[diag]}
                m['validator_results'][id]=record
                ev('validator_'+id,canonical(record))
        m['preview_evidence']=[diag]
        cls.files['runtime.bin']=b'TEST_ONLY_RUNTIME_BUNDLE'
        receipt={'bundle_format_version':'tree-candidate-1','resource_map':[{'logical_path':'res://runtime.bin','member_path':'runtime.bin'}],'members':[{'path':'runtime.bin','sha256':sha(cls.files['runtime.bin'])}],'registration_hash':'5'*64,'rights_reference_hash':'6'*64,'timing_recipe_version':'godot-ms-weight-1','toolchain_fingerprint_hash':sha(canonical(fingerprint))}
        cls.files['receipt.json']=canonical(receipt);bh=sha(canonical(receipt))
        m['candidate_bundle']={'candidate_bundle_hash':bh,'receipt_ref':'receipt.json','logical_prefab_path':'res://runtime.bin'}
        m['runtime_proof']={'runtime_proof_bundle_hash':bh,'authority_projection_hash':ph,'record':m['gates']['runtime']['record']}
        m['catalog_entry_ref']='TEST_ONLY_catalog_entry'
        payload={'approval_schema_version':'phase0-approval-1','asset_id':m['asset_id'],'asset_version':m['asset_version'],'job_id':m['job_id'],'attempt_id':m['attempt_id'],'template':m['template'],'style_calibration':{'id':'TEST_ONLY_style','version':'1'},'world_authority_projection_hash':ph,'rights_decision_revision':'TEST_RIGHTS_1','gate_results':{g:'passed' for g in m['gates'] if g!='human'},'evidence':cls.evs,'runtime_proof_bundle_hash':bh,'approved_bundle_hash':bh,'reviewer_principal':'TEST_ONLY_reviewer','reviewer_role':'final_human_reviewer','credential_id':'TEST_ONLY_key','decision':'approve','timestamp':'2026-09-30T00:00:00Z'}
        payload['asset_contract_hash']=sha(canonical(asset_contract_view(m)))
        m['human_approval']=sign(payload,cls.key,d)
        cls.manifest=m;cls.context={'schema_version':'phase0-context-1','action':'publish','current_attempt_id':m['attempt_id'],'rights_decision_revision':'TEST_RIGHTS_1','current_template':m['template'],'current_style_calibration':payload['style_calibration'],'style_status':'approved','current_world_projection_hash':ph,'compatibility_affirmations':[],'required_evidence_ids':['review_'+g for g in m['gates']],'trusted_review_record_hashes':[sha(canonical(r['record'])) for r in m['gates'].values()],'bundle_hash':bh,'published_bundle_hash':bh,'release_eligibility':'eligible','trust_store_revision':'TEST_TRUST_1','credential_id':'TEST_ONLY_key'}
        cls.context['blocking_dependencies']=[]
        cls.context['current_motion_policy_versions']={r['criterion_id']:r['policy_version'] for r in m['motion_policy_results']}
        (E/'test_only_signed_manifest.json').write_text(json.dumps({'label':'TEST FIXTURE — NOT PRODUCTION TRUST ROOT; synthetic approvals only','manifest':m},indent=2)+'\n')
        (E/'test_only_context.json').write_text(json.dumps(cls.context,indent=2)+'\n')
        (E/'test_only_trust.json').write_text(json.dumps(cls.trust,indent=2)+'\n')
        (E/'test_only_artifact_bytes.json').write_text(json.dumps({k:base64.b64encode(v).decode() for k,v in cls.files.items()},indent=2)+'\n')
    @classmethod
    def tearDownClass(cls):cls.tmp.cleanup()
    def setUp(self):self.m=copy.deepcopy(self.manifest);self.c=copy.deepcopy(self.context);self.t=copy.deepcopy(self.trust);self.f=copy.deepcopy(self.files)
    def ready(self):return production_ready(self.m,self.c,self.t,self.f,True)
    def test_positive_synthetic_predicate(self):self.assertTrue(self.ready())
    def test_fixture_credential_not_production(self):self.assertFalse(production_ready(self.m,self.c,self.t,self.f))
    def test_auth_verifier_accepts_exact_fixture(self):self.assertTrue(verify_approval(self.m['human_approval'],self.t,True))
    def test_auth_tampered_payload(self):self.m['human_approval']['payload']['asset_version']='changed';self.assertFalse(self.ready())
    def test_auth_revoked_credential(self):self.t['credentials']['TEST_ONLY_key']['state']='revoked';self.assertFalse(self.ready())
    def test_auth_unknown_credential(self):del self.t['credentials']['TEST_ONLY_key'];self.assertFalse(self.ready())
    def test_auth_forged_role(self):self.m['human_approval']={'role':'human','decision':'approve'};self.assertFalse(self.ready())
    def test_signed_wrong_attempt(self):p=self.m['human_approval']['payload'];p['attempt_id']='other';self.m['human_approval']=sign(p,self.key,self.d);self.assertFalse(self.ready())
    def test_rights_action_independent(self):self.c['action']='rollback';self.m['rights_evaluations'][1]['assessments'][0]['outcome']='unresolved';p=self.m['human_approval']['payload'];p['asset_contract_hash']=sha(canonical(asset_contract_view(self.m)));self.m['human_approval']=sign(p,self.key,self.d);self.assertFalse(self.ready());self.c['action']='publish';self.assertTrue(self.ready())
    def test_rights_prohibited(self):self.m['rights_evaluations'][0]['assessments'][0]['outcome']='prohibited';self.assertFalse(self.ready())
    def test_rights_not_applicable_not_permission(self):self.m['rights_evaluations'][0]['assessments'][0]['outcome']='not_applicable';self.assertFalse(self.ready())
    def test_rights_exact_scope_set(self):self.m['rights_evaluations'][0]['required_scopes']=['production_runtime'];self.assertFalse(self.ready())
    def test_active_release_revocation(self):self.c['release_eligibility']='revoked';self.assertFalse(self.ready())
    def test_rollback_current_rights(self):self.c['action']='rollback';self.c['rights_decision_revision']='revoked_revision';self.assertFalse(self.ready())
    def test_rollback_current_authority(self):self.c['action']='rollback';self.c['current_world_projection_hash']='0'*64;self.assertFalse(self.ready())
    def test_uncalibrated_motion(self):self.m['motion_policy_results'][0]['policy_version']='CANDIDATE_REQUIRES_CALIBRATION';self.assertFalse(self.ready())
    def test_jelly_rejected_despite_numbers(self):self.m['motion_review']['result']='failed';self.assertTrue(all(r['result']=='passed' for r in self.m['motion_policy_results']));self.assertFalse(self.ready())
    def test_required_frame_validator_missing(self):self.m['validator_results'].pop('V-FRAME');self.assertFalse(self.ready())
    def test_current_dependency_blocker(self):self.c['blocking_dependencies']=['calibration_changed'];self.assertFalse(self.ready())
    def test_stale_motion_policy(self):self.c['current_motion_policy_versions']['root_drift']='changed';self.assertFalse(self.ready())
    def test_no_writable_override(self):self.m['production_ready']=True;self.assertFalse(self.ready())
    def test_unsigned_contract_change_rejected(self):self.m['registration']['floor_baseline_px']='601';self.assertFalse(self.ready())
    def test_bundle_bytes_must_exist(self):del self.f['runtime.bin'];self.assertFalse(self.ready())
    def test_runtime_member_tamper(self):self.f['runtime.bin']+=b'x';self.assertFalse(self.ready())
    def test_human_criterion_rejects_numeric_pass(self):self.m['motion_review']['criteria_results'][0]['result']='failed';self.assertFalse(self.ready())
    def test_human_criteria_missing(self):self.m['motion_review'].pop('criteria_results');self.assertFalse(self.ready())
    def test_root_lock_required(self):self.m['animation']['root_lock']=False;self.assertFalse(self.ready())
    def test_durations_count(self):self.m['animation']['durations_ms'].pop();self.assertFalse(self.ready())
    def test_duplicate_frame_id(self):self.m['animation']['frame_map'][1]['frame_id']='0';self.assertFalse(self.ready())
    def test_stage_progression_obligations(self):
        stages=load_contract('lifecycle')['stages'];new=load_contract('tree_profile')['required_by_stage']
        for stage in stages:
            m=copy.deepcopy(self.m);m['lifecycle_stage']=stage;validate_manifest(m)
            for field in new[stage]:
                x=copy.deepcopy(m);x.pop(field,None)
                with self.subTest(stage=stage,missing=field),self.assertRaises(Exception):validate_manifest(x)
    def test_empty_semantic_containers(self):
        for field,value in [('asset_id',''),('source',{}),('preview_evidence',[]),('animation',{}),('normalized',{})]:
            with self.subTest(field=field):self.m=copy.deepcopy(self.manifest);self.m[field]=value;self.assertFalse(self.ready())
    def transition_fixture(self):
        a=copy.deepcopy(self.m);b=copy.deepcopy(self.m);a['lifecycle_stage']='cataloged';return a,b
    def test_adjacent_transition(self):
        a,b=self.transition_fixture();self.assertTrue(transition_allowed(a,b,'TEST_RIGHTS_1',self.f,self.t,True))
    def test_skip_transition_rejected(self):
        a,b=self.transition_fixture();a['lifecycle_stage']='preview';self.assertFalse(transition_allowed(a,b,'TEST_RIGHTS_1',self.f,self.t,True))
    def test_transition_artifact_tamper(self):
        a,b=self.transition_fixture();self.f['normalized.bin']=b'changed';self.assertFalse(transition_allowed(a,b,'TEST_RIGHTS_1',self.f,self.t,True))
    def test_transition_changed_pin_rejected(self):
        a,b=self.transition_fixture();b['template']['version']='2';self.assertFalse(transition_allowed(a,b,'TEST_RIGHTS_1',self.f,self.t,True))
    def test_transition_unresolved_rights_rejected(self):
        a,b=self.transition_fixture();b['rights_evaluations'][0]['assessments'][0]['outcome']='unresolved';self.assertFalse(transition_allowed(a,b,'TEST_RIGHTS_1',self.f,self.t,True))
    def test_transition_contract_complete(self):
        l=load_contract('lifecycle');self.assertEqual(len(l['transitions']),11)
        for i,t in enumerate(l['transitions']):
            self.assertEqual([t['from_stage'],t['to_stage']],l['stages'][i:i+2]);self.assertTrue(t['required_evidence']);self.assertTrue(t['required_scopes'])
    def test_schemas_parse_and_self_validate(self):
        for file in ROOT.glob('*.schema.json'):Draft202012Validator.check_schema(json.loads(file.read_text()))
    def test_canonical_key_order(self):self.assertEqual(canonical({'a':1,'b':2}),canonical({'b':2,'a':1}))
    def test_duplicate_json_keys_rejected(self):
        with self.assertRaises(ValueError):parse_json('{"a":1,"a":2}')
    def test_float_signing_rejected(self):
        with self.assertRaises(ValueError):canonical({'a':0.1})
    def test_projection_five_cases(self):
        x=json.loads((E/'projection_tests.json').read_text());self.assertTrue(all(x[k] for k in ['same_data','unrelated_edit','relevant_edit','ordering','missing_field_rejected']))
    def test_projection_negative_zero(self):self.assertEqual(decimal_string(-0.0),'0')
    def test_projection_nonfinite_rejected(self):
        with self.assertRaises(ValueError):decimal_string(float('nan'))
    def test_tree_negative_control_unapproved(self):self.m['lifecycle_stage']='normalized';self.m['gates']['motion']={'status':'not_started'};self.m['gates']['visual']={'status':'not_started'};self.m.pop('human_approval');self.assertFalse(self.ready())

negative_cases={
 '01_missing_human':lambda s:s.m.pop('human_approval'),
 '02_invalid_signature':lambda s:s.m['human_approval'].update(signature='AAAA'),
 '03_unresolved_rights':lambda s:s.m['rights_evaluations'][0]['assessments'][0].update(outcome='unresolved'),
 '04_stale_rights':lambda s:s.c.update(rights_decision_revision='REVISION_CHANGED'),
 '05_structural_failed':lambda s:s.m['gates']['structural'].update(status='failed'),
 '06_missing_motion_human':lambda s:s.m.pop('motion_review'),
 '07_visual_failed':lambda s:s.m['gates']['visual'].update(status='failed'),
 '08_runtime_failed':lambda s:s.m['gates']['runtime'].update(status='failed'),
 '09_stale_world':lambda s:s.c.update(current_world_projection_hash='0'*64),
 '10_incompatible_template':lambda s:s.c['current_template'].update(version='changed'),
 '11_stale_style':lambda s:s.c['current_style_calibration'].update(version='changed'),
 '12_changed_evidence':lambda s:s.f.update({'fixtures/motion_loop.json':b'tampered'}),
 '13_approved_not_proof':lambda s:s.m['runtime_proof'].update(runtime_proof_bundle_hash='0'*64),
 '14_published_not_approved':lambda s:s.c.update(published_bundle_hash='0'*64),
 '15_superseded':lambda s:s.m.update(disposition='superseded'),
 '16_cancelled':lambda s:s.m.update(disposition='cancelled'),
 '17_missing_validator_evidence':lambda s:s.f.pop('fixtures/review_structural.json')}
for name,mutator in negative_cases.items():
    def test(self,mutator=mutator):mutator(self);self.assertFalse(self.ready())
    setattr(ContractProof,'test_predicate_'+name,test)

class FilesystemProof(unittest.TestCase):
    def setUp(self):self.tmp=tempfile.TemporaryDirectory(dir='/private/tmp');self.root=Path(self.tmp.name);(self.root/'source').mkdir();(self.root/'dest').mkdir()
    def tearDown(self):self.tmp.cleanup()
    def test_real_production_root_rejected(self):
        with self.assertRaises(ValueError):safe_path(Path(os.environ['PHASE0_REPO'])/'assets','asset.png')
    def test_atomic_concurrent_updates(self):
        from concurrent.futures import ThreadPoolExecutor
        values=[(str(i)*4096).encode() for i in range(1,5)]
        with ThreadPoolExecutor(4) as pool:list(pool.map(lambda data:atomic_pointer(self.root/'dest','active.json',data),values))
        self.assertIn((self.root/'dest/active.json').read_bytes(),values)
    def test_traversal_rejected(self):
        for path in ['../escaped','x/../../escaped','/tmp/absolute','x\\..\\escape']:
            with self.subTest(path=path),self.assertRaises(ValueError):write_once(self.root/'source',path,b'x')
    def test_symlink_escape_rejected(self):
        (self.root/'source/link').symlink_to(self.root/'dest',target_is_directory=True)
        with self.assertRaises(ValueError):write_once(self.root/'source','link/escape',b'x')
        self.assertFalse((self.root/'dest/escape').exists())
    def test_dangling_symlink_rejected(self):
        (self.root/'source/link').symlink_to(self.root/'nonexistent')
        with self.assertRaises(ValueError):write_once(self.root/'source','link',b'x')
    def test_source_write_once(self):
        write_once(self.root/'source','x',b'original')
        with self.assertRaises(FileExistsError):write_once(self.root/'source','x',b'replacement')
        self.assertEqual((self.root/'source/x').read_bytes(),b'original')
    def receipt(self):
        write_once(self.root/'source','assets/tree.bin',b'original')
        return bundle_receipt(self.root/'source',[{'logical_path':'res://assets/tree.bin','member_path':'assets/tree.bin'}],'1'*64,'2'*64,'3'*64)
    def test_copy_parity_no_compile(self):
        r=self.receipt();h=sha(canonical(r));self.assertEqual(promote_simulation(self.root/'source',self.root/'dest',r,h),h)
    def test_bundle_mutation_invalidation(self):
        r=self.receipt();p=self.root/'source/assets/tree.bin';p.chmod(0o600);p.write_bytes(b'changed')
        with self.assertRaises(ValueError):check_bundle(self.root/'source',r)
    def test_logical_path_identity(self):
        r=self.receipt();write_once(self.root/'source','assets/other.bin',b'original')
        changed=bundle_receipt(self.root/'source',[{'logical_path':'res://assets/other.bin','member_path':'assets/other.bin'}],'1'*64,'2'*64,'3'*64)
        self.assertNotEqual(sha(canonical(r)),sha(canonical(changed)))
    def test_rebuild_needs_new_cycle(self):
        r=self.receipt()
        with self.assertRaises(FileExistsError):write_once(self.root/'source','assets/tree.bin',b'rebuilt')
    def test_cache_not_identity(self):
        r=self.receipt();(self.root/'source/.godot').mkdir();(self.root/'source/.godot/cache').write_bytes(b'cache changed')
        self.assertEqual(check_bundle(self.root/'source',r),sha(canonical(r)))
    def test_interrupt_keeps_previous_pointer(self):
        atomic_pointer(self.root/'dest','active.json',b'old')
        with self.assertRaises(InterruptedError):atomic_pointer(self.root/'dest','active.json',b'new',interrupt=True)
        self.assertEqual((self.root/'dest/active.json').read_bytes(),b'old')
    def test_partial_copy_no_pointer(self):
        r=self.receipt();write_once(self.root/'dest','assets/tree.bin',b'partial')
        with self.assertRaises(FileExistsError):promote_simulation(self.root/'source',self.root/'dest',r,sha(canonical(r)))
        self.assertFalse((self.root/'dest/active.json').exists())

class TimingProof(unittest.TestCase):
    def test_nonuniform_round_trip(self):
        r=json.loads((E/'timing_round_trip.json').read_text());self.assertEqual(r['manifest_durations_ms'],r['recovered_durations_ms']);self.assertEqual(r['runtime_playing_speed'],1.0)
    def test_legacy_writer_unchanged(self):
        from willicat_asset_forge.godot_export import generate_sprite_frames_tres
        s=generate_sprite_frames_tres('res://a.png',4,512,640,5.0,True,'original');self.assertEqual(s.count('"duration": 1.0'),4);self.assertIn('"speed": 5.0',s)
    def test_nonuniform_wrapper(self):
        frames=[{'atlas_rect_px':[i*512,0,512,640]} for i in range(4)]
        s=compile_timing('res://a.png',frames,[100,300,150,450]);self.assertIn('"speed": 1000.0',s)
        for d in [100,300,150,450]:self.assertIn('"duration": '+str(d)+'.0',s)
    def test_import_policy_proof_release_equal(self):
        r=json.loads((E/'import_parity.json').read_text());self.assertTrue(r['equal']);self.assertEqual(r['proof_bundle_hash'],r['simulated_release_bundle_hash'])
    def test_unsupported_fractional_timing_rejected(self):
        with self.assertRaises(ValueError):compile_timing('res://a.png',[{'atlas_rect_px':[0,0,512,640]}],[100.5])
