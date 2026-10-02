# WILLICAT HYBRID 3D HERO ASSET REPLACEMENT PASS V1 — RESULT

## 1. Scope and decision

**TECHNICAL DEV PROOF: PASS. AGENT VISUAL SELF-QA: improved forms visible at gameplay scale. HUMAN VISUAL ACCEPTANCE: PENDING. Production publication/migration: not authorized.**

Human accepted V2 as the development baseline and Hybrid direction, then authorized this bounded replacement pass. This is the **same V2 café**, inherited through its existing presentation code. Exact V2 camera, lighting, placement calls, seven plant instances, semantic owner transforms, navigation and existing 2D service/Focus authority remain intact. No new room, stairs, seating zone, layout or protagonist pixels.

Scene: `scenes/dev/hybrid_cafe_hero_replacement/hybrid_cafe_hero_replacement_v1.tscn`.

Launcher: `tools/willicat_hero_asset_replacement/Open_Hero_Asset_Replacement.command`. It composes the existing V2 launcher and creates a fresh `/private/tmp` project with `WilliCatCafeHeroReplacementDEVV1` save namespace. Click floor to walk; **Depth Walk** runs real navigation; **Make coffee** uses the unchanged customer/service/reward loop.

## 2. Visual gap and bounded replacement

| Family | Concrete V2 gap | Replacement | Gameplay-scale observation |
|---|---|---|---|
| Counter | Similar flat sage rectangles; box-like end treatment | Thick rounded cream-stone slab; inset cedar fields, projecting stiles, side panels, recessed plinth, softened corner posts | Cedar framing and slab mass are visible in the primary matched shot |
| Espresso | Rectangular casing with small trim additions | Authored extruded side profile, stepped deck, deep extraction zone, two group heads, tactile controls, central gauge, bent wand and existing two deck cups | Service equipment reads as an intentionally designed machine; small controls are principally closeup detail |
| Chair | Rectangular cushion/back pad, tubular/simple legs | Continuous swept crest/lower rail, tapered splayed cedar members, negative-space framing, domed superellipse sage seat | Four chairs read rounder and more handcrafted without changing seating roots |
| Window/wall | Thin, dense planar grid | Nested deep jamb/bead, thicker lintel, plaster returns, fewer readable mullions, inner ledge and restrained joinery shoulders | Rear architecture has stronger frame depth and quieter construction rhythm |
| Plants | Narrow spear-like floor silhouette; procedural role foliage without editable Blender sources | Four authored roles: broad-leaf floor, small shelf, trailing, flowering; thrown pot and shared pigment/cavity | Floor foliage is visibly broader/softer; shelf/trailing/flowering differences remain local and restrained |

**Ten editable replacements:** three counter modules, espresso, chair, window/wall, and four plant roles. Eight corresponding base GLBs are replaced; **19 of the 27 V2 base GLBs are reused byte-for-byte**, plus two new plant-role entries (29-entry review catalog). All seven V2 plant instances retain their role, position and authoring scale intent. New complete plant geometry replaces the old pot/foliage presentation, rather than being layered over it. No extra plants or countertop prop clusters. Optional lamp was not rebuilt; table remains the V2 asset.

## 3. Blender sources and runtime outputs

| Asset | Editable Blender source | Runtime GLB | Evaluated triangles |
|---|---|---|---:|
| Counter_Straight_A | `assets_src/3d/cafe_hero_replacement_v1/furniture/WC_CAFE_Counter_Straight_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/furniture/WC_CAFE_Counter_Straight_A.glb` | 3996 |
| Counter_End_A | `assets_src/3d/cafe_hero_replacement_v1/furniture/WC_CAFE_Counter_End_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/furniture/WC_CAFE_Counter_End_A.glb` | 2052 |
| Counter_Short_A | `assets_src/3d/cafe_hero_replacement_v1/furniture/WC_CAFE_Counter_Short_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/furniture/WC_CAFE_Counter_Short_A.glb` | 2052 |
| Espresso_A | `assets_src/3d/cafe_hero_replacement_v1/equipment/WC_CAFE_Espresso_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/equipment/WC_CAFE_Espresso_A.glb` | 9004 |
| Chair_A | `assets_src/3d/cafe_hero_replacement_v1/furniture/WC_CAFE_Chair_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/furniture/WC_CAFE_Chair_A.glb` | 2350 |
| Wall_Window_A | `assets_src/3d/cafe_hero_replacement_v1/architecture/WC_CAFE_Wall_Window_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/architecture/WC_CAFE_Wall_Window_A.glb` | 2700 |
| Planter_Floor_A | `assets_src/3d/cafe_hero_replacement_v1/plants/WC_CAFE_Planter_Floor_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/plants/WC_CAFE_Planter_Floor_A.glb` | 1644 |
| Planter_Table_A | `assets_src/3d/cafe_hero_replacement_v1/plants/WC_CAFE_Planter_Table_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/plants/WC_CAFE_Planter_Table_A.glb` | 1260 |
| Plant_Trailing_A | `assets_src/3d/cafe_hero_replacement_v1/plants/WC_CAFE_Plant_Trailing_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/plants/WC_CAFE_Plant_Trailing_A.glb` | 2272 |
| Plant_Flowering_A | `assets_src/3d/cafe_hero_replacement_v1/plants/WC_CAFE_Plant_Flowering_A.blend` | `assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/plants/WC_CAFE_Plant_Flowering_A.glb` | 2780 |

