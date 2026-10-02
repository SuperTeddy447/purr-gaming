# WILLICAT RIVERSIDE 3D ART TRANSLATION REFINEMENT V2 — RESULT

2026-10-02. **Isolated DEV refinement. Human visual approval pending.**

**B — CLEAR IMPROVEMENT — ONE FINAL POLISH PASS REQUIRED.** The same route now has deeper café framing, broader handcut paving, heavier varied banks, a more substantial compact bridge and an original asymmetric vegetation family. It remains noticeably simpler than the Master; this recommendation does not confer aesthetic approval or authorize district expansion.

## 1. Authority and bounded scope

World/asset design: [Riverside design](../art_direction/WILLICAT_RIVERSIDE_HOME_DISTRICT_DESIGN_V1.md), the existing Master, asset-family board and five hero studies under `artifacts/world_design/riverside_home_district_v1/`. Gameplay authority: the exact [V1 DEV translation](../../scenes/dev/riverside_translation/DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.tscn). Style: [approved calibration](../art_direction/WILLICAT_STYLE_FAMILY_CALIBRATION_V1.md).

V2 is an **additive version of the same bounded slice**, preserving V1 for fair comparison. No new playable area, route graph, district, game system, character artwork, source texture, weather or leaf-particle pack is created. Background cues extend visual context only. Production Home, approved 2D café, approved Tree Pilot, navigation, semantic anchors, interaction slots, saves and production project configuration remain byte-identical.

## 2. Exact files / launch

Existing files changed: **NONE**. New files are enumerated individually with SHA-256 in [created-file inventory](../../artifacts/prototype_review/riverside_3d_art_refinement_v2/diagnostics/created_file_inventory.json).

| New paths | Responsibility |
|---|---|
| `assets_src/3d/riverside_refinement_v2/` | 25 editable `.blend` sources, 25 source `.glb` exports, `build_receipt.json` |
| `assets/dev_review/riverside_refinement_v2/` | 25 byte-identical runtime GLBs, `asset_manifest.json`, `painted_variation.gdshader`, `foliage_sway.gdshader`, `water.gdshader` |
| `scripts/dev/riverside_refinement_v2/riverside_refinement_v2.gd` | V1 subclass overriding presentation only |
| `scenes/dev/riverside_refinement_v2/DEV_WILLICAT_RIVERSIDE_3D_ART_REFINEMENT_V2.tscn` | Playable DEV entry point |
| `tools/willicat_riverside_refinement_v2/` | `blender_build.py`, `run.py`, `Open_Riverside_Refinement_V2.command`, `README.md` |
| `tests/` | `capture_riverside_refinement_v2.gd`, `capture_riverside_matched_refinement_v2.gd`, `test_riverside_input_refinement_v2.gd`, `test_riverside_launcher_refinement_v2.py`, `test_riverside_controls_refinement_v2.gd` |
| `artifacts/prototype_review/riverside_3d_art_refinement_v2/` | Native PNG/video, matched comparisons and diagnostic receipts |
| `docs/production/WILLICAT_RIVERSIDE_3D_ART_TRANSLATION_REFINEMENT_V2_RESULT.md` | This result |

Open [Open_Riverside_Refinement_V2.command](../../tools/willicat_riverside_refinement_v2/Open_Riverside_Refinement_V2.command). It builds a fresh minimal temporary Godot project; separate user namespace `WilliCatRiversideRefinementDEVV2`. No production Home is loaded. Controls: **click/tap stone to walk**, **Walk route**, **Route debug**, **NPC width**. The latter is a second existing-art diagnostic proxy, not new NPC gameplay.

## 3. Visual gap audit and actual refinements

