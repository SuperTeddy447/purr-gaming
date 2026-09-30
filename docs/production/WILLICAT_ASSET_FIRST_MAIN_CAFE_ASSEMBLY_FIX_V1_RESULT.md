# WilliCat asset-first Main Café assembly fix V1 — result

Status: **dev café visually assembled and playable**. The edited room is `res://scenes/dev/playable_placeholder/main_cafe.tscn`; production Home V3 and the project main scene were not changed. No environment image was generated or regenerated for this pass.

## A01–A10 scale calibration

World sizes below are approximate visible bounds, measured from source pixels with alpha ≥ 128 (the floor fills its full canvas). `offset` is local to the semantic object root. The base line is the visible lower edge, not the physical footprint or interaction slot. The generated images retain their original high-resolution files; Godot scales them for play.

| Asset | Source px | Visible source bbox `(left,top,right,bottom)` | Runtime scale | Visible world size | Visual offset / pivot | Visible base |
| --- | ---: | --- | --- | ---: | --- | --- |
| A01 wood floor | 1254×1254 | full canvas | TextureRect `0.18` | 226×226 per repeat | top-left `(0,0)` | room surface `y=0–1000` |
| A02 cream/jade wall | 1536×1024 | `(170,21,1371,998)` | `(0.52,0.32)` | 625×313 | scene center `(320,157)` | wall lower edge `y≈313` |
| A03 counter | 1536×1024 | `(48,159,1489,944)` | `0.28` | 403×220 | counter root +`(130,30)` | `y≈336` |
| A04 pastry case | 1312×1199 | `(81,14,1238,1190)` | `0.10` | 116×118 | pastry root +`(0,-60)` | `y≈294`, near root `y=295` |
| A05 espresso | 1312×1199 | `(17,6,1303,1194)` | `0.085` | 109×101 | espresso root +`(0,-30)` | `y≈203`, on the bar work surface |
| A06 round table | 1278×1230 | `(148,90,1132,1114)` | `0.11` | 108×113 | table root +`(0,-56)` | ≈1 above root |
| A07 chair | 1230×1278 | `(173,73,1121,1207)` | `0.065` | 62×74 | chair root +`(0,-35)` | ≈2 below root |
| A08 cat bed | 1536×1024 | `(128,88,1411,945)` | `0.075` | 96×64 | bed root +`(0,-32)` | at root |
| A09 scratch post | 1224×1285 | `(317,74,908,1205)` | `0.065` | 38×74 | post root +`(0,-35)` | ≈2 below root |
| A10 potted plant | 1151×1367 | `(172,97,1049,1216)` | `0.07` | 61×78 | plant root +`(0,-40)` | ≈3 above root |

The existing dev actor is about 60 world pixels tall. A06/A07 now read as appropriately sized furniture beside it. A02 uses separate horizontal and vertical scale so one wall module spans the 640-world-pixel room without descending into the seating area. POS and grinder use the project’s existing Home V2 isolated textures: POS ≈50×54 world pixels and grinder ≈37×89. The entrance and garden door use a small object-owned drawn placeholder.

## Assembly and gameplay boundaries

- A01 is repeated in a Godot `TextureRect` at `0.18` texture scale, about 226 world pixels per square tile, across the 640×1000 floor. The source image is not stretched into one room-sized board. Floor contrast is reduced slightly for character and interaction readability. The wood-tile option is enabled only on Main Café; Back Garden retains its prior floor behavior.
- The service zone runs from the left POS through counter, espresso and grinder to the right pastry case. The counter is one visual child of `CounterShell`; espresso and grinder bases sit at the back work surface, while the pastry case fronts the customer end. Worker start and `WorkerIdle` were aligned behind the bar; the worker’s *drawing* has a local downward offset of 35 pixels. Its collision and interaction positions remain owned by the actor and slots.
- Seating group A: TableA `(175,455)` with ChairA/B `(110,530)` / `(245,530)`. Group B: TableB `(455,560)` with ChairC/D `(385,635)` / `(525,635)`. Their same stable IDs, reusable PackedScenes, seat slots, footprints and save-delta behavior remain.
- The cat area is on the lower left: Plant `(205,700)`, CatBed `(100,790)` and ScratchPost `(220,805)`. The center approach from Entrance `(320,910)` stays open.
- Primitive object visuals are suppressed when an object has a `RuntimeVisual` child. Node IDs and actor names are visible only in Godot debug mode. Physical footprints still have their original debug-only drawing. The new door drawing is owned by each existing portal object.
- Y sorting remains on `DepthSortedLayer`, with no global actor z-index override. The counter image is owned by its root, so the worker draws behind its front while the customer approaches from the front. Chair seating and counter service were captured during actions for occlusion review.
- The portrait camera family is unchanged. Main Café opts into an assembly-specific zoom profile; Back Garden retains the original profile. At the project’s logical viewport, café overview is zoom `2.048`, default `2.171`, and service focus `2.499` around `(335,410)`. The three real 540×960 captures show each framing.

Object IDs, room IDs, `InteractionSlot` resources/markers, collision and footprint sizes, navigation ownership, save schema, coffee/customer loop, and room transition code were not rewritten. The authored locations of POS, grinder, pastry case and furniture moved within this dev room; the existing navigation bake and persistence test cover the new positions.

## Rendered evidence

All PNGs were captured from Godot 4.7.2 using the Metal renderer, with the HUD hidden for visual assessment. The three post-loop views have no room labels or object IDs:

1. [Default gameplay](../../artifacts/prototype_review/asset_first_main_cafe_assembly_fix_v1/01_default_gameplay.png)
2. [Overview](../../artifacts/prototype_review/asset_first_main_cafe_assembly_fix_v1/02_overview.png)
3. [Service focus](../../artifacts/prototype_review/asset_first_main_cafe_assembly_fix_v1/03_service_focus.png)

Additional evidence: [before assembly](../../artifacts/prototype_review/asset_first_main_cafe_assembly_fix_v1/00_before.png), [counter service occlusion](../../artifacts/prototype_review/asset_first_main_cafe_assembly_fix_v1/04_counter_occlusion.png), and [seat occlusion](../../artifacts/prototype_review/asset_first_main_cafe_assembly_fix_v1/05_seat_occlusion.png).

Regenerate the five final captures with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/teddywoot/willi-cat --resolution 540x960 --script res://scripts/dev/playable_placeholder/asset_first_assembly_capture.gd
```

## Verification and remaining art limits

`tests/test_playable_placeholder_reset_v1.gd` passes with the assembled scene: café visit/reward, repeated loop, chair movement/rollback, room transition, garden cat action, and furniture/save restoration. The capture run completed the visit and wrote all five final images at 540×960. `git diff --check` passes. No commit or push was made.

This is a dev assembly candidate. The generic actor drawings, the code-drawn doors and the existing Home V2 POS/grinder are placeholders for later approved production art. The chair asset is a single sprite, so a future seated-character pass may split its front edge for finer occlusion. The A01 source is repeated by Godot, but its original edge pixels were not repainted into a mathematically exact seamless tile.
