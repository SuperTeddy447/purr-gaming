# WilliCat asset catalog architecture V1 — proposal, not implementation

## Decision

Keep the playable room's authored scene instances and object-owned semantic slots as spatial/gameplay authority. Add a small asset catalog for *visual definitions and provenance*. A room places a reusable object scene with a stable `instance_id`; its definition chooses the visual and authored footprint/slots. Switching visual candidates must not silently resize collision, move slots, change navigation or migrate saves. The existing `stable_id` on `HardeningWorldObject` is instance identity; a new `asset_id` identifies the reusable definition. They must not be conflated.

Pipeline: immutable source + license record → technical import/QA → catalog entry → versioned object definition → Godot visual scene/texture → existing object scene's visual child → authored room placement → existing instance-ID placement delta save. A texture alone cannot encode usable gameplay dimensions; visual scale and floor-contact pivot are approved against the object footprint in Godot.

## Asset families and ownership

| Family | Examples | Runtime form |
|---|---|---|
| Architecture surfaces/modules | floor finish, wall segment, doorway trim | Room-owned surface layer or repeated module; not movable furniture; no baked service-object footprint. |
| Facilities/stations | counter, espresso, grinder, POS, pastry case | Reusable PackedScene; visual back/front where occlusion requires it; object-owned InteractionSlots/footprint. |
| Furniture | table, chair, bench | Reusable PackedScene with contact-origin, footprint, optional seat/approach slot; movable only where current rules allow. |
| Cat-life | bed, scratch post, rest/sniff fixture | Reusable PackedScene and semantic slot; may be movable later only after route/footprint policy. |
| Decor/vegetation | planter, garden plant patch | Reusable scene or non-interactive sprite; collision/slot only when gameplay needs it. |
| Exterior/atmosphere | ground material, sunlit zone | Room-owned surface or FX. A sun spot is a semantic activity zone, not necessarily a furniture asset. |
| Actors/feedback | worker, customer, cat, order bubble, steam, carried cup, reward, HUD | Separate character/FX/UI pipelines. Not furniture catalog records merely because they are visible. |

## Minimal record schema

Authoritative Godot `.tres` definition (typed custom Resource when implemented), plus a generated read-only JSON browse index. Do **not** hand-maintain two authorities. Required: `asset_id` (stable lowercase namespace), `revision`, `display_name`, `category`, `source_pack_id` (or `project_owned`), `source_sha256`, `runtime_scene` or `runtime_texture`, `preview_path`, `contact_pivot_px`, `world_unit_scale`, `footprint_size`/shape, `capabilities` (e.g. `sit`, `work_coffee`, `sniff`), `allowed_rotations`, `status` (`PROTOTYPE`, `CANDIDATE`, `FINAL`, retired). Useful as needed: `visual_style_family`, `room_tags`, `variant_of`, `notes`. Dimensions should be measured from the runtime image, not typed as an independent guess. Each placed instance stores `instance_id`, `asset_id/revision` only if variant switching is supported, room ID, transform and mutable state; existing V1 furniture saves currently store transform deltas only, so adding variant persistence is a later migration, not implied by this document.

Source/pack record: `pack_id`, exact author/publisher, canonical URL, downloaded version/date, license identifier **and retained license text/path**, commercial permission, modification permission, attribution text/requirement, allowed use status (`RESEARCH`, `PROTOTYPE`, `PRODUCTION_CANDIDATE`), and reviewer/date. Asset records reference this pack record; per-file exceptions override it. Unknown or ambiguous license → **RESEARCH only**, never production import. CC0 still receives provenance. Check license of the exact acquired archive, not just today's webpage. Respect non-license creator requests where applicable and never copy unlicensed Godot Valley art/code. Keep original external files in a provenance folder outside runtime imports (with `.gdignore`), and runtime derivatives under `assets/` only after approval.

## Validation and browsing

Build-time checks: unique IDs/revisions, valid source hash, exact path existence, license/use gate, nonzero visual bounds, pivot inside intended canvas/contact band, sane scale relative to footprint, required slots for declared capability, preview freshness, and forbidden source/output overwrite. Godot in-scene proof then checks silhouette, overlap, y-sort/occlusion, touch area, routes and camera zoom. A `PASS` from the compiler is technical, not art approval. Catalog browsing can start as a generated Markdown/HTML contact sheet or Godot editor list with consistent 2D thumbnails and filters by category/status/style/license/capability; an Astro site or major editor plugin is unnecessary.

## Minimal Asset Forge evolution

Existing `tools/willicat_asset_forge/` already performs deterministic character processing and `build-static` PNG packaging with source hash, pivots, dimensions, alpha edge checks and status. Its `SKILL.md` keeps immutable sources and derived runtime assets separate. Extend in narrow order: (1) `register` source/pack metadata and license gate; (2) catalog validation; (3) deterministic preview from runtime asset at project camera scale; (4) optional generator for a *small* typed resource and browse index. The Forge should **not** own level layout, collision editing, navigation, placement UI, material painting, animation authoring or save migration. Those remain Godot/editor and game-system responsibilities. The currently modified Forge files in the working tree belong to pre-existing work; this research does not edit them.

## Rendering strategy decision

| Option | Strength | Cost/risk for WilliCat |
|---|---|---|
| A — modular illustrated 2D sprites | Reuses current scenes, y-sort, camera, animation and asset processing; cheap mobile runtime and direct art control | Needs disciplined pivots, perspective/scale templates and coherent kit art. Zoom exposes pixel quality. |
| B — model in 3D, render to 2D sprites | Gives repeatable perspective, lighting, variants and occlusion silhouettes while retaining 2D runtime | Offline render pipeline, alpha/normal/shadow consistency, many directional renders and asset/license provenance. |
| C — fixed-camera simple 3D room + 2D/2.5D characters | Genuine depth, physical lighting and flexible furniture angles | Requires new 3D collision/navigation/character integration, camera and interaction parity, mobile profiling, and style matching. Not justified by present proof. |
| D — hybrid 2D runtime with selected pre-rendered 3D assets | Keeps existing world/gameplay; uses 3D only where modular furniture/architecture consistency is faster | Two art pipelines and registration QA; must enforce one scale/pivot/material contract. |

**Recommend D, with A as the default runtime representation.** This is an asset-production hybrid, not a Godot 3D conversion: use illustrated 2D where it works; allow legally sourced/created 3D models to be rendered into approved 2D assets where they reduce art drift. No 3D commitment before one object A/B proof. This recommendation is falsifiable: if 2D/pre-rendered furniture cannot handle zoom, rotation, occlusion or lighting at mobile cost after representative tests, reassess a bounded fixed-camera 3D lab. The current room architecture and locked Home V3 remain untouched.
