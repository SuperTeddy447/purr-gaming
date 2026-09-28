# WilliCat V2 Production Batch 03 — Composition Diagnosis

Status: **CANDIDATE / HUMAN REVIEW REQUIRED**. This is a V2-only registration pass on `scenes/dev/home_v2_environment_preview.tscn`. The default Home, canonical character, gameplay systems, camera configuration and Batch 02 counter solution remain the source of truth.

## Reference and capture source

The task's short reference path `docs/references/home/v2/` is not present in this repository. The authoritative files are the nested paths documented by [WILLICAT_V2_VISUAL_SOURCE_OF_TRUTH.md](WILLICAT_V2_VISUAL_SOURCE_OF_TRUTH.md):

- Primary: `docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_PRODUCTION_STYLE_LOCK_V1.png`
- Secondary: `docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_GAMEPLAY_TRANSLATION_V1.png`

The baseline and all iteration/final evidence were captured from Godot's rendered 941×1672 SubViewport. No screenshots were reconstructed or retouched. Compare `00_before_runtime.png` against `01_iteration_1.png` through `03_iteration_3.png` in the artifact package.

## Before-pass mismatches

The baseline matched the locked architecture, warm lighting and camera, but several modular placements read as a technical staging layout rather than the same composed café:

- Two round tables were visually undersized and their seating did not form complete, legible guest groupings. Seat markers were offset from some chair feet.
- The lower-center table was too small relative to the 941×1672 room and ~150 px worker.
- The right-side cat-life items and spare seating lacked a clear lounge relationship; some read as isolated test objects.
- The left window had no visibly associated cat-watch perch. Entrance planters were unevenly registered to the foreground arch.
- The main, hanging and menu sign surfaces were not registered to the revised wall positions; runtime text rectangles no longer matched their blank panels.
- The pastry display lacked a readable cake prop at the visible shelf level.
- The entrance leaves remained the old simple placeholder, unlike the detailed architectural arch.

The architecture itself, staircase, camera framing and counter assembly were not moved. The open central floor was kept clear for the existing customer/worker routes.

## Iterations

1. **01_iteration_1.png — seating registration:** moved/enlarged the left and lower-center tables, scaled the chairs consistently, added a second left-table chair, and attached all four seat roots to chair floor points. This made the two customer groupings coherent without filling the circulation aisle.
2. **02_iteration_2.png — lived-in right side:** placed the existing cat bed, cushion, basket, scratch post, window perch, stool and small plant as complete floor-contact props under the existing shared Y-sort owner; moved the window-watch anchor to its perch.
3. **03_iteration_3.png — integration cleanup:** balanced the right lounge grouping, aligned signage surfaces to their frames, re-registered entrance plants as a pair, moved the freestanding sign into the entrance-side zone, and raised the cake visual into the pastry-case viewing area. Re-captured after this pass.

The authoritative transform/role list, floor pivots, depth owners and gameplay links are in [home_v2_composition_map.json](../../data/environment/home_v2_composition_map.json).

## Final candidate transforms

| Zone | Registration | Notes |
| --- | --- | --- |
| Service | CounterBack `(465,520)`, CounterFront `(465,625)`, espresso `(402,445)`, grinder `(510,445)`, POS `(314,435)`, pastry case `(658,500)` | Retained the Batch 02 counter and station contract. Cake child is at case-local `(0,-65)`. |
| Left table | table `(250,860)`, chairs / seats `(155,895)` and `(335,900)` | Added only a second instance of the existing chair texture; stable seat semantics A/D retained. |
| Lower center | table `(535,1190)` at 1.38, chairs / seats `(430,1220)` and `(680,1235)` | Both chair scales 1.18; route/circulation lane left open. |
| Right lounge | bed/rest `(775,1045)`, basket `(760,680)`, cushion `(820,1270)`, stool `(760,1120)`, scratch `(895,1040)`, plant `(880,1140)` | Complete separate assets, floor-contact anchored and Y-sorted; these positions are candidates for human review. |
| Signage | main `(372,180)`, hanging `(72,345)`, menu `(725,255)`, freestanding `(805,1530)` | Surfaces remain blank; live copy stays owned by `DynamicSignage`. |
| Entrance | foreground frame remains `(426,1620)`; leaves remain `(426,1506)`; floor plants `(140,1600)` and `(670,1600)` | Entrance architecture and door/spawn semantics were not redesigned. |

## Gameplay anchors and protected behavior

Changed anchors, each because the previous point was not physically registered to its visual affordance:

- `SeatA`: `(225,915)` → `(155,895)`, aligned to the left-table chair.
- `SeatB`: `(445,1230)` → `(430,1220)`, aligned to the lower-center left chair.
- `SeatC`: `(638,1260)` → `(680,1235)`, aligned to the lower-center right chair.
- `SeatD`: `(360,935)` → `(335,900)`, aligned to the added left-table chair.
- `AmbientB`: `(848,800)` → `(100,680)`, so the existing window-watch behavior uses the visible window perch.

The cat destinations `cat_rest_01`, `cat_inspect_basket_01`, `cat_jump_stool_01`, `cat_sniff_plant_01` and `cat_scratch_stretch_01` are colocated with their matching props. `WorkerIdle (620,525)`, `CoffeeAction (402,525)`, `CounterExitRear (165,525)`, `OrderPoint (347,595)`, `ServePoint (100,785)`, customer spawn/exit, route markers, camera config and CounterBack/CounterFront transforms were not changed in this batch.

Counter depth remains `BackDecorLayer z20 < DepthSortedLayer z50 < ForegroundOccluderLayer z80`. Mochi remains a full-body runtime actor. No state-specific z-index was introduced. The existing Batch 02 opaque-front assertion is retained and re-run.

## Scale and depth inspection

Tables are now 1.32 and 1.38 uniform scale in the candidate registration; guest chairs are 1.18. Cat props use explicit maximum bounds and source proportions rather than stretching. Floor props remain complete texture assets with bottom-center contact pivots under `DepthSortedLayer.y_sort_enabled`; entrance plants and frame remain in the foreground occluder owner. No source image was cropped, repainted or altered in this pass.

## Remaining visual differences / regeneration triage

- The modular main sign's current frame is portrait/square, while the locked style master uses a broad, prominent main-sign silhouette. Transform registration improves placement but cannot fix this shape mismatch. **Review as a sign-frame shape candidate**; if the mismatch is confirmed, replace only the main-sign module in a later art task.
- The two entrance leaves remain the older cream blockout inside the now-detailed jade/wood arch. They still function and Y-sort, but the doorway is not yet at the master’s visual finish. **Review as an entrance-leaf module candidate**; do not replace the architecture plate or change door behavior in response.
- The right-side furniture and cat props are separate generated candidates, not an exact pixel recreation of the master. Their scale and clustering need human phone-size review.
- Runtime signage text is dynamic; its surfaces are blank. The master image is a composition/material reference, not a texture pasted over the modular scene.

No whole-environment generation, camera workaround, per-device layout or gameplay adjustment was made. Whether the two frame shapes should be regenerated is left for visual review; there is no confirmed wrong-perspective runtime asset that blocks technical capture.

## Technical verification

The capture harness runs the existing `VerticalSliceController` in MANUAL mode and takes coffee preparation, serving, and completed-return states from that same loop. Composition-focused assertions protect source Home isolation, seat registration, Y-sort ownership, camera bounds, the F6 master toggle and the Batch 02 occlusion stack. Automated results are indexed in `artifacts/prototype_review/home_v2_batch_03/README.md` after capture.