Blender 5.2.1 LTS, build `9e2066aef7ef`. Every source retains named editable geometry parts; hard-surface sources retain proportional bevel/normal modifiers, while plants use directly authored profile/leaf topology; the export working scene applies modifiers and joins render geometry into named material surfaces. Semantic origins remain ground/contact center or structural left-ground corner as appropriate. Godot import verifies evaluated AABB/triangle parity, UV0 coverage, finite normals, material mapping and identity prefab roots for **all 29 entries**.

## 4. Reusable templates and form language

`tools/willicat_hero_asset_replacement/build_hero_assets.py` reuses the original first-party Blender helpers for coordinate conversion, UVs, lathe/cup geometry and editable modifiers. New reusable functions implement parameterized counter widths/depths, tapered members, swept rails, shaped machine housing, nested window joinery and four botanical roles.

`assets_src/3d/cafe_hero_replacement_v1/form_language.json` records the DEV design rules. Bevels depend on **local member thickness or module depth**: chair legs use the smaller end width; crest rails use the smaller section dimension; stone edge softness follows counter depth with a bounded design cap. These are **DEV authoring parameters fitted to V2**, not invented production calibration tolerances. Countertop height remains the existing 1.08 authoring surface, and the V2 placement offsets remain authoritative.

The generator's numeric weld distance is mesh cleanup precision, not an asset registration tolerance. New category geometry must still be extracted from its own authority; this template cannot invent it.

## 5. Material/texture strategy

Reuse the exact existing V2 ShaderMaterial resources: cedar light/mid/dark, cream stone/plaster, sage, ceramic, charcoal/metal and organic foliage, plus existing small accent roles. **No new textures, no image-generation calls, no photographic inputs, no new lighting/shader design.** All five existing first-party albedo file/pixel hashes are bound in the toolchain receipt. Blender material slots are import identities; the existing V2 wrapper supplies the Godot shared painted shaders.

Geometry supplies richer broad material separation and recesses. Vertex red carries short-range geometric cavity; organic foliage green carries authored pigment variation. Shared foliage uses opaque two-sided meshes, not transparent photographic cards. High roughness/low specular are inherited. Cavity radii/darkening are recorded DEV artistic choices, not scene sun bakes or global calibration limits. Source diffuse previews are approximate; the mapped Godot shader is the tested presentation.

## 6. Camera, light, cat and authority

No camera or light override exists in the replacement script. The native proof compares the **full V2 camera transform/projection/size** and actual key/ambient/practical configuration by equality. Key remains warm-neutral, ambient soft, practical local; no bloom, fog, vignette, DOF, SSAO or LightmapGI added.

Canonical orange protagonist retains its exact existing SpriteFrames, depth-tested AnimatedSprite3D, V2 ambient tint and separate floor-aligned contact shadow. Worker/customer sprite handling also remains inherited. All V2 placement calls/counts and seven plant-role positions match. GameplayRoot owns Vector2 transforms, PhysicalFootprint/collision, navigation, anchors, service/rewards, Focus, saves and semantic IDs. New imports contain no 3D collision world.

## 7. Performance — measured desktop comparison

Both branches use Mobile Metal on Apple M2 Pro, identical viewport/camera and sampling: wait for readiness, foreground, 5-second warmup, 240 frames with first 60 discarded. No screenshot readback during samples.

| Metric | V2 measured control | Final replacement | Delta |
|---|---:|---:|---:|
| Visible geometry meshes | 71 | 67 | -4 (-5.63%) |
| Geometry triangles | 122004 | 118838 | -3166 (-2.59%) |
| Draw indicators / frame | 156 | 151 | -5 (-3.21%) |
| Active geometry materials | 18 | 18 | 0 |
| Geometry texture resources | 5 | 5 | 0 |
| Lights / shadow lights | 2 / 1 | 2 / 1 | 0 |
| Desktop TIME_PROCESS monitor mean | 13.09 ms | 29.56 ms | Higher; not evidence of improved frame time |

Initial replacement was 139,894 triangles / 19 materials / 153 draw indicators. Optimization removed invisible plant-stem bevels, reduced pot-rim/flower/leaf tessellation and merged stem pigment into the shared organic material. Final **118,838 triangles** retain the designed silhouette with lower geometry/draw counts than V2.

The TIME_PROCESS monitor is higher in this desktop run and is not a CPU/GPU or phone benchmark. Geometry/draw reduction **does not establish faster runtime**. Actual hardware profiling remains necessary before a mobile decision. Resource monitors include retained hidden 2D authority, avatars, embedded imports and contact shadows; five refers to active geometry albedo resources, not total memory allocation. Raw samples are retained.

