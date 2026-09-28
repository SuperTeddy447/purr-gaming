"""WilliCat Asset Forge — sprite-sheet detection and frame extraction."""

from __future__ import annotations

import numpy as np
from PIL import Image

from .image_processing import ensure_rgba


# ---------------------------------------------------------------------------
# Uniform-grid detection (V1 — unchanged)
# ---------------------------------------------------------------------------


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


# ---------------------------------------------------------------------------
# Uniform-grid frame extraction (V1 — unchanged)
# ---------------------------------------------------------------------------


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


# ---------------------------------------------------------------------------
# Content-strip extraction (V1.2)
# ---------------------------------------------------------------------------


def _is_column_transparent(alpha_arr: np.ndarray, col: int, threshold: int = 0) -> bool:
    """Check if a column in the alpha channel is fully transparent.

    *alpha_arr* is a 2D numpy array (height × width) of alpha values.
    A column is transparent if ALL its alpha values are <= *threshold*.
    """
    return bool(np.all(alpha_arr[:, col] <= threshold))


def detect_content_strips(
    img: Image.Image,
    expected_count: int,
    alpha_threshold: int = 0,
    min_gap_width: int = 1,
) -> list[tuple[int, int]]:
    """Detect non-uniform frame boundaries in a horizontal sprite strip.

    Scans for fully-transparent column separators (alpha <= *alpha_threshold*
    across all rows) and groups contiguous content columns into strips.

    Args:
        img: Source RGBA image (horizontal strip, 1 row of variable-width frames).
        expected_count: Expected number of frames. Raises ValueError if the
            detected count does not match.
        alpha_threshold: Maximum alpha value considered transparent.
        min_gap_width: Minimum number of consecutive transparent columns to
            qualify as a gap separator.  Single transparent columns within
            content are NOT treated as separators.

    Returns:
        List of (x_start, x_end_exclusive) tuples — one per frame.
        Each frame is the tightest bounding crop containing all non-transparent
        columns in that content region.
    """
    rgba = ensure_rgba(img)
    alpha = np.array(rgba.getchannel("A"))
    width = alpha.shape[1]

    # Build a boolean mask: True = transparent column.
    col_transparent = np.array([
        bool(np.all(alpha[:, c] <= alpha_threshold))
        for c in range(width)
    ])

    # Walk left-to-right, grouping contiguous content columns.
    # A "gap" must be at least min_gap_width consecutive transparent columns.
    strips: list[tuple[int, int]] = []
    in_content = False
    content_start = 0

    c = 0
    while c < width:
        if col_transparent[c]:
            if in_content:
                # Peek ahead: is this gap wide enough?
                gap_end = c
                while gap_end < width and col_transparent[gap_end]:
                    gap_end += 1
                gap_width = gap_end - c
                if gap_width >= min_gap_width:
                    # Close the current content strip.
                    strips.append((content_start, c))
                    in_content = False
                    c = gap_end
                    continue
            c += 1
        else:
            if not in_content:
                content_start = c
                in_content = True
            c += 1

    # Close any trailing content strip.
    if in_content:
        strips.append((content_start, width))

    if len(strips) != expected_count:
        raise ValueError(
            f"Content-strip detection found {len(strips)} strips, "
            f"expected {expected_count}. "
            f"Strip edges: {strips}. "
            f"Try adjusting --alpha-threshold or --min-gap-width, "
            f"or provide explicit split edges."
        )

    return strips


def extract_content_strip_frames(
    img: Image.Image,
    strips: list[tuple[int, int]],
) -> list[Image.Image]:
    """Extract frames from pre-detected content strips.

    Each frame is cropped to its strip boundaries and full source height.
    Frames may have different widths.

    Returns list of RGBA images.
    """
    rgba = ensure_rgba(img)
    height = rgba.height
    frames: list[Image.Image] = []
    for x_start, x_end in strips:
        frame = rgba.crop((x_start, 0, x_end, height)).copy()
        frames.append(frame)
    return frames


def explicit_split_edges_to_strips(
    split_edges: list[int],
) -> list[tuple[int, int]]:
    """Convert a list of split edge X positions to (x_start, x_end) strip tuples.

    *split_edges* must have N+1 entries for N frames.
    Example: [0, 273, 545, 817] → [(0, 273), (273, 545), (545, 817)]

    Raises ValueError if fewer than 2 edges are provided.
    """
    if len(split_edges) < 2:
        raise ValueError(
            f"split_edges must have at least 2 entries (for 1 frame), "
            f"got {len(split_edges)}."
        )
    strips = []
    for i in range(len(split_edges) - 1):
        start = split_edges[i]
        end = split_edges[i + 1]
        if end <= start:
            raise ValueError(
                f"split_edges must be strictly increasing: "
                f"edge[{i}]={start} >= edge[{i+1}]={end}."
            )
        strips.append((start, end))
    return strips
