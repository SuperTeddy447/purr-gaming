# WilliCat World, Location & Room Architecture V1

Status: proposed architecture for review; existing Home V3 and production scenes are unchanged.
Prerequisite authority: Production World Architecture V1, Home V3 Layout Lock V1, Interaction Slot Contract V1, Navigation Footprint Strategy V1, Camera Director Architecture V1, World Atmosphere Architecture V1, and Character Runtime Production Contract V1_1.

## Recommendation

Use a **location graph + room-scene composition**. A `WorldDefinition` catalogs named locations and connections. Each location references one or more `RoomDefinition` resources. Each `RoomDefinition` identifies one authored `RoomRoot` `PackedScene`, entry/return spawn IDs, camera policy, atmosphere defaults, and portal definitions. The active `RoomRoot` is the spatial authority for all local objects and navigation.

This is not a migration plan or authorization to change Home V3. It is the target architecture to prove in a separate dev lab before production adoption.

## Responsibility tree

```text
GameRoot (persistent application/session root)
├── WorldFlowController
├── SaveCoordinator / WorldSession (persistent data only)
└── RoomHost (one active room initially)
    └── RoomRoot: PackedScene instance
        ├── Architecture (fixed room shell, windows, built-in surfaces)
        ├── LogicalFloor / PlacementZones (semantic walkable/placement data)
        ├── Navigation (room-local NavigationRegion2D and optional links)
        ├── WorldObjects (authored baseline + restored placed-object deltas)
        ├── Characters (actors currently visible in this room)
        ├── Foreground (Y-sort and foreground occluders)
        ├── FX (room-local effects and attachment points)
        ├── RuntimeSignage (semantic/runtime text or visuals)
        ├── Portals (room exit triggers with stable destination IDs)
        └── CameraRig / CameraDirector (room-specific composition)
```

HUD may be hosted by the persistent application or in a room-configured `CanvasLayer`; world-tinted and screen-space UI must be explicitly separated according to the atmosphere contract. This tree is conceptual and must be reconciled with any approved production bootstrap before implementation.

## Data model

Use stable string IDs at authored boundaries. Use custom Godot Resources (`.tres`) for designer-facing immutable definitions, `PackedScene` for spatial templates, and compact serializable records for mutable player state.

### `WorldDefinition`

- `world_id`
- `location_ids` / referenced `LocationDefinition`s
- high-level connections, unlock requirements, and world-map presentation metadata
- No actor-specific region behavior and no per-room world coordinates.

### `LocationDefinition`

- `location_id`
- display/localization IDs and world-map grouping/position data
- referenced room IDs and location-level atmosphere/exterior defaults
- unlock/story metadata
- This is a destination grouping, not necessarily a loaded scene. A city block may contain a café interior and an outdoor street as separate rooms.

### `RoomDefinition`

- `room_id`, `location_id`
- `room_scene: PackedScene` (or a loadable resource identifier resolved centrally)
- default atmosphere profile IDs / exterior-window family
- room camera profile reference
- stable entry spawn IDs and portal destination records
- optional room tags, audio profile, and simulation policy
- It does not store duplicated global transforms for every object already authored in the room scene.

### `WorldObjectDefinition`

- stable `definition_id`, type/category, display/icon IDs
- reusable `PackedScene`
- footprint/placement policy reference, allowed room/zone tags, allowed orientations
- variant IDs, inventory/shop metadata if later relevant
- semantics/capabilities for UI filtering, not a duplicate of live interaction logic
- object scene remains the authority for its actual local anchor nodes and collision hierarchy.

### `PlacedObjectInstanceRecord`

- `instance_id` (stable and unique in the save)
- `room_id`, `definition_id`
- room-local `Transform2D` serialized as numeric position/rotation/scale fields
- `variant_id` and small object-specific persistent state/version where necessary
- No `NodePath`, texture path, sprite frame, raw global position, navigation path, or live node reference.

### `PortalDefinition`

- stable `portal_id` scoped to a room
- destination `room_id` + destination `spawn_id`
- optional return policy, fade/transition profile, and unlock conditions
- Each room owns the visible portal/door location; flow code resolves the semantic IDs.

## Room lifecycle and transitions

1. A door/portal emits a semantic travel request (`portal_id`, source room ID), not a scene path or pixel coordinate.
2. `WorldFlowController` resolves the destination through `WorldDefinition`/`LocationDefinition`/`RoomDefinition` and checks unlock/transition policy.
3. `SaveCoordinator` or `WorldSession` commits the source room's mutable deltas and releases transient reservations. It does not save actor node trees.
4. Transition presentation runs (fade, door animation, optional loading state). Known destination assets may be prefetched later with threaded resource loading, but only consumed after the load reports completion.
5. `RoomHost` unloads/replaces its active `RoomRoot`, instantiates the destination scene, applies that room's saved deltas, waits for navigation setup as required, and places the visitor at `spawn_id`.
6. The destination room owns the new camera director, nav map, active room atmosphere binding, and local actors.
7. Return travel resolves the matching portal/entry semantic, not an old actor pixel.

