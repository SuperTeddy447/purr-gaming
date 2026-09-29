# Home V3 Level Design Pass 01 — live Godot review pack

These PNGs are unretouched full game viewports captured from the running Godot 4.7.2 scene. `00` is the inherited architecture-lab baseline; `01–11` are Pass 01. They are review evidence, **not runtime assets or final-art references**. The folder has `.gdignore`.

| File | State / inspect | Pixels | Result |
| --- | --- | ---: | --- |
| `00_before_architecture_lab.png` | Baseline four horizontal bands and original cat zoning | 540×960 | Captured |
| `01_normal_9x16.png` | Default world; service, tables, cat nooks, entrance, event space | 1428×2539 | Captured |
| `02_debug_slots_footprints_routes.png` | Owned slots, real red footprints, live route and three waiting anchors | 1428×2539 | Captured |
| `03_multi_actor_9x16.png` | Existing two-customer/three-cat/worker semantic demo in motion | 1428×2539 | Captured |
| `04_crowd_five_customers.png` | Five-customer transient staging; entry/order/seat contention | 539×959 | Captured |
| `05_brew_focus.png` | Worker + Espresso + Brew feedback; object-owned focus | 1428×2539 | Captured |
| `06_cup_reveal.png` | Worker + machine + Cup reveal; object-owned focus | 1428×2539 | Captured |
| `07_cat_emotion_focus.png` | CatBed rest/emotion and adjacent café context | 1428×2539 | Captured |
| `08_event_state_9x16.png` | Active SeasonalDisplay niche, cat inspect, door clearance | 1428×2539 | Captured |
| `09_tall_phone_normal.png` | Normal world on tall portrait | 539×1168 | Captured |
| `10_tall_phone_multi_actor.png` | Worker, customer and three simultaneous cat activities on tall portrait | 539×1168 | Captured |
| `11_tall_phone_event.png` | Event on tall portrait | 539×1168 | Captured |

The current main Editor game stretch yields a 1428×2539 captured backing viewport for the nominal 9:16 game. The crowd and tall images come from development-only `SubViewport` instances of the **same** scene/behavior at 539×959 and 539×1168. The capture script waits for real actor phases and CameraDirector shot states; it does not simulate fake screenshots. All files were checked as readable, non-zero PNGs with the dimensions above and visually inspected for blank/failed render.

## Reproduce

1. Open `res://scenes/dev/home_v3_level_design_pass_01.tscn` in Godot and run **Current Scene** (F6 in Godot's editor, or the top-right current-scene run button). In the running game, press **F6** once to regenerate `01–11`. Wait for the output line `HOME V3 PASS 01 CAPTURE COMPLETE images=11` (roughly 1–2 minutes). This overwrites only this dev review pack's numbered PNGs, not the baseline `00`.
2. For an interactive look in the running scene: **F7** toggles debug slots/footprints, **F9** runs the existing 1-worker/2-customer/3-cat demo, **F5** runs the 5-customer crowd sanity, **F10** toggles event content. **F4/F8/F11/F12** remain the inherited camera/development controls.
3. To re-run the automated Pass 01 acceptance gate from the repository: `/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/teddywoot/willi-cat --script res://tests/test_home_v3_level_design_pass_01.gd`.

Review honestly: greybox labels overlap in a few areas, and these placeholder actor circles are not final character scale approvals. See `docs/design/WILLICAT_HOME_V3_LEVEL_DESIGN_PASS_01.md` for the decision and limitations.
