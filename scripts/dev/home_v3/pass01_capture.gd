extends Node
## Deterministic development-only review pack; every image comes from Godot.

const OUTPUT := "res://artifacts/prototype_review/home_v3_level_design_pass_01/"
const SCENE_PATH := "res://scenes/dev/home_v3_level_design_pass_01.tscn"

var running := false
var captured := 0
@onready var world: Variant = get_parent()


func run_capture() -> void:
	if running:
		return
	running = true
	_run_sequence()


func _run_sequence() -> void:
	await get_tree().physics_frame
	await _save("01_normal_9x16.png")
	world.get_node("DebugOverlay").visible = true
	await _save("02_debug_slots_footprints_routes.png")
	world.get_node("DebugOverlay").visible = false
	world.run_v3_demo()
	if not await _wait_demo_active(world, 60):
		return _abort("multi-actor start")
	await _save("03_multi_actor_9x16.png")
	if not await _wait_demo_end(world, 2000):
		return _abort("multi-actor completion")
	if not await _capture_crowd():
		return _abort("crowd sanity")
	var worker := world.actors.get_node("Worker") as HardeningActor
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee") \
			or not await _wait_shot(world, &"brew_closeup", 700):
		return _abort("Brew Focus")
	await _save("05_brew_focus.png")
	if not await _wait_shot(world, &"cup_reveal", 700):
		return _abort("Cup Reveal")
	await _save("06_cup_reveal.png")
	if not await _wait_camera_idle(world, 500):
		return _abort("Cup camera restore")
	var cat_a := world.actors.get_node("CatA") as HardeningActor
	if not cat_a.request_interaction_on(&"cat_bed", &"rest") \
			or not await _wait_phase(cat_a, HardeningActor.Phase.ACTION, 650) \
			or not world.focus_cat(cat_a) \
			or not await _wait_shot(world, &"cat_emotion", 300):
		return _abort("Cat Emotion Focus")
	await _save("07_cat_emotion_focus.png")
	if not await _wait_camera_idle(world, 500):
		return _abort("Cat camera restore")
	world.set_event_active(true)
	var cat_c := world.actors.get_node("CatC") as HardeningActor
	if not await _wait_phase(cat_c, HardeningActor.Phase.IDLE, 300) \
			or not cat_c.request_interaction_on(&"seasonal_display", &"inspect") \
			or not await _wait_phase(cat_c, HardeningActor.Phase.ACTION, 650) \
			or not world.focus_event() \
			or not await _wait_shot(world, &"event_focus", 300):
		return _abort("Event Focus")
	await _save("08_event_state_9x16.png")
	if not await _capture_tall():
		return _abort("Tall portrait")
	print("HOME V3 PASS 01 CAPTURE COMPLETE images=%d" % captured)
	running = false


func _capture_crowd() -> bool:
	var view := _new_view(959)
	var room: Variant = view.get_child(0)
	room.run_crowd_sanity()
	for i in 1600:
		if room.crowd_phase == &"seating":
			break
		if room.crowd_phase == &"failed":
			view.queue_free()
			return false
		await get_tree().physics_frame
	if room.crowd_phase != &"seating":
		view.queue_free()
		return false
	await _save("04_crowd_five_customers.png", view)
	for i in 1600:
		if not room.crowd_running:
			break
		await get_tree().physics_frame
	var passed: bool = room.crowd_phase == &"complete"
	view.queue_free()
	return passed


func _capture_tall() -> bool:
	var view := _new_view(1168)
	var room: Variant = view.get_child(0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await _save("09_tall_phone_normal.png", view)
	var worker := room.actors.get_node("Worker") as HardeningActor
	var customer := room.actors.get_node("CustomerA") as HardeningActor
	var cat_a := room.actors.get_node("CatA") as HardeningActor
	var cat_b := room.actors.get_node("CatB") as HardeningActor
	var cat_c := room.actors.get_node("CatC") as HardeningActor
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee") \
			or not customer.request_interaction_on(&"entrance_door", &"enter") \
			or not cat_a.request_interaction_on(&"cat_bed", &"rest") \
			or not cat_b.request_interaction_on(&"plant", &"sniff") \
			or not cat_c.request_interaction_on(&"scratch_post", &"scratch"):
		view.queue_free()
		return false
	await get_tree().physics_frame
	await _save("10_tall_phone_multi_actor.png", view)
	room.set_event_active(true)
	await get_tree().physics_frame
	await _save("11_tall_phone_event.png", view)
	view.queue_free()
	return true


func _new_view(height: int) -> SubViewport:
	var view := SubViewport.new()
	view.size = Vector2i(539, height)
	view.world_2d = World2D.new()
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_tree().root.add_child(view)
	var scene: PackedScene = load(SCENE_PATH)
	var room: Variant = scene.instantiate()
	view.add_child(room)
	# Raw SubViewport does not inherit the editor game's 1152→540 stretch.
	(room.get_node("Camera") as Camera2D).zoom = Vector2(0.84, 0.84)
	return view


func _wait_demo_active(room: Variant, frames: int) -> bool:
	for i in frames:
		if room.v3_demo_running and (room.actors.get_node("CustomerA") as HardeningActor).phase \
				!= HardeningActor.Phase.IDLE:
			return true
		await get_tree().physics_frame
	return false


func _wait_demo_end(room: Variant, frames: int) -> bool:
	for i in frames:
		if not room.v3_demo_running:
			return room.all_reservations_clear()
		await get_tree().physics_frame
	return false


func _wait_phase(actor: HardeningActor, phase: int, frames: int) -> bool:
	for i in frames:
		if actor.phase == phase:
			return true
		await get_tree().physics_frame
	return false


func _wait_shot(room: Variant, id: StringName, frames: int) -> bool:
	for i in frames:
		if room.camera_director.current_shot_id == id and room.camera_director.is_holding():
			return true
		await get_tree().process_frame
	return false


func _wait_camera_idle(room: Variant, frames: int) -> bool:
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
		push_error("HOME V3 PASS 01 capture %s failed: %d" % [filename, error])
		return
	captured += 1
	print("HOME V3 PASS 01 CAPTURE %s %dx%d" % [filename, image.get_width(), image.get_height()])


func _abort(reason: String) -> void:
	push_error("HOME V3 PASS 01 CAPTURE ABORT: " + reason)
	running = false
