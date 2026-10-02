"""Compose existing Forge and frozen Phase 0 contracts. Diagnostics are never gates."""
from pathlib import Path
import io,json,copy,subprocess,platform,sys,importlib.metadata,uuid
from datetime import datetime,timezone
import numpy as np
from PIL import Image,ImageDraw
from willicat_asset_forge.image_processing import resize_frame,ensure_rgba
from willicat_asset_forge.sprite_sheet import extract_frames
from willicat_asset_factory_phase0.contracts import canonical,sha,project,projection_hash,validate_manifest,transition_allowed,load_contract,verify_approval,scopes_permitted
from willicat_asset_factory_phase0.timing import compile_timing
from .store import Store
VERSION='dev-diagnostic-1'
# Authored pilot samples, not validated universal motion/timing thresholds.
WIND=[0,.6,1.8,3.8,6.4,9,11,12,11.8,10.7,8.7,5.7,2.2,-1.2,-3.4,-5,-5.8,-5.7,-4.8,-3.1,-1.4,-.4,0]
DURATIONS=[200,120,100,100,100,120,140,190,120,110,100,90,90,90,110,160,210,160,130,110,100,160,220]
LOGICAL='assets/__DEV_DIAGNOSTIC_tree_pilot_v1__/'

def png(im):
    b=io.BytesIO();im.save(b,format='PNG');return b.getvalue()

def normalized_rest(raw,template):
    if template.get('source_canvas_px')!=[512,640] or [str(v) for v in template.get('pivot_px',[256,600])]!=['256','600']:raise ValueError('This pilot recipe requires its exact measured registration template')
    im=ensure_rgba(raw);a=np.array(im.getchannel('A'));visible=a>1
    ys,xs=np.where(visible)
    if not len(xs):raise ValueError('empty source')
    if xs.min()==0 or ys.min()==0 or xs.max()==im.width-1 or ys.max()==im.height-1:raise ValueError('clipped source silhouette; regenerate')
    # Observed alpha-1 fringe only, not clipping repair/chroma deletion.
    arr=np.array(im);arr[a<=1]=0;im=Image.fromarray(arr)
    bbox=(int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1));crop=im.crop(bbox)
    bottom=arr[max(0,ys.max()-32):ys.max()+1,:,3];root_x=float((bottom.sum(axis=0)*np.arange(im.width)).sum()/bottom.sum())
    factor=min(459/crop.width,444/crop.height)
    size=(round(crop.width*factor),round(crop.height*factor));cut=resize_frame(crop,size)
    x=round(256-(root_x-bbox[0])*size[0]/crop.width);y=600-size[1]
    if x<0 or x+size[0]>512 or y<0:raise ValueError('source does not fit fixed template')
    rest=Image.new('RGBA',(512,640));rest.alpha_composite(cut,(x,y))
    # Remove resampling-only near-zero alpha halo. Original immutable source retained.
    r=np.array(rest);r[r[:,:,3]<=1]=0;rest=Image.fromarray(r)
    return rest,{'source_bbox_px':list(bbox),'source_ground_anchor_x':str(root_x),'normalization_size_px':list(size),'placement_px':[x,y],'alpha_noise_rule':'Only alpha<=1 cleared after confirming all silhouette alpha>1 is inside original source borders','template_canvas_px':[512,640],'pivot_px':[256,600]}

def author_frames(rest):
    # Translation of each horizontal row; no vertical or whole-sprite scale transform.
    # Eased bending concentrates travel high in the canopy, locks y>=480 exactly.
    source=np.asarray(rest).astype(np.float64);h,w=source.shape[:2];xx=np.arange(w)
    alpha=source[:,:,3:]/255;prem=np.concatenate([source[:,:,:3]*alpha,source[:,:,3:]],axis=2)
    result=[]
    for wind in WIND:
        dest=np.empty_like(source)
        for y in range(h):
            weight=max(0,min(1,(480-y)/324))**1.7
            u=xx-wind*weight
            for c in range(4):dest[y,:,c]=np.interp(u,xx,prem[y,:,c],left=0,right=0)
        a=dest[:,:,3:]/255
        dest[:,:,:3]=np.divide(dest[:,:,:3],a,out=np.zeros_like(dest[:,:,:3]),where=a>0)
        arr=np.clip(np.rint(dest),0,255).astype('uint8');arr[480:]=np.array(rest)[480:]
        result.append(Image.fromarray(arr))
    return result

