"""WilliCat Asset Forge — Mochi Walk Side acceptance test.

Uses the actual MOCHI_WALK_SIDE_PROTOTYPE_V1 source as a test fixture.
Does NOT modify any production files.
"""

from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

_tool_root = Path(__file__).resolve().parent.parent
if str(_tool_root.parent) not in sys.path:
    sys.path.insert(0, str(_tool_root.parent))

from PIL import Image

from willicat_asset_forge.forge import inspect_source, run_pipeline
from willicat_asset_forge.paths import detect_project_root


def _get_mochi_source() -> Path | None:
    """Locate the Mochi walk side source PNG."""
    try:
        root = detect_project_root()
    except FileNotFoundError:
        return None
    src = root / "docs" / "source_assets" / "mochi" / "walk_side_v1" / \
        "MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk.png"
    return src if src.exists() else None


def _get_known_good_atlas() -> Path | None:
    """Locate the existing known-good runtime atlas."""
    try:
        root = detect_project_root()
    except FileNotFoundError:
        return None
    atlas = root / "assets" / "characters" / "mochi" / "animations" / "walk" / \
        "mochi_walk_side_right_prototype_v1.png"
    return atlas if atlas.exists() else None


@unittest.skipUnless(
    _get_mochi_source() is not None,
    "Mochi walk source not available — skipping acceptance test.",
)
class TestMochiWalkAcceptance(unittest.TestCase):
    """Acceptance test: process the real Mochi walk side sprite sheet."""

    def test_source_inspection(self):
        src = _get_mochi_source()
        info = inspect_source(src)
        self.assertEqual(info.width, 5120)
        self.assertEqual(info.height, 640)
        self.assertEqual(info.mode, "RGBA")
        self.assertTrue(info.has_alpha)
        self.assertFalse(info.is_animated)

    def test_full_pipeline(self):
        src = _get_mochi_source()
        with tempfile.TemporaryDirectory() as tmp:
            result = run_pipeline(
                source_path=str(src),
                character="mochi",
                action="walk",
                direction="side_right",
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
            self.assertEqual(manifest["direction"], "side_right")
            self.assertEqual(manifest["frames"], 8)
            self.assertEqual(manifest["fps"], 8)
            self.assertTrue(manifest["loop"])
            self.assertEqual(manifest["source_frame_size"], [640, 640])
            self.assertEqual(manifest["runtime_frame_size"], [320, 320])

            # QA checks.
            qa = manifest["qa"]
            self.assertIn(qa["overall"], ("PASS", "WARNING"))
            self.assertEqual(qa["baseline_variation"], 0)
            # Top-touching frames (known from production docs).
            self.assertTrue(len(qa["frames_touching_top"]) > 0)

            # SpriteFrames .tres.
            tres_path = Path(result["tres_path"])
            self.assertTrue(tres_path.exists())
            tres_content = tres_path.read_text()
            self.assertIn("walk_side", tres_content)
            self.assertIn("Rect2(0, 0, 320, 320)", tres_content)
            self.assertIn("Rect2(2240, 0, 320, 320)", tres_content)
            self.assertIn('"speed": 8.0', tres_content)
            self.assertIn('"loop": true', tres_content)

            # 8 individual frames exported.
            frames_dir = Path(result["frames_dir"])
            frame_files = sorted(frames_dir.glob("frame_*.png"))
            self.assertEqual(len(frame_files), 8)

    def test_structural_comparison_with_known_good(self):
        """Compare generated atlas structurally against the existing known-good."""
        src = _get_mochi_source()
        known_good = _get_known_good_atlas()
        if known_good is None:
            self.skipTest("Known-good atlas not found.")

        with tempfile.TemporaryDirectory() as tmp:
            result = run_pipeline(
                source_path=str(src),
                character="mochi",
                action="walk",
                direction="side_right",
                rows=1,
                cols=8,
                fps=8,
                loop=True,
                runtime_size=320,
                status="PROTOTYPE",
                output_dir_override=tmp,
            )

            with Image.open(result["atlas_path"]) as generated:
                with Image.open(known_good) as reference:
                    # Same dimensions.
                    self.assertEqual(generated.size, reference.size)
                    self.assertEqual(generated.mode, reference.mode)


@unittest.skipUnless(
    _get_mochi_source() is not None,
    "Mochi walk source not available.",
)
class TestSourceImmutability(unittest.TestCase):
    """Verify the pipeline never modifies the source file."""

    def test_source_file_unchanged(self):
        import hashlib
        src = _get_mochi_source()
        original_hash = hashlib.sha256(src.read_bytes()).hexdigest()

        with tempfile.TemporaryDirectory() as tmp:
            run_pipeline(
                source_path=str(src),
                character="mochi",
                action="walk",
                direction="side_right",
                rows=1,
                cols=8,
                fps=8,
                runtime_size=320,
                output_dir_override=tmp,
            )

        self.assertEqual(
            hashlib.sha256(src.read_bytes()).hexdigest(),
            original_hash,
            "Source file was modified by pipeline!"
        )


if __name__ == "__main__":
    unittest.main()
