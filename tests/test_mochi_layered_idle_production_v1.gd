extends SceneTree
## Runtime-only stand-ins exercise transforms; no generated or saved art is used.

const PREVIEW: PackedScene = preload("res://scenes/dev/mochi_animation_preview.tscn")
const REFERENCE: Texture2D = preload("res://docs/references/mochi/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT.png")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var preview := PREVIEW.instantiate() as MochiAnimationPreview
	root.add_child(preview)
	await process_frame
	if not _check_preview_controls(preview):
		quit(1)
		return
	if not await _check_temp_fallback_and_root(preview):
		quit(1)
		return
	if not await _check_layered_motion_and_routing(preview):
		quit(1)
		return
	preview.queue_free()
	await process_frame
	print("--- ALL MOCHI LAYERED IDLE PRODUCTION V1 CHECKS PASSED ---")
	quit(0)


func _check_temp_fallback_and_root(preview: MochiAnimationPreview) -> bool:
	var presenter: MochiVisualPresenter = preview.presenter
	var layered: MochiLayeredIdleVisual = presenter.layered_idle
	var actor: Node2D = preview.actor
	var body: Sprite2D = layered.body_base
	var shadow: Node2D = actor.get_node("ContactShadow")
	if not _check(presenter.requested_action == &"idle" and presenter.resolved_source == &"LAYERED_TEMP" \
		and presenter.presentation_mode == &"LAYERED_IDLE" and layered.is_idle_active \
		and body.texture == REFERENCE and body.visible and not presenter.animated_sprite.visible,
		"idle must resolve to the layered presenter with exact canonical TEMP fallback"):
		return false
	if not _check(not layered.production_layers_complete and layered.tail_sprite.texture == null \
		and layered.ear_sprite.texture == null and layered.eyes_open.texture == null \
		and layered.current_eye_state == &"OPEN" and not layered.tail_pivot.visible,
		"Absent production layers must remain empty and must not invent replacement artwork"):
		return false
	var root_before: Vector2 = actor.global_position
	var shadow_before: Vector2 = shadow.global_position
	var floor_before: float = _body_floor_world(body)
	for _frame in range(22):
		await create_timer(0.02).timeout
		var body_scale: float = layered.body_motion.scale.y
		if not _is_finite(body_scale):
			return _check(false, "Breathing transform must stay finite")
	if not _check(actor.global_position == root_before and shadow.global_position == shadow_before \
		and is_equal_approx(_body_floor_world(body), floor_before),
		"Breathing must preserve gameplay root, floor contact, and independent contact shadow"):
		return false
	if not _check(absf(layered.body_motion.scale.y - 1.0) > 0.0001,
		"The canonical fallback should show only subtle in-place breathing"):
		return false
	print("[PASS] Semantic idle route, missing-art fallback, empty future layers, breathing, feet and shadow stability")
	return true


func _check_preview_controls(preview: MochiAnimationPreview) -> bool:
	preview._unhandled_input(_key(KEY_2))
	if not _check(preview.presenter.requested_action == &"ambient_idle", "Key 2 must select ambient_idle"):
		return false
	preview._unhandled_input(_key(KEY_1))
	if not _check(preview.presenter.requested_action == &"idle", "Key 1 must select idle"):
		return false
	preview._unhandled_input(_key(KEY_SPACE))
	if not _check(preview.presenter.is_paused and preview.presenter.layered_idle.is_paused, "Space must pause layered idle"):
		return false
	preview._unhandled_input(_key(KEY_SPACE))
	if not _check(not preview.presenter.is_paused, "Space must resume layered idle"):
		return false
	preview._unhandled_input(_key(KEY_R))
	var timing_after_restart: Dictionary = preview.presenter.layered_idle.timing_snapshot()
	preview._unhandled_input(_key(KEY_R))
	if not _check(preview.presenter.layered_idle.timing_snapshot() == timing_after_restart, "R must restart the deterministic idle sequence"):
		return false
	preview._unhandled_input(_key(KEY_G))
	if not _check(not preview.show_guides, "G must hide preview guides"):
		return false
	preview._unhandled_input(_key(KEY_G))
	if not _check(preview.show_guides, "G must restore preview guides"):
		return false
	return true


