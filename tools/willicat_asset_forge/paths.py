"""WilliCat Asset Forge — project root detection and canonical paths."""

from __future__ import annotations

import os
from pathlib import Path


def detect_project_root(override: str | None = None) -> Path:
    """Return the WilliCat project root.

    Resolution order:
    1. Explicit *override* argument.
    2. WILLICAT_PROJECT_ROOT environment variable.
    3. Walk upward from this file until we find ``project.godot``.

    Raises ``FileNotFoundError`` if no root can be determined.
    """
    if override:
        root = Path(override).resolve()
        if (root / "project.godot").exists():
            return root
        raise FileNotFoundError(
            f"Override path does not contain project.godot: {root}"
        )

    env = os.environ.get("WILLICAT_PROJECT_ROOT")
    if env:
        root = Path(env).resolve()
        if (root / "project.godot").exists():
            return root

    current = Path(__file__).resolve().parent
    for _ in range(10):
        if (current / "project.godot").exists():
            return current
        parent = current.parent
        if parent == current:
            break
        current = parent

    raise FileNotFoundError(
        "Cannot detect WilliCat project root (no project.godot found). "
        "Set WILLICAT_PROJECT_ROOT or pass --project-root."
    )


# Canonical project-relative directories.

def tool_root() -> Path:
    """Return the Asset Forge tool root directory."""
    return Path(__file__).resolve().parent


def profiles_dir() -> Path:
    return tool_root() / "profiles"


def inbox_dir() -> Path:
    d = tool_root() / "inbox"
    d.mkdir(parents=True, exist_ok=True)
    return d


def workspace_dir() -> Path:
    d = tool_root() / "workspace"
    d.mkdir(parents=True, exist_ok=True)
    return d


def output_dir() -> Path:
    d = tool_root() / "output"
    d.mkdir(parents=True, exist_ok=True)
    return d


# Game-asset relative paths.

def characters_animation_root(project_root: Path) -> Path:
    return project_root / "assets" / "characters"


def source_assets_root(project_root: Path) -> Path:
    return project_root / "docs" / "source_assets"


def character_animation_dir(
    project_root: Path,
    character: str,
    action: str,
) -> Path:
    return characters_animation_root(project_root) / character / "animations" / action
