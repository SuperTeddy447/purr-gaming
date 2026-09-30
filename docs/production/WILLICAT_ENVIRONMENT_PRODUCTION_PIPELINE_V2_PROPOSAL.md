# WilliCat Environment Production Pipeline V2 — Proposal

Status: production-process proposal only. It does not approve new art, replace current contracts, or modify Home V3.
Spatial authority: Godot room scene and locked authoring guide.
Visual authority: approved art direction/reference at the correct, explicitly scoped role.

## Objective

Create multiple cohesive illustrated rooms and locations without baking one complete gameplay state into a single image, without inventing geometry from concept art, and without losing the authored composition that makes each café distinctive.

## Recommended art/runtime split

Adopt a **registered composition-to-module workflow**:

- Art direction may begin from a complete approved room composition/master so artists and reviewers can judge balance, palette, focal hierarchy, and overall style.
- The composition is not spatial authority. The locked Godot guide defines canvas, room envelope, opening geometry, camera, object slots, safe regions, and registration.
- Export/decompose only along an approved asset contract into registered room layers: floor base, fixed architectural shell, fitted/window/exterior layers, runtime-signage surfaces, and separate reusable interactive or movable objects.
- Runtime ownership follows the room/object architecture: room-owned shell layers remain part of the room composition; every movable/interactable object is its own `PackedScene` with object-local geometry, footprint, collision, semantic anchors, and FX attachment points.
- The complete art master remains a visual parity reference; it is never used as an unregistered full-room runtime background behind duplicate gameplay objects.

This uses the visual consistency of a master-composition process while preserving the modular ownership of the recommended runtime model. It is closer to the existing Home V3 Batch A shell-plus-object direction than either a single flattened background or a fully generic tile kit.

## Environment options compared

| Method | Advantages | Risks | Decision |
|---|---|---|---|
| One complete flattened room image | Strong immediate composition; low node count | Furniture cannot move independently; atmosphere/weather baked; gameplay/occlusion ownership impossible; duplicates runtime actors; whole-room replacement for variants | Reference-only, not runtime world representation |
| Fully modular art kit for every architectural element | High reuse and free layout | Many seams, perspective drift, inconsistent hand-painted transitions, large authoring/QA burden; may turn illustrated rooms into a kit aesthetic | Use selectively for truly reusable props, not every wall/floor seam |
| Fixed room shell + individual object scenes | Predictable world ownership; direct fit for anchors and gameplay; room-specific composition can remain coherent | Architectural shells may be room-specific; requires careful registration and edge/occlusion plans | Sound runtime result |
| Approved master composition decomposed into registered shell layers + object scenes | Preserves art direction, allows cohesive room-specific architecture, keeps gameplay objects independent, supports selected variants | Requires strict contract and registration QA; decomposition should be planned, not improvised from a flattened image | **Recommended production workflow; runtime output resolves to fixed shell + object scenes** |

## Production gates

### Gate 0 — authority and scope declaration

Before a prompt or artist brief, list the exact spatial authority and asset contract. Specify whether each image is **style only**, **composition reference**, **registration guide**, **lighting mood only**, or **runtime source**. No image may silently serve multiple roles. Read the applicable agent bootstrap and current locked contract first.

### Gate 1 — scene/layout lock

Designer locks the Godot room guide: source dimensions, viewport/camera assumptions, floor polygon, wall/window openings, service relationship, stable object IDs/transforms, signage surfaces, foreground boundaries, gameplay markers, and placement/exclusion polygons. Record screenshots/guides from the actual scene. The art brief may reference those guides but may not ask image generation to reinterpret or move them.

### Gate 2 — visual direction and neutral-light contract

Approve style and material reference separately from layout. Use current WilliCat visual target within its declared role. Base-room artwork should carry intrinsic form shading and restrained contact tone only; avoid fixed sun shafts, long directional shadows, lamp pools, permanent night tint, rain wetness, or season grading. Dynamic atmosphere is handled by room fixtures, profile data, and small exterior/season variants as already defined by the atmosphere architecture.

### Gate 3 — asset decomposition plan

For every asset decide:

- fixed room-shell layer vs object `PackedScene` vs runtime-only effect/UI
- exact dimensions, origin/root, pivot, alpha/opaque requirement, bleed/padding, safe area, crop/registration bounds
- stable asset/instance ID policy and owning layer
- footprint/collision/interaction slots, if any
- lighting compatibility and whether runtime shadows/occluders are required
- which profile/event variants are justified

Plan the cuts before generation; do not attempt to infer all object transforms from a single generated image.

### Gate 4 — candidate generation and source preservation

Generate only the scoped candidates authorized by the batch. Preserve immutable raw output and metadata in the source/provenance package. Candidate is not production-approved simply because it looks attractive. If output dimensions or alpha do not meet contract, record the actual result as RAW DRAFT and stop; do not stretch/paint/repair to claim compliance.

### Gate 5 — registration and Asset Forge validation

