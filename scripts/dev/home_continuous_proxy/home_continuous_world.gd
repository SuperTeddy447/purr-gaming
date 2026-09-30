class_name HomeContinuousWorld
extends PlaceholderCafe
## One shared Home map. The successful proxy café remains the gameplay core.

const SAVE_PATH := "user://willicat_home_continuous_v1.save"
const SAVE_SCHEMA := 1
@export var autoplay_route := true

var session: Dictionary = {}
var current_area: StringName = &"cafe"
var area_states: Dictionary = {}
var route_active := false
var route_succeeded := false
var route_step := ""
var route_error := ""
var last_sniff_completed := false
var decoration_mode := false
var _moving: HardeningWorldObject
var _move_origin := Vector2.ZERO
var _move_rotation := 0.0
var _move_offset := Vector2.ZERO
var _view_mode := &"default"
var _status: Label
var _reward: Label
var _visitor: HardeningActor
var _cat: HardeningActor


func _ready() -> void:
	super._ready()
	_visitor = actors.get_node("Visitor") as HardeningActor
	_cat = actors.get_node("Cat") as HardeningActor
	_cat.action_completed.connect(_on_cat_action_completed)
	phase_changed.connect(_on_phase_changed)
	reward_earned.connect(_on_reward_earned)
	visit_completed.connect(_on_visit_completed)
	session = {
		"save_schema_version": SAVE_SCHEMA,
		"world_id": "willicat_home_continuous_v1",
		"location_id": "home",
		"current_area": "cafe",
		"character_position": _visitor.position,
		"cat_position": _cat.position,
		"cat_activity": "idle",
		"furniture_deltas": {},
		"coins": 0,
		"next_order_seq": 1,
		"rewarded_orders": [],
		"unlocked_room_ids": ["home_cafe_main"],
	}
	camera_input.input_enabled = false
	$Camera.global_position = _visitor.global_position + Vector2(0, -120)
	$Camera.zoom = Vector2.ONE * 1.6
	_clamp_gameplay_camera()
	_build_hud()
	_update_area()
	if autoplay_route:
		_start_route_deferred.call_deferred()


func _process(delta: float) -> void:
	if _visitor == null:
		return
	_update_area()
	if _view_mode == &"overview" or camera_director.mode != HardeningCameraDirector.Mode.GAMEPLAY:
		return
	var target_zoom := 1.6 if current_area == &"cafe" else 1.35
	var factor := 1.0 - exp(-4.0 * delta)
	$Camera.global_position = $Camera.global_position.lerp(_visitor.global_position + Vector2(0, -105), factor)
	$Camera.zoom = $Camera.zoom.lerp(Vector2.ONE * target_zoom, factor)
	_clamp_gameplay_camera()


func _clamp_gameplay_camera() -> void:
	var camera := $Camera as Camera2D
	var half: Vector2 = camera.get_viewport_rect().size * 0.5 / camera.zoom
	var center: Vector2 = room_bounds.get_center()
	var min_pos: Vector2 = room_bounds.position + half
	var max_pos: Vector2 = room_bounds.end - half
	camera.global_position = Vector2(
		clampf(camera.global_position.x, min_pos.x, max_pos.x) if min_pos.x <= max_pos.x else center.x,
		clampf(camera.global_position.y, min_pos.y, max_pos.y) if min_pos.y <= max_pos.y else center.y)


func _area_for(point: Vector2) -> StringName:
	if point.y < 0.0:
		return &"back_garden"
	if point.x < 0.0:
		return &"riverside"
	if point.y >= 1024.0:
		return &"front_plaza"
	return &"cafe"


func _update_area() -> void:
	var next := _area_for(_visitor.global_position)
	if next == current_area and not area_states.is_empty():
		return
	current_area = next
	var adjacent := {
		"cafe": ["front_plaza", "back_garden"],
		"front_plaza": ["cafe", "riverside"],
		"riverside": ["front_plaza"],
		"back_garden": ["cafe"],
	}
	for key in adjacent:
		area_states[key] = "active" if key == String(current_area) else \
			("near" if adjacent[String(current_area)].has(key) else "dormant")
	if _status != null:
		_set_status(route_step if route_active else "Walk by clicking, or run the route")


