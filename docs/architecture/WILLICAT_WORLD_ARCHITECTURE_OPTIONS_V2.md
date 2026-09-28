# Three viable WilliCat world architectures V2

These are production candidates, not a forced ranking. All can keep the current coffee loop as a behavior specification. Scores are qualitative; a small production spike must validate mobile performance and authoring cost before migration.

## A — Authored room/zone scenes composed of freeform PackedScene objects

Each café/room is a `.tscn` with a `WorldRoot`, architecture, level-owned `NavigationRegion2D`, object instances, characters, foreground, FX, signage, and camera. Furniture/stations own their local collision and semantic anchors; the room owns transitions and shared routes. `NavigationAgent2D` supplies continuous paths; a semantic resolver maps roles/IDs to current anchor transforms. Decoration can later gain an invisible placement grid without moving the rendered art to cells.

This is idiomatic for illustrated, bespoke rooms. Artists and designers can move object roots in the editor and see anchors follow. Many cafés reuse object scenes and generic behavior. Main costs: navmesh authoring/rebaking when collision changes, placement validation, and careful scene ownership/versioning. Hundreds of unique object nodes may need profiling on mobile; room partitioning and visibility management help. AI/GodotAI can inspect and move meaningful scene instances, but must not bypass scene ownership or undo discipline. Migration is incremental through adapters, although replacing global markers still needs rigorous regression tests.

## B — Invisible rectangular/isometric logical grid with freeform illustrated objects

A room owns deterministic cells for placement, reservations, occupancy, and perhaps AStarGrid2D pathing. Rendered object scenes remain freeform with authored local offsets and anchors. The grid is **gameplay-only**, never a visible pixel-tile aesthetic. This is strong for user decoration, furniture rotation, reliable save/load, and many café variants. It can also make mobile path queries predictable.

Its hard problem is keeping grid cells, oversized irregular footprints, elevated 3/4 art, collision, and rendered anchors synchronized. Cat wander can use grid paths while station approaches still require local semantic anchors. Designers would need a grid overlay/placement validator and rules for non-cell scenery. GodotAI can author object instances, but must also validate cell occupancy; artists can freely paint visual layers while engineering maintains grid contracts. Migration is medium/high because existing freeform positions need cell assignments. Long-term maintenance is good if decoration is central, but it adds another authoritative coordinate system and must not be introduced casually.

## C — TileMapLayer-authored architecture plus PackedScene interactables

Use TileMapLayer/TileSet for floor, walls, repetitive collision/navigation, and a clear grid. Place counters, furniture, beds, doors, characters, and special illustrated set pieces as scene instances with local anchors. This scales well to many map variants and makes collision/nav painting efficient. Painted cells have compact storage and can be friendly to mobile when atlases are used; scene tiles should be limited to objects needing behavior.

This option is a strong fit if future cafés have repeated architectural motifs or large walkable maps. It can still show premium illustrations over a hidden or subtle tiled foundation, but unusual perspective and large bespoke art need registration rules and may make tile editing less artist-friendly. GodotAI can manipulate scene instances and inspect TileMapLayer, though tile painting/TileSet editing automation needs its own proof. Existing Home art would require floor/wall decomposition and tile metrics, so migration is highest. Maintenance is excellent for repeated map geometry but there are two authoring surfaces: painted architecture and object scenes.

## Comparison

| Criterion | A: freeform object rooms | B: hidden grid + objects | C: TileMapLayer + objects |
| --- | --- | --- | --- |
| Godot-native fit | Excellent (`PackedScene`, room navmesh) | Good (scene + custom grid/AStarGrid2D) | Excellent (`TileMapLayer`, TileSet, scenes) |
| Illustrated-art freedom | Highest | High, with cell/offset reconciliation | Medium/high; unique overlay art remains freeform |
| Designer level authoring | Direct editor transforms | Cells + object transforms, validator required | Fast painting + instance placement |
| Navigation | Navmesh + semantic endpoints | Grid paths + local endpoint bridges | Tile/nav layers + semantic endpoints |
| Multiple cafés | Reuse room template and objects | Reuse objects/grid rules; data-driven variants | Paint variants efficiently |
| Future decoration | Needs optional placement rules/grid | Strongest native model for placement | Strong if decorations snap to tile footprint |
| Mobile performance | Profile node counts/nav baking; zone loading | Predictable grid; still render many scenes | Efficient atlas tiles; scene-tile count matters |
| AI/GodotAI workflow | Meaningful hierarchy and simple transforms | Must author/validate two coordinate views | Tile editing API proof still needed |
| Artist friendliness | Highest for bespoke composition | High visual freedom, grid registration cost | High for repeated maps, lower for one-off painterly geometry |
| Home migration | Lowest, still nontrivial | Medium/high | Highest |
| Long-term maintenance | Strong if IDs/validation/nav are disciplined | Strong if placement system is core product | Strong if map grammar is repeatable |

Recommendation: A now, with an optional *invisible* B-style placement grid if decoration becomes an approved feature. Do not choose C until actual map-production evidence shows repeatable TileSet-compatible architecture. This choice optimizes the current premium illustrated café and editor-authored composition, not merely migration ease.
