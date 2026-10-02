"""Collect development evidence. This module cannot confer canonical runtime approval."""
from pathlib import Path
import json, subprocess, shutil
import numpy as np
from PIL import Image
from willicat_asset_factory_phase0.contracts import sha,canonical,projection_hash,validate_manifest
from .store import Store
from .pipeline import DURATIONS

def check_bundle(store,project):
    receipt=json.loads(store.read('diagnostic_bundle_receipt.json'))
    if receipt['scope']!='diagnostic_bundle' or receipt['canonical_candidate'] is not False:raise ValueError('wrong proof scope')
    members=[]
    for row in receipt['members']:
        rel=row['member_path'];data=store.read('diagnostic_bundle/'+rel)
        if sha(data)!=row['sha256']:raise ValueError('diagnostic bundle changed')
        p=Path(project)/rel
        if p.is_symlink() or any(x.is_symlink() for x in p.parents):raise ValueError('project symlink')
        if sha(p.read_bytes())!=row['sha256']:raise ValueError('logical res:// member differs in actual proof project')
        members.append(row)
    return {'diagnostic_bundle_hash':sha(canonical(receipt)),'proof_project_member_hashes':members,'logical_path_identity':True,'canonical_integration_proof':False}

def numeric_strings(value):
    if type(value) is float:return str(value)
    if isinstance(value,list):return [numeric_strings(x) for x in value]
    if isinstance(value,dict):return {k:numeric_strings(v) for k,v in value.items()}
    return value

def occlusion(directory,prefix):
    def a(s):return np.asarray(Image.open(directory/(prefix+'_'+s+'.png')).convert('RGB'))
    actor=a('actor_only');background=a('background');combined=a('combined');tree=a('tree_only')
    actor_mask=np.any(actor!=background,axis=2)
    visible=np.any(combined!=tree,axis=2)&actor_mask
    n=int(actor_mask.sum());v=int(visible.sum())
    if not n:raise ValueError('no rendered actor comparison pixels')
    return {'actor_alone_pixels':n,'actor_visible_pixels':v,'actor_occluded_pixels':n-v,'nonzero_actor_pixel_fraction':str(v/n),'actor_alone_rgb_difference_sum':str(int(np.abs(actor.astype(int)-background.astype(int))[actor_mask].sum())),'composited_actor_rgb_difference_sum':str(int(np.abs(combined.astype(int)-tree.astype(int))[actor_mask].sum())),'method':'Exact RGB pixel differences at frozen same-pose viewport renders; comparison evidence only, no quality threshold'}

