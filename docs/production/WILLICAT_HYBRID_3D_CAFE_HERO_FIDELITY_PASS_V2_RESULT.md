# WILLICAT HYBRID 3D CAFE HERO FIDELITY PASS V2 RESULT

**Status:** completed isolated DEV/REVIEW art iteration; human visual decision **PENDING**. Production migration/publication is not authorized. Same V1 café, gameplay authority and exact common camera; no layout redesign. **No image generation calls or new texture files.**

## 1. V1 gap / bounded response

| V1 observation | V2 response |
|---|---|
| Busy common cedar multiplication makes many surfaces read alike | Role-specific cedar/light/mid/dark, quiet wood floor, cream stone versus plaster/ceramic, shared palette and value-map treatment |
| Espresso lacks a readable control/face hierarchy; equipment reads as separate props | Cream casing / charcoal fascia, raised control header, four cream keys, side cheeks, cup-deck lip, grinder controls; no replacement machine |
| Six repeated rear planters and generic table leaves | Four authored plant roles with different silhouettes, plus selective muted flowering and hanging foliage |
| Uniform jars, isolated furniture and little coffee-specific life | Muted indigo jar accents, supported cup/jar pair, small cloth, shelf cup, two small pastries on the existing display cabinet |
| Functional lighting / bright flat actor | Neutral-warm key, quiet fill, localized practical; less dark actor tint and soft floor contact |

Hero remains a mood/material/quality ceiling only. Its layout, stairs, exterior, extra furniture/cats and baked text are not copied. Approved 2D and formal style record are unchanged; true3D remains this explicitly authorized DEV presentation experiment, not a production style/runtime migration.

## 2. Material specificity / painterly finish

Shared families: cedar light/mid/dark, floor wood, cream stone, cream plaster, sage fabric, warm ceramic, charcoal trim / dark metal, foliage pigment, paper/lantern, restrained indigo/coffee, woven rug and small pastry/petal accents. **18 materials are active in the final geometry**; the resource library also contains fallback/import mappings which are not all active at once. No unique per-object materials.

Cedar uses the existing first-party V1 brush texture; other maps are original kit plaster, fabric, ceramic and foliage. All five PNGs are unchanged. `painted_family.gdshader` derives restrained value changes around a role-specific source-color palette, instead of multiplying the same colored texture into every role. Two broad smooth brush fields and local normal-led edge warmth add subtle irregularity. No pixel-noise generator, photo, grunge, normal maps, toon outlines or beauty scoring.

Cedar light/mid/dark follow #C68F5E / #9B6D44 / #583F2E anchors. Other authored variations are explicitly DEV choices inside the approved family, not new canonical swatches or tolerances. Cream stone top is now a separate imported material assignment; panel beads stay cedar. Ceramic/metal use restrained specular with high roughness, zero metallic. Plaster/fabric remain quiet and matte. Parameters, palette and exact texture references: `assets/dev_review/hybrid_cafe_hero_fidelity_v2/material_recipe.json`.

## 3. Service zone / espresso and grinder

Only **five existing Blender sources** were revised: three counter modules, espresso and grinder. Twenty-two V1 GLBs are referenced unchanged. Service-root attachment/footprints and original countertop height remain intact. Source revisions and exports are separate, not destructive replacements.

- Counter: only top faces switch to cream stone; current panel/trim construction stays.
- Espresso: current housing, heads, gauges, tray, wand and cups preserved; cream casing / dark fascia, four keys, header, cup-deck lip and softened side cheeks establish a clearer workstation silhouette.
- Grinder: control panel/key, dose-cup support and hopper collar give the original body more identity.
- Existing counter surface: small cloth/cup group and jar pairing. Existing upper shelf: one cup; selected jars share muted indigo glaze. Existing pastry cabinet: replace inherited cup/jar display dressing with a shallow ceramic tray and two understated crescents, avoiding overlap. No new gameplay item/interaction/save ID or extra display furniture.

| Existing component | V1 triangles | V2 triangles |
|---|---:|---:|
| Counter_Straight_A | 5020 | 5020 |
| Counter_End_A | 2104 | 2104 |
| Counter_Short_A | 2104 | 2104 |
| Espresso_A | 8184 | 9048 |
| Grinder_A | 884 | 1316 |

Blender cavity colors are rebaked for revised geometry using the prior DEV recipe. Input/source/GLB hashes, measured bounds, normals/UVs and triangle parity are retained. Geometry dimensions are authoring choices; no Home measurement/calibration limit was invented.

## 4. Organic layering / architectural softening

| Role | Placement relationship | Distinct grammar |
|---|---|---|
| `trailing` | Existing upper shelf end | Three curved static strands, alternating rounded leaves, below-pot overlap |
| `floor_lance` | Exact existing plant GameplayRoot/foot center | Taller lance leaves, varied rising arcs; same imported ceramic pot/soil |
| `shelf_fan` | Existing window/shelf surfaces and secondary table pot | Compact fanned leaf masses |
| `flowering` | Existing sill and primary table pot | Restrained cream/pink petal clusters, lower foliage mass |

