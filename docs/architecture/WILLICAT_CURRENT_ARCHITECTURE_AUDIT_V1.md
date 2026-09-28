# WilliCat current architecture audit V1

Audited 2026-09-28 against the playable repository and the live Godot 4.7.2 editor. This is a classification, not a migration. None of the production scenes or gameplay controllers was changed for the bootcamp.

## Keep

| System | Evidence | Why keep |
| --- | --- | --- |
| Core coffee loop | `scripts/slice/vertical_slice_controller.gd`, `scenes/home/home_scene.tscn` | Manual/automatic customer, order, worker, service, reward, and reset behavior already work. This is the product-behavior baseline. |
| Camera ownership | `scripts/camera/camera_controller.gd`, `data/room_main_cafe_camera.tres` | Room framing, pan/zoom, and mobile aspect tests have an established owner. Do not move camera rules into furniture. |
| Depth concept | `DepthSortedLayer` and `ForegroundOccluderLayer` in `scenes/home/home_scene.tscn` | Foot-based Y-sort and a distinct foreground pass are correct building blocks, even though current objects need better ownership. |
| Character presentation | `scripts/characters/mochi_visual_presenter.gd`, Mochi animation resources, `CarryAnchor` | Visual clips and carry attachment can remain separate from gameplay state. |
| Stable visual slots | `scripts/home/home_asset_slot.gd`, `data/home_visual_asset_catalog.tres` | The 17 stable IDs are useful content identity; retain them through any future scene migration. |
| Dynamic signage and Asset Forge | `scripts/home/dynamic_sign.gd`, `tools/willicat_asset_forge/` | Reusable visual presentation and source/provenance workflows do not need replacement by world architecture. |

## Migrate only after architecture approval

| System | Current form | Target direction |
| --- | --- | --- |
| Global gameplay markers | `GameplayNodes` in `scenes/home/home_scene.tscn` owns `OrderPoint`, `ServePoint`, `WorkerIdle`, `CoffeeAction`, `SeatA`–`SeatD`, `CustomerSpawn`, `CustomerExit` | Object-specific anchors should move under the appropriate counter/chair/entrance instance; room-wide waypoints stay with the room. Preserve stable semantic IDs and provide an adapter to the existing loop. |
| Counter assembly | `CounterSystem` has back/front visual pieces and prop anchors, while station action points live separately | A reusable counter/station scene should own its local visuals, occluder, footprint, and action anchors. Independently movable equipment should remain its own subscene. |
| Seat and route data | `scripts/home/home_spatial_routes.gd` uses authored seat-specific waypoint sequences and global positions | Keep authored route intent, but resolve endpoints from seat/door/station instances. Decide whether local navmesh or a waypoint graph supplies the intermediate path. |
| Living Café destinations | `scripts/home/living_cafe_ambient_controller.gd` builds a local zone dictionary from scene markers | Keep the ambient behavior concept; let room/prop semantic destinations supply current positions. |
| Visual Universe V2 placement | `scenes/dev/home_v2_environment_preview.tscn` inherits Home and overrides global marker positions; `scripts/home/home_v2_visual_installer.gd` applies candidate visuals to slots | Preserve the visual references and candidate art, but do not let art registration become the authority for interaction positions. |

## Prototype debt

- `GameplayNodes` and `SliceWaypoints` are global siblings of the modular objects they describe. Moving one object in the editor does not move all of its behavior points.
- `scripts/home/home_v2_cat_life.gd` has an `ANCHORS` table of literal `Vector2` world positions and creates life markers independently of the matching props. This demonstrates the portability problem; it is not a reason to delete the living-café experiment now.
- Multiple V2 composition/registration tools can visually patch a scene without guaranteeing collision, anchors, and nav clearance remain in register.
- A seat marker is not intrinsically owned by its chair, and CoffeeAction is not intrinsically owned by its station. These are the concrete causes of coordinate drift.
- Current live navigation is valuable proof of movement and timing, but authored route positions are map-specific. The two labs demonstrate an alternate semantic destination contract without rewriting the existing controller.

## Remove later, not now

Only after a replacement is reviewed and regressions pass: obsolete duplicate global anchor nodes, redundant V2 position overrides, and temporary registration/debug aids that no longer serve a production workflow. Keep the original Home and its tests as a rollback comparison until the new authored room is demonstrably equivalent. Do not delete code merely because a lab makes a cleaner example.

## Boundary

The bootcamp added only isolated `scenes/dev/world_lab/` objects, two dev lab scenes, dev scripts, tests, docs, and screenshots. It did not migrate Home, change its camera, gameplay, asset IDs, or art.