| Family / V1 cause | V2 change | Remaining gap |
|---|---|---|
| Café window: cream wall behind a shallow flat warm panel | Real aperture with recessed rear volume, cedar jambs/mullions, thick sill and small ceramic shelf silhouettes | Warm interior remains restrained and partially hidden by the awning at gameplay scale |
| Café silhouette: uniform tile slabs / little lower profile | Deeper eave layers, thicker ridge/edge profiles, cream gable with cedar structure, stronger framed blank sign, cedar lower panels and stone base | Roof remains a regular module, without the Master’s selective painted tile finishing |
| Entrance: relatively quiet frame | Deeper cedar jamb / face profile, substantial lintel and open threshold; exact 1.08 DEV opening retained | Door can be visually dark at 360; no baked text or opaque exterior image substitutes for traversal |
| River: identical 4-stone rows / uninterrupted course | Mixed .42/.49/.68/.72/.83/.86 DEV stone spans, offset seams, two straight variants, small coping-height differences and river-side outsets | Underlying reach remains straight because crossing and route are locked; this is not a reconstructed natural river bend |
| River grounding: very thin repeated moss line | Three stronger planted pockets per planted section and larger below-cap anchor stone; no walking-width reduction | Planted pockets and cap variations are restrained; more deliberate long-range rhythm could improve them |
| Bridge: thin plank/rail structure and four identical posts | Broader thicker deck planks, substantial side beams, underside cross-supports, three timber posts, softened continuous rail segments, restrained pins and iron feet | Flat deck preserves the proven 2D movement height; no new camber/grade/nav assumptions |
| Paving: repeated small 3×4 brick grid | Three reusable 2×2 DEV modules with different broad stone partitions, authored chamfered corners, occasional 180° repetition breaks and low-frequency per-part pigment | Rectangular module joins still reveal repetition; no universal tile/grid equality claimed |
| Vegetation: UV-sphere cloud masses / mechanically similar lobes | Tapered bent trunks, exposed fork structure, asymmetric unequal-shouldered lobed crown meshes with broad leaf groups; medium tree, small tree, shrub, broad river blades and potted foliage | Still more sculpted/faceted and less delicate than the illustrated hero; finer intentional edge silhouettes remain the main polish need |
| Background: abrupt end / two very plain distant house boxes | Same two distant houses gain cedar/window cues; second shifts to `(2.65,0,-6.8)` for visible continuation; grouped reuse of existing tree family plus a low tapered ground rise | Quiet volumes remain deliberately economical; no full neighborhood, new interior or extra navigation |

Geometry edits stay within permitted exterior/bridge/bank/vegetation/background/minor-paving families. The **original bench and practical lamp GLBs are reused unchanged** from V1. New source/runtimes remain experimental DEV material, not published production prefabs.

## 4. Camera — exact changes and framing limits

| Setting | V1 | Final V2 |
|---|---|---|
| Projection / portrait | Orthographic KEEP_WIDTH; 540×960 / 360×640 | Same |
| Orthographic size | 13.4 | 13.2 |
| Position | `(5.5,13,21)` | `(8.35,16.5,21)` |
| Look-at target | `(.65,.75,3.2)` | `(1.05,.75,2.8)` |
| Elevation / azimuth | approximately 34° / 15° | 38.77° / 21.86° |
| Near / far | .1 / 60 | Same |
| Gameplay camera movement | Fixed | Fixed; no free rotation or cinematic shot |

The closer draft first hid storefront depth and clipped the far-bank continuation; both were corrected before final proof. Final required tour targets project inside the actual viewport. The taller background/camera treatment reduces accidental top margin, but this intentionally bounded island still has neutral outer space and a partial neighbor crop. Matched close cameras are identical V1/V2; `matched/V1_WITH_V2_CAMERA_CONTROL.png` isolates the camera change from asset changes. Gameplay pair labels explicitly identify different primary framing. No lens blur, fog, bloom, vignette or dramatic sunlight hides geometry.

## 5. Materials / lighting / water

