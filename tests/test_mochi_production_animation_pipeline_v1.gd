extends SceneTree
## Tests only reuse the canonical reference texture in memory; no art files are generated.

const PREVIEW: PackedScene = preload("res://scenes/dev/mochi_animation_preview.tscn")
const HOME: PackedScene = preload("res://scenes/home/home_scene.tscn")
const REFERENCE: Texture2D = preload("res://docs/references/mochi/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT.png")
const SOURCE_PNG_PATH: String = "res://docs/source_assets/mochi/walk_side_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk.png"
const RUNTIME_WALK_FRAMES: SpriteFrames = preload("res://assets/characters/mochi/animations/walk/mochi_walk_side_right_prototype_v1.tres")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check_walk_side_asset_contract():
		quit(1)
		return
	if not _check_map_and_resolution():
		quit(1)
		return
	if not await _check_preview_and_geometry():
		quit(1)
		return
	if not await _check_home_handoff():
		quit(1)
		return
	print("--- ALL MOCHI PRODUCTION ANIMATION PIPELINE V1 CHECKS PASSED ---")
	quit(0)


func _check_walk_side_asset_contract() -> bool:
	var source := Image.new()
	var source_error: Error = source.load(ProjectSettings.globalize_path(SOURCE_PNG_PATH))
	if not _check(source_error == OK and source.get_size() == Vector2i(5120, 640) \
		and source.get_format() == Image.FORMAT_RGBA8 and source.detect_alpha(),
		"Preserved source PNG must be 5120x640 RGBA with real transparency"):
		return false
	var top_edge_frames: int = 0
	for frame_index in range(8):
		var cell: Image = source.get_region(Rect2i(frame_index * 640, 0, 640, 640))
		var bounds: Rect2i = cell.get_used_rect()
		if not _check(bounds.size.x > 0 and bounds.size.y > 0 and bounds.position.x > 0 and bounds.end.x < 640 \
			and bounds.end.y == 640,
			"Source frame %d must have clear side gutters and the shared bottom contact" % frame_index):
			return false
		if bounds.position.y == 0:
			top_edge_frames += 1
	if not _check(top_edge_frames == 4, "Source edge QA must retain the four observed ear/top edge contacts"):
		return false

	var derived := Image.new()
	var derived_error: Error = derived.load(ProjectSettings.globalize_path(
		"res://assets/characters/mochi/animations/walk/mochi_walk_side_right_prototype_v1.png"
	))
	if not _check(derived_error == OK and derived.get_size() == Vector2i(2560, 320) \
		and derived.get_format() == Image.FORMAT_RGBA8 and derived.detect_alpha(),
		"Derived runtime prototype atlas must be 2560x320 RGBA with transparency"):
		return false
	if not _check(RUNTIME_WALK_FRAMES.has_animation(&"walk_side") \
		and RUNTIME_WALK_FRAMES.get_frame_count(&"walk_side") == 8 \
		and RUNTIME_WALK_FRAMES.get_animation_loop(&"walk_side") \
		and is_equal_approx(RUNTIME_WALK_FRAMES.get_animation_speed(&"walk_side"), 8.0),
		"SpriteFrames prototype must provide 8 looping frames at 8 FPS"):
		return false
	for frame_index in range(8):
		var texture: Texture2D = RUNTIME_WALK_FRAMES.get_frame_texture(&"walk_side", frame_index)
		if not _check(texture != null and texture.get_size() == Vector2(320, 320) \
			and texture.get_image().detect_alpha(),
			"Derived SpriteFrames frame %d must be 320x320 with alpha" % frame_index):
			return false
	print("[PASS] Source PNG 5120x640 RGBA, eight 640px cells; derived atlas 2560x320; SpriteFrames 8x320 at 8 FPS looping")
	return true


