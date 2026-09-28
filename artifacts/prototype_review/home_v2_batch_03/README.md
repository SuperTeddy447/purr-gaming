# Home V2 Batch 03 — Composition Review Captures

All current and iteration images are full-frame PNGs saved directly from the running Godot 4.7.2 `SubViewport` using the Mac Metal renderer. No image was generated, composited, cropped, annotated outside the scene, or filtered. `00` is the pre-pass baseline; `01`–`03` are the three actual comparison iterations. All captures are successful, non-empty RGB PNGs.

Capture camera/layout stays under the existing camera config. The guide screenshot is the only composition-guide view; ordinary screenshots keep guides off. `24`–`26` use the existing `VerticalSliceController` in manual mode, not a screenshot-only gameplay simulation.

| Filename | Prototype state | What to inspect | Viewport / camera | Debug / mode | Capture |
| --- | --- | --- | --- | --- | --- |
| `00_before_runtime.png` | V2 layout before Batch 03 | Starting table, seat, right lounge, signage and entrance registration | 941×1672 / default 1.00× | OFF / manual idle | Success; baseline |
| `01_iteration_1.png` | Iteration 1 | Table scale and paired left/lower-center seating | 941×1672 / default 1.00× | OFF / manual idle | Success |
| `02_iteration_2.png` | Iteration 2 | Right lounge/cat-life grouping and window association | 941×1672 / default 1.00× | OFF / manual idle | Success |
| `03_iteration_3.png` | Iteration 3 | Final sign, entrance plant and pastry-case registration | 941×1672 / default 1.00× | OFF / manual idle | Success; recaptured after final candidate registration |
| `10_final_runtime_clean.png` | Final candidate normal view | Whole café hierarchy, open circulation, composition and placeholders | 941×1672 / default 1.00× | OFF / manual idle | Success |
| `11_final_runtime_guides.png` | Candidate with registration guides | Zone extents and seat/worker/service markers | 941×1672 / default 1.00× | Guides ON / manual idle | Success |
| `12_counter_zone.png` | Counter-focused view | Espresso/grinder/POS/case grouping and back/front relationship | 941×1672 / max 1.35× (bounds-clamped) | OFF / manual idle | Success |
| `13_left_table_zone.png` | Left-table view | Window perch, vase, table, two seats and anchor feet | 941×1672 / max 1.35× (bounds-clamped) | OFF / manual idle | Success |
| `14_lower_center_zone.png` | Lower-center view | Table/chair scale and circulation clearance | 941×1672 / max 1.35× (bounds-clamped) | OFF / manual idle | Success |
| `15_right_lounge_zone.png` | Right lounge view | Bed, cushion, basket, stool, scratch post and plant | 941×1672 / max 1.35× (bounds-clamped) | OFF / manual idle | Success |
| `16_entrance_zone.png` | Entrance view | Arch/door placeholder, freestanding sign and paired foreground plants | 941×1672 / max 1.35× (bounds-clamped) | OFF / manual idle | Success |
| `20_9x16.png` | Canonical phone profile | Full composition and safe zoom | 941×1672 / effective min 1.000× | OFF / manual idle | Success |
| `21_tall_phone.png` | Tall phone profile | Vertical crop and object readability | 941×2039 / effective min 1.219× | OFF / manual idle | Success |
| `22_wide_device.png` | 3:4 profile | Horizontal composition and bounded crop | 1254×1672 / effective min 1.333× | OFF / manual idle | Success |
| `23_desktop.png` | Existing desktop preview profile | Wide viewport behavior and scene scale | 1280×720 / effective min 1.360× | OFF / manual idle | Success |
| `24_coffee_action.png` | Existing loop, coffee preparation active | Mochi at CoffeeAction; front fascia occlusion; prep cue and order state | 941×1672 / default 1.00× | OFF / manual, preparing | Success |
| `25_serve.png` | Existing loop, serving active | Worker/customer/service relationship and carry presentation | 941×1672 / default 1.00× | OFF / manual, serving | Success |
| `26_return.png` | Existing loop completed | Reward, customer exit, worker idle, closed door and cleared order | 941×1672 / default 1.00× | OFF / manual, settled | Success; 1 reward, 5 coins |

The max-zoom focus views do not expand or bypass `pan_bounds`; centers are clamped by the existing camera controller. This intentionally leaves some requested object edges less centered where the existing safe bounds require it.

## Review notes

- The primary style master is `docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_PRODUCTION_STYLE_LOCK_V1.png`; composition guidance is `docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_GAMEPLAY_TRANSLATION_V1.png`. The prompt's shorter `docs/references/home/v2/` location does not exist.
- Known differences remain visible: portrait/square modular main-sign frame vs. the master's wide silhouette, and the existing cream placeholder entrance leaves inside the detailed arch. See `docs/production/WILLICAT_V2_BATCH_03_COMPOSITION_DIAGNOSIS.md` and `WILLICAT_V2_BATCH_03_HUMAN_REVIEW.md`.
- The return frame intentionally shows normal scene presentation/HUD and ambient feline behavior; no gameplay visuals were hidden for the capture.

## Regenerate

From a terminal on this Mac, run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --fixed-fps 60 --path /Users/teddywoot/willi-cat --script res://scripts/dev/home_v2_batch_03_capture.gd
```

This re-renders `03`, `10`–`16`, and `20`–`26`. Historical `00`, `01` and `02` remain untouched. The `.gdignore` in this directory keeps review evidence out of Godot's runtime import tree.
