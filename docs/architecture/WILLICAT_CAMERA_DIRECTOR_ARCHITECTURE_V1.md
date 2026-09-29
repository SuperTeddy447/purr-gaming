# CameraDirector architecture V1

Status: dev lab reference; production CameraRig not modified.

Room owns a `Camera2D`, its pan/zoom input adapter and a local CameraDirector. Objects/actors own `Marker2D` focus anchors. `HardeningCameraShot` is a typed Resource containing zoom, in/out times, easing, hold, follow, input lock, HUD policy and priority. Generic actor AI does not move the camera; an action signal may request a named shot at its owning object's marker.

The director has GAMEPLAY, FOCUS_SHOT, STORY, EVENT and DEBUG ownership modes. On the first temporary request it snapshots camera global position/zoom/offset, input enabled and HUD visible. It accepts higher-priority replacement only, kills the old Tween, uses a serial token so stale async completions cannot restore over the new shot, and optionally follows a moving marker during hold. Completion, cancellation, removed target or scene exit restores the exact saved state. The existing camera limits are never changed. Gameplay gestures are disabled during locked shots and work again afterward.

CoffeeAction signals start a Brew close-up at EspressoStation/CameraBrewFocus with steam placeholder; action completion requests Cup Reveal at EspressoStation/CameraCupReveal and then restores. SeasonalDisplay/CameraEventFocus and actor/CameraEmotionFocus prove the same API is reusable. Moving Espresso or the actor moves those markers automatically. World-space visual FX stays with the object; the HUD lives in CanvasLayer. The lab keeps HUD visible in normal focus; future STORY shots may hide it, restoring its *previous* state rather than always showing it.

Rule: use Tween for data-driven pan/zoom; use AnimationPlayer/AnimationMixer when a human-authored multitrack story beat coordinates camera, FX, sound and object state. Do not bake per-map focus pixels into actor scripts. Before Home migration, adapt to the existing CameraRig ownership/limits and run device-safe-area QA without changing the approved camera family.
