# Home Functional Readability Pass V1 — viewport evidence

These are unretouched PNGs from the running Godot 4.7.2 Home scene. The capture harness uses the existing manual Vertical Slice state transitions and a rendered `SubViewport`; it does not simulate a second gameplay loop. All captures passed PNG decoding/dimension checks and the harness's non-blank image check. The first 20 files are 941×1672 at default zoom 1.00 unless noted. Debug is OFF except where noted.

| File | Prototype state / what to inspect | Result |
| --- | --- | --- |
| `01_home_default_debug_off.png` | Clean default Home, canonical Mochi, no active customer | PASS |
| `02_home_default_debug_on.png` | Same scene with existing development overlays and hit regions | PASS |
| `03_customer_entering.png` | Customer entering through responsive door; entry cue | PASS |
| `04_customer_seated_order.png` | Customer, attached coffee-order bubble, next-action hint | PASS |
| `05_mochi_coffee_action.png` | Mochi behind counter; station progress and activity cue | PASS |
| `06_coffee_preparing_debug.png` | Same preparation state with development overlay | PASS |
| `07_mochi_carrying_coffee.png` | Coffee-ready cue follows Mochi en route; customer becomes serve target | PASS |
| `07b_ready_serve_target.png` | Customer ready bubble/ring and Mochi at ServePoint | PASS |
| `08_serving_customer.png` | Service state before reward | PASS |
| `09_reward_feedback.png` | Served reaction and +5 reward; order/carry cues cleared | PASS |
| `10_customer_leaving.png` | Leaving cue, customer near doorway, door open | PASS |
| `11_loop_reset_idle.png` | Customer removed, door closed, Mochi idle, no stale cues | PASS |
| `12_depth_table_behind.png` | Existing character-behind-table depth sample | PASS |
| `13_depth_table_front.png` | Existing character-in-front-of-table depth sample | PASS |
| `14_counter_occlusion_test.png` | Counter back / Mochi / counter front with debug guides | PASS |
| `15_camera_effective_min.png` | Current effective minimum zoom 1.00 | PASS |
| `16_camera_default.png` | Default camera zoom 1.00 | PASS |
| `17_camera_max_zoom.png` | Maximum camera zoom 1.35 | PASS |
| `18_visual_master.png` | Existing F6 Visual Master comparison | PASS |
| `20_aspect_9x16.png` | 941×1672, zoom 1.00 | PASS |
| `21_aspect_tall_phone.png` | 941×2039, zoom 1.2195 | PASS |
| `22_aspect_3x4.png` | 1254×1672, zoom 1.3326 | PASS |

All captures use PROTOTYPE MANUAL mode. No production art, camera setting, gameplay marker, modular slot, or stable asset ID was changed for the pictures. There is no separate `19_modular_vs_master.png`; compare `01` and `18` directly.

Regenerate the complete pack from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/teddywoot/willi-cat --fixed-fps 60 --script res://scripts/dev/functional_prototype_capture.gd -- readability-v1
```

Human review should pay special attention to how little of Mochi's body and the attached cup can be seen from behind the existing counter, especially at ServePoint. The new world-space cue communicates the state, but does not change the locked occlusion or placement. The existing top-left prototype status text and F1 button are still visible with debug OFF; this pass does not redesign the HUD.
