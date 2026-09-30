# WilliCat Main Café production assembly lock V1 — result

Status: **ready for human visual review**. This is the existing playable Main Café, assembled with project-owned A01–A10 art and the existing Home V2 POS/grinder visuals. No environment image was made or regenerated. The Back Garden scene and the world, save, slot, navigation, character, and CameraDirector implementations were not edited for this pass.

## Scale authority and final asset calibration

The runtime cat is the perceptual scale reference. Gameplay object roots, physical footprints, and InteractionSlot anchors define world space. The art is presentation under those roots; no placement was inferred from a PNG or from A01 plank edges. Alpha-visible source bounds were measured at alpha ≥ 128; displayed bounds below are approximate world-space rectangles before rotation, derived from those bounds and the final Sprite2D scale. The final rendered 540×960 views were visually inspected.

| Asset / use | Alpha-visible source bbox `(l,t,r,b)` px | Footprint world | Displayed visible world | Visual scale | Visual offset from object root | Visible contact / baseline |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| A03 counter | `(48,159,1489,944)` | 224×55 | 403.5×180.6 | `(0.28,0.23)` | `(130,-30)` | `y≈254`, at wall/floor edge |
| A04 pastry case | `(81,14,1238,1190)` | 88×32 | 115.7×117.6 | `(0.10,0.10)` | `(0,-95)` | `y≈259`, at bar end |
| A05 espresso | `(17,6,1303,1194)` | 73×45 | 109.3×101.0 | `(0.085,0.085)` | `(0,-60)` | `y≈173`, behind bar top |
| A06 tables, 2 instances | `(148,90,1132,1114)` | 108×80 each | 108.2×112.6 | `(0.11,0.11)` | `(0,-56)` | `y≈root−1` |
| A07 chairs, 4 instances | `(173,73,1121,1207)` | 48×28 each | 61.6×73.7 | `(0.065,0.065)` | `(0,-35)` | `y≈root+2` |
| A08 cat bed | `(128,88,1411,945)` | 88×41 | 96.2×64.3 | `(0.075,0.075)` | `(0,-32)` | `y≈root` |
| A09 scratch post | `(317,74,908,1205)` | 42×25 | 38.4×73.5 | `(0.065,0.065)` | `(0,-35)` | `y≈root+2` |
| A10 plant | `(172,97,1049,1216)` | 30×25 | 61.4×78.3 | `(0.07,0.07)` | `(0,-40)` | `y≈root−3` |

The visual silhouette can exceed a physical footprint, especially the counter and plant, without changing navigation or object placement. POS and grinder retain their existing Home V2 textures at `(0.05,0.05)` with local offset `(45,-70)` and `(0.065,0.065)` with local offset `(0,-75)` respectively. A02 wall remains at scale `(0.52,0.32)` and was moved to center `(320,105)` so its lower edge meets the counter's visible base. This changes wall presentation only.

## Composition

- **Floor:** A01 is a repeating `TextureRect`, `STRETCH_TILE` with mirrored texture repeat, scale `0.18` (roughly 226 world units per repeat), over the existing 640×1000 room. Modulate `(0.86,0.86,0.86)` quiets the plank contrast. The plank pattern has no placement or navigation role.
- **Service bar:** CounterShell remains at its authored gameplay root. Its visual is shallower and raised; the POS is legible at the left customer order end. Espresso and grinder sit together behind the bar. The pastry case visually joins the right customer end. The customer order anchor and worker serve/brew anchors were not moved. The worker's drawing offset is `(0,-20)` so the upper body stays visible above the bar while its semantic actor position is unchanged.
- **Seating:** Exactly two table groups remain: TableA with ChairA/ChairB, TableB with ChairC/ChairD. Their stable IDs, roots, seat anchors, footprints, route clearance, and save deltas are unchanged. Each chair's visible front is adjacent to its table; the central path remains open.
- **Cat corner:** CatBed, ScratchPost, and Plant form the lower-left cluster at their existing roots. The bed reads as one-cat size, with the plant a small accent and the entrance path clear.
- **Entrance:** The existing Entrance object now owns a simple double-door DEV drawing at the lower foreground. Its spawn, enter/leave slots, and exit path are unchanged. BackDoor retains the existing small door drawing.
- **Clean view:** Object IDs, footprint fills, slot markers, and actor names are gated by the existing debug settings. The clean captures disable collision hints and hide the HUD; runtime gameplay retains its controls.

## Camera and depth

The Main Café's existing portrait camera profile is preserved. At the 540×960 capture size, overview uses zoom `0.96` and center near `(320,500)`; default uses zoom about `1.018`; service focus uses zoom about `1.171`, clamped near `(335,410)`. The seating evidence uses the default profile centered near `(320,520)`. CameraDirector still owns scripted focus shots.

The live serve capture shows the worker's upper body and cup behind the counter top, with the lower body hidden by the bar. The customer remains visible at the order side. Existing chair-seat proof from the prior assembly pass shows the seated actor in front of the chair rather than swallowed by it; this pass did not move or rescale chairs. Tables and the pastry case retain their object-root Y-sort. The plant is separated from the café actors in the captured layout, so no live plant-overlap case was observed. No broad z-index override was added.

## Rendered evidence

All five PNGs are real Godot 4.7.2 Metal viewport captures at 540×960. HUD and debug overlays are off; the occlusion shot contains live customer/worker actors.

1. [Clean overview](../../artifacts/prototype_review/willicat_main_cafe_production_assembly_lock_v1/01_clean_overview.png)
2. [Default gameplay](../../artifacts/prototype_review/willicat_main_cafe_production_assembly_lock_v1/02_default_gameplay.png)
3. [Service bar](../../artifacts/prototype_review/willicat_main_cafe_production_assembly_lock_v1/03_service_bar.png)
4. [Seating groups](../../artifacts/prototype_review/willicat_main_cafe_production_assembly_lock_v1/04_seating_groups.png)
5. [Actor occlusion](../../artifacts/prototype_review/willicat_main_cafe_production_assembly_lock_v1/05_actor_occlusion.png)

Recreate them with `res://scripts/dev/playable_placeholder/main_cafe_production_assembly_lock_capture.gd` using a graphical Godot renderer; a headless dummy render is not evidence.

## Gameplay regression and limitations

`tests/test_playable_placeholder_reset_v1.gd` **passed** in Godot 4.7.2 with writable `user://` access: first customer enter → order → brew → serve → seat → exit → reward; second loop; furniture move and rejection rollback; café ↔ garden transition; cat garden action; save/load of room, furniture, cat, and reward state. The headless sandbox-only attempt could not write `user://` and was not counted as a gameplay failure. The final visual offsets change no footprints, slots, roots, or save fields.

Remaining visual defects: actors are still primitive DEV drawings; POS/grinder use older Home V2 art; the entrance is a code-drawn DEV door; A01 repeats visibly and its source was not repainted into a mathematically seamless tile. The worker/counter occlusion is suitable for this prototype but still needs final character art review. A live actor/plant overlap and a new post-lock seated-actor capture were not recorded.

## Exact change scope and Git summary

This pass changed `scenes/dev/playable_placeholder/main_cafe.tscn`, `scripts/dev/playable_placeholder/placeholder_floor.gd`, and `scripts/dev/playable_placeholder/placeholder_door_visual.gd`; it added `scripts/dev/playable_placeholder/main_cafe_production_assembly_lock_capture.gd`, the five PNGs above, and this result document. These playable-placeholder paths were already untracked before this pass, so the ordinary tracked `git diff --stat` does not include them. The nine pre-existing tracked modifications and other untracked work in the repository were preserved. No commit or push was made.
