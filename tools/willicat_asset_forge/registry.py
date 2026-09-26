"""WilliCat Asset Forge — character and action profile registry."""

from __future__ import annotations

import json
from pathlib import Path

from .models import ActionProfile, CharacterProfile
from .paths import profiles_dir


def load_character(character_id: str) -> CharacterProfile:
    """Load a character profile JSON by id."""
    path = profiles_dir() / "characters" / f"{character_id}.json"
    if not path.exists():
        raise FileNotFoundError(f"Character profile not found: {path}")
    return CharacterProfile.from_json(path)


def load_action(action_id: str) -> ActionProfile:
    """Load an action profile JSON by id."""
    path = profiles_dir() / "actions" / f"{action_id}.json"
    if not path.exists():
        raise FileNotFoundError(f"Action profile not found: {path}")
    return ActionProfile.from_json(path)


def list_characters() -> list[str]:
    """Return ids of all available character profiles."""
    d = profiles_dir() / "characters"
    if not d.exists():
        return []
    return sorted(p.stem for p in d.glob("*.json"))


def list_actions() -> list[str]:
    """Return ids of all available action profiles."""
    d = profiles_dir() / "actions"
    if not d.exists():
        return []
    return sorted(p.stem for p in d.glob("*.json"))
