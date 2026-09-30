class_name PlaceholderWorld
extends Node2D
## Dev-only two-room proof. Authored room scenes own all world coordinates.

const CAFE_SCENE: PackedScene = preload("res://scenes/dev/playable_placeholder/main_cafe.tscn")
const GARDEN_SCENE: PackedScene = preload("res://scenes/dev/playable_placeholder/back_garden.tscn")
const SAVE_PATH := "user://willicat_placeholder_reset_v1.save"
const SCHEMA := 1

var session: Dictionary = {}
var room: PlaceholderRoom
var decoration_mode := false
var _moving: HardeningWorldObject
var _move_origin := Vector2.ZERO
var _move_rotation := 0.0
var _move_offset := Vector2.ZERO
var _tap_start := Vector2.ZERO
var _tap_active := false
var _tap_cancelled := false
var _touch_count := 0
var _status: Label
var _reward_label: Label


func _ready() -> void:
	session = _fresh_session()
	_build_hud()
	_activate_room(&"home_cafe_main", &"customer_entry")
	_start_initial_loop.call_deferred()


func _fresh_session() -> Dictionary:
	return {
		"save_schema_version": SCHEMA,
		"world_id": "willicat_placeholder_world",
		"location_id": "home_cafe",
		"active_room_id": "home_cafe_main",
		"entry_spawn_id": "customer_entry",
		"unlocked_room_ids": ["home_cafe_main"],
		"room_deltas": {},
		"cats": {"mochi": {"room_id": "home_cafe_main", "activity_id": "idle"}},
		"coins": 0,
		"next_order_seq": 1,
		"rewarded_orders": [],
	}


func _start_initial_loop() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	start_loop()


func _scene_for(room_id: StringName) -> PackedScene:
	match room_id:
		&"home_cafe_main": return CAFE_SCENE
		&"home_cafe_garden": return GARDEN_SCENE
	return null


func _capture_room_delta() -> void:
	if room == null:
		return
	var deltas: Dictionary = session["room_deltas"]
	deltas[String(room.room_id)] = room.furniture_overrides()


func _activate_room(room_id: StringName, spawn_id: StringName) -> bool:
	var packed := _scene_for(room_id)
	if packed == null or not session["unlocked_room_ids"].has(String(room_id)):
		return false
	var candidate := packed.instantiate() as PlaceholderRoom
	if candidate == null:
		return false
	if candidate.spawn(spawn_id) == null:
		candidate.free()
		return false
	if room != null:
		room.get_parent().remove_child(room)
		room.queue_free()
	$RoomHost.add_child(candidate)
	room = candidate
	room.apply_overrides(session["room_deltas"].get(String(room_id), {}))
	session["active_room_id"] = String(room_id)
	session["entry_spawn_id"] = String(spawn_id)
	var cat := room.actors.get_node_or_null("Cat") as HardeningActor
	if cat != null:
		cat.visible = session["cats"]["mochi"]["room_id"] == String(room_id)
		cat.collision_layer = 4 if cat.visible else 0
		if cat.visible and room.spawn(&"cat_entry") != null:
			cat.global_position = room.spawn(&"cat_entry").global_position
		if cat.visible and room_id == &"home_cafe_garden":
			cat.action_completed.connect(_on_cat_action_completed)
			if session["cats"]["mochi"]["activity_id"] == "sniff":
				_garden_cat_action.call_deferred()
	if room is PlaceholderCafe:
		(room as PlaceholderCafe).phase_changed.connect(_set_status)
		(room as PlaceholderCafe).reward_earned.connect(_grant_reward)
		(room as PlaceholderCafe).visit_completed.connect(_visit_finished)
	_set_status("Ready | coins %d" % int(session["coins"]))
	return true


func transition_to(room_id: StringName, spawn_id: StringName) -> bool:
	if room is PlaceholderCafe and (room as PlaceholderCafe).loop_active:
		_set_status("Finish this customer before changing rooms")
		return false
	if _scene_for(room_id) == null:
		return false
	if decoration_mode:
		_cancel_move()
		decoration_mode = false
	_capture_room_delta()
	return _activate_room(room_id, spawn_id)


func enter_garden() -> bool:
	if session["active_room_id"] != "home_cafe_main":
		return false
	if room is PlaceholderCafe and (room as PlaceholderCafe).loop_active:
		return false
	var previous: String = session["cats"]["mochi"]["room_id"]
	session["cats"]["mochi"]["room_id"] = "home_cafe_garden"
	session["cats"]["mochi"]["activity_id"] = "sniff"
	if transition_to(&"home_cafe_garden", &"garden_entry"):
		return true
	session["cats"]["mochi"]["room_id"] = previous
	return false


func _garden_cat_action() -> void:
	await get_tree().physics_frame
	if room == null or room.room_id != &"home_cafe_garden":
		return
	var cat := room.actors.get_node_or_null("Cat") as HardeningActor
	if cat != null and cat.visible:
		if cat.request_interaction_on(&"cat_sniff", &"sniff"):
			_set_status("Garden: Mochi sniffs the plants")


