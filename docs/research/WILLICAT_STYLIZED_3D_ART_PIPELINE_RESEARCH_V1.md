# WilliCat Stylized 3D Art Pipeline Research V1

## 1. Decision and evidence scope

**Engineering/art recommendation: A. CURRENT 2D REMAINS BEST for the current game.** This spike improves actual geometry, registration, material reuse and moving depth over the previous hybrid. It has not established a material visual improvement over the approved 2D café. Pre-rendering cleans sampling and removes live geometry cost for a still; it does not add painterly design or prove a moving modular 2D game. **Human visual preference: OPEN.** No 3D migration, production publication or replacement was performed.

Date: 2026-10-01. Native test: Godot 4.7.2, `ed1daf0bf001b61586d9930840f2f1394092c079`, Mobile/Metal 4.0, Apple M2 Pro. OBSERVED = visible frames; MEASURED = recorded native/analysis output; DOCUMENTED = linked primary source; PROPOSED = a future workflow; UNTESTED = no experimental claim. Creative model dimensions/light settings are DEV art choices, not new Home measurements, approved templates or calibrated global tolerances.

Authorities: [Style calibration](../art_direction/WILLICAT_STYLE_FAMILY_CALIBRATION_V1.md), [style record](../asset_factory/style_families/WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1.json), [approved café decision](../production/WILLICAT_CAFE_VISUAL_FIDELITY_RECOVERY_V1_HUMAN_REVIEW_DECISION.md), [previous hybrid result](../production/WILLICAT_HYBRID_3D_DIORAMA_FEASIBILITY_SPIKE_V1_RESULT.md). The style record's approved 2D runtime designation remains unchanged; this task authorizes an isolated 3D presentation experiment using its material vocabulary.

Hero art/mood ceiling inspected: the human-supplied `codex-clipboard-2ec56610-c2f2-42d0-851a-f7a747b92645.png`; family board: `codex-clipboard-3ef99a70-ff37-4cd5-8fd4-de384ab269b8.png`. Their original attachment paths/hashes are retained in the input receipt. Reference image pixels were not sent to generation or copied into materials.

## 2. Previous hybrid limitations / bounded response

| Previous evidence | Response in this spike | Remaining limit |
|---|---|---|
| 35 mesh batches / 13,410 triangles; primitive jars/leaves and no espresso machine | Profiled lathe forms, hollow ceramics, framed cabinet, articulated espresso equipment, curved leaves | Some forms still have a procedural regularity and sparse illustrated contour |
| Full 6.4×10 floor with a sparse left furniture group | One L-shaped displayed floor section around the existing service/seating/plant region | Miniature silhouette differs from full approved café composition |
| Cropped sprite luminance multiplied into flat material colors | Reusable painted albedo family, triplanar sampling, differentiated palette/edge values | Grain is still more uniform than bespoke 2D painting |
| Camera-facing cat card and functional lighting | Upright billboard, tint/shadow comparisons, practical close-ups and stronger root/mesh tests | Billboard is not a volumetric cat; fixed camera only |

No whole café, roof, town, Riverside or gameplay rebuild was undertaken.

## 3. Geometry fidelity

| Family | Actual authored construction |
|---|---|
| Floor / wall | Beveled staggered floorboards, shallow plinth, cedar post/rail joins, quiet segmented cream wall |
| Opening | Real wall recess between segments, paper backing, deep jamb/lintel, projecting sill, shoji members |
| Counter | Thick continuous top; recessed framed front panels, side recesses, toe kick; solid bases registered to existing counter and espresso footprints |
| Espresso | Beveled wood/cream housing, extraction recess, groups/handles, steam wand, gauges/hands/buttons, grooved tray and cups |
| Shelf / lamp | Thick shelf offset from wall, diagonal brackets, jars/books, quiet sign; profiled ribbed lantern and cord |
| Table | Rounded bevel profile, apron bead, turned pedestal with collar, shaped splayed feet; cup and small bud vase |
| Chairs | Splayed legs/stretchers, layered seat/cushion, deep back posts/crown/spindles, sage inset |
| Planter | Hollow tapered stoneware profile, rim/bands/soil, branching curved leaf masses |

