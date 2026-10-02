"""Fresh temporary DEV refinement project; no production world/save access."""
from pathlib import Path
import sys,importlib.util,json,hashlib,shutil,tempfile,argparse,subprocess
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT='/Applications/Godot.app/Contents/MacOS/Godot'
SCENE='scenes/dev/riverside_refinement_v2/DEV_WILLICAT_RIVERSIDE_3D_ART_REFINEMENT_V2.tscn'
def prepare(repo,project,source=None):
 repo=Path(repo).resolve();source=Path(source or repo).resolve();dst=Path(project)
 spec=importlib.util.spec_from_file_location('v1_runner',repo/'tools/willicat_riverside_translation/run.py');v1=importlib.util.module_from_spec(spec);spec.loader.exec_module(v1)
 # V1 enforces fresh canonical temporary destinations and refuses traversal/symlink escapes.
 receipt=v1.prepare(repo,dst,repo);dst=dst.resolve()
 for rel in ['assets/dev_review/riverside_refinement_v2','scripts/dev/riverside_refinement_v2','scenes/dev/riverside_refinement_v2','tests']:
  for p in (source/rel).rglob('*'):
   if rel=='tests' and 'refinement_v2' not in p.name:continue
   if p.is_symlink():raise ValueError('Source symlink refused')
   if not p.is_file() or p.suffix in ['.uid','.import']:continue
   if source not in p.resolve().parents:raise ValueError('Source path escape')
   path=p.relative_to(source);target=dst/path
   if target.exists():raise ValueError('V2 must not overwrite V1 intake')
   target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,target);receipt['source_hashes'][str(path)]=hashlib.sha256(p.read_bytes()).hexdigest()
 text=(dst/'project.godot').read_text().replace(v1.SCENE,SCENE).replace('WilliCatRiversideTranslationDEVV1','WilliCatRiversideRefinementDEVV2').replace('WilliCat Riverside Translation DEV','WilliCat Riverside Art Refinement DEV V2')
 (dst/'project.godot').write_text(text);receipt['distinct_user_namespace']='WilliCatRiversideRefinementDEVV2';receipt['scope']='isolated additive V2 DEV refinement';(dst/'dev_intake_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');return receipt
def main():
 p=argparse.ArgumentParser();p.add_argument('--repo',default=str(REPO));p.add_argument('--project');p.add_argument('--prepare-only',action='store_true');a=p.parse_args()
 dst=Path(a.project) if a.project else Path(tempfile.mkdtemp(prefix='willicat_riverside_v2_',dir='/private/tmp'))/'project';prepare(a.repo,dst);print('Isolated V2 DEV:',dst,flush=True)
 if not a.prepare_only:
  subprocess.run([GODOT,'--headless','--editor','--import','--path',str(dst),'--quit'],check=True)
  subprocess.run([GODOT,'--path',str(dst),'--rendering-method','mobile','--rendering-driver','metal'],check=True)
if __name__=='__main__':main()
