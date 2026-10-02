# WILLICAT HYBRID 3D PAINTED MATERIAL PIPELINE V1

Status: executed isolated DEV material/light spike; final human visual review pending. No production migration or publication. This report studies the existing first-party pipeline and this experiment; it makes no new third-party rights determination.

## 1. Authority and audit

- Style/material language: [approved style calibration](../art_direction/WILLICAT_STYLE_FAMILY_CALIBRATION_V1.md) and [machine-readable style record](../asset_factory/style_families/WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1.json).
- Exact geometry/camera/placement baseline: `scenes/dev/hybrid_cafe_hero_replacement/hybrid_cafe_hero_replacement_v1.tscn` and its inherited implementation.
- Quality/mood reference: `/Users/teddywoot/Downloads/ChatGPT Image Oct 1, 2026, 08_34_49 PM.png`. Visually inspected; not a layout authority and not a generation input.
- Approved 2D café remains the quality baseline. Its human-review binding verifies 164 files; no changes to that baseline.

**OBSERVED IN CODE:** previous shared shader collapses input RGB to luminance, scales a palette by a restrained `texture_strength`, explicitly samples softened mip levels and adds repeated sine fields. That suppresses source hue differences and gives objects a uniformly clean finish. Geometry is already authored and reusable; replacing it would confound this experiment.

| Family | Concrete cause of gap | This experiment | Remaining limitation |
|---|---|---|---|
| Cedar | Luminance-only compressed variation; shared repeated fields; weak painted hue structure | Full RGB pigment variation, coordinated light/mid/dark anchors, quiet floor treatment | Grain orientation follows existing UVs and local face normal; some repeated motifs remain |
| Plaster | Broad uniform palette and softened pattern | Cream/pale cool/warm broad source strokes; matte | Some streaks visible near camera; not an authored per-wall painting |
| Stone | Material differs mainly by palette; weak diffuse identity | Independent quiet ivory source; restrained specular | Small mobile surfaces lose subtle mottling |
| Ceramic | Very even cups/jars; weak pigment irregularity | Shared cream pigment, off-white/blue-grey palette variants | Does not add handcrafted asymmetry or patterns |
| Sage fabric | Quiet single palette, weak broad pigment | Desaturated sage source, high roughness | No geometric weave; appearance must survive small scale |
| Dark trim/metal | Separate similar material slots | Shared charcoal pigment material, zero metallic, low specular | Some contrast between trim and equipment is deliberately reduced |
| Foliage | Uniform leaf material despite authored asymmetric geometry | Existing pigment mask plus dark/mid/light palette and green painted source | Leaf planes still visibly faceted; surface art cannot replace silhouette authoring |

## 2. Source generation and rights/provenance

| Item | Recorded result |
|---|---|
| Provider | OpenAI built-in `image_gen` |
| Model | `NOT_EXPOSED_BY_TOOL`; no model name inferred |
| Prompt version | `WILLICAT_PAINTED_ATLAS_PROMPT_V1`; complete prompt archived |
| Generation calls | **1** |
| Input reference images | **None**; textual approved palette/material grammar only |
| Raw output | One 1536×1024 six-cell atlas |
| Runtime extraction | Six exact 512×512 RGB rectangular crops |
| Processing | Crop/export only; no pixel retouch, recolor, phototexture, seam repair or character generation |
| Rights record | Explicit task authorization for first-party generated DEV texture support; no third-party conditioning; production rights/publication are not established by this spike |

Source folder: `assets_src/materials/willicat_painted_surface_v1/`. `generation_provenance.json` records the provider result path, source SHA-256, crop file and decoded RGB hashes, dimensions, rectangles and opposite-edge measurements. `atlas_rect_px` means `[x,y,width,height]`; `crop_box_ltrb_px` means `[left,top,right,bottom]`.

**MEASURED:** raw opposite-edge normalized RGB deltas are approximately 0.030–0.050 across the six crops. No acceptance threshold is inferred. These cells are **not verified seamless**. Runtime mirror-repeat provides continuous boundary values, but can create symmetric motifs and slope/mipmap transitions. Inspect at gameplay scale; do not market these raw crops as proven seamless tiles.

## 3. Reusable library and application

Runtime library: `assets/dev_review/hybrid_cafe_painted_surface_v1/`.

| Required material resource | Shared source | Treatment |
|---|---|---|
| `WC3D_MAT_CEDAR_LIGHT_V1` | cedar | Honey/light cedar |
| `WC3D_MAT_CEDAR_MID_V1` | cedar | Mid cedar |
| `WC3D_MAT_CEDAR_DARK_V1` | cedar | Deep warm trim |
| `WC3D_MAT_PLASTER_CREAM_V1` | plaster | Warm matte cream |
| `WC3D_MAT_STONE_CREAM_V1` | stone | Quiet cream counter |
| `WC3D_MAT_SAGE_FABRIC_V1` | sage | Muted sage upholstery |
| `WC3D_MAT_CERAMIC_V1` | ceramic | Warm handmade off-white |
| `WC3D_MAT_CHARCOAL_METAL_V1` | stone | Charcoal; no metallic/chrome response |
| `WC3D_MAT_FOLIAGE_LIGHT_V1` | foliage | Light pigment role |
| `WC3D_MAT_FOLIAGE_MID_V1` | foliage | Mid pigment / active leaf material |
| `WC3D_MAT_FOLIAGE_DARK_V1` | foliage | Dark pigment role |

