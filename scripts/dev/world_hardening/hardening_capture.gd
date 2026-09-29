extends Node
## Dev-only deterministic real-viewport evidence pack. F6 in the lab.

const OUTPUT := "res://artifacts/prototype_review/world_architecture_hardening_v1/"

var running := false
var captured := 0
@onready var world: HardeningWorld = get_parent()


func run_capture() -> void:
	if running:
		return
	running = true
	_run_sequence()


func _run_sequence() -> void:
	var a := world.actors.get_node("CustomerA") as HardeningActor
	var b := world.actors.get_node("CustomerB") as HardeningActor
	var cat_a := world.actors.get_node("CatA") as HardeningActor
	var cat_b := world.actors.get_node("CatB") as HardeningActor
	var cat_c := world.actors.get_node("CatC") as HardeningActor
	var worker := world.actors.get_node("Worker") as HardeningActor
	await get_tree().physics_frame
	await _capture("01_hardening_lab_overview.png")
	world.get_node("DebugOverlay").visible = true
	if not a.navigate_to_marker(world.get_node("CrossTableTarget")):
		return _abort("table route did not start")
	for i in 10:
		await get_tree().physics_frame
	await _capture("02_table_navigation_avoidance.png")
	if not await _wait_actor(a, HardeningActor.Phase.IDLE, 500):
		return _abort("table route did not finish")
	world.get_node("DebugOverlay").visible = false
	if not a.request_interaction_on(&"chair_a", &"sit"):
		return _abort("Chair A reserve failed")
	if not await _wait_actor(a, HardeningActor.Phase.ACTION, 500):
		return _abort("Chair A action missing")
	await _capture("03_chair_a_reserved.png")
	if not b.request_interaction_on(&"chair_b", &"sit"):
		return _abort("Chair B reserve failed")
	if not await _wait_actor(b, HardeningActor.Phase.ACTION, 500):
		return _abort("Chair B action missing")
	await _capture("04_chair_b_second_customer.png")
	await _wait_actor(a, HardeningActor.Phase.IDLE, 500)
	await _wait_actor(b, HardeningActor.Phase.IDLE, 500)
	if not cat_a.request_interaction_on(&"cat_bed", &"rest"):
		return _abort("CatBed reserve failed")
	if not await _wait_actor(cat_a, HardeningActor.Phase.ACTION, 500):
		return _abort("CatBed action missing")
	await _capture("05_catbed_reserved.png")
	if cat_b.request_interaction_on(&"cat_bed", &"rest"):
		return _abort("second cat incorrectly reserved occupied bed")
	if not cat_b.request_interaction_on(&"plant", &"sniff"):
		return _abort("second cat alternate action missing")
	if not await _wait_actor(cat_b, HardeningActor.Phase.ACTION, 500):
		return _abort("alternate sniff action missing")
	await _capture("06_second_cat_alternate_action.png")
	await _wait_actor(cat_a, HardeningActor.Phase.IDLE, 500)
	await _wait_actor(cat_b, HardeningActor.Phase.IDLE, 500)
	# 07/08 are separately captured directly by GodotAI before/after editor moves.
	world.get_node("DebugOverlay").visible = true
	await _capture("09_owned_anchors_after_move.png")
	world.get_node("DebugOverlay").visible = false
	world.camera_input.pan_by(Vector2(22, 14))
	world.camera_input.zoom_by(1.16)
	var expected_position := (world.get_node("Camera") as Camera2D).global_position
	var expected_zoom := (world.get_node("Camera") as Camera2D).zoom
	await _capture("10_gameplay_camera_before_focus.png")
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee"):
		return _abort("worker coffee action failed")
	if not await _wait_shot(&"brew_closeup", 500):
		return _abort("brew close-up missing")
	await _capture("11_brew_closeup.png")
	if not await _wait_shot(&"cup_reveal", 500):
		return _abort("cup reveal missing")
	await _capture("12_cup_reveal.png")
	if not await _wait_camera_idle(500):
		return _abort("camera restore timeout")
	if not (world.get_node("Camera") as Camera2D).global_position.is_equal_approx(expected_position) \
			or not (world.get_node("Camera") as Camera2D).zoom.is_equal_approx(expected_zoom):
		return _abort("camera restore drift")
	await _capture("13_camera_restored.png")
	if not await _capture_tall_view():
		return _abort("tall SubViewport capture failed")
	world.set_event_active(false)
	await _capture("15_event_variant_off.png")
	world.set_event_active(true)
	await get_tree().physics_frame
	await _capture("16_event_variant_on.png")
	if not cat_c.request_interaction_on(&"seasonal_display", &"inspect"):
		return _abort("event inspect action failed")
	if not await _wait_actor(cat_c, HardeningActor.Phase.ACTION, 500):
		return _abort("event inspect action missing")
	await _capture("17_event_object_interaction.png")
	if not world.focus_event():
		return _abort("event camera focus refused")
	if not await _wait_shot(&"event_focus", 300):
		return _abort("event camera focus missing")
	await _capture("18_event_camera_focus.png")
	await _wait_camera_idle(500)
	print("HARDENING CAPTURE COMPLETE generated=%d (07/08 via live GodotAI)" % captured)
	running = false


func _wait_actor(actor: HardeningActor, expected: HardeningActor.Phase, limit: int) -> bool:
	for i in limit:
		if actor.phase == expected:
			return true
		await get_tree().physics_frame
	return false


func _capture_tall_view() -> bool:
	# The editor's embedded game window refuses runtime resize. A second genuine
	# Godot viewport renders the SAME lab scene at a real tall-phone raster.
	var view := SubViewport.new()
	view.size = Vector2i(539, 1168)
	view.world_2d = World2D.new()
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_tree().root.add_child(view)
	var lab_scene: PackedScene = load("res://scenes/dev/world_architecture_hardening_lab.tscn")
	var tall_world := lab_scene.instantiate() as HardeningWorld
	view.add_child(tall_world)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var worker := tall_world.actors.get_node("Worker") as HardeningActor
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee"):
		view.queue_free()
		return false
	var held := false
	for i in 500:
		if tall_world.camera_director.current_shot_id == &"brew_closeup" \
				and tall_world.camera_director.is_holding():
			held = true
			break
		await get_tree().process_frame
	if held:
		await _capture("14_tall_phone_focus.png", view)
	view.queue_free()
	return held


func _wait_shot(id: StringName, limit: int) -> bool:
	for i in limit:
		if world.camera_director.current_shot_id == id and world.camera_director.is_holding():
			return true
		await get_tree().process_frame
	return false


func _wait_camera_idle(limit: int) -> bool:
	for i in limit:
		if world.camera_director.mode == HardeningCameraDirector.Mode.GAMEPLAY:
			return true
		await get_tree().process_frame
	return false


func _capture(filename: String, source_viewport: Viewport = null) -> void:
	await RenderingServer.frame_post_draw
	var viewport := source_viewport if source_viewport != null else get_viewport()
	var image := viewport.get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUTPUT + filename)
	var error := image.save_png(path)
	if error != OK:
		push_error("HARDENING CAPTURE FAILED %s error=%d" % [filename, error])
		return
	captured += 1
	print("HARDENING CAPTURE %s %dx%d" % [filename, image.get_width(), image.get_height()])


func _abort(reason: String) -> void:
	push_error("HARDENING CAPTURE ABORT: " + reason)
	running = false
