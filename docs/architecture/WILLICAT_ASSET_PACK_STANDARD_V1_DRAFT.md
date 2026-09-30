# WilliCat asset pack standard V1 — draft

Status: candidate contract derived from the working Pixel Crawler café and Tiny Swords outdoor DEV proof. Values below should be validated with first-party WilliCat art before locking. Source-art rights remain separate from this technical contract.

## World

- One shared 2D world-coordinate system per physical Home location. The café, Front Plaza, Back Garden and Riverside are spatial areas within that location, with continuous navigation and camera movement.
- Elevated three-quarter presentation, portrait framing, no free rotation. Ground contact, rather than texture center, is the Y-sort baseline.
- Candidate logical placement cell: **32 world units**, matching the tested café placement grid. Candidate outdoor terrain art cell: **64×64 source pixels mapped to 64 world units**. These are separate measures; a prop may occupy multiple logical cells or overlap several art tiles.
- Each area declares bounds, adjacency, active/near/dormant state, route anchors and nav boundary. Far areas may reduce simulation without disappearing at thresholds.

## Terrain

- Deliver `TileSet`-ready base cells, terrain edge and corner cells, interior fill, transition cells, and a documented atlas coordinate map. A flat background screenshot is not a terrain deliverable.
- Distinguish grass, paving/path, water and river bank. Surface transitions need authored edge conventions and test scenes at straight edges, inner/outer corners and door thresholds.
- Animated terrain or ambient props carry source frame size, count, order, loop flag and per-frame duration. Unanimated surfaces remain static unless the art contains authored frames.
- Tile pixels do not define navigation or placement occupancy. Walking boundaries and bank safety are authored gameplay data.

## Furniture

- Semantic `HardeningWorldObject` identity (`stable_id`, `kind`) owns a `VisualRoot`, a floor contact pivot, a small `PhysicalFootprint`, and owned interaction slots/anchors.
- Package the art with an explicit native pixel scale, target world scale, transparent canvas, baseline and optional directional variants. Do not infer collision from alpha bounds.
- Furniture position and rotation deltas are saved against authored coordinates. Valid moves check occupancy, clearance and required circulation paths; slot anchors move with the object.

## Buildings

- Separate interior floor/wall shell, exterior front, entrance threshold, rear connection and foreground occluder where needed. Give each entrance a walkable aperture and approach markers on both sides in the same coordinate space.
- Provide building footprint and navigable door gap metadata independently from decorative roof or wall pixels. Explicitly test paths through every local threshold.
- Upgrades can replace a visual variant while preserving semantic IDs, entrance anchors, interaction slots and save compatibility. Their size changes require navigation/placement validation.

## Characters

- Candidate first-party frame contract: stable transparent 64×64 frame canvas for café-scale actors, rendered at 2× in this DEV proof, with one consistent foot baseline. Final character art must validate scale in both indoor and outdoor views before that size is fixed.
- Required animation set: `Idle` and `Walk` in down, up and side directions; define whether left mirrors right or has separately authored frames. Store fps or per-frame durations with each strip, not only in engine code.
- The existing `HardeningActor`/`NavigationAgent2D` owns movement and interactions. `VisualRoot` is presentation only and uses velocity for facing. This separation allowed one Pixel Crawler proxy visitor to walk the entire Home route without replacing character behavior.

## Environment props

- Static and animated props are semantic prefabs grouped by composition and area. Deliver transparent visual canvas, ground-contact pivot, optional separate shadow, trunk/base collision footprint, navigation obstruction and interaction anchors.
- Animated tree reference: 192×256 eight-frame strip at 100 ms per frame, stable canvas, trunk contact near frame bottom, 28×26 DEV trunk obstacle. These are measured Tiny Swords proof values, **not** a mandated first-party tree style or size.
- Place large foliage in the Y-sorted world layer. A character must pass both behind and in front of one test tree while the tree continues to animate. Avoid arbitrary per-object z-index patches.
- Use quiet ambient loops selectively; do not turn every prop into a moving decoration.

## Required pack handoff and acceptance

Every final asset family should include: source file, export(s), usage/redistribution terms, atlas or strip map, frame timing, scale, pivot/baseline, collision footprint, optional shadow, semantic name/ID, and a small Godot test scene. The acceptance scene should show a moving character crossing at least one doorway, one terrain transition and one foreground/background vegetation boundary. Recheck navigation, service interactions, furniture moves, save/load and portrait camera after each art swap.
