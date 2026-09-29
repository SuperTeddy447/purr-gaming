# WilliCat production world architecture V1

**PRODUCTION ARCHITECTURE LOCKED — HOME PRODUCTION CUTOVER NOT YET AUTHORIZED.** Godot 4.7.2 hardening labs passed the 32 structural gates in `tests/test_world_architecture_hardening_v1.gd`, live GodotAI Editor moves, and real viewport review. Keep the playable Home/True Slice baseline until the separate migration, real-device profiling, and human visual approvals. This document supersedes the provisional [V2 recommendation](WILLICAT_WORLD_ARCHITECTURE_RECOMMENDATION_V2.md) on ownership/capacity/footprints/camera/events; it does not supersede locked art, character masters, or camera framing. The lock rationale is recorded in [ADR V1](WILLICAT_PRODUCTION_ARCHITECTURE_LOCK_ADR_V1.md).

## Room / Zone responsibility

```text
RoomRoot (stable room ID; semantic registry; placement & variant authority)
├── Architecture / Floor / fixed walls
├── Navigation (room walkable polygon, footprint contributions)
├── DepthSortedLayer
│   ├── WorldObjects (stations, furniture, cat-life props, decor)
│   ├── Characters (foot-pivot actors)
│   └── EventLayer (optional props, slots, FX, focus targets)
├── Foreground (true fixed overlays only)
├── FX / RuntimeSignage (room-owned or attached to objects)
├── Camera2D + CameraInput + CameraDirector
└── HUD CanvasLayer
```

The room owns authored instance transforms, walkability, camera bounds, entrances/transitions, semantic discovery, event activation and placement validation. It does **not** own each chair's seat point or an EspressoStation's CoffeeAction. A separate event Room/Zone uses the same contracts with different authored placements.

## Reusable WorldObject / PackedScene

Each object instance has a stable **room-scoped instance ID** plus a reusable PackedScene/type ID. The object root is its floor transform. Optional composed children: VisualBack/VisualFront, PhysicalFootprint+collision, InteractionSlots, state/controller, FX anchors, CameraFocus markers and tap area. Moving/rotating the root carries all local children. Object scene defines local mechanics and geometry; `.tscn` Room defines where instances sit. No texture alpha or generated-art composition is spatial truth. Persisted references use IDs, never display labels or raw NodePaths. Not every prop needs every component.

CounterServiceZone groups related objects but is not a monolithic CounterStation. CounterShell owns counter geometry/front occlusion plus OrderPoint, ServePoint and customer approach semantics. Independently movable EspressoStation owns CoffeeActionSlot, SteamFXAnchor, CupSpawnAnchor, CameraBrewFocus and CameraCupReveal. Grinder/POS may later own their own slots. WorkerIdle may be a room/zone-authored staging point if not physically intrinsic to one machine. The lab verifies Espresso moves all five machine anchors while CounterShell OrderPoint/ServePoint do not move.

Chair owns SeatSlot/approach/action/exit and floor footprint; Table owns its footprint and only table-specific slots, not separately movable chairs. CatBed owns Rest/Sleep (shared capacity), Plant owns Sniff, ScratchPost owns Scratch/Stretch. Future HotSpring can own several SoakSlots and front water occluder; DigPatch can own Dig/Plant/Harvest slots. These are extension shapes, not implemented gameplay.

## Interaction, reservation and animation

Actor asks the room for a compatible semantic action, optionally constrained to an object ID. Room chooses enabled, category-compatible, unoccupied slot by priority/distance. Reservation must occur before pathing; slot and optional object-level shared capacity are claimed atomically. Actor navigates to Approach, binds to Action, emits action-start, waits for completion/animation/object state, exits, releases once. Cancellation, actor/object removal, disable, failed nav and scene exit release. A lost slot returns actor to Idle rather than leaving a dead reservation. See [slot contract](WILLICAT_INTERACTION_SLOT_CONTRACT_V1.md).