def collect(repo,root,project,capture_dir):
    store=Store(root,repo);directory=Path(capture_dir)
    project=Path(project)
    for p in [project,directory]:
        if Path('/private/tmp') not in p.resolve().parents or p.is_symlink():raise ValueError('isolated temporary project/capture directory required')
    parity=check_bundle(store,project)
    suppression=json.loads((project/'proxy_suppression.json').read_text())
    if suppression['runtime_proxy_pixels']!='suppressed':raise PermissionError('unresolved proxy pixels must be suppressed')
    for row in suppression['rows']:
        path=project/row['logical_path'].removeprefix('res://')
        im=Image.open(path).convert('RGBA')
        if im.getchannel('A').getbbox() is not None or sha(path.read_bytes())!=row['diagnostic_transparent_placeholder_sha256']:raise PermissionError('unverified proxy runtime pixels present')
    before=json.loads((directory/'authority_before.json').read_text());after=json.loads((directory/'authority_after.json').read_text())
    m=json.loads(store.read('human_hold_manifest.json'));validate_manifest(m)
    expected=m['world_authority']['world_authority_projection_hash']
    obs=json.loads((directory/'diagnostic_runtime_observations.json').read_text());log=(directory/'run.log').read_text()
    if obs['scope']!='diagnostic_runtime_proof' or obs['canonical_integration_proof'] is not False:raise ValueError('wrong diagnostic scope')
    front=occlusion(directory,'front');behind=occlusion(directory,'behind')
    samples=obs['registration_samples'];trace=obs['actor_trace'];moving=[r for r in trace if any(r['actor_velocity'])]
    stable=bool(samples) and all(r==samples[0] for r in samples)
    timing=[r for r in obs['frame_change_observations'] if r['engine_elapsed_seconds']>=trace[0]['time']]
    checks={'no_godot_errors':not any(s in log for s in ['ERROR:','SCRIPT ERROR:','Assertion failed']),
        'authority_projection_preserved':projection_hash(before)==projection_hash(after)==expected,
        'all_existing_route_legs_reached':len(obs['routes'])==11 and all(r['success'] for r in obs['routes']),
        'nonuniform_timing_resource_parity':all(round(x)==d for x,d in zip(obs['timing_weights_ms'],DURATIONS)) and len(obs['timing_weights_ms'])==len(DURATIONS),
        'actual_frame_playback':len(set(r['frame'] for r in timing))==len(DURATIONS),
        'root_sprite_shadow_transforms_stable':stable,
        'actual_moving_character':bool(moving),
        'front_and_behind_positions':any(r['actor_behind_tree'] for r in moving) and any(not r['actor_behind_tree'] for r in moving),
        'rendered_front_actor_visible':front['actor_visible_pixels']>0,
        'rendered_behind_actor_occluded':behind['actor_occluded_pixels']>0 and float(behind['nonzero_actor_pixel_fraction'])<float(front['nonzero_actor_pixel_fraction']),
        'diagnostic_logical_bundle_parity':parity['logical_path_identity'],
        'actual_nonempty_viewport_capture':obs['captured_frames']>0 and np.array(Image.open(directory/'01_actor_in_front.png')).std()>0}
    checks={k:bool(v) for k,v in checks.items()}
    if not all(checks.values()):raise ValueError('Diagnostic checks failed: '+str({k:v for k,v in checks.items() if not v}))
    prefix='evidence/DEV_DIAGNOSTIC/'
    for path in sorted(directory.glob('*.png')):store.once(prefix+path.name,path.read_bytes())
    store.once(prefix+'proxy_suppression.json',(project/'proxy_suppression.json').read_bytes())
    for name in ['authority_before.json','authority_after.json','diagnostic_runtime_observations.json','run.log']:
        store.once(prefix+name,(directory/name).read_bytes())
    # Exact source sequence stays in temporary cache; deliver normal-speed encoded evidence.
    ffmpeg=shutil.which('ffmpeg') or '/opt/homebrew/bin/ffmpeg'
    mp4=directory/'DEV_DIAGNOSTIC_moving_actor_tree.mp4';gif=directory/'DEV_DIAGNOSTIC_moving_actor_tree.gif'
    commands=[[ffmpeg,'-y','-framerate','20','-i',str(directory/'frames/%05d.png'),'-c:v','libx264','-pix_fmt','yuv420p','-crf','18',str(mp4)],
              [ffmpeg,'-y','-i',str(mp4),'-vf','fps=12,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse',str(gif)]]
    media=[]
    for args in commands:
        result=subprocess.run(args,capture_output=True,check=True)
        media.append({'output':Path(args[-1]).name,'sha256':sha(Path(args[-1]).read_bytes())})
    for path in [mp4,gif]:store.once(prefix+path.name,path.read_bytes())
    receipt={'suppressed_proxy_texture_count':len(suppression['rows']),'proxy_use':'No third-party DEV proxy pixels in this diagnostic world','scope':'diagnostic_runtime_proof','result':'PASS','checks':checks,'bundle_parity':parity,'authority_projection_before':projection_hash(before),'authority_projection_after':projection_hash(after),'front_pixel_comparison':front,'behind_pixel_comparison':behind,'actual_character_motion_samples':len(moving),'registration_samples':len(samples),'captured_frames':obs['captured_frames'],'frame_durations_ms':DURATIONS,'engine_frame_changes':numeric_strings(timing),'media':media,'ffmpeg_version':subprocess.check_output([ffmpeg,'-version'],text=True).splitlines()[0],'diagnostic_script_hash':sha((project/'DEV_DIAGNOSTIC_tree.gd').read_bytes()),'human_technical_animation_review':'PENDING','human_art_lead_review':'PENDING','canonical_integration_proof':'NOT_YET_EXECUTED','canonical_candidate_compilation':'BLOCKED_PENDING_REQUIRED_HUMAN_REVIEWS','production':'BLOCKED'}
    store.json('evidence/diagnostic_runtime_proof.json',receipt)
    return receipt