func _on_cat_action_completed(slot: HardeningInteractionSlot) -> void:
	if slot.action_type == &"sniff" and room.room_id == &"home_cafe_garden":
		session["cats"]["mochi"]["activity_id"] = "idle"


func return_to_cafe() -> bool:
	return transition_to(&"home_cafe_main", &"garden_return")


func summon_cat() -> void:
	var cat_state: Dictionary = session["cats"]["mochi"]
	cat_state["room_id"] = session["active_room_id"]
	cat_state["activity_id"] = "idle"
	var cat := room.actors.get_node_or_null("Cat") as HardeningActor
	if cat != null:
		cat.visible = true
		cat.collision_layer = 4
		cat.global_position = room.spawn(&"cat_entry").global_position
	_set_status("Mochi assigned to %s" % session["active_room_id"])


func start_loop() -> bool:
	if not room is PlaceholderCafe or (room as PlaceholderCafe).loop_active:
		return false
	var order_id := "order_%d" % int(session["next_order_seq"])
	session["next_order_seq"] += 1
	_run_loop(order_id)
	return true


func _run_loop(order_id: String) -> void:
	await (room as PlaceholderCafe).run_coffee_loop(order_id)


func _grant_reward(order_id: String) -> void:
	var receipts: Array = session["rewarded_orders"]
	if receipts.has(order_id):
		return
	receipts.append(order_id)
	session["coins"] += 1
	if not session["unlocked_room_ids"].has("home_cafe_garden"):
		session["unlocked_room_ids"].append("home_cafe_garden")
	_reward_label.text = "+1 COIN"
	_set_status("Order complete | coins %d" % int(session["coins"]))
	_clear_reward_later()


func _clear_reward_later() -> void:
	await get_tree().create_timer(1.5).timeout
	_reward_label.text = ""


func _visit_finished(success: bool) -> void:
	if not success:
		_set_status("Visit failed; see Godot output")


func _set_status(value: String) -> void:
	var title := "MAIN CAFÉ" if session["active_room_id"] == "home_cafe_main" else "BACK GARDEN"
	_status.text = "%s · %s" % [title, value]
	print("PLACEHOLDER %s" % value)


func save_game(path: String = SAVE_PATH) -> bool:
	if room is PlaceholderCafe and (room as PlaceholderCafe).loop_active:
		_set_status("Save at a safe checkpoint after this customer")
		return false
	_capture_room_delta()
	var snapshot := session.duplicate(true)
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
	_set_status("Saved %s" % path)
	return true


func load_game(path: String = SAVE_PATH) -> bool:
	if room is PlaceholderCafe and (room as PlaceholderCafe).loop_active:
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var incoming = file.get_var(false)
	file.close()
	if not _valid_snapshot(incoming):
		return false
	var previous := session
	session = incoming
	if not _activate_room(StringName(incoming["active_room_id"]), StringName(incoming["entry_spawn_id"])):
		session = previous
		return false
	_set_status("Loaded %s | coins %d" % [session["active_room_id"], int(session["coins"])])
	return true


