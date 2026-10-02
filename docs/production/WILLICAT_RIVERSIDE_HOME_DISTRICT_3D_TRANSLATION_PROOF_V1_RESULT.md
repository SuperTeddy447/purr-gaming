# WILLICAT RIVERSIDE HOME DISTRICT 3D TRANSLATION PROOF V1 — RESULT

Date: 2026-10-02. **ISOLATED DEVELOPMENT PROOF. HUMAN VISUAL REVIEW PENDING.**

**Recommendation B — PROMISING — REFINE TRANSLATION BEFORE EXPANSION.** A real modular scene now supports café entry → short street → river edge → bridge → far-bank continuation. The family transfers cedar/cream/jade/stone/water relationships and moving-character depth. It does not yet preserve the Master's full warmth, organic silhouettes or frontage richness. Technical checks cannot confer those visual decisions.

## 1. Scope and authorities

- [Approved Riverside design](../art_direction/WILLICAT_RIVERSIDE_HOME_DISTRICT_DESIGN_V1.md), [research](../research/WILLICAT_RIVERSIDE_WORLD_VISUAL_RESEARCH_V1.md), Master, asset-family board and hero studies guide design transfer. Their old document status text remains historical; this user request separately authorizes the DEV translation.
- [Style calibration](../art_direction/WILLICAT_STYLE_FAMILY_CALIBRATION_V1.md) and its exact machine record guide the palette/rendering family; no new style lock is created.
- Existing [painted-surface Café result](WILLICAT_HYBRID_3D_PAINTED_SURFACE_AND_LIGHTING_SPIKE_V1_RESULT.md) and shader/material resources are reused unchanged. That earlier pass remains visually pending; reuse is not an invented production approval.
- Approved 2D café and Tree Pilot are untouched. Existing Home is never instantiated by this new DEV project. No canonical coordinates, navigation, anchors, save IDs or existing scene/source/art files are changed. No commit/push.

The Master is **not** a runtime texture/backdrop. No new source-art image generation, third-party pack intake, terrain for other districts, season/VFX pack or production migration occurs.

## 2. Files and launch

Scene: [`scenes/dev/riverside_translation/DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.tscn`](../../scenes/dev/riverside_translation/DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.tscn).

Script: [`scripts/dev/riverside_translation/riverside_translation.gd`](../../scripts/dev/riverside_translation/riverside_translation.gd).

Launch: [`Open_Riverside_Translation.command`](../../tools/willicat_riverside_translation/Open_Riverside_Translation.command). Each launch creates a fresh minimal temporary project, preserving source bytes, imports it and opens the native playable view. `WilliCatRiversideTranslationDEVV1` is a separate namespace; this scene has no save/load implementation and cannot load production Home saves.

| New subtree | Contents |
|---|---|
| `assets_src/3d/riverside_translation_v1/` | 22 editable Blender files, 22 source GLB exports, measured build receipt |
| `assets/dev_review/riverside_translation_v1/` | 22 identical runtime GLB copies, asset/provenance manifest, water and foliage shader |
| `scripts/dev/riverside_translation/`, `scenes/dev/riverside_translation/` | DEV presentation and scene entry point |
| `tools/willicat_riverside_translation/` | Reproducible Blender recipe, isolated launcher, open command, README |
| `tests/` | Three new diagnostics: native capture/route/import, mouse/touch/depth, launcher safety |
| `artifacts/prototype_review/riverside_3d_translation_proof_v1/` | Native captures, comparison, moving proof, measured reports, receipts and regression logs |

Exact per-file paths and hashes are listed in [created-file inventory](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/diagnostics/created_file_inventory.json); existing protected hashes are verified separately. Godot `.godot/` caches, `.import` sidecars, native temporary frame sequences and test saves are not copied into repository source.

## 3. Modular asset inventory and registration

All geometry is first-party **agent-authored scripted Blender construction**, using the existing Café helper code, not image-to-3D generation. Every GLB carries UV0, normals, vertex pigmentation and semantic material slots; all 22 pass native import checks. Roots carry intended ground-contact/attachment registration. Measured root-space AABBs below are dimensions of this DEV geometry, not Home measurements, universal units or approved production tolerances.

