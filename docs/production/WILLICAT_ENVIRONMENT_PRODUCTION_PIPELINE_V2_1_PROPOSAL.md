# WilliCat Environment Production Pipeline V2.1 — Coherent Room Authoring Proposal

Status: revision for human review. This document clarifies and supersedes the image-composition/decomposition language in [V2](WILLICAT_ENVIRONMENT_PRODUCTION_PIPELINE_V2_PROPOSAL.md); it does not replace locked Home V3 scene/layout or asset contracts. No artwork is produced by this document.

## Why revise the pipeline

The first Home V3 environment pass divided the room into floor, north/side walls, service wall and window deliverables. Generating each as a visually independent image can make joints, perspective, material rhythm and light response look pasted together. The opposite approach—painting a complete café and cutting out sprites afterward—is explicitly deprecated by [Agent Bootstrap V1](../architecture/WILLICAT_AGENT_BOOTSTRAP_V1.md) and the [world architecture ADR](../architecture/WILLICAT_PRODUCTION_ARCHITECTURE_LOCK_ADR_V1.md). A full-room painting cannot determine correct interaction anchors, footprints, movable objects or dynamic lighting.

The correction is to **design the whole room first, then author registered deliverables as planned components**. The whole-room composition is a visual target/mockup with a fixed Godot guide underneath. Production sources are independently authored registered layers/objects; they are not cropped from a finished flattened room image. Seams and material transitions are designed together, and the assembled Godot viewport is the acceptance image.

## Four production approaches

| Approach | Multiple room shapes / location identity | Decoration / runtime lighting | AI generation, memory, zoom and visual cohesion | Verdict |
|---|---|---|---|---|
| A. Full monolithic room art | Distinct room shapes look cohesive, but every layout or locale variation tends toward a new large image | Movable furniture and partial occlusion require duplicate overlays or baked remnants; time/weather variants multiply full-room sources | Single prompt can be visually coherent but register poorly to real geometry; large texture cost and painted detail may break at zoom | Use as mood/composition reference only |
| B. Fully independent modular tiles/props | Many layouts reuse pieces | Strong placement flexibility and per-object light response | Independent AI generations drift in perspective/material/palette; seams and repetitive kit look are high risk; many imports/draw layers | Use for selected repeatable props, not the whole illustrated shell |
| C. Cohesive room-specific fixed shell + separate object scenes | Each room can have its own architectural shape while sharing gameplay object scenes | Separate furniture/fixtures remain movable; shell stays neutral for runtime atmosphere | Shell can be visually coherent and often needs fewer large layers; requires careful shell/foreground registration and memory review | Correct runtime ownership shape |
| D. Room-first composition and registered production modules | One approved whole-room art direction governs unique rooms and a reusable object family | Modules are planned from the start, so movable objects and runtime light remain independent | Hardest authoring discipline, but preserves perspective/material continuity; Godot assembled scene exposes mistakes early | **Recommended workflow; produces C's runtime structure** |

No approach removes the need to profile actual imported textures and mobile zoom. A 960×1980 RGBA layer alone represents about 7.25 MiB of raw pixels before platform import/compression/mip decisions; multiple full-size layers and simultaneous rooms can grow memory quickly. The proposed one-active-room lifecycle limits resident room art, but target-device measurement remains mandatory.

## V2.1 authoring sequence

