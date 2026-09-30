# WilliCat asset pack standard V1.1 — draft

Evidence: the continuous Home V1 proof, the live visual comparison in `scenes/dev/visual_proxy_lab/home_visual_proxy_lab_v1.tscn`, measured local source sheets, and the moving-character route captured on 2026-09-30. This is a handoff standard candidate for first-party **non-pixel** art, not a requirement to copy any proxy pack's resolution, color or style. Rights/redistribution are reviewed separately.

## World unit and projection

- World size is in Godot 2D units. Source pixels, logical placement cells, drawn silhouette, interaction reach and physical collision are distinct measurements. Every asset declares `source_pixels_per_world_unit` or an equivalent prefab visual scale. A room does not recalibrate it.
- One Home location shares coordinates and navigation across Café, Front Plaza, Riverside and Back Garden. Deliver an elevated three-quarter reference camera and portrait reference framing. State the asset's authored projection, viewing angle and permitted orientation/mirroring.
- The proved DEV placement grid uses 32 world-unit cells and the outdoor art uses 64-source-pixel terrain cells. Neither number is locked for first-party exports. Record the mapping between placement grid, visual ground span and collision geometry.

## Terrain

- Deliver base, edge, inner/outer corner, path/door threshold, water and bank variants with an atlas map and documented intended neighbors. Specify source tile size, world tile size, texture filtering, transparent padding and transition rules.
- Terrain art does not decide navigation. Supply walkability and bank/wall boundaries separately. Test a walking actor crossing a café threshold and a path edge without a scale or foot-contact jump.
- Ambient terrain frame lists must identify which cells are animation frames and which rows are different states. The SuperRetroWorld fire/campfire example shows why treating an entire sheet as one loop is unsafe.

## Buildings and exterior upgrades

- A building handoff declares base/back, interior floor/wall (if traversable), foreground occluder, collision shell, door apertures, door approach anchors and upgrade variants. A full exterior raster is not evidence of a usable interior.
- Register all layered views to one declared canvas and pivot. FreeAssets Restaurant/Cinema prove that a sparse Front file can share exact pixel coordinates with the complete base, allowing `base → actor → front` draw order. Specify exactly which parts Front duplicates. Keep any occluder separate from collision and Y-sort rules.
- Upgrade variants preserve semantic IDs, world footprint, walkable entrance and anchor positions unless a migration and nav test are supplied. The measured apartment levels preserve canvas/bottom registration while adding height; increasing roof art must not silently move the door or gameplay root.

## Furniture and reusable compositions

- Each piece is one semantic object with stable ID/kind, `GameplayRoot`, `PhysicalFootprint`, interaction slots, `VisualRoot`, optional shadow and an explicit floor-contact pivot. Visual variants never create new gameplay identities.
- The source sheet/frame registration belongs to the asset/prefab. The tested Cozy wood chair uses an authored 384×384 direction cell, `(192,380)` sheet pivot and 0.18 DEV world scale. Those **measured proxy values are examples only**. The eight trimmed files have unequal canvases, so individual PNG top-left placement is invalid.
- Directional variants declare exactly which of N, NE, E, SE, S, SW, W, NW exist and what `facing` means (seat occupant direction, object front or camera-facing art). Never rotate a raster view to fake an authored direction. If a direction is absent, declare an approved fallback or block it.
- A seat has an action anchor, approach and exit anchors, seated actor facing, occupancy limit, allowed body types and any front armrest occluder. A wide loveseat or booth needs its own footprint/slot model even if its source pivot matches a chair.
- A reusable composition may bind known-good visual and spatial relationships while leaving existing semantic members directly addressable. `CafeTableSet2.tscn` demonstrates a small binding; avoid a new general prefab framework. Store table/chair relative placement, facing and visual scales with the composition and its member prefabs.

## Characters

- Follow `WILLICAT_CHARACTER_RUNTIME_PRODUCTION_CONTRACT_V1_1.md`: fixed logical floor root, visual offset metadata, explicit clip/direction mapping and opt-in mirroring. Declare frame canvas and per-frame foot baseline so raised paws do not shift the physical character.
- Require Idle and Walk in the directions the runtime actually needs; list actions separately (sit enter/idle/exit, carry, sniff, etc.). Each clip declares frame order, count, timing, loop mode and allowed mirroring. An unlabeled atlas cannot be promoted into a runtime animation contract.
- Test the character beside a chair and bar, through both doors, and in front of/behind vegetation. Match foot contact and scale in indoor and outdoor portrait views.

