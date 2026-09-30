# WilliCat Decoration & Placement Architecture V1

Status: proposed system; current Home V3 layout and production content are unchanged.
Authority: Production World Architecture V1, Interaction Slot Contract V1, Navigation Footprint Strategy V1, and Home V3 stable object/slot contracts.

## Core rule

Decoration changes a room's **player-owned instance delta**. It does not move the authoritative scene layout during playtest, rewrite global markers, or turn concept art into spatial data. Every movable object remains a reusable `PackedScene` whose one room-local transform carries its visual, collision, footprint, interaction anchors, and effect anchors together.

Keep four concerns separate:

1. **Room architecture:** authored fixed shell and permanent fitted objects.
2. **Gameplay furniture/stations:** object scenes with local slots and physical footprint; some can be movable, some fixed by policy.
3. **Pure decoration:** visual objects with footprint/placement rules but no gameplay slot.
4. **Event variants:** temporary authored layers that enable/disable visual + semantic + physical effects atomically.

An object can be both furniture and gameplay-relevant (e.g. a chair owns a Seat slot); “decorative” does not mean “semantics may be detached.”

## Ownership model

```text
RoomRoot
├── Architecture (fixed authored shell)
├── PlacementZones (room-owned allowed regions, reserved paths, no-place zones)
├── Navigation (walkable room surface)
├── WorldObjects
│   ├── authored fixed instance
│   ├── authored movable baseline instance
│   └── restored player placed instances
├── EventLayers
└── WorldObjectRegistry / PlacementController (room-scoped services)

WorldObject.tscn
├── VisualRoot
├── Collision (if needed)
├── PhysicalFootprint (local shape/resource)
├── InteractionArea (if needed)
├── SemanticSlots (Seat / Rest / Sniff / CoffeeAction ...)
├── Approach / Exit anchors
└── FX / visual attachment anchors
```

`WorldObjectRegistry` resolves stable IDs and room membership. It is not a global service locator. Slot nodes live inside the owning object scene; their local position/rotation is edited with that object. The registry may expose queries such as “find available seat compatible with this actor,” never generic hardcoded pixels.

## Authored definition vs placed instance

### Immutable `WorldObjectDefinition` Resource

Recommended fields: `definition_id`, PackedScene reference, object category/tags, placement policy, allowed rotations, room/zone restrictions, optional inventory/catalog data, default variant ID, and footprint policy override only when intentionally different per product variant. The object scene is still authoritative for its real local geometry/anchors.

### Mutable `PlacedObjectInstanceRecord`

Recommended fields: stable `instance_id`, `room_id`, `definition_id`, room-local transform (position/rotation; scale only if art contract allows it), `variant_id`, and an explicit compact/versioned state payload. Do not persist node names, NodePaths, texture paths, scene-tree order, sprite frame, reservation owner, nav path, animation state, or derived render values.

An unchanged baseline object needs no player save delta. If a baseline movable object is moved, save its override keyed by its stable instance ID. A newly acquired decoration receives a new instance ID. Removing a baseline object stores a tombstone/removed flag; removing a player-added object removes that placed record and updates inventory according to the future economy policy.

## Movability policy

Each object definition/instance must declare one policy:

- **Fixed:** architecture, fitted windows, fixed service shell, essential door frame, fixed gameplay stations if the room design requires them.
- **Movable within zones:** chairs, some tables, cat bed, approved plants/decor; retains its own semantic anchors.
- **Placeable from inventory:** new object instance with ownership/inventory validation.
- **Event-only:** authored/temporary object enabled by event data, not ordinary furniture inventory.

Do not infer movability from display labels or scene names. Stable IDs and typed policy are authoritative.

## Placement space: freeform visuals, soft logical support

WilliCat artwork is not a pixel-tile aesthetic. Keep visual composition freeform. Where beneficial, provide an **invisible soft grid** or snap increment for initial/final user control; snapping is a placement affordance, not the art layout or a mandatory grid occupancy model. Allow specific objects to use non-grid placement.

Represent constraints as authored room-local polygons/regions:

- allowed placement zones (floor, patio, designated decoration area)
- blocked architectural footprints (walls, counter, door swing/threshold)
- reserved circulation/queue routes
- interaction/approach clearances for stations and seats
- minimum navigation connections and doorway access

Use object-owned `PhysicalFootprint` in local coordinates, independent of visible alpha bounds. For objects with meaningful interaction, use separate approach/seat/action-clearance shapes if their access requirement differs from physical overlap.

## Placement interaction lifecycle

