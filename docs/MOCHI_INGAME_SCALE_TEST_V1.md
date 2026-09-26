# Mochi in-game scale test V1

Run HomeScene with F5. One DEV-only Mochi `Sprite2D` is placed at the open-floor marker in `DepthSortedLayer`; the existing café loop continues as configured.

Turn on the debug view with F1 or D, then use:

- `1`, `2`, `3`: SMALL (100 px), TARGET (132 px), LARGE (150 px)
- `F2`–`F5`: WorkerIdle, CoffeeAction, ServePoint, open floor
- `Z`, `X`, `C`, `V`: default, effective minimum, 1.2x, maximum camera zoom

The mode heights measure only nontransparent Mochi pixels at the current device/window stretch and default camera framing. They are test samples; none is selected as the final production scale. The Sprite2D keeps uniform scaling and anchors its visible alpha bounds to the foot-contact origin. At CoffeeAction, Mochi stays in `DepthSortedLayer` so the existing foreground counter covers it.

The canonical transparent image currently lives at `docs/references/mochi/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT.png`. The scene references that file directly and does not alter it. Delete `scenes/dev/mochi_scale_test.tscn`, `scripts/dev/mochi_scale_test.gd`, its HomeScene instance, and its DebugOverlay field to remove this test later.
