# WilliCat Functional Prototype V1 — Visual Capture Pack

These captures are evidence of the Home prototype as it is currently rendered. They are full-frame PNGs from the actual `HomeScene` running in a Godot `SubViewport`; they were not generated, reconstructed, cropped, or retouched. The capture run used Godot 4.7.2, the normal macOS Metal / Forward Mobile renderer on Apple M2 Pro, and a fixed 60 FPS step. The adjacent `.gdignore` keeps this review-only directory out of Godot's runtime asset imports.

The harness instantiates the current Home scene and reuses its one `VerticalSliceController`, worker/customer states, markers, door controller, feedback, and reward path. Baseline captures hold automatic start so the idle composition is stable; the loop is then started explicitly in MANUAL mode, with the first available seat (Seat A) and a fixed random seed. No gameplay or layout behavior was changed for these captures.

All required captures succeeded. The PNGs are RGB, non-zero, decode successfully, and contain varied rendered pixels. Normal Home profile: **941×1672**. Tall phone: **941×2039**. 3:4 tablet: **1254×1672**. The camera zoom and debug/mode state below are recorded at capture time. Every capture used **MANUAL** prototype mode unless stated otherwise.

| Filename | Prototype state | What to inspect / capture result |
|---|---|---|
| `01_home_default_debug_off.png` | Idle baseline · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Home composition, default camera, canonical Mochi scale. **PASS** |
| `02_home_default_debug_on.png` | Same idle baseline · 941×1672 · zoom 1.000 · debug ON · MANUAL | Marker/asset labels, bounds, safe areas, hit-area/debug readability. **PASS**; current debug overlays overlap densely. |
| `03_customer_entering.png` | Customer entering · door opening · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Customer at entrance and door response/foreground relationship. **PASS** |
| `04_customer_seated_order.png` | Seat A · coffee order active · bubble visible · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Customer/order association and order readability. **PASS** |
| `05_mochi_coffee_action.png` | Preparing coffee at CoffeeAction · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Mochi/counter/station depth and clean-view preparation feedback. **PASS**; “BREWING…” is visible, machine-side progress arc is difficult to distinguish. |
| `06_coffee_preparing_debug.png` | Same preparation state · 941×1672 · zoom 1.000 · debug ON · MANUAL | Worker state, station, progress, debug readout. **PASS**; debug readout competes with scene labels. |
| `07_mochi_carrying_coffee.png` | Coffee ready · Mochi carrying en route to service point · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Real carry state during the existing walk route (at least 72 world units from CoffeeAction). **PASS**; in this full-frame view the cup is not clearly distinguishable and Mochi is partially masked by the current counter/station overlap. |
| `08_serving_customer.png` | Serving timer active at service point · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Serve feedback and character visibility. **PASS**; Mochi is largely occluded by the counter at ServePoint. |
| `09_reward_feedback.png` | Immediately after serve · reward +5 · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Reward, removed order bubble, removed carry visual. **PASS** |
| `10_customer_leaving.png` | Customer crossing entrance · door reacting · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Exit path, door and entrance foreground behavior. **PASS** |
| `11_loop_reset_idle.png` | Cycle complete · no customer · Mochi idle · door closed · 941×1672 · zoom 1.000 · debug OFF · MANUAL | No stale order/cup; next-loop readiness. **PASS**; current HUD retains “Customer left · next customer soon” while this one-cycle capture run has repeat disabled. |
| `12_depth_table_behind.png` | Existing behind-table test pose · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Table/chair naturally occludes the rear-positioned placeholder character. **PASS** |
| `13_depth_table_front.png` | Existing in-front-of-table test pose · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Y-sort reverses naturally for the front-positioned placeholder character. **PASS** |
| `14_counter_occlusion_test.png` | Mochi at CoffeeAction · counter guide visible · 941×1672 · zoom 1.000 · debug ON · MANUAL | CounterBack, runtime Mochi, CounterFrontOccluder and layer labels. **PASS**; debug readout still overlays the upper scene. |
| `15_camera_effective_min.png` | Effective minimum zoom · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Check world bounds and empty-space exposure. **PASS**; this profile’s effective minimum equals default zoom. |
| `16_camera_default.png` | Default camera · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Canonical framing. **PASS** |
| `17_camera_max_zoom.png` | Maximum configured zoom · 941×1672 · zoom 1.350 · debug OFF · MANUAL | Character/environment readability at max zoom. **PASS** |
| `18_visual_master.png` | Existing F6 Visual Master mode · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Approved locked master with the current runtime Mochi/HUD layer. **PASS** |
| `19_modular_vs_master.png` | Optional comparison artifact | **Skipped**; compare the two sequential full-frame captures `01_home_default_debug_off.png` and `18_visual_master.png`. No split-screen feature was added. |
| `20_aspect_9x16.png` | 9:16 baseline profile · 941×1672 · zoom 1.000 · debug OFF · MANUAL | Default Home at the project’s baseline aspect. **PASS** |
| `21_aspect_tall_phone.png` | Tall-phone profile · 941×2039 · zoom 1.2195 · debug OFF · MANUAL | Existing camera/aspect test dimensions and effective minimum. **PASS** |
| `22_aspect_3x4.png` | 3:4 tablet profile · 1254×1672 · zoom 1.3326 · debug OFF · MANUAL | Existing camera/aspect test dimensions and effective minimum. **PASS** |

## Visual notes for review

- No visual/layout fixes were made. The captures preserve the current modular graybox, camera framing, artwork, and debug behavior.
- At the service point, Mochi and the carried cup appear largely occluded. Please review captures 07–08; this pack records that behavior rather than moving the marker or changing depth.
- Preparation text is visible, while the machine-side progress cue is not readily legible in the full scene. Debug view also has substantial overlapping readouts/labels; see 02, 06, and 14.
- The master comparison is intentionally a different, much more polished environment rendering than the current modular café. See 01 and 18 in sequence; neither image was altered to improve the match.

## Regenerate

Run this from the repository (without `--headless` so the project uses a real renderer):

```sh
/Applications/Godot.app/Contents/MacOS/Godot --fixed-fps 60 --path /Users/teddywoot/willi-cat --script res://scripts/dev/functional_prototype_capture.gd
```

The script waits on the real prototype states/signals, saves the PNGs to this directory, reports viewport size/zoom/debug/mode for each, and exits non-zero on a state timeout or invalid/blank capture.
