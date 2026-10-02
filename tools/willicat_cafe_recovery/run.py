"""Isolated9:16 DEV visual-framing proof; canonical world/camera stay unchanged."""
import argparse,sys,tempfile,shutil,subprocess
from pathlib import Path
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT='/Applications/Godot.app/Contents/MacOS/Godot'
def prepare(repo,project,source=None):
 repo=Path(repo).resolve();source=Path(source or repo);sys.path.insert(0,str(repo/'tools'))
 from willicat_cafe_kit.run import prepare as previous
 project=Path(project).resolve()
 temp_root=Path('/private/tmp').resolve()
 if not project.is_relative_to(temp_root) or project.exists():
  raise ValueError('Use a fresh isolated project under /private/tmp; existing projects and repository paths are refused.')
 project=previous(repo,project)
 for rel in ['assets/dev_review/cafe_visual_recovery_v1','scripts/dev/cafe_visual_recovery','scenes/dev/cafe_visual_recovery']:
  shutil.copytree(source/rel,project/rel)
 for p in (source/'tests').glob('*cafe_visual_recovery*.gd'):shutil.copy2(p,project/'tests'/p.name)
 p=project/'project.godot';p.write_text(p.read_text().replace('scenes/dev/cafe_interior_kit/cafe_interior_kit_v1.tscn','scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn').replace('viewport_width=640','viewport_width=576').replace('viewport_height=900','viewport_height=1024').replace('window_width_override=640','window_width_override=504').replace('window_height_override=900','window_height_override=896').replace('WilliCatCafeKitReviewV1','WilliCatCafeVisualRecoveryV1').replace('Café Modular Kit Review','Café Visual Recovery Review'))
 return project
def main():
 p=argparse.ArgumentParser();p.add_argument('--repo',default=str(REPO));p.add_argument('--source');p.add_argument('--project');p.add_argument('--prepare-only',action='store_true');a=p.parse_args()
 dest=Path(a.project) if a.project else Path(tempfile.mkdtemp(prefix='willicat_cafe_recovery_',dir='/private/tmp'))/'project'
 prepare(a.repo,dest,a.source);print('DEV VISUAL FRAMING PROOF:',dest,flush=True)
 if a.prepare_only:return
 subprocess.run([GODOT,'--headless','--editor','--import','--path',str(dest),'--quit'],check=True);subprocess.run([GODOT,'--path',str(dest)],check=True)
if __name__=='__main__':main()
