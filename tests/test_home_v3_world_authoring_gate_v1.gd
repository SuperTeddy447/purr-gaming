extends SceneTree
## New-room authoring gate: all positions are scene data, not actor behavior.

const LAB := preload("res://scenes/dev/home_v3_world_authoring_lab.tscn")

var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := LAB.instantiate() as HomeV3World
	root.add_child(world)
	await physics_frame
	await physics_frame
	var ids := {}
	_collect_ids(world.objects, ids)
	_check(ids.size() >= 17, "Home V3 has too few authored world objects")
	_check(world.find_object(&"table_a") != null and world.find_object(&"table_b") != null,
		"Two separate table instances missing")
	_check(world.all_slots(&"sit").size() == 4, "Four chair seat slots missing")
	for action in [&"order", &"serve", &"work_coffee", &"grind", &"operate_pos",
			&"browse", &"enter", &"leave", &"story", &"wait", &"rest", &"sleep",
			&"watch", &"sniff", &"scratch"]:
		_check(not world.all_slots(action).is_empty(), "Missing semantic slot %s" % action)
	var customer_a := world.actors.get_node("CustomerA") as HardeningActor
	var customer_b := world.actors.get_node("CustomerB") as HardeningActor
	var worker := world.actors.get_node("Worker") as HardeningActor
	var cat_a := world.actors.get_node("CatA") as HardeningActor
	var cat_b := world.actors.get_node("CatB") as HardeningActor
	var cat_c := world.actors.get_node("CatC") as HardeningActor
	var seat := world.find_object(&"chair_a").get_node("SeatSlot") as HardeningInteractionSlot
	_check(seat.reserve(customer_a) and not seat.reserve(customer_b),
		"Capacity-1 Chair A double-reservation accepted")
	seat.release(customer_a)
	_check(seat.use_count() == 0, "Chair A reservation did not release")
	_check(not world.find_slot_on_object(&"espresso_station", &"work_coffee").reserve(cat_a),
		"Cat reserved worker-only coffee slot")

	var table_foot := world.find_object(&"table_a").get_node("PhysicalFootprint") as HardeningFootprint
	var route_start := Vector2(180, 800)
	var route_end := Vector2(180, 420)
	var path := PackedVector2Array()
	for frame in 30:
		path = NavigationServer2D.map_get_path(world.navigation.get_navigation_map(),
			route_start, route_end, true)
		if path.size() >= 3:
			break
		await physics_frame
	_check(path.size() >= 3, "Table A did not bend navigation path")
	for i in range(1, path.size()):
		_check(not _segment_enters_rect(path[i - 1], path[i], table_foot.global_bounds()),
			"Server path crosses Table A physical footprint")
	var cat_start := cat_a.global_position
	cat_a.global_position = route_start
	var target := Marker2D.new()
	world.add_child(target)
	target.global_position = route_end
	_check(cat_a.navigate_to_marker(target), "Cat could not begin furniture avoidance route")
	await _wait_actor_idle(cat_a, 600)
	_check(not cat_a.failed_navigation, "Cat failed route around table")
	for point in cat_a.path_trace:
		_check(not table_foot.global_bounds().has_point(point),
			"Actor feet entered table footprint")
	cat_a.global_position = cat_start
	target.queue_free()

	_check(await world.run_v3_demo(), "Home V3 semantic daily-life demo failed")
	_check(world.v3_trace.count(&"enter") == 2 and world.v3_trace.count(&"order") == 2
		and world.v3_trace.count(&"sit") == 2 and world.v3_trace.count(&"leave") == 2,
		"Both customers did not enter/order/sit/leave")
	_check(world.v3_trace.has(&"work_coffee") and world.v3_trace.has(&"serve"),
		"Worker did not coffee/serve")
	_check(cat_a.last_action == &"rest" and cat_b.last_action == &"sniff"
		and cat_c.last_action == &"scratch", "Three cats did not use different life slots")
	_check(world.all_reservations_clear(), "Base slots leaked after demo")
	_check(world.find_object(&"entrance_door").get_node("DoorStoryPoint") is Marker2D,
		"Door story location missing")
	_check(cat_c.request_interaction_on(&"window_perch", &"watch"),
		"WindowWatch interaction could not be acquired")
	await _wait_actor_idle(cat_c, 650)
	_check(not cat_c.failed_navigation and cat_c.last_action == &"watch",
		"Cat did not use WindowPerch")

	var counter := world.find_object(&"counter_shell")
	var order_before := (counter.get_node("OrderPoint") as Marker2D).global_position
	var moved_cases := [
		[&"chair_a", Vector2(93, 625), PI / 12.0,
			["SeatSlot/ActionAnchor", "PhysicalFootprint"]],
		[&"cat_bed", Vector2(125, 875), -PI / 14.0,
			["RestSlot/ActionAnchor", "SleepFXAnchor", "PhysicalFootprint"]],
		[&"plant", Vector2(550, 930), PI / 8.0,
			["SniffSlot/ActionAnchor", "PhysicalFootprint"]],
		[&"espresso_station", Vector2(360, 285), -PI / 16.0,
			["CoffeeActionSlot/ActionAnchor", "PhysicalFootprint", "SteamFXAnchor",
			"BrewFXAnchor", "CupRevealFXAnchor", "CameraBrewFocus", "CameraCupReveal"]],
	]
	for data in moved_cases:
		var object: HardeningWorldObject = world.find_object(data[0])
		var old_global: Vector2 = object.global_position
		var local_points := {}
		for path_name in data[3]:
			var part := object.get_node(path_name) as Node2D
			local_points[path_name] = object.to_local(part.global_position)
		_check(world.validate_placement(data[0], data[1], data[2]),
			"Valid placement rejected for %s" % data[0])
		var revision := world.navigation.revision
		_check(world.place_object(data[0], data[1], data[2]),
			"Rotated placement failed for %s" % data[0])
		await physics_frame
		_check(world.navigation.revision > revision and world.find_object(data[0]) == object,
			"Navigation/semantic lookup did not update after move %s" % data[0])
		_check(not object.global_position.is_equal_approx(old_global),
			"Object did not move %s" % data[0])
		for path_name in data[3]:
			var part := object.get_node(path_name) as Node2D
			_check(part.global_position.is_equal_approx(object.to_global(local_points[path_name])),
				"Owned anchor/footprint drifted after move %s/%s" % [data[0], path_name])
	_check((counter.get_node("OrderPoint") as Marker2D).global_position.is_equal_approx(order_before),
		"Counter customer-facing semantics moved with Espresso")
	_check(not world.validate_placement(&"chair_a", world.find_object(&"table_a").global_position),
		"Placement accepted furniture overlap")
	var snapshot := world.placement_snapshot()
	_check(snapshot.size() >= ids.size(), "Stable-ID placement snapshot incomplete")

	var camera := world.get_node("Camera") as Camera2D
	var hud := world.get_node("HUD/Status") as Control
	var hud_position := hud.position
	await _wait_camera_idle(world, 400)
	camera.global_position = Vector2(332, 660)
	camera.zoom = Vector2(1.12, 1.12)
	var before_position := camera.global_position
	var before_zoom := camera.zoom
	_check(worker.request_interaction_on(&"espresso_station", &"work_coffee"),
		"Worker could not reacquire moved EspressoStation")
	_check(await _wait_shot(world, &"brew_closeup", 700), "Brew Focus missing")
	_check(not world.camera_input.pan_by(Vector2(15, 0))
		and not world.camera_input.zoom_by(1.1), "Input fought CameraDirector")
	_check(world.find_object(&"espresso_station").get_node("BrewFXAnchor/Preview").visible,
		"Object-owned BrewFX did not activate")
	_check(await _wait_shot(world, &"cup_reveal", 700), "Cup Reveal missing")
	_check(world.find_object(&"espresso_station").get_node("CupRevealFXAnchor/Preview").visible,
		"Object-owned CupRevealFX did not activate")
	await _wait_camera_idle(world, 400)
	_check(camera.global_position.is_equal_approx(before_position)
		and camera.zoom.is_equal_approx(before_zoom) and world.camera_input.input_enabled,
		"Gameplay camera did not restore exactly")
	_check(hud.position.is_equal_approx(hud_position), "CanvasLayer HUD moved with camera")
	await _wait_actor_idle(worker, 150)
	_check(customer_a.request_interaction_on(&"chair_a", &"sit")
		and cat_a.request_interaction_on(&"cat_bed", &"sleep")
		and cat_b.request_interaction_on(&"plant", &"sniff"),
		"Actors could not reacquire moved Chair/Bed/Plant")
	await _wait_actor_idle(customer_a, 700)
	await _wait_actor_idle(cat_a, 700)
	await _wait_actor_idle(cat_b, 700)
	_check(not customer_a.failed_navigation and not cat_a.failed_navigation
		and not cat_b.failed_navigation, "Move left an actor with invalid route")

	var heart := cat_a.get_node("HeartFX") as Marker2D
	var purr := cat_a.get_node("PurrFX") as Marker2D
	var heart_before := heart.global_position
	var purr_before := purr.global_position
	cat_a.global_position += Vector2(12, -5)
	_check(heart.global_position.is_equal_approx(heart_before + Vector2(12, -5))
		and purr.global_position.is_equal_approx(purr_before + Vector2(12, -5)),
		"Character-owned Heart/Purr FX did not follow cat")
	_check(world.focus_cat(cat_a), "Cat Emotion Focus failed")
	_check(heart.get_node("Preview").visible and purr.get_node("Preview").visible,
		"Cat emotion placeholder FX did not activate")
	await _wait_camera_idle(world, 400)
	_check(camera.global_position.is_equal_approx(before_position)
		and camera.zoom.is_equal_approx(before_zoom), "Cat focus did not restore camera")
	_check(not heart.get_node("Preview").visible and not purr.get_node("Preview").visible,
		"Cat emotion FX did not clear")

	world.set_event_active(true)
	var display := world.find_object(&"seasonal_display")
	var fx := display.get_node("FXAnchor/EventFX") as Node2D
	var fx_before := fx.global_position
	var display_before := display.global_position
	_check(world.move_object(&"seasonal_display", display_before + Vector2(-18, -15)),
		"Event object could not move")
	await physics_frame
	_check(fx.global_position.is_equal_approx(fx_before + Vector2(-18, -15)),
		"Event FX did not follow its object")
	_check(cat_c.request_interaction_on(&"seasonal_display", &"inspect"),
		"Event interaction missing")
	_check(world.focus_event(), "Event CameraFocus missing")
	await _wait_camera_idle(world, 400)
	await _wait_actor_idle(cat_c, 500)
	_check(world.all_reservations_clear(), "Event interaction left stale reservation")

	for viewport_height in [959, 1168]:
		var top_world := 190.0
		var bottom_world := 1126.0
		var zoom := 0.85
		var top_screen := (top_world - 650.0) * zoom + float(viewport_height) * 0.5
		var bottom_screen := (bottom_world - 650.0) * zoom + float(viewport_height) * 0.5
		_check(top_screen > 56.0 and bottom_screen < float(viewport_height) - 56.0,
			"Important interactions entered top/bottom safe area at %d" % viewport_height)
	world.queue_free()
	await process_frame
	if _ok:
		print("--- HOME V3 WORLD AUTHORING GATE V1 PASSED ---")
	quit(0 if _ok else 1)


