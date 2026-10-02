"""Launch an isolated DEV-only 3D presentation spike. No publication or world migration."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
REPO = Path(__file__).resolve().parents[2]
GODOT = "/Applications/Godot.app/Contents/MacOS/Godot"
APPROVAL = "artifacts/prototype_review/cafe_visual_fidelity_recovery_v1/diagnostics/human_visual_review_approved_v1.json"


def prepare(repo, project, source=None, renderer="mobile"):
    repo = Path(repo).resolve()
    source = Path(source or repo).resolve()
    raw = Path(project)
    if not raw.is_absolute() or ".." in raw.parts or raw.is_symlink():
        raise ValueError("Use a fresh isolated /private/tmp project")
    project = raw.resolve()
    if project.exists() or Path("/private/tmp").resolve() not in project.parents:
        raise ValueError("Existing projects and repository destinations are refused")
    if renderer not in ("mobile", "gl_compatibility"):
        raise ValueError("Unsupported DEV renderer")
    approval = json.loads((repo / APPROVAL).read_text())
    for item in approval["reviewed_content"]:
        path = (repo / item["path"]).resolve()
        if repo not in path.parents:
            raise ValueError("Approval reference escapes repository")
        if hashlib.sha256(path.read_bytes()).hexdigest() != item["hash"]:
            raise ValueError("Approved café baseline changed: " + item["path"])
    sys.path.insert(0, str(repo / "tools"))
    from willicat_cafe_recovery.run import prepare as cafe_context
    cafe_context(repo, project)
    for rel in ("scripts/dev/hybrid_diorama", "scenes/dev/hybrid_diorama"):
        shutil.copytree(source / rel, project / rel)
    for name in ("capture_hybrid_diorama_v1.gd", "profile_hybrid_steady.gd"):
        shutil.copy2(source / "tests" / name, project / "tests" / name)
    config = project / "project.godot"
    text = config.read_text().replace("scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn", "scenes/dev/hybrid_diorama/hybrid_cafe_diorama_v1.tscn")
    text = text.replace("WilliCatCafeVisualRecoveryV1", "WilliCatHybridDioramaDEVV1").replace("Café Visual Recovery Review", "Hybrid Diorama Feasibility")
    text = text.replace('renderer/rendering_method="gl_compatibility"', 'renderer/rendering_method="' + renderer + '"')
    text += "\nanti_aliasing/quality/msaa_3d=1\nlights_and_shadows/directional_shadow/soft_shadow_filter_quality=2\n"
    config.write_text(text)
    receipt = {"scope": "isolated DEV feasibility", "renderer": renderer, "approved_baseline_files_verified": len(approval["reviewed_content"]), "source_art_regenerated": False, "production_migration": False, "production_publication": False, "source_hashes": {str(p.relative_to(source)): hashlib.sha256(p.read_bytes()).hexdigest() for rel in ("scripts/dev/hybrid_diorama", "scenes/dev/hybrid_diorama") for p in (source / rel).rglob("*") if p.is_file()}}
    (project / "hybrid_spike_receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt


def main():
    parser = argparse.ArgumentParser(description="Open isolated WilliCat hybrid café feasibility")
    parser.add_argument("--repo", default=str(REPO))
    parser.add_argument("--project")
    parser.add_argument("--renderer", choices=["mobile", "gl_compatibility"], default="mobile")
    parser.add_argument("--prepare-only", action="store_true")
    args = parser.parse_args()
    project = Path(args.project) if args.project else Path(tempfile.mkdtemp(prefix="willicat_hybrid_", dir="/private/tmp")) / "project"
    prepare(args.repo, project, renderer=args.renderer)
    print("DEV feasibility project:", project, flush=True)
    if args.prepare_only:
        return
    subprocess.run([GODOT, "--headless", "--editor", "--import", "--path", str(project), "--quit"], check=True)
    subprocess.run([GODOT, "--rendering-method", args.renderer, "--path", str(project)], check=True)


if __name__ == "__main__":
    main()
