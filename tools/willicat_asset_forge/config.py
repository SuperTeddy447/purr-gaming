"""WilliCat Asset Forge — global configuration constants."""

from __future__ import annotations

VERSION = "1.2.0"
PRODUCT_NAME = "WilliCat Asset Forge"
SUBSYSTEM_NAME = "WilliCat Asset Agent Pipeline"

# Supported input formats (checked by magic bytes, not just extension).
SUPPORTED_IMAGE_EXTENSIONS = frozenset({".png", ".webp"})

# Asset status workflow — only FINAL requires human visual approval.
STATUS_VALUES = ("PROTOTYPE", "TEMP", "CANDIDATE", "FINAL")
DEFAULT_STATUS = "PROTOTYPE"

# Default animation settings.
DEFAULT_FPS = 8
DEFAULT_LOOP = True
DEFAULT_RUNTIME_CELL = 320

# Resampling — per-cell Lanczos on premultiplied RGBA (matches existing pipeline).
RESAMPLE_METHOD = "LANCZOS"

# Alpha halo detection threshold.
ALPHA_HALO_THRESHOLD = 20  # alpha value considered suspicious at RGB-opaque edges

# Safe padding (transparent canvas expansion, in pixels).
DEFAULT_SAFE_PADDING = 0

# Atlas layout — V1 supports horizontal only.
ATLAS_LAYOUT = "horizontal"
