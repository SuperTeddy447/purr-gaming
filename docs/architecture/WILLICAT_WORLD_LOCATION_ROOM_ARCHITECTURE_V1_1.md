# WilliCat World / Location / Room Architecture V1.1

Status: **production-lock candidate for human review**, not a production lock or Home migration authorization. This document hardens [V1](WILLICAT_WORLD_LOCATION_ROOM_ARCHITECTURE_V1.md). The [Production World Architecture V1](WILLICAT_PRODUCTION_WORLD_ARCHITECTURE_V1.md), [InteractionSlot contract](WILLICAT_INTERACTION_SLOT_CONTRACT_V1.md), [navigation/footprint strategy](WILLICAT_NAVIGATION_FOOTPRINT_STRATEGY_V1.md), [CameraDirector contract](WILLICAT_CAMERA_DIRECTOR_ARCHITECTURE_V1.md), [atmosphere architecture](WILLICAT_WORLD_ATMOSPHERE_ARCHITECTURE_V1.md), [Character Runtime V1.1](WILLICAT_CHARACTER_RUNTIME_PRODUCTION_CONTRACT_V1_1.md), and [Home V3 layout lock](../design/WILLICAT_HOME_V3_LAYOUT_LOCK_V1.md) remain authoritative.

## Decision and corrections to V1

Use **WorldDefinition → LocationDefinition → RoomDefinition → RoomRoot PackedScene**. Do not introduce `BuildingDefinition` in V1. A location is a map destination or venue, whether it is a building, street, garden, or plaza. One location may contain several room scenes. Optional map groups identify district/town/city presentation and unlock structure without becoming loaded gameplay scenes. A building only becomes a first-class definition if a later mechanic gives the building its own lifecycle or shared state that cannot be represented by its location and rooms.

Two V1 proposals are corrected to conform to the locked production-world contract:

- Authored object `instance_id`s are **room-scoped**. Persisted identity is `(room_id, instance_id)`; a bare object ID is not globally authoritative. Player-added IDs are unique within their room. An inventory item has a separate globally stable `item_id`.
- The V1 text suggesting JSON as the default game save does not override the locked statement that JSON is only an interchange format when needed. The [state/persistence contract](WILLICAT_WORLD_STATE_AND_PERSISTENCE_CONTRACT_V1.md) defines a format-independent schema and a Godot-native V1 storage candidate; the codec must pass a small round-trip/migration proof before selection is locked.

The V1 pipeline phrase “decompose a master composition” must never be interpreted as cutting a finished flat café image into game sprites. The [pipeline V2.1 proposal](../production/WILLICAT_ENVIRONMENT_PRODUCTION_PIPELINE_V2_1_PROPOSAL.md) makes that boundary explicit.

## 1. Canonical hierarchy and IDs

```text
WorldDefinition (world_id; location catalog; map groups and travel graph)
├── MapGroup records (group_id, optional parent_group_id; data/UI only)
└── LocationDefinition (location_id, map_group_id, default environment profile)
    └── RoomDefinition (globally unique room_id, location_id, room_scene)
        └── RoomRoot PackedScene (one active instance in RoomHost)
            ├── Architecture / floor / fixed shell
            ├── Navigation / placement zones / entrances
            ├── DepthSortedLayer (object, character, event instances)
            ├── Foreground / FX / RuntimeSignage
            └── CameraRig / CameraDirector / HUD policy
```

`world_id`, `location_id`, `room_id`, `group_id`, portal IDs and spawn IDs are stable authored IDs, never translated display labels. `room_id` is unique within one world catalog; `instance_id` is unique within a room. Actor and save references to a placed object carry both IDs. A `RoomDefinition` references an authored scene and defaults; it does not repeat the scene's object transforms. The room scene owns world-space geometry and child-object instance transforms. The reusable object scene owns local footprint, collision, slots, focus/FX anchors, and visuals.

Example identity plan, not a city design:

