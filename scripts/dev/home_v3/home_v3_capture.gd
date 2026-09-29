extends Node
## Deterministic DEV viewport evidence. F6 in the Home V3 lab only.

const OUTPUT := "res://artifacts/prototype_review/home_v3_world_authoring_lab_v1/"

var running := false
var captured := 0
@onready var world: HomeV3World = get_parent()


func run_capture() -> void:
	if running:
		return
	running = true
	_run_sequence()


func _run_sequence() -> void:
	await get_tree().physics_frame
	await _save("01_home_v3_overview_9x16.png")
	world.get_node("DebugOverlay").visible = true
	await _save("02_semantic_anchors_and_footprints.png")
	world.get_node("DebugOverlay").visible = false
	var customer := world.actors.get_node("CustomerA") as HardeningActor
	if not await _perform(customer, &"entrance_door", &"enter"):
		return _abort("Customer entry")
	if not customer.request_interaction_on(&"counter_shell", &"order"):
		return _abort("Customer order")
	if not await _wait_actor_phase(customer, HardeningActor.Phase.ACTION, 650):
		return _abort("Order state")
	await _save("03_customer_order.png")
	if not await _wait_actor_phase(customer, HardeningActor.Phase.IDLE, 250):
		return _abort("Order completion")
	var worker := world.actors.get_node("Worker") as HardeningActor
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee"):
		return _abort("Worker coffee slot")
	if not await _wait_shot(world, &"brew_closeup", 650):
		return _abort("Brew close-up")
	await _save("04_brew_focus.png")
	if not await _wait_shot(world, &"cup_reveal", 650):
		return _abort("Cup reveal")
	await _save("05_cup_reveal.png")
	if not await _wait_camera_idle(world, 400):
		return _abort("Camera restore")
	var cat_a := world.actors.get_node("CatA") as HardeningActor
	var cat_b := world.actors.get_node("CatB") as HardeningActor
	var cat_c := world.actors.get_node("CatC") as HardeningActor
	if not cat_a.request_interaction_on(&"cat_bed", &"rest") \
			or not cat_b.request_interaction_on(&"plant", &"sniff") \
			or not cat_c.request_interaction_on(&"scratch_post", &"scratch"):
		return _abort("Cat life slots")
	if not await _wait_actor_phase(cat_a, HardeningActor.Phase.ACTION, 650):
		return _abort("Cat rest")
	await _save("06_cat_daily_life.png")
	if not world.focus_cat(cat_a) or not await _wait_shot(world, &"cat_emotion", 300):
		return _abort("Cat emotion focus")
	await _save("06b_cat_emotion_focus.png")
	if not await _wait_camera_idle(world, 400):
		return _abort("Cat emotion restore")
	if not await _wait_actor_phase(cat_c, HardeningActor.Phase.IDLE, 400):
		return _abort("Cat scratch completion")
	world.set_event_active(true)
	if not cat_c.request_interaction_on(&"seasonal_display", &"inspect"):
		return _abort("Event inspect")
	if not await _wait_actor_phase(cat_c, HardeningActor.Phase.ACTION, 650):
		return _abort("Event action")
	if not world.focus_event() or not await _wait_shot(world, &"event_focus", 300):
		return _abort("Event focus")
	await _save("07_event_interaction_focus.png")
	if not await _capture_tall():
		return _abort("Tall viewport")
	print("HOME V3 CAPTURE COMPLETE images=%d" % captured)
	running = false


func _capture_tall() -> bool:
	var view := SubViewport.new()
	view.size = Vector2i(539, 1168)
	view.world_2d = World2D.new()
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_tree().root.add_child(view)
	var scene: PackedScene = load("res://scenes/dev/home_v3_world_authoring_lab.tscn")
	var tall_world := scene.instantiate() as HomeV3World
	view.add_child(tall_world)
	# The editor game window uses the project's 1152-wide logical canvas at
	# 540 physical pixels; a raw SubViewport does not inherit that stretch.
	(tall_world.get_node("Camera") as Camera2D).zoom = Vector2(0.84, 0.84)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await _save("08_tall_phone_overview.png", view)
	var worker := tall_world.actors.get_node("Worker") as HardeningActor
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee") \
			or not await _wait_shot(tall_world, &"brew_closeup", 650):
		view.queue_free()
		return false
	await _save("09_tall_phone_brew_focus.png", view)
	view.queue_free()
	return true


func _perform(actor: HardeningActor, object_id: StringName, action: StringName) -> bool:
	if not actor.request_interaction_on(object_id, action):
		return false
	return await _wait_actor_phase(actor, HardeningActor.Phase.IDLE, 650) \
		and not actor.failed_navigation


func _wait_actor_phase(actor: HardeningActor, phase: int, frames: int) -> bool:
	for i in frames:
		if actor.phase == phase:
			return true
		await get_tree().physics_frame
	return false


func _wait_shot(room: HomeV3World, shot_id: StringName, frames: int) -> bool:
	for i in frames:
		if room.camera_director.current_shot_id == shot_id \
				and room.camera_director.is_holding():
			return true
		await get_tree().process_frame
	return false


func _wait_camera_idle(room: HomeV3World, frames: int) -> bool:
	for i in frames:
		if room.camera_director.mode == HardeningCameraDirector.Mode.GAMEPLAY:
			return true
		await get_tree().process_frame
	return false


func _save(filename: String, source: Viewport = null) -> void:
	await RenderingServer.frame_post_draw
	var viewport := source if source != null else get_viewport()
	var image := viewport.get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUTPUT + filename)
	var error := image.save_png(path)
	if error != OK:
		push_error("HOME V3 CAPTURE %s failed: %d" % [filename, error])
		return
	captured += 1
	print("HOME V3 CAPTURE %s %dx%d" % [filename, image.get_width(), image.get_height()])


func _abort(reason: String) -> void:
	push_error("HOME V3 CAPTURE ABORT: " + reason)
	running = false