Seven plant instances use these four roles. Original generic foliage surfaces are removed from these visual instances; imported ceramic pot/soil/stem remain. They are not seven identical scaled clones. No new ground obstacle, jungle coverage or vegetation pack. Modest joint caps use existing rear spans; the garden aperture remains clear. Rug and table centerpieces refine the existing seating regions without moving furniture.

Initial batching dropped non-indexed leaf/joinery geometry. Explicit indices/colors were added before SurfaceTool append; triangle preservation is now an actual passing test. Failed iteration evidence is retained in `diagnostics/iteration_01_failed_native_proof.json`. Semantic asset IDs identify duplicate plant instances reliably rather than trusting auto-renamed node names.

## 5. Lighting / grounding / cat

Two lights, one shadow caster light: existing directional key and localized practical. Key #FFF4E4 energy.92; fill #E9EBE5 energy.52; practical #F3CE99 energy.50 / range1.9. Key direction and common camera unchanged from V1; shadow opacity.46. These are DEV art settings, not quality thresholds.

No bloom, SSAO, LightmapGI, fog, DOF, orange wash or cinematic sunbeams. Existing real geometric cast shadows + contact sprites and restrained vertex cavity ground major forms. Small rear/table foliage and tiny pastries do not cast expensive geometric shadows; floor plant foliage retains a cast shadow. No dirty black cavity outlines.

Exact canonical orange SpriteFrames/pixels/clips, upright billboard, alpha/depth behavior and actor scale remain unchanged. Default ambient tint (.985,.975,.96) is **less dark than V1**; protagonist contact opacity.28. A/B/C sprite-mode diagnostics remain available. The cat is never repainted, remodeled or manually switched around occluders.

## 6. Frozen camera / layout

Native test loads unchanged V1 first, records its common transform/size and all visual group registration transforms, then compares V2. **Exact equality passes.** Orthographic KEEP_WIDTH size7.65, position(5.15,13.2,20), original look-at basis. Same actor navigation approach325,300 →325,355, same entrance/counter/seating roots and original 2D authority.

Close-ups are additional labelled native views; they are never substituted for the primary same-camera comparison. No crop trick, free rotation, stairs, second floor, new room/circulation or furniture density increase. Decorative plants/props are presentation-only support-surface dressing, not edits to canonical world data.

## 7. Performance before/after

Native Godot4.7.2 Mobile/Metal, Apple M2 Pro; same isolated project/settings. Final paired profile protocol: wait for scene readiness, foreground window, five-second warmup, 240 frames / last180 samples, no screenshot readback during sampling. Count metrics are direct runtime observations.

| Indicator | V1 | V2 final |
|---|---:|---:|
| Visible meshes | 64 | 71 |
| Geometry triangles | 143824 | 122004 |
| Visible surfaces | 178 | 182 |
| Mean draw indicators | 149.0 | 156.0 |
| Lights | 2 | 2 |
| Shadow lights | 1 | 1 |
| Active shared materials | 17 | 18 |
| Geometry texture resources | 5 | 5 |
| Texture allocation MiB | 217.95 | 170.27 |
| Engine process monitor mean ms | 13.27 | 22.74 |

Net geometry falls by **21,820 triangles (~15.2%)**, despite service refinements, because simpler role foliage replaces dense repeated original leaves. Before foliage optimization V2 had81 meshes /20 active materials /179 draw indicators. Vertex-authored dark/mid/light pigments now share one foliage material; small leaf shadow work is reduced. Final draw indicators still exceed V1 by7 (~4.7%): added service/detail surfaces remain a cost, not a performance victory.

Engine process-monitor samples repeat discrete values and vary strongly; these means do **not** establish a trustworthy CPU/GPU speed ratio or phone FPS. GPU timing and real-device performance remain unmeasured. Allocation includes hidden2D authority, embedded import resources, avatars and contacts; grouping/pruning changes lifetime/allocation and is not a shipping-memory budget. Risks: two-sided leaf overdraw, alpha prepass for avatars, shadow bandwidth and material/surface count. No phone-performance PASS or mobile migration approval.

## 8. Playable proof / exact tests

- Final native Hybrid/camera/27-import/registration/depth/service proof: **349 checks PASS**.
- Imported cavity color checks: **14 PASS** (prior revised sources plus new grinder).
- Real screen-click input: **5 PASS**.
- Launcher safeguards/fresh project/main scene/namespace/approved Café binding: **9 PASS**.
- Four-layer counter/table front/behind raster cases: **4 PASS**.
- Existing regressions: Café39, continuous Home28, world/navigation172, Focus33 = **272 PASS**.
- Original content parity: **4572 pre-task files unchanged**, plus approved Café human binding164/164.

