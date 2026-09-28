"""WilliCat Asset Forge — Streamlit GUI.

Launch: streamlit run app.py
"""

from __future__ import annotations

import json
import sys
import time
from dataclasses import asdict
from pathlib import Path

# Ensure the tool package is importable.
_tool_root = Path(__file__).resolve().parent
if str(_tool_root.parent) not in sys.path:
    sys.path.insert(0, str(_tool_root.parent))

import streamlit as st
from PIL import Image, ImageDraw

from willicat_asset_forge import config
from willicat_asset_forge.animation_preview import (
    composite_on_checkerboard,
    create_preview_apng,
    create_preview_gif,
    frames_to_base64_pngs,
)
from willicat_asset_forge.forge import inspect_source, run_pipeline
from willicat_asset_forge.image_processing import (
    alpha_bounds,
    ensure_rgba,
    root_preserving_expand,
)
from willicat_asset_forge.qa import analyse_animation, analyse_frame, qa_summary_text
from willicat_asset_forge.registry import list_actions, list_characters, load_action
from willicat_asset_forge.sprite_sheet import (
    detect_content_strips,
    detect_grid,
    explicit_split_edges_to_strips,
    extract_content_strip_frames,
    extract_frames,
)
from willicat_asset_forge.webp_processing import extract_webp_frames
from willicat_asset_forge.godot_export import suggest_godot_paths
from willicat_asset_forge.paths import detect_project_root, output_dir, inbox_dir


