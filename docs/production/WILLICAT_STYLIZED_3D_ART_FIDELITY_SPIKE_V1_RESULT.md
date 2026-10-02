# WilliCat Stylized 3D Art Fidelity Spike V1 — Result

## 1. Status

| Area | Result |
|---|---|
| Isolated implementation / native moving proof | PASS — 86 assertions/capture checks |
| Counter solid-body / authority root correction | PASS — 0 tour roots inside the final solid cabinet footprints |
| Four raster depth cases | PASS; masks/limits retained |
| Original café / Home / world / Focus regressions | PASS — 39 + 28 + 172 + 33 = 272 executed checks |
| Floor-picking / authority preservation | PASS — 7 checks |
| Actual automatic hero startup | PASS — 4 checks |
| Actual baked 2D presentation | PASS for a **static** comparison only |
| Human visual decision | OPEN / PENDING |
| Engineering recommendation | **A. CURRENT 2D REMAINS BEST** based on this evidence |
| Production migration/publication | NOT AUTHORIZED / NOT EXECUTED |

Technical PASS does not confer Visual PASS. The previous primitive Hybrid is the technical starting point; the approved 2D café remains the baseline; the Hero remains the art/mood ceiling.

## 2. Runnable deliverables

- Micro-diorama: `scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn`.
- Actual 2D bake view: `scenes/dev/stylized_fidelity/prerendered_cafe_comparison_v1.tscn`.
- Live launcher: `tools/willicat_stylized_fidelity/OpenStylizedDiorama.command`.
- Baked launcher: `tools/willicat_stylized_fidelity/OpenPreRenderedComparison.command`.
- Source: `scripts/dev/stylized_fidelity/` and `assets/dev_review/stylized_fidelity_v1/`.
- [Research / art and production comparison](../research/WILLICAT_STYLIZED_3D_ART_PIPELINE_RESEARCH_V1.md).

Launch verifies the existing 164-file human café binding and creates a fresh `/private/tmp` project through existing Hybrid/Café preparation. Separate DEV save namespace; original project configuration/scenes remain unchanged. The protected-file receipt verifies all 3,744 pre-task non-cache files, including the previous spike.

## 3. Geometry upgrades

One displayed floor section/rear wall/opening, one connected counter, one espresso machine, one shelf/lamp, one table/two chairs/planter, one optional rug and small ceramic details. **283 authored pieces, 58 final batches, 39,272 triangles.** Authored lathe/table/pot/cup profiles, recessed cabinet planes, soft bevels, window recess/sill, chair back/seat depth, shelf brackets and curved foliage replace generic primitive silhouettes.

Self-QA found a full-width counter body conflicting with a valid 2D route. The main cabinet and espresso support now use their exact existing footprint extents; the bridging service slab leaves the canonical gap open. Espresso follows its actual existing `(410,182)` root. The correction changes DEV meshes only. No nav/anchor/world coordinate is moved to make the art fit.

## 4. Materials / textures

12 used mesh materials, one painted spatial shader family plus matte charcoal trim. Five reusable 512×512 albedos: cedar, cream plaster, sage weave, ceramic, foliage. One text-only built-in imagegen cedar source retained unchanged at 1536×1024; four deterministic original procedural sources reproduced byte-for-byte. Exact prompt/source/export hashes in `texture_provenance.json`. No photographic texture or third-party raw material. Model/seed/cost unavailable for generation are recorded as unavailable.

Albedo dominates; subdued vertex edge/recess variation, roughness .96, no specular/chrome/ORM/normal maps/cel outline. Surfaces are richer than the old crop-luminance materials, with repeated grain and simplified contour still visible.

## 5. Lighting, shadows and AO

One neutral key + soft ambient + restrained practical; same rig used for live/bake comparison. Filtered real cast shadows from 58 mesh casters, separate contact grounding, recessed cavity/edge values. Practical/ambient/key variants have actual captures. No bloom/fog/vignette/DOF/golden-hour grading. **SSAO OFF; LightmapGI not baked.** UV2/bake/import/probe fixture cost was judged outside the useful first art comparison; no baked gain is fabricated.

## 6. Cat / camera / depth

Exact existing orange SpriteFrames and Vector2 actor/nav. Fixed-Y upright AnimatedSprite3D with opaque prepass/depth testing, modest ambient tint and separate ground contact. Unshaded/tinted and blob/card-cast/hybrid grounding alternatives are retained. Sprite pixels/clips are unchanged. DEV vertical presentation scale compensates orthographic camera-up foreshortening; the final screen-height/root assertion passes. The selected tint is fixed for this rig; no dynamic cat-lighting system is claimed.

