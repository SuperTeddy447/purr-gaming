# WilliCat Hybrid 3D Diorama Feasibility Spike V1 — Result

## 1. Status / recommendation

**D. MORE RESEARCH REQUIRED.** Technical feasibility demonstrated; premium visual improvement and phone suitability not established. Cat-in-3D self-QA: **B — acceptable but requires refinement**. Human hybrid visual approval: PENDING. Production migration/publication: NOT AUTHORIZED / NOT EXECUTED.

The recovered 2D café remains the approved baseline. This task added an isolated DEV projection; it did not resume or complete the interrupted premium 2D polish staging.

## 2. Deliverables / runnable scene

- [Research](../research/WILLICAT_HYBRID_3D_DIORAMA_RESEARCH_V1.md)
- Scene: `scenes/dev/hybrid_diorama/hybrid_cafe_diorama_v1.tscn`
- Source: `scripts/dev/hybrid_diorama/hybrid_diorama.gd`, `diorama_geometry.gd`, `painted_surface.gdshader`
- Launch: `tools/willicat_hybrid_diorama/OpenHybridDiorama.command`; `run.py --renderer gl_compatibility` selects fallback.
- Native proof: `tests/capture_hybrid_diorama_v1.gd`; steady profile: `tests/profile_hybrid_steady.gd`.

Launcher verifies all 164 café review-bound files and makes a fresh `/private/tmp` project. New scene/code remains additive; the main project configuration and existing scenes are untouched. Save namespace is `WilliCatHybridDioramaDEVV1`, not the original Focus notebook. No Factory compile/release/canonical integration status is claimed.

## 3. Architecture and terminology

Hybrid = real 3D environment + original illustrated cat plane, not a full 3D game or rigged 3D cats. The original Home scene supplies authoritative Vector2 actor motion, navigation, semantic IDs, footprint/interaction anchors and service/reward logic. Presentation maps `(x,y)` to `(.01x, elevation, .01y)`; inverse mapping returns the original world coordinate.

One floor/rear frame/counter/table/two chairs/planter/lamp are rendered. One optional shelf and shoji window enrich the rear plane. Heights and bevels are DEV presentation choices. Counter and tabletop ground registration follow measured runtime footprints. No world coordinate, seat, order point, worker anchor, navigation path, ID or source bitmap was changed.

## 4. Rendering setup / materials

Godot 4.7.2 (`ed1daf0bf001b61586d9930840f2f1394092c079`). Primary actual renderer: **Mobile / Metal 4.0**, Apple M2 Pro. Fallback actual renderer: **Compatibility / OpenGL 4.1 Metal bridge**, same machine.

Orthographic Camera3D: size 7, KEEP_WIDTH, position `(3.2,10.3,17)`, target `(3.2,.45,4.3)`, near .1/far 45. Portrait native render: **504×896**, logical design 576×1024. No free rotation; mild perspective not tested.

Bevelled cedar joinery, rounded ceramic/table shapes, shoji grids, sage chair cushions, opaque clustered leaves and a ribbed paper lantern provide a fair volume experiment beyond plain cubes. Existing first-party cedar/plaster/floor/textile textures supply surface variation. Matte roughness .95/.96, metallic 0, specular disabled; no normal/ORM/clearcoat maps. Palette-derived starting colors are not physically calibrated albedo values or a new style lock.

## 5. Cat rendering / motion result

AnimatedSprite3D references the **exact original SpriteFrames instance** and follows the source clip/frame/progress after its update. Existing down/up/left/right idle/walk semantics remain authored and unmirrored. Ground offset 104 derives from the original 232px contact in its 256px canvas. Current source scale determines pixel size.

Camera-facing, fixed-Y upright and fixed-facing were captured. Final camera-facing + opaque prepass + depth testing keeps the illustrated proportions readable and passes the depth proof. Blending/discard/prepass examples are retained. Cast shadows are OFF for the card; the existing contact-shadow texture lies on the ground plane instead. No cat regeneration/repaint, motion change, 3D rig or 3D actor physics was performed.