def prepare(repo,root,project):
    """Temporary world copy; unresolved DEV proxies contribute no raster pixels."""
    from .qa import inspect_live
    inspect_live(repo,root);repo=Path(repo);project=Path(project)
    if Path('/private/tmp') not in project.parents or project.exists():raise ValueError('new /private/tmp diagnostic project required')
    target=Store(project,repo);source=Store(root,repo)
    tracked=subprocess.check_output(['git','ls-files','-z'],cwd=repo).decode().split('\0')
    prefixes=('assets/','scripts/','Scripts/','scenes/','tests/','data/','resources/')
    count=0
    for rel in tracked:
        if rel.startswith(('assets/dev_proxy/','assets/Fonts/','scenes/Levels/')):continue
        if rel.startswith(prefixes) or rel in ['Icon.png','icon.svg']:
            f=repo/rel
            if f.is_file():target.once(rel,f.read_bytes());count+=1
    # Read headers and hashes for permitted structural study, not art conditioning.
    suppressed=[]
    for f in sorted((repo/'assets/dev_proxy').rglob('*.png')):
        rel=str(f.relative_to(repo));dims=Image.open(f).size
        b=__import__('io').BytesIO();Image.new('RGBA',dims).save(b,format='PNG');data=b.getvalue()
        target.once(rel,data)
        suppressed.append({'logical_path':'res://'+rel,'dimensions_px':list(dims),'source_metadata_sha256':sha(f.read_bytes()),'diagnostic_transparent_placeholder_sha256':sha(data)})
    for rel in ['docs/references/WILLICAT_HOME_CAMERA_PROTOTYPE_V2_1.png','docs/references/mochi/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT.png','docs/references/home/WILLICAT_HOME_ENVIRONMENT_STYLE_LOCK_V1.png']:
        target.once(rel,(repo/rel).read_bytes())
    receipt=json.loads(source.read('diagnostic_bundle_receipt.json'))
    for row in receipt['members']:target.once(row['member_path'],source.read('diagnostic_bundle/'+row['member_path']))
    target.once('DEV_DIAGNOSTIC_tree.gd',(Path(__file__).parent/'DEV_DIAGNOSTIC_tree.gd').read_bytes())
    target.once('project.godot',b'''config_version=5
[application]
config/name="WilliCat DEV_DIAGNOSTIC Tree Pilot"
config/use_custom_user_dir=true
config/custom_user_dir_name="WilliCatMVP_DEV_DIAGNOSTIC"
[display]
window/size/viewport_width=960
window/size/viewport_height=640
window/size/window_width_override=960
window/size/window_height_override=640
[rendering]
renderer/rendering_method="gl_compatibility"
''')
    # Disposable copy may be reimported by Godot; attempt/source/evidence remain write-once.
    for p in project.rglob('*'):
        if p.is_file():p.chmod(0o600)
    policy={'scope':'DEV_DIAGNOSTIC temporary project only','runtime_proxy_pixels':'suppressed','geometry_and_gameplay_files':'byte-identical to tracked authority','original_repository_modified':False,'rows':suppressed}
    (project/'proxy_suppression.json').write_text(json.dumps(policy,indent=2)+'\n')
    return {'project':str(project),'copied_tracked_files':count,'suppressed_proxy_textures':len(suppressed),'diagnostic_bundle_hash':sha(canonical(receipt)),'canonical_integration_proof':False}
