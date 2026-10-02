# WILLICAT HYBRID 3D CAFE ART DIRECTION PASS V1 RESULT

**Scope:** isolated DEV/REVIEW refinement of the same V1 Café kit. Human Hybrid presentation direction is accepted; this art-pass visual acceptance is **PENDING**. Production migration/publication is **NOT AUTHORIZED**. Recommendation **B — PROMISING, BUT ONE MORE ART PASS REQUIRED** to reach the Hero's bespoke richness. This is an art recommendation, not an automated human approval.

## 1. Visual gap analysis

Audit used the unchanged approved 2D Café, current Hybrid V1 native frame, original human 2D Hero and latest human Hybrid Hero B. Original references are unchanged. The 2D Hero remains the polish/mood ceiling, never world-layout authority. The latest Hybrid Hero additionally informs physical framing/material response; its stairs/second floor/new cat are excluded.

| Hybrid-specific gap | Concrete cause | Bounded response / remaining limit |
|---|---|---|
| Material richness | One equally busy cedar map dominates floor and tabletop; subtle cream/sage planes have little material separation | Quieter floor material, broader cedar brush source, local painted variation and distinct roughness; still fewer bespoke motifs than Hero |
| Silhouette / edges | Counter reads as box + flat inset; table/seat edges have very little profile rhythm | Retain carcass, deepen edge/profile read through mouldings, thicker top and rounded furniture accents |
| Architecture | Rear wall ends with thin disconnected stile tops; shelf rhythm resembles a uniform jar display | Continuous upper cedar framing within existing spans; shelf edge depth; varied jars and grouped plants |
| Lighting hierarchy | Almost equal ambient exposure flattens contacts; many small surfaces have the same response | Neutral/cool fill, warm-neutral key, restrained service practical and short-range cavity data |
| Foliage | Twenty thin leaves with three repeated green tones leave large open gaps | Interleaved curved leaves and layered masses on existing key planters; still not Hero species/flower diversity |
| Grouping / intimacy | Tables/chairs appear independently placed across the inherited long footprint | Two quiet seating rugs, paired cup clusters, service ceramic group; walking ground remains calm |
| Cat cohesion | Unshaded bright artwork can read as a card against darker timber | Ambient tint + smaller floor contact; compare unshaded, tinted and bounded custom light response |
| Focal hierarchy | Floor grain competes with cat/counter while equally spaced jars repeat | Reduce floor contrast, concentrate detail at service/windows/table tops |

The approved 2D baseline has richer authored shelf/plant/seat imagery; it was not weakened. The human-approved style record still states 2D runtime/2.5D presentation for its original scope. This explicit task authorizes a DEV true-3D presentation using its palette/material grammar; that record was not rewritten or silently promoted to production Hybrid authority.

## 2. Geometry refinements

**13 original `.blend` assets were surgically refined; 14 original GLBs are referenced unchanged. The 27 semantic asset IDs and original source kit remain intact.** Separate editable revisions: `assets_src/3d/cafe_art_direction_v1/`; corresponding exports: `assets/dev_review/hybrid_cafe_art_direction_v1/glb/`.

- Counter: existing service height maintained; top thickness increased downward; inner panel beads, softer corners/base moulding. No body extension into navigation gaps.
- Table: existing rounded top/pedestal retained, warm rim bead and collar added.
- Chair: softened selected bevels, seat piping and lower backrest rail; original floor registration retained.
- Window: inner sill bead/depth. Shelves: lower edge trim. Upper wall framing reuses V1 Beam_Cedar on existing rear spans; garden opening remains clear.
- Planter: retain pot/trunk/original leaves, add 30 varied curved leaves per key source; rounded, layered green masses.
- Lamp: lower collar refinement, existing restrained paper-lantern silhouette. Espresso: housing foot/header detail, original silhouette and stations retained.

No blanket subdivision, new town/vegetation kit, second floor or new gameplay layout. Softened bevels use existing modifiers; selected prominent profiles use three segments. Authored dimensions/intensities are DEV art choices, not newly invented calibration thresholds.

| Refined existing asset | Exported triangles |
|---|---:|
| Wall_Window_A | 2484 |
| Window_Recess_A | 1404 |
| Counter_Straight_A | 5020 |
| Counter_End_A | 2104 |
| Counter_Short_A | 2104 |
| Espresso_A | 8184 |
| Table_Round_A | 3056 |
| Chair_A | 2568 |
| Shelf_A | 1076 |
| Shelf_Short_A | 1076 |
| Planter_Floor_A | 4392 |
| Planter_Table_A | 4392 |
| Lamp_Hanging_A | 3672 |

## 3. Material refinements

