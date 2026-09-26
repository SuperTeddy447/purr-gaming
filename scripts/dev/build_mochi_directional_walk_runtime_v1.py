#!/usr/bin/env python3
"""Build 320px-per-cell runtime atlases for Mochi directional walk UP and DOWN."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE_CELL = 640
RUNTIME_CELL = 320
FRAME_COUNT = 8

TASKS = [
	{
		"id": "walk_up",
		"source": ROOT / "docs/source_assets/mochi/walk_up_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_back_walk_walk_up.png",
		"output": ROOT / "assets/characters/mochi/animations/walk/mochi_walk_up_v1.png",
	},
	{
		"id": "walk_down",
		"source": ROOT / "docs/source_assets/mochi/walk_down_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk_down.png",
		"output": ROOT / "assets/characters/mochi/animations/walk/mochi_walk_down_v1.png",
	},
]


def alpha_bounds(image: Image.Image) -> tuple[int, int, int, int] | None:
	return image.getchannel("A").getbbox()


def process_task(task: dict[str, object]) -> dict[str, object]:
	source_path: Path = task["source"]  # type: ignore[assignment]
	output_path: Path = task["output"]  # type: ignore[assignment]
	with Image.open(source_path) as opened:
		if opened.size != (SOURCE_CELL * FRAME_COUNT, SOURCE_CELL):
			raise SystemExit(f"Unexpected source dimensions: {opened.size} in {source_path}")
		if opened.mode != "RGBA":
			raise SystemExit(f"Expected RGBA source, got {opened.mode} in {source_path}")
		source = opened.copy()

	atlas = Image.new("RGBA", (RUNTIME_CELL * FRAME_COUNT, RUNTIME_CELL), (0, 0, 0, 0))
	report: list[dict[str, object]] = []

	for index in range(FRAME_COUNT):
		cell = source.crop((index * SOURCE_CELL, 0, (index + 1) * SOURCE_CELL, SOURCE_CELL))
		bounds = alpha_bounds(cell)
		if bounds is None:
			raise SystemExit(f"Frame {index + 1} has no visible alpha in {source_path}")
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

	output_path.parent.mkdir(parents=True, exist_ok=True)
	atlas.save(output_path, format="PNG", optimize=True)
	return {
		"task": task["id"],
		"source": str(source_path.relative_to(ROOT)),
		"output": str(output_path.relative_to(ROOT)),
		"source_size": list(source.size),
		"runtime_size": list(atlas.size),
		"mode": atlas.mode,
		"frames": report,
	}


def main() -> None:
	results = [process_task(t) for t in TASKS]
	print(json.dumps(results, indent=2))


if __name__ == "__main__":
	main()
