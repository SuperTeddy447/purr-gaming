#!/usr/bin/env python3
"""WilliCat Asset Forge — command-line interface.

Usage examples:

    python cli.py inspect <path>
    python cli.py build --source <path> --character mochi --action walk ...
    python cli.py export-godot --source <path> ...

Designed for both human operators and coding agents.
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict
from pathlib import Path

# Allow running as `python cli.py` from the tool directory.
_tool_root = Path(__file__).resolve().parent
_repo_root = _tool_root.parent.parent
if str(_tool_root.parent) not in sys.path:
    sys.path.insert(0, str(_tool_root.parent))

from willicat_asset_forge import config
from willicat_asset_forge.forge import inspect_source, run_pipeline
from willicat_asset_forge.registry import list_actions, list_characters, load_action, load_character
from willicat_asset_forge.static_prop import PIVOTS, package_static_prop


def _parse_float_list(value: str) -> list[float]:
    """Parse a comma-separated list of floats from CLI argument."""
    return [float(x.strip()) for x in value.split(",")]


def _parse_int_list(value: str) -> list[int]:
    """Parse a comma-separated list of ints from CLI argument."""
    return [int(x.strip()) for x in value.split(",")]


def cmd_inspect(args: argparse.Namespace) -> None:
    """Inspect a source image and print metadata."""
    info = inspect_source(args.path)
    print(json.dumps(asdict(info), indent=2, default=str))


def _build_pipeline_kwargs(args: argparse.Namespace) -> dict:
    """Build keyword arguments for run_pipeline from CLI args."""
    kwargs = dict(
        source_path=args.source,
        character=args.character,
        action=args.action,
        direction=args.direction or "",
        rows=args.rows,
        cols=args.cols,
        frame_count=args.frame_count,
        fps=args.fps,
        loop=not args.no_loop,
        runtime_size=args.runtime_size,
        runtime_width=args.runtime_width,
        runtime_height=args.runtime_height,
        safe_padding=args.safe_padding,
        status=args.status,
        project_root_override=args.project_root,
        output_dir_override=args.output_dir,
        extraction_mode=args.extraction_mode,
        alpha_threshold=args.alpha_threshold,
        min_gap_width=args.min_gap_width,
        split_edges=args.split_edges,
        canvas_mode=args.canvas_mode,
        root_x=args.root_x,
        baseline_y=args.baseline_y,
        source_baseline_y=args.source_baseline_y,
        source_root_x_per_frame=args.source_root_x_per_frame,
    )
    return kwargs


def cmd_build(args: argparse.Namespace) -> None:
    """Run the full processing pipeline."""
    result = run_pipeline(**_build_pipeline_kwargs(args))
    # Print summary.
    print("=" * 60)
    print("WilliCat Asset Forge — Build Complete")
    print("=" * 60)
    print(f"Source:       {args.source}")
    print(f"Character:    {args.character}")
    print(f"Action:       {args.action}")
    if args.direction:
        print(f"Direction:    {args.direction}")
    print(f"Status:       {args.status}")
    print(f"Extraction:   {args.extraction_mode}")
    print(f"Canvas:       {args.canvas_mode}")
    print(f"Grid:         {result['grid']}")
    print()
    print("--- QA Summary ---")
    print(result["qa_summary"])
    print()
    print(f"Atlas:        {result['atlas_path']}")
    print(f"SpriteFrames: {result['tres_path']}")
    print(f"Frames:       {result['frames_dir']}")
    print(f"Manifest:     {Path(result['atlas_path']).parent / (Path(result['atlas_path']).stem + '_manifest.json')}")
    if result.get("suggested_godot_paths"):
        print()
        print("--- Suggested Godot Paths ---")
        for k, v in result["suggested_godot_paths"].items():
            print(f"  {k}: {v}")
    print()
    # Also write full JSON result.
    json_path = Path(result["atlas_path"]).parent / (
        Path(result["atlas_path"]).stem + "_result.json"
    )
    with open(json_path, "w", encoding="utf-8") as f:
        # Remove tres_content from JSON (it's large text).
        out = {k: v for k, v in result.items() if k != "tres_content"}
        json.dump(out, f, indent=2, default=str)
    print(f"Full result:  {json_path}")


def cmd_export_godot(args: argparse.Namespace) -> None:
    """Generate a Godot SpriteFrames .tres from a processed asset."""
    result = run_pipeline(**_build_pipeline_kwargs(args))
    print(f"SpriteFrames .tres: {result['tres_path']}")
    print(f"Atlas:              {result['atlas_path']}")
    if result.get("suggested_godot_paths"):
        print()
        print("To deploy to Godot project:")
        sp = result["suggested_godot_paths"]
        print(f"  cp {result['atlas_path']} {sp.get('atlas_abs_path', '?')}")
        print(f"  cp {result['tres_path']} {sp.get('tres_abs_path', '?')}")


def cmd_list_profiles(args: argparse.Namespace) -> None:
    """List available character and action profiles."""
    print("Characters:", list_characters())
    print("Actions:   ", list_actions())


def cmd_build_static(args: argparse.Namespace) -> None:
    """Package one static environment PNG and print its QA metadata."""
    result = package_static_prop(
        source=args.source,
        asset_id=args.asset_id,
        output_dir=args.output_dir,
        pivot=args.pivot,
        status=args.status,
        alpha_threshold=args.alpha_threshold,
        padding=args.padding,
        opaque=args.opaque,
        preserve_canvas=args.preserve_canvas,
        expected_size=tuple(map(int, args.expected_size.lower().split("x"))) if args.expected_size else None,
    )
    print(json.dumps(result, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="willicat-asset-forge",
        description="WilliCat Asset Forge — local asset processing pipeline",
    )
    parser.add_argument(
        "--project-root",
        help="Override WilliCat project root detection.",
    )
    sub = parser.add_subparsers(dest="command")

    # --- inspect ---
    p_inspect = sub.add_parser("inspect", help="Inspect a source image file.")
    p_inspect.add_argument("path", help="Path to image file.")

    # --- build ---
    p_build = sub.add_parser("build", help="Run the full processing pipeline.")
    _add_build_args(p_build)

    # --- export-godot ---
    p_export = sub.add_parser("export-godot", help="Build and generate Godot .tres.")
    _add_build_args(p_export)

    # --- list-profiles ---
    sub.add_parser("list-profiles", help="List character and action profiles.")

    # --- build-static ---
    p_static = sub.add_parser(
        "build-static", help="Package one static prop PNG with alpha and pivot QA."
    )
    p_static.add_argument("--source", required=True)
    p_static.add_argument("--asset-id", required=True)
    p_static.add_argument("--output-dir", required=True)
    p_static.add_argument("--pivot", required=True, choices=sorted(PIVOTS))
    p_static.add_argument("--status", default="CANDIDATE", choices=config.STATUS_VALUES)
    p_static.add_argument("--alpha-threshold", type=int, default=16)
    p_static.add_argument("--padding", type=int, default=16)
    p_static.add_argument("--opaque", action="store_true")
    p_static.add_argument("--preserve-canvas", action="store_true", help="Keep the exact transparent full canvas and top-left registration.")
    p_static.add_argument("--expected-size", help="Reject wrong source size, e.g. 960x1980.")

    args = parser.parse_args()

    if args.command == "inspect":
        cmd_inspect(args)
    elif args.command == "build":
        cmd_build(args)
    elif args.command == "export-godot":
        cmd_export_godot(args)
    elif args.command == "list-profiles":
        cmd_list_profiles(args)
    elif args.command == "build-static":
        cmd_build_static(args)
    else:
        parser.print_help()
        sys.exit(1)


def _add_build_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--source", required=True, help="Path to source image.")
    parser.add_argument("--character", required=True, help="Character id (e.g. mochi).")
    parser.add_argument("--action", required=True, help="Action id (e.g. walk).")
    parser.add_argument("--direction", default="", help="Direction (e.g. side_right).")
    parser.add_argument("--rows", type=int, default=None, help="Sprite-sheet rows.")
    parser.add_argument("--cols", type=int, default=None, help="Sprite-sheet columns.")
    parser.add_argument("--frame-count", type=int, default=None, help="Total frame count.")
    parser.add_argument("--fps", type=int, default=config.DEFAULT_FPS, help="Animation FPS.")
    parser.add_argument("--no-loop", action="store_true", help="Disable animation loop.")
    parser.add_argument(
        "--runtime-size",
        type=int,
        default=None,
        help="Target runtime cell size (square, e.g. 320).",
    )
    parser.add_argument(
        "--runtime-width",
        type=int,
        default=None,
        help="Target runtime cell width (for non-square cells).",
    )
    parser.add_argument(
        "--runtime-height",
        type=int,
        default=None,
        help="Target runtime cell height (for non-square cells).",
    )
    parser.add_argument(
        "--safe-padding",
        type=int,
        default=0,
        help="Transparent padding pixels to add around each frame.",
    )
    parser.add_argument(
        "--status",
        default=config.DEFAULT_STATUS,
        choices=config.STATUS_VALUES,
        help="Asset status.",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Override output directory.",
    )

    # V1.2 — extraction mode.
    parser.add_argument(
        "--extraction-mode",
        default="grid",
        choices=("grid", "content-strip", "explicit-edges"),
        help="Frame extraction mode: 'grid', 'content-strip', or 'explicit-edges'.",
    )
    parser.add_argument(
        "--alpha-threshold",
        type=int,
        default=0,
        help="Maximum alpha value considered transparent for content-strip detection.",
    )
    parser.add_argument(
        "--min-gap-width",
        type=int,
        default=1,
        help="Minimum consecutive transparent columns to qualify as a gap.",
    )
    parser.add_argument(
        "--split-edges",
        type=_parse_int_list,
        default=None,
        help="Comma-separated split edge X positions (explicit-edges mode). "
             "N+1 values for N frames, e.g. '0,273,545,817'.",
    )

    # V1.2 — canvas mode.
    parser.add_argument(
        "--canvas-mode",
        default="resize",
        choices=("resize", "root_preserving"),
        help="Canvas processing: 'resize' (scale to runtime) or 'root_preserving' (expand only).",
    )
    parser.add_argument(
        "--root-x",
        type=int,
        default=None,
        help="Target root X position in runtime cell (root_preserving mode).",
    )
    parser.add_argument(
        "--baseline-y",
        type=int,
        default=None,
        help="Target baseline Y position in runtime cell (root_preserving mode).",
    )
    parser.add_argument(
        "--source-baseline-y",
        type=int,
        default=None,
        help="Baseline Y position in source frames (root_preserving mode).",
    )
    parser.add_argument(
        "--source-root-x-per-frame",
        type=_parse_float_list,
        default=None,
        help="Comma-separated per-frame source root X values (root_preserving mode).",
    )


if __name__ == "__main__":
    main()