17 shared geometry materials: original 15 families plus a quieter floor-wood variant and shared woven-rug dressing. Cedar/plaster/sage/ceramic/foliage share one restrained painted shader family. Solid trim, metal, paper/lantern preserve existing shared resources. No unique per-object material proliferation.

`storybook_painted.gdshader` uses existing/new painted albedo, reduced grain contrast, broad local value variation, restrained saturation, matte roughness and disabled specular. Soft Lambert wrap reveals form without hard toon bands/outlines. Foliage uses its two-sided variant; other solids cull backs. Individual silhouettes/scale/UVs stay authored, not shader-deformed. No automatic art-beauty score.

## 4. Texture strategy / provenance

One **built-in imagegen edit** refined only the first-party cedar albedo, using that existing material as the sole image input. No Hero/third-party pixels or cat artwork were used as generation conditioning. Original input is untouched. Four other first-party texture families are reused unchanged. Runtime cedar is normalized to 512×512 (Lanczos only); source PNG is retained separately. No new café concept or asset-family images were generated.

Exact provenance: `assets/dev_review/hybrid_cafe_art_direction_v1/texture_refinement_provenance.json`. Source: `assets_src/3d/cafe_art_direction_v1/materials/cedar_brush_source_v1.png`. Runtime: `assets/dev_review/hybrid_cafe_art_direction_v1/textures/cedar_brush_v1.png`. Model/seed are not disclosed by the built-in tool; none are invented. Tile repetition is evaluated visually in the assembled scene, not asserted to be mathematically seamless.

Floor uses lower grain contrast and muted saturation than tables/counter, supporting the actor rather than competing. Two simple procedural woven rugs are presentation dressing; no collision or new gameplay asset semantics. Dynamic signs remain editable text, not generated lettering.

## 5. Lighting setup

One directional key: warm-neutral `#FFF0DC`, energy .80, orientation (-57,-28,0); soft shadow opacity .52 / blur4. Ambient `#E7E9E3`, .48 keeps shaded planes readable. One existing service practical: energy .42, range2.25, shadows off. These are bounded authored DEV settings; no canonical light/quality tolerances are inferred.

No bloom, fog, vignette, DOF, dramatic sunbeams/golden-hour or new shadow lights. No attempt to hide geometry with cinematic effects. Cat remains a focal warm accent against quiet ground; service detail follows, then seating and rear architecture.

## 6. AO/contact-depth strategy

Selected assets carry geometric short-range cavity values baked into a named vertex-color attribute. Eight deterministic hemisphere rays per original vertex; .13 art-unit ray range; at most .18 authored darkening. Measured ranges are recorded, not promoted to global thresholds. Source `.blend` keeps editable geometry/attributes; GLB exports `CavityPaint` as **COLOR_0** explicitly. The shader uses it as restrained AO, not a black outline or scene-light cast bake.

An export check caught the glTF default emitting white COLOR_0 for material-unused colors; named export was corrected. Another check caught metadata resolving original rather than refined prefabs; it was corrected before final proof. **All 13 modified exports contain nonuniform valid cavity values in actual Godot import.** Tests cover values, not merely attribute existence.

Separate small contact sprites and real key cast shadows ground cats, counter/table/seat/planter. No LightmapGI or SSAO used; no baked illumination or phone suitability claimed. Rear static grouping preserves every triangle and material visibility; an initial auto-renamed-node visibility defect was fixed and specifically tested.

## 7. Cat integration

Exact original orange SpriteFrames and movement clips remain unchanged. Upright AnimatedSprite3D keeps authored screen proportions, alpha depth and real geometry occlusion. Contact shadow is slightly smaller and stronger; moves with the original logical root.

| Mode | Actual evidence / decision |
|---|---|
| A. Unshaded | `diagnostics/cat_mode_unshaded.png`; original color, more independent from environment |
| B. Ambient-tinted | `diagnostics/cat_mode_ambient_tinted.png`; selected playable mode, restrained (.94,.945,.925) tint |
| C. Custom light-touch | `diagnostics/cat_mode_lightly_lit.png`; original atlas/alpha, upright billboard transform and tightly compressed key-direction tint; not full 3D relighting |

C preserves illustrated color by design and was inspected, but B is simpler and more stable for this pass. No cat repaint/model, scale pulse, pose generation or manual 2D occluder switching. All source pixels remain unchanged. Additional original worker/customer visuals remain bound to existing gameplay actors.

## 8. Camera refinement

Portrait orthographic elevated 3/4 retained. Common A/B comparison uses **the exact original V1 camera transform**, KEEP_WIDTH size7.65 instead of historic8.05. Both branches use that same framing: after does not gain an artificial advantage from a crop/perspective change. Whole café and entrance remain readable; a small corner approaches frame edge, explicitly visible in both. No free rotation.

