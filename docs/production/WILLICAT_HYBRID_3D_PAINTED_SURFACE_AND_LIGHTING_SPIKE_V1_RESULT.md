# WILLICAT HYBRID 3D PAINTED SURFACE + LIGHTING SPIKE V1 — RESULT

**Scope:** isolated DEV/REVIEW surface and lighting variant of the exact current Hero Replacement café. **Human visual decision: PENDING. Production migration/publication: NOT AUTHORIZED.**

## 1. Material audit and outcome

[Pipeline research and provenance](../research/WILLICAT_HYBRID_3D_PAINTED_MATERIAL_PIPELINE_V1.md) contains the per-family audit, full library names, shader limitations and reproduction model.

The old luminance-compressed, softened shader made wood/plaster/ceramic and foliage look too uniform. The new six-source pigment family preserves broad RGB brush variation, material-specific palette/roughness and softer color relationships. Gameplay-scale evidence shows warmer painted tabletops, distinct cream stone, muted sage seating, more varied green masses and clearer existing cast/contact shadows. Improvement is visible, but it is modest relative to the Hero gap.

## 2. Exact scene, source and library paths

- Scene: `scenes/dev/hybrid_cafe_painted_surface/hybrid_cafe_painted_surface_v1.tscn`.
- Presentation script: `scripts/dev/hybrid_cafe_painted_surface/painted_surface.gd`.
- Launcher: `tools/willicat_painted_surface/Open_Painted_Surface.command`.
- Source atlas/prompt/provenance: `assets_src/materials/willicat_painted_surface_v1/`.
- Nineteen material resources, six shared textures, two shaders and role manifest: `assets/dev_review/hybrid_cafe_painted_surface_v1/`.

**Generation:** 1 OpenAI built-in image generation call; one 1536×1024 atlas → six exact 512×512 crops. Model identity is not exposed. No image reference conditioning, complete-room generation, character generation, photographic texture or source pixel retouch. File and decoded-pixel hashes are in `generation_provenance.json`; no production rights clearance is inferred.

The 11 required `WC3D_MAT_*_V1` library roles exist. Eight extra roles preserve existing secondary materials. Seventeen materials are active; foliage uses existing vertex pigments for its light/mid/dark values. Charcoal trim/metal now share one material. Source tiles are not verified seamless; runtime mirror sampling is explicit.

## 3. Shader / cavity / foliage treatment

Albedo-led RGB mean normalization, quiet mirrored sampling and instance phase, restrained Burley diffuse, roughness 0.83–0.99, specular 0–0.10, zero metallic. Existing cavity and pigment masks remain untouched. A small derivative-based warm edge proxy is used; no curvature or AO bake is claimed.

Cedar light/mid/dark share one pigment source; tabletop flow is more legible and floor variation stays quieter. Plaster and stone have separate low-frequency sources. Foliage keeps the exact authored geometry and asymmetric masses, with greater painted hue/value variation; no polygon growth, added alpha cards or new plants. Faceting and repetitive leaf shading still remain visible in closeup.

## 4. Lighting hierarchy / practical response

| Setting | Before | After |
|---|---|---|
| Key color / energy | `#FFF4E4` / 0.92 | `#FFF4E7` / 0.93 |
| Ambient color / energy | `#E9EBE5` / 0.52 | `#E5E9E6` / 0.40 |
| Practical color / energy | `#F3CE99` / 0.50 | `#F3DBB9` / 0.70 |
| Practical range | 1.9 | 1.9 |
| Shadow opacity / blur | 0.46 / 4 | 0.45 / 4 |
| Shadow bias / normal bias | 0.025 / 0.32 | 0.012 / 0.14 |

All values are artistic DEV settings, not motion/geometry tolerances. Key/practical transforms are unchanged. Service surfaces receive the clearest light/material emphasis, seating remains medium and wall/corner fill is quieter. Practical warmth remains local with no extra shadow-casting light. Hierarchy improves mildly; the lamp is still a small accent rather than a Hero-quality luminous material study.

No cinematic or fullscreen treatment. No new SSAO/lightmap/baked AO. Existing geometric shadows and authored contact sprites provide grounding.

