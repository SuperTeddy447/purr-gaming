# WilliCat World State and Persistence Contract V1

Status: **schema and ownership candidate for review**; no game-world save implementation currently exists. This contract extends the locked [Production World Architecture V1](WILLICAT_PRODUCTION_WORLD_ARCHITECTURE_V1.md) without changing scene authority. The current `HardeningWorld.placement_snapshot()` is a test seed only and is **not** a serializer.

## Principle: one mutable owner, explicit reconstruction

`WorldSession` owns mutable logical world state in memory. `SaveCoordinator` copies an immutable snapshot, validates/encodes/decodes it, and commits it to a `user://` save slot; it does not own a second independently changing world model. Active room nodes present and execute that state. Authored `.tscn` scenes and typed `.tres` resources own baseline geometry and definitions. Evaluated lighting, navigation, camera shots, animation and reservations are reconstructed.

## Field ownership ledger

| Field / state | Authored source | Runtime owner | Save representation | Derived / never saved |
|---|---|---|---|---|
| `world_id`, location/room/portal/spawn definitions and unlock conditions | World/Location/Room typed Resources; portal geometry in Room scene | Read-only catalog / WorldFlowController | `world_id`; unlocked ID set and durable story flags | Map UI layout and currently enabled edges |
| Fixed architecture, room bounds, nav walkable base and baseline object transforms | `RoomRoot.tscn` | Active RoomRoot | No duplicate transforms | Active nodes, nav mesh |
| Object `definition_id`, local footprint, slots, visual anchors, allowed placement policy | Object Resource + PackedScene | Read-only catalog / object instance | Definition ID only for added/replaced instance | Sprite, collision, slot nodes |
| Room baseline object `instance_id` | Room scene, unique in `room_id` | Room-scoped registry | ID only when overridden/removed | NodePath/tree order |
| Added object's `instance_id`, transform, variant, durable object state | Definition plus player action | `WorldSession.RoomDelta` | Full added record | Instantiated object, reservations |
| Moved baseline object's transform/variant | Room scene baseline | `WorldSession.RoomDelta` | Override keyed by `(room_id, instance_id)` | Unchanged baseline data |
| Cat `cat_id`, room, activity, assignment, relationship, schedule/needs | `CatDefinition.tres` for identity/defaults | `WorldSession.CatWorldState` | Bounded logical record | Actor node, movement path, slot reservation |
| Cat `location_id` | RoomDefinition relation | Derived from cat `room_id` | Omit to avoid conflicting duplicates | API projection / validation result |
| Ordinary customer's open visit and order | Customer template and gameplay order definition | Active-room `VisitSession` and existing gameplay controller | At most one active transaction checkpoint if saving mid-service | Guest history, actor/FX nodes |
| Named/story visitor relationship/quest state | Visitor/event definition | WorldSession | Visitor/story IDs, flags and schedule checkpoint | Visit actor/path |
| Currency and reward grant receipt | Existing reward/gameplay handler | WorldSession economy/transaction state when migrated | Balance and transaction grant marker in one snapshot | Reward UI/coin FX |
| Season/time/weather/location/event input IDs | Atmosphere catalog and event definitions | WorldSession | Semantic IDs and durable manual lamp overrides | Evaluated colors, lamp energy, particles |
| Camera profile/default limits and shot definitions | Room scene / CameraShot Resources | Active CameraDirector | No temporary shot or V1 pan/zoom | Tween, focus target node, input/HUD snapshot |
| Event object definitions and activation rules | Event Resource / room EventLayer scene | WorldSession active event ID; active room controller | Event ID/flags and only truly persistent per-object state | Hidden/showing visuals, slot/nav effects |
| Art textures, local root registration and material response | Approved art contract, source assets and object scenes | Renderer / active scene | Selected durable `variant_id` only | Imported textures and visual nodes |

Runtime state cannot silently write back into an authored Resource shared by several rooms. If a mutable `.tres` is instantiated, it is still design data unless explicitly duplicated and put behind a runtime state boundary.

## Stable IDs and reference shape

