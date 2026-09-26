class_name TestMochiDirectionalWalkRuntimeV1
extends SceneTree
## Focused test suite for WILLICAT_MOCHI_DIRECTIONAL_WALK_RUNTIME_V1.
## Validates directional walk resolution (RIGHT, LEFT mirrored, UP, DOWN),
## asset contracts, SpriteFrames, lack of foreign/Downloads paths,
## layered idle preservation, prepare_coffee compatibility,
## ContactShadow & root stability, and True Vertical Slice execution.

const SET_PATH: String = "res://assets/characters/mochi/runtime/mochi_animation_set.tres"
const WALK_SIDE_TRES: String = "res://assets/characters/mochi/animations/walk/mochi_walk_side_right_prototype_v1.tres"
const WALK_UP_TRES: String = "res://assets/characters/mochi/animations/walk/mochi_walk_up_v1.tres"
const WALK_DOWN_TRES: String = "res://assets/characters/mochi/animations/walk/mochi_walk_down_v1.tres"
const PREPARE_COFFEE_TRES: String = "res://assets/characters/mochi/animations/prepare_coffee/mochi_prepare_coffee_v1.tres"

const WALK_UP_PNG: String = "res://assets/characters/mochi/animations/walk/mochi_walk_up_v1.png"
const WALK_DOWN_PNG: String = "res://assets/characters/mochi/animations/walk/mochi_walk_down_v1.png"
const WALK_SIDE_PNG: String = "res://assets/characters/mochi/animations/walk/mochi_walk_side_right_prototype_v1.png"

const PREVIEW_SCENE: PackedScene = preload("res://scenes/dev/mochi_animation_preview.tscn")
const HOME_SCENE: PackedScene = preload("res://scenes/home/home_scene.tscn")

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("[FAIL] %s" % message)
		_failed = true
		return false
	return true


func _run() -> void:
	print("--- BEGIN TEST_MOCHI_DIRECTIONAL_WALK_RUNTIME_V1 ---")

	if not await _check_asset_contracts_and_provenance():
		quit(1)
		return

	if not _check_resolver_contracts():
		quit(1)
		return

	if not await _check_preview_presentation_and_geometry():
		quit(1)
		return

	if not await _check_home_true_slice_manual():
		quit(1)
		return

	if not await _check_home_true_slice_auto():
		quit(1)
		return

	print("--- ALL MOCHI DIRECTIONAL WALK RUNTIME V1 CHECKS PASSED ---")
	quit(0)


