# Recommended WilliCat world architecture V2

**Decision for human review:** room/zone-authored `PackedScene` composition with local semantic anchors, room-owned navigation, and foot-pivot Y-sort. Keep a future invisible placement grid as an optional decoration subsystem, not the visual foundation. This is a recommendation, **not** approval to migrate Home.

## Ownership and tree

```text
WorldRoot (room scene; stable room ID and destination registry)
├── Architecture (floor, walls, noninteractive shell)
├── LogicalFloor (walkability/nav data; optional hidden placement grid)
├── WorldObjects (Y-sorted, instanced object roots)
│   ├── InteractiveStations (counter/espresso/POS/entrance)
│   ├── Furniture (table/chair)
│   └── CatLifeProps (bed/plant/basket)
├── Navigation (NavigationRegion2D and authored clearance)
├── Characters (foot-pivot actor roots and NavigationAgent2D)
├── Foreground (true foreground-only architectural overlays)
├── FX (world FX, attached locally where possible)
├── RuntimeSignage (level or object-bound dynamic signs)
└── Camera (room camera rig and approved framing)
```

The tree is a responsibility map; actual Y-sorted descendants must share compatible CanvasItem sorting ancestry. `WorldRoot` stores/querys stable instance IDs and semantic roles, not a hard-coded array of screen pixels. The lab resolver recursively indexes `LabDestination` markers at `_ready`; production needs registration/invalidation when decorations spawn, move, or despawn and must handle duplicate semantic roles deliberately.

## Scene vs object contract

The level owns the instance transform, room entrance/transition, shared navigation, overall camera, and truly global staging points. A reusable object owns its visual parts, footprint/collision, tap area, local interaction/FX/animation anchors, and optional stateful controller. Moving the object root moves all owned anchors without rewriting coordinates. A counter can own WorkerIdle, OrderPoint, and ServePoint when those are physically counter-defined. If the espresso machine is independently rearrangeable, CoffeeAction belongs to that machine subscene, mounted on or near the counter; never maintain duplicate authoritative anchors. A chair owns its SeatAnchor; a table owns table approaches but not independently movable chairs. Bed owns Rest/Sleep/Knead; plant owns Sniff. The entrance owns its threshold; the room owns which destination room it leads to.

Semantic destinations should be queried by role plus optional stable object/seat ID, e.g. `find_destination(&"coffee_action", station_id)` or an object capability method. Generic behavior must not contain `Vector2(402, 525)` or node display-name-dependent paths. The current labs implement one-instance-per-role lookup and the same `LabActor` script in both layouts; a production resolver must support multiple stations/seats, allocation/occupancy, and invalidation.

## Navigation

For customer flow (Entrance → Order → assigned Seat → Exit), resolve semantic endpoints from object instances and route with a `NavigationAgent2D` on an authored room `NavigationRegion2D`. Keep a small semantic/waypoint graph only where flow lanes, queues, or cutscenes demand a particular approach. For cats (Idle → Bed/Plant/Window/Station → Idle), use the same navmesh with different valid destination capabilities and local approach anchors; wandering policies are separate from the pathfinder. `AStarGrid2D` is appropriate if future decoration requires strict cell occupancy. It should not be introduced as the sole path model until grid registration is proven for irregular illustrated furniture. NavigationPolygon clearance must be authored/baked against actual footprints; physics collision and sprites do **not** automatically make navmesh obstacles.

Lab A/B prove semantic endpoint resolution and path-query traversal on a simple rectangular navmesh. They do **not** prove production obstacle avoidance, multi-agent collision, dynamic furniture rebaking, touch UX, or frame-budget performance. Lab actors deliberately use collision mask 0 to isolate endpoint/path proof. Those are explicit next acceptance gates before a Home migration.

## Depth/occlusion

Put actor origin at floor contact; set sprite local offset to register feet there. Use Y-sort for actor and furniture/counter front pieces sharing a compatible sorting ancestry. Split a large object into visual back and front pieces where needed, anchored to the same object root. Use fixed `z_index` only for broad layers or fixed rear pieces, not per-state actor fixes. Foreground plants/architecture may use a dedicated overlay where they are always in front. Avoid a single giant counter sprite that cannot occlude locally, hard-coded z-index changes on CoffeeAction, sorting by visual center rather than feet, and detached front occluders that drift when objects move. The lab's F9 probe showed counter and table occlusion reversing as the worker's *feet* cross the respective objects, without actor z changes.

## Data responsibility

| Home | Data |
| --- | --- |
| `.tscn` | Authored room geometry, object instances/transforms, local markers, nav regions, camera, visual layer structure. |
| `.tres` custom Resources | Typed reusable station/prop definitions, interactions/capabilities, footprints, movement profiles, camera/aspect configuration, asset catalog contracts. Do not store per-room object positions here. |
| `TileMapLayer` | Optional repeated floor/wall or future placement-authoring cells when justified; not required by the recommended first implementation. |
| Runtime save | Room ID, stable instance IDs, object state/transforms, occupancy, decoration changes, progress. Version/schema and migration rules required when shipping. |
| JSON | Only when external tooling/interchange genuinely needs it; not the main authored world format. |

## Lab evidence and limits

`scenes/dev/world_architecture_lab_a.tscn` and `scenes/dev/world_architecture_lab_b.tscn` instance the same CounterStation, TableRound, Chair, CatBed, Plant, Entrance, and LabActor scenes. A live GodotAI editor move of the counter/chair in A and table/bed/plant in B was saved. Unit/runtime tests assert local anchors follow moves exactly; both layouts completed customer, worker, and ambient-cat itineraries using the same actor script and semantic queries. Captures under `artifacts/prototype_review/world_architecture_bootcamp_v2/` show distinct layouts and Y-sort probes. All visuals are dev placeholder drawing, not production art.
