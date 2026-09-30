# WilliCat World, Location, Room & Decoration Reference Research V1

Status: research and recommendation; no production architecture is changed by this document.
Research snapshot: 2026-09-29. Godot target: 4.7.2.
Scope: world/location/room composition, object placement, persistence, transitions, cozy-life simulation patterns, and reference-system inspection.

## Executive finding

WilliCat should treat a world as a graph of authored locations and rooms, with each active room loaded as a Godot `PackedScene`. The room scene owns spatial truth. Reusable object scenes own their local geometry, collision/footprint, interaction slots, and visual anchors. Room and object definitions are immutable authored data; a future save stores stable IDs and player-created deltas, not scene paths or duplicated baseline layout coordinates.

For illustration, the recommended production method is a carefully approved visual composition decomposed into registered architectural layers plus independent interactive/movable object scenes. The composition remains an art-direction and parity reference; it is never a substitute for Godot placement data. This combines a visually cohesive illustrated room with reliable gameplay ownership and future decoration.

This document distinguishes three kinds of evidence:

- **Official Godot fact:** behavior documented by Godot 4.7 documentation or visible in an official demo.
- **Observed reference:** behavior or content directly inspected in a public reference project. It is not a claim about an unseen commercial game's internals.
- **WilliCat recommendation / inference:** a design conclusion based on the current project contracts and the evidence above.

## 1. Official Godot material studied