MEASURED: **283 authored pieces → 58 mesh batches, 39,272 triangles**; before/after batching equality is asserted. Common prior helper is composed unchanged; the new lathe/leaf grammar is in `scripts/dev/stylized_fidelity/authored_forms.gd`. No Blender or new modelling application was required. Bevels, contrasting recesses and selected lighter edges carry form; imperfections stay in restrained painted variation rather than making every object crooked.

A first wider opaque counter incorrectly occupied an existing free path: 14 tour root samples intersected that visual body. Self-QA rejected it. The final main cabinet reads exact counter footprint `(78,135.5; 224×55)`, and the separate support reads exact espresso footprint `(373.5,141.5; 73×45)`. The continuous slab bridges a genuinely open undercroft. The espresso follows its existing `(410,182)` root with the measured footprint-center offset. **The mesh changed; navigation and coordinates did not.** Final tour roots never enter either solid cabinet footprint. This regression is retained explicitly; a screenshot alone would not reveal it.

## 4. Material language / shader experiment

Twelve used environment mesh materials: eleven instances of one restrained painted-albedo spatial shader plus charcoal trim StandardMaterial3D. The unused glass proposal is not counted. Sprite/text internal materials are separate. Surface families: cedar light/mid/recess, cream plaster/paper, muted sage fabric, warm off-white/indigo ceramics, charcoal trim, three foliage values.

`painted_albedo.gdshader` samples color textures with triplanar weights, selected vertex edge values and modest material tint. Roughness .96; specular disabled; metallic remains zero. No photo textures, chrome, normal/ORM maps, cel outlines or automatic beauty score. The shader supplies reusable painted color with real diffuse form response; it does not claim a fully hand-painted illustrated finish.

## 5. Texture authoring / provenance

| Source | Method / retained identity |
|---|---|
| Cedar | **One** built-in imagegen text-only generation, 1536×1024 immutable original; deterministic Lanczos export 512×512. Exact prompt/source and export hashes retained. Model/seed/cost unavailable from tool are not invented. |
| Plaster, sage weave, ceramic, foliage | Original deterministic layered-noise/brush-scale recipes, seed 41071; four 512×512 albedos. Reproduction produced four byte-identical PNGs. |
| Cat / contact texture | Exact existing first-party orange down/up/left/right sheets and contact-shadow texture; no regeneration or repaint |

Runtime scene references five new reusable albedos plus five existing cat/contact files. Font atlas and engine render-target allocations are not included in this **file** count. No third-party pack imagery or photographic material was used. Source generation is authorized for this DEV spike; no production rights clearance or authenticated approval is inferred. Details: `assets/dev_review/stylized_fidelity_v1/texture_provenance.json`, retained generated source, recipe and toolchain receipt.

## 6. Lighting hierarchy

One broadly neutral directional key, quiet warm-neutral ambient fill and one restrained warm lamp accent. Key .68 / ambient .60 / practical .22 are experimental settings. Primary filtered geometric shadows: opacity .48, blur 3; no bloom, fog, depth of field, vignette, LUT or golden-hour wash. Orthographic form/cabinet depth is visible under ordinary lighting. The lamps/ceramics accent service; the orange actor remains a color focal point.

Three lighting treatments are captured at the same pose: ambient; key+ambient; key+ambient+practical, including dedicated lamp views. No claim of a baked indirect contribution is made.

## 7. Shadows, AO and LightmapGI decision

