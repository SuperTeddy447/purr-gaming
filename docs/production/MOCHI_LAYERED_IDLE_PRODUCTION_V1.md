# Mochi Layered Idle Production V1

Status: **Layered idle runtime READY; production layer artwork REQUIRED.** This document is the handoff contract for producing the six transparent layer PNGs. The canonical House Style Lock image remains unchanged and is the visible runtime fallback until the complete set is installed.

## Purpose and boundaries

`idle` and `ambient_idle` use a small layered procedural presentation. `walk`, `prepare_coffee`, `carry_coffee`, `serve`, and `return_idle` continue through the existing `SpriteFrames` action pipeline. Both are selected through `MochiVisualPresenter.play_action(action_id)`. Neither presenter owns worker state, movement, coffee timing, rewards, or customer logic.

This pass creates no character art, animation frames, café art, gameplay behavior, or screenshots. The Home root, feet contact, DepthSortedLayer/Y-sort ownership, interaction ownership, CarryAnchor, and contact shadow remain in their existing world locations.

## Runtime hierarchy and layer order

```text
MochiScaleTestDEV (existing gameplay / floor-contact root)
├── ContactShadow                         floor anchored; independent of visual motion
└── MochiAnimationSlot (MochiVisualPresenter)
    ├── LayeredIdleVisual                 visible only for idle/ambient_idle/static fallback
    │   ├── BodyMotion                    tiny breathing transform around feet origin
    │   │   ├── BodyBase                  canonical TEMP fallback or final body layer
    │   │   └── FaceLayers
    │   │       ├── EyesOpen
    │   │       ├── EyesHalf
    │   │       └── EyesClosed
    │   ├── TailPivot (z -1)               Tail child sprite; base pivot
    │   └── EarPivot (z +1)                one selected asymmetric ear; base pivot
    └── ActionAnimatedSprite               visible only for action SpriteFrames
├── CarryAnchor                            unchanged actor-local attachment
├── FXAnchors                               unchanged future FX attachment points
└── SliceMover / SliceWorker                existing gameplay authority
```

`BodyBase` is the identity/registration anchor. Tail draws behind the body; eye patches draw over the body; EarTwitch currently draws over the body and must be reviewed against the chosen ear cutout before art acceptance. `ContactShadow` stays a separate actor child behind the presentation node: it does not breathe, blink, twitch, or rotate.

## Required production PNGs

All paths are under `assets/characters/mochi/runtime/layered_idle/`:

| File | Contents |
| --- | --- |
| `mochi_body_base_v1.png` | Canonical body, clothing, face/muzzle, and feet with the moving tail/ear and eye patch regions prepared for compositing |
| `mochi_tail_v1.png` | Canonical striped S-curve tail as one separate piece |
| `mochi_ear_twitch_v1.png` | One approved, asymmetric ear as a separate piece; never mirrored automatically |
| `mochi_eyes_open_v1.png` | Open eye patch state |
| `mochi_eyes_half_v1.png` | Half-lidded eye patch state |
| `mochi_eyes_closed_v1.png` | Closed eye patch state |

No final layer art is installed yet. The currently empty Sprite2D slots are not replacement art. The config marks the art `FINAL` only when all six textures are assigned; if any is missing, every partial layer is hidden and the untouched canonical reference is shown instead.

## Identity, body, and cleanup requirements

Preserve the locked orange tabby, cream muzzle/lower face, warm brown almond eyes, forehead M, asymmetric ears, jade Art Deco apron, cream shirt, rust scarf, striped S-tail, compact proportions, and matte storybook finish. Preserve canonical standing height of approximately **145–150 visible px** at the default Home framing.

`BodyBase` must retain the canonical feet silhouette and floor alignment. Remove the moving tail and selected twitching ear cleanly, reconstructing all newly exposed body regions without scars. Remove only the eye-state patch area needed for replacement; the forehead M, cheeks, muzzle, whiskers, and all non-eye identity marks must remain unchanged. Do not bake a floor shadow into the body.

