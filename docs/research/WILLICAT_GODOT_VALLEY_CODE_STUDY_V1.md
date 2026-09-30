# Godot Valley code study V1

## Source and limitation

Inspected only `/Users/teddywoot/Downloads/godew-valley 3` for the local reference. It is an already extracted Godot 4.5 project (`project.godot`), not a pair of START and COMPLETE archives. No START project, archive, README, or LICENSE was found there. Thus **START → COMPLETE differences cannot be verified**; the observations below concern this single project only. It was not merged into WilliCat. Without a local license, its code and artwork are research-only; do not copy them.

## Exact files studied and what they prove

| File | Observed architecture | Transfer / limit |
|---|---|---|
| `scenes/levels/level.tscn`, `level.gd` | `Layers` contains water/grass/soil TileMapLayers. `Objects` instances player, trees, simple props, house and characters. Script uses tile custom data (`farmable`) and terrain connections for farming. | TileMapLayer is useful for repeated terrain, but it is not the whole world: objects are separate scene instances. WilliCat's illustrated café need not adopt visual tiles for its floor. |
| `scenes/levels/house.tscn`, `house.gd` | Floor/wall/roof TileMapLayers plus furniture scenes and some in-place sprite/collision objects; house script fills floor cells and fades roof on area entry. | Architecture and props can be authored independently. Roof fade is a local visibility interaction, not evidence of a room-transition architecture. |
| `scenes/characters/player.tscn`, `player.gd` | CharacterBody2D, AnimationPlayer/Tree, RayCast2D, Camera2D; movement and raycast object interaction are player-owned. | Reusable object interfaces are helpful. The player-attached camera is unlike WilliCat's room camera and should not be copied. |
| `scenes/objects/simple_object.gd/.tscn` and tree instances | One simple object scene displays variants using frames from shared art and carries collision; many scene instances are placed on the level. | Reuse scene definition, vary visuals and transforms; avoid bespoke behavior for each prop. |
| `scenes/objects/plant.gd`, `resources/plant_res.gd`, `resources/tomato_res.tres` | Plant scene uses a typed Resource for texture/growth parameters and tracks grid position. | Typed `.tres` is Godot-native content data. Do not treat mutable shared Resource state as a WilliCat save file; save per-instance state separately. |
| `scenes/machines/machine.gd` and machine scenes | Shared machine behavior is specialized by machine scenes with sprites/animation/timers. | Define common capabilities once, then create object-specific scenes. |
| `global/Data.gd` | Autoload holds plant/machine catalogs and mutable player/item values. | Shows a compact prototype registry, but a giant mutable global catalog is not WilliCat's long-term ownership model. |

`project.godot` identifies `scenes/levels/level.tscn` as main scene and a 1920×1080 project viewport. No save/load implementation was established in the inspected `scenes/` and `global/` scripts. No claim is made that the project lacks persistence elsewhere, only that this inspection did not prove it.

## Answer to the world-building question

This project composes a world from terrain layers, repeatable PackedScene instances, scene-owned collisions, actor scenes, and typed content resources. A designer places instances in the scene; the runtime code operates on those scene objects and tile data. It is not a full-scene painting used as collision or interaction truth. For WilliCat, preserve authored room geometry and object transforms, then replace primitive object visuals while retaining object-owned slots/footprints. The existing [playable placeholder proof](../production/WILLICAT_PLAYABLE_PLACEHOLDER_RESET_V1_RESULT.md) already demonstrates this foundation in two rooms.

## What this study does not establish

There is no verified START → COMPLETE evolution, license grant, mobile performance result, production save architecture, or evidence that Godot Valley's specific assets fit WilliCat's visual direction. Those cannot be inferred from a single local project snapshot.
