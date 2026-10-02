# WILLICAT HYBRID 3D CAFE ASSET KIT V1 RESULT

## Decision and scope

Human LIVE HYBRID direction preference: accepted as the direction for this isolated slice. Kit visual/playable approval: **PENDING**. Production migration/publication: **NOT AUTHORIZED**. Agent technical/visual self-QA passes the DEV presentation checks; it does not establish human art acceptance or Hero-reference equality.

## Implementation

| Item | Delivered |
|---|---|
| Blender | 5.2.1 LTS, `9e2066aef7ef`, `/Applications/Blender.app/Contents/MacOS/Blender` |
| Calibration | Tiny table .blend → GLB → Godot native render before family; 10 checks passed |
| Family | 27 editable sources, 27 GLBs, 27 wrappers; additional calibration source/GLB, material library and catalogue sources |
| Source | `assets_src/3d/cafe_kit_v1/` |
| Runtime DEV assets | `assets/dev_review/hybrid_cafe_kit_v1/` |
| Builders | `tools/willicat_hybrid_cafe_kit/blender_build.py`, `blender_catalog.py` |
| Shared look | 15 materials; five reused unchanged 512×512 painted albedos; no new image generation |
| Scene | `scenes/dev/hybrid_cafe_kit/hybrid_cafe_asset_kit_v1.tscn` |
| Open | `tools/willicat_hybrid_cafe_kit/Open_Hybrid_Cafe_Kit.command` |

| Family | Count | Assets |
|---|---:|---|
| architecture | 9 | Wall_Cream_A, Wall_Window_A, Beam_Cedar_A, Post_Cedar_A, Window_Recess_A, Window_Sill_A, Entrance_Open_A, Trim_Cedar_A, Floor_Section_A |
| counter | 3 | Counter_Straight_A, Counter_End_A, Counter_Short_A |
| service | 4 | Espresso_A, Grinder_A, POS_A, Cup_Saucer_A |
| furniture | 2 | Table_Round_A, Chair_A |
| decor | 9 | Shelf_A, Shelf_Short_A, Planter_Floor_A, Planter_Table_A, Ceramic_Jar_A, Lamp_Hanging_A, Lamp_Wall_A, Sign_Blank_A, Cat_Cushion_A |

## Geometry/material upgrades and self-QA

Authored recessed/outlined counter panels with genuine thick tops; recessed shoji window and sill; actual open arch registered to canonical 64-unit entrance; physical shelves/brackets, softened cedar rails; rounded lathed table rim/pedestal/splayed base; frame/backrest/seat chair; hollow pottery, service controls and cup/coffee shapes; separated layered foliage mass; mountable lamps and cat cushion.

Close-ups exposed collapsed table UVs from mismatched UV layer names at mesh joining. Corrected before final evidence; final checks verify painted surface UV coverage as well as array count. Cabinet posts were inset into authoritative solid width/depth; pastry support fits its existing footprint. Lower and upper shelving stop before the existing garden aperture. No opaque cabinet spans a navigable service gap.

Agent inspection: cedar/plaster/fabric share their material families; true counter/table/seat volume, bevels and original orange cat remain readable at gameplay scale. Feet remain floor-registered, subtly grounded, with depth-tested front/back occlusion. Compared with the primitive feasibility spike, authored recesses, silhouettes and painted texture response are materially richer. Remaining Hero gap: foliage is simpler, equipment and ceramics have less authored richness, foreground planting/architectural density is restrained, and the full inherited floor footprint remains spacious. Those limitations are explicit; final art preference belongs to the human.

## Lighting and cat

One soft directional + ambient + one small unshadowed practical; no cinematic effects or bake. Exact existing illustrated cat clips are AnimatedSprite3D, ambient-tinted rather than strongly relit, with separate contact shadow. Original worker and active customer are also projected. Fixed orthographic portrait elevated 3/4 camera. Seven real navigation targets and the original coffee service/reward loop execute; no manual depth swaps, independent 3D collision or new nav.

## Evidence and tests

Native Godot DEV proof: **310 checks PASS**. Four independent raster-layer occlusion comparisons PASS (counter behind/front and table behind/front); geometry/sprite depth testing is also checked directly. Calibration: 10 PASS. Launcher: 9 PASS. Native screen-click navigation: 5 PASS. Existing regression results are listed in `diagnostics/regression_summary.json` with copied run logs. Counts are execution evidence, not visual scores.

