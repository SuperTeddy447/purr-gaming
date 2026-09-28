# Home V2 production asset breakdown — Batch 01 candidate

Status: **CANDIDATE / HUMAN REVIEW REQUIRED** (2026-09-28). The V2 preview is an inherited playable Home scene; the 17 original stable asset IDs, camera, routes and layered ownership remain the source of truth. See `data/environment/home_v2_asset_manifest.json` for per-asset runtime dimensions, pivot, source hash, QA record and integration status.

## P0 generated and Forge-packaged

| Asset | Ownership / assembly | Human review |
| --- | --- | --- |
| `architecture_home_v2_01` | StructuralBase full canvas, top-left | Fixed room skin only; doorway/frame composition and missing world overscan require review |
| `counter_home_v2_01` | BackDecorLayer / CounterBack; independent of station props | Worktop registration against foreground panel |
| `counter_front_occluder_home_v2_01` | ForegroundOccluderLayer / CounterFront; no character z override | Critical: current art does not convincingly hide Mochi's lower body at CoffeeAction |
| `espresso_home_v2_01`, `grinder_home_v2_01`, `pos_home_v2_01` | Separate BackDecorLayer semantic slots | Mobile-size readability; metallic highlights appear brighter than matte style lock |
| `pastry_case_home_v2_01` | Separate case shell; existing pastry slots retained | Empty case, glass transparency and overlap with menu sign |
| `table_round_home_v2_01`, `chair_jade_home_v2_01` | Existing DepthSortedLayer slots; existing seat coordinates untouched | Furniture reads small versus the large open floor; judge in playable camera |
| `cat_bed_home_v2_01`, `cat_rest_cushion_home_v2_01` | New cat-life candidate props | Bed placed only in preview; cushion unplaced pending layout review |
| `plant_floor_home_v2_01` | Existing foreground plant slots | Compare foliage scale and repeated-instance appearance |

Architecture, CounterBack and table each had two generated candidates. Their first source images remain immutable; `source_v2.png` is selected for Forge. All selected P0 images passed technical alpha/edge/pivot packaging. This does **not** mean visual approval.

## P1 generated and Forge-packaged

`stool_home_v2_01`, `cat_inspection_basket_home_v2_01`, `cat_scratch_post_home_v2_01`, `cat_window_perch_home_v2_01`, `pastry_set_home_v2_01`, `cake_set_home_v2_01`, `plant_small_home_v2_01`, `plant_hanging_home_v2_01`, `flower_vase_home_v2_01`, `signage_blank_home_v2_01`.

The basket is placed only in the V2 preview and is a semantic story destination. Small plant, vase and blank sign use existing slots. The stool, scratch post, window perch and cake have runtime candidate packages but no final placement. Pastry-set and hanging-plant source images have visible generated ambient halos: they are retained in provenance/Forge output but **not copied into runtime assets or integrated**. Signage is blank art; existing runtime text surfaces remain separate.

## Packaging contract

Source: `docs/source_assets/environment/home_v2/<asset_id>/source_vN.png`, protected by parent `.gdignore`. Each folder has `provenance.json` and a preserved `forge_qa.json`. Forge's `build-static` command emits an unchanged-source hash, technical QA metadata, and a candidate PNG in `tools/willicat_asset_forge/output/home_v2/<asset_id>/`. Selected candidates are copied to `assets/environment/home_v2/`; no source is overwritten. Alpha threshold is 16 and padding is 16px for standalone props. Contact pivots are bottom-center; wall/counter-back/full-canvas pivots are explicitly recorded. Forge QA catches source-edge clipping but not style, mobile readability or counter compositing.

## Remaining art/scene contracts

- P0/P1 textures remain CANDIDATE, not FINAL. Per-asset exact prompt text was not persisted by the image generator; provenance records the generation intent and source hashes, without falsely claiming a verbatim prompt.
- Full-canvas architecture is 941×1672, with no proven world overscan. Do not expand camera bounds solely to hide this.
- Door leaves retain existing V1 placeholder art and controller. A matching V2 door-leaf asset was not generated in this batch; the open door frame/leaf mismatch is visible.
- Existing character placeholders remain placeholders, not V2 feline production art.
- Cat-life anchor positions are semantic candidates, not approved furniture layout. The existing Living Café agent/reservation controller is reused; no second AI loop was added.
