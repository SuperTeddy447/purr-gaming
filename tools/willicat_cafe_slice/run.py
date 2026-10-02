"""Open one isolated DEV café slice; no production source/art/world publication."""
import argparse,sys,tempfile,json,shutil,subprocess
from pathlib import Path
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT='/Applications/Godot.app/Contents/MacOS/Godot'
def prepare(repo,project,source=None):
 repo=Path(repo).resolve();raw=Path(project)
 if not raw.is_absolute() or '..' in raw.parts or raw.is_symlink():raise ValueError('new isolated /private/tmp destination required')
 project=raw.resolve()
 if project.exists() or Path('/private/tmp') not in project.parents:raise ValueError('new isolated /private/tmp destination required')
 sys.path.insert(0,str(repo/'tools'))
 from willicat_asset_factory_mvp.canonical_proof import prepare as context
 context(repo,repo/'artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt',project)
 source=Path(source or repo)
 for rel in ['assets/dev_review/cafe_interior_slice_v1','scripts/dev/cafe_interior_slice','scenes/dev/cafe_interior_slice']:
  shutil.copytree(source/rel,project/rel)
 for name in ['test_cafe_interior_slice_v1.gd','capture_cafe_interior_slice_v1.gd']:
  if (source/'tests'/name).exists():shutil.copy2(source/'tests'/name,project/'tests'/name)
 config=(project/'project.godot').read_text().replace('config/name="WilliCat Canonical Candidate Proof"','config/name="WilliCat — Café Interior Review"\nrun/main_scene="res://scenes/dev/cafe_interior_slice/cafe_interior_slice_v1.tscn"').replace('WilliCatMVP_CanonicalProof','WilliCatCafeInteriorReviewV1').replace('viewport_width=960','viewport_width=640').replace('viewport_height=640','viewport_height=900').replace('window_width_override=960','window_width_override=640').replace('window_height_override=640','window_height_override=900')
 config+='\nenvironment/defaults/default_clear_color=Color(0.92,0.89,0.83,1)\n'
 (project/'project.godot').write_text(config)
 prep=json.loads((project/'proof_preparation.json').read_text());prep['scope']='DEV_REVIEW_CAFE_CONTEXT_PREPARATION';prep['canonical_integration_proof_executed']=False;(project/'proof_preparation.json').write_text(json.dumps(prep,indent=2)+'\n')
 (project/'cafe_preview_receipt.json').write_text(json.dumps({'scope':'DEV_REVIEW_CANDIDATE','source_art_regeneration':False,'production_publication':False,'world_sources':'unchanged isolated copy','unresolved_proxy_pixels':'suppressed','save_namespace':'WilliCatCafeInteriorReviewV1'},indent=2)+'\n')
 return project
def main():
 p=argparse.ArgumentParser(description='Open the isolated café interior playable review');p.add_argument('--repo',default=str(REPO));p.add_argument('--project');p.add_argument('--prepare-only',action='store_true');a=p.parse_args()
 dest=Path(a.project) if a.project else Path(tempfile.mkdtemp(prefix='willicat_cafe_',dir='/private/tmp'))/'project'
 prepare(a.repo,dest);print('DEV cafe project:',dest,flush=True)
 if a.prepare_only:return
 subprocess.run([GODOT,'--headless','--editor','--import','--path',str(dest),'--quit'],check=True)
 subprocess.run([GODOT,'--path',str(dest)],check=True)
if __name__=='__main__':main()