func _check_asset_contracts_and_provenance() -> bool:
	# 1. Verify PNG atlases
	var up_tex := load(WALK_UP_PNG) as Texture2D
	if not _check(up_tex != null and up_tex.get_size() == Vector2(2560, 320),
		"mochi_walk_up_v1.png must load and be 2560x320 RGBA"):
		return false

	var down_tex := load(WALK_DOWN_PNG) as Texture2D
	if not _check(down_tex != null and down_tex.get_size() == Vector2(2560, 320),
		"mochi_walk_down_v1.png must load and be 2560x320 RGBA"):
		return false

	var side_tex := load(WALK_SIDE_PNG) as Texture2D
	if not _check(side_tex != null and side_tex.get_size() == Vector2(2560, 320),
		"mochi_walk_side_right_prototype_v1.png must load and be 2560x320 RGBA"):
		return false

	# 2. Verify SpriteFrames resources
	var up_frames := load(WALK_UP_TRES) as SpriteFrames
	if not _check(up_frames != null and up_frames.has_animation(&"walk_up") \
		and up_frames.get_frame_count(&"walk_up") == 8 \
		and up_frames.get_animation_loop(&"walk_up") \
		and is_equal_approx(up_frames.get_animation_speed(&"walk_up"), 8.0),
		"mochi_walk_up_v1.tres must have 8 frames at 8.0 FPS looping"):
		return false
	for i in range(8):
		var t: Texture2D = up_frames.get_frame_texture(&"walk_up", i)
		if not _check(t != null and t.get_size() == Vector2(320, 320),
			"mochi_walk_up_v1 frame %d must be 320x320" % i):
			return false

	var down_frames := load(WALK_DOWN_TRES) as SpriteFrames
	if not _check(down_frames != null and down_frames.has_animation(&"walk_down") \
		and down_frames.get_frame_count(&"walk_down") == 8 \
		and down_frames.get_animation_loop(&"walk_down") \
		and is_equal_approx(down_frames.get_animation_speed(&"walk_down"), 8.0),
		"mochi_walk_down_v1.tres must have 8 frames at 8.0 FPS looping"):
		return false
	for i in range(8):
		var t: Texture2D = down_frames.get_frame_texture(&"walk_down", i)
		if not _check(t != null and t.get_size() == Vector2(320, 320),
			"mochi_walk_down_v1 frame %d must be 320x320" % i):
			return false

	# 3. Verify no foreign or Downloads paths in text resources
	var files_to_scan: Array[String] = [
		SET_PATH, WALK_UP_TRES, WALK_DOWN_TRES, WALK_SIDE_TRES, PREPARE_COFFEE_TRES
	]
	for res_path in files_to_scan:
		var file := FileAccess.open(res_path, FileAccess.READ)
		if not _check(file != null, "Resource %s must be readable" % res_path):
			return false
		var text := file.get_as_text()
		file.close()
		if not _check(not text.contains("Downloads") and not text.contains("/Users/"),
			"Resource %s must not contain Downloads or absolute paths" % res_path):
			return false

	# 4. Verify provenance files exist
	var provenance_files: Array[String] = [
		"res://docs/source_assets/mochi/walk_up_v1/.gdignore",
		"res://docs/source_assets/mochi/walk_up_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_back_walk_walk_up.png",
		"res://docs/source_assets/mochi/walk_up_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_back_walk_walk_up.webp",
		"res://docs/source_assets/mochi/walk_down_v1/.gdignore",
		"res://docs/source_assets/mochi/walk_down_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk_down.png",
		"res://docs/source_assets/mochi/walk_down_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk_down.webp",
		"res://docs/source_assets/mochi/back_idle_reference_v1/.gdignore",
		"res://docs/source_assets/mochi/back_idle_reference_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_back_idle_idle_back.png",
		"res://docs/source_assets/mochi/back_idle_reference_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_back_idle_idle_back.webp",
	]
	for p in provenance_files:
		if not _check(FileAccess.file_exists(p), "Provenance file %s must exist" % p):
			return false

	print("[PASS] Asset contracts & provenance: 2560x320 atlases, 8 frames @ 8 FPS looping, clean res:// paths, all provenance files stored")
	return true


func _check_resolver_contracts() -> bool:
	var set := load(SET_PATH) as MochiAnimationSet
	if not _check(set != null and set.allow_side_mirror,
		"MochiAnimationSet must load with allow_side_mirror = true"):
		return false

	# Walk RIGHT -> TEMP:walk_side, flip_h: false
	var walk_r: Dictionary = set.resolve(&"walk", &"RIGHT")
	if not _check(walk_r["source"] == &"TEMP" and walk_r["clip"] == &"walk_side" \
		and walk_r["resolved_action"] == &"walk" and not walk_r["flip_h"],
		"walk RIGHT must resolve to TEMP:walk_side unflipped"):
		return false

	# Walk LEFT -> TEMP:walk_side, flip_h: true (TEMP mirror)
	var walk_l: Dictionary = set.resolve(&"walk", &"LEFT")
	if not _check(walk_l["source"] == &"TEMP" and walk_l["clip"] == &"walk_side" \
		and walk_l["resolved_action"] == &"walk" and walk_l["flip_h"],
		"walk LEFT must resolve to TEMP:walk_side mirrored (flip_h=true)"):
		return false

	# Walk UP -> TEMP:walk_up, flip_h: false
	var walk_u: Dictionary = set.resolve(&"walk", &"UP")
	if not _check(walk_u["source"] == &"TEMP" and walk_u["clip"] == &"walk_up" \
		and walk_u["resolved_action"] == &"walk" and not walk_u["flip_h"],
		"walk UP must resolve to TEMP:walk_up unflipped"):
		return false

	# Walk DOWN -> TEMP:walk_down, flip_h: false
	var walk_d: Dictionary = set.resolve(&"walk", &"DOWN")
	if not _check(walk_d["source"] == &"TEMP" and walk_d["clip"] == &"walk_down" \
		and walk_d["resolved_action"] == &"walk" and not walk_d["flip_h"],
		"walk DOWN must resolve to TEMP:walk_down unflipped"):
		return false

	# Idle remains STATIC in resolver (presented via LayeredIdleVisual)
	for d in [&"RIGHT", &"LEFT", &"UP", &"DOWN"]:
		var idle_res: Dictionary = set.resolve(&"idle", d)
		if not _check(idle_res["source"] == &"STATIC" and idle_res["clip"] == &"",
			"idle %s must remain STATIC in resolver" % String(d)):
			return false

	# prepare_coffee never mirrors regardless of direction
	for d in [&"RIGHT", &"LEFT", &"UP", &"DOWN"]:
		var prep_res: Dictionary = set.resolve(&"prepare_coffee", d)
		if not _check(prep_res["source"] == &"TEMP" and prep_res["clip"] == &"prepare_coffee" \
			and not prep_res["flip_h"],
			"prepare_coffee %s must resolve to generic TEMP:prepare_coffee without flip" % String(d)):
			return false

	print("[PASS] Semantic walk resolver: RIGHT (unflipped), LEFT (mirrored), UP (walk_up), DOWN (walk_down), prepare_coffee unflipped")
	return true


