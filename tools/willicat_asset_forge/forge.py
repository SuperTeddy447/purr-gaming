"""WilliCat Asset Forge — main processing pipeline orchestrator."""

from __future__ import annotations

import json
import shutil
from dataclasses import asdict
from pathlib import Path
from typing import Any

from PIL import Image

from . import config
from .godot_export import generate_sprite_frames_tres, suggest_godot_paths, write_sprite_frames
from .image_processing import (
    add_safe_padding,
    alpha_bounds,
    ensure_rgba,
    resize_frame,
    root_preserving_expand,
)
from .models import AnimationQA, AssetManifest, SourceInspection
from .paths import detect_project_root, output_dir, workspace_dir
from .qa import analyse_animation, qa_summary_text
from .sprite_sheet import (
    detect_content_strips,
    detect_grid,
    explicit_split_edges_to_strips,
    extract_content_strip_frames,
    extract_frames,
)
from .webp_processing import extract_webp_frames, inspect_webp


# ---------------------------------------------------------------------------
# Source inspection
# ---------------------------------------------------------------------------

def inspect_source(path: str | Path) -> SourceInspection:
    """Inspect a source image file and return metadata."""
    path = Path(path)
    if not path.exists():
        raise FileNotFoundError(f"Source not found: {path}")

    suffix = path.suffix.lower()

    # WebP: use dedicated inspector.
    if suffix == ".webp":
        return inspect_webp(str(path))

    # PNG / other raster.
    with Image.open(path) as img:
        info = SourceInspection(
            path=str(path),
            file_type=suffix.lstrip("."),
            width=img.width,
            height=img.height,
            mode=img.mode,
            has_alpha=img.mode in ("RGBA", "PA", "LA"),
            is_animated=False,
            frame_count=1,
        )
        # Try to detect sprite-sheet grid.
        try:
            grid = detect_grid(img.width, img.height)
            info.potential_grid = grid
        except ValueError:
            pass
    return info


# ---------------------------------------------------------------------------
# Full pipeline
# ---------------------------------------------------------------------------