Tail cutout must remain visually identical to the canonical tail, include enough hidden base overlap for a small pivot rotation, and preserve the full S curve without clipping. Ear cutout must preserve the exact selected ear's asymmetric shape and include sufficient base overlap to avoid seams during a tiny twitch. Do not mirror it.

Eye states must align perfectly. Only eyelid/eye-region pixels may differ: no pupil/iris drift, no face morph, no M-marking change, and no muzzle change.

## Authoring canvas, pivots, and runtime registration

Preferred authoring method: prepare the six layers on one shared canvas matching the canonical reference dimensions, with every layer registered to the same foot-origin coordinate convention. Keep a layered source file for review. For delivery, layers may be tightly cropped to save texture memory, but retain the crop rectangle (x, y, width, height) relative to the shared canvas.

Runtime uses **Mochi's floor-contact origin** as local `(0, 0)`. In `MochiLayeredIdleConfig`, each Sprite2D is top-left anchored (`centered = false`) and its `offset` places its source's top-left relative to that foot origin. For a cropped source:

`runtime_offset = shared_canvas_top_left_from_feet + crop_origin`

The root uniform scale is calibrated from the canonical full-character reference height, not from a cropped layer's own alpha bounds. All layer offsets and pivots are in source design pixels and inherit that scale.

- **BodyBase:** feet/ground point unchanged from the canonical reference. `body_base_offset` is the cropped source's top-left relative to floor origin.
- **Tail:** `tail_pivot_position` marks the anatomical attachment point in floor-origin coordinates. The Tail sprite's `tail_sprite_offset` is its top-left relative to that pivot. Never rotate around the crop center.
- **Ear:** `ear_pivot_position` marks the base of the selected ear. `ear_sprite_offset` is relative to that pivot. Record which ear was selected in the layered source and review z-order/seam before acceptance.
- **Eyes:** all three image crops have identical registration. `eyes_patch_position` and `eyes_sprite_offset` register their top-left relative to the shared body coordinate frame; all three states must use the exact same values.

The config's current tail/ear pivot positions are **TEMP guide estimates only** (`(-44, -205)` and `(12, -410)` design px respectively). They are not approved art pivots. Recompute them from the shared-canvas source after the artist selects and separates the moving pieces. Leave the canonical image's original tail/ears untouched.

## Alpha and Godot import expectations

Deliver RGBA transparent PNGs with clean matte alpha edges, no white fringe, no premultiplied-looking halo, no baked background, and no baked floor shadow. Keep the native authored resolution initially; do not apply aggressive compression/atlas optimization before real assets are reviewed.

Import as ordinary `Texture2D` resources. Assign the six textures and registration offsets in `data/mochi_layered_idle_config.tres`. Texture filtering/mipmap changes require on-device review at the 145–150 px gameplay size; do not silently change project-wide import defaults for this pass.

## Timing and motion philosophy

The runtime values are centralized in `data/mochi_layered_idle_config.tres`:

| Property | Current value | Intent |
| --- | ---: | --- |
| Breathing amount / period | `0.002` / `4.8 s` | Nearly imperceptible vertical scale around the foot origin |
| Blink interval | `3.2–6.4 s` | Randomized single blink; HALF → CLOSED → HALF → OPEN |
| Blink half / closed duration | `0.075 s` / `0.08 s` | Quick eyelid sequence |
| Tail interval | `6–11 s` | Occasional eased event, then meaningful stillness |
| Tail move / return | `0.42 s` / `0.58 s` | Small single-digit angle, exact neutral return |
| Ear interval | `10–19 s` | Rare short twitch, independent of tail/blink timers |
| Ear twitch / return | `0.12 s` / `0.24 s` | Tiny angle and exact neutral return |
| Ambient activity multiplier | `1.4` | Slightly shorter event intervals for `ambient_idle` only |
| RNG seed | `734021` | Repeatable preview/test sequence |