| Map group | Location | Rooms and relationship |
|---|---|---|
| `home_district` | `home_cafe` | `home_cafe_main`, `home_cafe_upstairs`, possibly `home_cafe_garden` if garden is part of the same venue |
| `home_district` | `home_street` | `home_street_main`, reached by an authored entrance portal |
| `home_district` | `neighbor_shop` | `neighbor_shop_main`; its own room scene and later unlock |
| `harbor` | `harbor_shop`, `harbor_plaza`, `harbor_event` | Each has at least one room; the map group adds no actor branches |

A garden that merits its own world-map icon can instead be a location with one room; the room/portal/actor APIs remain identical. A later city/region is a map group or set of connected map groups until it needs a concrete new gameplay responsibility. No production code should branch on the literal `home_district` or `harbor` string.

## 2. Single-owner authority model

| Concern | Authoritative owner | Saved form | Rebuilt or transient form |
|---|---|---|---|
| Spatial truth, fixed architecture, baseline instance transforms, local portal/spawn geometry | Authored `RoomRoot.tscn` and child object scenes | Only player overrides/additions/removals | Active room node hierarchy, physics/nav map |
| Gameplay object capabilities and type identity | `WorldObjectDefinition.tres` plus reusable object `PackedScene` | `definition_id` on a changed/added instance | Instantiated slots/footprints/controllers |
| Placed object mutable state | `WorldSession.RoomDelta` keyed by room and instance ID | Versioned transform/variant/state delta | Room instance transform and local child anchors |
| Cat identity, assignment, relationship, schedule/activity | `WorldSession.CatWorldState` | Versioned cat record | Visible `CharacterBody2D`, reservations, path, animation |
| Ordinary customer visit and current order | Active room `VisitSession`/existing gameplay controller | At most a bounded active transaction checkpoint if saves may occur mid-loop | Customer actor, bubble, cup, slot reservations |
| Recurring/story visitor identity and story progress | WorldSession story/visitor record | Visitor/story IDs and durable flags | Current visit actor and route |
| Atmosphere source IDs / persistent lamp override | WorldSession plus immutable profile catalog | Location/season/time/weather/event IDs, manual lamp override | Evaluated colors, lights, FX, per-room fixture bindings |
| Camera defaults, limits, authored focus markers | Room scene / `RoomDefinition` / typed CameraShot resources | No temporary shot or pan/zoom in V1 | Director mode, tween, input/HUD snapshot |
| Event eligibility and current active event | Event definitions + WorldSession ID | Durable event ID/flags and eligible object state | Room EventLayer visibility, slots, footprint/nav contribution |
| Art presentation, perspective, registration | Approved asset contract and object/room scene | Variant ID only when player/event changes it | Imported textures, sorting, render output |

Runtime `RoomRoot` can temporarily own interaction and navigation state while active; it is not a second persistence owner. `WorldFlowController` sequences transitions but does not own cats or save data. `SaveCoordinator` encodes/decodes snapshots but does not become another mutable world model.

## 3. Room lifecycle

V1 uses **UNLOADED → LOADING → ACTIVE → UNLOADING → UNLOADED**. A `PackedScene` resource may be prefetched while the source room remains ACTIVE, but this is a resource cache, not a loaded second room or a background simulation state. There is no V1 `SUSPENDED` RoomRoot.

| State | Live nodes | Durable/world state | Simulation |
|---|---|---|---|
| UNLOADED | No RoomRoot, camera, nav agents or visual actors | Authored definitions and scene resources remain addressable; WorldSession holds room delta, cat/visitor state, unlocks | Coarse clock/schedule/activity updates on logical records only |
| LOADING | Destination room instantiates under `RoomHost`; apply scene baseline and validated deltas | WorldSession remains owner of mutable state | Hold actor input and route requests until nav, slots, atmosphere and camera initialize |
| ACTIVE | Exactly one RoomRoot, local object/actor nodes, nav map and camera | Changes are mirrored into WorldSession at stable checkpoints | Full local gameplay and visible animation |
| UNLOADING | Source input and new slot reservations stopped; active transactions resolved | Snapshot room deltas and logical entities before freeing nodes | Release reservations, cancel camera shots/tweens, detach FX, stop local actors |