OBSERVED: readable orange focal actor; valid floor contact and no obvious rectangular shadow. The body is still a billboard. Crowds, rotating cameras, close camera moves and per-pose foot contact under many views remain untested. The quieter 3D environment still lacks some painterly contour/detail of the approved 2D family.

## 6. Real depth proof

Seven actual 2D-nav targets: entrance, counter front, counter back, table back, chair back, table side, table front. No actor teleport is used. Mesh depth is genuine; no separate authored 2D foreground occluder is used by the 3D view.

Four fixed-root raster-layer comparisons per renderer (background/cat-only/object-only/combined) measure pixel ownership:

| Primary Mobile case | Overlap pixels | Object-dominant | Cat-dominant | Result |
|---|---:|---:|---:|---|
| Counter behind | 1,593 | 1,593 | 0 | PASS |
| Counter front | 995 | 29 | 964 | PASS |
| Table behind | 611 | 611 | 0 | PASS |
| Table front | 743 | 11 | 732 | PASS |

Compatibility independently passes all four. Analysis RGB-delta/margin choices are recorded as analysis parameters, **not** production art tolerances. Transparent fringes and object shadows can contribute to masks; visible captures corroborate the classification. Chair-behind has a real navigation/render screenshot, not a separate four-layer pixel test.

## 7. Lighting / grounding

Tested: ambient only; one directional key + ambient; key + ambient + one non-shadowed warm practical. Key energy .58, ambient .35, practical .33/range 2.1 are DEV experiment settings, not portable calibrated targets. Key filtered shadow blur 2/opacity .58, a single orthogonal shadow map, no directional PCSS. Source illustrations remain separate from light settings.

Shadowed geometry gives real contact/cast depth. The cat uses an existing floor contact texture at .009 elevation to avoid z-fighting. No SSAO, glow, fog, reflections, dynamic GI, full-screen distortion or blur is enabled. LightmapGI was researched but **not baked**; UV2/bake/probe/renovation behavior requires a separate fixture. Mobile and Compatibility show visible lighting/value differences under identical inputs.

## 8. Measured complexity / mobile risks

| Final scene item | MEASURED |
|---|---:|
| Environment MeshInstance3D / surfaces | 35 / 35 |
| Environment triangles | 13,410 |
| Used material resources | 12 |
| Referenced texture files | 9 |
| Transparent Sprite3D-family components | 2: cat prepass + alpha contact shadow |
| AnimatedSprite3D | 1 |
| Realtime light nodes / shadowed lights | 2 / 1 |
| New SubViewport / screen-effect passes | 0 / 0 |

Static construction was batched from 115 mesh pieces to 35 per-semantic-object/material batches. Final before/after triangle equality is an explicit test. Mixed indexed/non-indexed meshes initially dropped surfaces; index/color normalization fixed it before final evidence. Semantic groups remain independently hideable for proof.

Steady measurements: one diagnostic Godot process, no screenshots/movie during sampling, 3s scene warm-up; each condition settles 1.3s, samples 240 frames and discards first 60. Values below are medians of 180 retained samples. M2 Pro desktop, compositor/vsync enabled; no target phone or thermal/battery validation.

| Renderer | Condition | Draw indicator | Render primitives | Wall frame wait ms | TIME_PROCESS ms | Texture MiB | Video MiB |
|---|---|---:|---:|---:|---:|---:|---:|
| Mobile / Metal | current_2d | 99 | 1272 | 8.27 | 16.43 | 107.25 | 157.31 |
| Mobile / Metal | hybrid | 78 | 27178 | 8.31 | 16.34 | 24.27 | 210.16 |
| Mobile / Metal | ambient_only | 43 | 13768 | 8.32 | 15.79 | 24.27 | 210.16 |
| Mobile / Metal | key_ambient | 78 | 27178 | 8.33 | 15.45 | 24.27 | 210.16 |
| Mobile / Metal | key_ambient_practical | 78 | 27178 | 8.25 | 15.96 | 24.27 | 210.16 |
| Compatibility / OpenGL | current_2d | 99 | 1272 | 8.26 | 20.52 | 154.05 | 160.23 |
| Compatibility / OpenGL | hybrid | 78 | 27178 | 8.30 | 14.62 | 161.23 | 170.04 |
| Compatibility / OpenGL | ambient_only | 43 | 13768 | 8.27 | 14.75 | 161.23 | 170.04 |
| Compatibility / OpenGL | key_ambient | 78 | 27178 | 8.28 | 14.68 | 161.23 | 170.04 |
| Compatibility / OpenGL | key_ambient_practical | 78 | 27178 | 8.29 | 14.79 | 161.23 | 170.04 |

