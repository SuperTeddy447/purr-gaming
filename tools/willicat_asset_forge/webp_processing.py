"""WilliCat Asset Forge — animated WebP reading and frame extraction."""

from __future__ import annotations

from PIL import Image

from .image_processing import ensure_rgba
from .models import SourceInspection


def inspect_webp(path: str) -> SourceInspection:
    """Inspect a WebP file for animation metadata."""
    with Image.open(path) as img:
        is_animated = getattr(img, "is_animated", False)
        n_frames = getattr(img, "n_frames", 1)

        durations: list[int] = []
        if is_animated:
            for i in range(n_frames):
                img.seek(i)
                dur = img.info.get("duration", 0)
                durations.append(int(dur) if dur else 0)

        loop = img.info.get("loop", 0)

        return SourceInspection(
            path=str(path),
            file_type="webp",
            width=img.width,
            height=img.height,
            mode=img.mode,
            has_alpha=img.mode in ("RGBA", "PA", "LA"),
            is_animated=is_animated,
            frame_count=n_frames,
            frame_durations_ms=durations,
            loop_count=int(loop) if loop else 0,
        )


def extract_webp_frames(path: str) -> list[Image.Image]:
    """Extract all frames from an animated WebP as independent RGBA images."""
    frames: list[Image.Image] = []
    with Image.open(path) as img:
        n_frames = getattr(img, "n_frames", 1)
        for i in range(n_frames):
            img.seek(i)
            frame = ensure_rgba(img.copy())
            frames.append(frame)
    return frames