Eight additional resources preserve existing floor, paper, coffee, lamp, indigo ceramic, petal, pastry and rug semantics. Nineteen reusable resources exist; **17 are active in the final scene**. Light/dark foliage resources are available, while current leaf geometry expresses the three-value family through its existing vertex pigment mask in the active mid shader. Do not equate resource inventory with active draw/material counts.

`material_manifest.json` preserves exact role map, source means and recipe tuples `[material_role,source_family,palette_hex,paint_strength,roughness,specular]`. One cedar source serves multiple wood roles. No per-object unique texture was generated. The existing Asset Forge environment supplies Pillow/NumPy for extraction and metadata; no new Factory/provider integration is introduced.

## 4. Shader, edge and cavity strategy

Two lightweight shared spatial shaders: back-culled opaque surfaces and two-sided opaque foliage. One painted color texture sample per fragment; mip filtering; palette multiplied by bounded, mean-normalized **RGB** source variation. Static instance-position phase and mirror repeat vary reuse; existing UVs are unchanged. Cedar face orientation uses local normal/UV swapping on horizontal faces. No procedural noise field, normal map, outline, toon band or fullscreen effect.

Diffuse Burley was selected in this experiment after the wrap variant looked overly even. Roughness values are 0.83–0.99, restrained specular 0–0.10 and metallic is zero. These are recorded artistic DEV settings, **not canonical calibration thresholds**.

Existing red vertex cavity mask is preserved and attenuates color mildly; existing green foliage pigment mask selects dark/mid/light painted colors. A very small screen-space normal-derivative tint warms exposed changes of form. This is an **edge proxy**, not signed curvature, a true AO bake or a stable world-space edge mask. Normal derivatives can vary with resolution/camera. Existing authored warm pigments provide cavity warmth; no new per-object cavity painting was baked.

No mesh regeneration, UV changes, vertex-color rewrite or new silhouettes are part of the final variant. An early attempt to rebuild color arrays failed geometry identity and was removed. Later QA caught object-level material overrides overriding surface bindings; both override paths are now mapped, and the final native check verifies every active surface belongs to the new library. Failed iteration logs are retained rather than counted as passes.

## 5. Lighting and cat boundary

Same key direction, practical position, practical range, two-light architecture and orthographic camera. Refined warm-neutral key/neutral fill and restrained local lamp; lower contact bias brings existing geometric shadows closer to chair/counter feet. Existing contact sprites remain. No SSAO, LightmapGI, additional light, fog, bloom, DOF, vignette or image filter was added.

Canonical cat pixels, SpriteFrames, animation synchronization, depth test, billboard solution, scale, ambient tint and contact shadow are unchanged. The environment moves toward the painted character. Actual 2D navigation drives its 3D position; occlusion is real depth testing. The moving proof covers seven targets and existing service/reward behavior.

## 6. Reproduction and mobile implications

Receipts bind source file/decoded hashes, full prompt, material/shader recipe hashes, exact reused GLBs, style/world implementation references, Factory/Forge helper identities, Python/Pillow/NumPy, Godot version, renderer/driver/device, repository HEAD and resulting evidence hashes. No new Blender export occurred; all 29 resolved GLBs are reused unchanged. Existing Blender sources remain reusable.

Six new 512² textures with complete RGBA8 mip chains have a calculated budget of about **8 MiB**, excluding every retained old import, cat/contact texture and render target. Actual formats/compression may differ. A source budget is not resident memory. Runtime imports/hidden 2D authority retain older resources in this DEV project; trimming those dependencies belongs to a later isolated mobile pilot.

One added source family but fewer active shader/material variants; triangle and draw indicator counts do not grow. Derivative tint, mirror sampling and two-sided foliage still need real-device inspection. Native desktop process timings varied considerably across repeated runs and do not establish a speedup/regression. The Metal texture monitor also returned overflow-like values on an earlier run; final valid-looking values are reported with that limitation. No phone FPS or energy claim is made.

## 7. Recommendation

**B — surface art improves the result somewhat; more material research is required.** Main-scale painted wood, cream stone distinction and contact grounding improve; the material-only control separates that contribution from lighting. The scene still reads as a tidy stylized model set more than a premium illustrated miniature. Foliage silhouette/brush structure, per-form painted accents, subtle architectural contact and unified illustrated lighting remain below the Hero ceiling.

Keep this as a reusable DEV material family and request human comparison before extending it. Do not rebuild geometry, migrate Home or treat this recommendation as human acceptance.
