#!/usr/bin/env python3
"""Build a 320px-per-cell TEMP atlas from the preserved eight-cell source sheet."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "docs/source_assets/mochi/walk_side_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk.png"
OUTPUT = ROOT / "assets/characters/mochi/animations/walk/mochi_walk_side_right_prototype_v1.png"
SOURCE_CELL = 640
RUNTIME_CELL = 320
FRAME_COUNT = 8


def alpha_bounds(image: Image.Image) -> tuple[int, int, int, int] | None:
	return image.getchannel("A").getbbox()


def main() -> None:
	with Image.open(SOURCE) as opened:
		if opened.size != (SOURCE_CELL * FRAME_COUNT, SOURCE_CELL):
			raise SystemExit(f"Unexpected source dimensions: {opened.size}")
		if opened.mode != "RGBA":
			raise SystemExit(f"Expected RGBA source, got {opened.mode}")
		source = opened.copy()

	atlas = Image.new("RGBA", (RUNTIME_CELL * FRAME_COUNT, RUNTIME_CELL), (0, 0, 0, 0))
	report: list[dict[str, object]] = []
	for index in range(FRAME_COUNT):
		cell = source.crop((index * SOURCE_CELL, 0, (index + 1) * SOURCE_CELL, SOURCE_CELL))
		bounds = alpha_bounds(cell)
		if bounds is None:
			raise SystemExit(f"Frame {index + 1} has no visible alpha")
		if bounds[0] <= 0 or bounds[2] >= SOURCE_CELL:
			raise SystemExit(f"Frame {index + 1} touches a horizontal cell edge: {bounds}")

		# Resample premultiplied RGBA one cell at a time to prevent neighbor bleed.
		resized = cell.convert("RGBa").resize(
			(RUNTIME_CELL, RUNTIME_CELL), Image.Resampling.LANCZOS
		).convert("RGBA")
		atlas.paste(resized, (index * RUNTIME_CELL, 0))
		runtime_bounds = alpha_bounds(resized)
		report.append({
			"frame": index,
			"source_cell": [index * SOURCE_CELL, 0, SOURCE_CELL, SOURCE_CELL],
			"source_alpha_bounds": bounds,
			"runtime_alpha_bounds": runtime_bounds,
		})

	OUTPUT.parent.mkdir(parents=True, exist_ok=True)
	atlas.save(OUTPUT, format="PNG", optimize=True)
	print(json.dumps({
		"source": str(SOURCE.relative_to(ROOT)),
		"output": str(OUTPUT.relative_to(ROOT)),
		"source_size": list(source.size),
		"runtime_size": list(atlas.size),
		"mode": atlas.mode,
		"resampling": "per-cell Lanczos on premultiplied RGBA",
		"frames": report,
	}, indent=2))


if __name__ == "__main__":
	main()
