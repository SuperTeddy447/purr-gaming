# Home V3 real-art lighting proof — micro-room revision V1

This is a development-only, 540×960 real Godot 4.7.2 viewport capture pack. The 16 PNGs were rendered with Metal/Mobile on an Apple M2 Pro from [the isolated revision scene](../../../scenes/dev/home_v3_real_art_lighting_proof_revision_v1.tscn). The original V1 scene and screenshots remain separate. No generated or retouched art was used; the neutral background and window-only exterior are runtime placeholders outside/behind the approved assets. See [revision result](../../../docs/production/WILLICAT_HOME_V3_REAL_ART_LIGHTING_PROOF_REVISION_RESULT_V1.md).

| PNG | Inspection |
| --- | --- |
| [01_neutral.png](01_neutral.png) | Coherent five-asset micro-room; natural base lighting |
| [02_day_clear.png](02_day_clear.png) | Day/clear and material response |
| [03_sunset_clear.png](03_sunset_clear.png) | Sunset warmth; no new room image |
| [04_night_lamp_off.png](04_night_lamp_off.png) | Same room at night, lamp OFF |
| [05_night_lamp_on.png](05_night_lamp_on.png) | Same night, runtime lamp ON; real plaster/wood/jade/cat response |
| [05b_night_lamp_dimmed.png](05b_night_lamp_dimmed.png) | Same night, runtime lamp DIMMED |
| [06_rainy_afternoon.png](06_rainy_afternoon.png) | Rainy afternoon and window treatment |
| [07_rainy_night_lamp_on.png](07_rainy_night_lamp_on.png) | Rainy night, lamp ON |
| [08_character_close.png](08_character_close.png) | Amber eyes, cream muzzle, ears, paws and tail under rainy-night light |
| [09a_window_day.png](09a_window_day.png) | Embedded frame and separate exterior, DAY |
| [09b_window_night.png](09b_window_night.png) | Same frame, NIGHT |
| [09c_window_sunset.png](09c_window_sunset.png) | Same frame, SUNSET |
| [09d_window_clear.png](09d_window_clear.png) | Afternoon CLEAR control for rain comparison |
| [09e_window_rain.png](09e_window_rain.png) | Same afternoon, RAIN behind unchanged frame |
| [10a_chair_shadow_before.png](10a_chair_shadow_before.png) | Grounded chair before temporary move |
| [10b_chair_shadow_moved.png](10b_chair_shadow_moved.png) | Chair +52 world px; owner-local shadow follows, old location clears |

Regenerate in a rendered Godot window:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/teddywoot/willi-cat --scene res://scenes/dev/home_v3_real_art_lighting_proof_revision_v1.tscn -- --capture-real-art-proof
```

The F6 capture guard still refuses incomplete/incorrect-canvas/opaque-perimeter samples. The folder's `.gdignore` keeps evidence PNGs out of Godot runtime imports. This micro-room is not the locked Home V3 level and does not authorize moving its objects or navigation.