| Method | Status / decision |
|---|---|
| Filtered real cast shadows | MEASURED: one shadowed directional, **58 mesh casters**; selected for live geometric grounding |
| Registered contact sprites | MEASURED: counter/support/table/chairs/pot + cat contacts; small restrained grounding |
| Authored cavity / edge values | MEASURED: recessed construction, toe kick, darker joinery/soil and bevel vertex values; selected; not a physically baked AO map |
| SSAO | Not enabled. Godot 4.7 documents no Mobile SSAO; Compatibility support does not make it a common Mobile solution. [Renderer feature matrix](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html). |
| LightmapGI | DOCUMENTED mobile-capable baked lighting; **not baked here**. Runtime-built meshes have no prepared UV2/save/bake/probe fixture. Material/registration QA consumed the useful scope; a bake would add an unvalidated asset/import workflow. Setup cost was judged disproportionate for this first art comparison. No measured LightmapGI gain or cost is claimed. [Lightmap workflow](https://docs.godotengine.org/en/4.7/tutorials/3d/global_illumination/using_lightmap_gi.html). |

Baked AO/lightmaps could reduce realtime shadow dependence in a future fixed-layout pilot; movable furniture, probe response and lighting variants would need new evidence. The present contact/cavity approach is portable and inspectable, with visible dynamic cast shadows.

## 8. Cat integration and moving depth

The original authoritative Vector2 actor/nav and exact SpriteFrames still drive the AnimatedSprite3D clip/frame/progress. Mapping is the prior reversible `.01` unit projection. Ground offset 104 comes from the existing 232px contact in the 256px cell. No card cast shadow in the selected mode.

Compared unshaded white modulation vs restrained ambient tint `(.95,.965,.945)`. Selected tint is a fixed presentation treatment for this neutral rig; it is **not** a dynamic relighting system. Camera-facing / fixed-Y upright / fixed-facing and alpha modes were captured. Fixed-Y upright avoids leaning the upper sprite into a nearby tabletop. DEV presentation-only vertical scale compensates camera-up foreshortening by `1 / abs(camera.global_basis.y.y)`; the final proof asserts preserved authored screen height, while the root stays locked. Original image pixels are unchanged. Blob, card-cast+contact and reduced-opacity hybrid contact were actually compared; the selected hybrid contact avoids card-shadow artefacts while surrounding objects cast real shadows. [Sprite flags/alpha/billboard API](https://docs.godotengine.org/en/4.7/classes/class_spritebase3d.html).

Six **existing** navigation targets: counter front/back, table back/side/front and derived chair-back. The entrance outside the displayed floor is excluded from this micro-tour. Initial automatic navigation enters the presented region; floor picking rejects the cut-away/outside regions without editing world navigation. Genuine mesh depth handles occlusion; no manual 2D occluder switching is used in Live Hybrid.

| Case | Overlap | Object dominant | Cat dominant | Unclassified |
|---|---:|---:|---:|---:|
| counter_back | 1444 | 1436 | 5 | 3 |
| counter_front | 1034 | 7 | 1024 | 3 |
| table_back | 1043 | 760 | 281 | 2 |
| table_front | 902 | 39 | 857 | 6 |


Four fixed-camera layers isolate object/cat/background/combined. RGB delta >12 and L1 margin 5 are **analysis choices**, not art quality tolerances. Exposed limbs/gaps and shadow-mask fringes explain partial classifications. Moving video plus screenshots corroborate the result; roots/footprints/anchors and original service behavior are separately checked.

## 9. Orthographic composition

Camera3D KEEP_WIDTH, size 7.15, position `(4.55,12,16.1)`, target `(2.90,.57,3.3)`. Elevated 3/4, small azimuth; portrait native 504×896. This camera belongs only to the DEV projection. Back: opening/shelf/lamp; middle: continuous service top/machine/actor; front: table/chairs/rug/planter. The L-shaped display reduces unused right-side floor. No canonical 2D camera field is rewritten.

## 10. Live Hybrid visual result

OBSERVED: substantial improvement in recessed construction, real equipment, table/pot profiles, reusable painted surfaces and correct free under-counter passage. True form/light/contact and between-object depth are readable. Remaining shortcomings: relatively regular wood grain, simpler planter/ceramic silhouettes, thinner illustrated contour vocabulary, quieter bespoke rear dressing, and a sparse miniature composition. The upright cat is readable but remains a shaded/tinted plane. These are substantive art limits, not test failures that can be renamed as visual approval.

## 11. Pre-rendered 3D → 2D result / modular sample

The **exact live micro-diorama**, materials, lights and primary camera render into a shared-world SubViewport at 1008×1792 with 4× MSAA. The existing idle cat pose is included. The native **2D TextureRect comparison scene** displays that exact baked image; this is more than a filename copied from the live screenshot. No relighting, painting or scene reconstruction occurs between B and C.

OBSERVED: cleaner small edges/grain through supersampling, same artistic strengths/weaknesses. **C is a static comparison, not a moving pre-rendered gameplay proof.** The 2-draw static cost cannot be presented as the cost of a complete animated modular 2D world.

A separate table RGBA specimen uses the **same gameplay camera basis**, translated/framed for the object. Its crop and pivot derive from the captured ground-root projection; alpha is measured 0…255. Cups/vase are currently batched with it; future modular production needs independent prop/state and shadow layers. One whole micro-scene still is DEV feasibility evidence only; it is not a giant-room production asset.

PROPOSED production translation: retain versioned 3D masters → fixed camera/resolution renders per object/direction → separate contact/front/state layers → exact pivots/baselines/footprints → existing Forge → frozen validators/reviews → 2D prefab. Seasons need compatible texture/foliage master variants and repeated layer/pivot checks. No such production pipeline was built.

## 12. Fair approved-2D comparison

A is freshly captured from the **unchanged approved full café**, after real navigation to the same `(325,355)` hero actor point. B/C share the exact new scene/camera/pose, palette and light mood. All panes preserve native aspect and have no beauty retouching. Full approved A is retained intact; no density/detail/lighting was removed to make B win.

**Comparison limitation:** A has two seating groups and richer approved dressing; B/C are the required one-table micro-region, with a slightly different camera and cut-away silhouette. This is a family/fidelity decision, not a strict equal-layout benchmark. Close-up and individual-object evidence expose surface/silhouette quality so that fewer objects are not mistaken for lower per-object fidelity. The preserved A advantage cannot justify a claim of universal 2D superiority; the conservative recommendation applies to the evidence produced here.

| Visual criterion | A approved 2D | B Live Hybrid | C same master, baked 2D |
|---|---|---|---|
| Depth | Authored overlap/Y-sort already accepted | Actual volumes/occlusion demonstrated | Volumes preserved in this fixed still; moving layer grammar unproved |
| Materials / painterly identity | Rich approved brush/contour family | Painted wood/quiet matte family; regularity remains | Same art, cleaner sampling |
| Cat cohesion/readability | Current human-approved baseline | Original identity retained; upright plane/tint still visible | Exact baked pose; animation absent |
| Miniature/grounding | Accepted intimate café composition | Real plinth/profile/contact/shadow form | Same fixed view grounding |
| Atmosphere/consistency | More bespoke lived-in richness | Restrained light, fewer bespoke cues | Same light; cannot improve design by baking alone |

These are agent observations. Human preference remains open.

## 13. Mobile complexity / measurement limitations

| Inventory | Previous hybrid | Final art-fidelity scene |
|---|---:|---:|
| Mesh batches | 35 | 58 |
| Mesh triangles | 13,410 | 39,272 |
| Used mesh materials | 12 | 12 |
| Referenced scene texture files | 9 | 10 |
| Sprite3D-family transparency components | 2 | 8 |
| Realtime lights / shadowed lights | 2 / 1 | 2 / 1 |
| LightmapGI / SSAO | No / No | No / No |
| New live SubViewport / postprocess passes | 0 / 0 | 0 / 0 |

One custom spatial shader resource with different material parameters; one Label3D and its generated font resources are recorded separately. All 58 environment meshes cast shadows; contact/cat cards do not. The temporary high-resolution bake viewport is absent from live gameplay.

| Branch | Draws | Rendered primitives | Texture MiB | Video MiB | Wall frame wait ms | Engine TIME_PROCESS ms |
|---|---:|---:|---:|---:|---:|---:|
| approved_2d | 99 | 1272 | 107.25 | 157.31 | 8.287 | 13.458 |
| previous_hybrid | 78 | 27178 | 159.52 | 218.12 | 8.304 | 14.593 |
| stylized_hybrid | 131 | 78968 | 165.03 | 226.12 | 8.328 | 15.473 |
| prerendered_static_2d | 2 | 144 | 6.92 | 35.48 | 8.320 | 9.674 |


MEASURED fresh-process medians: same machine/renderer/4× MSAA, 3s scene warmup +1.3s settling, 240 samples discard first 60; no image readback during samples. The previous hybrid was remeasured under the common AA setup, rather than substituting its earlier 2× AA timings. A separate sequential profile is retained: its texture counter wrapped after resource teardown and is **excluded** from memory conclusions. It also shows why TIME_PROCESS and frame-wait samples cannot be treated as interchangeable.

Wall waits near display-vsync pacing are not GPU execution measurements or phone FPS promises. Video/texture counters are engine allocations, not measured physical VRAM/RSS. Live hybrid memory includes the hidden original 2D authority scene and loaded visual resources; stripping that presentation dependency is a future integration question. Transparent overdraw, shadow passes, thermal behavior, WebView/web Compatibility behavior and phone hardware remain **UNTESTED**.

## 14. AI-assisted 3D production options

| Option | Evidence / practical judgement | Human skill burden / limit |
|---|---|---|
| 1. Style → scripted geometry/profile/bevel → painted texture → Godot | **Executed**. Agent creates semantic shapes, deterministic forms and one generated material; repeatable object family and visible QA | Human art decisions remain essential; no manual Blender modelling needed. Best near-term authoring mechanism for hard-surface props |
| 2. Concept → agent reconstruction → material → cleanup | **Partly demonstrated** through reference-informed authored forms, not automated image reconstruction. PROPOSED explicit silhouette/part breakdown and registration template | Good for constrained café props; underside/back geometry and scale need inspection |
| 3. Image-to-3D → cleanup/simplification/material replacement | **DOCUMENTED capability / UNTESTED here**. [TripoSR official repository](https://github.com/VAST-AI-Research/TripoSR) provides single-image reconstruction. No model/weights/source pack installed or used | INFERRED: silhouettes/back surfaces, topology, scale/pivots and baked illumination need cleanup. No claimed quality, cost, mobile readiness or input-rights permission |
| 4. 3D master → fixed orthographic modular 2D | **Executed for one transparent table specimen and static hero**; strong reuse potential with familiar 2D runtime | Independent direction/layer/animation contracts and actual modular moving-actor proof remain necessary |

The [SurfaceTool API](https://docs.godotengine.org/en/4.7/tutorials/3d/procedural_geometry/surfacetool.html) supplies deterministic mesh construction/normals/indexing. This spike composes existing geometry/batching, not a custom DCC or provider platform. Agent geometry automation does not replace human art review or deterministic validators.

## 15. Production implications and reusable systems

Vector2 world/navigation, actors, service/Focus, save/load, economy/receipt idempotence, relationships, stable IDs, interactions and original asset Forge remain intact. Reusable new DEV findings: profile/bevel grammar, painted materials, shadow/contact treatment, primary projection and object bake metadata. Existing source/runtime separation and frozen Factory gates remain the required production handoff.

Live migration risk is **material**: richer meshes/shadow/transparent passes, hidden-2D resource dependency, arbitrary-route grounding beyond tested paths, billboard/view changes, renderer differences, new category registration and real-device requirements. Pre-rendered migration has less runtime-domain change, but direction/layer/state/shadow proliferation and source-version invalidation remain substantial. No production suitability is certified.

## 16. Limits and next decision

No LightmapGI bake, full custom painterly diffuse quantization, procedural beauty score, image-to-3D execution, phone test, crowd test, full-room migration, production prefab or Factory gate bypass. Only the tested actor route and root/body integrity are claimed; exhaustive arbitrary-path 3D contact parity is not established. C has no moving sprite/layer integration. The supplied Hero remains a polish/mood ceiling.

**A. CURRENT 2D REMAINS BEST — engineering recommendation for the current project.** Keep the approved café as its quality baseline. A human may choose a further narrowly scoped modular pre-render or live material/contour pilot after reviewing this evidence; neither is started automatically. Visual acceptance and any rendering migration require a separate decision.

[Result and exact evidence index](../production/WILLICAT_STYLIZED_3D_ART_FIDELITY_SPIKE_V1_RESULT.md).
