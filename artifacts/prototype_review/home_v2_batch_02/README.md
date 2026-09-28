# Home V2 Batch 02 — rendered review pack

All 13 PNGs below came from the real Godot 4.7.2 Metal-rendered `SubViewport` of `home_v2_environment_preview.tscn`, captured by `res://scripts/dev/home_v2_batch_02_capture.gd`. They were not painted, composited, cropped, or filtered. The only technical overlay is `03`; `01`–`02` and `04`–`13` are gameplay view. The capture uses canonical large (~150 px) Mochi, the existing camera, a deterministic manual Vertical Slice, and the V2-only counter-floor marker correction. PNG validity, dimensions, nonzero size and color variance were checked.

| Filename | State / device | Size | Inspect |
| --- | --- | --- | --- |
| `01_worker_idle_clean.png` | WorkerIdle; default camera | 941×1672 | Head/upper apron visible, lower body hidden. |
| `02_coffee_action_clean.png` | CoffeeAction; default camera | 941×1672 | Work position behind front lip; no feet on worktop. |
| `03_coffee_action_debug.png` | Same, technical overlay | 941×1672 | Back/front canvas, alpha silhouette, root/feet, shadow, CoffeeAction. |
| `04_prepare_clean.png` | Actual PreparingCoffee | 941×1672 | Prep feedback and occlusion. |
| `05_carry_exit_clean.png` | Actual WalkingToServe at left exit | 941×1672 | Full body reappears when passing counter edge. |
| `06_return_clean.png` | Actual ReturningToIdle behind counter | 941×1672 | Natural re-entry occlusion. |
| `07_return_idle_clean.png` | Worker idle after completed service | 941×1672 | Reset and no stale cup. |
| `08_aspect_9x16_min.png` | Effective-min zoom | 941×1672 | Canonical world coverage. |
| `09_aspect_tall_phone_min.png` | Effective-min zoom | 941×2039 | Tall aspect bounds. |
| `10_aspect_3x4_min.png` | Effective-min zoom | 1254×1672 | Wide/tablet bounds. |
| `11_aspect_desktop_min.png` | Effective-min zoom | 1280×720 | Desktop-preview bounds. |
| `12_tall_phone_max_pan.png` | Max zoom; bottom/right pan bound | 941×2039 | Extreme valid camera position, no exposed void. |
| `13_aspect_3x4_max_pan.png` | Max zoom; top/left pan bound | 1254×1672 | Opposite valid camera position, no exposed void. |

Regenerate from repository root (Godot requires a rendered display; do not use `--headless`):

```sh
/Applications/Godot.app/Contents/MacOS/Godot --fixed-fps 60 --path /Users/teddywoot/willi-cat --script res://scripts/dev/home_v2_batch_02_capture.gd
```

Review decisions and remaining visual caveats are in `docs/production/WILLICAT_V2_BATCH_02_HUMAN_REVIEW.md`. This folder has `.gdignore` and is not a runtime asset package.
