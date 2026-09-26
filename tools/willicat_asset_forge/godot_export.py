"""WilliCat Asset Forge — Godot 4.x SpriteFrames .tres generation.

Matches the format observed in the existing production resource:
    assets/characters/mochi/animations/walk/mochi_walk_side_right_prototype_v1.tres
"""

from __future__ import annotations

from pathlib import Path


def generate_sprite_frames_tres(
    atlas_res_path: str,
    frame_count: int,
    cell_w: int,
    cell_h: int,
    fps: float,
    loop: bool,
    animation_name: str,
) -> str:
    """Generate the text content of a Godot 4.x SpriteFrames .tres resource.

    *atlas_res_path* is the ``res://`` path to the atlas PNG.
    Generates AtlasTexture sub-resources for each frame region.
    Matches the format used by the existing Mochi walk prototype.
    """
    load_steps = 1 + frame_count + 1  # ext_resource + sub_resources + resource

    lines: list[str] = []
    lines.append(
        f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]'
    )
    lines.append("")
    lines.append(
        f'[ext_resource type="Texture2D" path="{atlas_res_path}" id="1_atlas"]'
    )

    # AtlasTexture sub-resources.
    for i in range(frame_count):
        lines.append("")
        lines.append(
            f'[sub_resource type="AtlasTexture" id="AtlasTexture_frame_{i}"]'
        )
        lines.append('atlas = ExtResource("1_atlas")')
        x = i * cell_w
        lines.append(f"region = Rect2({x}, 0, {cell_w}, {cell_h})")

    # Animation resource.
    frame_entries = []
    for i in range(frame_count):
        frame_entries.append(
            f'{{"duration": 1.0, "texture": SubResource("AtlasTexture_frame_{i}")}}'
        )
    frames_str = ", ".join(frame_entries)

    loop_str = "true" if loop else "false"
    lines.append("")
    lines.append("[resource]")
    lines.append(f'animations = [{{')
    lines.append(f'"frames": [{frames_str}],')
    lines.append(f'"loop": {loop_str},')
    lines.append(f'"name": &"{animation_name}",')
    lines.append(f'"speed": {fps:.1f}')
    lines.append("}]")

    return "\n".join(lines) + "\n"


def write_sprite_frames(
    output_path: Path,
    atlas_res_path: str,
    frame_count: int,
    cell_w: int,
    cell_h: int,
    fps: float,
    loop: bool,
    animation_name: str,
    overwrite: bool = False,
) -> Path:
    """Write a SpriteFrames .tres file to disk.

    Raises FileExistsError if *output_path* exists and *overwrite* is False.
    """
    if output_path.exists() and not overwrite:
        raise FileExistsError(
            f"Will not overwrite existing file: {output_path}. "
            "Pass overwrite=True or choose a different path."
        )
    content = generate_sprite_frames_tres(
        atlas_res_path=atlas_res_path,
        frame_count=frame_count,
        cell_w=cell_w,
        cell_h=cell_h,
        fps=fps,
        loop=loop,
        animation_name=animation_name,
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content, encoding="utf-8")
    return output_path


def suggest_godot_paths(
    project_root: Path,
    character: str,
    action: str,
    direction: str,
    status: str = "prototype",
) -> dict[str, str]:
    """Suggest Godot res:// paths for atlas and .tres based on conventions."""
    status_tag = status.lower()
    direction_tag = direction.lower() if direction else ""
    name_parts = [character, action]
    if direction_tag:
        name_parts.append(direction_tag)
    name_parts.append(f"{status_tag}_v1")
    base_name = "_".join(name_parts)

    rel_dir = f"assets/characters/{character}/animations/{action}"
    atlas_path = f"res://{rel_dir}/{base_name}.png"
    tres_path = f"res://{rel_dir}/{base_name}.tres"
    abs_dir = project_root / rel_dir

    return {
        "atlas_res_path": atlas_path,
        "tres_res_path": tres_path,
        "atlas_abs_path": str(abs_dir / f"{base_name}.png"),
        "tres_abs_path": str(abs_dir / f"{base_name}.tres"),
        "base_name": base_name,
        "rel_dir": rel_dir,
    }
