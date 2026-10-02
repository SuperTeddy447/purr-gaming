"""Prepare/open an isolated DEV cafe kit. Never publish or modify gameplay authority."""
from pathlib import Path
import argparse, hashlib, importlib.util, json, shutil, subprocess, sys, tempfile
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"

def prepare(repo, project, source=None):
    repo=Path(repo).resolve();source=Path(source or repo).resolve()
    raw=Path(project)
    if not raw.is_absolute() or ".." in raw.parts or raw.is_symlink():raise ValueError("Fresh canonical /private/tmp project required")
    destination=raw.resolve()
    if destination.exists() or Path("/private/tmp").resolve() not in destination.parents:raise ValueError("Existing or protected destinations refused")
    sys.path.insert(0,str(repo/"tools"))
    from willicat_hybrid_diorama.run import prepare as previous_prepare
    receipt=previous_prepare(repo,destination)
    for rel in ("assets/dev_review/hybrid_cafe_kit_v1","scenes/dev/hybrid_cafe_kit","scripts/dev/hybrid_cafe_kit"):
        origin=(source/rel).resolve()
        if source not in origin.parents:raise ValueError("Source path escape")
        for path in origin.rglob("*"):
            if path.is_symlink():raise ValueError("Symlinks refused in kit intake")
        shutil.copytree(origin,destination/rel)
    for name in ("capture_hybrid_cafe_kit_v1.gd","profile_hybrid_cafe_kit_v1.gd","calibrate_hybrid_cafe_kit_v1.gd"):
        shutil.copy2(source/"tests"/name,destination/"tests"/name)
    config=destination/"project.godot";text=config.read_text().replace("scenes/dev/hybrid_diorama/hybrid_cafe_diorama_v1.tscn","scenes/dev/hybrid_cafe_kit/hybrid_cafe_asset_kit_v1.tscn").replace("WilliCatHybridDioramaDEVV1","WilliCatHybridCafeKitDEVV1").replace("Hybrid Diorama Feasibility","WilliCat Hybrid Cafe Kit DEV").replace("anti_aliasing/quality/msaa_3d=1","anti_aliasing/quality/msaa_3d=2");config.write_text(text)
    receipt.update({"scope":"ISOLATED_DEV_ONLY; not canonical candidate/integration proof/publication","distinct_save_namespace":"WilliCatHybridCafeKitDEVV1","source_art_regenerated":False,"kit_hashes":{str(p.relative_to(source)):hashlib.sha256(p.read_bytes()).hexdigest() for rel in ("assets/dev_review/hybrid_cafe_kit_v1","scripts/dev/hybrid_cafe_kit","scenes/dev/hybrid_cafe_kit") for p in (source/rel).rglob("*") if p.is_file() and not p.name.endswith((".import",".uid"))}})
    (destination/"hybrid_cafe_kit_receipt.json").write_text(json.dumps(receipt,indent=2)+"\n");return receipt

def main():
    parser=argparse.ArgumentParser(description="Open isolated playable WilliCat Hybrid Cafe kit")
    parser.add_argument("--repo",default=str(REPO));parser.add_argument("--project");parser.add_argument("--prepare-only",action="store_true");args=parser.parse_args()
    try:import numpy;from PIL import Image
    except ImportError:
        python=Path(args.repo)/"tools/willicat_asset_forge/.venv/bin/python"
        if python.exists() and str(python)!=sys.executable:raise SystemExit(subprocess.call([str(python),__file__,*sys.argv[1:]],env={**__import__('os').environ,"PYTHONDONTWRITEBYTECODE":"1"}))
        raise RuntimeError("Existing Forge Python environment with Pillow/NumPy required")
    destination=Path(args.project) if args.project else Path(tempfile.mkdtemp(prefix="willicat_hybrid_cafe_kit_",dir="/private/tmp"))/"project"
    prepare(args.repo,destination);print("Isolated DEV review project:",destination,flush=True)
    if args.prepare_only:return
    subprocess.run([GODOT,"--headless","--editor","--import","--path",str(destination),"--quit"],check=True)
    subprocess.run([GODOT,"--rendering-method","mobile","--rendering-driver","metal","--path",str(destination)],check=True)
if __name__=="__main__":main()
