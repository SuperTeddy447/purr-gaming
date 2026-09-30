# Phantom Camera evaluation V1

Verdict: **STUDY ONLY**. Do not install now.

[Phantom Camera's maintainer README](https://github.com/ramokz/phantom-camera) describes priority-based cameras, 2D/3D follow modes, smoothing/tweening, zoom, viewfinder/editor preview and target framing. These are relevant authoring ideas, but the README alone does not prove compatibility with Godot 4.7.2 or WilliCat's gesture/room lifecycle. No plugin was installed or run for this research.

## Comparison to current playable world

| Need | Already in WilliCat | Phantom opportunity / gap |
|---|---|---|
| Priority shots | `scripts/dev/world_hardening/camera_director.gd`: `request_shot`, priority rejection, timed hold/restore, target-removal and scene-exit cleanup | Similar selection abstraction; an install would overlap this ownership. |
| Zoom/pan/bounds | `scripts/dev/playable_placeholder/placeholder_camera_input.gd`: overview/default/focus presets, wheel/pinch, drag pan, effective minimum zoom, room clamp | Existing touch behavior is proved for the two-room prototype. A plugin must preserve this input contract. |
| Focus and transitions | Director tweens position/zoom and saves/restores gameplay camera/HUD/input | Phantom could offer richer editor-authored rigs; current feature is sufficient for next asset replacement. |
| Multiple rooms | `main_cafe.tscn` and `back_garden.tscn` each own Camera2D, input adapter and director | Future reusable room profiles may benefit from a data resource/editor viewfinder, independent of plugin adoption. |
| Viewfinder/editor authoring | No equivalent production authoring proof was found in the placeholder scenes | Worth borrowing the *pattern* of visible camera frame guides in a later tooling experiment. |

Current director is not a comprehensive camera framework, but installing Phantom to solve already-working pan/zoom/focus would add dependency and migration risk. **Potential later decision:** if several rooms require complex concurrent framing, run a separate isolated A/B proof measuring gesture parity, bounds, target cleanup, scene transitions, maintenance cost and mobile behavior. Only then consider INSTALL, with explicit removal or adaptation of `HardeningCameraDirector` and `PlaceholderCameraInput` responsibilities; two simultaneous camera owners would be unacceptable. For this asset-first pass, camera code and scene cameras remain unchanged.
