# Asset-first world assembly plan V1 — research handoff

Status: **next proof planned, not executed**. Base is `scenes/dev/playable_placeholder/playable_world.tscn`, with `main_cafe.tscn` and `back_garden.tscn`. Do not create a new abstract sandbox or edit production Home V3.

## Exact visible-placeholder audit

Read from the scene instances and their current primitive drawing scripts (`placeholder_floor.gd`, `HardeningWorldObject._draw`, and actor/FX scenes). A production visual is not a license to move the gameplay node.

| Current visible object | Category | Replacement form / unchanged contract |
|---|---|---|
| Main Café and Garden Floor, café north wall/room outline | Architecture | Neutral repeatable floor finish and wall/shell modules or room-owned surface art; match current room bounds. No baked furniture, door, sun/shadow or collision. Garden needs its own ground finish. |
| Entrance, BackDoor, GardenDoor | Architecture / portal | Reusable doorway/leaf visual scene attached to existing door object and portal target; retain threshold, tap and transition semantics. |
| CounterShell | Café facility / structure | Object-scene visual with back/work surface and front occluder; preserve `WorkerIdle`, order/serve slots, depth and footprint. |
| EspressoStation, Grinder, POS, PastryCase | Café facility | Separate prop/station visuals under their existing object scenes; preserve `work_coffee`/inspection slots, contact pivot, touch regions and independent identities. No baked integration into counter art. |
| TableA/B | Furniture | One reusable table visual/definition with stable floor pivot and existing footprints. Both instances use same definition; preserve movement and route gates. |
| ChairA–D | Furniture | One reusable chair visual/definition plus controlled facing variants; retain seat/approach anchors and each instance ID, occupancy and save deltas. |
| CatBed, ScratchPost | Cat-life | Reusable bed/post assets with rest/scratch slots, footprint and contact origin. |
| Plant | Decor / cat-life | Isolated planter sprite/scene; retain sniff slot if it has one and its obstruction footprint. |
| Garden Bench (`CatBed` instance), PlantPatch and CatSniff (`Plant` instances), CatRest (`CatBed` instance) | Outdoor/cat-life | Later give bench and garden plants *visual variants* and clear catalog IDs while preserving their existing reusable slot behavior. `CatRest`/`CatSniff` are semantic destinations on object instances, not loose coordinates or mandatory visible markers. |
| SunSpot | Outdoor/activity zone | Soft runtime-local light/decal/FX or temporarily invisible activity zone; keep `SunSlot` anchors. Do not bake a permanent sunny patch into garden ground. |
| Worker, Customer, Cat | Character | Separate approved character visual/animation pipeline; leave actor movement/slot handling intact. Do not include them in furniture batch. |
| CarryCup, OrderBubble, steam, reward label, HUD | Feedback/UI/FX | Separate FX/UI production; prototype visuals remain during first asset proof. HUD stays CanvasLayer and is not room art. |

Scene-owned `Spawns`, camera and navigation are logical systems, not visual props to replace. The audit covers the current two-room placeholder, not all future world content.

## Smallest next proof: ASSET-FIRST VISUAL REPLACEMENT PASS V1

1. Inventory project-owned candidates first, especially `assets/environment/home_v2/` (counter, table, chair, plant, cat bed/scratch post, equipment). Existing runtime files are **candidates**, not automatically legal-for-final or perspective-compatible; verify their provenance, dimensions, style and license before use. If no coherent legal set fits, select one external pack only after capturing its exact license and use scope. Do not copy Godot Valley assets.
2. Register a tiny catalog slice: one floor finish and wall finish; one CounterShell; one TableA/B definition; one ChairA–D definition; one Plant; and either CatBed or ScratchPost. Keep Espresso/Grinder/POS/Pastry and all other placeholders for visual contrast, unless a required occlusion mask needs the existing counter layers. This is not a whole-room restyle.
3. Place approved visual children into the **existing** object PackedScenes or a non-destructive dev-scene variant. Preserve object root transforms, stable instance IDs, slot marker local transforms, footprints, collisions, y-sort and room bounds. Use floor-contact pivots. Document any art whose silhouette cannot fit the existing footprint instead of moving gameplay to hide it.
4. Capture before/after at identical default/zoom/pan framing, including behind/in-front counter and table, both rooms and the garden door. Produce a visual contact sheet/camera-scale preview from actual Godot viewport; inspect on a phone if available.
5. Run existing playable-placeholder tests and regression set, plus explicit assertions that slot global positions, object root transforms, required navigation routes, room travel, café loop/reward, save/load placement deltas and camera limits are unchanged. Test moving an updated chair and reloading its saved position. Any altered gameplay requires rejection or a separate approved task.
6. Human art gate: approve only the candidates that read as one kit at default and max zoom, keep Mochi/customer visible, do not hide interaction feedback, and maintain counter/table/door occlusion. Mark `CANDIDATE` until review; no automatic `FINAL`.

Existing systems reused unchanged: `PlaceholderWorld` room host and save, `PlaceholderRoom` placement validation/nav, `PlaceholderCafe` loop, `HardeningWorldObject` identity/capacity, `HardeningInteractionSlot`, `HardeningNavigation`, generic actor behavior, `HardeningCameraDirector`/`PlaceholderCameraInput`, room portals, HUD and reward receipt handling. This plan authorizes no current code edits.

## Production boundaries and risk

AI image generation remains useful for isolated prop/character/animation candidate art, small décor/texture variants and material exploration under a kit contract. It is **not** allowed to define room coordinates, navigation, object ownership, door thresholds, whole-room geometry, shadows tied to movable objects, or a single composite café image as spatial authority. A polished image is never a substitute for slot/footprint validation.

The major open risks are perspective mismatch between existing Home V2 assets and the new placeholder room, inconsistent pixel density at zoom, missing provenance on older assets, counter-front visual split and mobile memory/draw cost. Report these with captures; do not silently redesign the layout. A later decision may reject a particular asset without rejecting the asset-first architecture.