Same six first-party 512² painted texture sources and semantic material mapping. No new texture generation, photographs, external meshes or new material research. One restrained derivative of the current painted shader uses authored `COLOR.b` for low-frequency per-part pigment; `COLOR.g` retains foliage color grouping. Roughness/specular philosophy and source-color palette remain shared. Vegetation is opaque geometry, not photorealistic alpha leaf cards. Shader uses two-sided rendering for the broad foliage blades; this broad shared setting is a remaining cost opportunity, not a mobile optimization claim.

Lighting is unchanged: one warm-neutral shadow directional + one subtle practical, ambient fill .47, key .90, practical .32/range1.6; no SSAO, glow, fog, reflection, refraction or additional lights. Water shader remains the **same cheap opaque broad slow blue-green motion** as V1; its content is reused unchanged. Bank form/pigment provides the new edge depth cue. No LightmapGI or expensive postprocess is added.

## 6. One representative vegetation motion test

Only the foreground medium tree has duplicated wind materials. All other trees, shrubs, bank moss, river blades and pots remain static. Only foliage surfaces receive low-amplitude two-axis offsets; wood and whole-instance transforms stay fixed. No scale pulse, falling leaves or weather.

CPU sampling of the actual shader formula on imported vertices records 282,194 evaluations over 12 s: maximum local foliage X offset 0.012000, Z offset 0.005400 DEV units. Root/trunk receives zero deformation by material partition. These are **analytic shader-function samples**, not GPU vertex readbacks or approved family tolerances. `.012` amplitude and the low-vertex mask are DEV art parameters only. Native time-pair captures demonstrate playback. Human motion/visual acceptance is not inferred from measurements.

## 7. Gameplay / authority / depth

V2 inherits V1 `_gameplay`, actor class/speed, route polygon, mapping `.01`, sprite sheets, frame timing, input, tour, contact shadow and depth-tested billboard. No second 3D navigation or physics authority. Exact comparison checks cover route vertices, movement settings, café entrance location and bridge location. Hash for both revisions:

```text
9eeae7da851cbb18b52caf816db2f952346a1d38049b6e3906f0077507ce39a1
```

All eight tour checkpoints succeed: café entrance → street → river → bridge → far bank → continuation → bridge return → street return. All recorded route samples stay inside the existing DEV authority; actor root Y=0 and shadow follows. Background rise remains outside the main street/far-bank strips. Route debug and NPC-width controls toggle correctly. Existing two-actor lane pass remains valid; it is width proof, not a finished crowd-avoidance system.

Four-layer static native controls verify actual geometric occlusion: bridge hides 107 of 544 isolated cat pixels; entrance hides 308 of 535. No manual 2D occluder swapping. RGB cutoff10 is analysis instrumentation, not a canonical visual threshold.

Idle silhouette measured on the final camera is **27×38 px at 540×960**, **18×25 px at 360×640**. V1 was 29×37 / 19×25: width is slightly lower in the new projection; face detail must not carry gameplay readability. Source pixels, tint, pixel size and source baseline are unchanged. Native café/river/bridge evidence shows silhouette readability against cedar/stone/water; foliage frames the route, with the main tree outside the movement strip. Final mobile readability remains a human decision.

## 8. Performance — actual desktop comparison

| Indicator | V1 | V2 |
|---|---:|---:|
| Visible geometry meshes | 88 | 93 |
| Scene triangles, repeated instances included | 194,058 | 84,418 |
| Geometry surfaces | 165 | 209 |
| Active geometry materials | 19 | 21 |
| Geometry texture sources | 6 | 6 |
| Geometry shaders | 3 | 3 |
| Lights / shadow lights | 2 / 1 | 2 / 1 |
| Mesh shadow casters | 48 | 52 |
| Transparent geometry surfaces | 0 | 0 |
| Steady-state desktop draw indicator, 180 samples | 134 | 142–142 |

