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


def cmd_inspect(args: argparse.Namespace) -> None:
    """Inspect a source image and print metadata."""
    info = inspect_source(args.path)
    print(json.dumps(asdict(info), indent=2, default=str))


def cmd_build(args: argparse.Namespace) -> None:
    """Run the full processing pipeline."""
    result = run_pipeline(
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
        safe_padding=args.safe_padding,
        status=args.status,
        project_root_override=args.project_root,
        output_dir_override=args.output_dir,
    )
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
    result = run_pipeline(
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
        safe_padding=args.safe_padding,
        status=args.status,
        project_root_override=args.project_root,
        output_dir_override=args.output_dir,
    )
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

    args = parser.parse_args()

    if args.command == "inspect":
        cmd_inspect(args)
    elif args.command == "build":
        cmd_build(args)
    elif args.command == "export-godot":
        cmd_export_godot(args)
    elif args.command == "list-profiles":
        cmd_list_profiles(args)
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


if __name__ == "__main__":
    main()