| Asset ID | Family | Evaluated triangles | Measured root-space AABB size X × Y × Z |
|---|---|---:|---|
| WC_RIVER_Ground_Stone_A | ground | 2652 | 2.000 × 0.170 × 2.000 |
| WC_RIVER_Bank_Straight_A | river | 1728 | 1.992 × 0.868 × 0.453 |
| WC_RIVER_Bank_Inner_A | river | 3564 | 1.223 × 0.868 × 1.222 |
| WC_RIVER_Bank_Outer_A | river | 3564 | 1.223 × 0.868 × 1.223 |
| WC_RIVER_Bank_PathTransition_A | river | 2592 | 1.992 × 0.868 × 1.333 |
| WC_RIVER_Bank_Vegetation_A | river | 2736 | 1.992 × 0.868 × 0.484 |
| WC_RIVER_Bridge_Deck_A | bridge | 2268 | 3.410 × 0.250 × 1.910 |
| WC_RIVER_Bridge_Rail_A | bridge | 1080 | 3.500 × 0.760 × 0.160 |
| WC_RIVER_Bridge_Abutment_A | bridge | 1404 | 0.700 × 0.798 × 1.987 |
| WC_RIVER_Wall_Window_A | architecture | 1944 | 2.870 × 2.380 × 0.520 |
| WC_RIVER_Entrance_Open_A | architecture | 756 | 1.400 × 2.410 × 1.059 |
| WC_RIVER_Wall_Plain_A | architecture | 756 | 3.400 × 2.360 × 0.255 |
| WC_RIVER_Roof_CedarSlate_A | architecture | 13184 | 4.720 × 0.900 × 3.970 |
| WC_RIVER_Awning_Jade_A | architecture | 1984 | 3.592 × 0.344 × 0.714 |
| WC_RIVER_Sign_Blank_A | architecture | 324 | 1.685 × 0.430 × 0.110 |
| WC_RIVER_Tree_Medium_A | vegetation | 6136 | 3.173 × 3.738 × 2.147 |
| WC_RIVER_Tree_Small_A | vegetation | 6296 | 1.348 × 1.579 × 0.912 |
| WC_RIVER_Grass_Bank_A | vegetation | 15 | 0.510 × 0.350 × 0.555 |
| WC_RIVER_Potted_Plant_A | vegetation | 1636 | 0.601 × 0.980 × 0.562 |
| WC_RIVER_Bench_Cedar_A | props | 648 | 1.400 × 0.465 × 0.400 |
| WC_RIVER_Lamp_Practical_A | props | 660 | 0.260 × 0.265 × 0.425 |
| WC_RIVER_Background_House_A | background | 328 | 2.300 × 2.100 × 1.960 |

Straight bank connectors are authored at local `[-1,0,0]` and `[1,0,0]` with `river_bank_course_v1` profile: **2.0 DEV span**. Beveled stone itself is narrower: measured bounds do not redefine connector pitch. Inner/outer corners, path transition and moss-compatible section use this same cap/course language. The scene is a straight bounded reach; corner modules form terminal registration studies, not a fabricated navigable river bend. Full cross-family adjacency certification remains future work.

Bridge deck top and ground route are at DEV Y=0; two rails sit outside the crossing corridor. Bridge is real geometry with separate deck, rail and abutment pieces. Near-flat deck avoids introducing unsupported navigation grades. Floor substrate closes tile-to-bank and café/path joins without moving navigation. Runtime-created ground/water/counter/debug meshes also have provenance records in the asset manifest.

## 4. Runtime hierarchy and authority