def run_pipeline(
    source_path: str | Path,
    character: str,
    action: str,
    direction: str = "",
    rows: int | None = None,
    cols: int | None = None,
    frame_count: int | None = None,
    fps: int = config.DEFAULT_FPS,
    loop: bool = config.DEFAULT_LOOP,
    runtime_size: int | None = None,
    runtime_width: int | None = None,
    runtime_height: int | None = None,
    safe_padding: int = config.DEFAULT_SAFE_PADDING,
    status: str = config.DEFAULT_STATUS,
    project_root_override: str | None = None,
    output_dir_override: str | None = None,
    # V1.2 — content-strip / explicit-edges extraction.
    extraction_mode: str = "grid",
    alpha_threshold: int = 0,
    min_gap_width: int = 1,
    split_edges: list[int] | None = None,
    # V1.2 — root-preserving canvas expand.
    canvas_mode: str = "resize",
    root_x: int | None = None,
    baseline_y: int | None = None,
    source_root_x_per_frame: list[float] | None = None,
    source_baseline_y: int | None = None,
) -> dict[str, Any]:
    """Execute the full Asset Forge pipeline.

    Returns a result dict with keys:
        inspection, grid, qa_summary, qa_details, manifest, atlas_path,
        tres_content, suggested_godot_paths.

    Extraction modes:
        "grid"            — uniform-grid extraction (V1, default).
        "content-strip"   — transparent-separator-based extraction (V1.2).
        "explicit-edges"  — user-supplied split edge X positions (V1.2).

    Canvas modes:
        "resize"            — scale each frame to runtime_size² (V1, default).
        "root_preserving"   — place unresized artwork on a uniform canvas,
                              anchored at a registration root (V1.2).
    """
    source = Path(source_path).resolve()
    if not source.exists():
        raise FileNotFoundError(f"Source not found: {source}")

    # Project root (for Godot path suggestions).
    try:
        project_root = detect_project_root(project_root_override)
    except FileNotFoundError:
        project_root = None

    # Output directory.
    out_dir = Path(output_dir_override) if output_dir_override else output_dir()
    out_dir.mkdir(parents=True, exist_ok=True)

    # Resolve runtime cell dimensions.
    # Priority: explicit width/height > runtime_size (square) > source size.
    if runtime_width is not None and runtime_height is not None:
        rt_w, rt_h = runtime_width, runtime_height
    elif runtime_size is not None and runtime_size > 0:
        rt_w, rt_h = runtime_size, runtime_size
    else:
        rt_w, rt_h = None, None  # will be set from source later

    # 1. Inspect.
    inspection = inspect_source(source)

    # 2. Extract frames.
    frames: list[Image.Image]
    grid: dict[str, Any]

    if inspection.is_animated and inspection.file_type == "webp":
        frames = extract_webp_frames(str(source))
        grid = {
            "rows": 1,
            "cols": len(frames),
            "cell_w": inspection.width,
            "cell_h": inspection.height,
            "frame_count": len(frames),
        }
    elif extraction_mode == "content-strip":
        # V1.2 — non-uniform frame extraction (algorithmic).
        with Image.open(source) as img:
            src_img = ensure_rgba(img.copy())
        expected = frame_count if frame_count else 8  # require explicit count
        strips = detect_content_strips(
            src_img,
            expected_count=expected,
            alpha_threshold=alpha_threshold,
            min_gap_width=min_gap_width,
        )
        frames = extract_content_strip_frames(src_img, strips)
        widths = [s[1] - s[0] for s in strips]
        grid = {
            "rows": 1,
            "cols": len(strips),
            "cell_w": widths,  # list of per-frame widths
            "cell_h": src_img.height,
            "frame_count": len(strips),
            "extraction_mode": "content-strip",
            "strip_edges": strips,
        }
    elif extraction_mode == "explicit-edges":
        # V1.2 — user-supplied split edges.
        if split_edges is None:
            raise ValueError(
                "explicit-edges extraction mode requires --split-edges."
            )
        with Image.open(source) as img:
            src_img = ensure_rgba(img.copy())
        strips = explicit_split_edges_to_strips(split_edges)
        frames = extract_content_strip_frames(src_img, strips)
        widths = [s[1] - s[0] for s in strips]
        grid = {
            "rows": 1,
            "cols": len(strips),
            "cell_w": widths,
            "cell_h": src_img.height,
            "frame_count": len(strips),
            "extraction_mode": "explicit-edges",
            "strip_edges": strips,
        }
    else:
        # V1 — uniform grid.
        with Image.open(source) as img:
            src_img = ensure_rgba(img.copy())
        grid = detect_grid(
            src_img.width,
            src_img.height,
            rows=rows,
            cols=cols,
            frame_count=frame_count,
        )
        frames = extract_frames(
            src_img,
            grid["rows"],
            grid["cols"],
            grid["cell_w"],
            grid["cell_h"],
            grid["frame_count"],
        )

    # Source cell size (for manifest — use max for variable-width).
    if isinstance(grid.get("cell_w"), list):
        source_cell_w = max(grid["cell_w"])
        source_cell_h = grid["cell_h"]
    else:
        source_cell_w = grid["cell_w"]
        source_cell_h = grid["cell_h"]

    # 3. Apply safe padding (before resize, on source frames).
    if safe_padding > 0:
        frames = [add_safe_padding(f, safe_padding) for f in frames]
        source_cell_w += 2 * safe_padding
        source_cell_h += 2 * safe_padding

    # 4. Canvas processing.
    if canvas_mode == "root_preserving":
        # V1.2 — root-preserving canvas expansion.
        if rt_w is None or rt_h is None:
            raise ValueError(
                "root_preserving canvas mode requires explicit "
                "--runtime-width and --runtime-height."
            )
        if root_x is None or baseline_y is None:
            raise ValueError(
                "root_preserving canvas mode requires --root-x and --baseline-y."
            )
        if source_baseline_y is None:
            raise ValueError(
                "root_preserving canvas mode requires --source-baseline-y."
            )
        n_frames = len(frames)
        # Resolve per-frame source root X.
        if source_root_x_per_frame is not None:
            if len(source_root_x_per_frame) != n_frames:
                raise ValueError(
                    f"source_root_x_per_frame has {len(source_root_x_per_frame)} "
                    f"entries but there are {n_frames} frames."
                )
            per_frame_roots = source_root_x_per_frame
        else:
            # Default: center each frame horizontally.
            per_frame_roots = [f.width / 2.0 for f in frames]

        expanded: list[Image.Image] = []
        for i, f in enumerate(frames):
            expanded.append(root_preserving_expand(
                frame=f,
                runtime_width=rt_w,
                runtime_height=rt_h,
                root_x=root_x,
                baseline_y=baseline_y,
                source_root_x=per_frame_roots[i],
                source_baseline_y=source_baseline_y,
            ))
        frames = expanded
        runtime_cell_w = rt_w
        runtime_cell_h = rt_h
    elif rt_w is not None and rt_h is not None:
        # V1 — uniform resize (supports non-square targets too).
        target = (rt_w, rt_h)
        frames = [resize_frame(f, target) for f in frames]
        runtime_cell_w = rt_w
        runtime_cell_h = rt_h
    else:
        runtime_cell_w = frames[0].width if frames else source_cell_w
        runtime_cell_h = frames[0].height if frames else source_cell_h

    # 5. QA.
    qa = analyse_animation(frames)

    # 6. Build horizontal atlas.
    n = len(frames)
    atlas_w = runtime_cell_w * n
    atlas_h = runtime_cell_h
    atlas = Image.new("RGBA", (atlas_w, atlas_h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        atlas.paste(f, (i * runtime_cell_w, 0))

    # 7. Save atlas.
    name_parts = [character, action]
    if direction:
        name_parts.append(direction.lower())
    name_parts.append(f"{status.lower()}_v1")
    base_name = "_".join(name_parts)

    atlas_path = out_dir / f"{base_name}.png"
    atlas.save(str(atlas_path), format="PNG", optimize=True)

    # 8. Manifest.
    manifest = AssetManifest(
        character=character,
        action=action,
        direction=direction,
        status=status,
        frames=n,
        fps=fps,
        loop=loop,
        source=str(source),
        source_frame_size=(source_cell_w, source_cell_h),
        runtime_frame_size=(runtime_cell_w, runtime_cell_h),
        atlas=str(atlas_path),
        safe_padding=safe_padding,
        qa={
            "overall": qa.overall,
            "baseline_variation": qa.baseline_variation,
            "center_x_range": qa.center_x_range,
            "center_y_range": qa.center_y_range,
            "min_padding_top": qa.min_padding_top,
            "frames_touching_top": qa.frames_touching_top,
            "alpha_halo": qa.alpha_halo_check,
            "warnings": qa.warnings,
        },
    )
    manifest_path = out_dir / f"{base_name}_manifest.json"
    manifest.save(manifest_path)

    # 9. Godot SpriteFrames.
    animation_name = f"{action}_{'side' if direction.lower() in ('side_right', 'side_left', 'side') else direction.lower()}" if direction else action

    tres_content = generate_sprite_frames_tres(
        atlas_res_path=f"res://assets/characters/{character}/animations/{action}/{base_name}.png",
        frame_count=n,
        cell_w=runtime_cell_w,
        cell_h=runtime_cell_h,
        fps=float(fps),
        loop=loop,
        animation_name=animation_name,
    )
    tres_path = out_dir / f"{base_name}.tres"
    tres_path.write_text(tres_content, encoding="utf-8")

    # Suggested Godot paths.
    suggested = {}
    if project_root:
        suggested = suggest_godot_paths(
            project_root, character, action, direction, status
        )

    # Save individual frames too.
    frames_dir = out_dir / f"{base_name}_frames"
    frames_dir.mkdir(parents=True, exist_ok=True)
    for i, f in enumerate(frames):
        f.save(str(frames_dir / f"frame_{i:03d}.png"), format="PNG")

    return {
        "inspection": asdict(inspection) if hasattr(inspection, '__dataclass_fields__') else {},
        "grid": grid,
        "qa_summary": qa_summary_text(qa),
        "qa_details": asdict(qa),
        "manifest": manifest.to_dict(),
        "atlas_path": str(atlas_path),
        "tres_path": str(tres_path),
        "tres_content": tres_content,
        "frames_dir": str(frames_dir),
        "suggested_godot_paths": suggested,
    }
