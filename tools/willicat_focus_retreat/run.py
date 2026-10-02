"""Create a local isolated playable preview. No production/world/art writes or compilation."""
from pathlib import Path
import argparse,sys,tempfile,shutil,json,subprocess,hashlib
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT='/Applications/Godot.app/Contents/MacOS/Godot'

def prepare(repo,project,source=None):
    repo=Path(repo).resolve();project=Path(project)
    if not project.is_absolute() or '..' in project.parts or project.is_symlink():raise ValueError('new isolated /private/tmp project required')
    project=project.resolve()
    if project.exists() or Path('/private/tmp').resolve() not in project.parents:raise ValueError('new isolated /private/tmp project required')
    sys.path.insert(0,str(repo/'tools'))
    from willicat_asset_factory_mvp.canonical_cli import inspect
    from willicat_asset_factory_mvp.canonical_proof import prepare as prepare_proof
    root=repo/'artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt'
    status=inspect(repo,root)
    if status['integrity']!='passed' or status['stage']!='runtime_validated':raise PermissionError('reviewed tree proof identity unavailable')
    prepare_proof(repo,root,project)
    source=Path(source or repo)
    for rel in ['scripts/dev/focus_retreat','scenes/dev/focus_retreat']:
        shutil.copytree(source/rel,project/rel,dirs_exist_ok=False)
    for name in ['test_focus_retreat_v1.gd','capture_focus_retreat_v1.gd']:
        if (source/'tests'/name).exists():shutil.copy2(source/'tests'/name,project/'tests'/name)
    config=(project/'project.godot').read_text().replace('config/name="WilliCat Canonical Candidate Proof"','config/name="WilliCat — Riverside Focus Preview"\nrun/main_scene="res://scenes/dev/focus_retreat/focus_retreat_v1.tscn"').replace('WilliCatMVP_CanonicalProof','WilliCatFocusRetreatPreviewV1').replace('viewport_width=960','viewport_width=1200').replace('viewport_height=640','viewport_height=800').replace('window_width_override=960','window_width_override=1200').replace('window_height_override=640','window_height_override=800')
    (project/'project.godot').write_text(config)
    receipt={'scope':'development-only focus gameplay preview','candidate_bundle_hash':status['bundle_hash'],'source_tree_regenerated':False,'protected_home_modified':False,'production_publication':False,'source_code_hashes':{str(p.relative_to(source)):hashlib.sha256(p.read_bytes()).hexdigest() for rel in ['scripts/dev/focus_retreat','scenes/dev/focus_retreat'] for p in sorted((source/rel).rglob('*')) if p.is_file()},'save_namespace':'WilliCatFocusRetreatPreviewV1 / willicat_focus_retreat_dev_v1.save','mobile_host':'not implemented; native Godot UI prototype, transport-independent command boundary'}
    (project/'focus_preview_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    return receipt

def main():
    p=argparse.ArgumentParser(description='Launch isolated WilliCat Riverside Focus playable preview')
    p.add_argument('--repo',default=str(REPO));p.add_argument('--project');p.add_argument('--prepare-only',action='store_true');a=p.parse_args()
    project=Path(a.project) if a.project else Path(tempfile.mkdtemp(prefix='willicat_focus_',dir='/private/tmp'))/'project'
    prepare(a.repo,project)
    print('Preview project:',project,flush=True)
    if a.prepare_only:return
    subprocess.run([GODOT,'--headless','--path',str(project),'--editor','--import','--quit'],check=True)
    subprocess.run([GODOT,'--path',str(project)],check=True)
if __name__=='__main__':main()