```text
DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1 (Node3D)
├─ RiversideVisualRoot (Node3D)
│  ├─ imported modular GLB instances (grounds/banks/bridge/architecture/plants)
│  ├─ supporting substrate / earth / café floor meshes
│  └─ QuietMovingRiver (opaque PlaneMesh)
├─ GameplayRootDEV_Vector2Authority (Node2D, hidden representation)
│  ├─ DEVRouteNavigation (NavigationRegion2D)
│  ├─ OrangeProtagonist (existing HardeningActor / CharacterBody2D)
│  ├─ FutureNPCWidthProxy (same existing actor/art, diagnostic only)
│  └─ OriginalOrangeClips (AnimatedSprite2D timing source)
├─ VisualRootOrangeSprite3D (AnimatedSprite3D, depth-tested)
├─ OptionalNPCScaleProxy (AnimatedSprite3D)
├─ protagonist contact-shadow Sprite3D
├─ PortraitGameplayCamera / QuietOutdoorEnvironment
├─ LateMorningSoftKey / CafePracticalAccent
├─ DEVWalkableOutline
└─ DEVControls
```

Existing `HardeningActor` and `NavigationAgent2D` drive the scene. Mapping is `Vector2(x,y) → Vector3(x × .01, 0, y × .01)`. There is no second 3D gameplay body or independent 3D navigation authority. This **new DEV polygon** is a prototype authoring choice and does not pretend to be the existing continuous Home authority. Five connected corridors define street/forecourt/opening/bridge/far-bank access. Their hash is unchanged after movement. Whole-project pre-existing source parity separately protects actual Home.

## 5. Camera and lighting

| Setting | Actual value / scope |
|---|---|
| Primary camera | Orthographic, KEEP_WIDTH, size 13.4, portrait 540×960 and native 360×640 |
| Position / target | `(5.5,13.0,21.0)` looking at `(.65,.75,3.2)`; approximately 34° elevation / 15° azimuth |
| Clipping | Near .1 / far 60, DEV framing choices |
| Ambient | `#E5E9E6`, energy .47, no reflection contribution |
| Key | `#FFF7ED`, energy .90, rotation `(-58,-28,0)`; one shadow directional light |
| Soft key shadow | Opacity .40, blur 4, bias .012, normal bias .14, max distance 45; DEV engine/art settings, not calibrated tolerances |
| Practical | `#F3DBB9`, energy .32, radius 1.6, no shadow casting |
| Environment | Neutral `#EAE6DA`, linear tonemap, no bloom/glow/fog/SSAO/DOF/refraction/reflections |

Camera remains fixed during gameplay. Close/top shots are explicitly diagnostic views. Neutral space around this bounded diorama is visible; the neighbor façade/tree can clip at the gameplay edges. This is a remaining framing gap, not a reason to pretend the screenshot contains the whole Master district.

## 6. Material / texture / water / foliage treatment

Shared families: cedar light/mid/dark, painted cream plaster, warm stone, slate roof, muted jade awning, sage valance, aged brass lamp bracket, charcoal caps/trim, ceramic pots, warm paper/glass/lamp, three foliage pigments, quiet sage earth and interior floor wood. All 19 active geometry material instances use the coherent first-party painted family or minimal water shader.

Six unchanged 512² painted texture sources are reused; no photographic or new generated texture. New color bindings and foliage shader duplicate material resources in DEV memory and never rewrite the existing library. Roof/stone are palette rebindings; they do not imply per-object unique painted UV art. Beveled edges, deep sill, framed opening, low timber rail rhythm and leaf-lobe clusters provide volume. Existing plaster/wood microvariation remains a shared texture treatment, not a unique hand-painted finishing pass.

Water is one **opaque** plane below the bank with broad source-color blue-green interpolation and slow sinusoidal color-flow marks. No normal map, transparent refraction, screen reads or reflections. Runtime speed .12 is an experimental art parameter, not a global calibration policy. Native time-pair differencing is recorded in [motion/scale/depth analysis](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/diagnostics/image_depth_scale_motion_analysis.json).

Foliage-only vertex offset reuses the painted shader. Cedar trunk surfaces and all whole-object transforms remain stationary. Local low-vertex mask locks the base; canopy tips carry a restrained two-axis offset and per-instance phase. DEV amplitude .016 and local mask limits .30/1.45 are recipe choices, **not** production motion thresholds or a human motion approval. No scale pulsing, skeleton/particles/weather/falling leaves. Shader source demonstrates the motion mechanism; native captures demonstrate playback, not GPU vertex-displacement calibration.