func _check_preview_presentation_and_geometry() -> bool:
	var preview := PREVIEW_SCENE.instantiate() as MochiAnimationPreview
	root.add_child(preview)
	await process_frame

	var presenter: MochiVisualPresenter = preview.presenter
	var actor: Node2D = preview.actor
	var root_pos_before: Vector2 = actor.global_position
	var shadow_pos_before: Vector2 = actor.get_node("ContactShadow").global_position
	var carry_anchor_pos_before: Vector2 = preview.carry_anchor.global_position

	# 1. Start in Layered Idle
	if not _check(presenter.presentation_mode == &"LAYERED_IDLE" \
		and not presenter.animated_sprite.visible and presenter.layered_idle.visible \
		and not presenter.animated_sprite.flip_h,
		"Preview must start in LayeredIdleVisual with no flip_h"):
		preview.queue_free()
		return false

	# 2. Key 3 (walk) + Key D (RIGHT)
	_send_key(preview, KEY_3)
	_send_key(preview, KEY_D)
	await process_frame
	if not _check(presenter.requested_action == &"walk" and presenter.direction == &"RIGHT" \
		and presenter.resolved_clip == &"walk_side" and presenter.animated_sprite.visible \
		and not presenter.animated_sprite.flip_h \
		and is_equal_approx(preview.carry_anchor.position.x, 28.0),
		"Walk RIGHT must show unflipped walk_side and normal carry anchor"):
		preview.queue_free()
		return false
	_check_clip_height_and_root(presenter, actor, root_pos_before, shadow_pos_before, "walk_side RIGHT")

	# 3. Key A (LEFT) -> Mirrored walk_side
	_send_key(preview, KEY_A)
	await process_frame
	if not _check(presenter.direction == &"LEFT" and presenter.resolved_clip == &"walk_side" \
		and presenter.animated_sprite.visible and presenter.animated_sprite.flip_h \
		and is_equal_approx(preview.carry_anchor.position.x, -28.0),
		"Walk LEFT must show mirrored walk_side and inverted carry anchor (-28 px)"):
		preview.queue_free()
		return false
	_check_clip_height_and_root(presenter, actor, root_pos_before, shadow_pos_before, "walk_side LEFT (mirrored)")

	# 4. Key W (UP) -> walk_up unflipped, carry anchor restored
	_send_key(preview, KEY_W)
	await process_frame
	if not _check(presenter.direction == &"UP" and presenter.resolved_clip == &"walk_up" \
		and presenter.animated_sprite.visible and not presenter.animated_sprite.flip_h \
		and is_equal_approx(preview.carry_anchor.position.x, 28.0),
		"Walk UP must show unflipped walk_up and reset carry anchor (+28 px)"):
		preview.queue_free()
		return false
	_check_clip_height_and_root(presenter, actor, root_pos_before, shadow_pos_before, "walk_up")

	# 5. Key S (DOWN) -> walk_down unflipped
	_send_key(preview, KEY_S)
	await process_frame
	if not _check(presenter.direction == &"DOWN" and presenter.resolved_clip == &"walk_down" \
		and presenter.animated_sprite.visible and not presenter.animated_sprite.flip_h \
		and is_equal_approx(preview.carry_anchor.position.x, 28.0),
		"Walk DOWN must show unflipped walk_down and normal carry anchor"):
		preview.queue_free()
		return false
	_check_clip_height_and_root(presenter, actor, root_pos_before, shadow_pos_before, "walk_down")

	# 6. Key 1 (idle) -> Clean return to layered idle, flip_h reset
	_send_key(preview, KEY_1)
	await process_frame
	if not _check(presenter.presentation_mode == &"LAYERED_IDLE" \
		and not presenter.animated_sprite.visible and presenter.layered_idle.visible \
		and not presenter.animated_sprite.flip_h,
		"Return to Key 1 must restore LayeredIdleVisual with flip_h=false"):
		preview.queue_free()
		return false

	# 7. Key 4 (prepare_coffee) -> Clean transition, never mirrored
	_send_key(preview, KEY_4)
	await process_frame
	if not _check(presenter.requested_action == &"prepare_coffee" \
		and presenter.resolved_clip == &"prepare_coffee" and presenter.animated_sprite.visible \
		and not presenter.animated_sprite.flip_h,
		"Key 4 must activate prepare_coffee unflipped"):
		preview.queue_free()
		return false

	# 8. Clean return to idle again
	_send_key(preview, KEY_1)
	await process_frame
	if not _check(presenter.presentation_mode == &"LAYERED_IDLE" \
		and not presenter.animated_sprite.visible and presenter.layered_idle.visible,
		"Clean return to idle after prepare_coffee"):
		preview.queue_free()
		return false

	preview.queue_free()
	await process_frame
	print("[PASS] Preview presentation: RIGHT, LEFT (mirror), UP, DOWN, idle return, prepare_coffee, all root & shadow stable")
	return true