Camera: orthographic KEEP_WIDTH size 7.15, elevated 3/4; 504×896 native. The six-target micro-tour uses original café targets and real navigation. It stays inside the presented floor; out-of-region picks cannot dispatch navigation. 3D depth handles front/back occlusion, with no manual occluder swaps. Original 2D Y-sort authority remains untouched.

| Case | Overlap | Object dominant | Cat dominant | Unclassified |
|---|---:|---:|---:|---:|
| counter_back | 1444 | 1436 | 5 | 3 |
| counter_front | 1034 | 7 | 1024 | 3 |
| table_back | 1043 | 760 | 281 | 2 |
| table_front | 902 | 39 | 857 | 6 |


Root/body and raster ownership tests have separate purposes. The latter's RGB delta/margin are documented analysis parameters, not beauty/motion/calibration thresholds.

## 7. Live result

OBSERVED improvements: real machine detail, framed/recessed construction, profile thickness, true contact and spatial movement. OBSERVED limits: uniformity of grain, procedural regularity, sparse bespoke dressing, simplified leaf/ceramic mass and an upright sprite plane. It has not proved a premium artistic gain over approved 2D. Human art verdict remains open.

## 8. Pre-rendered result

Shared-world bake from the exact same live micro-scene/camera/lights at 1008×1792, 4× MSAA. Actual 2D TextureRect scene displays it; cleaner edge sampling, same art. **Static cat pose is baked. No moving 2D occlusion/layer implementation is claimed.** A transparent table specimen uses the exact gameplay camera basis, a measured crop and a root-derived pivot; its cup/vase/contact separation remains a future modular requirement.

This full micro-scene image is feasibility-only. Future reusable exports would be individual registered objects/directions and separate shadow/front/state layers, processed through the existing 2D pipeline.

## 9. Approved 2D comparison / fairness

Approved A is freshly captured intact with a real actor navigation to the same hero world point as B/C. B and C are exact same scene/palette/light/camera/pose, with resolution/sampling as the intended difference. No image is retouched to make a branch win. **A remains the richer full slice; B/C are a one-table micro-region.** The board labels that density/composition limitation; detail/module evidence supplements full-scene comparison. No universal or human visual superiority is asserted.

## 10. Measured complexity / desktop cost

- 58 environment mesh surfaces, 39,272 triangles; 12 used mesh materials; 10 referenced scene texture files; one Label3D/font resource outside that file count.
- 8 Sprite3D-family transparency components (cat + contacts), one AnimatedSprite3D, two realtime lights / one shadowed light, 58 mesh casters.
- One custom spatial shader resource, 11 parameterized instances plus standard trim; live SubViewport/postprocess count 0; temporary bake viewport excluded.

| Branch | Draws | Rendered primitives | Texture MiB | Video MiB | Wall frame wait ms | Engine TIME_PROCESS ms |
|---|---:|---:|---:|---:|---:|---:|
| approved_2d | 99 | 1272 | 107.25 | 157.31 | 8.287 | 13.458 |
| previous_hybrid | 78 | 27178 | 159.52 | 218.12 | 8.304 | 14.593 |
| stylized_hybrid | 131 | 78968 | 165.03 | 226.12 | 8.328 | 15.473 |
| prerendered_static_2d | 2 | 144 | 6.92 | 35.48 | 8.320 | 9.674 |


Fresh native process per branch, common 4× MSAA. Earlier sequential texture-memory overflow is retained and rejected for conclusions; fresh counters are plausible and separately recorded. Wall waits are desktop vsync pacing, not GPU/phone FPS; TIME_PROCESS is a separate engine monitor. The hidden original 2D authority scene contributes to live memory. The baked still's 2 draws are not a complete animated game's cost. No real-device result is claimed.

Fresh import retains pre-existing `Scripts/` versus `scripts/` case warnings in unused legacy resources. No new DEV script/shader parse failure is accepted; the original case references were not repaired in this bounded spike. Case-sensitive export remains an inherited limitation.

## 11. AI-assisted workflow / reuse

Executed: reference-informed semantic geometry → procedural bevel/lathe/leaf forms → small painted/algorithmic albedo → existing indexed batching → Godot → native inspect/fix → same-camera bake → actual 2D view. No human Blender expertise or external mesh generator was needed. Concept reconstruction and image-to-3D are only evaluated options, with untested cleanup/registration/rights and no provider integration installed.

