extends SceneTree
## Narrow snapshot gate for the accepted starter layout. Do not use this as art pixel data.

const LOCKED_SCENE := preload("res://scenes/dev/home_v3_level_design_pass_01.tscn")
const ROOTS := {
	&"counter_shell": Vector2(160, 380),
	&"espresso_station": Vector2(360, 350),
	&"grinder_station": Vector2(485, 350),
	&"pos_station": Vector2(90, 235),
	&"pastry_case": Vector2(245, 230),
	&"table_a": Vector2(210, 700),
	&"chair_a": Vector2(105, 795),
	&"chair_b": Vector2(310, 795),
	&"table_b": Vector2(445, 840),
	&"chair_c": Vector2(350, 935),
	&"chair_d": Vector2(545, 935),
	&"cat_bed": Vector2(175, 550),
	&"window_perch": Vector2(515, 520),
	&"plant": Vector2(530, 680),
	&"scratch_post": Vector2(100, 985),
	&"entrance_door": Vector2(320, 1165),
	&"seasonal_display": Vector2(510, 1105),
	&"waiting_spot": Vector2(235, 1060),
	&"waiting_spot_b": Vector2(405, 1040),
	&"waiting_spot_c": Vector2(150, 1080),
}
const FOOTPRINTS := {
	&"counter_shell": Vector2(224, 55), &"espresso_station": Vector2(73, 45),
	&"grinder_station": Vector2(48, 35), &"pos_station": Vector2(58, 30),
	&"pastry_case": Vector2(88, 32), &"table_a": Vector2(108, 80),
	&"table_b": Vector2(108, 80), &"chair_a": Vector2(48, 28),
	&"chair_b": Vector2(48, 28), &"chair_c": Vector2(48, 28),
	&"chair_d": Vector2(48, 28), &"cat_bed": Vector2(88, 41),
	&"window_perch": Vector2(86, 32), &"plant": Vector2(30, 25),
	&"scratch_post": Vector2(42, 25), &"seasonal_display": Vector2(53, 28),
}

var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := LOCKED_SCENE.instantiate() as HomeV3Pass01World
	root.add_child(world)
	await physics_frame
	await physics_frame
	var objects := {}
	_collect_objects(world, objects)
	_check(objects.size() == ROOTS.size(), "Stable-object inventory changed")
	for id in ROOTS:
		_check(objects.has(id), "Locked stable ID missing: %s" % id)
		if not objects.has(id):
			continue
		var object: HardeningWorldObject = objects[id]
		_check(object.position.is_equal_approx(ROOTS[id]) and is_zero_approx(object.rotation),
			"Locked transform changed: %s" % id)
		var footprint := object.get_node_or_null("PhysicalFootprint") as HardeningFootprint
		if FOOTPRINTS.has(id):
			_check(footprint != null and footprint.footprint_size.is_equal_approx(FOOTPRINTS[id]),
				"Locked footprint changed: %s" % id)
		else:
			_check(footprint == null, "Semantic threshold/wait gained obstruction: %s" % id)
	_check(world.navigation.walkable_bounds == Rect2(25, 100, 590, 1190),
		"Authored walkable bounds changed")
	_check(world.navigation.revision > 0 and world.all_slots(&"wait").size() == 3,
		"Navigation or distributed wait slots missing")
	var camera := world.get_node("Camera") as Camera2D
	_check(camera.position.is_equal_approx(Vector2(320, 650))
		and camera.zoom.is_equal_approx(Vector2(1.8, 1.8))
		and camera.limit_left == 0 and camera.limit_top == 0
		and camera.limit_right == 640 and camera.limit_bottom == 1320,
		"Locked room camera frame changed")
	_check(is_equal_approx(world.brew_shot_zoom, 3.25)
		and is_equal_approx(world.cup_shot_zoom, 3.45),
		"Reviewed Brew/Cup framing configuration changed")
	_check((world.get_node("DepthSortedLayer") as Node2D).y_sort_enabled,
		"Floor-contact depth sorting disabled")
	_check(_owned(objects, &"counter_shell", "OrderSlot")
		and _owned(objects, &"counter_shell", "ServeSlot")
		and _owned(objects, &"counter_shell", "VisualFrontOccluder")
		and _owned(objects, &"espresso_station", "CoffeeActionSlot")
		and _owned(objects, &"espresso_station", "CameraBrewFocus")
		and _owned(objects, &"espresso_station", "CameraCupReveal")
		and _owned(objects, &"window_perch", "CameraWindowFocus")
		and _owned(objects, &"cat_bed", "RestSlot")
		and _owned(objects, &"cat_bed", "SleepSlot")
		and _owned(objects, &"entrance_door", "EnterSlot")
		and _owned(objects, &"entrance_door", "LeaveSlot")
		and _owned(objects, &"seasonal_display", "InspectSlot")
		and _owned(objects, &"seasonal_display", "CameraEventFocus"),
		"Object-owned semantic/depth/camera children changed")
	for id in [&"chair_a", &"chair_b", &"chair_c", &"chair_d"]:
		_check(_owned(objects, id, "SeatSlot"), "Chair-owned seat missing: %s" % id)
	_check(not world.event_active and world.find_object(&"seasonal_display") == null,
		"Event should default inactive")
	world.set_event_active(true)
	_check(world.find_object(&"seasonal_display") != null,
		"Locked event object not discoverable while active")
	world.queue_free()
	await process_frame
	if _ok:
		print("--- HOME V3 LAYOUT LOCK V1 PASSED ---")
	quit(0 if _ok else 1)


func _collect_objects(node: Node, objects: Dictionary) -> void:
	if node is HardeningWorldObject:
		var object := node as HardeningWorldObject
		_check(object.stable_id != &"" and not objects.has(object.stable_id),
			"Duplicate/missing stable ID: %s" % object.stable_id)
		objects[object.stable_id] = object
	for child in node.get_children():
		_collect_objects(child, objects)


func _owned(objects: Dictionary, id: StringName, child: String) -> bool:
	return objects.has(id) and (objects[id] as Node).get_node_or_null(child) != null


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