func _check_layered_motion_and_routing(preview: MochiAnimationPreview) -> bool:
	var presenter: MochiVisualPresenter = preview.presenter
	var layered: MochiLayeredIdleVisual = presenter.layered_idle
	var actor: Node2D = preview.actor
	var anchor_before: Vector2 = preview.carry_anchor.global_position
	var config := layered.config.duplicate(true) as MochiLayeredIdleConfig
	var test_texture: ImageTexture = _make_in_memory_test_texture()
	config.body_base_texture = test_texture
	config.tail_texture = test_texture
	config.ear_twitch_texture = test_texture
	config.eyes_open_texture = test_texture
	config.eyes_half_texture = test_texture
	config.eyes_closed_texture = test_texture
	config.body_base_offset = Vector2(-1.5, -3.0)
	config.breathing_amount = 0.01
	config.breathing_period = 0.42
	config.blink_interval_min = 100.0
	config.blink_interval_max = 100.0
	config.blink_half_duration = 0.025
	config.blink_closed_duration = 0.025
	config.tail_interval_min = 100.0
	config.tail_interval_max = 100.0
	config.tail_motion_duration = 0.025
	config.tail_return_duration = 0.035
	config.ear_interval_min = 100.0
	config.ear_interval_max = 100.0
	config.ear_twitch_duration = 0.025
	config.ear_return_duration = 0.035
	layered.install_config(config)
	presenter.play_action(&"idle")
	if not _check(layered.production_layers_complete and presenter.resolved_source == &"LAYERED_FINAL" \
		and layered.eyes_open.visible and not layered.eyes_half.visible and not layered.eyes_closed.visible,
		"A complete production layer set must be presented as layered-final with OPEN eyes"):
		return false

	layered.restart()
	var timing_a: Dictionary = layered.timing_snapshot()
	layered.restart()
	var timing_b: Dictionary = layered.timing_snapshot()
	if not _check(timing_a == timing_b, "A fixed RNG seed must replay initial idle timing deterministically"):
		return false

	for action in [&"walk", &"prepare_coffee", &"carry_coffee", &"serve"]:
		if not _install_action_clip(presenter, action):
			return false
		presenter.play_action(action)
		if not _check(presenter.presentation_mode == &"ACTION_ANIMATION" \
			and presenter.resolved_source == &"FINAL" and presenter.animated_sprite.visible \
			and not layered.visible and not layered.is_idle_active,
			"%s must continue using the existing ActionAnimatedSprite pipeline" % String(action)):
			return false
		if not _check((preview.carry_anchor as Marker2D).global_position.is_equal_approx(anchor_before),
			"CarryAnchor must remain stable across visual mode changes"):
			return false
		presenter.play_action(&"idle")
		if not _check(presenter.presentation_mode == &"LAYERED_IDLE" and layered.is_idle_active \
			and layered.current_eye_state == &"OPEN" and is_equal_approx(layered.body_motion.scale.y, 1.0),
			"Action → idle must restore open eyes and baseline breathing"):
			return false

	layered._tail_wait = 0.0
	layered._process(0.016)
	if not _check(layered._tail_tween != null and layered._tail_tween.is_running(), "Tail should use an event-like eased tween"):
		return false
	await create_timer(0.12).timeout
	if not _check(is_equal_approx(layered.tail_pivot.rotation, layered._tail_neutral_rotation),
		"Tail motion must restore exactly to its canonical neutral rotation"):
		return false
	layered._ear_wait = 0.0
	layered._process(0.016)
	if not _check(layered._ear_tween != null and layered._ear_tween.is_running(), "Ear twitch should use a short eased tween"):
		return false
	await create_timer(0.12).timeout
	if not _check(is_equal_approx(layered.ear_pivot.rotation, layered._ear_neutral_rotation),
		"Ear twitch must restore exactly to its neutral rotation"):
		return false

	layered._blink_wait = 0.0
	layered._process(0.001)
	var blink_states: Array[StringName] = [layered.current_eye_state]
	for expected in [&"CLOSED", &"HALF", &"OPEN"]:
		layered._blink_remaining = 0.0
		layered._process(0.001)
		blink_states.append(layered.current_eye_state)
	if not _check(blink_states == [&"HALF", &"CLOSED", &"HALF", &"OPEN"],
		"Blink must follow OPEN → HALF → CLOSED → HALF → OPEN"):
		return false

	layered._tail_wait = 0.0
	layered._ear_wait = 0.0
	layered._blink_wait = 0.0
	layered._process(0.001)
	presenter.play_action(&"walk")
	if not _check(not layered.is_idle_active and layered._tail_tween == null and layered._ear_tween == null \
		and layered.current_eye_state == &"OPEN" and is_equal_approx(layered.body_motion.scale.y, 1.0),
		"Idle → action must cancel tweens/timers and reset all layers immediately"):
		return false
	presenter.play_action(&"ambient_idle")
	if not _check(layered.current_action == &"ambient_idle" and layered.is_idle_active \
		and presenter.resolved_source == &"LAYERED_FINAL",
		"ambient_idle must reuse the same layered visual system with its timing profile"):
		return false
	print("[PASS] Hybrid semantic routing, seeded timing, blink sequence, tail/ear neutral return, interruption and recovery")
	return true


func _install_action_clip(presenter: MochiVisualPresenter, action: StringName) -> bool:
	var animation_set := presenter.animation_set.duplicate(true) as MochiAnimationSet
	if animation_set.final_frames == null:
		animation_set.final_frames = SpriteFrames.new()
	if not animation_set.final_frames.has_animation(action):
		animation_set.final_frames.add_animation(action)
	animation_set.final_frames.add_frame(action, REFERENCE)
	animation_set.final_frames.set_animation_loop(action, action != &"serve")
	presenter.install_animation_set(animation_set)
	return true


func _make_in_memory_test_texture() -> ImageTexture:
	var image: Image = Image.create(3, 3, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.6, 0.3, 1.0))
	return ImageTexture.create_from_image(image)


func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	return event


func _body_floor_world(body: Sprite2D) -> float:
	var used: Rect2i = body.texture.get_image().get_used_rect()
	var local_foot: Vector2 = body.offset + Vector2(0.0, float(used.end.y))
	return body.to_global(local_foot).y


func _is_finite(value: float) -> bool:
	return not is_nan(value) and not is_inf(value)


func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("[FAIL] " + message)
		return false
	return true