st.set_page_config(
    page_title="WilliCat Asset Forge",
    page_icon="🐱",
    layout="wide",
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _parse_split_edges(text: str) -> list[int] | None:
    """Parse comma-separated split edges. Returns None if empty/invalid."""
    text = text.strip()
    if not text:
        return None
    try:
        values = [int(x.strip()) for x in text.split(",")]
        if len(values) < 2:
            return None
        return values
    except ValueError:
        return None


# Public alias for tests
parse_split_edges = _parse_split_edges


def _parse_root_x_per_frame(text: str) -> list[float] | None:
    """Parse comma-separated per-frame root X values."""
    text = text.strip()
    if not text:
        return None
    try:
        return [float(x.strip()) for x in text.split(",")]
    except ValueError:
        return None


# Public alias for tests
parse_root_x_per_frame = _parse_root_x_per_frame


def _find_associated_metadata(source_file: Path | None) -> Path | None:
    """Find a metadata JSON associated with the source file if present."""
    if not source_file:
        return None
    parent = source_file.parent
    if not parent.exists():
        return None
    for candidate in sorted(parent.glob("*METADATA*.json")):
        return candidate
    return None


def _resolve_source_path(raw: str | None) -> Path | None:
    """Resolve a source image path, checking absolute, cwd, and project root."""
    if not raw or not raw.strip():
        return None
    p = Path(raw.strip())
    if p.exists():
        return p.resolve()
    try:
        root = detect_project_root()
        proj_p = (root / p).resolve()
        if proj_p.exists():
            return proj_p
    except Exception:
        pass
    return None


def _annotate_frame_preview(
    frame: Image.Image,
    frame_idx: int,
    root_x: int | None = None,
    baseline_y: int | None = None,
    runtime_w: int | None = None,
    runtime_h: int | None = None,
) -> Image.Image:
    """Draw registration markers and frame info onto a checkerboard preview."""
    display = composite_on_checkerboard(frame, tile=16)
    draw = ImageDraw.Draw(display)
    w, h = display.size

    bbox = alpha_bounds(frame)

    # Alpha bounding box (cyan dashed).
    if bbox:
        x0, y0, x1, y1 = bbox
        draw.rectangle([x0, y0, x1 - 1, y1 - 1], outline=(0, 200, 200, 180), width=1)

    # Root marker (red crosshair).
    if root_x is not None and baseline_y is not None:
        rx, ry = root_x, baseline_y
        arm = 8
        draw.line([(rx - arm, ry), (rx + arm, ry)], fill=(255, 50, 50), width=2)
        draw.line([(rx, ry - arm), (rx, ry + arm)], fill=(255, 50, 50), width=2)

    # Baseline (green horizontal line).
    if baseline_y is not None and 0 <= baseline_y < h:
        draw.line([(0, baseline_y), (w - 1, baseline_y)], fill=(50, 200, 50, 128), width=1)

    # Frame label.
    label = f"F{frame_idx}"
    if runtime_w and runtime_h:
        label += f"  {runtime_w}×{runtime_h}"
    draw.text((4, 4), label, fill=(255, 255, 255))

    return display


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    st.title("🐱 WilliCat Asset Forge")
    st.caption(f"v{config.VERSION} — Local Asset Processing Pipeline")

    # ---- Sidebar: Source Panel ----
    with st.sidebar:
        st.header("📁 Source")
        source_mode = st.radio("Input mode", ["Upload file", "Enter path"], horizontal=True)

        source_path: str | None = None

        if source_mode == "Upload file":
            uploaded = st.file_uploader(
                "Drop a PNG or WebP",
                type=["png", "webp"],
                help="Sprite sheet, animated WebP, or individual frames",
            )
            if uploaded is not None:
                # Save to inbox.
                inbox = inbox_dir()
                save_path = inbox / uploaded.name
                save_path.write_bytes(uploaded.getvalue())
                source_path = str(save_path)
                st.success(f"Saved to inbox: {uploaded.name}")
        else:
            source_path = st.text_input("Image path", placeholder="/path/to/sprite_sheet.png")

        # Recent inbox files.
        inbox = inbox_dir()
        recent = sorted(inbox.glob("*.*"), key=lambda p: p.stat().st_mtime, reverse=True)[:5]
        if recent:
            st.markdown("**Recent inbox files:**")
            for f in recent:
                if st.button(f.name, key=f"inbox_{f.name}"):
                    source_path = str(f)

        st.divider()

        # ---- Asset Metadata ----
        st.header("🏷️ Asset Metadata")
        characters = list_characters()
        character = st.selectbox("Character", characters if characters else ["mochi"])
        actions = list_actions()
        action = st.selectbox("Action", actions if actions else ["walk"])

        action_profile = None
        try:
            action_profile = load_action(action)
        except Exception:
            pass

        directions = ["", "side_right", "side_left", "up", "down"]
        direction = st.selectbox("Direction", directions)

        status = st.selectbox("Status", config.STATUS_VALUES, index=0)

        st.divider()

        # ---- Extraction Mode (V1.2) ----
        st.header("✂️ Extraction Mode")

        # Preset loader for known metadata or action profiles
        resolved_src = _resolve_source_path(source_path) if source_path else None
        meta_file = _find_associated_metadata(resolved_src)
        if meta_file:
            if st.button(f"📋 Load Preset ({meta_file.name})", help="Populate split edges and root registration from metadata"):
                try:
                    with open(meta_file, "r", encoding="utf-8") as mf:
                        mdata = json.load(mf)
                    if "detected_grid" in mdata and "split_positions_x_px" in mdata["detected_grid"]:
                        st.session_state["split_edges_text"] = ",".join(str(x) for x in mdata["detected_grid"]["split_positions_x_px"])
                    if "registration" in mdata and "per_frame" in mdata["registration"]:
                        st.session_state["root_x_text"] = ",".join(str(f["measured_source_local_root_x"]) for f in mdata["registration"]["per_frame"])
                    st.session_state["extraction_mode_label"] = "Explicit Edges"
                    st.session_state["canvas_mode_label"] = "Root-Preserving Expand"
                    st.rerun()
                except Exception as e:
                    st.warning(f"Could not load metadata: {e}")
        elif character == "mochi" and action == "serve":
            if st.button("📋 Load Mochi Serve V1 Preset", help="Populate known-good Serve split edges and per-frame root X"):
                st.session_state["split_edges_text"] = "0,273,545,817,1098,1362,1633,1896,2172"
                st.session_state["root_x_text"] = "162.25,158.75,154.5,147.0,145.0,152.5,154.25,152.75"
                st.session_state["extraction_mode_label"] = "Explicit Edges"
                st.session_state["canvas_mode_label"] = "Root-Preserving Expand"
                st.rerun()

        extraction_options = ["Grid", "Content Strip", "Explicit Edges"]
        default_extract_idx = 0
        if "extraction_mode_label" in st.session_state and st.session_state["extraction_mode_label"] in extraction_options:
            default_extract_idx = extraction_options.index(st.session_state["extraction_mode_label"])

        extraction_mode_label = st.radio(
            "Frame extraction",
            extraction_options,
            index=default_extract_idx,
            horizontal=True,
            help="Grid: uniform cells. Content Strip: auto-detect gaps. Explicit Edges: manual split positions.",
        )
        extraction_mode_map = {
            "Grid": "grid",
            "Content Strip": "content-strip",
            "Explicit Edges": "explicit-edges",
        }
        extraction_mode = extraction_mode_map[extraction_mode_label]

        # Mode-specific controls.
        rows: int | None = None
        cols: int | None = None
        frame_count: int | None = None
        alpha_threshold: int = 0
        min_gap_width: int = 1
        split_edges: list[int] | None = None

        if extraction_mode == "grid":
            rows = st.number_input("Rows", min_value=1, max_value=20, value=1)
            cols = st.number_input("Columns", min_value=1, max_value=64, value=8)
        elif extraction_mode == "content-strip":
            frame_count = st.number_input("Expected frames", min_value=1, max_value=64, value=8)
            alpha_threshold = st.number_input(
                "Alpha threshold",
                min_value=0,
                max_value=255,
                value=0,
                help="Max alpha value considered transparent for gap detection.",
            )
            min_gap_width = st.number_input(
                "Min gap width (px)",
                min_value=1,
                max_value=100,
                value=1,
                help="Minimum consecutive transparent columns to count as a gap.",
            )
        elif extraction_mode == "explicit-edges":
            frame_count = st.number_input("Expected frames", min_value=1, max_value=64, value=8)
            edges_default = st.session_state.get("split_edges_text", "")
            edges_text = st.text_input(
                "Split edges (comma-separated)",
                value=edges_default,
                placeholder="0,273,545,817,1098,1362,1633,1896,2172",
                help="N+1 X positions for N frames. Must be strictly increasing.",
            )
            split_edges = _parse_split_edges(edges_text)
            if edges_text.strip() and split_edges is None:
                st.error("Invalid split edges — must be comma-separated integers.")
            elif split_edges is not None:
                n_edges = len(split_edges)
                n_frames = n_edges - 1
                widths = [split_edges[i + 1] - split_edges[i] for i in range(n_frames)]
                st.caption(f"{n_frames} frames: widths = {widths}")

        st.divider()

        # ---- Animation Config ----
        st.header("⚙️ Animation Config")
        default_fps = action_profile.default_fps if action_profile else 8
        fps = st.number_input("FPS", min_value=1, max_value=60, value=default_fps)
        default_loop = action_profile.loop if action_profile else True
        loop = st.checkbox("Loop", value=default_loop)
        safe_padding = st.number_input(
            "Safe padding (px)",
            min_value=0,
            max_value=128,
            value=0,
        )

        st.divider()

        # ---- Canvas Mode (V1.2) ----
        st.header("🖼️ Canvas Mode")
        canvas_options = ["Standard (Resize)", "Root-Preserving Expand"]
        default_canvas_idx = 0
        if "canvas_mode_label" in st.session_state and st.session_state["canvas_mode_label"] in canvas_options:
            default_canvas_idx = canvas_options.index(st.session_state["canvas_mode_label"])

        canvas_mode_label = st.radio(
            "Canvas processing",
            canvas_options,
            index=default_canvas_idx,
            horizontal=True,
            help="Standard: scale to square/rect runtime size. Root-Preserving: expand canvas without resizing artwork.",
        )
        canvas_mode = "resize" if canvas_mode_label == "Standard (Resize)" else "root_preserving"

        runtime_size: int | None = None
        runtime_width: int | None = None
        runtime_height: int | None = None
        root_x: int | None = None
        root_y: int | None = None
        baseline_y: int | None = None
        source_baseline_y: int | None = None
        source_root_x_per_frame: list[float] | None = None

        if canvas_mode == "resize":
            runtime_size = st.number_input(
                "Target runtime size (px, 0=keep)",
                min_value=0,
                max_value=2048,
                value=320,
            )
        else:
            # Root-preserving mode controls.
            rp_col1, rp_col2 = st.columns(2)
            with rp_col1:
                runtime_width = st.number_input("Runtime width", min_value=1, max_value=4096, value=360)
            with rp_col2:
                runtime_height = st.number_input("Runtime height", min_value=1, max_value=4096, value=520)

            rp_col3, rp_col4 = st.columns(2)
            with rp_col3:
                root_x = st.number_input("Root X", min_value=0, max_value=4096, value=185)
            with rp_col4:
                root_y = st.number_input("Root Y", min_value=0, max_value=4096, value=484)

            baseline_y = root_y  # Root Y and baseline Y are the same concept.

            source_baseline_y = st.number_input(
                "Source baseline Y",
                min_value=0,
                max_value=8192,
                value=580,
                help="Y row in the source frame where feet contact the ground.",
            )

            root_default = st.session_state.get("root_x_text", "")
            root_x_text = st.text_input(
                "Per-frame source root X (optional)",
                value=root_default,
                placeholder="162.25,158.75,154.5,...",
                help="Comma-separated per-frame root X in source coordinates. Leave blank to auto-center.",
            )
            source_root_x_per_frame = _parse_root_x_per_frame(root_x_text)

    # ---- Main content ----
    if not source_path or not source_path.strip():
        st.info("👈 Select or upload a source image to begin.")
        return

    source = _resolve_source_path(source_path)
    if not source:
        st.error(f"Source file not found: `{source_path}`")
        return

    # ---- Source Info ----
    col1, col2 = st.columns([1, 1])
    with col1:
        st.subheader("🖼️ Source")
        inspection = inspect_source(source)
        st.write(f"**File:** {source.name}")
        st.write(f"**Type:** {inspection.file_type.upper()}")
        st.write(f"**Dimensions:** {inspection.width} × {inspection.height}")
        st.write(f"**Mode:** {inspection.mode}")
        st.write(f"**Alpha:** {'Yes' if inspection.has_alpha else 'No'}")
        if inspection.is_animated:
            st.write(f"**Animated:** Yes ({inspection.frame_count} frames)")
        if inspection.potential_grid:
            st.write(f"**Detected grid:** {inspection.potential_grid}")

        # Show extraction config summary.
        st.caption(f"Extraction: **{extraction_mode_label}** | Canvas: **{canvas_mode_label}**")

    # ---- Extract & Preview ----
    with col2:
        st.subheader("🎬 Preview")

    # Extract frames based on mode.
    frames: list[Image.Image] = []
    extraction_error: str | None = None
    try:
        if inspection.is_animated and inspection.file_type == "webp":
            frames = extract_webp_frames(str(source))
        elif extraction_mode == "grid":
            with Image.open(source) as img:
                src_img = ensure_rgba(img.copy())
            grid = detect_grid(src_img.width, src_img.height, rows=rows, cols=cols)
            frames = extract_frames(
                src_img, grid["rows"], grid["cols"],
                grid["cell_w"], grid["cell_h"], grid["frame_count"],
            )
        elif extraction_mode == "content-strip":
            with Image.open(source) as img:
                src_img = ensure_rgba(img.copy())
            expected = frame_count if frame_count else 8
            strips = detect_content_strips(
                src_img,
                expected_count=expected,
                alpha_threshold=alpha_threshold,
                min_gap_width=min_gap_width,
            )
            frames = extract_content_strip_frames(src_img, strips)
        elif extraction_mode == "explicit-edges":
            if split_edges is None:
                with col2:
                    st.info("👈 Enter split edges (comma-separated X positions) in the sidebar to extract frames.")
                return
            with Image.open(source) as img:
                src_img = ensure_rgba(img.copy())
            strips = explicit_split_edges_to_strips(split_edges)
            frames = extract_content_strip_frames(src_img, strips)
    except Exception as e:
        extraction_error = str(e)

    if extraction_error:
        with col2:
            st.error(f"Frame extraction error: {extraction_error}")
            if extraction_mode == "grid":
                st.info("💡 For irregular sprite sheets, try **Explicit Edges** or **Content Strip** mode in the sidebar.")
        return

    if not frames:
        with col2:
            st.warning("No frames extracted.")
        return

    # For root-preserving preview, apply canvas expand to frames.
    preview_frames = frames
    preview_root_x: int | None = None
    preview_baseline_y: int | None = None
    preview_rt_w: int | None = None
    preview_rt_h: int | None = None

    if canvas_mode == "root_preserving" and runtime_width and runtime_height:
        preview_rt_w = runtime_width
        preview_rt_h = runtime_height
        preview_root_x = root_x
        preview_baseline_y = baseline_y

        if root_x is not None and baseline_y is not None and source_baseline_y is not None:
            # Resolve per-frame source root X.
            if source_root_x_per_frame and len(source_root_x_per_frame) == len(frames):
                per_frame_roots = source_root_x_per_frame
            else:
                per_frame_roots = [f.width / 2.0 for f in frames]

            try:
                expanded = []
                for i, f in enumerate(frames):
                    expanded.append(root_preserving_expand(
                        frame=f,
                        runtime_width=runtime_width,
                        runtime_height=runtime_height,
                        root_x=root_x,
                        baseline_y=baseline_y,
                        source_root_x=per_frame_roots[i],
                        source_baseline_y=source_baseline_y,
                    ))
                preview_frames = expanded
            except Exception as e:
                st.warning(f"Root-preserving preview error: {e}")
    elif canvas_mode == "resize" and runtime_size and runtime_size > 0:
        from willicat_asset_forge.image_processing import resize_frame
        preview_frames = [resize_frame(f, (runtime_size, runtime_size)) for f in frames]

    with col2:
        # Animation preview using GIF.
        preview_data = create_preview_gif(preview_frames, fps=fps, loop=loop)
        if preview_data:
            st.image(preview_data, caption=f"Animation preview — {len(preview_frames)} frames @ {fps} FPS")

        # Frame-by-frame inspector.
        frame_idx = st.slider(
            "Frame inspector",
            min_value=0,
            max_value=len(preview_frames) - 1,
            value=0,
            key="frame_slider",
        )

    # ---- Frame Inspector ----
    st.subheader(f"🔍 Frame {frame_idx} / {len(preview_frames)}")
    col_a, col_b = st.columns([1, 1])

    frame = preview_frames[frame_idx]
    with col_a:
        display = _annotate_frame_preview(
            frame,
            frame_idx,
            root_x=preview_root_x,
            baseline_y=preview_baseline_y,
            runtime_w=preview_rt_w,
            runtime_h=preview_rt_h,
        )
        st.image(display, caption=f"Frame {frame_idx} (annotated)", use_container_width=True)

    with col_b:
        fqa = analyse_frame(frame, frame_idx)
        st.write(f"**Size:** {fqa.width} × {fqa.height}")
        if fqa.alpha_bbox:
            st.write(f"**Alpha bounds:** {fqa.alpha_bbox}")
            st.write(
                f"**Padding:** T={fqa.padding_top} B={fqa.padding_bottom} "
                f"L={fqa.padding_left} R={fqa.padding_right}"
            )
            st.write(f"**Center:** ({fqa.center_x:.1f}, {fqa.center_y:.1f})")
            st.write(f"**Baseline Y:** {fqa.baseline_y}")
            st.write(f"**Visible:** {fqa.visible_width} × {fqa.visible_height}")
        if preview_root_x is not None and preview_baseline_y is not None:
            st.write(f"**Root:** ({preview_root_x}, {preview_baseline_y})")
        # Source frame info (before canvas expand).
        if canvas_mode == "root_preserving" and frame_idx < len(frames):
            src_f = frames[frame_idx]
            st.caption(f"Source frame: {src_f.width}×{src_f.height}")
        if fqa.warnings:
            for w in fqa.warnings:
                st.warning(f"⚠ {w}")

    # ---- QA Summary ----
    st.subheader("📊 QA Summary")
    qa = analyse_animation(preview_frames)
    summary = qa_summary_text(qa)
    if qa.overall == "PASS":
        st.success(summary)
    else:
        st.warning(summary)

    # ---- Export Panel ----
    st.divider()
    st.subheader("📦 Export")

    # Godot path preview.
    try:
        project_root = detect_project_root()
        suggested = suggest_godot_paths(project_root, character, action, direction, status)
        st.write(f"**Character:** {character}")
        st.write(f"**Action:** {action}")
        if direction:
            st.write(f"**Direction:** {direction}")
        st.write(f"**Suggested destination:** `{suggested.get('rel_dir', '')}`")
    except FileNotFoundError:
        project_root = None
        suggested = {}
        st.info("Project root not detected — Godot paths unavailable.")

    # Build kwargs (shared by both Build and Export buttons).
    def _build_kwargs() -> dict:
        kwargs = dict(
            source_path=str(source),
            character=character,
            action=action,
            direction=direction,
            fps=fps,
            loop=loop,
            safe_padding=safe_padding,
            status=status,
            extraction_mode=extraction_mode,
            alpha_threshold=alpha_threshold,
            min_gap_width=min_gap_width,
            canvas_mode=canvas_mode,
        )
        # Extraction-specific.
        if extraction_mode == "grid":
            kwargs["rows"] = rows
            kwargs["cols"] = cols
        elif extraction_mode == "content-strip":
            kwargs["frame_count"] = frame_count
        elif extraction_mode == "explicit-edges":
            kwargs["split_edges"] = split_edges
            kwargs["frame_count"] = frame_count

        # Canvas-specific.
        if canvas_mode == "resize":
            kwargs["runtime_size"] = runtime_size if runtime_size and runtime_size > 0 else None
        elif canvas_mode == "root_preserving":
            kwargs["runtime_width"] = runtime_width
            kwargs["runtime_height"] = runtime_height
            kwargs["root_x"] = root_x
            kwargs["baseline_y"] = baseline_y
            kwargs["source_baseline_y"] = source_baseline_y
            kwargs["source_root_x_per_frame"] = source_root_x_per_frame

        return kwargs

    col_e1, col_e2, col_e3 = st.columns(3)

    with col_e1:
        if st.button("🔨 Build Runtime Atlas", type="primary"):
            with st.spinner("Processing..."):
                try:
                    result = run_pipeline(**_build_kwargs())
                    st.success(f"Atlas saved: {result['atlas_path']}")
                    st.json(result["manifest"])
                except Exception as e:
                    st.error(f"Build failed: {e}")

    with col_e2:
        if st.button("🎮 Generate Godot .tres"):
            with st.spinner("Generating..."):
                try:
                    result = run_pipeline(**_build_kwargs())
                    st.success(f"SpriteFrames: {result['tres_path']}")
                    st.code(result["tres_content"], language="ini")
                except Exception as e:
                    st.error(f"Export failed: {e}")

    with col_e3:
        out = output_dir()
        if st.button("📂 Open Output Folder"):
            import subprocess
            subprocess.Popen(["open", str(out)])
            st.info(f"Opened: {out}")


if __name__ == "__main__":
    main()