Close-ups are native camera captures, labelled separately. The unchanged approved 2D capture and Hero use their original framing/lighting; they are contextual quality references, not matched geometry benchmarks. Comparison provenance records this limitation.

## 9. Composition changes

No world object/anchor moved. Two seating rugs group existing table/chair positions; primary table has a small extra cup pairing. Existing service surface hosts a coherent jar/cup group. Existing shelves/window ledge hold additional instances of the same planter; jar scale/facing varies modestly. All dressing remains on existing support surfaces or flat ground without new obstruction. No opaque bridge across service/garden/entry apertures and no random scatter across walking space.

## 10. Foliage treatment

Existing floor/table planter sources retain their pot/roots and add interleaved, rounded curved leaves with moss/sage/dark/light hierarchy. No photographic alpha leaf cards, neon green or whole-plant scale motion. New shelf instances supply architectural clusters rather than new ground obstacles. Remaining limitation: leaf geometry is still comparatively stylized/simple and lacks Hero's small floral/species groupings. No vegetation pack was created.

## 11. Performance before/after

Fresh V1 and final art variant were measured in native Godot4.7.2 / Mobile Metal on Apple M2 Pro. Three-second warmup, 180 steady samples without screenshot readback. Both use the same runtime settings; process time is desktop engine timing, not phone FPS or GPU time.

| Indicator | Before V1 | After art pass |
|---|---:|---:|
| Visible mesh instances | 69 | 64 |
| Geometry triangles | 112328 | 143824 |
| Visible geometry surfaces | 235 | 178 |
| Mean draw calls | 161.0 | 149.0 |
| Mean rendered primitives | 130678.0 | 206920.0 |
| Lights | 2 | 2 |
| Shadow lights | 1 | 1 |
| Shared geometry materials | 15 | 17 |
| Geometry texture resources | 5 | 5 |
| Texture allocation (MiB) | 216.61 | 217.95 |
| Mean engine process time (ms) | 25.18 | 17.65 |

Rear architectural/decorative surfaces are grouped by shared material only. Interactive counter/table/chair wrappers remain independently inspectable/modular. Grouping retains every triangle and all materials; original source instances are hidden for traceability, so memory is not claimed reduced. Draw calls fall despite added shape/detail; triangles increase because of planter leaves and prominent profile refinements. Material count increases only for floor/rug roles. No aggressive whole-room merge.

Allocation includes retained hidden 2D authority, imported embedded materials/textures, shared overrides and original avatars. Five source textures alone do not explain the measured allocation. Real phone testing, shader/GPU time, resource stripping and shipping budgets remain **UNTESTED/UNMEASURED**. Mobile risks: transparency/alpha prepass, shadow bandwidth, surface count, retained resources and shader sampling. No false real-device performance claim.

## 12. Playable proof

Scene: `scenes/dev/hybrid_cafe_art_direction/hybrid_cafe_art_direction_v1.tscn`, extends the existing kit presentation; no replacement gameplay architecture. Click floor to walk, **Depth Walk** for seven real targets, **Make Coffee** for the original service/customer/reward loop, **2D Baseline** for retained approved source. No freely rotating camera.

Open `tools/willicat_cafe_art_direction/Open_Cafe_Art_Direction.command`. It prepares a fresh isolated `/private/tmp` project and imports resources. Namespace `WilliCatCafeArtDirectionDEVV1`; protected/existing/traversal/symlink destinations are refused. Human-approved Café binding is verified before assembly. No Factory candidate/release or production publishing capability is added.

## 13. Test results

- Final native Hybrid proof: **316 checks PASS**, covering 27 imports, UV/normals/material mapping, measured Blender bounds/triangle parity, roots/door opening, original cat identity, seven navigation targets, real clip movement, original coffee reward + duplicate guard, unchanged authority and rear grouping integrity.
- Cavity color export/import: **13 checks PASS**.
- Real native screen-click input: **5 checks PASS**.
- Isolated launcher safeguards: **9 checks PASS**.
- Four-layer counter/table front/behind raster depth cases: **4 PASS**; thresholds are analysis-classification choices, not aesthetic tolerances.
- Existing regressions: Café **39**, continuous Home **28**, world architecture/navigation **172**, Focus **33**; **272 total PASS**. Original source tests are unchanged; temporary Home/world copies only add execution counters.
- Protected-content SHA256 parity: **4272 pre-task content files unchanged**, plus separate approved Café binding164/164. Includes original Hybrid kit and approved Tree Pilot.