Triangles reduce **56.50%** by broad stone modules, cheaper one-segment bevel treatment and cheaper crown geometry. Draw indicators **increase** because foliage/module surface splits and background cues outweigh that saving. No claim of phone suitability: native desktop **Apple M2 Pro / Metal / Godot 4.7.2 Mobile renderer** only. Blender **5.2.1 LTS**. No real-device FPS, thermal, allocation or battery test. Six shared sources avoid new raster memory; sprite/shadow sources remain five. Effective import sidecars are recorded; inherited mipmap generation remains false and needs an isolated device/import pilot later.

### Top-10 scene geometry contributors

| Asset | Instances | Triangles / instance | Scene triangles | Share |
|---|---:|---:|---:|---:|
| WC_RIVER_Roof_CedarSlate_A | 2 | 5,322 | 10,644 | 12.61% |
| WC_RIVER_Tree_Small_A | 3 | 3,460 | 10,380 | 12.30% |
| WC_RIVER_Tree_Medium_A | 3 | 3,460 | 10,380 | 12.30% |
| WC_RIVER_Ground_Stone_C | 12 | 764 | 9,168 | 10.86% |
| WC_RIVER_Ground_Stone_B | 11 | 672 | 7,392 | 8.76% |
| WC_RIVER_Bank_Straight_A | 8 | 528 | 4,224 | 5.00% |
| WC_RIVER_Bridge_Rail_A | 5 | 820 | 4,100 | 4.86% |
| WC_RIVER_Shrub_Riverside_A | 3 | 1,152 | 3,456 | 4.09% |
| WC_RIVER_Wall_Window_A | 2 | 1,704 | 3,408 | 4.04% |
| WC_RIVER_Ground_Stone_A | 4 | 780 | 3,120 | 3.70% |

All contributor totals reconcile to 84,418; [complete cost report](../../artifacts/prototype_review/riverside_3d_art_refinement_v2/diagnostics/top_10_triangle_contributors.json). First optimization candidates remain roof relief, repeated paving, medium/small-tree LOD distinctions, foliage surface/material splits and selected shadow work. No aggressive merge or quality sacrifice was made.

## 9. Regression results — exact cases

| Suite | Passed | Failed |
|---|---:|---:|
| Native V2 import/registration/route/camera/root/capture/identity | 77 | 0 |
| Native mouse/touch input | 5 | 0 |
| Temporary launcher safety and byte-preserving intake | 7 | 0 |
| Four-layer native pixel occlusion | 2 | 0 |
| Existing world architecture / navigation | 172 | 0 |
| Existing continuous Home | 28 | 0 |
| Existing approved 2D café / service | 39 | 0 |
| Existing Focus/persistence/economy guards | 33 | 0 |
| Installed visible controls / movement / debug / width | 4 | 0 |
| **Total assertions/cases** | **367** | **0** |

Fresh native import/capture/input/comparison/installed proof logs contain no script/shader/import errors. Existing copied regression fixture retains inherited `Scripts/` vs `scripts/` case warnings; no unrelated fixes applied. Home/world counting instrumentation lives only in the pre-existing temporary fixture. Café and Focus fixture scripts match original hashes; new execution receipts identify fixture hashes and exit codes. Installed controls exercise button signal wiring and visible toggles; separate native input tests exercise actual mouse/touch events.

All **7,246 pre-existing non-cache files** remain byte-identical, including V1 and approved production baselines. [Final parity receipt](../../artifacts/prototype_review/riverside_3d_art_refinement_v2/diagnostics/protected_file_parity.json) lists actual count and exceptions. Snapshot excludes `.git`, `.godot`, `.venv`, `node_modules`, `__pycache__`; no destructive modification, commit or push.

## 10. Evidence — native, moving, comparable

Evidence root: `artifacts/prototype_review/riverside_3d_art_refinement_v2/`.

