# Home living continuous world / Tiny Swords DEV proof V1

## Open the proof

Run `res://scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn` in Godot 4.7. The route starts automatically. `ROUTE` replays it; click or tap the ground to walk, `LOOP` runs another café customer visit, `SNIFF` works in the Back Garden, `MOVE` drags café tables/chairs, and `SAVE`/`LOAD` use the dedicated Home proof save. `OVERVIEW`, `DEFAULT`, and `FOCUS` exercise the camera family. The older proxy café scene and its legacy Garden button remain available separately for regression.

## What is in one world

The new `HomeLocationRoot` inherits the successful Pixel Crawler proxy café and extends its world coordinates. Its front wall opening leads south to a Tiny Swords Front Plaza. The rear opening leads north to the Back Garden and its existing `cat_sniff` slot. A walkable path runs west from the plaza to a small Riverside, with real water, bank edge and a navigation boundary. The route never swaps scenes. It uses the existing `HardeningActor`, `NavigationAgent2D`, object/slot ownership, café service loop, and `CameraDirector`.

Outdoor terrain is built with 64-unit Godot `TileMapLayer` cells. The café retains its existing indoor tilemap, furniture, semantic IDs, slots and Y-sort behavior. Trees and the Garden plant are semantic world objects with `VisualRoot`; trees play the downloaded authored eight-frame strips at 10 fps, use their separate shadow, and obstruct only at the trunk. A water rock plays its authored frame strip. The shared Y-sort layer allows the visitor to appear in front of and behind a tree. The inherited logical placement grid remains 32 units and is expanded to cover the Home property. Furniture moves retain navigation and café/home route checks.

Area state is intentionally small: café, plaza, riverside and Garden report active/near/dormant based on the visitor's position and adjacency. The gameplay camera follows and zooms smoothly, clamps to the map edge, and yields to `CameraDirector` focus shots. This is a single navigation region with 67 baked polygons and 28 obstructions in the verified run. The doors and water edge are obstacles/gaps in shared space. Regional navmeshes can replace this if the Home map grows, without changing actor behavior.

The dedicated V1 save stores Home location, current area, visitor and cat positions, cat activity, café furniture deltas, coins, rewarded order receipts, sequence number and the legacy Garden progression flag. It restores both café and Garden checkpoints. The original two-room save remains separate and unchanged.

## Live-rendered evidence

Captured from Godot 4.7.2 OpenGL Compatibility, 540×960, with the character and environment actively updating:

- `01_home_location_overview.png` — café, plaza, Garden, Riverside and their spatial relationship.
- `02_cafe_to_plaza.png` — visitor physically crossing the front threshold.
- `03_animated_tree_depth.png` and `03b_character_behind_tree.png` — moving visitor on the two depth sides of a looping Tiny Swords tree.
- `04_back_garden.png` — rear connection, visitor, cat, terrain and Garden vegetation.
- `05_riverside.png` — walkable bank, water and safe edge.
- `06_character_world_scale.png` — visitor and tree/building scale in the plaza.
- `07_cafe_gameplay_preserved.png` — customer and worker visible while the service loop runs.
- `08_save_load_return.png` — loaded Home café with reward/progress status.
- `home_continuous_world_walkthrough.gif` — shortened sequence assembled from real rendered frames across the full route.

All captures are in `artifacts/prototype_review/home_continuous_world_tiny_swords_proof_v1/`.

## Validation and limits

`tests/test_home_continuous_world_v1.gd` completes the full route, checks the visitor has no position jump between physics frames, verifies authored tree frame advancement and all four physical areas, confirms the Garden sniff and café reward, moves and restores a chair, and saves/loads both café and Garden area state. The capture run also completed the same route and wrote all eight requested images. The older `tests/test_proxy_cafe_proof_v1.gd` should remain the regression gate for the legacy two-room proof.

The downloaded pack contained no license/README/redistribution terms. Only inspected selections are copied under ignored `assets/dev_proxy/tiny_swords/`; they are temporary local source art, not first-party WilliCat assets. No original Downloads files were edited, no plugin was installed, and no commit or push was made. The Garden cat is still its prior DEV placeholder drawing. The river look point is a future semantic anchor; river gameplay is not implemented.

See `docs/research/WILLICAT_TINY_SWORDS_ASSET_SYSTEM_STUDY_V1.md` for measured source conventions and `docs/architecture/WILLICAT_ASSET_PACK_STANDARD_V1_DRAFT.md` for the first-party pack contract draft.
