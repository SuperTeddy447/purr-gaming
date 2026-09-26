"""WilliCat Asset Forge — data models (plain dataclasses, JSON-serialisable)."""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any


# ---------------------------------------------------------------------------
# Character / Action profiles
# ---------------------------------------------------------------------------

@dataclass
class CharacterProfile:
    id: str
    display_name: str
    canonical_reference: str = ""
    target_gameplay_height: int = 150
    default_runtime_frame_size: tuple[int, int] = (320, 320)
    default_fps: int = 8
    horizontal_mirror_policy: str = "disabled"
    identity_notes: list[str] = field(default_factory=list)
    runtime_animation_root: str = ""

    @classmethod
    def from_json(cls, path: Path) -> CharacterProfile:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        # tuple conversion
        if "default_runtime_frame_size" in data and isinstance(
            data["default_runtime_frame_size"], list
        ):
            data["default_runtime_frame_size"] = tuple(
                data["default_runtime_frame_size"]
            )
        return cls(**data)

    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        d["default_runtime_frame_size"] = list(d["default_runtime_frame_size"])
        return d


@dataclass
class ActionProfile:
    id: str
    display_name: str
    default_fps: int = 8
    loop: bool = True
    requires_direction: bool = False
    recommended_frames: int = 8
    runtime_folder: str = ""
    semantic_action: str = ""

    @classmethod
    def from_json(cls, path: Path) -> ActionProfile:
        with open(path, "r", encoding="utf-8") as f:
            return cls(**json.load(f))

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


# ---------------------------------------------------------------------------
# Frame-level QA
# ---------------------------------------------------------------------------

@dataclass
class FrameQA:
    index: int
    width: int
    height: int
    alpha_bbox: tuple[int, int, int, int] | None = None  # (x0, y0, x1, y1)
    padding_left: int = 0
    padding_right: int = 0
    padding_top: int = 0
    padding_bottom: int = 0
    center_x: float = 0.0
    center_y: float = 0.0
    baseline_y: int = 0  # lowest visible pixel (y coordinate)
    visible_width: int = 0
    visible_height: int = 0
    warnings: list[str] = field(default_factory=list)


@dataclass
class AnimationQA:
    frame_count: int = 0
    center_x_range: float = 0.0
    center_y_range: float = 0.0
    baseline_variation: int = 0
    visible_size_variation_w: int = 0
    visible_size_variation_h: int = 0
    min_padding_top: int = 0
    min_padding_bottom: int = 0
    min_padding_left: int = 0
    min_padding_right: int = 0
    frames_touching_top: list[int] = field(default_factory=list)
    frames_touching_left: list[int] = field(default_factory=list)
    frames_touching_right: list[int] = field(default_factory=list)
    alpha_halo_check: str = "PASS"
    overall: str = "PASS"
    warnings: list[str] = field(default_factory=list)
    frames: list[FrameQA] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Source inspection result
# ---------------------------------------------------------------------------

@dataclass
class SourceInspection:
    path: str = ""
    file_type: str = ""  # "png" | "webp"
    width: int = 0
    height: int = 0
    mode: str = ""  # "RGBA", "RGB", etc.
    has_alpha: bool = False
    is_animated: bool = False
    frame_count: int = 1
    frame_durations_ms: list[int] = field(default_factory=list)
    loop_count: int = 0  # 0 = infinite
    potential_grid: dict[str, int] | None = None  # rows, cols, cell_w, cell_h


# ---------------------------------------------------------------------------
# Asset manifest
# ---------------------------------------------------------------------------

@dataclass
class AssetManifest:
    character: str = ""
    action: str = ""
    direction: str = ""
    status: str = "PROTOTYPE"
    frames: int = 0
    fps: int = 8
    loop: bool = True
    source: str = ""
    source_frame_size: tuple[int, int] = (0, 0)
    runtime_frame_size: tuple[int, int] = (0, 0)
    atlas: str = ""
    safe_padding: int = 0
    qa: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        d["source_frame_size"] = list(d["source_frame_size"])
        d["runtime_frame_size"] = list(d["runtime_frame_size"])
        return d

    def save(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)
            f.write("\n")

    @classmethod
    def load(cls, path: Path) -> AssetManifest:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        for key in ("source_frame_size", "runtime_frame_size"):
            if key in data and isinstance(data[key], list):
                data[key] = tuple(data[key])
        return cls(**data)