Reusable: current 2D gameplay/Focus/service/save/relationships/economy/IDs, existing Forge and Hybrid projection/batching/preparation; new DEV profile/material/bake metadata concepts. Existing Factory contracts, human veto and production publisher boundary remain unchanged.

## 12. Migration risk / limits

Live: phone thermal/cost, transparent/shadow passes, renderer calibration, hidden-2D resource dependency, arbitrary-route 3D contacts, camera/billboard limitations and new registration profiles. Pre-render: direction/state/layer proliferation, fixed-light variants, pivots/front occlusion/shadows and source invalidation. No production conversion is authorized. No LightmapGI bake, 3D cats, full café, full modular animated 2D world or beauty score was built.

## 13. Exact evidence index

All paths below are rooted at `artifacts/prototype_review/stylized_3d_art_fidelity_v1/`:

| Required file | Evidence |
|---|---|
| `01_APPROVED_2D_BASELINE.png` | Actual unchanged approved scene after real hero-point navigation |
| `02_LIVE_HYBRID_HERO.png` | Actual final native 3D scene, existing orange cat |
| `03_PRERENDERED_3D_HERO.png` | Actual 2D runtime display of exact same-scene bake |
| `04_THREE_WAY_COMPARISON.png` | Unretouched native panes, density limitation labelled |
| `05_HYBRID_CAT_FRONT_COUNTER.png` | Real front-point navigation / depth |
| `06_HYBRID_CAT_BEHIND_COUNTER.png` | Genuine mesh occlusion; cat-only isolation in diagnostics |
| `07_HYBRID_TABLE_DEPTH.png` | Actual table-side checkpoint; rear/front four-layer cases in diagnostics |
| `08_HYBRID_MATERIAL_CLOSEUP.png` | Native profile/material/service close-up |
| `09_HYBRID_LIGHTING_CLOSEUP.png` | Dedicated practical lamp/contact close-up, three light variants retained |
| `10_PRERENDERED_OBJECT_SAMPLE.png` | Same-camera transparent table export specimen with grounded pivot metadata |
| `WILLICAT_STYLIZED_3D_ART_FIDELITY_SPIKE_V1.mp4` | Actual six-target moving proof, measured timestamps, no actor teleport/time acceleration |

Diagnostics: `native_proof.json`, `pixel_depth_analysis.json`, four-layer PNGs, motion frame timestamps/trace, `lighting_close_proof.json`, `prerender_2d_proof.json`, `floor_input_proof.json`, `startup_proof.json`, `complexity_inventory.json`, `fresh_performance_*.json`, `performance_summary.json`, regression logs/JSON, `toolchain_receipt.json`, `protected_file_parity.json`, `launcher_checks.json`, and retained counter self-QA issue. Raw movie frames are retained; exports/prompt/recipe are in the new DEV asset/tool folders.

## 14. Verification and protected files

Original regressions executed in the isolated copy: Café 39; Home route/save-load 28; world architecture 172; Focus state/persistence/receipt 33. Source originals were not instrumented or edited. Final moving proof checks route/depth, root/registration, resource identity, reversible picking, batching, cabinet-root integrity and original service reward/duplicate guard. Floor input adds seven actual dispatcher/authority checks. Actual automatic hero startup adds four arrival/visibility/authority checks after a fresh launcher import. Alpha/camera-basis export and deterministic texture reproduction are verified independently.

`protected_file_parity.json` enumerates unchanged pre-task files; the 164-file human café review binding is verified independently at launch. New outputs are additive. No production scene/configuration, old asset, world geometry/navigation, save ID, frozen contract or approved bitmap was replaced; no commit/push.

## 15. Recommendation / next permitted step

**A. CURRENT 2D REMAINS BEST** — retain it as the current quality baseline. The new live view demonstrates more serious forms/materials and valid moving depth, but the generated small wood surface and scripted forms have not closed the bespoke painterly/cohesion gap. Baking the same master cannot solve that gap by itself.

Next permitted step: **human visual decision on this evidence**. No new pilot, full café conversion or automatic migration begins from this recommendation.

## 16. Human decision state

OPEN / PENDING. Agent self-QA and engineering preference are not human art acceptance, authenticated production approval or publication eligibility.

WILLICAT STYLIZED 3D ART FIDELITY SPIKE V1
— READY FOR HUMAN VISUAL DECISION
