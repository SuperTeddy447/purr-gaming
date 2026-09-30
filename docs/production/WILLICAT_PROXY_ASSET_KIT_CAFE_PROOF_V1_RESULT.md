# WilliCat proxy asset kit café proof v1 — result

## What ran

Open `scenes/dev/proxy_cafe/proxy_playable_world.tscn` to play the local proof. It inherits the existing Main Café and uses the existing `PlaceholderWorld`, `PlaceholderCafe`, `HardeningActor`, slots, navigation, camera director, save identity, and Garden scene. The proxy installer changes only presentation and a few café slot anchor positions for visible counter contact. The original playable café and A01–A10 production batch remain available.

The proof contains two 16 px source-tile `TileMapLayer`s (wood floor and stone boundary) at 2× scale, so one logical placement cell is 32 world units. The independent `ProxyPlacementGrid` supplies `world_to_cell`, `cell_to_world`, `snap_to_cell`, rectangular occupancy, and clearance checks. It registers the initial tables, chairs, bed, post, and plant as an assembly check; the existing object footprints and navmesh remain the runtime authority. Furniture art may overhang its logical footprint.

All furniture sprites sit under each existing semantic object's `VisualRoot`. Stable IDs and InteractionSlots stay on those objects. The service bar, two table sets, and cat corner have named composition descriptors with member IDs; objects remain direct children of `WorldObjects` so the existing furniture-save traversal continues to work. These descriptors are dev assembly markers, not extracted production composition scenes yet. Directional chair sheets from the Cozy add-on were examined but deliberately not mixed with the Pixel Crawler family.

The customer and worker each have `CharacterBody2D → VisualRoot → AnimatedSprite2D`. Their original movement controller, navigation, category, state, and interaction calls are unchanged. The proxy uses down/up/right strips, valid horizontal mirroring for left, and only Idle/Walk. Source y = 48 is normalized across frames; at 2× display scale the visual is offset −32 world units so the feet meet the gameplay root. This is a human-sized development ruler, not a canonical WilliCat cat scale.

## Rendered evidence

Real Godot 4.7.2 OpenGL Compatibility renderer capture, 540 × 960, debug collision labels off:

- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/01_proxy_shell.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/02_proxy_cafe_overview.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/03_proxy_cafe_gameplay.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/04_proxy_service_bar.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/05_proxy_seating.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/06_proxy_character_walk.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/07_proxy_character_counter_occlusion.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/08_proxy_character_scale_check.png`
- `artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/proxy_character_walkthrough.gif` — an animated sequence of live rendered frames from entry, ordering, brewing, serving, seating, and exit.

The moving visitor passes through the entrance frame, traverses open floor and seating, stands in front of the counter, and moves to a chair. The worker crosses behind the counter face and is partially hidden by it during service. The screenshots and animation are the visual check; scene parsing alone was not used as evidence. The scene is intentionally a temporary, sparse pixel-art proxy. The cat remains a gray gameplay placeholder, and the human body-base sprite is plainly a dev stand-in.

## Gameplay regression

`tests/test_proxy_cafe_proof_v1.gd` passed: first and second café visits, one reward per order, a valid chair move and rejected invalid move, preserved slot anchor after a furniture move, Garden tap transition and return, cat Garden action, save/load in both rooms, and restored café progression. The test also checks both `TileMapLayer`s, the proxy `AnimatedSprite2D`, and grid occupancy conversions. The separate rendered capture completed one full visit and wrote all eight screenshots. Garden visual content was not edited.

## Decisions and limits

1. A coherent single-family pack improves scale consistency and makes table, door, counter, and actor proportions legible. The result is a development assembly proof, not final café art.
2. The runtime accepts a replaceable character presentation child without changing gameplay code. The current actor `_draw` placeholder is displaced only in this dev scene; a production integration should expose a visual toggle instead.
3. Existing semantic objects can be reskinned without changing stable IDs or interaction logic. A few slot anchor positions were calibrated in the proxy scene to align with the new counter face; gameplay coordinates are therefore not entirely frozen.
4. `TileMapLayer` plus a separate placement grid and semantic objects is a workable foundation for future areas. The named composition descriptors need conversion to true reusable scenes before treating the pipeline as production complete.

## Files added or changed

- Changed: `.gitignore` (ignores raw dev proxy extracts and generated review imports).
- Added: `assets/dev_proxy/pixel_crawler/` (ignored local cropped artwork), `scenes/dev/proxy_cafe/`, `scripts/dev/proxy_cafe/`, `tests/test_proxy_cafe_proof_v1.gd`, this result, the research audit, and the review captures.
- No commit or push was made.