func _check_clip_height_and_root(presenter: MochiVisualPresenter, actor: Node2D,
		expected_root: Vector2, expected_shadow: Vector2, clip_name: String) -> void:
	var anim_sprite: AnimatedSprite2D = presenter.animated_sprite
	var visible_h: float = 320.0 * anim_sprite.scale.y
	_check(is_equal_approx(visible_h, 150.0),
		"%s visible height must scale to ~150 px (got %.2f)" % [clip_name, visible_h])
	_check(actor.global_position == expected_root,
		"%s must not move actor root position" % clip_name)
	_check(actor.get_node("ContactShadow").global_position == expected_shadow,
		"%s must keep ContactShadow position stable" % clip_name)


func _send_key(preview: MochiAnimationPreview, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	preview._unhandled_input(event)


func _check_home_true_slice_manual() -> bool:
	var home := HOME_SCENE.instantiate() as HomeScene
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

	var clips_seen: Dictionary = {}
	presenter.clip_resolved.connect(func(_action: StringName, _source: StringName, clip: StringName) -> void:
		if clip != &"":
			clips_seen[clip] = true
	)

	slice.start_slice()

	# Wait for customer arrival & order
	for _frame in range(900):
		await process_frame
		if slice.active_order_id != &"":
			break

	if not _check(interaction.interact_with_target(&"espresso_station"), "Espresso tap must succeed"):
		home.queue_free()
		return false

	# Wait for coffee preparation
	for _frame in range(900):
		await process_frame
		if slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
			break

	# Complete service
	if not _check(interaction.interact_with_target(&"active_customer"), "Serve tap must succeed"):
		home.queue_free()
		return false

	# Wait for completion
	for _frame in range(1500):
		await process_frame
		if slice.completed_cycles == 1:
			break

	if not _check(slice.completed_cycles == 1, "Manual true slice must complete 1 cycle"):
		home.queue_free()
		return false

	if not _check(presenter.resolved_source == &"LAYERED_TEMP",
		"Worker must return to LayeredIdleVisual after manual cycle"):
		home.queue_free()
		return false

	home.queue_free()
	await process_frame
	print("[PASS] True Vertical Slice Manual: completes cleanly with directional walk")
	return true


func _check_home_true_slice_auto() -> bool:
	var home := HOME_SCENE.instantiate() as HomeScene
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

	slice.start_slice()

	# Run until completion of 1 full auto cycle
	for _frame in range(3000):
		await process_frame
		if slice.completed_cycles == 1:
			break

	if not _check(slice.completed_cycles == 1, "AUTO slice must complete cycle 1"):
		home.queue_free()
		return false

	if not _check(presenter.resolved_source == &"LAYERED_TEMP",
		"AUTO worker must return to layered idle"):
		home.queue_free()
		return false

	home.queue_free()
	await process_frame
	print("[PASS] True Vertical Slice Auto: complete cycle with prepare_coffee, reward, clean return")
	return true