No fabricated visual gate PASS. Motion proof uses actual existing navigation and walk clips. Make Coffee completes the original customer/service flow, rewards once and rejects duplicate reward. Original repository tests are unchanged; temporary Home/world copies add counters only. Focus test uses a separate temporary project/save namespace. JSON/logs identify exact executions. Raster delta12/L1 margin5 are analysis-classification choices, not art/motion acceptance tolerances.

## 9. Evidence / controls

Scene: `scenes/dev/hybrid_cafe_hero_fidelity/hybrid_cafe_hero_fidelity_v2.tscn`.
Launcher: `tools/willicat_cafe_hero_fidelity/Open_Cafe_Hero_Fidelity.command`.
Fresh isolated `/private/tmp` project; namespace `WilliCatCafeHeroFidelityDEVV2`. Click floor, **Depth Walk**, **Make Coffee**, **2D Baseline**. No publisher/production ability is added.

All evidence: `artifacts/prototype_review/hybrid_cafe_hero_fidelity_v2/`.

| File | Meaning |
|---|---|
| [01_ART_DIRECTION_V1.png](../../artifacts/prototype_review/hybrid_cafe_hero_fidelity_v2/01_ART_DIRECTION_V1.png) | Fresh unchanged V1 native capture |
| [02_HERO_FIDELITY_V2.png](../../artifacts/prototype_review/hybrid_cafe_hero_fidelity_v2/02_HERO_FIDELITY_V2.png) | Final V2, exact same common camera |
| [03_V1_V2_SIDE_BY_SIDE.png](../../artifacts/prototype_review/hybrid_cafe_hero_fidelity_v2/03_V1_V2_SIDE_BY_SIDE.png) | Unresized native frames pasted with labels only |
| 04_SERVICE_ZONE_CLOSEUP.png | Machine/control/stone/ceramic/shelf hierarchy |
| 05_MATERIAL_CLOSEUP.png | Material specificity and service surfaces |
| 06_PLANT_LAYERING.png | Authored shelf/window/trailing/flower roles |
| 07_CAT_ENVIRONMENT_INTEGRATION.png | Original cat, value relationship and floor contact |
| 08_GAMEPLAY_SCALE.png | Native primary framing / gameplay-scale readability |
| [WILLICAT_HYBRID_3D_CAFE_HERO_FIDELITY_PASS_V2.mp4](../../artifacts/prototype_review/hybrid_cafe_hero_fidelity_v2/WILLICAT_HYBRID_3D_CAFE_HERO_FIDELITY_PASS_V2.mp4) | Actual moving cat/depth tour, recorded timestamps preserved as VFR |

`diagnostics/` contains camera, authority checks, four-layer depth, sprite modes, coffee loop, before/final/pre-optimization profiles, failed iteration, regression logs, protected-file parity, provenance and toolchain/artifact hashes. Godot import cache is temporary and not evidence source-of-truth. DEV proof is not canonical Factory integration approval.

## 10. Human quality question / remaining Hero gap

| Criterion | Evidence-based agent observation; human acceptance remains open |
|---|---|
| Painterly identity | More role-specific pigment/value treatment and calmer grain; **partial** improvement. Still cleaner and more geometrically regular than Hero illustration. |
| Café-specific richness | Clearer machine/control/grinder/cup workstation, distinct jars, restrained pastry group: visible improvement. Still fewer bespoke coffee/pastry silhouettes. |
| Material differentiation | Cream stone caps, timber panels, sage cushions, indigo/cream ceramics and charcoal equipment separate clearly at fixed camera. |
| Organic life | Distinct tall/fan/trailing/flower silhouettes improve layering, with fewer triangles. Still less botanical nuance/trailing fullness than Hero. |
| Cat/environment cohesion | Exact artwork preserved; less dark tint and floor contact retain readability. Billboard flatness remains a deliberate hybrid limitation. |
| Premium miniature feeling | Real depth and construction remain useful; service/material/plant hierarchy is stronger. **Hero-level premium finish is not established.** |

## 11. Recommendation / production boundary

V2 is a meaningful bounded improvement in material separation, café identity and organic silhouettes; it does not establish visual superiority over approved2D or parity with Hero. **Recommend human same-camera visual decision now.** If the human accepts this fidelity as sufficient, a separately authorized real-device mobile viability pilot is the next useful test. If not, prioritize bespoke service/foliage/material finishing within the same kit, rather than another layout or architecture reset. Do not auto-start another art pass or mobile migration.

No Home/Riverside migration, approved2D replacement, gameplay/nav/anchors/save/semantic change, new room/stair/floor/furniture plan, new cat/image generation, Factory-gate weakening, commit or push. Rights/authentication/publisher requirements and human visual veto remain intact.

WILLICAT HYBRID 3D CAFÉ HERO FIDELITY PASS V2
— READY FOR HUMAN VISUAL DECISION