## 7. Background choice

Two instances of one low-detail background house module plus scaled reuse of the existing prototype tree family provide depth. They are noninteractive, outside navigation and have no separate full-house interiors. No image billboard or distant full town is built. This keeps the scene small and modular; current house silhouettes are deliberately too simple/clean compared with the Master. Refine roof/frontage and background contrast before expansion, rather than building all distant houses uniquely.

## 8. Protagonist scale / motion / depth findings

Exact existing orange sheets are reused; no repaint, regeneration, alpha surgery, mirroring or new character identity. The existing idle/walk frame map is preserved (8 fps walk). `AnimatedSprite3D` uses fixed-Y billboard, alpha depth prepass, normal depth test and mild ambient tint. A separate floor-aligned contact shadow follows the same 2D authority.

DEV pixel size is `.0044`, baseline offset `(0,104)` and camera-elevation vertical compensation; this is a presentation-scale trial, not a new canonical character scale. Measured isolated idle silhouette is **29×37 px at 540×960** and **19×25 px at 360×640**. Orange/cream separates from wood/stone/water; facial detail is weaker at 360. Human readability acceptance remains open.

All eight route targets are reached: café entrance, street, riverside, bridge, far bank, continuation, bridge return and street return. Every recorded sample stays within the connected DEV polygon; root Y remains zero; contact shadow follows the actor. Real mouse and touch input are tested, including water rejection. Two same-art actors pass on separated street lanes with minimum center separation 110 gameplay px (1.10 DEV units); bodies are .18 in diameter. This proves room for the chosen width proxy, **not** general future crowd avoidance or every NPC silhouette.

Four-layer native pixel controls show actual geometric occlusion: bridge hides 97 of 524 isolated cat pixels; café entry hides 193 of 525. Environmental shader motion is frozen only for these diagnostic controls. No manual foreground sprite swaps or 2D occluder sorting. The RGB differencing cutoff is analysis instrumentation, not an approved visual tolerance.

## 9. Performance — measured desktop proof

| Indicator | Final result | Interpretation |
|---|---:|---|
| Visible geometry mesh instances | 88 | Excludes sprites; many are repeated module instances |
| Evaluated geometry triangles | 194,058 | Includes repeated instances; not a unique-library triangle total |
| Geometry material surfaces | 165 | Shader/material surface splits remain an optimization opportunity |
| Active geometry materials | 19 | Shared/rebound instances, not 19 unique textures |
| Geometry texture sources | 6 × 512² | No new raster sources |
| Actor/shadow source textures | 5 | Four original sheets + original contact shadow |
| Geometry shader variants | 3 | Shared painted, derived foliage, opaque water |
| Lights / shadow lights | 2 / 1 | Practical does not cast shadows |
| Mesh shadow casters | 48 | Floor/grass/background/plane shadow work removed |
| Transparent geometry surfaces | 0 | Sprite alpha and contact shadow are separate transparency cost |
| Steady-state draw indicator | 134–134 (180 samples) | Desktop Apple M2 Pro / Metal / Godot Mobile renderer, common actor position |
| RGBA8 source-resolution estimate, all 11 textures | 9.875 MiB | Base level only, excludes GPU buffers, targets, shadows and importer overhead |
| Hypothetical full RGBA8 mip chains | 13.167 MiB | Size estimate only; this proof's effective imports have mipmap generation **false** |

Actual desktop renderer: **Godot 4.7.2 stable `ed1daf0bf`, Metal 4.0, Apple M2 Pro (Apple8)**. Blender: **5.2.1 LTS `9e2066aef7ef`**. No phone was tested and no device FPS/thermal/battery/VRAM claim is made.