Start with **one active `RoomRoot` at a time**. Keep session/save orchestration outside the root so swapping the root does not erase player state. Do not keep every future location active by default; add additive loading only for a demonstrated seamless-transition requirement.

## Spatial ownership and navigation

- The room scene owns the layout and local scene transforms. The object instance transform is the single placement transform for its visual, collision, footprint and child markers.
- `WorldObject` local anchors include semantic action, approach/exit, interaction, FX, and visual attachment points appropriate to that object. Actors request a semantic destination from the world/object registry; they do not contain map-specific pixel constants.
- Fixed architecture (walls, floor shell, fitted windows, permanent service shell) belongs to room architecture layers. Interactive station components that may move/reuse are object scenes, even if their initial room instance is fixed.
- `NavigationRegion2D`/`NavigationPolygon` describes the room's walkable floor. Use links only for genuine discontinuities/doorway connections inside a room. Room portals are a higher-level transition and do not connect nav meshes between unloaded rooms.
- Object footprints must keep the nav mesh and approach clearance coherent. On a committed placement/removal, validate/rebuild the room's affected navigation representation once. Do not rebake continuously while dragging a preview.
- An avoidance obstacle is not a substitute for changing pathfinding walkability. Reserve non-overlapping room nav space and validate agent reachability to required slots.
- Use Y-sort around stable floor-contact roots and existing foreground/occluder contracts. No per-state z-index patches or sprite-alpha-derived collision.

## Characters and simulation ownership

### Cats

Each cat is a persistent logical entity with a stable `cat_id`, definition, chosen/current room, relationship/needs/intent state, and optional target object/slot IDs. A `CharacterBody2D` is a **room runtime actor** spawned when the cat is visible or actively simulated in the active room. When a room deactivates, serialize logical state and remove the node; reinstantiate from the semantic state in a later active room. This keeps animation, physics, nav agents, and visual nodes out of save data.

Inactive-room simulation should be coarse and data-driven (elapsed-time needs, scheduled intent, completed assignment result), not frame-by-frame actor simulation. A story event may opt a named cat into a different persistence policy.

### Customers / visitors

- Ordinary café guests can be short-lived `VisitSession`s with a template/customer definition and visit state; they need not become permanent world residents.
- Named recurring NPCs may have persistent identity, relationship/story flags, and schedule data, while their visible actor is still spawned only in the active room.
- Resolve active order/service transactions on checkpoint/travel using explicit rules (finish, defer, or safely cancel/refund). Do not serialize a live waiter/cup/order node graph.
- Customer route destinations are room semantic IDs and available seat reservations. Never depend on a particular room's pixel layout.

## Atmosphere and environmental identity

Location, season, time of day, weather, and event are independent data inputs as defined by `WILLICAT_WORLD_ATMOSPHERE_ARCHITECTURE_V1`. A `RoomDefinition` binds local window/exterior fixtures and optional local lighting endpoints; the `WorldAtmosphereDirector` evaluates profiles and addresses those fixture interfaces. Characters and gameplay objects must not branch on country IDs.

Exterior foliage/window variants may be location/season/weather art resources. They do not replace the interior room scene. Event content activates its visual, semantic, collision/nav, and atmosphere effects together under the Event Variant contract.

## Room families and reuse

Reuse object PackedScenes and their contracts across locations; do not make every room a copy of one generic scene. Different rooms may intentionally have different architecture, nav polygons, spawn/portal layout, camera profile, and available placement zones. Shared behavior resolves capabilities and semantic slots. Art/layout authoring remains room-specific where required for a distinctive illustrated composition.

## Validation gates before any production migration

- Two strongly different room scenes instantiate the same Chair, Bed, Plant, CounterStation and generic actor behaviors.
- Moving an object moves all of its visual, physical, semantic and FX anchors through the one instance transform.
- Actor code has no room-specific destination pixels or location-country branches.
- Portal round-trip resolves destination and return by IDs.
- Saved decoration moves/rotates/removes/reappears correctly after unload/reload without changing baseline `.tscn` transforms.
- Unknown definition/variant and older save versions fail safely with diagnostics or fallback.
- Each room's required semantic destinations remain navigable after decoration placement.
- Active room camera, atmosphere, canvas/UI split, depth sort and occlusion initialize/clean up on transition.
- Performance is measured on representative target phones before changing load/preload policy.

## Deliberately out of scope for this proposal

No Home V3 migration, scene transform edits, portal implementation, global event bus, backend, inventory/store, save schema implementation, cross-room simulation engine, or new plugin is authorized here. The next step is a dev-only two-room persistence/transition proof, reviewed independently before it becomes production work.