1. **Select:** choose an owned/catalog object; validate it is placeable in the active room.
2. **Ghost:** instantiate preview visuals with interaction/collision disabled; transform follows screen-to-world input under the active room camera.
3. **Snap/rotate:** apply the object's allowed orientation set and optional soft-grid snap. Do not rotate to arbitrary angles unless the art, anchors, and footprint are authored for it.
4. **Validate continuously:** evaluate room zone containment, footprint overlap, forbidden polygons, doorway and circulation clearance, required action/approach clearances, and nav reachability. Use separate success/invalid preview feedback.
5. **Confirm:** atomically commit room-local transform, update the live object, slot index and relevant nav data, then emit one placement result. The operation must be undoable within the current edit session.
6. **Cancel:** discard the preview without mutating object records, navigation, inventory, or saved state.
7. **Persist:** on a save/checkpoint, write the compact record. Never write from each pointer-move frame.

Do not rebake/rebuild navigation every drag frame. During preview use cheap footprint and zone checks. On confirm, update/rebake once as required, then run reachability checks. If the placement strands a required slot or entrance, reject/roll back the commit.

## Collision, slots, navigation, and occlusion consistency

- The local shape and semantic anchors travel under the same instance transform. A moved chair must move `SeatAnchor` and `ApproachAnchor` together.
- Every occupied/reserved slot is released/reacquired transactionally if its owning object moves. Disallow moving a busy object or first safely cancel/relocate the user of the slot.
- Footprints keep space for the character's navigation radius, not only the texture bounds.
- Use nav mesh changes/room nav rebuilding for pathfinding blockers. Avoidance-only obstacles do not block the planned path.
- Y-sort order comes from the object's/character's floor-contact origin; foreground occluders remain separate scene visuals where architecture requires them.
- Don't scale a sprite as a substitute for a placement transform when that would distort collision/anchors or violate the art contract.

## Persistence and versioning

The save should contain a schema version and room-scoped placed-object deltas. JSON is an acceptable V1 format if the serializer converts vectors/transforms/colors/enums to explicit primitive structures. Use typed `.tres` resources for authored definitions, not mutable save state. Settings belong in `ConfigFile` or an equivalent settings store.

Recommended save fields:

```text
save_schema_version
world_id
unlocks / story flags
active_location_id / active_room_id
global atmosphere IDs (location, season, time, weather, persistent event)
cat logical records
per-room object overrides, added instances, removed-instance tombstones
per-object persistent state only where gameplay requires it
```

Do not store baseline room static placements, live customer/worker nodes, occupancy reservations, camera pan/zoom, active transition, computed light colors, nav mesh, or one-off guest visits. A save migration must tolerate missing/unknown definition IDs, define safe fallback behavior, and never silently discard the whole save. Atomic temp-file + replace, backup policy, and corruption handling should be designed before shipping; they are recommendations, not existing project capability.

## Fixed, movable, event and seasonal examples

| Category | Examples | Owner / persistence |
|---|---|---|
| Fixed architecture | floor, wall shell, fixed window opening, permanent service wall | Room scene; no placement record. Seasonal exterior view can be a separate variant resource. |
| Fixed gameplay object | a service station fixed by room design | Object PackedScene instance in room; local CoffeeAction/OrderPoint/approach anchors remain object-owned. |
| Movable gameplay furniture | chair with Seat slot, cat bed with Rest slot, selected table | Reusable object scene + footprint + local slots; room-local transform override only when moved. |
| Pure movable decor | approved plant, framed picture, small rug | Object definition + placement footprint; no unnecessary interaction slot. |
| Seasonal/event layer | festival textile or temporary light prop | Event/season data enables a registered layer; semantics/footprint/nav are applied with visuals if relevant. Not baked into baseline art. |
| Runtime atmosphere | lighting profile, rain, time, window contribution | Atmosphere data/director; not a furniture object and not copied into each instance save. |

## Failure cases to test

- chair overlaps table, but its seat marker/approach remains technically inside an invalid region
- object covers the only corridor or door threshold
- moved station leaves nav reachable but its approach point unreachable
- the object is grabbed while a cat/customer is using its slot
- user cancels after rotation/snap and inventory count stays unchanged
- save contains a moved baseline chair, but reload duplicates original plus override
- event prop disables visually but leaves a hidden footprint or active interaction slot
- a no-longer-installed/unknown object definition appears in an older save
- duplicated instance ID across two rooms or reusing an ID after deletion

## Smallest placement proof before production

Build a dev-only test with a fixed room shell, two separate furniture instances, one semantic chair and one cat bed, one plant, a nav polygon, a portal and two actor probes. Move/rotate/place/cancel/save/reload the same chair; prove the seat and approach move with it; prove access remains valid; prove a room swap preserves only its room record; prove a schema-migration fixture and unknown-definition fallback. Do not use Home V3 as the test bed or change its locked transforms until the architecture is approved.
