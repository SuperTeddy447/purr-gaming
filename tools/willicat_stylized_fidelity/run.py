"""Isolated DEV art-fidelity comparison. Never publishes, edits Home, or changes source art."""
from pathlib import Path
import argparse, hashlib, json, shutil, subprocess, sys, tempfile
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
MODES={"live":"scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn","prerender":"scenes/dev/stylized_fidelity/prerendered_cafe_comparison_v1.tscn"}
def prepare(repo,project,source=None,renderer="mobile",mode="live"):
 repo=Path(repo).resolve();source=Path(source or repo).resolve()
 if mode not in MODES:raise ValueError("Unknown DEV comparison mode")
 sys.path.insert(0,str(repo/"tools"))
 from willicat_hybrid_diorama.run import prepare as prior_context
 receipt=prior_context(repo,project,renderer=renderer)
 project=Path(project).resolve()
 names=["scripts/dev/stylized_fidelity","scenes/dev/stylized_fidelity","assets/dev_review/stylized_fidelity_v1"]
 hashes={}
 for rel in names:
  for item in (source/rel).rglob("*"):
   if not item.is_file() or item.suffix in (".uid",".import") or ".godot" in item.parts:continue
   if item.is_symlink():raise ValueError("DEV source symlink refused")
   target=project/item.relative_to(source);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(item,target);hashes[str(item.relative_to(source))]=hashlib.sha256(item.read_bytes()).hexdigest()
 for name in ["capture_stylized_fidelity_v1.gd","capture_prerendered_fidelity_v1.gd","profile_stylized_fidelity_v1.gd","capture_fidelity_lighting_v1.gd","profile_fidelity_fresh_v1.gd","test_stylized_fidelity_input_v1.gd","measure_stylized_fidelity_inventory_v1.gd","test_stylized_fidelity_startup_v1.gd"]:shutil.copy2(source/"tests"/name,project/"tests"/name)
 config=project/"project.godot";text=config.read_text().replace("scenes/dev/hybrid_diorama/hybrid_cafe_diorama_v1.tscn",MODES[mode]).replace("WilliCatHybridDioramaDEVV1","WilliCatStylizedFidelityDEVV1").replace("Hybrid Diorama Feasibility","Stylized Café Art Comparison").replace("anti_aliasing/quality/msaa_3d=1","anti_aliasing/quality/msaa_3d=2");config.write_text(text)
 receipt.update({"scope":"isolated DEV art-fidelity comparison","mode":mode,"source_hashes":hashes,"canonical_candidate":False,"production_migration":False,"publication":False})
 (project/"stylized_fidelity_receipt.json").write_text(json.dumps(receipt,indent=2)+"\n")
 return receipt

def main():
 # Reuse the existing Forge environment; do not install or alter dependencies.
 try:
  import numpy
 except ModuleNotFoundError:
  forge_python=REPO/"tools/willicat_asset_forge/.venv/bin/python"
  if not forge_python.is_file():raise RuntimeError("Existing Asset Forge Python environment with NumPy is required")
  subprocess.run([str(forge_python),str(Path(__file__).resolve()),*sys.argv[1:]],check=True)
  return
 parser=argparse.ArgumentParser(description="Open isolated WilliCat stylized art comparison")
 parser.add_argument("--repo",default=str(REPO));parser.add_argument("--project");parser.add_argument("--mode",choices=MODES,default="live");parser.add_argument("--renderer",choices=["mobile","gl_compatibility"],default="mobile");parser.add_argument("--prepare-only",action="store_true");args=parser.parse_args()
 project=Path(args.project) if args.project else Path(tempfile.mkdtemp(prefix="willicat_fidelity_",dir="/private/tmp"))/"project"
 prepare(args.repo,project,renderer=args.renderer,mode=args.mode);print("Isolated DEV project:",project,flush=True)
 if args.prepare_only:return
 subprocess.run([GODOT,"--headless","--editor","--import","--path",str(project),"--quit"],check=True)
 subprocess.run([GODOT,"--rendering-method",args.renderer,"--path",str(project)],check=True)
if __name__=="__main__":main()