func _collect_ids(node: Node, found: Dictionary) -> void:
	if node is HardeningWorldObject:
		var object := node as HardeningWorldObject
		_check(object.stable_id != &"" and not found.has(object.stable_id),
			"Missing/duplicate stable object ID %s" % object.stable_id)
		found[object.stable_id] = true
	for child in node.get_children():
		_collect_ids(child, found)


func _wait_actor_idle(actor: HardeningActor, frames: int) -> void:
	for i in frames:
		if actor.phase == HardeningActor.Phase.IDLE:
			return
		await physics_frame
	_check(false, "Actor timed out %s" % actor.name)


func _wait_shot(world: HomeV3World, id: StringName, frames: int) -> bool:
	for i in frames:
		if world.camera_director.current_shot_id == id and world.camera_director.is_holding():
			return true
		await process_frame
	return false


func _wait_camera_idle(world: HomeV3World, frames: int) -> void:
	for i in frames:
		if world.camera_director.mode == HardeningCameraDirector.Mode.GAMEPLAY:
			return
		await process_frame
	_check(false, "CameraDirector did not restore")


func _segment_enters_rect(a: Vector2, b: Vector2, rect: Rect2) -> bool:
	var steps := maxi(1, ceili(a.distance_to(b) / 2.0))
	for i in range(steps + 1):
		if rect.has_point(a.lerp(b, float(i) / float(steps))):
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