## 5. Same-geometry comparison / identity

Before is freshly captured **Hero Replacement**, not the older V2 scene. After inherits exactly the same baseline, uses the same actor navigation targets and common camera. Closeups use paired identical auxiliary cameras. Materials/light parameters are the intended variables; no prop movement, new scene density or camera crop is used to beautify the main after image.

Native geometry identity:

```text
before = a14e7ef804a7accab632fff39e58587cf1753bb746edbd0c91596ec9d057be19
after  = a14e7ef804a7accab632fff39e58587cf1753bb746edbd0c91596ec9d057be19
```

Hashes include visible node transforms and mesh vertices, normals, tangents, UVs and indices. They are exact matches. Existing GLB file hashes, complete camera transform, every placement call/count and all seven plant-role positions also match. Source mesh/color resources are not rewritten. Some inherited test labels retain `V2`; the actual before scene is Hero Replacement as documented in the capture script.

`diagnostics/material_only_baseline_lighting.png` retains the painted materials with original lights. `diagnostics/material_only_comparison.png` shows that control beside the current baseline, so the light refinement cannot stand in for material improvement.

## 6. Cat cohesion and playable proof

Existing canonical orange SpriteFrames, pixels, 2D motion clips, billboard/depth testing, ambient tint and contact shadow are unchanged. No 3D collision/navigation is introduced. Gameplay authority remains Vector2 and the approved hidden 2D world.

Controls: **click/tap floor** to walk, **Depth walk** for the existing route, **Make coffee** for original service/reward behavior, **2D / Hybrid** for diagnostic baseline switching. Seven navigation targets completed. Four-layer depth evidence verifies cat behind/in front of counter and table, using actual geometric depth. Coffee reward occurs once; replaying its receipt does not duplicate coins. Authority snapshots match after movement and after coffee.

## 7. Measured complexity and mobile limitations

Godot 4.7.2-stable (official) / Mobile renderer / native Metal / Apple M2 Pro (Apple8). Same readiness/foreground/5-second warmup protocol, 240 sampled frames with the first 60 discarded, 180 reported samples per scene.

| Metric | Before | After |
|---|---:|---:|
| Visible mesh instances | 67 | 67 |
| Geometry triangles | 118838 | 118838 |
| Mesh surfaces | 176 | 176 |
| Active materials | 18 | 17 |
| Active geometry texture sources | 5 | 6 |
| Geometry shader resource variants | 3 | 2 |
| Mean draw indicators | 151.0 | 151.0 |
| Lights / shadow lights | 2 / 1 | 2 / 1 |
| Transparent geometry surfaces | 0 | 0 |
| Native texture monitor, MiB | 164.158 | 170.158 |
| Native video-memory monitor, MiB | 233.531 | 239.531 |

Final texture-monitor values include hidden approved 2D authority, imported embedded/retained materials and textures, sprites and render targets. An earlier run returned overflow-like texture values; monitor behavior is not sufficiently stable to claim an exact isolated GPU budget. Raw runs are retained. These last readings are provisional allocation indicators, not phone measurements.

The six generated 512² sources have a separately calculated RGBA8 full-mip budget of 8,388,600 bytes (~8 MiB); source PNGs total 2,232,441 bytes. This calculation excludes retained imports and is not actual GPU residency. No texture or renderer compression claim is made.

Native process timing varied with OS foreground/scheduling across runs; it is **inconclusive for before/after performance**. Draw indicators, geometry and light counts are comparable. No real-device FPS, energy or production-memory target is asserted. Follow-up mobile work should trim inherited unused resources and inspect derivative/mirror sampling at device scale.

## 8. Tests — exact checks/cases

| Suite / scope | Passed |
|---|---:|
| Native asset/import/registration/camera/identity/motion/service proof | 381 |
| Final material resource/texture import checks | 63 |
| Real screen-input/navigation checks | 5 |
| Isolated launcher safety and baseline binding cases | 9 |
| Four-layer pixel depth cases | 4 |
| Approved 2D café regression | 39 |
| Continuous Home regression | 28 |
| World architecture regression | 172 |
| Focus regression | 33 |
| **Total checks/cases** | **734** |