func _check_map_and_resolution() -> bool:
	var set := load("res://assets/characters/mochi/runtime/mochi_animation_set.tres") as MochiAnimationSet
	if not _check(set != null and set.validate_fallback_chain() and set.ACTIONS.size() == 7,
		"Semantic map and fallback chain must cover all seven actions"):
		return false
	var integrated_right_walk: Dictionary = set.resolve(&"walk", &"RIGHT")
	if not _check(set.temp_frames == RUNTIME_WALK_FRAMES and set.final_frames == null \
		and not set.allow_side_mirror \
		and integrated_right_walk["source"] == &"TEMP" \
		and integrated_right_walk["clip"] == &"walk_side" \
		and integrated_right_walk["resolved_action"] == &"walk" \
		and not integrated_right_walk["flip_h"],
		"The shared semantic set must select the unflipped TEMP side-right walk clip"):
		return false
	for direction in [&"LEFT", &"DOWN", &"UP"]:
		var unsupported_walk: Dictionary = set.resolve(&"walk", direction)
		if not _check(unsupported_walk["source"] == &"STATIC" \
			and unsupported_walk["clip"] == &"" \
			and unsupported_walk["resolved_action"] == &"idle" \
			and not unsupported_walk["flip_h"],
			"Unsupported %s walk must keep the canonical static fallback without mirroring" % String(direction)):
			return false
	var carry_right: Dictionary = set.resolve(&"carry_coffee", &"RIGHT")
	var return_right: Dictionary = set.resolve(&"return_idle", &"RIGHT")
	var prepare_right: Dictionary = set.resolve(&"prepare_coffee", &"RIGHT")
	var serve_right: Dictionary = set.resolve(&"serve", &"RIGHT")
	if not _check(carry_right["source"] == &"TEMP" and carry_right["resolved_action"] == &"walk" \
		and return_right["source"] == &"TEMP" and return_right["resolved_action"] == &"walk" \
		and prepare_right["source"] == &"STATIC" and serve_right["source"] == &"STATIC",
		"The existing prepare/carry/serve semantic fallback chain must remain intact"):
		return false
	for action in set.ACTIONS:
		var contract: Dictionary = set.contract_for(action)
		if not _check(contract.has("loop") and contract.has("event") and contract.has("duration") \
			and contract.has("interruptible") and contract.has("asset_dir"),
			"Missing action contract for %s" % String(action)):
			return false
		if not _check(set.resolve(action, &"UP")["source"] == &"STATIC",
			"Missing action art must retain the canonical fallback"):
			return false
	var working := set.duplicate(true) as MochiAnimationSet
	# Exercise the generic resolver's optional mirror capability independently;
	# the shared asymmetric Mochi runtime set deliberately disables it.
	working.allow_side_mirror = true
	working.final_frames = SpriteFrames.new()
	working.temp_frames = SpriteFrames.new()
	for clip in [&"idle", &"walk", &"walk_side", &"walk_up"]:
		_add_reference_frame(working.final_frames, clip)
	_add_reference_frame(working.temp_frames, &"serve")
	var left: Dictionary = working.resolve(&"walk", &"LEFT")
	var right: Dictionary = working.resolve(&"walk", &"RIGHT")
	var up: Dictionary = working.resolve(&"walk", &"UP")
	var down: Dictionary = working.resolve(&"walk", &"DOWN")
	if not _check(left["clip"] == &"walk_side" and left["flip_h"] \
		and right["clip"] == &"walk_side" and not right["flip_h"] \
		and up["clip"] == &"walk_up" and down["clip"] == &"walk" \
		and down["used_fallback"], "Direction resolution and safe side mirroring are incorrect"):
		return false
	_add_reference_frame(working.final_frames, &"walk_left")
	if not _check(working.resolve(&"walk", &"LEFT")["clip"] == &"walk_left" \
		and not working.resolve(&"walk", &"LEFT")["flip_h"],
		"Dedicated left art must take priority over mirroring"):
		return false
	working.final_frames.remove_animation(&"walk_left")
	working.allow_side_mirror = false
	if not _check(working.resolve(&"walk", &"LEFT")["clip"] == &"walk" \
		and not working.resolve(&"walk", &"LEFT")["flip_h"],
		"Disabling mirror must use the unflipped generic clip"):
		return false
	if not _check(working.resolve(&"serve", &"DOWN")["source"] == &"TEMP" \
		and working.resolve(&"ambient_idle", &"DOWN")["clip"] == &"idle" \
		and working.resolve(&"return_idle", &"DOWN")["clip"] == &"walk",
		"Action fallback must use TEMP serve, idle ambience, and walk return"):
		return false
	working.temp_frames = null
	if not _check(working.resolve(&"serve", &"DOWN")["clip"] == &"idle",
		"Unavailable serve clip must fail safely through idle"):
		return false
	print("[PASS] Seven action contracts, fallback validity, missing-art STATIC, partial FINAL/TEMP, UP/DOWN/SIDE and mirroring")
	return true