## 8. Executed validation

| Suite | Executed checks/cases | Result |
|---|---:|---|
| Native full scene/import/camera/light/placement/navigation/service proof | 376 | PASS |
| Editable Blender source reopen audit | 10 | PASS |
| Exported cavity color checks, new and retained sources | 16 | PASS |
| Real screen-click navigation | 5 | PASS |
| Launcher destination/namespace/baseline safety | 9 | PASS |
| Four-layer counter/table front/behind pixel-depth cases | 4 | PASS |
| Approved 2D Café regression | 39 | PASS |
| Continuous Home navigation/depth regression | 28 | PASS |
| World architecture/navigation regression | 172 | PASS |
| Focus regression | 33 | PASS |

**692 executed checks/cases total**, including **272 existing gameplay regression checks**. Counts mix assertions and four diagnostic depth cases; they are not an art-quality score. Home/world execution counters are added only to temporary test copies; repository regression sources are unchanged.

Native proof executes seven actual actor navigation targets, original walking clips, collision-free cabinet routing, real actor front/behind counter and table depth, and original Make Coffee customer sequence, one earned coin and duplicate reward protection. The video records this moving actor route with actual capture timestamps. Four-layer depth measurements are in `diagnostics/pixel_depth_analysis.json`; pixel classification cutoffs are analysis parameters, not art approval tolerances.

Pre-existing source/review file hash parity: **6248 / 6248 unchanged**. Approved 2D binding: **164 / 164 verified**. Approved tree/style records and production scenes remain untouched. No commit or push.

## 9. Evidence

Root: `artifacts/prototype_review/hybrid_cafe_hero_replacement_v1/`.

| File | Contents |
|---|---|
| `01_V2_BASELINE.png` | Fresh native V2 control capture |
| `02_HERO_ASSET_PASS.png` | Native replacement at exactly the same camera/lighting/actor target |
| `03_V2_V3_SIDE_BY_SIDE.png` | Unretouched native images with labels, no primary crop/resize |
| `04_COUNTER_BEFORE_AFTER.png` | Matched extra camera: counter |
| `05_ESPRESSO_BEFORE_AFTER.png` | Matched extra camera: machine |
| `06_CHAIR_BEFORE_AFTER.png` | Matched extra camera: seating |
| `07_WINDOW_BEFORE_AFTER.png` | Matched extra camera: rear window |
| `08_PLANTS_BEFORE_AFTER.png` | Matched extra camera: broad-leaf floor plant |
| `09_GAMEPLAY_SCALE.png` | Primary gameplay-scale scene |
| `10_CAT_IN_SCENE.png` | Extra cat integration view |
| `WILLICAT_HYBRID_3D_HERO_ASSET_REPLACEMENT_PASS_V1.mp4` | About 14.5 seconds, actual moving canonical cat through the same café |

Additional trailing/flowering plants are visible in rear/service closeups; diagnostic role records identify all four source roles. `diagnostics/` contains native logs, import/cavity/launcher/input reports, both profile samples, four-layer depth evidence, moving trace, comparison provenance, protected parity and toolchain hashes. First iteration profiles remain labeled; final measurements supersede them. An initial source-audit assumption incorrectly required unused modifiers on explicit plant topology; that diagnostic is retained separately, and the corrected read-only audit verifies editable meshes, roots, UVs, packed sources and cavity attributes without adding artificial modifiers. Godot import caches are not source-of-truth evidence.

## 10. Visual self-QA and remaining Hero gap

The main shot shows rounded chair seats/crests, recessed cedar panels and broad foliage at gameplay size, rather than only magnified decoration. Machine/window forms gain more volume in paired closeups. Material family, actor identity and original navigation space remain coherent. This is **bounded progress**, not a declaration that the Hero ceiling is reached.

Hero still has stronger bespoke prop silhouettes, nuanced painted edge/face treatment, ceramic/foliage variation, architecture/material storytelling and local light richness. Some small machine controls disappear at portrait gameplay scale. Current floor/composition and lighting intentionally remain V2; their broad simplicity is not solved by adding clutter or cropping this comparison. No whole-café quality victory, automatic beauty score or human art decision is claimed.

## 11. Can this pipeline scale beyond the café?

**Engineering recommendation: yes for controlled, individually reviewed DEV asset families; not yet unrestricted production expansion.** Parameterized Blender sources → named materials/semantic origins → GLB → shared Godot wrappers → exact-authority native evidence is reusable. The four plants demonstrate family variation; three counters demonstrate reusable module sizing without moving world objects. No professional manual sculpting is required for these templates.

Before widening scope: human visual acceptance of this family, mobile profiling (especially the higher TIME_PROCESS observation), per-category measured templates/connectors, provenance/use-scope requirements and normal Factory review/publisher gates remain required. The task does not authorize town/Home/Riverside migration or production publication. Final visual preference and further pilot selection remain human-controlled.

WILLICAT HYBRID 3D HERO ASSET REPLACEMENT PASS V1
— READY FOR HUMAN VISUAL REVIEW
