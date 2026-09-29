# WilliCat Home V3 — spatial layout lock V1

**Status: LOCKED for Environment V3 art authoring; production Home cutover is NOT authorized.** Human review accepted Level Design Pass 01. The canonical starter-room layout is **STAGGERED SALON** in [`scenes/dev/home_v3_level_design_pass_01.tscn`](../../scenes/dev/home_v3_level_design_pass_01.tscn). Its inherited PackedScenes and Godot-authored scene transforms—not this table, a screenshot, or an older concept image—are the spatial source of truth. This lock records the approved baseline and change-control boundary; `tests/test_home_v3_layout_lock_v1.gd` checks its key authored invariants.

## Canonical framing and scope

- World design canvas: 640×1320 Godot world units. Project window override: 540×960, `canvas_items` / `expand`; accepted tall review: 539×1168. The 9:16 screenshot backing texture was 1428×2539 because of desktop stretch; it is not a new authored canvas.
- Room camera: position `(320,650)`, zoom `(1.8,1.8)`, limits `(0,0)–(640,1320)`. Pass 01 dev Brew/Cup review zooms are 3.25/3.45; they are camera **presentation candidates**, not final-device approvals. Focus positions stay on object/actor-owned markers.
- Navigation walkable bounds: `Rect2(25,100,590,1190)`. The room bakes the actual object-owned PhysicalFootprints; no painted-floor shortcut replaces them.
- The canonical starter arrangement is locked. Later player decoration may move eligible furniture **through validated placement**, retaining owner/slot/footprint contracts. That is not permission to silently re-author this baseline scene.

## Stable-object inventory and locked instance transforms

All positions are the root's Godot local position in this scene, in world units; the ancestors currently have no offset/rotation. Rotation is 0° unless noted. Rows 1–17 are the **17 art-bearing world-object instances**. Rows 18–20 are semantic-only waiting objects; this reconciles the earlier handoff's “17 world objects” wording with the actual 20 stable scene instances. `FreeFloorIdle` and `SeasonalDisplayZone` are markers, not world-object IDs.

| # | Stable instance ID | Root `(x,y)` | Spatial relationship / owned gameplay |
| ---: | --- | ---: | --- |
| 1 | `counter_shell` | (160,380) | Back-left service; Order/Serve slots, OrderPoint, ServePoint, front lip |
| 2 | `espresso_station` | (360,350) | Back-right service; CoffeeAction, Brew/Cup focus and FX |
| 3 | `grinder_station` | (485,350) | Adjacent preparation; GrindSlot/FX |
| 4 | `pos_station` | (90,235) | Service wall; POSSlot |
| 5 | `pastry_case` | (245,230) | Service wall; BrowseSlot |
| 6 | `table_a` | (210,700) | First staggered seating island; own table footprint, no seat slot |
| 7 | `chair_a` | (105,795) | First island; own SeatSlot |
| 8 | `chair_b` | (310,795) | First island; own SeatSlot |
| 9 | `table_b` | (445,840) | Second staggered island |
| 10 | `chair_c` | (350,935) | Second island; own SeatSlot |
| 11 | `chair_d` | (545,935) | Second island; own SeatSlot |
| 12 | `cat_bed` | (175,550) | Sheltered left-middle nook; Rest/Sleep and SleepFX |
| 13 | `window_perch` | (515,520) | Signature right-side window corner; WatchSlot/CameraWindowFocus |
| 14 | `plant` | (530,680) | Window/seating edge; SniffSlot |
| 15 | `scratch_post` | (100,985) | Left entry-side transition; Scratch/Stretch slots |
| 16 | `entrance_door` | (320,1165) | Central threshold; Enter/Leave/Story, door FX/focus |
| 17 | `seasonal_display` | (510,1105) | Right-side event niche, off by default; Inspect/FX/focus and active footprint |
| 18 | `waiting_spot` | (235,1060) | Invisible WaitSlot, left-center entry holding |
| 19 | `waiting_spot_b` | (405,1040) | Invisible WaitSlot, right-center entry holding |
| 20 | `waiting_spot_c` | (150,1080) | Invisible WaitSlot, left entry holding |