Matched intermediate diagnostic reported 162 draw indicators before suppressing floor shadow work; final is 134 with three extra two-triangle substrate surfaces. Geometry is not aggressively merged. First optimization candidates: batch repeated paving/bank instances, cheaper paving bevel LOD, trim repeated material surfaces, evaluate proper mip/compression settings on an isolated mobile import, and limit shadow work to meaningful silhouettes. Texture filtering asks for mip support but current inherited imports lack mips; real-device aliasing/format/performance remains unresolved.

## 10. Verification — final exact counts

| Suite / cases | Passed | Failed |
|---|---:|---:|
| New native route/import/registration/camera/root/identity/capture diagnostics | 65 | 0 |
| Real native mouse/touch route input | 5 | 0 |
| Launcher safety / byte-preserving intake | 7 | 0 |
| Native four-layer pixel occlusion cases | 2 | 0 |
| Existing world architecture / actor navigation regression | 172 | 0 |
| Existing continuous Home regression | 28 | 0 |
| Existing approved 2D café/service regression | 39 | 0 |
| Existing Focus/persistence/economy guard regression | 33 | 0 |
| Installed native scene / visible button / movement smoke | 4 | 0 |
| **Total assertions/cases** | **355** | **0** |

These are checks/cases, not 355 independent test functions. Regressions run in a copied temporary project with a separate namespace; counting instrumentation exists only in copied Home/world test scripts. Production tests/scripts are unchanged. Initial fixture/coordinate-space failures are recorded separately and not counted as passes.

New minimal Riverside import has no script/shader/import errors. Larger existing regression context emits five inherited `Scripts/…` vs `scripts/…` case-mismatch warnings (AudioManager, SceneTransition, Coin, LevelFinishDoor, player); they remain an existing case-sensitive export risk, outside this DEV task. No silent existing-file fix.

Protected-file verification: all **7,097** pre-existing non-cache repository files remain byte-identical, including approved café, Tree Pilot, production Home, project settings, navigation and saves present in source. Intentionally excluded caches: `.git`, `.godot`, `.venv`, `node_modules`, `__pycache__`, `.pytest_cache`, `.DS_Store`. [Parity receipt](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/diagnostics/protected_file_parity.json) records actual final verification. No production-world instance/save access occurs in the minimal Riverside project.

## 11. Evidence

| File | Purpose |
|---|---|
| [01_FULL_PORTRAIT_GAMEPLAY_540x960.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/01_FULL_PORTRAIT_GAMEPLAY_540x960.png) | Native common portrait gameplay view |
| [02_CAT_CAFE_ENTRANCE.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/02_CAT_CAFE_ENTRANCE.png) | Reached real café opening; architecture occlusion |
| [03_CAT_RIVER_WALK.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/03_CAT_RIVER_WALK.png) | Cat reaches riverside route |
| [04_CAT_BRIDGE_CROSSING.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/04_CAT_BRIDGE_CROSSING.png) | Reached bridge with real depth |
| [05_CAFE_FACADE_CLOSE_3Q.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/05_CAFE_FACADE_CLOSE_3Q.png) | Diagnostic close 3/4 view, not the gameplay camera |
| [06_RIVER_EDGE_WATER_CLOSE.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/06_RIVER_EDGE_WATER_CLOSE.png) | Bank/deck/water diagnostic close view |
| [07_TOP_VIEW_PLAYABLE_ROUTE.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/07_TOP_VIEW_PLAYABLE_ROUTE.png) | Actual DEV navigation polygon overlay |
| [08_MOBILE_360_CAFE.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/08_MOBILE_360_CAFE.png) | Native 360×640 café view |
| [09_MOBILE_360_RIVER.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/09_MOBILE_360_RIVER.png) | Native 360×640 river view |
| [10_MOBILE_360_BRIDGE.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/10_MOBILE_360_BRIDGE.png) | Native 360×640 bridge view |
| [11_TWO_CAT_WIDTH_TEST.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/11_TWO_CAT_WIDTH_TEST.png) | Two existing-art copies after successful passing test; not a new NPC identity |
| [12_WATER_FOLIAGE_TIME_A.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/12_WATER_FOLIAGE_TIME_A.png) | Native environmental motion comparison A |
| [13_WATER_FOLIAGE_TIME_B.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/13_WATER_FOLIAGE_TIME_B.png) | Native environmental motion comparison B |
| [14_MASTER_VS_3D_TRANSLATION.png](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/14_MASTER_VS_3D_TRANSLATION.png) | Unchanged Master/native images placed side by side with labels |
| [WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.mp4](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.mp4) | 23.36 s native timestamped motion; 231 source readbacks plus final hold, no interpolated motion |

