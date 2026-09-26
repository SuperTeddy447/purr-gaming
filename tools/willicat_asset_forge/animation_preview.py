"""WilliCat Asset Forge — animation preview helpers for Streamlit GUI.

Provides utilities to generate GIF/APNG previews and base64-encoded
animations for in-browser display.
"""

from __future__ import annotations

import base64
import io
from pathlib import Path

from PIL import Image

from .image_processing import ensure_rgba


def create_preview_gif(
    frames: list[Image.Image],
    fps: int = 8,
    loop: bool = True,
) -> bytes:
    """Create an animated GIF from a list of RGBA frames.

    Returns the GIF bytes.  GIF doesn't support full alpha, so we composite
    onto a checkerboard background.
    """
    gif_frames = []
    for frame in frames:
        rgba = ensure_rgba(frame)
        # Composite onto light gray background for GIF.
        bg = Image.new("RGBA", rgba.size, (240, 240, 240, 255))
        composite = Image.alpha_composite(bg, rgba)
        gif_frames.append(composite.convert("RGB"))

    if not gif_frames:
        return b""

    buf = io.BytesIO()
    duration = max(1, int(1000 / fps))
    gif_frames[0].save(
        buf,
        format="GIF",
        save_all=True,
        append_images=gif_frames[1:],
        duration=duration,
        loop=0 if loop else 1,
    )
    return buf.getvalue()


def create_preview_apng(
    frames: list[Image.Image],
    fps: int = 8,
    loop: bool = True,
) -> bytes:
    """Create an animated PNG (APNG) from frames.  Preserves alpha."""
    if not frames:
        return b""
    rgba_frames = [ensure_rgba(f) for f in frames]
    buf = io.BytesIO()
    duration = max(1, int(1000 / fps))
    rgba_frames[0].save(
        buf,
        format="PNG",
        save_all=True,
        append_images=rgba_frames[1:],
        duration=duration,
        loop=0 if loop else 1,
    )
    return buf.getvalue()


def frames_to_base64_pngs(frames: list[Image.Image]) -> list[str]:
    """Convert each frame to a base64-encoded PNG data URI."""
    result = []
    for f in frames:
        rgba = ensure_rgba(f)
        buf = io.BytesIO()
        rgba.save(buf, format="PNG")
        b64 = base64.b64encode(buf.getvalue()).decode("ascii")
        result.append(f"data:image/png;base64,{b64}")
    return result


def checkerboard_background(w: int, h: int, tile: int = 16) -> Image.Image:
    """Create a checkerboard pattern image for transparency visualization."""
    img = Image.new("RGB", (w, h))
    pixels = img.load()
    c1 = (220, 220, 220)
    c2 = (180, 180, 180)
    for y in range(h):
        for x in range(w):
            if (x // tile + y // tile) % 2 == 0:
                pixels[x, y] = c1
            else:
                pixels[x, y] = c2
    return img


def composite_on_checkerboard(
    frame: Image.Image,
    tile: int = 16,
) -> Image.Image:
    """Composite an RGBA frame onto a checkerboard for display."""
    rgba = ensure_rgba(frame)
    bg = checkerboard_background(rgba.width, rgba.height, tile)
    bg.paste(rgba, (0, 0), rgba)
    return bg
