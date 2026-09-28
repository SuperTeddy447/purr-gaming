"""Reusable static-prop PNG packaging for modular WilliCat environments.

The generated source is immutable. This only removes low-alpha fringe from a
runtime derivative, fits its complete visible bounds on a transparent canvas,
and records an explicit contact pivot for review.
"""

from __future__ import annotations

import hashlib
import json
import re
import shutil
from pathlib import Path

from PIL import Image


CONTACT_PIVOTS = {
    "FLOOR_CONTACT_BOTTOM_CENTER",
    "COUNTERTOP_BASE_CENTER",
    "COUNTER_FRONT_BOTTOM_CENTER",
}
PIVOTS = CONTACT_PIVOTS | {
    "CENTER",
    "WALL_MOUNT_CENTER",
    "COUNTER_BACK_SURFACE_CENTER",
    "FULL_CANVAS_TOP_LEFT",
}


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def package_static_prop(
    source: str | Path,
    asset_id: str,
    output_dir: str | Path,
    pivot: str,
    status: str = "CANDIDATE",
    alpha_threshold: int = 16,
    padding: int = 16,
    opaque: bool = False,
) -> dict:
    """Build one runtime PNG and JSON QA record without changing the source."""
    source_path = Path(source).resolve()
    target_dir = Path(output_dir).resolve()
    if not source_path.is_file() or source_path.suffix.lower() != ".png":
        raise ValueError("Static source must be an existing PNG.")
    if not re.fullmatch(r"[a-z][a-z0-9_]*", asset_id):
        raise ValueError("asset_id must be lowercase snake_case.")
    if pivot not in PIVOTS:
        raise ValueError(f"Unsupported pivot: {pivot}")
    if status not in {"PROTOTYPE", "CANDIDATE", "TEMP", "FINAL"}:
        raise ValueError(f"Unsupported status: {status}")
    if not 0 <= alpha_threshold <= 254 or padding < 0:
        raise ValueError("alpha_threshold must be 0..254 and padding non-negative.")
    runtime_path = target_dir / f"{asset_id}.png"
    metadata_path = target_dir / f"{asset_id}.runtime.json"
    if runtime_path == source_path or metadata_path == source_path:
        raise ValueError("Runtime output cannot overwrite the source.")

    source_hash = _sha256(source_path)
    with Image.open(source_path) as image:
        if image.format != "PNG":
            raise ValueError("Static source must be PNG data.")
        source_size = image.size
        if opaque:
            if pivot != "FULL_CANVAS_TOP_LEFT":
                raise ValueError("Opaque architecture requires FULL_CANVAS_TOP_LEFT pivot.")
            runtime = None
            source_bbox = (0, 0, image.width, image.height)
            content_bbox = source_bbox
            pivot_pixel = (0, 0)
            fringe_pixels = 0
        else:
            rgba = image.convert("RGBA")
            alpha = rgba.getchannel("A")
            if alpha.getextrema() == (255, 255):
                raise ValueError("Standalone prop has an opaque background.")
            fringe_pixels = sum(alpha.histogram()[1 : alpha_threshold + 1])
            clean_alpha = alpha.point(
                lambda value: value if value > alpha_threshold else 0
            )
            source_bbox = clean_alpha.getbbox()
            if source_bbox is None:
                raise ValueError("No visible pixels above alpha threshold.")
            if (
                source_bbox[0] == 0
                or source_bbox[1] == 0
                or source_bbox[2] == image.width
                or source_bbox[3] == image.height
            ):
                raise ValueError("Visible source artwork touches a source edge.")
            crop = rgba.crop(source_bbox)
            crop.putalpha(clean_alpha.crop(source_bbox))
            bottom_padding = 0 if pivot in CONTACT_PIVOTS else padding
            runtime = Image.new(
                "RGBA",
                (
                    crop.width + padding * 2,
                    crop.height + padding + bottom_padding,
                ),
                (0, 0, 0, 0),
            )
            runtime.alpha_composite(crop, (padding, padding))
            content_bbox = (
                padding,
                padding,
                padding + crop.width,
                padding + crop.height,
            )
            if pivot in CONTACT_PIVOTS:
                pivot_pixel = (runtime.width / 2, runtime.height)
            elif pivot == "FULL_CANVAS_TOP_LEFT":
                pivot_pixel = (0, 0)
            else:
                pivot_pixel = (runtime.width / 2, runtime.height / 2)

    target_dir.mkdir(parents=True, exist_ok=True)
    if opaque:
        shutil.copyfile(source_path, runtime_path)
        runtime_size = source_size
    else:
        runtime.save(runtime_path)
        runtime_size = runtime.size
    if _sha256(source_path) != source_hash:
        raise RuntimeError("Source image changed during packaging.")

    result = {
        "asset_id": asset_id,
        "status": status,
        "source_path": str(source_path),
        "runtime_path": str(runtime_path),
        "source_sha256": source_hash,
        "runtime_sha256": _sha256(runtime_path),
        "source_dimensions": list(source_size),
        "runtime_dimensions": list(runtime_size),
        "source_visual_bounds": list(source_bbox),
        "runtime_visual_bounds": list(content_bbox),
        "pivot": pivot,
        "pivot_pixel": list(pivot_pixel),
        "floor_contact": pivot in CONTACT_PIVOTS,
        "alpha_threshold": alpha_threshold if not opaque else None,
        "padding": padding if not opaque else 0,
        "low_alpha_fringe_pixels_removed": fringe_pixels,
        "technical_qa": "PASS",
        "status_note": "Technical packaging only; subjective visual approval remains pending.",
    }
    metadata_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result