- `world_id`, `location_id`, `room_id`, `definition_id`, `cat_id`, `item_id`, event/story IDs and transaction IDs are stable catalog/session identifiers; display names may change independently.
- The authoritative object key is `(room_id, instance_id)`. An authored `chair_a` in Room A and another `chair_a` in Room B are distinct. Validate uniqueness **inside each room**, not globally across rooms.
- User-added objects receive new room-scoped `instance_id`s; never derive IDs from node order, timestamp alone, or display labels. Inventory uses a separate global `item_id` so a stored item can move between rooms without claiming the same room instance identity.
- A cat target is `(room_id, instance_id, action_type)` plus optional assignment ID. It is a *goal*, not a persisted reserved slot. Resolve through the active room registry after loading. Unknown or incompatible targets clear to a safe activity/Idle state.
- Portal references use `(destination_room_id, spawn_id)`; room definition resolves the corresponding location ID. Saves do not contain `res://` scene paths or absolute filesystem paths.

## V1 save shape

The schema is independent of its on-disk codec. Conceptual root fields:

```text
save_schema_version: 1
content_revision: authored catalog revision used at last save
world_id
active_room_id and entry_spawn_id
world_game_time and random_seed/state only where deterministic replay needs it
unlocked_location_ids / unlocked_room_ids / story_flags
atmosphere: season_id, time_id, weather_id, persistent_event_id, lamp_overrides
cats: cat_id -> logical CatWorldState
visitors: named/story durable records only
rooms: room_id -> RoomDelta {baseline_overrides, baseline_tombstones, additions, durable_object_states}
inventory: item_id -> definition_id, variant_id, durable_item_state, ownership/location
economy: currency, bounded active/recent transaction receipts
active_visit_checkpoint: optional and limited to active room
```

`location_id` is derived from `active_room_id` and each cat's `room_id`. `room_id` must resolve to one location; validation rejects mismatches. Session mutation updates this in-memory structure; saving serializes a snapshot at an explicit safe checkpoint. Never save visible node trees, scene paths, baseline object placements, live NavigationAgent paths, animation frames, temporary camera shots, transient slot occupancy, or computed atmosphere output.

### Candidate V1 storage

Use a versioned plain `Dictionary`/`Array` payload containing only primitive scalars, strings and collections, encoded with Godot `FileAccess.store_var(..., false)` and read with `get_var(false)` from `user://` behind a `SaveCodec`. Explicitly encode 2D position as numeric `x/y`, rotation in radians and supported scale as numeric values; reject NaN/Infinity/out-of-range values. Do **not** serialize full Objects/Resources. This is a candidate consistent with the locked architecture's JSON boundary; the two-room proof must validate the API and migration on Godot 4.7.2 and representative mobile devices before the codec is locked. [Godot FileAccess](https://docs.godotengine.org/en/4.7/classes/class_fileaccess.html) documents `store_var`/`get_var` options; [DirAccess](https://docs.godotengine.org/en/4.7/classes/class_diraccess.html) provides rename operations. JSON remains an optional debug/export interchange when truly needed, not the default world save authority.

Write to a same-directory temporary slot, close/flush, read back and validate length/schema/checksum, retain the prior valid slot as backup, then promote the new slot. The exact replace/backup order and crash behavior must be tested on macOS and supported mobile platforms; this document does **not** claim rename is universally atomic. On failed load, leave the current session untouched and offer last valid backup or a clean new game, never partially apply corrupt data.

## RoomDelta application order and invariants

1. Instantiate the authored room scene; index baseline object IDs and compare `content_revision`/room revision before mutation.
2. Validate all delta records against the catalog and object placement policies. Preserve unknown entries in a recoverable quarantine instead of dropping them.
3. Apply baseline tombstones, then baseline transform/variant overrides keyed by the room/object pair. Never instantiate another copy of a moved baseline object.
4. Instantiate additions with unique room-scoped IDs, then apply durable object state. Ensure a global owned `item_id` is in exactly one state: stored or placed.
5. Apply the active event variant coherently to visuals, slots, footprints and nav contribution.
6. Build/rebake navigation once from the final validated object footprints. Validate entrance, required service slots and cat/customer clearance. Wait for nav synchronization before actor requests.
7. Spawn visible actors from logical records and bind the destination camera/atmosphere. Reacquire semantic goals; never restore reservations.

