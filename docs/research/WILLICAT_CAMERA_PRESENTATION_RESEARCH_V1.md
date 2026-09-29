# Camera presentation research V1

Status: isolated architecture lab; not a redesign of the production Home camera.

| Topic | Official Godot behavior | WilliCat decision |
| --- | --- | --- |
| [Camera2D](https://docs.godotengine.org/en/4.7/classes/class_camera2d.html) | Position, zoom, offset, limits and smoothing affect the rendered view. A camera offset can push the view past limits, so it is not a safe general-purpose focus fix. | Preserve the room camera and its limits. Director snapshots global position, zoom and offset before temporary ownership, then restores them exactly. Shot targets are object-owned Marker2D nodes. |
| [Tween](https://docs.godotengine.org/en/4.7/classes/class_tween.html) | Tweens interpolate properties over time and are appropriate for short dynamic transitions. Kill an interrupted tween so competing writers do not fight. | Use Tween for runtime pan/zoom and brief hold/restore. A serial token suppresses stale async completions after replacement/cancel. |
| [AnimationPlayer](https://docs.godotengine.org/en/4.7/classes/class_animationplayer.html) and [AnimationMixer](https://docs.godotengine.org/en/4.7/classes/class_animationmixer.html) | Authored tracks coordinate multiple animated properties; AnimationPlayer is built on AnimationMixer. | Use later for scripted multi-track story beats/FX/sound/object timing. It is unnecessary for a single semantic focus interpolation. CameraDirector should own the camera even if a future authored sequence supplies its shot cues. |
| [CanvasLayer](https://docs.godotengine.org/en/4.7/classes/class_canvaslayer.html) | HUD in a CanvasLayer is rendered in screen space rather than moving/scaling with the 2D world camera. | Existing HUD remains screen-space. A shot may hide it by policy but must restore the previous visible state; debug UI is a separate policy. |
| [Marker2D](https://docs.godotengine.org/en/4.7/classes/class_marker2d.html), child transforms, signals | A marker inherits its parent transform and can signal removal through the node tree. | Espresso owns Brew/Cup anchors; SeasonalDisplay owns Event focus; actors can own emotion focus. A freed target cancels the shot. |

## Lab findings

`HardeningCameraDirector` is independent of actor navigation. Worker action signals ask it for Brew Close-up then Cup Reveal, using `HardeningCameraShot` Resources. The director locks gameplay pan/zoom during focus, accepts only higher-priority replacement shots, follows a moving marker during hold, restores input/HUD/position/zoom, and cancels on target removal or scene exit. The test begins from a nondefault camera state and compares exact restored values. It also moves an actor with its emotion focus anchor during a holding shot.

The 9:16 evidence is a 539×959 embedded game viewport. A second real Godot `SubViewport` renders the same lab at 539×1168 for tall-phone QA; merely resizing the embedded editor window did **not** change its viewport, so that attempt was rejected. These images prove placeholder framing only. Final illustrated art and actual device safe areas require a later human/mobile pass.

## Production rule

Tween = dynamic one-target camera interpolation. AnimationPlayer/AnimationMixer = explicitly authored multi-track event/story sequence. Do not keyframe map pixel coordinates inside generic character logic. An object-scene Marker2D supplies composition; a typed CameraShot Resource supplies transition policy. The room/camera layer owns device clamps; actors request semantics, not shot coordinates.
