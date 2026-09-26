"""WilliCat Asset Forge — unit tests for core processing."""

from __future__ import annotations

import hashlib
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

# Ensure package is importable.
_tool_root = Path(__file__).resolve().parent.parent
if str(_tool_root.parent) not in sys.path:
    sys.path.insert(0, str(_tool_root.parent))

from PIL import Image

from willicat_asset_forge.config import DEFAULT_FPS
from willicat_asset_forge.forge import inspect_source, run_pipeline
from willicat_asset_forge.godot_export import generate_sprite_frames_tres
from willicat_asset_forge.image_processing import (
    add_safe_padding,
    alpha_bounds,
    detect_alpha_halo,
    ensure_rgba,
    resize_frame,
)
from willicat_asset_forge.models import AssetManifest, CharacterProfile, ActionProfile
from willicat_asset_forge.qa import analyse_animation, analyse_frame
from willicat_asset_forge.sprite_sheet import detect_grid, extract_frames
from willicat_asset_forge.paths import detect_project_root


def _make_test_frame(w: int = 64, h: int = 64, color: tuple = (255, 128, 0, 255)) -> Image.Image:
    """Create a test RGBA frame with a centered colored rectangle."""
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    # Draw a rectangle leaving a border.
    margin = max(4, w // 8)
    for y in range(margin, h - margin):
        for x in range(margin, w - margin):
            img.putpixel((x, y), color)
    return img


def _make_test_sheet(
    frame_count: int = 8,
    cell_w: int = 64,
    cell_h: int = 64,
) -> Image.Image:
    """Create a horizontal sprite sheet of test frames."""
    sheet = Image.new("RGBA", (cell_w * frame_count, cell_h), (0, 0, 0, 0))
    for i in range(frame_count):
        frame = _make_test_frame(cell_w, cell_h, color=(255, 128 + i * 10, 0, 255))
        sheet.paste(frame, (i * cell_w, 0))
    return sheet


class TestImageProcessing(unittest.TestCase):
    def test_ensure_rgba_from_rgb(self):
        img = Image.new("RGB", (10, 10), (255, 0, 0))
        result = ensure_rgba(img)
        self.assertEqual(result.mode, "RGBA")

    def test_ensure_rgba_passthrough(self):
        img = Image.new("RGBA", (10, 10), (255, 0, 0, 128))
        result = ensure_rgba(img)
        self.assertIs(result, img)

    def test_alpha_bounds_opaque(self):
        img = _make_test_frame(64, 64)
        bbox = alpha_bounds(img)
        self.assertIsNotNone(bbox)
        x0, y0, x1, y1 = bbox
        self.assertGreater(x0, 0)
        self.assertGreater(y0, 0)
        self.assertLess(x1, 64)
        self.assertLess(y1, 64)

    def test_alpha_bounds_transparent(self):
        img = Image.new("RGBA", (10, 10), (0, 0, 0, 0))
        self.assertIsNone(alpha_bounds(img))

    def test_resize_frame_preserves_rgba(self):
        frame = _make_test_frame(64, 64)
        resized = resize_frame(frame, (32, 32))
        self.assertEqual(resized.size, (32, 32))
        self.assertEqual(resized.mode, "RGBA")

    def test_resize_frame_identity(self):
        frame = _make_test_frame(64, 64)
        result = resize_frame(frame, (64, 64))
        self.assertEqual(result.size, (64, 64))

    def test_add_safe_padding(self):
        frame = _make_test_frame(64, 64)
        padded = add_safe_padding(frame, 16)
        self.assertEqual(padded.size, (96, 96))
        self.assertEqual(padded.mode, "RGBA")
        # Original content should be at (16, 16).
        original_bbox = alpha_bounds(frame)
        padded_bbox = alpha_bounds(padded)
        self.assertEqual(padded_bbox[0], original_bbox[0] + 16)
        self.assertEqual(padded_bbox[1], original_bbox[1] + 16)

    def test_add_safe_padding_zero(self):
        frame = _make_test_frame(64, 64)
        result = add_safe_padding(frame, 0)
        self.assertEqual(result.size, (64, 64))


class TestSpriteSheet(unittest.TestCase):
    def test_detect_horizontal_strip(self):
        grid = detect_grid(512, 64)
        self.assertEqual(grid["rows"], 1)
        self.assertEqual(grid["cols"], 8)
        self.assertEqual(grid["cell_w"], 64)
        self.assertEqual(grid["cell_h"], 64)

    def test_detect_vertical_strip(self):
        grid = detect_grid(64, 512)
        self.assertEqual(grid["rows"], 8)
        self.assertEqual(grid["cols"], 1)

    def test_detect_with_explicit(self):
        grid = detect_grid(5120, 640, rows=1, cols=8)
        self.assertEqual(grid["cell_w"], 640)
        self.assertEqual(grid["cell_h"], 640)
        self.assertEqual(grid["frame_count"], 8)

    def test_detect_grid_error(self):
        with self.assertRaises(ValueError):
            detect_grid(5120, 640, rows=3, cols=3)

    def test_extract_frames_count(self):
        sheet = _make_test_sheet(8, 64, 64)
        frames = extract_frames(sheet, 1, 8, 64, 64, 8)
        self.assertEqual(len(frames), 8)

    def test_extract_frames_rgba_preservation(self):
        sheet = _make_test_sheet(4, 32, 32)
        frames = extract_frames(sheet, 1, 4, 32, 32)
        for f in frames:
            self.assertEqual(f.mode, "RGBA")
            self.assertEqual(f.size, (32, 32))


class TestQA(unittest.TestCase):
    def test_analyse_frame_basic(self):
        frame = _make_test_frame(64, 64)
        qa = analyse_frame(frame, 0)
        self.assertEqual(qa.width, 64)
        self.assertIsNotNone(qa.alpha_bbox)
        self.assertGreater(qa.padding_top, 0)

    def test_analyse_frame_transparent(self):
        frame = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        qa = analyse_frame(frame, 0)
        self.assertIsNone(qa.alpha_bbox)
        self.assertIn("Fully transparent", qa.warnings[0])

    def test_analyse_animation_pass(self):
        frames = [_make_test_frame(64, 64) for _ in range(4)]
        qa = analyse_animation(frames)
        self.assertEqual(qa.frame_count, 4)
        # All identical frames should have 0 variation.
        self.assertEqual(qa.baseline_variation, 0)
        self.assertEqual(qa.center_x_range, 0.0)

    def test_baseline_detection(self):
        frame = _make_test_frame(64, 64)
        qa = analyse_frame(frame, 0)
        bbox = alpha_bounds(frame)
        self.assertEqual(qa.baseline_y, bbox[3] - 1)

    def test_padding_calculation(self):
        frame = _make_test_frame(64, 64)
        qa = analyse_frame(frame, 0)
        bbox = alpha_bounds(frame)
        self.assertEqual(qa.padding_left, bbox[0])
        self.assertEqual(qa.padding_top, bbox[1])
        self.assertEqual(qa.padding_right, 64 - bbox[2])
        self.assertEqual(qa.padding_bottom, 64 - bbox[3])


class TestGodotExport(unittest.TestCase):
    def test_generate_tres_structure(self):
        tres = generate_sprite_frames_tres(
            atlas_res_path="res://test.png",
            frame_count=4,
            cell_w=320,
            cell_h=320,
            fps=8.0,
            loop=True,
            animation_name="walk_side",
        )
        self.assertIn('[gd_resource type="SpriteFrames"', tres)
        self.assertIn('AtlasTexture_frame_0', tres)
        self.assertIn('AtlasTexture_frame_3', tres)
        self.assertIn('"loop": true', tres)
        self.assertIn('"speed": 8.0', tres)
        self.assertIn('"name": &"walk_side"', tres)

    def test_generate_tres_no_loop(self):
        tres = generate_sprite_frames_tres(
            atlas_res_path="res://test.png",
            frame_count=2,
            cell_w=64,
            cell_h=64,
            fps=4.0,
            loop=False,
            animation_name="serve",
        )
        self.assertIn('"loop": false', tres)

    def test_tres_regions(self):
        tres = generate_sprite_frames_tres(
            atlas_res_path="res://test.png",
            frame_count=3,
            cell_w=100,
            cell_h=100,
            fps=8.0,
            loop=True,
            animation_name="test",
        )
        self.assertIn("Rect2(0, 0, 100, 100)", tres)
        self.assertIn("Rect2(100, 0, 100, 100)", tres)
        self.assertIn("Rect2(200, 0, 100, 100)", tres)


class TestModels(unittest.TestCase):
    def test_manifest_serialization(self):
        m = AssetManifest(
            character="mochi",
            action="walk",
            direction="side_right",
            frames=8,
            fps=8,
            source_frame_size=(640, 640),
            runtime_frame_size=(320, 320),
        )
        d = m.to_dict()
        self.assertEqual(d["source_frame_size"], [640, 640])
        self.assertEqual(d["runtime_frame_size"], [320, 320])

        # Round-trip via JSON.
        json_str = json.dumps(d)
        loaded = json.loads(json_str)
        self.assertEqual(loaded["character"], "mochi")

    def test_manifest_save_load(self):
        with tempfile.TemporaryDirectory() as tmp:
            m = AssetManifest(character="test", action="run", frames=4)
            path = Path(tmp) / "manifest.json"
            m.save(path)
            loaded = AssetManifest.load(path)
            self.assertEqual(loaded.character, "test")
            self.assertEqual(loaded.frames, 4)

    def test_character_profile_from_json(self):
        profile_path = (
            Path(__file__).resolve().parent.parent
            / "profiles"
            / "characters"
            / "mochi.json"
        )
        if profile_path.exists():
            p = CharacterProfile.from_json(profile_path)
            self.assertEqual(p.id, "mochi")
            self.assertEqual(p.default_fps, 8)
            self.assertIn("orange tabby", p.identity_notes)


class TestAtlasRebuilding(unittest.TestCase):
    def test_atlas_dimensions(self):
        """Atlas of 8 frames at 32x32 should be 256x32."""
        frames = [_make_test_frame(32, 32) for _ in range(8)]
        atlas = Image.new("RGBA", (32 * 8, 32), (0, 0, 0, 0))
        for i, f in enumerate(frames):
            atlas.paste(f, (i * 32, 0))
        self.assertEqual(atlas.size, (256, 32))

    def test_runtime_resize_atlas(self):
        """Resize each frame independently, then build atlas."""
        frames = [_make_test_frame(64, 64) for _ in range(4)]
        resized = [resize_frame(f, (32, 32)) for f in frames]
        atlas = Image.new("RGBA", (32 * 4, 32), (0, 0, 0, 0))
        for i, f in enumerate(resized):
            atlas.paste(f, (i * 32, 0))
        self.assertEqual(atlas.size, (128, 32))


class TestOverwriteProtection(unittest.TestCase):
    def test_source_unchanged(self):
        """Source file must not be modified by pipeline."""
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            # Create a test sprite sheet.
            sheet = _make_test_sheet(4, 64, 64)
            src = tmp_path / "source.png"
            sheet.save(str(src))
            src_hash = hashlib.sha256(src.read_bytes()).hexdigest()

            # Run pipeline.
            out_dir = tmp_path / "output"
            run_pipeline(
                source_path=str(src),
                character="test",
                action="walk",
                direction="side_right",
                cols=4,
                rows=1,
                fps=8,
                runtime_size=32,
                output_dir_override=str(out_dir),
            )

            # Source must be unchanged.
            self.assertEqual(
                hashlib.sha256(src.read_bytes()).hexdigest(),
                src_hash,
                "Source file was modified!",
            )


class TestInspection(unittest.TestCase):
    def test_inspect_png(self):
        with tempfile.TemporaryDirectory() as tmp:
            img = _make_test_sheet(4, 64, 64)
            path = Path(tmp) / "test.png"
            img.save(str(path))
            info = inspect_source(path)
            self.assertEqual(info.file_type, "png")
            self.assertEqual(info.width, 256)
            self.assertEqual(info.height, 64)
            self.assertTrue(info.has_alpha)


class TestPipeline(unittest.TestCase):
    def test_full_pipeline_synthetic(self):
        """Full pipeline on synthetic test sheet."""
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            sheet = _make_test_sheet(8, 64, 64)
            src = tmp_path / "test_sheet.png"
            sheet.save(str(src))

            out_dir = tmp_path / "output"
            result = run_pipeline(
                source_path=str(src),
                character="test",
                action="walk",
                direction="side_right",
                rows=1,
                cols=8,
                fps=8,
                loop=True,
                runtime_size=32,
                output_dir_override=str(out_dir),
            )

            self.assertEqual(result["grid"]["cols"], 8)
            self.assertTrue(Path(result["atlas_path"]).exists())
            self.assertTrue(Path(result["tres_path"]).exists())

            # Check atlas dimensions.
            with Image.open(result["atlas_path"]) as atlas:
                self.assertEqual(atlas.size, (256, 32))
                self.assertEqual(atlas.mode, "RGBA")


if __name__ == "__main__":
    unittest.main()