| Source | Relevant facts | WilliCat implication |
|---|---|---|
| [PackedScene, Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_packedscene.html) | A `PackedScene` serializes a node hierarchy that can be instantiated. Scene ownership controls which nodes are included when packing a scene. | Use scenes for room compositions and reusable authored objects. Preserve meaningful `owner` relationships when building scenes in the editor or tooling. |
| [Resources, Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html) | Nodes express scene/runtime structure; Resources are data containers, can be custom script classes, and can be saved as `.tres` / `.res`. Loaded resources are cached/shared. | Use typed `.tres` definitions for immutable room/object/profile data; do not store mutable per-instance state in a shared definition Resource. |
| [Saving games, Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/io/saving_games.html) | The tutorial demonstrates collecting state and serializing it; JSON is human-readable but only represents basic types directly. Godot-specific values need explicit conversion. `ConfigFile` is suitable for settings-like data. | Define a versioned save schema and explicit serialization boundary. Use JSON for an inspectable V1 save if convenient, but encode transforms, IDs, enums, and typed values deliberately. Keep settings separate from game-world save data. |
| [ResourceLoader, Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_resourceloader.html) | Threaded loading has request/status/retrieval phases; a resource should be consumed only after it is loaded. | A known portal destination can be prefetched later, but loading strategy should remain behind the world-flow service and be profiled on target devices. |
| [SceneTree, Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_scenetree.html) and [manual scene changes](https://docs.godotengine.org/en/4.7/tutorials/scripting/change_scenes_manually.html) | Godot supports replacing the current scene or managing instantiated scene children explicitly. Manually hosted scenes can coexist with nodes outside the current scene. | Keep persistent session/save orchestration outside the replaceable room root. Start with one active room; add cross-fades or preloading without turning the room into a global singleton. |
| [2D navigation overview, Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/navigation/navigation_introduction_2d.html) | `AStarGrid2D` fits partial discrete grids; `NavigationServer2D` mesh navigation fits actors reaching arbitrary points in an area. `NavigationRegion2D` owns a `NavigationPolygon`; links connect separate positions. `NavigationObstacle2D` affects avoidance, not pathfinding. Navigation synchronization may require waiting a physics frame before querying. | Use room-local mesh navigation and semantic destinations for freely placed characters. Keep portals/room graph separate from within-room paths. Validate obstruction by changing the nav mesh/footprint, not by assuming avoidance obstacles block routes. |
| [Using TileMaps, Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/2d/using_tilemaps.html) | `TileMapLayer` supports quick grid authoring, reusable TileSets, collision, occlusion, and navigation. Godot cautions that built-in TileMap navigation has practical limitations and recommends baking an optimized navigation mesh for many use cases. Navigation meshes must not be stacked as visual layers. | TileMaps are useful for painted terrain or invisible logical cells, but they are not required for WilliCat's illustrated room surfaces and flexible furniture. Do not choose a TileMap solely to represent all object placement. |
| [Changing scenes manually, Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/scripting/change_scenes_manually.html) | A manually added scene renders through the viewport like the active scene; scene lifetime can be managed explicitly. | A `RoomHost` can own exactly one active `RoomRoot` while a persistent application/session root carries state across room swaps. |

### Official demo projects inspected

1. **2D Navigation demo** — [official Godot demo project, 4.2 branch snapshot](https://github.com/godotengine/godot-demo-projects/tree/4.2-31d1c0c/2d/navigation). Its `navigation.tscn`, `character.tscn`, `character.gd`, and `navigation_polygon.res` show a `NavigationRegion2D`/`NavigationPolygon` with a character using `NavigationAgent2D`. Lesson: the region provides walkable space; the actor owns movement execution; scene-level navigation is directly inspectable. The example is intentionally small and is not a multi-room content architecture.

2. **2D Role Playing Game demo** — [official Asset Library entry](https://godotengine.org/asset-library/asset/2729), [source snapshot](https://github.com/godotengine/godot-demo-projects/tree/4.2-31d1c0c/2d/role_playing_game). In `game.gd`, the demo retains and detaches the exploration scene while switching into combat, then reattaches it afterward. Lesson: a parent/controller can own mode transitions while a subscene's state survives a temporary mode change. This is not a ready-made world map, persistent save model, or proof that every room should stay loaded.

3. **Saving and Loading (Serialization) demo** — [official Asset Library entry](https://godotengine.org/asset-library/asset/2781), Godot 4.2-era. It demonstrates serialization examples, including JSON/ConfigFile patterns. Lesson: serialization is an explicit boundary that converts runtime state to storable values; it does not imply that scene trees or NodePaths should be written directly into a save. Treat it as a teaching example, not a production persistence framework.

These are Godot 4.2 demo snapshots, not Godot 4.7 architecture specifications. They were used for concrete scene/code patterns; 4.7 official documentation remains the API authority.

## 2. Reference systems inspected

### Kenney Starter Kit City Builder — placement/save workflow reference

Sources: [Godot Asset Library listing](https://godotengine.org/asset-library/asset/2174), [public source repository](https://github.com/KenneyNL/Starter-Kit-City-Builder).

The public repository was inspected in an isolated temporary checkout, not copied into WilliCat. At the inspected source snapshot, the latest commit was `4535092` dated 2026-03-12 (“Upgrade to Godot 4.6”). The project uses a `Structure` Resource to select a model/price, a separate structure placement record containing grid position/orientation/type index, a `DataMap` resource containing cash and structures, and a preview instance while the user selects/rotates an item. Placement and removal operate on `GridMap`; saving serializes the map's occupied cells to resources and loading reconstructs it.

**Useful pattern:** separate a reusable object definition from an instance placement record; validate a ghost/preview before commit; rotate/confirm/remove; create one serialization boundary that rebuilds the runtime world.

**Limits for WilliCat:** it is a 3D grid-first starter template. Its placement type uses ordering/index identity rather than a WilliCat-grade stable ID contract, and it does not prove freeform illustrated-room placement, local semantic anchors, schema migration, or a large life-sim persistence model. Adopt those concepts only after translating them into WilliCat's 2D typed contracts.

**Metadata caveat:** the Asset Library page and current source README show different Godot-version/update signals (the listing advertises a later update and marks the project unstable; the inspected source commit is dated March 2026 and says Godot 4.6). The recommendation does not depend on resolving that mismatch. The project is a study reference, not a dependency.

### KayKit City Builder Bits — visual-kit reference only

Sources: [Godot Asset Library listing](https://godotengine.org/asset-library/asset/2123), [asset repository](https://github.com/KayKit-Game-Assets/KayKit-City-Builder-Bits-1.0).

The kit is a CC0 collection of low-poly city-building models with a shared gradient atlas/material approach. **Observed lesson:** a limited common palette/material treatment helps visually distinct modular pieces read as one authored kit. The kit does not provide WilliCat room/world behavior, object anchors, placement validation, or save data. It is not a proposed art dependency and its 3D look is not a style target.

### Community Godot Town demo — portal-flow reference only

Source: [odylic/godot-town-demo](https://github.com/odylic/godot-town-demo), whose README identifies Godot 4.3.

The public sample demonstrates a door switching to an interior scene and recording a return scene/spawn position. The inspected implementation passes scene names and positions through global state and contains explicit town-specific branching for parts of its map/minimap flow. It is a small demonstrator, not a robust reusable-location architecture. No clear repository license was found during inspection, so no code should be copied or adapted. **Safe takeaway at concept level:** a portal should declare a destination and a return point. WilliCat should express these as stable room/spawn IDs rather than copied raw coordinates or town-specific actor branches.

### What this research does not claim

Commercial farming, cozy, decorating, and life-sim games are not open-source architecture references. Their internals were not inspected. The following genre patterns are design synthesis, not claims about how a named game is implemented:

- A world map/location graph represents destinations and unlocks; it need not be one continuously loaded scene.
- A room is a bounded authored scene with entrances, interaction points, navigation, camera policy, and local atmosphere binding.
- Furniture definition and placed furniture instance are different data concepts.
- A recurring named cat/NPC has persistent identity and intent; a live `CharacterBody2D` is only one active runtime representation.
- Ordinary customers can be short-lived visit records instead of permanent world entities.
- Unloaded rooms can advance coarse schedules or needs without simulating every actor frame-by-frame.
- Decoration modifies a room's authored baseline; it should not force the baseline level designer to serialize every unchanged object.

## 3. Existing WilliCat contracts reviewed

The following project material was checked: `WILLICAT_AGENT_BOOTSTRAP_V1`; Production World Architecture V1; World Architecture Recommendation V2; Interaction Slot Contract V1; Navigation Footprint Strategy V1; Camera Director Architecture V1; Home V3 Layout Lock V1; Home V3 World Authoring Lab V1; Home V3 Art Handoff Spec Lock V1; Event Variant Architecture V1; World Atmosphere Architecture V1; Character Runtime Production Contract V1_1; and the actual locked Home V3 scene at `scenes/dev/home_v3_level_design_pass_01.tscn` plus relevant development harness code.

### Keep as architecture authority

- Godot scene hierarchy and transforms are spatial truth. Artwork is not a placement map.
- Room roots own room-specific camera, world roots, navigation, portal/spawn registry, and local environment composition.
- Reusable `PackedScene` objects own local visual, collision/footprint, semantic slots, and object-local FX/interaction anchors.
- Stable semantic IDs are used instead of actor code with pixel coordinates or persisted NodePaths.
- Character floor-contact roots participate in depth sorting; state-specific z-index patches are prohibited.
- Atmosphere is composable location/season/time/weather/event data and stays independent of gameplay location branches.
- Event variants enable/disable visuals, semantics, and nav/collision consequences as one coherent authored layer.
- Home V3's Staggered Salon transforms and layout remain locked. This research grants no permission to migrate, reposition, or art-integrate that room.

### Current maturity and prototype debt

- World/object anchor and footprint contracts exist, and isolated portability labs provide architectural evidence.
- Home V3 is an authored development scene with stable object IDs and current layout authority, not yet a fully migrated production room pipeline.
- Existing placement experiments validate candidate transforms/footprints in development. `placement_snapshot` is explicitly described as a future save seed; it is not a game save system.
- A repository search found no game-world save/migration implementation that serializes room furniture and reloads it as persistent world state.
- Therefore persistent room customization, world unlock progression, actor residency across rooms, and production portal travel remain proposals requiring a separate proof and human approval.

## 4. Research conclusions

1. Use Godot's scene/resource split: scene trees for authored spatial/runtime composition; typed Resources for immutable definitions; plain versioned records for mutable saved instances.
2. Keep navigation local to a room, and use portals for room-to-room travel. Do not try to create a single navigation mesh spanning all future cafés.
3. Do not force an isometric TileMap onto high-detail illustrated room art. Use a freeform visual room and semantic anchors; add an invisible soft placement grid only if it improves placement ergonomics.
4. Separate world/location/room identity from the currently active room scene. A location may group multiple rooms; a room is the actual loaded spatial scene.
5. Plan for save/load explicitly. Scene defaults remain in `.tscn`; player changes are sparse placed-instance records; computed runtime state is rebuilt.
6. Choose references by the exact problem they demonstrate. Kenney helps study preview/place/save flow; KayKit helps study kit-wide material coherence; neither dictates WilliCat's scene/data contracts.

## Source list

- [Godot 4.7 documentation](https://docs.godotengine.org/en/4.7/): PackedScene, Resources, Saving games, ResourceLoader, SceneTree, Navigation 2D overview, TileMaps, manual scene changes.
- [Godot official demo projects](https://github.com/godotengine/godot-demo-projects), 4.2 source snapshot for the 2D Navigation and 2D RPG demos.
- [Godot Asset Library: 2D Role Playing Game](https://godotengine.org/asset-library/asset/2729).
- [Godot Asset Library: Saving and Loading (Serialization)](https://godotengine.org/asset-library/asset/2781).
- [Kenney Starter Kit City Builder](https://github.com/KenneyNL/Starter-Kit-City-Builder) and [Asset Library listing](https://godotengine.org/asset-library/asset/2174).
- [KayKit City Builder Bits](https://github.com/KayKit-Game-Assets/KayKit-City-Builder-Bits-1.0) and [Asset Library listing](https://godotengine.org/asset-library/asset/2123).
- [Godot Town demo](https://github.com/odylic/godot-town-demo), studied as an unlicensed-for-reuse community reference only.
