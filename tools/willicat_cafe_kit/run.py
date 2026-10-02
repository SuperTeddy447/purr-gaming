"""Open an isolated continuation of the DEV café review. No publication."""
import argparse,sys,tempfile,shutil,subprocess
from pathlib import Path
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT='/Applications/Godot.app/Contents/MacOS/Godot'
def prepare(repo,project,source=None):
 repo=Path(repo).resolve();source=Path(source or repo)
 sys.path.insert(0,str(repo/'tools'))
 from willicat_cafe_slice.run import prepare as previous
 project=previous(repo,project)
 for rel in ['assets/dev_review/cafe_interior_kit_v1','scripts/dev/cafe_interior_kit','scenes/dev/cafe_interior_kit']:
  shutil.copytree(source/rel,project/rel)
 for name in ['test_cafe_interior_kit_v1.gd','capture_cafe_interior_kit_v1.gd']:
  if (source/'tests'/name).exists():shutil.copy2(source/'tests'/name,project/'tests'/name)
 p=project/'project.godot';p.write_text(p.read_text().replace('scenes/dev/cafe_interior_slice/cafe_interior_slice_v1.tscn','scenes/dev/cafe_interior_kit/cafe_interior_kit_v1.tscn').replace('WilliCatCafeInteriorReviewV1','WilliCatCafeKitReviewV1').replace('Café Interior Review','Café Modular Kit Review'))
 return project
def main():
 p=argparse.ArgumentParser();p.add_argument('--repo',default=str(REPO));p.add_argument('--source');p.add_argument('--project');p.add_argument('--prepare-only',action='store_true');a=p.parse_args()
 dest=Path(a.project) if a.project else Path(tempfile.mkdtemp(prefix='willicat_cafe_kit_',dir='/private/tmp'))/'project'
 prepare(a.repo,dest,a.source);print('DEV café kit project:',dest,flush=True)
 if a.prepare_only:return
 subprocess.run([GODOT,'--headless','--editor','--import','--path',str(dest),'--quit'],check=True)
 subprocess.run([GODOT,'--path',str(dest)],check=True)
if __name__=='__main__':main()
