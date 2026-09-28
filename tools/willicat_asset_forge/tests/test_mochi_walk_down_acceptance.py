"""WilliCat Asset Forge — Mochi Walk Down trial acceptance test.

Uses the real MOCHI_WALK_DOWN_V1 source as a test fixture.
Validates V1.1 hardening and structural compatibility with production assets.
Does NOT modify any production files.
"""

from __future__ import annotations

import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path

_tool_root = Path(__file__).resolve().parent.parent
if str(_tool_root.parent) not in sys.path:
    sys.path.insert(0, str(_tool_root.parent))

from PIL import Image, ImageChops

from willicat_asset_forge.forge import inspect_source, run_pipeline
from willicat_asset_forge.paths import detect_project_root


def _get_mochi_walk_down_source() -> Path | None:
    """Locate the authoritative Mochi walk down source PNG."""
    try:
        root = detect_project_root()
    except FileNotFoundError:
        return None
    src = root / "docs" / "source_assets" / "mochi" / "walk_down_v1" / \
        "MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk_down.png"
    return src if src.exists() else None


def _get_production_walk_down_atlas() -> Path | None:
    """Locate the existing accepted production runtime atlas."""
    try:
        root = detect_project_root()
    except FileNotFoundError:
        return None
    atlas = root / "assets" / "characters" / "mochi" / "animations" / "walk" / \
        "mochi_walk_down_v1.png"
    return atlas if atlas.exists() else None


def _get_production_walk_down_tres() -> Path | None:
    """Locate the existing accepted production SpriteFrames .tres."""
    try:
        root = detect_project_root()
    except FileNotFoundError:
        return None
    tres = root / "assets" / "characters" / "mochi" / "animations" / "walk" / \
        "mochi_walk_down_v1.tres"
    return tres if tres.exists() else None


