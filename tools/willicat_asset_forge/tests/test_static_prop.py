"""Focused regression tests for reusable static-prop packaging."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from PIL import Image

from willicat_asset_forge.static_prop import package_static_prop


class StaticPropTests(unittest.TestCase):
    def test_trim_preserves_source_and_registers_floor_contact(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / "source.png"
            image = Image.new("RGBA", (40, 40), (0, 0, 0, 0))
            for y in range(10, 30):
                for x in range(8, 32):
                    image.putpixel((x, y), (20, 90, 60, 255))
            image.putpixel((1, 1), (255, 0, 0, 8))
            image.save(source)
            original = source.read_bytes()

            result = package_static_prop(
                source, "test_prop_01", root / "out",
                "FLOOR_CONTACT_BOTTOM_CENTER", padding=4,
            )
            self.assertEqual(source.read_bytes(), original)
            self.assertEqual(result["source_visual_bounds"], [8, 10, 32, 30])
            self.assertEqual(result["runtime_dimensions"], [32, 24])
            self.assertEqual(result["pivot_pixel"], [16.0, 24])
            self.assertEqual(result["low_alpha_fringe_pixels_removed"], 1)
            runtime = Image.open(root / "out" / "test_prop_01.png").convert("RGBA")
            self.assertEqual(runtime.getpixel((0, 0))[3], 0)
            self.assertEqual(runtime.getpixel((4, 4))[3], 255)

    def test_rejects_visible_source_edge_contact(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / "edge.png"
            image = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
            image.putpixel((0, 12), (255, 255, 255, 255))
            image.save(source)
            with self.assertRaisesRegex(ValueError, "source edge"):
                package_static_prop(
                    source, "edge_prop_01", root / "out",
                    "FLOOR_CONTACT_BOTTOM_CENTER",
                )

    def test_opaque_architecture_stays_byte_identical(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / "room.png"
            Image.new("RGB", (41, 77), (220, 180, 130)).save(source)
            result = package_static_prop(
                source, "architecture_test_01", root / "out",
                "FULL_CANVAS_TOP_LEFT", opaque=True,
            )
            self.assertEqual(result["runtime_dimensions"], [41, 77])
            self.assertEqual(
                (root / "out" / "architecture_test_01.png").read_bytes(),
                source.read_bytes(),
            )


if __name__ == "__main__":
    unittest.main()