Generic actor state is **not** animation asset state. Semantic states (Idle, Walk, Sit, Loaf, Sleep, Inspect, Sniff, Stretch, WorkCoffee, Carry, Serve, Purr) drive the existing sprite/AnimationPlayer/layered-expression presentation through local adapters. Use AnimationTree only if actual transition complexity warrants it. No skeletal system is prescribed. Gameplay completion/reward remains authoritative; animation never silently grants it. Object action state/FX is synchronized through signals/cues, not a global bus.

## Navigation, depth and future decoration

Room nav polygon is baked from authored walkable area minus transformed object-owned PhysicalFootprints, with clearance for actor feet. A physics collider or `NavigationObstacle2D` avoidance alone is **not** a path obstruction. Actor NavigationAgent2D samples the server path each physics step. After a discrete placement move, validate bounds/non-overlap, update object transform and nav contribution, wait for map synchronization, refresh affected actor targets. Batch/debounce production rebakes; profile on mobile. Static architecture bakes on load. See [footprint strategy](WILLICAT_NAVIGATION_FOOTPRINT_STRATEGY_V1.md).

Depth uses floor-contact actor/object origins and compatible Y-sort ancestry. Split a large object's rear/front visuals locally when its lower front must cover actors; dedicated foreground is for always-foreground architecture. Broad z layers are acceptable, per-state actor z-index patches are not. An optional **invisible** placement grid may later provide decoration snapping, while visuals remain freeform illustrated art. The lab tests a rotated chair and stable-ID placement snapshot; it does not implement decoration UI or save/load.

## Camera and UI

Room CameraDirector temporarily owns the existing Camera2D, not actor AI. Objects/characters own Marker2D focus targets; typed CameraShot Resources own zoom/timing/easing/hold/follow/priority/input/HUD policy. Director snapshots gameplay position/zoom/offset/input/HUD, locks gestures, handles higher-priority replacement/target removal/cancel/scene exit and restores exactly. It must preserve existing camera limits and portrait 3/4 visual family. HUD is CanvasLayer screen-space. Use Tween for dynamic focus interpolation; AnimationPlayer/AnimationMixer for authored multitrack story sequences. See [camera contract](WILLICAT_CAMERA_DIRECTOR_ARCHITECTURE_V1.md).

## Event and persistence boundary

Base-room EventLayer can overlay props/FX/slots/focus targets; activation must toggle visual, semantic and nav contribution together. A separate event Room reuses the same actor/slot/camera/navigation code with different `.tscn` placements. Event selection belongs to room/event state, never generic character coordinate branches. See [event contract](WILLICAT_EVENT_VARIANT_ARCHITECTURE_V1.md).

Authored room placements and object instances live in `.tscn`; reusable object definitions and typed shot/action policies in `.tscn`/`.tres`; runtime save will hold schema-versioned room ID, stable object instance ID, type ID, transform, variant and object state. Occupancy/reservations are ephemeral runtime state, not blindly restored. JSON is only an interchange format if an external tool truly needs it.

## Evidence and non-claims

The [18-image lab pack](../../artifacts/prototype_review/world_architecture_hardening_v1/README.md) includes a real 539×959 viewport and real 539×1168 tall SubViewport. The acceptance test covers capacity/double reservation/cleanup, actual table-hole path and actor traversal, object move/rotate/placement snapshot, multi-agent actions, Espresso ownership, camera focus/priority/follow/restore/cancel/scene exit, event variant and separate event room. Existing Foundation, camera, Vertical Slice, True Slice, Mochi scale and Home V2 tests remain green.

This is **not** a mobile frame-budget proof, crowd/queue solution, final art/style review, production decoration UI, save migration, or Home migration approval. The existing Home counter occlusion baseline is preserved; the hardening placeholder art does not certify final counter-front rendering. Human review and the [Home migration plan V2](WILLICAT_HOME_MIGRATION_PLAN_V2.md) are required before cutover.