@unittest.skipUnless(
    _get_mochi_walk_down_source() is not None,
    "Mochi walk down source not available — skipping acceptance test.",
)
class TestMochiWalkDownAcceptance(unittest.TestCase):
    """Acceptance test: process the real Mochi walk down sprite sheet."""

    def test_source_inspection(self):
        src = _get_mochi_walk_down_source()
        info = inspect_source(src)
        self.assertEqual(info.width, 5120)
        self.assertEqual(info.height, 640)
        self.assertEqual(info.mode, "RGBA")
        self.assertTrue(info.has_alpha)
        self.assertFalse(info.is_animated)
        self.assertEqual(info.potential_grid["rows"], 1)
        self.assertEqual(info.potential_grid["cols"], 8)
        self.assertEqual(info.potential_grid["cell_w"], 640)
        self.assertEqual(info.potential_grid["cell_h"], 640)

    def test_full_pipeline_run(self):
        src = _get_mochi_walk_down_source()
        with tempfile.TemporaryDirectory() as tmp:
            result = run_pipeline(
                source_path=str(src),
                character="mochi",
                action="walk",
                direction="down",
                rows=1,
                cols=8,
                fps=8,
                loop=True,
                runtime_size=320,
                status="PROTOTYPE",
                output_dir_override=tmp,
            )

            # Grid detection.
            self.assertEqual(result["grid"]["rows"], 1)
            self.assertEqual(result["grid"]["cols"], 8)
            self.assertEqual(result["grid"]["cell_w"], 640)
            self.assertEqual(result["grid"]["cell_h"], 640)

            # Atlas dimensions.
            atlas_path = Path(result["atlas_path"])
            self.assertTrue(atlas_path.exists())
            with Image.open(atlas_path) as atlas:
                self.assertEqual(atlas.size, (2560, 320))
                self.assertEqual(atlas.mode, "RGBA")

            # Manifest.
            manifest = result["manifest"]
            self.assertEqual(manifest["character"], "mochi")
            self.assertEqual(manifest["action"], "walk")
            self.assertEqual(manifest["direction"], "down")
            self.assertEqual(manifest["frames"], 8)
            self.assertEqual(manifest["fps"], 8)
            self.assertTrue(manifest["loop"])
            self.assertEqual(manifest["source_frame_size"], [640, 640])
            self.assertEqual(manifest["runtime_frame_size"], [320, 320])

            # QA checks.
            qa = manifest["qa"]
            self.assertIn(qa["overall"], ("PASS", "WARNING"))
            self.assertEqual(qa["baseline_variation"], 14)
            # Top-touching frames detected correctly on frames [0, 3, 7].
            self.assertEqual(sorted(qa["frames_touching_top"]), [0, 3, 7])

            # SpriteFrames .tres content.
            tres_path = Path(result["tres_path"])
            self.assertTrue(tres_path.exists())
            tres_content = tres_path.read_text(encoding="utf-8")
            self.assertIn('&"walk_down"', tres_content)
            self.assertIn("Rect2(0, 0, 320, 320)", tres_content)
            self.assertIn("Rect2(2240, 0, 320, 320)", tres_content)
            self.assertIn('"speed": 8.0', tres_content)
            self.assertIn('"loop": true', tres_content)
            self.assertIn('load_steps=10 format=3', tres_content)
            self.assertNotIn("Downloads", tres_content)
            self.assertNotIn("/Users/", tres_content)

            # 8 individual frames exported.
            frames_dir = Path(result["frames_dir"])
            frame_files = sorted(frames_dir.glob("frame_*.png"))
            self.assertEqual(len(frame_files), 8)

    def test_bit_for_bit_identical_to_production(self):
        """Verify Forge atlas is 100% bit-for-bit identical to production atlas."""
        src = _get_mochi_walk_down_source()
        prod_atlas = _get_production_walk_down_atlas()
        if prod_atlas is None:
            self.skipTest("Production atlas not found.")

        with tempfile.TemporaryDirectory() as tmp:
            result = run_pipeline(
                source_path=str(src),
                character="mochi",
                action="walk",
                direction="down",
                rows=1,
                cols=8,
                fps=8,
                loop=True,
                runtime_size=320,
                status="PROTOTYPE",
                output_dir_override=tmp,
            )

            with Image.open(result["atlas_path"]) as gen_img:
                with Image.open(prod_atlas) as prod_img:
                    self.assertEqual(gen_img.size, prod_img.size)
                    self.assertEqual(gen_img.mode, prod_img.mode)
                    diff = ImageChops.difference(gen_img, prod_img)
                    self.assertIsNone(
                        diff.getbbox(),
                        "Forge output differs from production atlas!"
                    )

    def test_safe_padding_option(self):
        """Verify safe-padding parameter prevents top-touching warnings."""
        src = _get_mochi_walk_down_source()
        with tempfile.TemporaryDirectory() as tmp:
            result = run_pipeline(
                source_path=str(src),
                character="mochi",
                action="walk",
                direction="down",
                rows=1,
                cols=8,
                fps=8,
                loop=True,
                runtime_size=320,
                safe_padding=16,
                status="PROTOTYPE",
                output_dir_override=tmp,
            )
            qa = result["manifest"]["qa"]
            self.assertEqual(len(qa["frames_touching_top"]), 0)
            self.assertGreater(qa["min_padding_top"], 0)

    def test_source_immutability(self):
        src = _get_mochi_walk_down_source()
        original_hash = hashlib.sha256(src.read_bytes()).hexdigest()

        with tempfile.TemporaryDirectory() as tmp:
            run_pipeline(
                source_path=str(src),
                character="mochi",
                action="walk",
                direction="down",
                rows=1,
                cols=8,
                fps=8,
                runtime_size=320,
                output_dir_override=tmp,
            )

        self.assertEqual(
            hashlib.sha256(src.read_bytes()).hexdigest(),
            original_hash,
            "Source file was modified by Asset Forge pipeline!"
        )

    def test_godot_ignores_asset_forge_directory(self):
        """Verify .gdignore is present in the Asset Forge directory."""
        gdignore = _tool_root / ".gdignore"
        self.assertTrue(
            gdignore.exists(),
            "tools/willicat_asset_forge/.gdignore must exist to protect Godot engine scan."
        )


if __name__ == "__main__":
    unittest.main()