Existing gameplay regressions total 272. These counts are assertions/cases, not 734 independent unit-test functions. Home/world counting instrumentation was confined to temporary copied scripts; original regression files remain untouched. Final materials are validated again after override fixes. No new Blender export occurred; native checks validate the reused imports.

Fresh installed import completed without script/import errors, but emitted **five inherited case-mismatch warnings** for `Scripts/AudioManager.gd`, `Scripts/SceneTransition.gd`, `Scripts/Coin.gd`, `Scripts/LevelFinishDoor.gd` and `Scripts/player.gd` versus the stored lowercase `scripts/` directory. They are existing unrelated project references, not newly authored material paths. They remain a case-sensitive export risk for future mobile packaging; this spike does not modify those protected existing files. The isolated native café proof still passes.

Failed early color-array and parser experiments and the incomplete override iteration are retained as diagnostic history; they are not counted as passing final work. The final native check confirms every active geometry material uses the new family.

## 9. Agent visual self-QA and remaining Hero gap

| Question | Agent observation |
|---|---|
| Less generic 3D? | Some improvement in broad pigment and contact; still a clean model set |
| Painted wood? | Yes, restrained visible flow, strongest on tables/counter framing |
| Warm handmade plaster? | Warmer and less uniform; brush direction still repeats |
| Distinct countertop? | Yes, quiet cream stone separated from cedar |
| Soft organic plants? | Better pigment grouping; silhouette/faceting remains below Hero |
| Richer service without clutter? | Yes, material contrast and existing shadow depth; no added objects |
| Cat belongs? | Existing painted identity remains clear; environment cohesion improves somewhat |
| Significantly closer to Hero? | Incremental movement; **not enough to claim Hero quality** |
| Visible at gameplay scale? | Yes for wood/stone/shadows; ceramic microvariation is subtle |

Final visual acceptance is human-owned. No automatic art-beauty score or human approval record is created.

## 10. Recommendation and production implications

**B — surface art improves somewhat; more material research is required.** Preserve this DEV material library for human comparison. The strongest next investigation would be per-form painted accents and foliage/shading cohesion on this same geometry, with an explicitly approved scope. Do not use this result to authorize Home migration or a full café rebuild.

Current approved 2D café, Tree Pilot, gameplay, navigation/anchors/semantic IDs/save behavior and all existing assets remain unchanged. Production publication remains unauthorized. No commit or push.

## 11. Evidence paths

Root: `artifacts/prototype_review/hybrid_cafe_painted_surface_v1/`.

| Evidence | Purpose |
|---|---|
| `01_CURRENT_SURFACE_BASELINE.png` | Fresh current Hero Replacement common view |
| `02_PAINTED_SURFACE_PASS.png` | Final same-geometry painted/light view |
| `03_SAME_GEOMETRY_SIDE_BY_SIDE.png` | Matched before/after; labels/paste only |
| `04_WOOD_CLOSEUP.png` | Counter/frame/wood response |
| `05_PLASTER_STONE_CLOSEUP.png` | Window/plaster/stone matched closeup |
| `06_SERVICE_ZONE.png` | Espresso/service materials |
| `07_FOLIAGE.png` | Existing planter geometry with new pigments |
| `08_CAT_ENVIRONMENT.png` | Cat/depth environment evidence |
| `09_GAMEPLAY_SCALE.png` | Actual common portrait gameplay scale |
| `WILLICAT_HYBRID_3D_PAINTED_SURFACE_AND_LIGHTING_SPIKE_V1.mp4` | Timestamped moving-character depth walk; no interpolated/synthesized motion |

Diagnostics contain matched before/after closeups, material-only control, counter/table four-layer isolates, geometry identities, motion trace, per-frame timestamps, regressions, profiles, source budget, launcher safety, toolchain receipt and installed verification. Godot generated import cache is disposable and excluded from source-of-truth hashes.

WILLICAT HYBRID 3D PAINTED SURFACE + LIGHTING SPIKE V1
— READY FOR HUMAN VISUAL REVIEW