func _build_hud() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	$HUD.add_child(panel)
	var stack := VBoxContainer.new()
	panel.add_child(stack)
	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 19)
	stack.add_child(_status)
	var first := HBoxContainer.new()
	stack.add_child(first)
	_add_button(first, "ROUTE", run_required_route)
	_add_button(first, "LOOP", start_customer_loop)
	_add_button(first, "SNIFF", trigger_garden_sniff)
	_add_button(first, "SAVE", save_game)
	_add_button(first, "LOAD", load_game)
	_add_button(first, "MOVE", toggle_decoration)
	var second := HBoxContainer.new()
	stack.add_child(second)
	_add_button(second, "OVERVIEW", overview)
	_add_button(second, "DEFAULT", gameplay_view)
	_add_button(second, "FOCUS", focus_tree)
	_reward = Label.new()
	stack.add_child(_reward)
	_set_status("Walk by clicking, or run the route")


func _add_button(parent: Node, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(68, 52)
	button.add_theme_font_size_override("font_size", 15)
	button.pressed.connect(action)
	parent.add_child(button)


func _set_status(value: String) -> void:
	if _status != null:
		_status.text = "HOME · %s · %s" % [String(current_area).replace("_", " ").capitalize(), value]
	print("HOME %s: %s" % [current_area, value])


func overview() -> void:
	_view_mode = &"overview"
	$Camera.global_position = Vector2(192, 540)
	$Camera.zoom = Vector2.ONE * 0.48


func gameplay_view() -> void:
	_view_mode = &"default"
	$Camera.global_position = _visitor.global_position + Vector2(0, -105)
	$Camera.zoom = Vector2.ONE * (1.6 if current_area == &"cafe" else 1.35)
	_clamp_gameplay_camera()


func focus_tree() -> void:
	var target_tree := find_object(&"river_depth_tree") as Node2D
	if target_tree == null:
		return
	var focus := target_tree.get_node_or_null("CameraDepthFocus") as Marker2D
	if focus == null:
		focus = Marker2D.new()
		focus.name = "CameraDepthFocus"
		focus.position = Vector2(0, -95)
		target_tree.add_child(focus)
	var shot := HardeningCameraShot.new()
	shot.shot_id = &"animated_tree_depth"
	shot.zoom = 1.2
	shot.hold_duration = 1.1
	camera_director.request_shot(focus, shot)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R: run_required_route()
			KEY_S: save_game()
			KEY_L: load_game()
			KEY_F8: toggle_decoration()
			KEY_ESCAPE: _cancel_move()
			KEY_1: overview()
			KEY_2: gameplay_view()
		return
	if route_active or _visitor.phase != HardeningActor.Phase.IDLE:
		return
	if decoration_mode:
		_handle_furniture_drag(event)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_walk_to_click(get_canvas_transform().affine_inverse() * event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_walk_to_click(get_canvas_transform().affine_inverse() * event.position)


func toggle_decoration() -> void:
	if route_active:
		return
	decoration_mode = not decoration_mode
	if not decoration_mode:
		_cancel_move()
	_set_status("MOVE: drag a table/chair; release to confirm" if decoration_mode else "MOVE off")


func _cancel_move() -> void:
	if _moving == null:
		return
	_moving.global_position = _move_origin
	_moving.global_rotation = _move_rotation
	_moving = null


func _pick_furniture(point: Vector2) -> HardeningWorldObject:
	var best: HardeningWorldObject
	var best_distance := INF
	for child in objects.get_children():
		if not child is HardeningWorldObject or String(child.kind) not in ["table", "chair"]:
			continue
		var candidate := child as HardeningWorldObject
		var footprint := candidate.get_node_or_null("PhysicalFootprint") as HardeningFootprint
		if footprint == null or not footprint.global_bounds().grow(18).has_point(point):
			continue
		var distance := candidate.global_position.distance_to(point)
		if distance < best_distance:
			best = candidate
			best_distance = distance
	return best


func _handle_furniture_drag(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_move(get_canvas_transform().affine_inverse() * event.position)
		else:
			_finish_move()
	elif event is InputEventMouseMotion and _moving != null:
		_moving.global_position = get_canvas_transform().affine_inverse() * event.position + _move_offset
	elif event is InputEventScreenTouch:
		if event.pressed:
			_begin_move(get_canvas_transform().affine_inverse() * event.position)
		else:
			_finish_move()
	elif event is InputEventScreenDrag and _moving != null:
		_moving.global_position = get_canvas_transform().affine_inverse() * event.position + _move_offset


func _begin_move(point: Vector2) -> void:
	_moving = _pick_furniture(point)
	if _moving != null:
		_move_origin = _moving.global_position
		_move_rotation = _moving.global_rotation
		_move_offset = _moving.global_position - point


func _finish_move() -> void:
	if _moving == null:
		return
	var item := _moving
	var candidate := item.global_position
	item.global_position = _move_origin
	item.global_rotation = _move_rotation
	_moving = null
	_set_status("Moved furniture" if confirm_furniture_move(item.stable_id, candidate, _move_rotation)
		else "Invalid furniture placement")


func _walk_to_click(point: Vector2) -> void:
	if not room_bounds.has_point(point) or point.x < -640.0:
		return
	var target := $Spawns.get_node_or_null("TapTarget") as Marker2D
	if target == null:
		target = Marker2D.new()
		target.name = "TapTarget"
		$Spawns.add_child(target)
	target.global_position = point
	_visitor.navigate_to_marker(target)


func _start_route_deferred() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	run_required_route()


func run_required_route() -> bool:
	if route_active or loop_active or _visitor.phase != HardeningActor.Phase.IDLE:
		return false
	_cancel_move()
	decoration_mode = false
	route_active = true
	route_succeeded = false
	route_error = ""
	last_sniff_completed = false
	_run_route_sequence()
	return true


func _run_route_sequence() -> void:
	var legs := [
		"front_threshold", "front_plaza", "river_front_depth", "river_behind_depth",
		"riverside", "return_plaza", "cafe_return", "rear_threshold", "back_garden",
	]
	for leg in legs:
		if not await _walk_leg(leg):
			_fail_route("Could not reach " + leg)
			return
	if not trigger_garden_sniff():
		_fail_route("Garden sniff was rejected")
		return
	for frame in 900:
		await get_tree().physics_frame
		if last_sniff_completed:
			break
	if not last_sniff_completed:
		_fail_route("Garden sniff did not complete")
		return
	if not await _walk_leg("final_cafe"):
		_fail_route("Could not return through rear door")
		return
	if not start_customer_loop():
		_fail_route("Customer loop did not start")
		return
	for frame in 5000:
		await get_tree().physics_frame
		if not loop_active:
			break
	if loop_active or int(session["coins"]) < 1:
		_fail_route("Customer loop did not complete")
		return
	if not save_game() or not load_game():
		_fail_route("Save/load failed")
		return
	route_succeeded = current_area == &"cafe" and int(session["coins"]) >= 1
	route_active = false
	route_step = "Proof complete" if route_succeeded else "Proof state mismatch"
	_set_status(route_step)


func _walk_leg(id: String) -> bool:
	var marker := $Spawns.get_node_or_null(id) as Marker2D
	if marker == null:
		return false
	route_step = "Walking to " + id.replace("_", " ")
	_set_status(route_step)
	if not _visitor.navigate_to_marker(marker):
		return false
	for frame in 1800:
		await get_tree().physics_frame
		if _visitor.phase == HardeningActor.Phase.IDLE:
			return not _visitor.failed_navigation and _visitor.global_position.distance_to(marker.global_position) <= 12.0
	_visitor.cancel_action(&"route_timeout")
	return false


func _fail_route(reason: String) -> void:
	route_error = reason
	route_active = false
	route_succeeded = false
	_set_status("Route failed: " + reason)
	push_error("HOME route failed: " + reason)


func trigger_garden_sniff() -> bool:
	if current_area != &"back_garden":
		_set_status("Walk to the Back Garden to sniff plants")
		return false
	if _cat.phase != HardeningActor.Phase.IDLE:
		return false
	session["cat_activity"] = "sniff"
	var accepted := _cat.request_interaction_on(&"cat_sniff", &"sniff")
	if accepted:
		_set_status("Mochi sniffs the Garden plants")
	return accepted


func _on_cat_action_completed(slot: HardeningInteractionSlot) -> void:
	if slot.action_type == &"sniff":
		last_sniff_completed = true
		session["cat_activity"] = "idle"
		_set_status("Garden sniff complete")


func start_customer_loop() -> bool:
	if loop_active:
		return false
	var order_id := "order_%d" % int(session["next_order_seq"])
	session["next_order_seq"] += 1
	_run_customer_loop(order_id)
	return true


func _run_customer_loop(order_id: String) -> void:
	await run_coffee_loop(order_id)


func _on_phase_changed(label: String) -> void:
	_set_status(label)


func _on_reward_earned(order_id: String) -> void:
	var receipts: Array = session["rewarded_orders"]
	if receipts.has(order_id):
		return
	receipts.append(order_id)
	session["coins"] = int(session["coins"]) + 1
	if not session["unlocked_room_ids"].has("home_cafe_garden"):
		session["unlocked_room_ids"].append("home_cafe_garden")
	_reward.text = "+1 COIN · café service preserved"
	_set_status("Order complete")


func _on_visit_completed(success: bool) -> void:
	if not success:
		_set_status("Customer visit failed")


func confirm_furniture_move(id: StringName, candidate: Vector2, angle: float) -> bool:
	var object := find_object(id)
	if object == null:
		return false
	var previous_position := object.global_position
	var previous_angle := object.global_rotation
	if not super.confirm_furniture_move(id, candidate, angle):
		return false
	if _required_routes_exist() and _required_home_routes_exist():
		return true
	object.global_position = previous_position
	object.global_rotation = previous_angle
	rebuild_navigation()
	return false


func _required_home_routes_exist() -> bool:
	NavigationServer2D.map_force_update(navigation.get_navigation_map())
	for pair in [
		["cafe_start", "front_plaza"],
		["front_plaza", "riverside"],
		["cafe_return", "back_garden"],
	]:
		var start := spawn(StringName(pair[0]))
		var finish := spawn(StringName(pair[1]))
		if start == null or finish == null:
			return false
		var path := NavigationServer2D.map_get_path(navigation.get_navigation_map(),
			start.global_position, finish.global_position, true)
		if path.size() < 2 or path[-1].distance_to(finish.global_position) > 18.0:
			return false
	return true


func _snapshot() -> Dictionary:
	return {
		"save_schema_version": SAVE_SCHEMA,
		"world_id": "willicat_home_continuous_v1",
		"location_id": "home",
		"current_area": String(current_area),
		"character_position": _visitor.global_position,
		"cat_position": _cat.global_position,
		"cat_activity": String(session["cat_activity"]),
		"furniture_deltas": furniture_overrides(),
		"coins": int(session["coins"]),
		"next_order_seq": int(session["next_order_seq"]),
		"rewarded_orders": session["rewarded_orders"].duplicate(),
		"unlocked_room_ids": session["unlocked_room_ids"].duplicate(),
	}


func _valid_snapshot(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var data: Dictionary = value
	if data.get("save_schema_version") != SAVE_SCHEMA or \
			data.get("world_id") != "willicat_home_continuous_v1" or \
			data.get("location_id") != "home" or \
			not data.get("character_position") is Vector2 or \
			not data.get("cat_position") is Vector2 or \
			not data.get("furniture_deltas") is Dictionary or \
			not data.get("rewarded_orders") is Array or \
			not data.get("unlocked_room_ids") is Array or \
			not data.get("coins") is int or \
			not data.get("next_order_seq") is int:
		return false
	return String(data.get("current_area", "")) == String(_area_for(data["character_position"]))


func save_game(path: String = SAVE_PATH) -> bool:
	if loop_active or _visitor.phase != HardeningActor.Phase.IDLE or \
			_cat.phase != HardeningActor.Phase.IDLE:
		return false
	var snapshot := _snapshot()
	if not _valid_snapshot(snapshot):
		return false
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_var(snapshot, false)
	file.close()
	var check := FileAccess.open(temp, FileAccess.READ)
	if check == null:
		return false
	var round_trip = check.get_var(false)
	check.close()
	if not _valid_snapshot(round_trip) or round_trip != snapshot:
		return false
	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(path + ".bak"))
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(path)) != OK:
		return false
	session = snapshot
	_set_status("Saved Home / %s" % current_area)
	return true


func load_game(path: String = SAVE_PATH) -> bool:
	if loop_active or _visitor.phase != HardeningActor.Phase.IDLE or _cat.phase != HardeningActor.Phase.IDLE:
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var incoming = file.get_var(false)
	file.close()
	if not _valid_snapshot(incoming):
		return false
	for id in _baseline_furniture:
		var object := find_object(StringName(id))
		if object == null:
			continue
		var record: Dictionary = _baseline_furniture[id]
		object.position = Vector2(float(record["x"]), float(record["y"]))
		object.rotation = float(record["angle"])
	apply_overrides(incoming["furniture_deltas"])
	_visitor.global_position = incoming["character_position"]
	_cat.global_position = incoming["cat_position"]
	session = incoming
	_update_area()
	gameplay_view()
	_set_status("Loaded Home / %s" % current_area)
	return true