## Animated props, shadows and depth

- A prop states whether it is static, state-switched or looped. Provide frame canvas, frame map, durations, loop flag and optional start-phase policy. Prefer authored motion when present; use sparse ambient motion with static structure and moving actors.
- Shadows are separate declared layers or clearly identified baked pixels. State ground plane, opacity intent and whether lighting modulates them. Do not allow a decorative shadow to change collision or placement bounds.
- Every visual declares the floor pivot and baseline in source pixel coordinates, its target world scale, and the Y-sort/canvas-layer policy. For large foliage, collision is around trunk/base; crown may overlap a walking actor. For front architecture, use an explicit foreground occluder that registers to the same base canvas.

## Naming and metadata

- Use stable asset IDs and names that expose family, asset, action/state, direction, variant and resolution where applicable; a machine-readable manifest remains authoritative. The SuperRetroWorld `01` suffix did not mean direction, because the four directions were rows inside each file.
- Minimum manifest per family: `asset_id`, category, rights/source record, style family, projection, canvas, frame map, alpha bounds, floor pivot, world scale, world footprint, directions, clip timing, collision, shadows, interaction anchors, draw-order/occlusion rule, output paths and target Godot scene. Mark provisional values explicitly.
- Keep DEV third-party source ignored and out of repository history when terms are absent/ambiguous. First-party final art should include source ownership, license and export rights records.

## Godot handoff and acceptance

- Deliver a semantic scene and a visual child scene/resource; the scene owns visual scale, pivot and per-direction atlas mapping. Slot, nav, collision, save ID and camera systems remain independent. No room script should crop a sheet or guess scale anew.
- Include a small authoring test scene and a moving-character acceptance scene. Required views: all authored furniture directions against one table; furniture footprint after visual switch; actor sits/stands and walks past a bar; café→plaza→riverside→café→garden→café route; actor in front of/behind an animated tree; building base/actor/front if the asset uses one; portrait camera; save/load after a legal furniture move.
- Capture real viewport frames with overlays off and retain a rollback scene. A static empty-room image is insufficient. The V1 lab's nine live screenshots and full-route regression are the first concrete acceptance example for this revision.
## First-party Mini Pack 001 observations (2026-09-30; draft evidence only)

- A 256 px terrain export mapped to one existing 64-world-unit TileMapLayer cell with 0.25 visual scale, while the café floor reused existing 32-world-unit cells at 0.125 scale. This is a successful local mapping, not a universal asset resolution rule. The live route and 39-entry coordinate comparison found no art-driven position or footprint change.
- Four authored tree poses on a fixed 512×640 canvas, pivot `(256,600)`, and a separate neutral shadow preserved the existing 28×26 trunk obstruction. A compact authored 0.8 s breeze loop is sufficient for this proof; final ambient timing remains open for art review.
- Eight separately authored chair views on 384×384 cells, pivot `(192,364)`, worked in the existing two-table seating compositions without moving seats or modifying SeatSlot anchors. The table used a 512×512 export with pivot `(256,480)` and an unchanged 108×80 footprint.
- Generated sheets can satisfy a pose brief while clipping at cell gutters or reversing prompted facing labels. Source-edge alpha rejection and human direction inspection are required before normalization. The accepted orange profile outputs were mapped by visible facing; a Down Walk pose overlapping the gutter was discarded.
- The first-party café proof needed an independent back wall and split front rail. An overlapping all-in-one source sheet could not be promoted safely. The live cat crossed the original central aperture while the rails participated in Y-sort; the original collision envelope stayed authoritative.
- A single base water texture plus four small authored ripple frames kept river motion separate from navigation. The initial padded bank piece produced repeated visual gaps; two alternating central crops from the authored straight-bank source repaired the live edge without moving the water boundary.
- The ROUTE DEV button was the only HUD control reskinned. Its pressed signal started the unchanged Home route and the coffee FX was triggered by the existing `Coffee ready → carrying` phase event. The result supports limited visual binding at semantic anchors without a new gameplay framework.

Evidence: `docs/production/WILLICAT_FIRST_PARTY_ANIMATED_STORYBOOK_MINI_PACK_001_RESULT.md`, `docs/source_assets/first_party_storybook_mini_pack_001/qa/validation_report.json`, and real Godot captures in `artifacts/prototype_review/first_party_storybook_mini_pack_001/`. This standard remains a draft.
