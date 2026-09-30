# WilliCat visual proxy world and asset lab V1 — result

Status: ready for human visual review (2026-09-30). The rollback scene remains `scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn`; the comparison is `scenes/dev/visual_proxy_lab/home_visual_proxy_lab_v1.tscn`. Neither gameplay systems nor the original Home architecture were rebuilt.

## What changed

- Four café chairs now use Cozy Coffee's authored eight-direction sheet through a reusable `VisualRoot` adapter. The adapter owns sheet registration, `(192,380)` source pivot and DEV world scale, while the existing chair IDs, footprints and slots remain authoritative. The left/right chairs face their tables as NE/NW. Direction switches were verified against unchanged transforms and bounds.
- A small `CafeTableSet2.tscn` composition binds each existing table and two chairs to a compatible warm Retro Interior table visual. It is a visual binding for the existing semantic members, not a new gameplay/save parent. The two inherited seating rugs are hidden in the comparison so they do not distort the grouping.
- The service bar, espresso/POS/pastry equipment, shell, entrances, customer, worker and walking visitor retain their proven fallback visuals. This retains a clear service route while showing exactly where the new art helps and where coherent first-party art is still needed.
- An isolated FreeAssets restaurant scene proves base → walking proxy → registered Front occluder. The character walks laterally and is partly hidden by patio furniture. This scene is an occlusion technique proof; the exterior raster is not a replacement for the traversable Home café.
- The existing authored Tiny Swords trees and water-rock loop remain in the continuous map. No fake procedural ambient animation was added.

## Real Godot render proof

`artifacts/prototype_review/visual_proxy_world_asset_lab_v1/` contains nine live viewport captures (540×960, GL Compatibility, debug overlays off):

1. `01_current_pixel_crawler_baseline.png` — rollback café.
2. `02_directional_cafe_upgrade.png` — comparable café with a walking visitor and revised seating.
3. `03_seating_direction_check.png` — closer table/chair and moving-visitor inspection.
4. `04_building_layer_test.png` — isolated restaurant base/actor/front occlusion.
5. `05_front_plaza_living_world.png` — moving visitor outside the front threshold.
6. `06_back_garden_animated_environment.png` — moving visitor, continuous rear connection and animated trees.
7. `07_riverside.png` — moving visitor by bank, trees and water-rock animation.
8. `08_character_depth_route.png` — moving visitor partly behind the animated tree.
9. `09_home_overview.png` — one continuous Home after route and service/save/load completion.

The same folder also contains `home_visual_proxy_motion_proof.gif`, assembled from 94 additional live Godot frames of the revised Home route. The capture measured 4,677 frames with nonzero visitor walking velocity, completed the route, and shows café, outdoor travel, depth and service in motion. The PNG frames remain in `motion_frames/` for inspection.

## Runtime validation

- `tests/test_visual_proxy_lab_v1.gd`: authored direction selection, invalid-direction rejection, stable chair semantic transform/footprint, reusable table visual, preserved outdoor tree, full café→plaza→riverside→café→garden/sniff→café walk, customer enter/order/brew/serve/sit/exit, furniture move, save and load. Passed.
- The live capture script also required all nine frames and `route_succeeded == true`. Passed with one coin earned and Home save/load performed after the service loop.
- The unchanged `tests/test_home_continuous_world_v1.gd` rollback regression passed, including route, furniture move and Garden-area save/load. The older `tests/test_proxy_cafe_proof_v1.gd` service/room regression also passed.

## Limits for review

The new seating makes direction and grouping legible, but the proxy packs still differ in palette, pixel density and outline. The old service bar and the Tiny Swords outdoors remain deliberately visible as sources of that gap. The FreeAssets restaurant provides no traversable interior; the test validates draw order only. New raw art is kept in ignored `assets/dev_proxy/` paths because several source rights are absent or ambiguous. No pack was committed, no new artwork was generated, and no production UI or world system was replaced.

The research evidence, pack-role matrix and local license table are in `docs/research/WILLICAT_VISUAL_PROXY_ASSET_LAB_V1.md`. The two next-step contracts are `docs/architecture/WILLICAT_ASSET_PACK_STANDARD_V1_1_DRAFT.md` and `docs/architecture/WILLICAT_ASSET_FACTORY_INPUT_CONTRACT_V1_DRAFT.md`.