1. **Lock geometry in Godot.** Use the existing room scene/guide for floor envelope, wall openings, service relationships, object roots, camera bounds, nav/circulation and signage/foreground surfaces. Home V3 uses its already locked Staggered Salon layout. No art image moves these.
2. **Set one room-wide visual brief.** Define perspective, relative scale, palette, wood/plaster/jade/brass material language, edge treatment, value hierarchy and neutral light behavior for the full room. Review with character silhouettes at gameplay zoom.
3. **Plan module boundaries before generation/painting.** Group architectural surfaces into the fewest coherent fixed-shell layers practical for occlusion, window variants and texture budgets. Do not divide a continuous wall into unrelated independent generations unless an actual layering/function boundary requires it. Identify object scenes, front occluders, runtime signage and window/exterior masks separately.
4. **Produce coordinated registered candidates.** Each deliverable receives the same Godot guide and room-wide material/style reference, plus exact layer bounds and neighboring seam context. A composite mockup may guide style, but no production asset is obtained by slicing a completed flat café picture. If image generation cannot supply exact dimensions/registration, mark RAW DRAFT, preserve source and request a new candidate or manually author the layer through the approved workflow.
5. **Assemble in Godot early.** Test shell pieces together before detailing each one. Inspect edges, vanishing/perspective continuity, trim thickness, light neutrality, object silhouette scale and service/seat legibility at default and zoomed camera. Fix the asset contract/candidate when artwork is wrong; do not move locked scene nodes to conceal drift.
6. **Add independent objects and interaction proof.** CounterShell, Espresso, grinder, POS, pastry, tables, chairs, bed, perch, plants, door and event objects retain separate stable IDs and PackedScenes. Verify their own roots, slots, footprints, front/back visuals and potential movement. No extra cup, worker, customer or shadow is baked into the shell.
7. **Run neutral atmosphere and variant review.** The room shell is time/season neutral. Runtime lamp, window/exterior, day/night and weather behavior comes from the composable atmosphere system; a small authored outside/foliage variant is permitted when justified. Do not repaint the entire interior for each atmospheric combination.
8. **Approve from assembled captures.** Human review sees the real Godot room at canonical and tall aspect, min/default/max relevant zoom, debug/off, actor at service/seating/entrance, counter/seat occlusion, event off/on and sample atmosphere states. Asset-level QA alone cannot certify a cohesive room.

## Specific boundary for Home V3

Home V3 can retain its existing floor guide, side/north wall geometry, service objects, window position, 17 art-bearing stable instances, three semantic-only waiting objects and locked camera. The room-wide art brief should coordinate the fixed floor/wall/window shell, but the five service pieces remain distinct gameplay objects. An architectural seam can be covered by a *fixed* registered trim whose physical/occlusion implications are scene-authored; it must not be hidden by baking a chair, coffee machine or sunlight into a base layer.

The signature window opening and exterior are separate addressable surfaces so location/season/weather can alter the outside view. Foreground shell splits are created only where scene depth requires them. A chair, bed, plant or lamp that may move cannot leave a permanent floor shadow or contact mark behind. Its localized contact treatment moves with the object. Runtime signage remains editable and legible without baked text.

## Review questions at each batch

- Does the whole assembled café read as one illustrated space at actual gameplay framing, including service, entrance and both seating islands?
- Do floor/wall/window materials and perspective connect across module edges with no unexplained recess, border or cutout?
- Are the object scenes still independently understandable and interactable? Does moving an approved object leave no painted duplicate or shadow?
- Can the neutral base support morning, rainy afternoon and night without a conflicting baked light source?
- Are major silhouettes and occluders correct at default and zoomed phone views?
- Does the asset manifest name the exact source, role, root/registration, alpha requirement, stable ID, status and remaining warnings?

## Asset Forge and source handling

Asset Forge validates source dimensions, alpha, root, padding, clipping, duplicate baked props, seam/registration warnings and neutral-light compatibility according to the relevant contract. It does not decide room layout or repaint seams. Keep original candidates and review captures separate from runtime textures. Reject a visually disconnected module even when it passes pixel-level checks; conversely, a beautiful composite cannot override an anchor or footprint mismatch.

## Production gate

Before another environment batch becomes production art, approve one assembled Home V3 shell/service proof and one differently shaped placeholder room composition using this authoring method. The second room tests whether the method can adapt to future locations without copying Home's geometry. This is a visual/process gate, not a request to build the multi-room gameplay system in the current hardening task.