| Evidence | Purpose |
|---|---|
| `matched/GAMEPLAY_V1.png`, `01_FULL_PORTRAIT_GAMEPLAY_540x960.png` | V1 original / V2 final actual gameplay portrait |
| `14_CAFE_V1_V2.png` | Identical diagnostic café camera |
| `15_BRIDGE_V1_V2.png` | Identical diagnostic bridge camera |
| `16_BANK_V1_V2.png` | Identical diagnostic bank camera |
| `17_VEGETATION_V1_V2.png` | Identical diagnostic tree camera |
| `18_GAMEPLAY_V1_V2.png` | Explicitly labeled primary camera comparison |
| `19_MASTER_V1_V2.png` | Unmodified design image / unretouched native V1 / V2 with labels |
| `matched/V1_WITH_V2_CAMERA_CONTROL.png` | V1 assets under final V2 camera, controlling framing effect |
| `02_CAT_CAFE_ENTRANCE.png` | Actor at the real unchanged opening |
| `03_CAT_RIVER_WALK.png` | Actor beside water / warm stone boundary |
| `04_CAT_BRIDGE_CROSSING.png` | Actual actor crossing real bridge geometry |
| `05_CAFE_FACADE_CLOSE_3Q.png`, `06_RIVER_EDGE_WATER_CLOSE.png` | Final diagnostic close views |
| `07_TOP_VIEW_PLAYABLE_ROUTE.png` | Unchanged DEV navigation outline |
| `08_MOBILE_360_CAFE.png`, `09_MOBILE_360_RIVER.png`, `10_MOBILE_360_BRIDGE.png` | Actual native 360×640 viewports, not downsized desktop images |
| `11_TWO_CAT_WIDTH_TEST.png` | Same-art width-proxy pass |
| `12_WATER_FOLIAGE_TIME_A.png`, `13_WATER_FOLIAGE_TIME_B.png` | Only one representative vegetation animation plus water |
| `20_INSTALLED_PLAYABLE_CONTROLS.png` | Installed copy, movement/debug/width UI |
| `WILLICAT_RIVERSIDE_3D_ART_TRANSLATION_REFINEMENT_V2.mp4` | 23.48 s native moving-character route; 231 real frame readbacks + final hold, timestamp-based encoding, no interpolation |
| `diagnostics/` + `native_runtime_report.json` | Import/settings, source/tool hashes, exact authority, all route samples, motion samples, input/depth layers, profile/cost, regressions, file inventory/parity |

Only comparison canvases add labels/proportional placement. Native screenshots are unretouched; the Master is never a runtime backdrop. Raw frame PNGs stay temporary; their hashes/timestamps are retained. The video proves a living playable slice rather than an empty scene.

## 11. What still differs from the Master and why

1. **Foliage:** asymmetric broad boughs now replace balls, but canopy edges are still coarse/layered rather than the Master’s finely illustrated warm leaves. This needs stronger authored leaf-group silhouette, not more random objects or a vegetation pack.
2. **Café identity:** physical recesses and cedar structure improve, but roof/awning/frontage still appear uniformly clean and interior visibility is modest. Selective form/pigment polish is the next opportunity; no readable generated text or full interior rebuild was added.
3. **Banks:** coping offsets, heavier blocks and planted pockets help, yet a straight modular reach remains visibly regular. Route/crossing lock prevents copying the Master’s curved landscape. Longer-range irregular visual composition can be refined without moving navigation.
4. **Background:** two economical house masses and a tapered rise imply continuation, but the Master is a fully framed district. Building that neighborhood would violate this bounded task. Neutral margin and partial right neighbor remain visible rather than concealed with a crop.
5. **Material finish:** all source textures are intentionally reused. Shared painted variation helps cohesion; it does not equal unique authored albedo finishing of every hero surface.
6. **Mobile:** orange silhouette survives both actual viewports but facial detail is tiny. Real phone performance, mip/format/aliasing and final human readability acceptance remain untested.

**B — CLEAR IMPROVEMENT — ONE FINAL POLISH PASS REQUIRED.** Submit this exact playable revision for human visual review. Do not expand district or migrate production automatically.

WILLICAT RIVERSIDE 3D ART TRANSLATION REFINEMENT V2
— READY FOR HUMAN VISUAL REVIEW
