extends SceneTree
## Layout acceptance. Exercises the existing actor/slot contract in a different room.

const PASS_SCENE := preload("res://scenes/dev/home_v3_level_design_pass_01.tscn")

var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := PASS_SCENE.instantiate() as HomeV3Pass01World
	root.add_child(world)
	await physics_frame
	await physics_frame
	_check(world.navigation.revision > 0, "Pass 01 nav did not bake")
	_check(world.all_slots(&"sit").size() == 4, "Four authored seats missing")
	_check(world.all_slots(&"wait").size() == 3, "Three distributed waiting pockets missing")
	_check(world.find_object(&"cat_bed").global_position.y < 800.0,
		"CatBed is still isolated in the lower cat band")
	_check(world.find_object(&"window_perch").global_position.x > 450.0,
		"WindowPerch left its window corner")
	_check(world.find_object(&"seasonal_display") == null,
		"Inactive event object should not be discoverable")
	_check(await world.run_v3_demo(), "Two-customer / three-cat semantic demo failed")
	_check(world.all_reservations_clear() and world._extra_reservations_clear(),
		"Normal demo leaked reservations")
	var camera := world.get_node("Camera") as Camera2D
	var original_position := camera.global_position
	var original_zoom := camera.zoom
	var worker := world.actors.get_node("Worker") as HardeningActor
	_check(worker.request_interaction_on(&"espresso_station", &"work_coffee"),
		"Worker could not reach Pass 01 coffee station")
	_check(await _wait_shot(world, &"brew_closeup", 700), "Pass 01 Brew shot missing")
	_check(await _wait_shot(world, &"cup_reveal", 700), "Pass 01 Cup shot missing")
	await _wait_camera_idle(world, 500)
	_check(camera.global_position.is_equal_approx(original_position)
		and camera.zoom.is_equal_approx(original_zoom), "Coffee shots did not restore camera")
	var cat_a := world.actors.get_node("CatA") as HardeningActor
	_check(world.focus_cat(cat_a), "Pass 01 Cat Emotion shot missing")
	_check(await _wait_shot(world, &"cat_emotion", 300), "Cat Emotion did not hold")
	await _wait_camera_idle(world, 500)
	_check(camera.global_position.is_equal_approx(original_position)
		and camera.zoom.is_equal_approx(original_zoom), "Cat shot did not restore camera")
	world.set_event_active(true)
	_check(world.focus_event(), "Pass 01 Event shot missing")
	_check(await _wait_shot(world, &"event_focus", 300), "Event Focus did not hold")
	await _wait_camera_idle(world, 500)
	_check(camera.global_position.is_equal_approx(original_position)
		and camera.zoom.is_equal_approx(original_zoom), "Event shot did not restore camera")
	world.queue_free()
	await process_frame

	world = PASS_SCENE.instantiate() as HomeV3Pass01World
	root.add_child(world)
	await physics_frame
	await physics_frame
	_check(await world.run_crowd_sanity(), "Five-customer crowd sanity failed")
	await process_frame
	_check(world.crowd_rejections["entrance"] and world.crowd_rejections["order"]
		and world.crowd_rejections["seat"], "Crowd capacity gates did not reject contention")
	_check(world.crowd_trace.has(&"five_customers_three_cats_one_worker")
		and world.crowd_trace.has(&"five_exits_clear"), "Crowd entry/exit trace incomplete")
	_check(world.all_reservations_clear() and world._extra_reservations_clear(),
		"Crowd leaked reservations")
	_check(world.actors.get_child_count() == 6, "Temporary crowd actors were not removed")
	world.set_event_active(true)
	_check(world.find_object(&"seasonal_display") != null and world.all_slots(&"inspect").size() == 1,
		"Event niche failed semantic activation")
	var chair := world.find_object(&"chair_a")
	var bed := world.find_object(&"cat_bed")
	for entry in [[chair, &"chair_a", Vector2(9, 8), 0.08],
			[bed, &"cat_bed", Vector2(12, -6), -0.07]]:
		var object: HardeningWorldObject = entry[0]
		var id: StringName = entry[1]
		var new_position: Vector2 = object.global_position + entry[2]
		var new_rotation: float = entry[3]
		var action_anchor := object.get_node("SeatSlot/ActionAnchor" if id == &"chair_a"
			else "RestSlot/ActionAnchor") as Marker2D
		var local_anchor := object.to_local(action_anchor.global_position)
		_check(world.validate_placement(id, new_position, new_rotation),
			"Pass 01 placement rejected movable %s" % id)
		_check(world.place_object(id, new_position, new_rotation),
			"Pass 01 placement failed movable %s" % id)
		_check(action_anchor.global_position.is_equal_approx(object.to_global(local_anchor)),
			"Owned slot detached when %s moved" % id)
	var customer_a := world.actors.get_node("CustomerA") as HardeningActor
	cat_a = world.actors.get_node("CatA") as HardeningActor
	_check(customer_a.request_interaction_on(&"chair_a", &"sit")
		and cat_a.request_interaction_on(&"cat_bed", &"rest"),
		"Actors could not reacquire moved chair/bed")
	_check(await _wait_actor_idle(customer_a, 700) and await _wait_actor_idle(cat_a, 700),
		"Moved furniture produced invalid actor route")
	_check(not customer_a.failed_navigation and not cat_a.failed_navigation,
		"Actor navigation failed after furniture move")
	world.queue_free()
	await process_frame
	if _ok:
		print("--- HOME V3 LEVEL DESIGN PASS 01 PASSED ---")
	quit(0 if _ok else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)


func _wait_shot(world: HomeV3Pass01World, id: StringName, frames: int) -> bool:
	for i in frames:
		if world.camera_director.current_shot_id == id and world.camera_director.is_holding():
			return true
		await process_frame
	return false


func _wait_camera_idle(world: HomeV3Pass01World, frames: int) -> void:
	for i in frames:
		if world.camera_director.mode == HardeningCameraDirector.Mode.GAMEPLAY:
			return
		await process_frame
	_check(false, "Pass 01 camera failed to restore")


func _wait_actor_idle(actor: HardeningActor, frames: int) -> bool:
	for i in frames:
		if actor.phase == HardeningActor.Phase.IDLE:
			return true
		await physics_frame
	return false
