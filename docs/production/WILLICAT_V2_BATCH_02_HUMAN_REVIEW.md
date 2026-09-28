# WilliCat V2 Batch 02 — human visual-lock review

This is a candidate/QA package, not a final visual lock. Open the real-viewport images in [`artifacts/prototype_review/home_v2_batch_02/`](../../artifacts/prototype_review/home_v2_batch_02/README.md), especially `01`–`07`. The V2-only CoffeeAction/idle/rear-waypoint correction is documented in `WILLICAT_V2_BATCH_02_COUNTER_OCCLUSION_DIAGNOSIS.md`; the mobile cost table is in `WILLICAT_V2_TEXTURE_MEMORY_AUDIT_V1.md`.

## Requested review questions

1. **Behind counter?** `01`, `02`, `04`, and `06`: Mochi's head and upper apron remain visible while lower body/feet/shadow are behind CounterFront. Technical `03` displays the actual front alpha line and foot/root position. Accept the amount of occlusion, or mark for a later visual registration pass.
2. **Physical occlusion?** `03`: the front silhouette reaches the worker's floor root; CounterBack remains below the character and CounterFront above it. No character z-index or cropped sprite workaround was added.
3. **Enter/leave transition?** Compare `04` → `05` → `06` → `07`. The left edge exposes the whole character while exiting and occludes again while returning. Still review motion in a running build if available; static captures cannot prove every intermediate frame.
4. **Viewport coverage?** `08`–`13` cover 9:16, tall phone, 3:4, desktop and both extreme max-zoom pan directions. No blank/transparent renderer strip was seen in these representative captures. Intentional cropping of the painted room at viewport edges is visible. This does not mathematically exhaust every continuous pan coordinate/device size.
5. **Complete edge assets?** All 19 packaged prop sources have no alpha >0.5 on their outermost source row/column; runtime files retain 16 px top/left/right safety padding, with bottom-touching floor-contact pivots where applicable. `05`, `09`, `12`, `13` show right furniture, beds, plants, tables, and entrance framing under pan/crop. Source objects are intact; camera cropping is intentional. The architecture is a full opaque canvas, not a cutout prop.
6. **Mobile texture cost?** 20 runtime PNGs total ~23 MiB on disk / 90.76 MiB estimated RGBA8 decoded if simultaneously resident. Most props are substantially over gameplay display size, so selective smaller runtime derivatives are worth a later device-profiled pass. No import/compression change was made here.
7. **Regeneration candidates?** No obvious broken source, missing edge, or incompatible counter perspective justified regeneration in this batch. `REGENERATE`: none on technical evidence. Judge the polish-later items below at full gameplay scale before approving art lock.

## Individual visual-style triage

The playable 19 semantic slots were reviewed together in Godot captures. These statuses are art-review triage, not approval of final art. Unplaced P1 props were inspected as their existing runtime/source cutouts, so their style fit in the actual scene remains pending. Matte jade/brass and warm architectural light are broadly coherent; the main contrast is the still-placeholder customer cats/door/labels, which are outside this targeted V2-art correction.

| Texture | Status | Note |
| --- | --- | --- |
| architecture | PASS | Warm world perspective and coverage in captured profiles. |
| counter | PASS | Worktop/corner register with front; glossy brass is noticeable but consistent with other fixtures. |
| counter_front_occluder | PASS | Correct physical occlusion after floor-marker correction. |
| espresso | PASS | Readable at current slot scale; fine details deserve mobile-size review. |
| grinder | PASS | Fits equipment palette/perspective. |
| pos | POLISH LATER | Very small in play view; interaction readability, not source completeness. |
| pastry_case | POLISH LATER | Legible outline; contents/signage detail may need later mobile readability pass. |
| table_round | PASS | Repeated tables use same source and read as complete objects. |
| chair_jade | PASS | Consistent jade furniture; small at default framing. |
| stool | POLISH LATER | Packaged P1 cutout, not placed in current view. |
| signage_blank | POLISH LATER | Intentionally blank dark field can read as placeholder. |
| plant_floor | PASS | Reused intact at edges. |
| plant_small | PASS | Reused intact around station. |
| flower_vase | PASS | Coherent small table accent; tiny details at default scale. |
| cat_bed | PASS | Complete woven rim; visible at right. |
| cat_inspection_basket | POLISH LATER | P1/unplaced; in-scene perspective pending. |
| cat_rest_cushion | POLISH LATER | P1/unplaced; in-scene perspective pending. |
| cat_scratch_post | POLISH LATER | P1/unplaced; in-scene scale pending. |
| cat_window_perch | POLISH LATER | P1/unplaced; edge/world placement pending. |
| cake_set | POLISH LATER | P1/unplaced; food readability in scene pending. |

## Cautions before lock

- The corrected rear corridor at y=525 is visually plausible, but the exact amount of lower-body hiding is a human art decision. Do not mark final solely from automated geometry checks.
- The `12` extreme pan capture includes two close placeholder customer/cat silhouettes near the right bed while the next prototype cycle starts. That is existing prototype behavior in an edge-state capture, not an art repair and not evidence of a source-image defect.
- Default gameplay captures still include prototype HUD and placeholder customer/entrance visuals. They were deliberately not polished or hidden for this QA batch.
- The stale Mochi scale test was changed only to expect CameraRig's already-locked effective-minimum clamp: request `1.2`, expect `max(1.2, effective_min_zoom)` (currently about `1.2195` on 941×1672/normalized profile). Camera logic and scale values were not changed.
