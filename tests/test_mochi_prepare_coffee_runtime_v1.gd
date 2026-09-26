extends SceneTree
## Focused validation test for WILLICAT_MOCHI_PREPARE_COFFEE_RUNTIME_INTEGRATION_V1.

const PREVIEW: PackedScene = preload("res://scenes/dev/mochi_animation_preview.tscn")
const HOME: PackedScene = preload("res://scenes/home/home_scene.tscn")
const RUNTIME_ATLAS_PATH: String = "res://assets/characters/mochi/animations/prepare_coffee/mochi_prepare_coffee_v1.png"
const RUNTIME_TRES_PATH: String = "res://assets/characters/mochi/animations/prepare_coffee/mochi_prepare_coffee_v1.tres"
const ANIMATION_SET_PATH: String = "res://assets/characters/mochi/runtime/mochi_animation_set.tres"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check_asset_contract():
		quit(1)
		return
	if not _check_resolution_and_contracts():
		quit(1)
		return
	if not await _check_preview_presentation_and_geometry():
		quit(1)
		return
	if not await _check_home_true_slice_execution():
		quit(1)
		return
	if not await _check_home_true_slice_auto_execution():
		quit(1)
		return
	print("--- ALL MOCHI PREPARE COFFEE RUNTIME V1 CHECKS PASSED ---")
	quit(0)


func _check_asset_contract() -> bool:
	var atlas := Image.new()
	var atlas_error: Error = atlas.load(ProjectSettings.globalize_path(RUNTIME_ATLAS_PATH))
	if not _check(atlas_error == OK and atlas.get_size() == Vector2i(3104, 474) \
		and atlas.get_format() == Image.FORMAT_RGBA8 and atlas.detect_alpha(),
		"Runtime prepare_coffee atlas must be 3104x474 RGBA with alpha"):
		return false

	var frames := load(RUNTIME_TRES_PATH) as SpriteFrames
	if not _check(frames != null and frames.has_animation(&"prepare_coffee"),
		"SpriteFrames resource must exist and have prepare_coffee animation"):
		return false
	if not _check(frames.get_frame_count(&"prepare_coffee") == 8,
		"prepare_coffee SpriteFrames must contain exactly 8 frames"):
		return false
	if not _check(is_equal_approx(frames.get_animation_speed(&"prepare_coffee"), 8.0),
		"prepare_coffee animation speed must be 8.0 FPS"):
		return false
	if not _check(frames.get_animation_loop(&"prepare_coffee"),
		"prepare_coffee animation loop must be true"):
		return false

	for i in range(8):
		var tex: Texture2D = frames.get_frame_texture(&"prepare_coffee", i)
		if not _check(tex is AtlasTexture, "Frame %d must be an AtlasTexture" % i):
			return false
		var atlas_tex := tex as AtlasTexture
		var expected_rect := Rect2(i * 388, 0, 388, 474)
		if not _check(atlas_tex.region == expected_rect,
			"Frame %d region must be %s, got %s" % [i, str(expected_rect), str(atlas_tex.region)]):
			return false
		if not _check(atlas_tex.get_size() == Vector2(388, 474),
			"Frame %d size must be 388x474" % i):
			return false

	# Verify no Downloads, absolute or foreign paths in runtime .tres
	var tres_file := FileAccess.open(ProjectSettings.globalize_path(RUNTIME_TRES_PATH), FileAccess.READ)
	if not _check(tres_file != null, "Must be able to open runtime .tres for text inspection"):
		return false
	var tres_text: String = tres_file.get_as_text()
	tres_file.close()
	if not _check(not tres_text.contains("Downloads") and not tres_text.contains("/Users/") \
		and not tres_text.contains("MochiPrepareCoffeeRuntime/"),
		"Runtime .tres must contain clean relative project paths with no Downloads or package-local paths"):
		return false

	# Verify source provenance documents and diagnostic files
	for doc_file in [
		"docs/source_assets/mochi/prepare_coffee_v1/.gdignore",
		"docs/source_assets/mochi/prepare_coffee_v1/MOCHI_PREPARE_COFFEE_RUNTIME_METADATA_V1.json",
		"docs/source_assets/mochi/prepare_coffee_v1/README_GODOT.md",
		"docs/source_assets/mochi/prepare_coffee_v1/MOCHI_PREPARE_COFFEE_EDGE_DIAGNOSTIC.png",
		"docs/source_assets/mochi/prepare_coffee_v1/MOCHI_PREPARE_COFFEE_150PX_PREVIEW.png"
	]:
		if not _check(FileAccess.file_exists(ProjectSettings.globalize_path("res://" + doc_file)),
			"Source provenance file must exist: %s" % doc_file):
			return false

	print("[PASS] Asset contract: 3104x474 RGBA atlas, 8 frames at 8 FPS looping, clean res:// paths, provenance stored")
	return true