The intent is **alive, not constantly moving**. Breathing is subtle and ongoing. Blink, tail, and ear use separate randomized timers; tail is not a pendulum. No personality rules or animation-driven gameplay events are added. Production can later supply a runtime seed policy without changing semantic actions.

## Fallback, transitions, and action compatibility

With missing/incomplete PNGs, `idle` and `ambient_idle` show the exact canonical reference as TEMP `BodyBase`; only imperceptible in-place breathing runs. Tail/ear/eye slots remain empty and inactive. The preview/status line reports `TEMP / FALLBACK` and missing components. Missing art cannot hide Mochi or block gameplay.

Once all six textures are assigned, the config selects `LAYERED_FINAL`; only then do blink/tail/ear motion activate. For `walk`, `prepare_coffee`, `carry_coffee`, `serve`, and `return_idle`, the presenter immediately kills active tweens, stops procedural timers, resets eye/tail/ear/body transforms, and shows the existing `ActionAnimatedSprite` resolution/fallback. Returning to either idle action restores OPEN eyes, neutral transforms, baseline breathing, and a newly seeded timing sequence. Root and shadow never move.

Semantic callers remain unchanged: `play_action("idle")`, `play_action("ambient_idle")`, etc. Direction handling for layered idle always keeps the canonical Home-facing orientation; it never flips asymmetric artwork. Existing directional SpriteFrames resolution for work actions is unchanged.

## Preview and art testing

Open `scenes/dev/mochi_animation_preview.tscn` for 20–30 seconds or longer. Keys: **1** idle, **2** ambient_idle, **3** walk, **4** prepare_coffee, **5** carry_coffee, **6** serve, **7** return_idle; **Space** pause/resume; **R** restart the deterministic idle sequence/action; **G** show/hide guides; W/A/S/D still choose action-facing direction. Guides show the foot/root, 150 px height ruler, CarryAnchor, estimated TEMP tail/ear pivots, eye state, semantic action, and TEMP/FINAL status.

When the PNG set is installed, verify the whole idle at native gameplay size, pause/restart, idle↔action interruption, each pivot return, and overlay registration. Compare each crop to the shared canvas before importing, then use G guides and check face, feet, and pivot registration. Pivot guide marks remain estimates until replaced by measured config values.

## Replacement, memory rationale, and acceptance

Replacing TEMP with FINAL requires assigning the six Texture2D resources and approved crop offsets/pivots in the config, then reviewing the existing preview and running layered-idle, production-pipeline, Living Café, and True Slice tests. No gameplay or semantic bridge changes are needed. If any slot is unassigned, the full canonical fallback remains active.

A subtle idle should not need 25–60 full-resolution whole-character frames. A handful of small textures plus local transforms and eye-state visibility reduces texture memory and avoids generative face/tail/ear registration drift. Optimize only after real art exists and device measurements are available.

### Artist acceptance checklist

- [ ] Canonical identity, clothing, markings, asymmetry, and matte finish are preserved.
- [ ] BodyBase has clean reconstructed holes; no tail/ear-removal scar; feet unchanged.
- [ ] Tail matches the canonical S-curve, has a clean attachment, overlap for small rotation, and no clipping.
- [ ] Selected ear matches canonical shape, has base overlap, no twitch seam, and is not mirrored.
- [ ] OPEN/HALF/CLOSED eye crops align exactly; M, muzzle, cheeks, and non-eye details do not change.
- [ ] All six layers share the measured authoring/reference coordinate convention and documented crops.
- [ ] Alpha is clean; no fringe, background, shadow, or baked environment.
- [ ] At gameplay scale: no foot slide, face/clothing/tail morph, visible seam, clipped silhouette, or mechanical repetition.
- [ ] Shadow remains floor anchored and the CarryAnchor remains stable through action/idle switches.
- [ ] Preview, Living Café interruption, and True Vertical Slice regression tests pass.