| Evidence | Purpose |
|---|---|
| [01_BLENDER_ASSET_KIT.png](../../artifacts/prototype_review/hybrid_3d_cafe_asset_kit_v1/01_BLENDER_ASSET_KIT.png) | Actual Blender catalogue of all 27 pieces; floor shown at catalogue .20 scale, others source scale |
| [02_GODOT_HYBRID_CAFE_FULL.png](../../artifacts/prototype_review/hybrid_3d_cafe_asset_kit_v1/02_GODOT_HYBRID_CAFE_FULL.png) | Native full playable café |
| 03_COUNTER_CLOSEUP.png | Panel/service material and geometry |
| 04_TABLE_CHAIR_CLOSEUP.png | Furniture proportions and painted UVs |
| 05_WINDOW_ARCHITECTURE_CLOSEUP.png | Recessed window, shelves and architecture |
| 06_CAT_GROUNDED.png | Original cat feet/contact/readability |
| 07_CAT_BEHIND_COUNTER.png | True geometry occlusion |
| 08_CAT_FRONT_COUNTER.png | Cat visible in front |
| 09_GAMEPLAY_SCALE.png | Portrait gameplay-scale presentation |
| [WILLICAT_HYBRID_3D_CAFE_ASSET_KIT_V1.mp4](../../artifacts/prototype_review/hybrid_3d_cafe_asset_kit_v1/WILLICAT_HYBRID_3D_CAFE_ASSET_KIT_V1.mp4) | Actual moving cat route, VFR from measured capture timestamps |

All evidence resides in `artifacts/prototype_review/hybrid_3d_cafe_asset_kit_v1/`. It is labelled DEV proof, not Factory canonical integration approval. Exact source/runtime recipe hashes are in `diagnostics/toolchain_and_artifact_receipt.json`.

## Measured complexity / mobile risk

| Indicator | Observed native slice |
|---|---|
| Device/backend | Apple M2 Pro, Metal 4.0 / Forward Mobile, Godot 4.7.2 |
| Geometry mesh instances | 69 |
| Geometry triangles | 112328 |
| Geometry material surfaces | 235 |
| Shared material resources | 15 |
| Original reusable geometry textures | 5 × 512×512 |
| Geometry transparent surfaces | 0; foliage is opaque double-sided modeled leaf ribbons |
| Illustrated cat sprites / contact sprites | 3 / 13 |
| Lights / shadow lights | 2 / 1 |
| Mean rendered draw calls | 161.0 |
| Mean rendered primitives | 130678.0 |
| Mean engine process time | 25.39 ms, 180 warmed desktop samples; not GPU time or mobile FPS |
| Reported texture allocation | 216.61 MiB |
| Reported video allocation | 278.30 MiB |

Allocation includes retained hidden 2D world textures, avatars, embedded imported GLB materials and contact resources. It is not the five-source-texture budget. Desktop vsync/background activity may affect process timing. The scene is deliberately unoptimized DEV evidence: 235 surfaces, embedded/shared texture duplication and retained gameplay resources need reduction before mobile readiness. No real-phone performance or shipping frame budget is claimed. Fresh import also reports five inherited uppercase `res://Scripts/` references in unrelated old platformer prefabs/managers; these are not new kit paths and do not prevent this native slice. They remain a portability cleanup item before case-sensitive/export shipping; no production source was edited to suppress them. Primary variants: shared opaque painted StandardMaterial3D, two-sided opaque foliage, small emission, sprite depth prepass and contact alpha blend. Shader variant count was not introspected; no invented count. LightmapGI/SSAO were not used.

## AI-assisted production findings

Headless parameterized Blender builders produce editable sources and reliable semantic origins without manual modeling. This works for a coherent small kit with shared texture grammar; meaningful art direction still requires silhouette/UV/material inspection, illustrated target comparison and human veto. The actual UV failure demonstrates why file generation/array count alone is insufficient. Automated rebuilding/export/testing supports iteration; it does not automatically produce the Hero ceiling.

## Preservation / migration recommendation

All 3960 pre-task non-cache content files remain SHA256-identical (one Finder `.DS_Store` metadata change is recorded separately), including the separate 164-file approved Café review binding. Source gameplay/navigation/coordinates/semantic IDs/save/economy/Focus remain unchanged. Isolated DEV saves use a distinct namespace. Original 2D assets remain available.

Recommend review this LIVE HYBRID kit in motion, then—only after separate acceptance—measure phone performance and optimize surfaces/resource loading before authorizing any limited integration. No production Home/Riverside migration, second floor, town expansion, React Native, commit or push occurred. Production publication remains blocked by its unchanged approval/rights/publisher requirements.

WILLICAT HYBRID 3D CAFÉ ASSET KIT V1
— READY FOR HUMAN PLAYABLE REVIEW
