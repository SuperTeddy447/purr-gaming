# Home V3 real-art lighting proof V1 — rendered evidence

Status: **technical capture complete; visual production gate FAIL**. These are unretouched 540×960 PNGs from the real Godot 4.7.2 Metal/Mobile viewport. The five exact-canvas candidate PNGs passed the existing F6 alpha/canvas guard. This is the isolated development lab, **not production Home**. See [result and limitations](../../../docs/production/WILLICAT_HOME_V3_REAL_ART_LIGHTING_PROOF_RESULT_V1.md).

| PNG | State / inspection |
| --- | --- |
| [01_neutral.png](01_neutral.png) | Neutral base; overall slot registration |
| [02_day_clear.png](02_day_clear.png) | Midday clear; material and character readability |
| [03_sunset_clear.png](03_sunset_clear.png) | Sunset clear; warm atmospheric response |
| [04_night_lamp_off.png](04_night_lamp_off.png) | Night clear; fixture OFF |
| [05_night_lamp_on.png](05_night_lamp_on.png) | Same night; runtime lamp ON |
| [06_rainy_afternoon.png](06_rainy_afternoon.png) | Afternoon rain; world/window response |
| [07_rainy_night_lamp_on.png](07_rainy_night_lamp_on.png) | Rainy night; fixture ON |
| [08_character_close.png](08_character_close.png) | Orange protagonist close review at rainy night |
| [09a_window_day.png](09a_window_day.png) | Window close; midday clear |
| [09b_window_night.png](09b_window_night.png) | Same frame; night clear |
| [09c_window_sunset.png](09c_window_sunset.png) | Same frame; sunset clear |
| [09d_window_clear.png](09d_window_clear.png) | Window close; afternoon clear |
| [09e_window_rain.png](09e_window_rain.png) | Same time; afternoon rain |
| [10a_chair_shadow_before.png](10a_chair_shadow_before.png) | Chair and owner-local shadow before move |
| [10b_chair_shadow_moved.png](10b_chair_shadow_moved.png) | Chair moved +52 world px; shadow followed; root restored |

Regenerate with a rendered Godot window:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/teddywoot/willi-cat --scene res://scenes/dev/home_v3_real_art_lighting_proof_v1.tscn -- --capture-real-art-proof
```

The old prep README described 12 planned captures; the implemented comparison now saves 15. PNGs remain development artifacts protected by this folder's `.gdignore`.