func _check_resolution_and_contracts() -> bool:
	var set := load(ANIMATION_SET_PATH) as MochiAnimationSet
	if not _check(set != null, "MochiAnimationSet must load from %s" % ANIMATION_SET_PATH):
		return false

	# Registration overrides
	if not _check(set.visible_height_by_clip.has(&"prepare_coffee") \
		and is_equal_approx(float(set.visible_height_by_clip[&"prepare_coffee"]), 412.0),
		"visible_height_by_clip must register prepare_coffee at 412.0 px"):
		return false
	if not _check(set.foot_y_by_clip.has(&"prepare_coffee") \
		and is_equal_approx(float(set.foot_y_by_clip[&"prepare_coffee"]), 441.0),
		"foot_y_by_clip must register prepare_coffee at 441.0 px"):
		return false

	# Direction-independent resolution (generic station working pose, no auto-flipping)
	for dir in [&"RIGHT", &"LEFT", &"DOWN", &"UP", &"SIDE"]:
		var res: Dictionary = set.resolve(&"prepare_coffee", dir)
		if not _check(res["source"] == &"TEMP" \
			and res["clip"] == &"prepare_coffee" \
			and res["resolved_action"] == &"prepare_coffee" \
			and not res["flip_h"],
			"prepare_coffee with direction %s must resolve to generic TEMP:prepare_coffee without flip" % String(dir)):
			return false

	# Walk directional pipeline remains unchanged
	var walk_right: Dictionary = set.resolve(&"walk", &"RIGHT")
	if not _check(walk_right["source"] == &"TEMP" and walk_right["clip"] == &"walk_side" \
		and not walk_right["flip_h"],
		"walk RIGHT must still resolve to unflipped TEMP:walk_side"):
		return false
	var walk_left: Dictionary = set.resolve(&"walk", &"LEFT")
	if not _check(walk_left["source"] == &"TEMP" and walk_left["clip"] == &"walk_side" \
		and walk_left["flip_h"],
		"walk LEFT must resolve to mirrored TEMP:walk_side"):
		return false

	# Fallback chain for other actions remains intact
	if not _check(set.resolve(&"carry_coffee", &"RIGHT")["source"] == &"TEMP",
		"carry_coffee must still fall back to walk"):
		return false
	if not _check(set.resolve(&"serve", &"RIGHT")["source"] == &"STATIC",
		"serve must still fall back to static idle"):
		return false

	print("[PASS] Resolution & contracts: generic prepare_coffee, no auto-mirror, walk directional pipeline intact")
	return true


func _check_preview_presentation_and_geometry() -> bool:
	var preview := PREVIEW.instantiate() as MochiAnimationPreview
	root.add_child(preview)
	await process_frame

	var presenter: MochiVisualPresenter = preview.presenter
	var actor: Node2D = preview.actor
	var root_pos_before: Vector2 = actor.global_position
	var shadow_pos_before: Vector2 = actor.get_node("ContactShadow").global_position
	var carry_anchor_pos_before: Vector2 = preview.carry_anchor.global_position

	# Verify start state is layered idle
	if not _check(presenter.presentation_mode == &"LAYERED_IDLE" \
		and presenter.resolved_source == &"LAYERED_TEMP" \
		and not presenter.animated_sprite.visible \
		and presenter.layered_idle.visible,
		"Preview must start in layered idle"):
		preview.queue_free()
		return false

	# Trigger prepare_coffee via Key 4
	var key_4 := InputEventKey.new()
	key_4.keycode = KEY_4
	key_4.pressed = true
	preview._unhandled_input(key_4)
	await process_frame

	if not _check(presenter.requested_action == &"prepare_coffee" \
		and presenter.resolved_source == &"TEMP" \
		and presenter.resolved_clip == &"prepare_coffee" \
		and presenter.animated_sprite.visible \
		and not presenter.layered_idle.visible \
		and not presenter.animated_sprite.flip_h,
		"Key 4 must activate prepare_coffee on AnimatedSprite2D unflipped"):
		preview.queue_free()
		return false

	# Verify 150 px scale and foot alignment
	var anim_sprite: AnimatedSprite2D = presenter.animated_sprite
	var visible_h: float = 412.0 * anim_sprite.scale.y
	if not _check(is_equal_approx(visible_h, 150.0),
		"prepare_coffee visible height must scale to ~150 px (got %.2f px)" % visible_h):
		preview.queue_free()
		return false

	# Check foot alignment: root in cell is y=441, offset.y is -441
	if not _check(is_equal_approx(anim_sprite.offset.y + 441.0, 0.0),
		"prepare_coffee foot contact offset must align root (offset.y=%.1f)" % anim_sprite.offset.y):
		preview.queue_free()
		return false

	# Check gameplay root, shadow, carry anchor stability
	if not _check(actor.global_position == root_pos_before \
		and actor.get_node("ContactShadow").global_position == shadow_pos_before \
		and preview.carry_anchor.global_position == carry_anchor_pos_before,
		"Gameplay root, shadow, and CarryAnchor must remain stable during prepare_coffee"):
		preview.queue_free()
		return false

	# Verify label status
	if not _check(preview.info_label.text.contains("prepare_coffee") \
		and preview.info_label.text.contains("TEMP:prepare_coffee"),
		"Preview info label must report prepare_coffee action"):
		preview.queue_free()
		return false

	# Return to idle via Key 1
	var key_1 := InputEventKey.new()
	key_1.keycode = KEY_1
	key_1.pressed = true
	preview._unhandled_input(key_1)
	await process_frame

	if not _check(presenter.presentation_mode == &"LAYERED_IDLE" \
		and not presenter.animated_sprite.visible \
		and presenter.layered_idle.visible,
		"Key 1 must return cleanly to layered idle"):
		preview.queue_free()
		return false

	preview.queue_free()
	await process_frame
	print("[PASS] Preview presentation: 150 px scale, foot root stable, shadow/CarryAnchor intact, clean transitions")
	return true


