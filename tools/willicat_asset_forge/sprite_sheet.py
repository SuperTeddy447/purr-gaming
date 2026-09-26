"""WilliCat Asset Forge — sprite-sheet detection and frame extraction."""

from __future__ import annotations

from PIL import Image

from .image_processing import ensure_rgba


def detect_grid(
    width: int,
    height: int,
    rows: int | None = None,
    cols: int | None = None,
    frame_count: int | None = None,
) -> dict[str, int]:
    """Determine grid layout for a sprite sheet.

    If *rows* and *cols* are both given, use them directly.
    If only one is given, infer the other from dimensions.
    If neither is given, try common layouts (horizontal strip, vertical strip).

    Returns dict with keys: rows, cols, cell_w, cell_h, frame_count.
    Raises ValueError if the dimensions don't divide evenly.
    """
    if rows is not None and cols is not None:
        cell_w = width // cols
        cell_h = height // rows
        if cell_w * cols != width or cell_h * rows != height:
            raise ValueError(
                f"Dimensions {width}x{height} do not divide evenly into "
                f"{rows} rows × {cols} cols."
            )
        count = frame_count if frame_count else rows * cols
        return {
            "rows": rows,
            "cols": cols,
            "cell_w": cell_w,
            "cell_h": cell_h,
            "frame_count": count,
        }

    if rows is not None and rows > 0:
        cell_h = height // rows
        if cell_h <= 0 or cell_h * rows != height:
            raise ValueError(f"Height {height} does not divide evenly into {rows} rows.")
        # Assume square cells unless width says otherwise.
        if width % cell_h == 0:
            cols = width // cell_h
            cell_w = cell_h
        else:
            cols = 1
            cell_w = width
        count = frame_count if frame_count else rows * cols
        return {"rows": rows, "cols": cols, "cell_w": cell_w, "cell_h": cell_h, "frame_count": count}

    if cols is not None and cols > 0:
        cell_w = width // cols
        if cell_w <= 0 or cell_w * cols != width:
            raise ValueError(f"Width {width} does not divide evenly into {cols} cols.")
        if height % cell_w == 0:
            rows = height // cell_w
            cell_h = cell_w
        else:
            rows = 1
            cell_h = height
        count = frame_count if frame_count else rows * cols
        return {"rows": rows, "cols": cols, "cell_w": cell_w, "cell_h": cell_h, "frame_count": count}

    # Auto-detect: try horizontal strip (1 row, square cells).
    if width > height and width % height == 0:
        cols = width // height
        return {
            "rows": 1,
            "cols": cols,
            "cell_w": height,
            "cell_h": height,
            "frame_count": frame_count if frame_count else cols,
        }

    # Try vertical strip (1 column, square cells).
    if height > width and height % width == 0:
        rows_val = height // width
        return {
            "rows": rows_val,
            "cols": 1,
            "cell_w": width,
            "cell_h": width,
            "frame_count": frame_count if frame_count else rows_val,
        }

    # Square image — treat as single frame.
    if width == height:
        return {
            "rows": 1,
            "cols": 1,
            "cell_w": width,
            "cell_h": height,
            "frame_count": 1,
        }

    raise ValueError(
        f"Cannot auto-detect grid for {width}x{height}. "
        "Please provide --rows and --cols explicitly."
    )


def extract_frames(
    img: Image.Image,
    rows: int,
    cols: int,
    cell_w: int,
    cell_h: int,
    frame_count: int | None = None,
) -> list[Image.Image]:
    """Extract individual frames from a sprite-sheet grid.

    Frames are read left-to-right, top-to-bottom.
    Each frame is returned as an independent RGBA image.
    """
    rgba = ensure_rgba(img)
    total = rows * cols
    if frame_count is not None:
        total = min(total, frame_count)

    frames: list[Image.Image] = []
    idx = 0
    for row in range(rows):
        for col in range(cols):
            if idx >= total:
                break
            x0 = col * cell_w
            y0 = row * cell_h
            frame = rgba.crop((x0, y0, x0 + cell_w, y0 + cell_h)).copy()
            frames.append(frame)
            idx += 1
    return frames