The ~8.3ms frame-wait samples indicate desktop frame pacing; they are not isolated GPU execution times. TIME_PROCESS has a different sampling/aggregation basis and must not be inverted into an FPS promise. Resource counters are backend-specific process totals, including hidden 2D authority/context and render buffers; 9 referenced textures is not total process residency. The comparison also contains many more visible props in the 2D baseline, so these are **not** equal-content performance benchmarks or evidence that hybrid is cheaper.

The shadowed key adds 35 draw indicators and approximately doubles submitted geometry; practical-light arithmetic still costs shading even where the draw count stays constant. Alpha prepass, light/shadow buffers, dense foliage layers, large towns, import compression and material proliferation are the main phone risks. Ambient-only is a tested lower-cost diagnostic fallback, with visibly weaker volume. No final device budget is invented.

## 9. Honest current 2D / hybrid comparison

Same native portrait resolution, same original entrance actor root and approximately comparable full-floor framing. Original 2D camera stays unchanged. Hybrid uses a fixed experimental 3D camera; camera equivalence is approximate, not a pixel-identical before/after. The approved café has a richer full modular composition; the tiny spike intentionally renders fewer objects and uses physically registered tabletop dimensions. Density, lighting/backend and art sophistication differ.

OBSERVED: real volume/occlusion is clearer to reason about in hybrid; approved 2D remains stronger in painterly richness/intimacy. The evidence does not establish hybrid as visually superior. No camera/light change was made to force it to win; the fallback render is shown as well.

## 10. Evidence

All links below are raw Godot captures or a timestamp-preserving encoding of those frames, not generated scene mockups.

- [01 Current 2D café](../../artifacts/prototype_review/hybrid_diorama_v1/01_CURRENT_2D_CAFE.png)
- [02 Hybrid café](../../artifacts/prototype_review/hybrid_diorama_v1/02_HYBRID_3D_CAFE.png)
- [03 Behind counter](../../artifacts/prototype_review/hybrid_diorama_v1/03_HYBRID_CAT_BEHIND_COUNTER.png)
- [04 Front counter](../../artifacts/prototype_review/hybrid_diorama_v1/04_HYBRID_CAT_FRONT_COUNTER.png)
- [05 Table depth](../../artifacts/prototype_review/hybrid_diorama_v1/05_HYBRID_TABLE_DEPTH.png)
- [06 Lighting](../../artifacts/prototype_review/hybrid_diorama_v1/06_HYBRID_LIGHTING.png)
- [Chair behind](../../artifacts/prototype_review/hybrid_diorama_v1/depth_chair_back.png)
- [Moving cat video](../../artifacts/prototype_review/hybrid_diorama_v1/WILLICAT_HYBRID_DIORAMA_SPIKE_V1.mp4)
- [Compatibility fallback](../../artifacts/prototype_review/hybrid_diorama_v1/diagnostics/compatibility_hybrid.png)
- [Native Mobile proof](../../artifacts/prototype_review/hybrid_diorama_v1/diagnostics/native_proof.json), [Compatibility proof](../../artifacts/prototype_review/hybrid_diorama_v1/diagnostics/compatibility_native_proof.json)
- [Pixel depth analysis](../../artifacts/prototype_review/hybrid_diorama_v1/diagnostics/pixel_depth_analysis.json)
- [Mobile steady metrics](../../artifacts/prototype_review/hybrid_diorama_v1/diagnostics/mobile_steady_performance.json), [Compatibility metrics](../../artifacts/prototype_review/hybrid_diorama_v1/diagnostics/compatibility_steady_performance.json)