Use existing WilliCat Asset Forge contracts/CLI for approved technical operations; do not replace it with one-off scripts. Validate exact dimensions, alpha, bounds, aspect, root/baseline, padding, contact edge, registration overlay, duplicate baked props, lighting assumptions, and runtime atlas/sprite metadata as appropriate. Forge validates compatibility; it is not the world-placement authority or atmosphere engine.

### Gate 6 — Godot scene composition proof

Integrate only in the authorized dev/proof scene first. Use stable IDs and object-owned slots. Compare Godot composition against the approved master for art parity without moving locked layout transforms to fit the artwork. Test camera framing, depth sort, front occluders, interactive footprints, multiple aspect profiles, and atmosphere changes. Keep the runtime result deterministic.

### Gate 7 — human review and status lock

Provide actual Godot captures and a manifest describing each asset's role, source, registration, scale, warnings, contract, and exact scene. Record pass/reject/candidate status. Promote to production only after explicit visual and technical approval. Keep rejected candidates and provenance as appropriate; do not silently overwrite.

## Art-to-world contract for locations and rooms

### Location and room identity

Location art expresses regional environmental tendencies and authored setting content, not lighting stereotypes. Room art belongs to a particular `RoomDefinition`/scene; common object art may be reused across rooms only when perspective, scale, occlusion, and style contracts permit it. A location may contain a café interior, entry street, garden, and special event room as distinct room scenes connected by semantic portals.

### Shell layers

- **Floor base:** quiet full-bleed surface within the guide-defined floor field; no furniture, characters, station parts, cast shadows, or invented raised zones.
- **Fixed architecture shell:** wall/fitted architecture within the actual locked envelope, with openings aligned to the Godot guides. No gameplay marker is painted into the raster.
- **Windows/exterior:** window mask/interior reveal and external backdrop kept addressable for lighting/weather/season where justified. Do not replace the whole room to indicate rain or night.
- **Runtime signage surfaces:** blank or safe printable region; text/content supplied by runtime UI/texture rather than baked final words unless a specific immutable sign is explicitly contracted.
- **Foreground architecture:** split only where real occlusion requires it; foreground layer registration is checked against the room scene and floor-contact sort contract.

### Object scenes

Chairs, tables, CounterStation components, beds, plants, lamps, and other approved movable/interactable objects ship independently with stable `definition_id`, image bounds/root registration, local collision/footprint, semantic slots/approach markers, and effect attachment points. Their art must not bake a shadow onto the floor outside the object's movable footprint. If an intrinsic object shadow is visually integral, contract its extent explicitly and verify movement in Godot.

## Variants policy

Use a full new room only when the gameplay architecture/physical space is intentionally different. Otherwise prefer:

1. runtime atmosphere profile changes;
2. small exterior/window/foliage variants;
3. event-owned prop layers with semantic/physical activation contracts;
4. selected material/texture variants where the same object still registers and fits its slots.

Do not generate one complete room image per country × season × time × weather combination. Do not encode culture using a national color wash. Architectural/cultural decor content is a separate authored environment decision; the lighting engine consumes environmental profiles.

## Forge compatibility validation proposal

Asset Forge should remain an asset-ingest/validation layer. Consider warnings (not automatic repainting) for:

- large shadow/glow pixels extending beyond a movable object's contracted image/footprint bounds
- strong directional or whole-image grading inconsistent with neutral base lighting
- missing transparent/opaque expectation, root/baseline/pivot metadata, or registration reference
- excessive glow padding that creates sorting/overlap problems
- missing runtime-shadow/occluder intent for assets that require them
- embedded text on a runtime-signage surface
- duplicate scene composition/background-baked object that should exist as separate gameplay art

Warnings must be contract-aware. Some assets intentionally contain intrinsic painted shading; Forge must not classify every shadow pixel as invalid. It should report evidence and bounds, not decide visual quality or world layout.

## Review package requirements

Every batch should include:

- current Godot geometry/layout guide screenshots at exact paths
- approved style and lighting references with each reference role labeled
- immutable source candidate and processing manifest
- registration overlays and dimensions/root/pivot report
- Godot scene capture at default camera and relevant zoom/aspect conditions
- object interaction/depth/occlusion proof where applicable
- neutral/day/night/weather capture only for the authorized proof state
- concise README with filename, role, status, contract, and warnings

## Location launch sequence

1. Lock first-room Godot authoring contract (do not mutate current Home V3 lock).
2. Approve a cohesive room visual target under mood/style authority only.
3. Build geometry screenshot pack from Godot.
4. Produce shell candidate batch and independently review registration.
5. Integrate shell into a dev clone/proof scene; compare parity without moving gameplay transforms.
6. Process reusable object scenes/slots and verify movement/occlusion.
7. Validate neutral base and runtime atmosphere.
8. Validate decoration records only after placement/persistence proof.
9. Promote candidates through explicit human review and release tagging.

## Boundaries

This proposal does not authorize image generation, new Home V3 assets, Home migration, production object movement, decoration menu/UI, economy, persistence implementation, plugins, or source cleanup. Human review should approve the pipeline contracts before the next production art batch is expanded.
