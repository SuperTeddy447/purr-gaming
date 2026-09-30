"""Encode the rendered Godot frame sequence as an animated proof.
Run after proxy_capture.gd. Requires Pillow. Raw pack art is not read here.
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1"
files = sorted((OUT / "frames").glob("frame_*.png"))
if not files:
    raise SystemExit("No rendered frames; run proxy_capture.gd first")
frames = [
    Image.open(path).convert("RGB").resize((432, 768), Image.Resampling.NEAREST).quantize(
        colors=96, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE
    )
    for path in files
]
frames[0].save(
    OUT / "proxy_character_walkthrough.gif",
    save_all=True,
    append_images=frames[1:],
    duration=160,
    loop=0,
    optimize=True,
    disposal=2,
)
print(f"Encoded {len(frames)} frames")