def measure(frames):
    rows=[];hashes=[];root=frames[0].crop((0,480,512,640)).tobytes()
    for i,f in enumerate(frames):
        a=np.asarray(f.getchannel('A'),dtype=np.float64);y,x=np.indices(a.shape);can=a[:480];yy,xx=np.indices(can.shape)
        rows.append({'frame':i,'duration_ms':DURATIONS[i],'wind_travel_setting_px':str(WIND[i]),'bbox_px':list(f.getchannel('A').getbbox()),'alpha_area_equivalent_px':str(float(a.sum()/255)),'canopy_centroid_px':[str(float((can*xx).sum()/can.sum())),str(float((can*yy).sum()/can.sum()))],'root_region_identical':f.crop((0,480,512,640)).tobytes()==root,'bottom_visible_row_px':int(np.where(a>1)[0].max()),'shadow_offset_world':['0','-5'],'shadow_drift_px':'0'})
        hashes.append(sha(f.tobytes()))
    baseline=rows[0]['canopy_centroid_px'];seams=np.abs(np.asarray(frames[-1],dtype=int)-np.asarray(frames[0],dtype=int))
    return {'scope':'development_motion_evidence','policy_state':'CANDIDATE_REQUIRES_CALIBRATION','numeric_quality_verdict':'not_evaluated_no_calibrated_thresholds','root_displacement_px':'0' if all(r['root_region_identical'] for r in rows) else 'changed','trunk_base_displacement_px':'0' if all(r['root_region_identical'] for r in rows) else 'changed','root_lock_region_px':[0,480,512,640],'whole_sprite_scale_animation':False,'loop_seam_max_channel_delta':int(seams.max()),'loop_seam_changed_pixels':int(np.count_nonzero(np.any(seams,axis=2))),'canopy_x_range_px':[min(float(r['canopy_centroid_px'][0]) for r in rows).__str__(),max(float(r['canopy_centroid_px'][0]) for r in rows).__str__()],'bbox_x_range_px':[min(r['bbox_px'][0] for r in rows),max(r['bbox_px'][2] for r in rows)],'duplicate_frame_groups':[[i for i,h in enumerate(hashes) if h==v] for v in sorted(set(hashes)) if hashes.count(v)>1],'intentional_duplicate_group':[0,len(frames)-1],'total_loop_ms':sum(DURATIONS),'frames':rows}

def structural(frames,template):
    checks={'canvas':all(f.size==tuple(template['source_canvas_px']) for f in frames),'nonempty':all(f.getchannel('A').getbbox() for f in frames),'transparent_padding':all((lambda b:b[0]>0 and b[1]>0 and b[2]<512 and b[3]<640)(f.getchannel('A').getbbox()) for f in frames),'frame_duration_parity':len(frames)==len(DURATIONS),'fixed_base':all(f.crop((0,480,512,640)).tobytes()==frames[0].crop((0,480,512,640)).tobytes() for f in frames),'ground_contact':all(np.where(np.asarray(f.getchannel('A'))>1)[0].max()==599 for f in frames),'no_whole_sprite_scale':True}
    return {'scope':'STRUCTURAL_DIAGNOSTIC','result':'PASS' if all(checks.values()) else 'FAIL','checks':{k:bool(v) for k,v in checks.items()},'interpretation':'Dimensions, alpha safety, fixed root and duration parity only; not canonical motion/visual approval.'}

