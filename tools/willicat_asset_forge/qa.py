"""WilliCat Asset Forge — QA analysis for animation frames."""

from __future__ import annotations

from PIL import Image

from .image_processing import alpha_bounds, detect_alpha_halo, ensure_rgba
from .models import AnimationQA, FrameQA


def analyse_frame(frame: Image.Image, index: int) -> FrameQA:
    """Compute QA metrics for a single frame."""
    rgba = ensure_rgba(frame)
    w, h = rgba.size
    bbox = alpha_bounds(rgba)

    qa = FrameQA(index=index, width=w, height=h)

    if bbox is None:
        qa.warnings.append("Fully transparent frame")
        return qa

    x0, y0, x1, y1 = bbox
    qa.alpha_bbox = (x0, y0, x1, y1)
    qa.padding_left = x0
    qa.padding_right = w - x1
    qa.padding_top = y0
    qa.padding_bottom = h - y1
    qa.visible_width = x1 - x0
    qa.visible_height = y1 - y0
    qa.center_x = (x0 + x1) / 2.0
    qa.center_y = (y0 + y1) / 2.0
    qa.baseline_y = y1 - 1  # lowest visible pixel row (0-indexed)

    # Edge warnings.
    if qa.padding_top == 0:
        qa.warnings.append("Touches top edge")
    if qa.padding_left == 0:
        qa.warnings.append("Touches left edge")
    if qa.padding_right == 0:
        qa.warnings.append("Touches right edge")
    if qa.padding_bottom == 0:
        qa.warnings.append("Touches bottom edge — possible clipping")

    # Alpha halo.
    if detect_alpha_halo(rgba):
        qa.warnings.append("Possible alpha fringe / halo")

    return qa


def analyse_animation(frames: list[Image.Image]) -> AnimationQA:
    """Compute QA metrics across all frames in an animation."""
    frame_qas = [analyse_frame(f, i) for i, f in enumerate(frames)]

    qa = AnimationQA(frame_count=len(frames), frames=frame_qas)

    non_empty = [f for f in frame_qas if f.alpha_bbox is not None]
    if not non_empty:
        qa.overall = "WARNING"
        qa.warnings.append("All frames are fully transparent")
        return qa

    centers_x = [f.center_x for f in non_empty]
    centers_y = [f.center_y for f in non_empty]
    baselines = [f.baseline_y for f in non_empty]
    vis_w = [f.visible_width for f in non_empty]
    vis_h = [f.visible_height for f in non_empty]

    qa.center_x_range = max(centers_x) - min(centers_x)
    qa.center_y_range = max(centers_y) - min(centers_y)
    qa.baseline_variation = max(baselines) - min(baselines)
    qa.visible_size_variation_w = max(vis_w) - min(vis_w)
    qa.visible_size_variation_h = max(vis_h) - min(vis_h)

    pad_tops = [f.padding_top for f in non_empty]
    pad_bots = [f.padding_bottom for f in non_empty]
    pad_lefts = [f.padding_left for f in non_empty]
    pad_rights = [f.padding_right for f in non_empty]

    qa.min_padding_top = min(pad_tops)
    qa.min_padding_bottom = min(pad_bots)
    qa.min_padding_left = min(pad_lefts)
    qa.min_padding_right = min(pad_rights)

    qa.frames_touching_top = [f.index for f in non_empty if f.padding_top == 0]
    qa.frames_touching_left = [f.index for f in non_empty if f.padding_left == 0]
    qa.frames_touching_right = [f.index for f in non_empty if f.padding_right == 0]

    # Alpha halo summary.
    halo_frames = [f.index for f in frame_qas if any("halo" in w.lower() for w in f.warnings)]
    qa.alpha_halo_check = "CHECK" if halo_frames else "PASS"

    # Collect all unique warnings.
    all_warnings: list[str] = []
    if qa.frames_touching_top:
        indices = ", ".join(str(i) for i in qa.frames_touching_top)
        all_warnings.append(f"Frames touching top edge: {indices}")
    if qa.min_padding_top == 0:
        all_warnings.append(f"Minimum top padding: 0 px")
    if qa.frames_touching_left:
        indices = ", ".join(str(i) for i in qa.frames_touching_left)
        all_warnings.append(f"Frames touching left edge: {indices}")
    if qa.frames_touching_right:
        indices = ", ".join(str(i) for i in qa.frames_touching_right)
        all_warnings.append(f"Frames touching right edge: {indices}")
    if qa.baseline_variation > 0:
        all_warnings.append(f"Baseline variation: {qa.baseline_variation} px")
    if halo_frames:
        all_warnings.append(f"Alpha halo detected on frames: {halo_frames}")

    qa.warnings = all_warnings
    qa.overall = "WARNING" if all_warnings else "PASS"

    return qa


def qa_summary_text(qa: AnimationQA) -> str:
    """Format a human-readable QA summary."""
    lines = [
        f"Frames: {qa.frame_count}",
        f"Alpha: {qa.overall}",
        f"Baseline variation: {qa.baseline_variation} px",
        f"Center X range: {qa.center_x_range:.1f} px",
        f"Center Y range: {qa.center_y_range:.1f} px",
        f"Visible size variation: {qa.visible_size_variation_w}×{qa.visible_size_variation_h} px",
        f"Min padding — T:{qa.min_padding_top} B:{qa.min_padding_bottom} L:{qa.min_padding_left} R:{qa.min_padding_right}",
    ]
    if qa.frames_touching_top:
        lines.append(f"⚠ Frames touching top: {qa.frames_touching_top}")
    if qa.frames_touching_left or qa.frames_touching_right:
        lines.append(
            f"⚠ Frames touching sides: L={qa.frames_touching_left} R={qa.frames_touching_right}"
        )
    lines.append(f"Alpha halo: {qa.alpha_halo_check}")
    return "\n".join(lines)