Other authored markers: `FreeFloorIdle (295,620)`, `SeasonalDisplayZone (510,1060)`, `CrossTableTarget (315,700)`. The six placeholder actor starts and their runtime movement are **not** environment sprite placement contracts. The five service items remain separate interactive PackedScene instances inside `CounterServiceZone`, even when art makes them look like one operation.

## Circulation and clearances

- Keep the door threshold and central entry-to-order lane visibly open. The door currently has no obstructing navigation footprint; future door art may not add a solid collider across its passable threshold. Three WaitSlots spread holding space without visible queue rings. Entrance/OrderPoint capacity and fifth-customer seating contention were proven by the 1-worker/5-customer/3-cat sanity run; this is not a full queue-system approval.
- Preserve the two staggered table/chair groups and their chair-owned seat approaches. Their actual footprints are the obstruction truth: each table 108×80, each chair 48×28. Maintain navigable gaps around both islands, not a single continuous furniture wall. Final art may overhang *visually* only after full-height silhouette, tap and occlusion review; it may not make the walkable route appear closed.
- Service must read as one workflow: counter/order/serve left, POS/Pastry on the back wall, Espresso/Grinder adjacent right. Do not merge their gameplay ownership or relocate CoffeeAction to fit an illustration. CounterShell footprint 224×55, Espresso 73×45, Grinder 48×35, POS 58×30, Pastry 88×32.
- Cat activities are interwoven: bed near first table, perch/plant at the window and scratch beside the left transition. Keep cats and customers simultaneously readable. The signature window and sheltered bed are camera-sensitive, not empty decor zones.
- Event niche stays to the right of the entrance lane. `seasonal_display` contributes a 53×28 footprint only while active. Seasonal silhouettes and FX must fit the designated area and keep the door/WaitSlots/service path accessible. Event OFF still needs a complete-looking base café.

## Ownership, depth and camera rules

Every object keeps its stable ID, floor-contact root, owned `InteractionSlot` approach/action/exit anchors, PhysicalFootprint/collision, and its own camera/FX children. Moving an eligible object moves those children together. Espresso owns Brew/Cup/Steam/CupSpawn anchors; CounterShell owns Order/Serve; chairs own seats; bed owns Rest/Sleep; door owns threshold semantics; EventLayer owns the event object. The room—not art pixels—owns instance transforms, navigation, camera bounds and event activation.

Floor-contact origins participate in the existing Y-sort ancestry. CounterShell's separate `VisualFrontOccluder` remains necessary; table/chair/bed front/back splits are permitted when justified. Do not solve depth with action-specific actor z-index changes or a full-screen foreground painting. CameraDirector owns temporary focus and restores the gameplay camera. Runtime signage and FX attach to authored surfaces/markers rather than becoming baked text or emitted from guessed pixels.

## Change control after lock

**Frozen without explicit layout re-review:** this starter scene's major root transforms/table topology, entrance and main circulation, service workflow, signature window/bed/event locations, stable IDs, slot/footprint/camera/FX ownership, camera family and scene-derived spatial authority. A final sprite that forces a slot or footprint move is a failed asset, not an automatic layout change.

**Artistically flexible within contract:** object-local alpha canvas and transparent padding, visual silhouette within an approved reviewed envelope, micro-alignment that does not move floor root/slot, room-base trim/material/lighting, textiles, small decor, foliage, signage surfaces, subtle front/back splits, FX skins and time/season variants. Movable furniture needs a full valid-placement and navigation recheck wherever its *runtime* placement changes. Real-device visual/performance approval remains a later gate.

Evidence: [`Pass 01 review pack`](../../artifacts/prototype_review/home_v3_level_design_pass_01/README.md) and [`layout-lock review notes`](../../artifacts/prototype_review/home_v3_layout_lock_v1/README.md). No production Home scene or final art changes are part of this lock.