An unloaded room retains **data**, not an inactive copy of its scene tree. Cats assigned to that room remain in WorldSession. On return, room-local object state is reconstructed, room navigation is built, the server is allowed to synchronize, then visible actors are spawned and their semantic goals revalidated. Offscreen cats do not advance physics paths or reserve slots.

## 4. Travel and camera responsibility

Door, stairs, edge portal and world-map selection all produce a typed request with `source_room_id`, destination `room_id` and destination `spawn_id`. An authored portal supplies its own destination and visual/trigger geometry; a world-map entry resolves a permitted room/spawn through the same flow. Unlock policy is checked against stable graph/quest IDs before any source teardown.

Transition order:

1. Reject overlapping requests and verify target IDs, unlocks, and resource availability. Keep the source room active on rejection or load failure.
2. Stop new interactions. Resolve the current visit/order under the explicit transaction policy; release slot reservations and cancel room-owned temporary camera shots.
3. Commit source room deltas and cat logical state to WorldSession. A durable file save is a separate checkpoint, not an implicit write on every door touch.
4. Show a persistent screen-space transition cover, freeze gameplay gestures and use the source door's presentation hook where available.
5. Unload the source RoomRoot; instantiate the destination RoomRoot; apply validated deltas and active event state; build navigation and wait for synchronization; spawn visible actors at the destination semantic spawn.
6. Bind destination camera, atmosphere fixtures and HUD policy. Start from that room's authored default framing; do not carry a temporary source shot or arbitrary pan/zoom into the next room.
7. Reveal and resume input. If destination activation fails after source unload, reconstruct the source from the pre-transition WorldSession snapshot and restore controls; no reward or inventory operation may run twice.

V1 requires **one active RoomRoot**. Resource prefetch is optional and requires a measured mobile benefit. A world map is graph/data/UI; it does not require all rooms to be loaded. The room owns its `CameraDirector` and local focus targets; the persistent transition cover owns only screen-space fade/loading presentation.

## 5. Cats, customers and offscreen time

A cat has one persistent `CatWorldState` keyed by `cat_id`; its current `room_id` is stored, and `location_id` is derived and checked through `RoomDefinition`. The API may expose both. Persist `activity_id`, optional assignment/target reference, relationship/needs/schedule checkpoint and `last_simulated_game_time`. The target is a semantic `(room_id, instance_id, action_type)` reference, never a NodePath or actor coordinates. On unload, stop its actor and release its slot; the logical target remains an intent only if still valid. On activation, validate the room, object and action, then reserve a fresh slot or choose a documented fallback such as Idle. A cat in transit has a logical destination room/spawn; no offscreen NavigationAgent exists.

Advance offscreen records at discrete game-clock boundaries (for example schedule events or bounded time steps), with a cap on elapsed-time catch-up. Keep random decisions seeded/stable if randomness is needed. Do not run full offscreen navigation, animation, collision, or customer/coffee gameplay. Do not award café currency through coarse cat simulation unless a separate business rule explicitly owns that outcome.

Ordinary customers are ephemeral per-visit actors and state, with an optional *single active transaction checkpoint* for crash recovery. Named recurring customers retain identity, relationship and schedule/story flags, but their visit actors are transient. Story visitors retain quest/event progress and only materialize as actors when the relevant room/event is active. Any reward granted from a visit must use the existing gameplay authority and a durable transaction ID/granted flag so transition/reload cannot grant it again; see the state contract. V1 does not create thousands of permanent guest records.

## 6. Decoration, navigation and events

Use a **hybrid placement policy**: freeform room-local placement, optional invisible soft-grid/edge snapping, object-specific allowed orientations, and exact physical/semantic validation. Snapping helps touch input; it does not define the room's art or replace object footprints. Player moves are RoomDelta records applied on top of the authored scene. Unchanged authored instances have no save entries. Stored, replaced and upgraded objects follow the transaction rules in the state contract.

