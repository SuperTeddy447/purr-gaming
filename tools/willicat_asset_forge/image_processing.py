"""WilliCat Asset Forge — core image processing utilities."""

from __future__ import annotations

import math

from PIL import Image

from . import config


def ensure_rgba(img: Image.Image) -> Image.Image:
    """Convert any image to RGBA, preserving data."""
    if img.mode == "RGBA":
        return img
    return img.convert("RGBA")


def alpha_bounds(img: Image.Image) -> tuple[int, int, int, int] | None:
    """Return (x0, y0, x1, y1) bounding box of non-transparent pixels.

    Returns None if the image is fully transparent.
    Coordinates are in Pillow convention: x1/y1 are exclusive.
    """
    rgba = ensure_rgba(img)
    return rgba.getchannel("A").getbbox()


def resize_frame(
    frame: Image.Image,
    target_size: tuple[int, int],
) -> Image.Image:
    """Resize a single frame using premultiplied-alpha Lanczos.

    This matches the existing pipeline in build_mochi_walk_side_prototype_v1.py:
    convert to premultiplied, Lanczos resample, convert back.
    """
    rgba = ensure_rgba(frame)
    if rgba.size == target_size:
        return rgba
    premul = rgba.convert("RGBa")
    resized = premul.resize(target_size, Image.Resampling.LANCZOS)
    return resized.convert("RGBA")


def add_safe_padding(
    frame: Image.Image,
    padding: int,
) -> Image.Image:
    """Place *frame* on a larger transparent canvas with *padding* pixels
    on each side.  Original registration (position within the cell) is preserved."""
    if padding <= 0:
        return frame
    rgba = ensure_rgba(frame)
    w, h = rgba.size
    canvas = Image.new("RGBA", (w + 2 * padding, h + 2 * padding), (0, 0, 0, 0))
    canvas.paste(rgba, (padding, padding))
    return canvas


def detect_alpha_halo(
    frame: Image.Image,
    threshold: int | None = None,
) -> bool:
    """Lightweight check for suspicious alpha-fringe / halo at visible edges.

    Looks at pixels where RGB channels are near-opaque but alpha is
    in the suspicious low range (1..threshold).  Returns True if found.
    """
    if threshold is None:
        threshold = config.ALPHA_HALO_THRESHOLD
    rgba = ensure_rgba(frame)
    pixels = rgba.load()
    if pixels is None:
        return False
    w, h = rgba.size

    # Sample edges of the alpha bounding box only.
    bbox = rgba.getchannel("A").getbbox()
    if bbox is None:
        return False
    x0, y0, x1, y1 = bbox

    suspect_count = 0
    sample_limit = 10  # don't over-scan

    for y in (y0, y1 - 1):
        if y < 0 or y >= h:
            continue
        for x in range(max(x0, 0), min(x1, w)):
            r, g, b, a = pixels[x, y]
            if 1 <= a <= threshold and (r > 128 or g > 128 or b > 128):
                suspect_count += 1
                if suspect_count >= sample_limit:
                    return True

    for x in (x0, x1 - 1):
        if x < 0 or x >= w:
            continue
        for y in range(max(y0, 0), min(y1, h)):
            r, g, b, a = pixels[x, y]
            if 1 <= a <= threshold and (r > 128 or g > 128 or b > 128):
                suspect_count += 1
                if suspect_count >= sample_limit:
                    return True

    return suspect_count > 0


def root_preserving_expand(
    frame: Image.Image,
    runtime_width: int,
    runtime_height: int,
    root_x: int,
    baseline_y: int,
    source_root_x: float | int,
    source_baseline_y: int,
) -> Image.Image:
    """Place *frame* onto a transparent canvas of (runtime_width × runtime_height).

    The frame is positioned so that its registration point
    (source_root_x, source_baseline_y) maps to (root_x, baseline_y)
    in the output canvas.  No resizing — original pixels are preserved.

    The integer translation is:
        dx = root_x - round(source_root_x)
        dy = baseline_y - source_baseline_y

    Pixels that fall outside the canvas are silently clipped (should not
    happen if canvas size is chosen properly).

    Args:
        frame: Source RGBA image (variable width × source height).
        runtime_width: Width of the output cell.
        runtime_height: Height of the output cell.
        root_x: Target X position of the character root in the output.
        baseline_y: Target Y position of the character baseline in the output.
        source_root_x: X position of the character root in the source frame.
        source_baseline_y: Y position of the baseline in the source frame.

    Returns:
        RGBA image of exactly (runtime_width × runtime_height).
    """
    rgba = ensure_rgba(frame)

    # Integer translation.
    # Use traditional round-half-up (floor(x + 0.5)) instead of Python's
    # banker's rounding (round()) to match the known-good registration
    # pipeline.  Python round(154.5) == 154 (even), but the reference
    # pipeline computes floor(154.5 + 0.5) == 155.
    dx = root_x - int(math.floor(source_root_x + 0.5))
    dy = baseline_y - source_baseline_y

    canvas = Image.new("RGBA", (runtime_width, runtime_height), (0, 0, 0, 0))
    canvas.paste(rgba, (dx, dy))
    return canvas