If a baseline override becomes invalid after an authored room revision, retain its original delta in recovery data and use the baseline transform for the live room until the player resolves it. If an added item or definition is missing, keep the owned item/placement record in recovery storage and omit its live node. Do not duplicate, delete, or silently move it onto a new floor point. These are proposed recovery policies to prove, not current implementation.

## Furniture state transitions

| Origin and action | RoomDelta / inventory result |
|---|---|
| Unchanged authored furniture | No save entry; instantiate exactly once from room scene. |
| Player moves/rotates authored furniture | One override keyed by `(room_id, instance_id)` with room-local transform and optional variant/state. Baseline remains in `.tscn`. |
| Player adds an owned item | New room-scoped instance ID, `definition_id`, transform, variant and `item_id`; inventory marks the item placed. |
| Player stores an authored baseline object | Baseline tombstone in source RoomDelta plus a newly assigned `item_id` in storage. The scene no longer presents its default copy. |
| Player stores an added object | Remove its active placement record; the same `item_id` becomes stored. No phantom placement remains. |
| Player places a stored item into another room | Create a new room-scoped instance ID there; preserve `item_id`, definition/variant/state; source tombstone or removal remains. |
| Player replaces/upgrades an object | Perform one transaction: validate new definition/footprint/slots, preserve `item_id` and instance ID only if the replacement is compatible; otherwise store old item and create a new approved placement. Never overwrite an authored definition. |

Inventory/shop rules are not implemented here. These records define the no-duplication boundary for future systems. Event-only and fixed architecture objects cannot be placed in inventory through ordinary decoration mode.

## Cat simulation and customer checkpoint

`CatWorldState` minimum stored values: `cat_id`, current `room_id`, `activity_id`, optional `assignment_id` and target ref, relationship/need values or IDs as actually implemented, schedule cursor/next event, `last_simulated_game_time`, and optional travel destination/spawn. The API derives `location_id` from room. One world record exists per cat, and at most one active-room visual actor represents it. On room unload, release interactions and delete the actor only after logical state is committed. Offscreen time advances from the **game clock** in bounded deterministic steps; it may update needs/schedule/intent, but not positions along a navigation path or unearned rewards.

Ordinary customer visits are transient. If a save can occur mid-loop, snapshot only the active room's bounded visit/order transaction with stable `order_id`/`visit_id`, state and reward-granted flag; on reload either resume at a documented safe state or cancel cleanly. Never replay a serve callback to infer whether reward was paid. Serving updates reward balance and grant receipt together in WorldSession; repeated taps/reload inspect the receipt and cannot pay again. After a completed visit has been checkpointed and removed, old receipt detail may be compacted because no active order can reference it. Travel during an active transaction must either wait for a safe checkpoint or follow an explicit cancel-without-reward policy; it cannot silently discard a served reward or replay it.

Special recurring customers persist identity, relationship and schedule/story flags. A story visitor persists its quest/event progress. Their live scene nodes and per-visit route/slot state remain transient. No mass archive of ordinary guest objects is part of V1.

## Schema evolution and error handling

- `save_schema_version` controls codec/schema migration; `content_revision` identifies authored catalog/layout changes. They are independent.
- Migrate one schema version at a time in a pure data step before constructing any RoomRoot. Keep migration fixtures for the prior released version. Never mutate a saved file before a migrated snapshot validates.
- Catalog migrations may map renamed room/object/definition/variant IDs. A removed ID must have an explicit map, fallback or recoverable unknown entry. No node name/path matching.
- Reject duplicate room-local instance IDs, duplicate item ownership, invalid transforms, unknown active room, bad enum IDs and impossible cat room relationships before applying state.
- Autosave only at stable checkpoints or through an explicit active-visit snapshot policy. Use a single in-flight save per slot; expose write failures rather than claiming success.
- The proof must verify old-schema migration, corrupted-primary recovery, unknown-content preservation, failed-transition rollback, inventory/placement uniqueness and reward once-only behavior.

## Implementation boundary

The contract specifies data, ownership and failure policy. It does not authorize a production save implementation, economy change, customer rewrite, Home V3 scene migration, or new plugin in this task. The [vertical proof plan](../production/WILLICAT_MULTI_ROOM_VERTICAL_PROOF_PLAN_V1.md) is the smallest implementation gate before a lock decision.
