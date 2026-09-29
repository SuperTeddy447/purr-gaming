# World architecture hardening V1 evidence

Isolated placeholder lab only. All 18 PNGs are real Godot-rendered viewports, not reconstructed artwork; `.gdignore` excludes this folder from runtime imports. Captures 01–06 and 09–18 came from the F6 dev harness, and 07–08 were captured from the live GodotAI game viewport before/after moving EspressoStation in the Editor. All are valid, nonzero RGB PNGs. Normal embedded viewport: **539×959** (near 9:16). The tall proof uses a separate actual Godot `SubViewport` at **539×1168**; it is not a resized/cropped image.

| File | State / inspection | Result |
| --- | --- | --- |
| `01_hardening_lab_overview.png` | Complete placeholder room; object relationships | Captured |
| `02_table_navigation_avoidance.png` | Debug route across table; see nav path around footprint | Captured |
| `03_chair_a_reserved.png` | Customer A occupies Chair A | Captured |
| `04_chair_b_second_customer.png` | Customer B uses second chair, no double occupancy | Captured |
| `05_catbed_reserved.png` | Cat A holds capacity-1 bed | Captured |
| `06_second_cat_alternate_action.png` | Cat B rejects occupied bed and uses Plant/Sniff | Captured |
| `07_espresso_before_move.png` | GodotAI Editor move proof: earlier Espresso location | Captured live |
| `08_espresso_after_move.png` | Espresso moved independently; counter shell remains | Captured live |
| `09_owned_anchors_after_move.png` | Debug anchors/footprints after saved editor moves | Captured |
| `10_gameplay_camera_before_focus.png` | Nondefault pan/zoom before worker action | Captured |
| `11_brew_closeup.png` | Worker at Espresso, steam and focus | Captured |
| `12_cup_reveal.png` | Cup placeholder and second focus | Captured |
| `13_camera_restored.png` | Camera returned to pre-shot pan/zoom | Captured |
| `14_tall_phone_focus.png` | Same Brew action at real 539×1168 viewport | Captured |
| `15_event_variant_off.png` | Base room without seasonal display | Captured |
| `16_event_variant_on.png` | Event display/FX/footprint activated | Captured |
| `17_event_object_interaction.png` | Cat using event InspectSlot | Captured |
| `18_event_camera_focus.png` | Director using event-owned focus anchor | Captured |

Reproduce 01–06, 09–18: open `res://scenes/dev/world_architecture_hardening_lab.tscn`, run current scene in the Godot 4.7.2 Editor, press **F6**, and wait for `HARDENING CAPTURE COMPLETE` in the game output. F7 toggles footprint/slot/path overlay; F8 moves prototype objects; F9 runs the concurrent actor demo; F10 toggles the event; F11 focuses it; F12 cancels a shot. For 07–08, use GodotAI on the running dev scene: capture the game viewport, move `EspressoStation` in the Editor and save, rerun and capture again. The live proof used Espresso `(350,205)→(330,216)` with Chair A, Bed and Plant moved as documented in the architecture test; no production scene was moved.

Visual review caveat: these deliberately crude placeholders prove ownership and mechanics, **not** final comfort/readability or mobile safe-area approval. Brew/tall shots are close enough to crop the room title and peripheral props by design; keep this visible for human composition review rather than masking it. Tests assert structural restore/slot/path behavior separately; screenshots alone do not prove reservation state.