func _valid_snapshot(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var data: Dictionary = value
	return data.get("save_schema_version") == SCHEMA \
		and data.get("world_id") == "willicat_placeholder_world" \
		and _scene_for(StringName(data.get("active_room_id", ""))) != null \
		and data.get("entry_spawn_id") is String \
		and data.get("room_deltas") is Dictionary \
		and data.get("cats") is Dictionary \
		and data["cats"].has("mochi") \
		and data.get("rewarded_orders") is Array \
		and data.get("coins") is int \
		and data.get("next_order_seq") is int \
		and data.get("unlocked_room_ids") is Array


func _build_hud() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	$HUD.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	_status = Label.new()
	_status.text = "Loading café"
	_status.add_theme_font_size_override("font_size", 22)
	rows.add_child(_status)
	var first := HBoxContainer.new()
	rows.add_child(first)
	_add_button(first, "LOOP", start_loop)
	_add_button(first, "GARDEN", enter_garden)
	_add_button(first, "CAFÉ", return_to_cafe)
	_add_button(first, "CAT", summon_cat)
	var second := HBoxContainer.new()
	rows.add_child(second)
	_add_button(second, "MOVE", toggle_decoration)
	_add_button(second, "SAVE", save_game)
	_add_button(second, "LOAD", load_game)
	_add_button(second, "VIEW", overview)
	_add_button(second, "ZOOM", gameplay_view)
	_add_button(second, "FOCUS", focus_cat)
	_reward_label = Label.new()
	rows.add_child(_reward_label)


func _add_button(parent: Node, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(88, 76)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	parent.add_child(button)


func overview() -> void:
	(room.camera_input as PlaceholderCameraInput).set_preset(&"overview")


func gameplay_view() -> void:
	(room.camera_input as PlaceholderCameraInput).set_preset(&"default")


func focus_cat() -> void:
	var cat := room.actors.get_node_or_null("Cat") as HardeningActor
	if cat == null or not cat.visible:
		return
	var shot := HardeningCameraShot.new()
	shot.shot_id = &"cat_focus"
	shot.zoom = 1.8
	shot.hold_duration = 1.2
	room.camera_director.request_shot(cat.get_node("CameraEmotionFocus") as Marker2D, shot)


func toggle_decoration() -> void:
	decoration_mode = not decoration_mode
	room.camera_input.input_enabled = not decoration_mode
	_set_status("MOVE: drag table/chair; release to confirm; Esc cancels" if decoration_mode else "MOVE off")


func _cancel_move() -> void:
	if _moving != null:
		_moving.global_position = _move_origin
		_moving.global_rotation = _move_rotation
		_moving = null


func _pick_furniture(point: Vector2) -> HardeningWorldObject:
	var best: HardeningWorldObject
	var best_distance := INF
	for child in room.objects.get_children():
		if not child is HardeningWorldObject or String(child.kind) not in ["chair", "table"]:
			continue
		var object := child as HardeningWorldObject
		var footprint := object.get_node_or_null("PhysicalFootprint") as HardeningFootprint
		if footprint == null or not footprint.global_bounds().grow(18).has_point(point):
			continue
		var distance := object.global_position.distance_to(point)
		if distance < best_distance:
			best = object
			best_distance = distance
	return best


func _world_point(screen_point: Vector2) -> Vector2:
	return room.get_canvas_transform().affine_inverse() * screen_point


func _portal_tap(screen_point: Vector2) -> void:
	var point := _world_point(screen_point)
	if session["active_room_id"] == "home_cafe_main":
		var door := room.find_object(&"back_door")
		if door != null and door.global_position.distance_to(point) <= 65.0:
			enter_garden()
	elif session["active_room_id"] == "home_cafe_garden":
		var door := room.find_object(&"garden_door")
		if door != null and door.global_position.distance_to(point) <= 65.0:
			return_to_cafe()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R: start_loop()
			KEY_G: enter_garden()
			KEY_B: return_to_cafe()
			KEY_C: summon_cat()
			KEY_S: save_game()
			KEY_L: load_game()
			KEY_F8: toggle_decoration()
			KEY_1: overview()
			KEY_2: gameplay_view()
			KEY_3: focus_cat()
			KEY_ESCAPE: _cancel_move()
		return
	if not decoration_mode:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_tap_start = event.position
				_tap_active = true
				_tap_cancelled = false
			else:
				if _tap_active and not _tap_cancelled \
						and event.position.distance_to(_tap_start) <= 14.0:
					_portal_tap(event.position)
				_tap_active = false
		elif event is InputEventMouseMotion and _tap_active:
			if event.position.distance_to(_tap_start) > 14.0:
				_tap_cancelled = true
		elif event is InputEventScreenTouch:
			if event.pressed:
				_touch_count += 1
				if _touch_count == 1:
					_tap_start = event.position
					_tap_active = true
					_tap_cancelled = false
				else:
					_tap_cancelled = true
			else:
				if _touch_count == 1 and _tap_active and not _tap_cancelled \
						and event.position.distance_to(_tap_start) <= 14.0:
					_portal_tap(event.position)
				_touch_count = maxi(0, _touch_count - 1)
				if _touch_count == 0:
					_tap_active = false
		elif event is InputEventScreenDrag and _tap_active:
			if event.position.distance_to(_tap_start) > 14.0:
				_tap_cancelled = true
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_moving = _pick_furniture(_world_point(event.position))
			if _moving != null:
				_move_origin = _moving.global_position
				_move_rotation = _moving.global_rotation
				_move_offset = _moving.global_position - _world_point(event.position)
		else:
			_finish_move()
	elif event is InputEventMouseMotion and _moving != null:
		_moving.global_position = _world_point(event.position) + _move_offset
	elif event is InputEventScreenTouch:
		if event.pressed:
			_moving = _pick_furniture(_world_point(event.position))
			if _moving != null:
				_move_origin = _moving.global_position
				_move_rotation = _moving.global_rotation
				_move_offset = _moving.global_position - _world_point(event.position)
		else:
			_finish_move()
	elif event is InputEventScreenDrag and _moving != null:
		_moving.global_position = _world_point(event.position) + _move_offset


func _finish_move() -> void:
	if _moving == null:
		return
	var item := _moving
	var candidate := item.global_position
	item.global_position = _move_origin
	item.global_rotation = _move_rotation
	_moving = null
	if room.confirm_furniture_move(item.stable_id, candidate, _move_rotation):
		_capture_room_delta()
		_set_status("Moved %s; its slots followed" % item.stable_id)
	else:
		_set_status("Invalid footprint: move cancelled")
