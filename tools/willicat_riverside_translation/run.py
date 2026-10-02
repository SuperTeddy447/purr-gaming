"""Open only a fresh temporary Riverside DEV project. No Home publication or save access."""
from pathlib import Path
import argparse,hashlib,json,shutil,subprocess,tempfile,sys
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT='/Applications/Godot.app/Contents/MacOS/Godot'
SCENE='scenes/dev/riverside_translation/DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.tscn'
def prepare(repo,project,source=None):
    repo=Path(repo).resolve();source=Path(source or repo).resolve();raw=Path(project)
    if not raw.is_absolute() or '..' in raw.parts or raw.is_symlink():raise ValueError('Fresh canonical /private/tmp project required')
    dst=raw.resolve()
    if dst.exists() or Path('/private/tmp').resolve() not in dst.parents:raise ValueError('Existing/protected projects refused')
    deps=[(source,'assets/dev_review/riverside_translation_v1'),(source,'scripts/dev/riverside_translation'),(source,'scenes/dev/riverside_translation'),(repo,'assets/dev_review/hybrid_cafe_painted_surface_v1'),(repo,'scripts/dev/world_hardening')]
    intake=[]
    for origin,rel in deps:
        for p in (origin/rel).rglob('*'):
            if p.is_symlink():raise ValueError('Source symlink refused')
            if p.is_file() and p.suffix not in ('.uid','.import'):
                if origin not in p.resolve().parents:raise ValueError('Path escape')
                intake.append((p,rel+'/'+str(p.relative_to(origin/rel))))
    for name in ['orange_down.png','orange_up.png','orange_left.png','orange_right.png','contact_shadow.png']:
        rel='assets/first_party/storybook_mini_pack_001/normalized/'+name;intake.append((repo/rel,rel))
    for name in ['capture_riverside_translation_v1.gd','test_riverside_input_depth_v1.gd']:
        p=source/'tests'/name
        if p.exists():intake.append((p,'tests/'+name))
    for p,rel in intake:
        if p.is_symlink() or not p.is_file() or not any(r in p.resolve().parents for r in [repo,source]):raise ValueError('Unsafe intake path')
    dst.mkdir(parents=True)
    for p,rel in intake:
        target=dst/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,target)
    (dst/'project.godot').write_text('''config_version=5
[application]
config/name="WilliCat Riverside Translation DEV"
run/main_scene="res://'''+SCENE+'''"
config/features=PackedStringArray("4.7", "Mobile")
config/use_custom_user_dir=true
config/custom_user_dir_name="WilliCatRiversideTranslationDEVV1"
[display]
window/size/viewport_width=540
window/size/viewport_height=960
window/size/window_width_override=540
window/size/window_height_override=960
window/stretch/mode="canvas_items"
[rendering]
renderer/rendering_method="mobile"
anti_aliasing/quality/msaa_3d=2
lights_and_shadows/directional_shadow/soft_shadow_filter_quality=2
''')
    receipt={'scope':'isolated DEV only; not production/canonical factory proof','project':str(dst),'original_home_loaded':False,'source_hashes':{rel:hashlib.sha256(p.read_bytes()).hexdigest() for p,rel in intake},'distinct_user_namespace':'WilliCatRiversideTranslationDEVV1'}
    (dst/'dev_intake_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');return receipt
def main():
    p=argparse.ArgumentParser();p.add_argument('--repo',default=str(REPO));p.add_argument('--project');p.add_argument('--prepare-only',action='store_true');args=p.parse_args()
    dst=Path(args.project) if args.project else Path(tempfile.mkdtemp(prefix='willicat_riverside_dev_',dir='/private/tmp'))/'project'
    prepare(args.repo,dst);print('Isolated Riverside DEV:',dst,flush=True)
    if not args.prepare_only:
        subprocess.run([GODOT,'--headless','--editor','--import','--path',str(dst),'--quit'],check=True)
        subprocess.run([GODOT,'--path',str(dst),'--rendering-method','mobile','--rendering-driver','metal'],check=True)
if __name__=='__main__':main()