[Installed playable controls](../../artifacts/prototype_review/riverside_3d_translation_proof_v1/15_INSTALLED_PLAYABLE_CONTROLS.png) additionally verifies the visible **Walk route** button starts movement from the installed copy.

All gameplay/close/debug screenshots are native Godot readbacks, unretouched. Comparison is only proportional placement and labels, not runtime compositing. Motion encoding follows native capture timestamps; no synthetic frames. Raw temporary frame hashes/timing, route trace, effective import settings, asset AABBs, toolchain/source hashes, input/depth layers, regressions and profile samples are preserved under `diagnostics/`; raw frame PNG sequence stays temporary to avoid duplicating video payload in source.

## 12. Design transfer versus Master

| Master principle | Translation / difference | Reason and remaining work |
|---|---|---|
| Café as home landmark | Single-story cedar/plaster body, jade awning, deep sill/opening, lamp and blank sign | No permanent name/text baked; interior only a geometric hint, not a rebuild of the approved café |
| Narrow water supports nearby walk | Opaque muted blue-green reach with stone banks and real deck | Straight small proof instead of entire bend; water rhythm still too broad/regular versus painterly concept |
| Bridge reveals continuation | Real cedar crossing to quiet neighbor/far-bank path | Flat navigation profile deliberately avoids unsupported grade/camber |
| Handcut warm stone | Irregular beveled paving on continuous substrate | Repeat/brick rhythm remains obvious; variation and bank silhouette need another bounded art pass |
| Organic foliage rhythm | Small reusable leaf-lobe tree/shrub/pot family, route center remains clear | Canopies retain rounded cloud/facet language rather than the Master's finer branch/leaf silhouette |
| Layered ordinary neighborhood | One quiet neighbor façade, two simple background houses | Background geometry is economical but visibly primitive relative to hero study; no full district built |
| Portrait miniature gameplay | Fixed orthographic, existing cat and real 2D route | Neutral margins and partial neighbor crop are intentional limitations of current bounded framing; close shots do not hide them |
| Warm inhabited café street | Shared painted texture family and soft late-morning key | Less lived-in microdetail/frontage richness than Master; no extra object/FX pack scattered to compensate |

## 13. Remaining visual / technical decisions

1. Human must assess whether this remains recognizably WilliCat at mobile gameplay scale. Geometry/material coherence is demonstrated, aesthetic acceptance is not conferred.
2. Refine bank profile/paving variation and fewer, stronger leaf/branch silhouettes before district expansion. Shared texture tint alone cannot reproduce the Master painterly form.
3. Café/neighbor framing and protagonist face scale at 360 need review; avoid resizing canonical world/navigation to solve visual concerns.
4. Prototype family is not production-ready: complete connectors/adjacency, style/motion review, production registration/rights/credential gates and authoritative Home reconciliation remain separate work.
5. Real phone performance, mips/texture compression, thermal/memory allocation and device aliasing remain untested.
6. Two-actor lanes demonstrate width, not a finished autonomous NPC avoidance/service/economy loop for the exterior. Existing service/Focus/save systems pass regressions and remain reusable.

**B — PROMISING — REFINE TRANSLATION BEFORE EXPANSION.** Keep this playable DEV scene as evidence for human visual review. No automatic expansion, migration, publication, commit or push is authorized by these results.

WILLICAT RIVERSIDE HOME DISTRICT 3D TRANSLATION PROOF V1
— READY FOR HUMAN VISUAL REVIEW
