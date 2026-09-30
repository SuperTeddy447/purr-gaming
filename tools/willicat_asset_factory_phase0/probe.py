"""Bounded reproducible diagnostic proof. Outputs only below caller's temporary root."""
from pathlib import Path
import json,subprocess,sys,shutil,platform,importlib.metadata
from .contracts import canonical,sha,project,projection_hash
from .filesystem import write_once,bundle_receipt,check_bundle,promote_simulation
from .timing import compile_timing

def run(repo,work,evidence):
    repo=Path(repo);work=Path(work);evidence=Path(evidence);work.mkdir(exist_ok=True);evidence.mkdir(parents=True,exist_ok=True)
    sys.path.insert(0,str(repo/'tools'))
    prefix='assets/first_party/__phase0_diagnostic_tree__/'
    candidate=work/'candidate';candidate.mkdir()
    def import_params(path):
        section=path.read_text().split('[params]\n',1)[1]
        return dict(line.split('=',1) for line in section.splitlines() if '=' in line)
    source=repo/'assets/first_party/storybook_mini_pack_001/normalized/tree_gentle_breeze.png'
    shadow=source.parent/'contact_shadow.png'
    files={prefix+'tree.png':source.read_bytes(),prefix+'shadow.png':shadow.read_bytes()}
    frames=[{'frame_id':'diagnostic_'+str(i),'atlas_rect_px':[i*512,0,512,640]} for i in range(4)]
    files[prefix+'tree_frames.tres']=compile_timing('res://'+prefix+'tree.png',frames,[100,300,150,450]).encode()
    files[prefix+'tree.tscn']=('''[gd_scene load_steps=3 format=3]
[ext_resource type="SpriteFrames" path="res://'''+prefix+'''tree_frames.tres" id="1"]
[ext_resource type="Texture2D" path="res://'''+prefix+'''shadow.png" id="2"]
[node name="Phase0DiagnosticVisual" type="Node2D"]
[node name="ShadowVisual" type="Sprite2D" parent="."]
texture = ExtResource("2")
position = Vector2(0, -5)
scale = Vector2(0.32, 0.32)
z_index = -1
modulate = Color(1, 1, 1, 0.38)
[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
sprite_frames = ExtResource("1")
position = Vector2(0, -112)
scale = Vector2(0.4, 0.4)
''').encode()
    snapshot=json.loads((evidence/'authority_snapshot.json').read_text());projection=project(snapshot);ph=sha(canonical(projection))
    (evidence/'world_projection.json').write_bytes(canonical(projection))
    files[prefix+'registration.json']=canonical({'projection_hash':ph,'authority_ref':'res://scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn','diagnostic_scope':'existing binding observation, not approved production template'})
    import_policy={'policy_version':'godot-texture-import-1','tree_params':import_params(source.with_suffix('.png.import')),'shadow_params':import_params(shadow.with_suffix('.png.import')),'renderer':'gl_compatibility','default_speed_scale':'1','default_custom_speed':'1'}
    files[prefix+'import_policy.json']=canonical(import_policy)
    files[prefix+'rights_reference.json']=canonical({'evidence_ref':'WILLICAT_ASSET_FACTORY_PHASE_0_CONTRACT_LOCK_V1 user authorization','dev_runtime':'diagnostic_only','production_runtime':'unresolved','publication_distribution':'unresolved'})
    from PIL import Image
    im=Image.open(source).convert('RGBA')
    decoded=sha(canonical({'mode':'RGBA','width':im.width,'height':im.height})+b'\n'+im.tobytes())
    environment={'python':sys.version,'platform':platform.platform(),'pillow':importlib.metadata.version('Pillow'),'jsonschema':importlib.metadata.version('jsonschema'),'openssl':subprocess.check_output(['/usr/bin/openssl','version'],text=True).strip()}
    inventory=sorted([{'distribution':d.metadata['Name'],'version':d.version} for d in importlib.metadata.distributions()],key=lambda v:v['distribution'])
    environment['dependency_inventory_hash']=sha(canonical(inventory))
    environment['forge_requirements_hash']=sha((repo/'tools/willicat_asset_forge/requirements.txt').read_bytes())
    environment['godot']=subprocess.check_output(['/Applications/Godot.app/Contents/MacOS/Godot','--version'],text=True).strip()
    tool_root=Path(__file__).parent
    inputs=list(tool_root.glob('*.py'))+list(tool_root.glob('*.gd'))+list((tool_root/'contracts').glob('*.json'))
    code={str(p.relative_to(tool_root)):sha(p.read_bytes()) for p in inputs}
    forge_code={p.name:sha(p.read_bytes()) for p in (repo/'tools/willicat_asset_forge').glob('*.py')}
    fingerprint={'factory_code_hash':sha(canonical(code)),'forge_code_hash':sha(canonical(forge_code)),'recipe_version':'godot-ms-weight-1','environment_hash':sha(canonical(environment)),'tool_versions':[{'tool':k,'version':v} for k,v in environment.items()],'source_file_hash':sha(files[prefix+'tree.png']),'decoded_pixel_hash':decoded,'output_hashes':[{'path':k,'sha256':sha(v)} for k,v in sorted(files.items())]}
    files[prefix+'processing_receipt.json']=canonical({'fingerprint':fingerprint,'environment':environment,'package_inventory':inventory,'git_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),'durations_ms':[100,300,150,450],'diagnostic_only':True,'decoded_pixel_recipe':'RGBA dimensions canonical header + newline + row-major RGBA bytes; no color transform','source_unchanged':sha(source.read_bytes())==fingerprint['source_file_hash']})
    for path,data in files.items():write_once(candidate,path,data)
    mapping=[{'logical_path':'res://'+k,'member_path':k} for k in files]
    receipt=bundle_receipt(candidate,mapping,sha(files[prefix+'registration.json']),sha(files[prefix+'rights_reference.json']),sha(canonical(fingerprint)))
    bundle_hash=sha(canonical(receipt));(evidence/'candidate_bundle_receipt.json').write_bytes(canonical(receipt));(evidence/'processing_receipt.json').write_bytes(files[prefix+'processing_receipt.json'])
    proof=work/'proof_project';proof.mkdir()
    promote_simulation(candidate,proof,receipt,bundle_hash)  # only copies into TEMP, no approval claim
    (proof/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Phase0TimingDiagnostic"\nconfig/use_custom_user_dir=true\nconfig/custom_user_dir_name="WilliCatPhase0TimingDiagnostic"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
    binary='/Applications/Godot.app/Contents/MacOS/Godot'
    for label,args in [('timing_import',['--editor','--import','--quit']),('timing_playback',['--script',str(Path(__file__).parent/'timing_probe.gd'),'--',str(evidence/'timing_round_trip.json')])]:
        p=subprocess.run([binary,'--headless','--path',str(proof),*args],capture_output=True,text=True,timeout=60)
        (evidence/(label+'.log')).write_text(p.stdout+p.stderr)
        if p.returncode:raise RuntimeError(label+' failed')
    proof_hash=check_bundle(proof,receipt)
    publication=work/'simulated_release';publication.mkdir();published_hash=promote_simulation(candidate,publication,receipt,bundle_hash)
    # Fresh import on simulated release: same logical paths, same engine and explicit import policy.
    (publication/'project.godot').write_bytes((proof/'project.godot').read_bytes())
    r=subprocess.run([binary,'--headless','--path',str(publication),'--editor','--import','--quit'],capture_output=True,text=True,timeout=60)
    (evidence/'simulated_release_import.log').write_text(r.stdout+r.stderr)
    if r.returncode:raise RuntimeError('simulated release import failed')
    def effective(root):return {'tree_params':import_params(root/(prefix+'tree.png.import')),'shadow_params':import_params(root/(prefix+'shadow.png.import'))}
    proof_params=effective(proof);release_params=effective(publication)
    expected={k:import_policy[k] for k in ['tree_params','shadow_params']}
    assert proof_params==release_params==expected
    assert check_bundle(publication,receipt)==bundle_hash
    (evidence/'import_parity.json').write_bytes(canonical({'equal':True,'proof_effective_params':proof_params,'simulated_release_effective_params':release_params,'proof_bundle_hash':proof_hash,'simulated_release_bundle_hash':published_hash,'cache_in_identity':False}))
    # Simulated approval identifies exact bytes only; no production or human decision is claimed.
    parity={'scope':'SIMULATED BYTE PROMOTION ONLY — NOT HUMAN APPROVAL/PUBLICATION','candidate_bundle_hash':bundle_hash,'runtime_proof_bundle_hash':proof_hash,'approved_bundle_hash':bundle_hash,'published_bundle_hash':published_hash,'logical_paths_identical':True,'compile_invocations':1,'import_cache_excluded':True,'godot_version':subprocess.check_output([binary,'--version'],text=True).strip()}
    (evidence/'bundle_parity.json').write_bytes(canonical(parity))
    result={'same_data':projection_hash(snapshot)==ph,'unrelated_edit':None,'relevant_edit':None,'ordering':None,'missing_field_rejected':False,'projection_hash':ph}
    import copy
    s=copy.deepcopy(snapshot);s['unrelated_decoration']='changed copied snapshot only';result['unrelated_edit']=projection_hash(s)==ph
    s=copy.deepcopy(snapshot);s['global_transform'][4]+=1;result['relevant_edit']=projection_hash(s)!=ph
    s=dict(reversed(list(snapshot.items())));s['depth_chain']=list(reversed(s['depth_chain']));result['ordering']=projection_hash(s)==ph
    s=copy.deepcopy(snapshot);del s['stable_id']
    try:projection_hash(s)
    except (KeyError,ValueError):result['missing_field_rejected']=True
    assert all(result[k] for k in ['same_data','unrelated_edit','relevant_edit','ordering','missing_field_rejected'])
    (evidence/'projection_tests.json').write_bytes(canonical(result))
    print(json.dumps(parity,indent=2))

if __name__=='__main__':run(*sys.argv[1:])