func _add_reference_frame(frames: SpriteFrames, clip: StringName) -> void:
	frames.add_animation(clip)
	frames.add_frame(clip, REFERENCE)
	frames.set_animation_loop(clip, clip != &"serve")


func _check_preview_and_geometry() -> bool:
	var preview := PREVIEW.instantiate() as MochiAnimationPreview
	root.add_child(preview)
	await process_frame
	var presenter: MochiVisualPresenter = preview.presenter
	var actor: Node2D = preview.actor
	var foot_before: Vector2 = actor.global_position
	var carry_before: Vector2 = preview.carry_anchor.global_position
	var shadow_before: Vector2 = actor.get_node("ContactShadow").global_position
	var reference_height: float = float(REFERENCE.get_image().get_used_rect().size.y) * absf(preview.static_sprite.scale.y)
	if not _check(is_equal_approx(reference_height, 150.0) and presenter.resolved_source == &"LAYERED_TEMP" \
		and presenter.static_sprite.visible and not presenter.animated_sprite.visible,
		"Preview must start with 150 px layered idle using the canonical TEMP fallback"):
		return false
	var spritecook_toggle := InputEventKey.new()
	spritecook_toggle.keycode = KEY_8
	spritecook_toggle.pressed = true
	preview._unhandled_input(spritecook_toggle)
	var generated_frames: SpriteFrames = presenter.animation_set.temp_frames
	if not _check(presenter.resolved_source == &"TEMP" and presenter.resolved_clip == &"walk_side" \
		and generated_frames != null and generated_frames.get_frame_count(&"walk_side") == 8 \
		and not presenter.animation_set.allow_side_mirror \
		and presenter.animated_sprite.visible and presenter.direction == &"RIGHT" \
		and not presenter.animated_sprite.flip_h and preview.info_label.text.contains("Prototype frame 1/8 at 8 FPS"),
		"Preview-only toggle must route the right-facing prototype through TEMP without mirroring"):
		return false
	var frame_height: float = 0.0
	var frame_foot_y: float = 0.0
	var feet_registered_to_cell_bottom: bool = true
	var side_gutters_clear: bool = true
	for frame_index in range(generated_frames.get_frame_count(&"walk_side")):
		var frame_texture: Texture2D = generated_frames.get_frame_texture(&"walk_side", frame_index)
		var frame_used: Rect2i = frame_texture.get_image().get_used_rect()
		frame_height = maxf(frame_height, float(frame_used.size.y))
		frame_foot_y = maxf(frame_foot_y, float(frame_used.end.y))
		feet_registered_to_cell_bottom = feet_registered_to_cell_bottom and frame_used.end.y == 320
		side_gutters_clear = side_gutters_clear and frame_used.position.x > 0 and frame_used.end.x < 320
	if not _check(is_equal_approx(frame_height * presenter.animated_sprite.scale.y, 150.0) \
		and feet_registered_to_cell_bottom and side_gutters_clear \
		and is_equal_approx((presenter.animated_sprite.offset.y + frame_foot_y) * presenter.animated_sprite.scale.y, 0.0),
		"Walk-side preview must retain 150 px height, clear side gutters, and a common cell-bottom floor contact"):
		return false
	if not _check(actor.global_position == foot_before and preview.carry_anchor.global_position == carry_before \
		and actor.get_node("ContactShadow").global_position == shadow_before \
		and presenter.animation_set.resolve(&"walk", &"LEFT")["source"] == &"STATIC",
		"Prototype activation must preserve root/shadow/CarryAnchor and must not auto-mirror to LEFT"):
		return false
	preview._unhandled_input(spritecook_toggle)
	if not _check(presenter.resolved_source == &"LAYERED_TEMP" and presenter.static_sprite.visible \
		and not presenter.animated_sprite.visible,
		"Disabling the SpriteCook test must restore the untouched canonical preview"):
		return false
	_send_preview_key(preview, KEY_A)
	_send_preview_key(preview, KEY_3)
	if not _check(presenter.requested_action == &"walk" and presenter.direction == &"LEFT" \
		and presenter.resolved_source == &"STATIC" and not presenter.animated_sprite.visible,
		"Normal semantic preview must keep the LEFT walk on the safe static fallback"):
		return false
	_send_preview_key(preview, KEY_D)
	if not _check(presenter.direction == &"RIGHT" and presenter.resolved_source == &"TEMP" \
		and presenter.resolved_clip == &"walk_side" and presenter.animated_sprite.visible \
		and not presenter.animated_sprite.flip_h and preview.info_label.text.contains("walk RIGHT → TEMP:walk_side"),
		"Normal semantic preview 3 then D must resolve the TEMP side-right clip"):
		return false
	_send_preview_key(preview, KEY_W)
	if not _check(presenter.direction == &"UP" and presenter.resolved_source == &"STATIC" \
		and not presenter.animated_sprite.visible,
		"Normal semantic preview must not use the side-right clip for UP movement"):
		return false
	_send_preview_key(preview, KEY_S)
	if not _check(presenter.direction == &"DOWN" and presenter.resolved_source == &"STATIC" \
		and not presenter.animated_sprite.visible,
		"Normal semantic preview must not use the side-right clip for DOWN movement"):
		return false
	_send_preview_key(preview, KEY_1)
	var set := presenter.animation_set.duplicate(true) as MochiAnimationSet
	# This isolated fixture validates the resolver's optional mirror behavior;
	# the shared runtime asset set keeps mirroring disabled.
	set.allow_side_mirror = true
	set.final_frames = SpriteFrames.new()
	_add_reference_frame(set.final_frames, &"walk_side")
	_add_reference_frame(set.final_frames, &"walk_up")
	presenter.animation_set = set
	presenter.play_action(&"walk")
	presenter.set_direction(&"LEFT")
	var animated: AnimatedSprite2D = presenter.animated_sprite
	if not _check(animated.visible and not presenter.layered_idle.visible \
		and animated.animation == &"walk_side" and animated.flip_h \
		and is_equal_approx(preview.carry_anchor.position.x, -28.0) \
		and is_equal_approx(float(REFERENCE.get_image().get_used_rect().size.y) * animated.scale.y, 150.0) \
		and actor.global_position == foot_before,
		"Clip switch must keep the 150 px floor-contact pivot and mirrored CarryAnchor (visible=%s static=%s clip=%s flip=%s anchor=%s height=%.8f height_ok=%s foot_ok=%s)" % [
			animated.visible, presenter.static_sprite.visible, String(animated.animation), animated.flip_h,
			str(preview.carry_anchor.position), float(REFERENCE.get_image().get_used_rect().size.y) * animated.scale.y,
			is_equal_approx(float(REFERENCE.get_image().get_used_rect().size.y) * animated.scale.y, 150.0), actor.global_position == foot_before]):
		return false
	_add_reference_frame(set.final_frames, &"walk_left")
	presenter.install_animation_set(set)
	if not _check(animated.animation == &"walk_left" and not animated.flip_h \
		and preview.carry_anchor.position.x < 0.0 and actor.global_position == foot_before,
		"Dedicated left clip must replace mirrored side without moving the cup anchor or foot root"):
		return false
	presenter.set_direction(&"UP")
	if not _check(animated.animation == &"walk_up" and not animated.flip_h \
		and actor.global_position == foot_before and is_equal_approx(preview.carry_anchor.position.x, 28.0),
		"UP clip must resolve without moving Mochi's foot root"):
		return false
	presenter.play_action(&"serve")
	if not _check(presenter.resolved_source == &"STATIC" and presenter.static_sprite.visible,
		"Partial final frames must fall back to static without hiding Mochi"):
		return false
	var action_key := InputEventKey.new()
	action_key.keycode = KEY_3
	action_key.pressed = true
	preview._unhandled_input(action_key)
	if not _check(presenter.requested_action == &"walk", "Preview action hotkey must select a semantic action"):
		return false
	var pause_key := InputEventKey.new()
	pause_key.keycode = KEY_SPACE
	pause_key.pressed = true
	preview._unhandled_input(pause_key)
	if not _check(presenter.is_paused, "Preview pause control must work"):
		return false
	preview.queue_free()
	await process_frame
	print("[PASS] Preview controls, clip switch, canonical height, stable foot pivot, mirrored CarryAnchor, static fallback")
	return true