Decoration mode starts only at a safe local checkpoint. It stops new slot reservations and actor routing, then freezes or finishes current interactions before editing. During drag, validate zones and transformed footprints cheaply; do not rebake navigation each frame. On confirm, stage the transform, rebuild/batch the affected room nav, await server synchronization, test required approaches and entrances for the **largest eligible actor clearance profile**, then commit revision and resume actors. Invalid placement rolls back the transform and nav; normal gameplay never continually rebakes for static furniture. Event footprints are included in validation when their variant can be active, and event activation itself updates visual, slots and nav together.

The [locked footprint strategy](WILLICAT_NAVIGATION_FOOTPRINT_STRATEGY_V1.md) remains the implementation basis. The current lab's synchronous bake, forced map updates, global-coordinate `placement_snapshot`, and scene-tree slot scan are **dev proofs**, not the production save codec or mobile update path. Room-local pathfinding does not cross room portals. On room activation the nav mesh is rebuilt from authored walkability and transformed object-owned footprints; path requests wait for nav synchronization.

## 7. Home V3 as the first reference room

Home V3 keeps its Staggered Salon transforms, 20 stable world-object instance IDs (17 art-bearing and three WaitSlots), two table islands, door circulation, camera family/limits, CounterShell/Espresso separation, scene-owned markers, Y-sort and event niche. The proposed `RoomDefinition` would *reference* the locked scene and provide stable room/location IDs, atmosphere/default exterior binding, entry spawn/portal IDs and camera profile metadata. It would not duplicate the 20 transforms.

The floor, walls, fitted window and fixed architectural connectors remain room architecture art. CounterShell/espresso/POS/grinder/pastry, seating, bed, perch, plant and scratch post remain independent scene objects with their existing local semantics. Only explicitly approved movable candidates become decoration eligible after placement/nav/visual review. Location-specific configuration chooses ambience/exterior/signage/event data; generic actor code receives semantic slots, never Home identifiers. The current Home scene is not changed by this document.

## 8. Reuse, deprecation and gates

**Retain:** InteractionSlot reserve→approach→action→exit lifecycle, object-owned anchors/footprints, NavigationRegion/Agent room paths, CameraDirector and focus anchors, atmosphere evaluator/director, Character Runtime root/visual split, Home V3 authored layout, EventLayer semantics, Asset Forge technical validation. Existing playable Home/True Slice remains baseline until separate cutover.

**Do not promote from dev proofs:** `HardeningWorld`'s recursive slot/object scan as a production registry; synchronous `map_force_update()` after each move; `placement_snapshot()` as save data; demo actor orchestration as business state. These remain useful tests. Previously deprecated global markers, hardcoded map vectors, concept-image coordinate reconstruction, and per-state z-index patches remain deprecated. No locked production subsystem is newly discarded.

Before lock, run the single [two-room vertical proof](../production/WILLICAT_MULTI_ROOM_VERTICAL_PROOF_PLAN_V1.md), save codec round-trip/migration, invalid-placement/failed-transition recovery, same actor/slot code in both layouts, Home unchanged diff check, and representative mobile profiling. This V1.1 is a reviewable contract candidate; it does not assert that the proof has passed.

## Open decisions for the proof

- Maximum usable navigation agent clearance across all intended cat/customer body classes may make narrow decorative arrangements invalid; measure against real character scale.
- Exact save file replacement/backup behavior must be tested on the supported mobile OS/filesystems, not assumed from desktop.
- Mid-order app termination and forced room travel need an explicit transaction checkpoint policy compatible with the existing reward handler.
- Catalog content revisions may invalidate placed object transforms; migration/recovery must keep user-owned items without duplicating authored furniture.
- Real art seams, overhang and camera readability still need assembled Godot review under the revised production pipeline.