Lighting modes, facing modes, alpha modes and four-layer comparison captures reside in `diagnostics/`. The movie records actual navigation, including actor front/behind behavior, with capture timestamps rather than an artificial speed-up. No audio was added.

## 11. Tests / regressions

| Executed suite | Checks | Result |
|---|---:|---|
| Existing approved café recovery / tour / service / receipt | 39 | PASS |
| Existing continuous Home / traversal / save/load | 28 | PASS |
| Existing world / actor / navigation / camera architecture | 172 | PASS |
| Existing Focus command / persistence / reward behavior | 33 | PASS |
| New native Mobile proof | 69 (34 semantic + 35 artifact-write) | PASS |
| New native Compatibility proof | 69 (same cases, second backend) | PASS |
| Fixed-render pixel depth cases | 4 per backend, 8 executions | PASS |
| New launcher path / identity / verified intake | 7 | PASS |

**410 GDScript assertions across these executed suites**, plus 8 pixel-analysis cases and 7 Python launcher checks. These are executions, not 410 unique feature scenarios. Existing regression counts were instrumented only in temporary copies. New native proof includes static triangle preservation, source SpriteFrames identity, mappings, ground contact, picking inverse, seven real routes, clip/frame sync, original service reward/dedupe and source-authority parity.

Final proof/profile/regression logs contain no runtime SCRIPT ERROR/ERROR. The full editor import scans unrelated inherited legacy resources and warns about `Scripts/` versus `scripts/` case mismatches; those sources were not edited and case-sensitive export remains a future host gate. No phone/WebView build is claimed.

## 12. Baseline / rights / production integrity

**All 3,559 pre-existing repository files checked: unchanged; no missing files. All 164 review-bound café files: exact hashes match.** This includes approved source/runtime images, original tree source/motion/resources, existing scenes/coordinates, Factory contracts and style calibration. See [parity record](../../artifacts/prototype_review/hybrid_diorama_v1/diagnostics/baseline_parity.json).

Visible materials/cat/contact use existing first-party files only. No competitor or third-party raw artwork entered the diorama; feature documentation does not confer provider rights. No image-to-3D/image-generation invocation or credit charge occurred. No new production rights decision, authenticated approval, Factory publication, save migration, commit or push was made. The new 3D representation has no approved production profile/publisher authorization.

## 13. Migration / AI workflow impact

KEEP: gameplay semantics, IDs, seats/actions/anchors, 2D navigation/collision, save/load, economy, relationships, Focus, event system, orange source and clips. ADAPT only under a later approved contract: visual projection, environment geometry/materials/UVs, camera/picking, lighting/shadows, environment animation, import and Factory evidence/validation. Replace 2D occlusion presentation only for individually converted objects after proof; do not replace the 2D authority.

Most practical further study: geometry-template-first procedural modular meshes, existing/approved painted textures, deterministic export/batching and human material review. Image-to-3D may supply draft source but needs scale/topology/UV/material/rights cleanup; no tool was integrated. Pre-rendered 3D → registered 2D remains an untested fallback. The human is not required to become a professional modeller.

## 14. Remaining risks / exact next permitted step

Open: painterly material/contour and silhouette calibration; cat shading/card appearance at scale; Mobile/Compatibility palette parity; multi-cat transparency; UV2/bake/probes and movable furniture; target-phone cost/thermal behavior; touch ergonomics; native versus web host; 3D asset registration/approval/profile design. No unsupported geometry or numeric acceptance thresholds were invented.

**D. MORE RESEARCH REQUIRED.** Next: human review of this moving, side-by-side evidence and a decision on whether a narrowly bounded material/light/device study is worth authorizing. Do not automatically expand this spike, convert Home/Riverside, build a second café, change saves, regenerate the cat or migrate the Factory.

WILLICAT HYBRID 3D DIORAMA RESEARCH + FEASIBILITY SPIKE V1
— READY FOR HUMAN REVIEW
