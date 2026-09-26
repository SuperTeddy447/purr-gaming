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
from PIL import Image

from willicat_asset_forge import config
from willicat_asset_forge.animation_preview import (
    composite_on_checkerboard,
    create_preview_apng,
    create_preview_gif,
    frames_to_base64_pngs,
)
from willicat_asset_forge.forge import inspect_source, run_pipeline
from willicat_asset_forge.image_processing import alpha_bounds, ensure_rgba
from willicat_asset_forge.qa import analyse_animation, analyse_frame, qa_summary_text
from willicat_asset_forge.registry import list_actions, list_characters
from willicat_asset_forge.sprite_sheet import detect_grid, extract_frames
from willicat_asset_forge.webp_processing import extract_webp_frames
from willicat_asset_forge.godot_export import suggest_godot_paths
from willicat_asset_forge.paths import detect_project_root, output_dir, inbox_dir


st.set_page_config(
    page_title="WilliCat Asset Forge",
    page_icon="🐱",
    layout="wide",
)


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

        directions = ["", "side_right", "side_left", "up", "down"]
        direction = st.selectbox("Direction", directions)

        status = st.selectbox("Status", config.STATUS_VALUES, index=0)

        st.divider()

        # ---- Frame Config ----
        st.header("⚙️ Frame Config")
        rows = st.number_input("Rows", min_value=1, max_value=20, value=1)
        cols = st.number_input("Columns", min_value=1, max_value=64, value=8)
        fps = st.number_input("FPS", min_value=1, max_value=60, value=8)
        loop = st.checkbox("Loop", value=True)
        runtime_size = st.number_input(
            "Target runtime size (px, 0=keep)",
            min_value=0,
            max_value=2048,
            value=320,
        )
        safe_padding = st.number_input(
            "Safe padding (px)",
            min_value=0,
            max_value=128,
            value=0,
        )

    # ---- Main content ----
    if not source_path or not Path(source_path).exists():
        st.info("👈 Select or upload a source image to begin.")
        return

    source = Path(source_path)

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

    # ---- Extract & Preview ----
    with col2:
        st.subheader("🎬 Preview")

    # Extract frames.
    frames: list[Image.Image] = []
    try:
        if inspection.is_animated and inspection.file_type == "webp":
            frames = extract_webp_frames(str(source))
        else:
            with Image.open(source) as img:
                src_img = ensure_rgba(img.copy())
            grid = detect_grid(src_img.width, src_img.height, rows=rows, cols=cols)
            frames = extract_frames(
                src_img, grid["rows"], grid["cols"],
                grid["cell_w"], grid["cell_h"], grid["frame_count"],
            )
    except Exception as e:
        st.error(f"Frame extraction error: {e}")
        return

    if not frames:
        st.warning("No frames extracted.")
        return

    with col2:
        # Animation preview using APNG.
        preview_data = create_preview_gif(frames, fps=fps, loop=loop)
        if preview_data:
            st.image(preview_data, caption=f"Animation preview — {len(frames)} frames @ {fps} FPS")

        # Frame-by-frame inspector.
        frame_idx = st.slider(
            "Frame inspector",
            min_value=0,
            max_value=len(frames) - 1,
            value=0,
            key="frame_slider",
        )

    # ---- Frame Inspector ----
    st.subheader(f"🔍 Frame {frame_idx} / {len(frames)}")
    col_a, col_b = st.columns([1, 1])

    frame = frames[frame_idx]
    with col_a:
        display = composite_on_checkerboard(frame, tile=16)
        st.image(display, caption=f"Frame {frame_idx} (checkerboard BG)", use_container_width=True)

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
        if fqa.warnings:
            for w in fqa.warnings:
                st.warning(f"⚠ {w}")

    # ---- QA Summary ----
    st.subheader("📊 QA Summary")
    qa = analyse_animation(frames)
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

    col_e1, col_e2, col_e3 = st.columns(3)

    with col_e1:
        if st.button("🔨 Build Runtime Atlas", type="primary"):
            with st.spinner("Processing..."):
                result = run_pipeline(
                    source_path=str(source),
                    character=character,
                    action=action,
                    direction=direction,
                    rows=rows,
                    cols=cols,
                    fps=fps,
                    loop=loop,
                    runtime_size=runtime_size if runtime_size > 0 else None,
                    safe_padding=safe_padding,
                    status=status,
                )
            st.success(f"Atlas saved: {result['atlas_path']}")
            st.json(result["manifest"])

    with col_e2:
        if st.button("🎮 Generate Godot .tres"):
            with st.spinner("Generating..."):
                result = run_pipeline(
                    source_path=str(source),
                    character=character,
                    action=action,
                    direction=direction,
                    rows=rows,
                    cols=cols,
                    fps=fps,
                    loop=loop,
                    runtime_size=runtime_size if runtime_size > 0 else None,
                    safe_padding=safe_padding,
                    status=status,
                )
            st.success(f"SpriteFrames: {result['tres_path']}")
            st.code(result["tres_content"], language="ini")

    with col_e3:
        out = output_dir()
        if st.button("📂 Open Output Folder"):
            import subprocess
            subprocess.Popen(["open", str(out)])
            st.info(f"Opened: {out}")


if __name__ == "__main__":
    main()