func _check_home_true_slice_execution() -> bool:
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
	slice.timing_config.coffee_preparation_duration = 0.15
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

	var action_log: Array[StringName] = []
	var prepare_source_seen: StringName = &""
	var prepare_clip_seen: StringName = &""
	var animated_visible_during_brew: bool = false

	bridge.mochi_action_changed.connect(func(action: StringName) -> void:
		action_log.append(action)
	)

	slice.start_slice()
	for _frame in range(900):
		await process_frame
		if slice.active_order_id != &"":
			break

	if not _check(interaction.interact_with_target(&"espresso_station"), "Espresso tap must succeed"):
		home.queue_free()
		return false

	# Observe coffee preparation phase
	for _frame in range(900):
		await process_frame
		if slice.worker_slice.state == SliceWorker.State.PREPARING_COFFEE:
			prepare_source_seen = presenter.resolved_source
			prepare_clip_seen = presenter.resolved_clip
			animated_visible_during_brew = presenter.animated_sprite.visible
		if slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
			break

	if not _check(action_log.has(&"prepare_coffee"), "prepare_coffee action must be emitted"):
		home.queue_free()
		return false
	if not _check(prepare_source_seen == &"TEMP" and prepare_clip_seen == &"prepare_coffee",
		"prepare_coffee must resolve to TEMP:prepare_coffee during brewing (got %s:%s)" % [
			String(prepare_source_seen), String(prepare_clip_seen)
		]):
		home.queue_free()
		return false
	if not _check(animated_visible_during_brew,
		"ActionAnimatedSprite must be visible during coffee preparation"):
		home.queue_free()
		return false

	# Complete service
	if not _check(interaction.interact_with_target(&"active_customer"), "Serve tap must succeed"):
		home.queue_free()
		return false

	for _frame in range(1500):
		await process_frame
		if slice.completed_cycles == 1:
			break

	if not _check(slice.completed_cycles == 1, "True slice cycle must complete"):
		home.queue_free()
		return false
	if not _check(presenter.resolved_source == &"LAYERED_TEMP",
		"Worker must return to layered idle after service"):
		home.queue_free()
		return false

	home.queue_free()
	await process_frame
	print("[PASS] True slice execution (Manual): prepare_coffee uses TEMP runtime animation, cycle completes cleanly")
	return true


func _check_home_true_slice_auto_execution() -> bool:
	var home := HOME.instantiate() as HomeScene
	var slice := home.get_node("VerticalSliceController") as VerticalSliceController
	slice.start_on_ready = false
	slice.auto_repeat_slice = false
	slice.interaction_mode = VerticalSliceController.InteractionMode.AUTO_LOOP
	slice.customer_move_speed = 10000.0
	slice.worker_move_speed = 10000.0
	slice.timing_config = slice.timing_config.duplicate_for_testing()
	slice.timing_config.set_preset("FAST")
	slice.timing_config.customer_arrival_pause = 0.02
	slice.timing_config.customer_order_delay = 0.02
	slice.timing_config.coffee_preparation_duration = 0.15
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

	var action_log: Array[StringName] = []
	bridge.mochi_action_changed.connect(func(action: StringName) -> void:
		action_log.append(action)
	)

	slice.start_slice()

	# Run until completion
	for _frame in range(3000):
		await process_frame
		if slice.completed_cycles == 1:
			break

	if not _check(action_log.has(&"prepare_coffee"), "AUTO slice must run prepare_coffee"):
		home.queue_free()
		return false
	if not _check(slice.completed_cycles == 1, "AUTO slice must complete cycle 1"):
		home.queue_free()
		return false
	if not _check(presenter.resolved_source == &"LAYERED_TEMP",
		"AUTO worker must return to layered idle"):
		home.queue_free()
		return false

	home.queue_free()
	await process_frame
	print("[PASS] True slice execution (Auto): complete cycle with prepare_coffee, reward, clean return")
	return true


func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("[FAIL] %s" % message)
	return condition