Evidence logs and JSON are in `diagnostics/`. Technical PASS does not imply human visual acceptance. Original inherited case-sensitive `res://Scripts/` warnings in unrelated copied platformer prefabs remain documented; no new kit import/shader error is accepted as a pass. Import cache is temporary, never production evidence authority.

## 14. Visual comparison / evidence

All evidence: `artifacts/prototype_review/hybrid_cafe_art_direction_v1/`.

| Required file | Evidence |
|---|---|
| [01_HYBRID_BEFORE.png](../../artifacts/prototype_review/hybrid_cafe_art_direction_v1/01_HYBRID_BEFORE.png) | Fresh unchanged V1 native render, common camera/actor approach |
| [02_HYBRID_ART_DIRECTION_AFTER.png](../../artifacts/prototype_review/hybrid_cafe_art_direction_v1/02_HYBRID_ART_DIRECTION_AFTER.png) | Final native art variant, same primary camera/actor approach |
| 03_APPROVED_2D_BASELINE.png | Byte-identical copy of human-approved 2D native frame |
| 04_HERO_TARGET.png | Byte-identical copy of original supplied 2D Hero; latest Hybrid Hero B also retained in diagnostics |
| [05_FOUR_WAY_COMPARISON.png](../../artifacts/prototype_review/hybrid_cafe_art_direction_v1/05_FOUR_WAY_COMPARISON.png) | Aspect-preserving evidence montage, no generated/retouched scene pixels |
| 06_COUNTER_MATERIAL_CLOSEUP.png | Actual top/panel/trim/shelf material depth |
| 07_TABLE_CHAIR_CLOSEUP.png | Furniture rim/seat/rug grouping |
| 08_CAT_INTEGRATION.png | Original artwork and floor contact |
| 09_LIGHTING_AND_SHADOW.png | Rear/window/shelf light/contact response |
| 10_GAMEPLAY_SCALE.png | Native portrait gameplay framing |
| [WILLICAT_HYBRID_3D_CAFE_ART_DIRECTION_PASS_V1.mp4](../../artifacts/prototype_review/hybrid_cafe_art_direction_v1/WILLICAT_HYBRID_3D_CAFE_ART_DIRECTION_PASS_V1.mp4) | Actual moving cat/nav depth, capture timestamps preserved as VFR |

Comparison/native source provenance and exact hashes are recorded separately. Still-frame scene density differs by the stated bounded clusters. Hero contextual light/detail density is not copied or used to sabotage the other branches. This is DEV diagnostic evidence, not canonical Factory integration approval.

## 15. Remaining gap to Hero

Agent self-QA: stronger construction/frame rhythm, quieter material hierarchy, fuller planter mass, more coherent seating clusters, retained tactile depth and consistent original cat. The counter/window/leaf form responds to light rather than relying on a single room painting. These are visible bounded changes to the same prototype.

The result still falls short of Hero's bespoke espresso/pastry/ceramic silhouettes, lush trailing plants/flowers, natural upholstered surfaces, authored wear/contours and composition richness. It is less illustrated than the approved 2D imagery in some close-ups. Micro-detail remains restrained; no extra visual density is claimed through a new layout. No assertion that Hybrid now looks better than approved2D or equals Hero is made on behalf of the human.

## 16. Recommendation

**B. PROMISING, BUT ONE MORE ART PASS REQUIRED.** Review this variant in motion first. If accepted, authorize one focused treatment of service equipment, natural plant clustering and authored material accents before making a final mobile-pilot art decision. Mobile profiling/optimization can then be separately authorized; current desktop metrics do not certify a phone build. The pipeline should not be abandoned and the whole kit should not be rebuilt.

Final visual acceptance remains human-controlled. No Home/Riverside migration, approved2D replacement, new layout/town/secondfloor, new cat, save/economy/schema change, monetization, React Native, commit or push occurred.

## 17. Evidence and reproduction ownership

`tools/willicat_cafe_art_direction/refine_blender.py` opens exact original sources, applies the listed bounded edits, exports separate sources/GLBs and records original/refined hashes + measured bounds/triangle counts/cavity settings. Godot material/shader/dressing overrides complete the look; raw GLB/Blender preview alone is not the full runtime appearance. Source/output/toolchain hashes bind this DEV run. Future production approval must follow the unchanged rights, authentication, immutable bundle and human review contracts.

Shader API reference: [Godot4.7 spatial shaders](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/spatial_shader.html). Actual compatibility is established by the local Godot import/native tests, not documentation alone.

WILLICAT HYBRID 3D CAFÉ ART DIRECTION PASS V1
— READY FOR HUMAN VISUAL REVIEW