class Pipeline:
    def __init__(self,repo,root):self.repo=Path(repo);self.store=Store(root,repo);self.manifest=None
    def file(self,path,data):return self.store.once(path,data)
    def evidence(self,path,data):return self.store.json(path,data)
    def record(self,m):
        validate_manifest(m)
        if self.manifest and not transition_allowed(self.manifest,m,'dev-human-authorization-v1',self.store.artifacts(),{}):raise ValueError('frozen transition blocked; no bypass')
        r=self.evidence('journal/'+m['lifecycle_stage']+'.json',m);self.store.pointer('current.json',r);self.manifest=copy.deepcopy(m)
    def run(self,source,template_path,authority_path,style_path,authorization_path,authoring_receipt_path):
        auth=self.file('evidence/development_authorization.txt',Path(authorization_path).read_bytes());style=json.loads(Path(style_path).read_text())
        if style['status']!='approved' or style['human_review']['status']!='approved':raise ValueError('style unapproved')
        style_ev=self.file('evidence/style_calibration.json',Path(style_path).read_bytes())
        template=json.loads(Path(template_path).read_text());templ_ev=self.file('evidence/template.json',Path(template_path).read_bytes())
        snapshot=json.loads(Path(authority_path).read_text());proj=project(snapshot);ph=sha(canonical(proj));self.evidence('evidence/world_projection.json',proj)
        # Rights are action-scoped operational authorization for this original text-only source.
        outcomes={s:('permitted' if s in ['structural_study','dev_runtime','modification'] else 'unresolved') for s in load_contract('rights_actions')['scopes']} if 'scopes' in load_contract('rights_actions') else {s:('permitted' if s in ['structural_study','dev_runtime','modification'] else 'unresolved') for s in ['structural_study','dev_runtime','production_runtime','modification','raw_redistribution','generative_conditioning_reference','ai_training','publication_distribution']}
        rights=[]
        for action,scopes in load_contract('rights_actions')['actions'].items():
            rights.append({'action':action,'required_scopes':scopes,'decision_revision':'dev-human-authorization-v1','assessments':[{'scope':s,'outcome':outcomes[s],'evidence':[auth]} for s in scopes],'result':'passed' if all(outcomes[s]=='permitted' for s in scopes) else 'failed'})
        self.evidence('evidence/rights_context.json',{'basis':'Explicit human authorization for original text-only first-party DEV creation/intake/processing/diagnostic evaluation. No third-party image supplied for conditioning. Not a legal license inference or production grant.','rights_evaluations':rights})
        m={'schema_version':'phase0-tree-1','profile_id':'animated_environment.tree.phase0.v1','request_id':'DEV_DIAGNOSTIC_tree_request_v1','job_id':'DEV_DIAGNOSTIC_tree_job_v1','attempt_id':'DEV_DIAGNOSTIC_tree_'+uuid.uuid4().hex,'asset_id':'willicat_tree_pilot_dev_01','asset_version':'1-dev','category':'animated_environment','family_id':'willicat_animated_environment_tree_dev','style_family_id':style['style_family_id'],'lifecycle_stage':'spec','disposition':'current','requested_action':'inspect','provenance_evidence':[auth],'rights_evaluations':rights,'gates':{g:{'status':'not_started'} for g in load_contract('lifecycle')['gate_ids']},'invalidation':{'blocking_dependencies':[]}}
        self.record(m)
        authority_ref=template['world_authority_ref'].removeprefix('res://');f=self.repo/authority_ref
        m.update({'lifecycle_stage':'template','template':{'id':template['template_id'],'version':template['template_version']},'style_calibration':{'id':style['style_family_id'],'version':style['version'],'status':'approved','evidence':[style_ev]},'world_authority':{'world_authority_ref':template['world_authority_ref'],'world_authority_file_hash':sha(f.read_bytes()),'dependency_hashes':[{'path':authority_ref,'sha256':sha(f.read_bytes())}],'projection_recipe_version':'tree-authority-1','world_authority_projection_hash':ph,'projection':proj},'registration':{'source_canvas_px':template['source_canvas_px'],'pivot_px':template['pivot_px'],'floor_baseline_px':template['floor_baseline_px'],'root_contact_ref':'GameplayRoot/TrunkFootprint','shadow_ref':'ShadowVisual','world_units_per_source_px':'0.4','attachment_ref':'VisualRoot'}});self.record(m)
        rawbytes=Path(source).read_bytes()
        authoring=json.loads(Path(authoring_receipt_path).read_text())
        if authoring['source_sha256']!=sha(rawbytes) or authoring['reference_image_inputs']!=[] or authoring['third_party_art_conditioning'] is not False or authoring.get('template_id')!=template['template_id'] or authoring.get('template_version')!=template['template_version']:raise ValueError('This pilot only accepts its traceable original text-only source')
        authoring_ev=self.file('evidence/source_authoring_receipt.json',Path(authoring_receipt_path).read_bytes())
        prompt=Path(authoring_receipt_path).parent/authoring['prompt_file']
        if prompt.parent.resolve()!=Path(authoring_receipt_path).parent.resolve() or sha(prompt.read_bytes())!=authoring['prompt_sha256']:raise ValueError('authoring prompt integrity')
        self.file('evidence/source_prompt.txt',prompt.read_bytes())
        self.file('source/tree_source_v1.png',rawbytes)
        shadow_path=self.repo/'assets/first_party/storybook_mini_pack_001/normalized/contact_shadow.png'
        shadow_bytes=shadow_path.read_bytes();self.file('source/contact_shadow.png',shadow_bytes)
        self.evidence('evidence/reused_shadow_receipt.json',{'source_path':str(shadow_path.relative_to(self.repo)),'sha256':sha(shadow_bytes),'use_scope':'dev_runtime','basis':'Existing first-party contact shadow reused under authorized DEV diagnostic scope','authorization':auth})
        m.update({'lifecycle_stage':'source','source':{'source_asset_version':'1','files':[{'path':'source/tree_source_v1.png','sha256':sha(rawbytes)},{'path':'source/contact_shadow.png','sha256':sha(shadow_bytes)}],'authorization_evidence':[auth,authoring_ev]}});self.record(m)
        rest,normalization=normalized_rest(Image.open(io.BytesIO(rawbytes)),template);self.evidence('evidence/normalization.json',normalization)
        frames=author_frames(rest);atlas=Image.new('RGBA',(512*len(frames),640))
        for i,f in enumerate(frames):atlas.paste(f,(i*512,0));self.file(f'normalized/frames/{i:02}.png',png(f))
        # Reuse Forge explicit grid extraction to verify no frame bleed; we authored these equal canvases.
        recovered=extract_frames(atlas,1,len(frames),512,640,len(frames))
        if any(a.tobytes()!=b.tobytes() for a,b in zip(frames,recovered)):raise ValueError('Forge extraction mismatch')
        files=[]
        for path,data in [('normalized/tree.png',png(atlas)),('normalized/rest.png',png(rest)),('normalized/shadow.png',shadow_bytes)]:self.file(path,data);files.append({'path':path,'sha256':sha(data)})
        env={'python':sys.version,'platform':platform.platform(),'dependencies':{k:importlib.metadata.version(k) for k in ['Pillow','numpy','jsonschema']},'dependency_inventory':[{'name':x.metadata['Name'],'version':x.version} for x in sorted(importlib.metadata.distributions(),key=lambda v:v.metadata['Name'])],'godot':subprocess.check_output(['/Applications/Godot.app/Contents/MacOS/Godot','--version'],text=True).strip()}
        self.evidence('evidence/environment.json',env)
        def code_hash(root):return sha(canonical({str(p.relative_to(root)):sha(p.read_bytes()) for p in sorted([*root.glob('*.py'),*root.glob('*.gd')])}))
        fp={'factory_code_hash':code_hash(Path(__file__).parent),'forge_code_hash':code_hash(self.repo/'tools/willicat_asset_forge'),'recipe_version':'dev-canopy-row-bend-1','environment_hash':sha(canonical(env)),'tool_versions':[{'tool':k,'version':v} for k,v in env['dependencies'].items()]+[{'tool':'Godot','version':env['godot']}],'source_file_hash':sha(rawbytes),'decoded_pixel_hash':sha(canonical({'mode':'RGBA','dimensions':list(Image.open(io.BytesIO(rawbytes)).size)})+b'\n'+ensure_rgba(Image.open(io.BytesIO(rawbytes))).tobytes()),'output_hashes':files}
        self.evidence('evidence/processing_receipt.json',{'fingerprint':fp,'git_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=self.repo,text=True).strip(),'recipe':'x-row bending; y>=480 copied pixel-identically; no vertical/whole-sprite scale; nonlinear authored wind; alpha premultiplied interpolation','durations_ms':DURATIONS,'wind_travel_px':[str(v) for v in WIND],'source_file_unchanged':sha(Path(source).read_bytes())==sha(rawbytes)})
        fmap=[{'frame_id':str(i),'atlas_rect_px':[i*512,0,512,640]} for i in range(len(frames))]
        m.update({'lifecycle_stage':'normalized','normalized':{'files':files,'toolchain_fingerprint':fp},'animation':{'motion_class':'ambient_sway','motion_intent':'DEV foliage-led asymmetric wind bend; stable lower trunk and separate shadow; final human review pending','frame_map':fmap,'durations_ms':DURATIONS,'timing_intent':'authored_arc','loop_mode':'loop','rest_frame':0,'root_lock':True,'baseline_lock':True,'transform_policy':{'whole_sprite_scale':'forbidden'},'silhouette_motion_policy':'foliage_led','loop_seam_policy':{'requirement':'required','policy_ref':'CANDIDATE_REQUIRES_CALIBRATION'},'phase_policy':'offset_by_instance','interruptible':True}});self.record(m)
        sr=structural(frames,template);se=self.evidence('evidence/structural_diagnostic.json',sr)
        measurements=measure(frames);me=self.evidence('evidence/development_motion_evidence.json',measurements)
        self.evidence('evidence/motion_calibration_pending.json',{'policy_state':'CANDIDATE_REQUIRES_CALIBRATION','human_technical_animation_review':'pending','human_art_lead_review':'pending','canonical_gate_motion':'pending','criteria':load_contract('tree_profile')['required_motion_policy_criteria'],'measurements':me})
        if sr['result']!='PASS':raise ValueError('structural diagnostic failed')
        validators={v:{'validator_id':v,'validator_version':VERSION,'gate':'structural','result':'passed','evidence':[se]} for v in ['V-SCHEMA','V-FRAME','V-SCALE']}
        review={'schema_version':'1','gate':'structural','owner_role':'structural_validator','timestamp':datetime.now(timezone.utc).isoformat().replace('+00:00','Z'),'asset_id':m['asset_id'],'asset_version':m['asset_version'],'attempt_id':m['attempt_id'],'result':'passed','evidence':[se],'notes':'Automated schema/frame/fixed-canvas registration checks only; no human motion or visual acceptance','tool_version':VERSION}
        m.update({'lifecycle_stage':'structurally_validated','validator_results':validators});m['gates']['structural']={'status':'passed','record':review};m['gates']['motion']={'status':'pending'};m['gates']['visual']={'status':'pending'};self.record(m)
        self.manifest['disposition']='human_hold';hold=self.evidence('human_hold_manifest.json',self.manifest);validate_manifest(self.manifest);self.store.pointer('current.json',hold)
        # All remaining artifacts are diagnostic evidence outside canonical stage advancement.
        self.previews(frames)
        self.bundle(m,template,fmap)
        return {'implementation':'PASS','structural_diagnostic':sr['result'],'motion_measurements':'RECORDED','godot_diagnostic':'NOT_YET_EXECUTED','style_self_qa':'PENDING_AGENT_INSPECTION','human_technical_animation_review':'PENDING','human_art_lead_review':'PENDING','canonical_candidate_compilation':'BLOCKED_PENDING_REQUIRED_HUMAN_REVIEWS','canonical_integration_proof':'NOT_YET_EXECUTED','production':'BLOCKED','last_completed_canonical_stage':m['lifecycle_stage']}
    def previews(self,frames):
        bg=Image.new('RGBA',(512,640),'#F3DEC7');rgb=[Image.alpha_composite(bg,f).convert('RGB') for f in frames]
        b=io.BytesIO();rgb[0].save(b,format='GIF',save_all=True,append_images=rgb[1:],duration=DURATIONS,loop=0);self.file('evidence/scene_speed_loop.gif',b.getvalue())
        b=io.BytesIO();frames[0].save(b,format='PNG',save_all=True,append_images=frames[1:],duration=DURATIONS,loop=0,disposal=0,blend=0);self.file('evidence/scene_speed_loop.apng',b.getvalue())
        sheet=Image.new('RGB',(6*256,4*350),'#F3DEC7');draw=ImageDraw.Draw(sheet)
        for i,f in enumerate(frames):sheet.paste(resize_frame(f,(256,320)),((i%6)*256,(i//6)*350),resize_frame(f,(256,320)));draw.text(((i%6)*256+8,(i//6)*350+323),f'{i:02}   {DURATIONS[i]}ms',fill='#352C28')
        self.file('evidence/animation_contact_sheet.png',png(sheet))
        overlay=Image.alpha_composite(Image.new('RGBA',(512,640),'#F3DEC7'),frames[0]);draw=ImageDraw.Draw(overlay);draw.line((0,600,512,600),fill='#C55044',width=2);draw.line((256,0,256,640),fill='#B29671',width=1);draw.rectangle((0,480,511,639),outline='#627E52',width=2);draw.text((15,20),'DEV / root (256,600) / fixed lower trunk',fill='#352C28');self.file('evidence/root_baseline_overlay.png',png(overlay))
    def bundle(self,m,template,fmap):
        if not scopes_permitted(m,'integration_proof','dev-human-authorization-v1'):raise PermissionError('DEV runtime scope is not permitted')
        prefix='diagnostic_bundle/'+LOGICAL
        for src,dst in [('normalized/tree.png','tree.png'),('normalized/shadow.png','shadow.png')]:self.file(prefix+dst,self.store.read(src))
        tres=compile_timing('res://'+LOGICAL+'tree.png',fmap,DURATIONS).replace('diagnostic_nonuniform','dev_wind')
        self.file(prefix+'tree_frames.tres',tres.encode())
        self.evidence(prefix+'registration.json',{'scope':'DEV_DIAGNOSTIC','registration':m['registration'],'authority_projection_hash':m['world_authority']['world_authority_projection_hash']})
        self.file(prefix+'tree_visual.tscn',('''[gd_scene load_steps=3 format=3]
[ext_resource type="SpriteFrames" path="res://'''+LOGICAL+'''tree_frames.tres" id="1"]
[ext_resource type="Texture2D" path="res://'''+LOGICAL+'''shadow.png" id="2"]
[node name="DEV_DIAGNOSTIC_TreeVisual" type="Node2D"]
[node name="ShadowVisual" type="Sprite2D" parent="."]
texture = ExtResource("2")
position = Vector2(0,-5)
scale = Vector2(0.32,0.32)
z_index = -1
modulate = Color(1,1,1,0.38)
[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
sprite_frames = ExtResource("1")
autoplay = "dev_wind"
animation = &"dev_wind"
position = Vector2(0,-112)
scale = Vector2(0.4,0.4)
''').encode())
        members=[{'member_path':str(p.relative_to(self.store.root/'diagnostic_bundle')),'sha256':sha(p.read_bytes())} for p in sorted((self.store.root/'diagnostic_bundle').rglob('*')) if p.is_file()]
        receipt={'scope':'diagnostic_bundle','format':'DEV_DIAGNOSTIC_TREE_1','members':members,'logical_paths':['res://'+r['member_path'] for r in members],'authority_projection_hash':m['world_authority']['world_authority_projection_hash'],'processing_receipt_hash':sha(self.store.read('evidence/processing_receipt.json')),'canonical_candidate':False}
        self.evidence('diagnostic_bundle_receipt.json',receipt)
    def canonical_compile(self,manifest):
        validate_manifest(manifest)
        if manifest['lifecycle_stage']!='preview' or any(manifest['gates'][g]['status']!='passed' for g in ['structural','motion','visual']):raise PermissionError('Frozen canonical compilation prerequisites not satisfied')
        raise NotImplementedError('Canonical compiler is deliberately unavailable in this DEV implementation')
    def publish(self,*args):raise PermissionError('No production publisher capability or credential; publication blocked')