func _send_preview_key(preview: MochiAnimationPreview, key_code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key_code
	event.pressed = true
	preview._unhandled_input(event)


func _check_home_handoff() -> bool:
	var home := HOME.instantiate() as HomeScene
	var slice := home.get_node("VerticalSliceController") as VerticalSliceController
	slice.start_on_ready = false
	slice.auto_repeat_slice = false
	slice.customer_move_speed = 10000.0
	slice.worker_move_speed = 10000.0
	slice.timing_config = slice.timing_config.duplicate_for_testing()
	slice.timing_config.set_preset("FAST")
	slice.timing_config.customer_arrival_pause = 0.02
	slice.timing_config.customer_order_delay = 0.02
	slice.timing_config.coffee_preparation_duration = 0.10
	slice.timing_config.serve_duration = 0.02
	slice.timing_config.served_reaction_duration = 0.02
	slice.timing_config.customer_exit_delay = 0.02
	slice.timing_config.door_transition_duration = 0.03
	(home.get_node("PrototypeDoorController") as PrototypeDoorController).timing_config = slice.timing_config
	root.add_child(home)
	await process_frame
	var actor := slice.worker_actor as MochiScaleTest
	var presenter: MochiVisualPresenter = actor.visual_presenter
	var bridge := home.get_node("TrueSlicePresentation") as TrueSlicePresentation
	var interaction := home.get_node("HomeInteractionController") as HomeInteractionController
	var ambient := home.get_node("LivingCafeAmbientController") as LivingCafeAmbientController
	var action_log: Array[StringName] = []
	bridge.mochi_action_changed.connect(func(action: StringName) -> void: action_log.append(action))
	if not _check(presenter != null and presenter.resolved_source == &"LAYERED_TEMP" \
		and actor.get_node_or_null("ContactShadow") != null \
		and actor.get_node_or_null("FXAnchors/ActionFX") != null \
		and (actor.get_node("CarryCupPlaceholder") as PrototypeCarryVisual).carry_anchor == actor.get_node("CarryAnchor"),
		"Runtime hierarchy must retain visual, shadow, FX, and carry attachments"):
		return false
	slice.start_slice()
	for _frame in range(900):
		await process_frame
		if slice.active_order_id != &"":
			break
	if not _check(slice.active_order_id != &"" and ambient.agent_for(&"Mochi").work_priority,
		"Order must preempt ambient activity"):
		return false
	if not _check(interaction.interact_with_target(&"espresso_station"), "Manual coffee tap must still work"):
		return false
	for _frame in range(900):
		await process_frame
		if slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
			break
	var cup := actor.get_node("CarryCupPlaceholder") as PrototypeCarryVisual
	if not _check(slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE and cup.visible \
		and cup.position == (actor.get_node("CarryAnchor") as Marker2D).position,
		"Carry cup must follow the anchor during the existing work sequence"):
		return false
	if not _check(interaction.interact_with_target(&"active_customer"), "Manual serve must still work"):
		return false
	for _frame in range(1500):
		await process_frame
		if slice.completed_cycles == 1:
			break
	if not _check(slice.completed_cycles == 1 and not cup.visible \
		and not ambient.agent_for(&"Mochi").work_priority and presenter.resolved_source == &"LAYERED_TEMP" \
		and presenter.requested_action == bridge.mochi_action \
		and action_log.has(&"walk") and action_log.has(&"prepare_coffee") \
		and action_log.has(&"carry_coffee") and action_log.has(&"serve") \
		and action_log.has(&"return_idle"),
		"Ambient → work → ambient must complete with no stale visual or carry state"):
		return false
	home.queue_free()
	await process_frame
	print("[PASS] Home ambient/work/ambient, carry lifecycle, static fallback, independent gameplay state")
	return true


func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("[FAIL] %s" % message)
	return condition
