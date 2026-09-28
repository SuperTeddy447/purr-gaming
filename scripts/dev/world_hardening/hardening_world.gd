class_name HardeningWorld
extends Node2D
## Isolated room authority: semantic discovery, placement/nav updates, demo orchestration.

signal event_variant_changed(active: bool)
signal demo_started()
signal demo_completed()

@onready var navigation: HardeningNavigation = $Navigation
@onready var camera_director: HardeningCameraDirector = $CameraDirector
@onready var camera_input: HardeningCameraInput = $CameraInput
@onready var objects: Node2D = $DepthSortedLayer/WorldObjects
@onready var event_layer: Node2D = $DepthSortedLayer/EventLayer
@onready var actors: Node2D = $DepthSortedLayer/Characters

@export var initial_event_active := false
var event_active := false
var demo_running := false
var _move_step := 0


func _ready() -> void:
	camera_input.camera = $Camera
	camera_director.camera = $Camera
	camera_director.camera_input = camera_input
	camera_director.hud = $HUD
	set_event_active(initial_event_active)
	_watch_objects(objects)
	_watch_objects(event_layer)
	for actor in actors.get_children():
		if actor is HardeningActor:
			(actor as HardeningActor).bind_world(self)
	var worker := actors.get_node("Worker") as HardeningActor
	worker.action_started.connect(_on_worker_action_started)
	worker.action_completed.connect(_on_worker_action_completed)
	worker.action_cancelled.connect(_on_worker_action_cancelled)
	print("HARDENING room ready nav=%d" % navigation.revision)


func all_slots(action: StringName) -> Array[HardeningInteractionSlot]:
	var result: Array[HardeningInteractionSlot] = []
	_collect_slots(objects, action, result)
	if event_active:
		_collect_slots(event_layer, action, result)
	return result


func _collect_slots(node: Node, action: StringName, result: Array[HardeningInteractionSlot]) -> void:
	if node is HardeningInteractionSlot and (node as HardeningInteractionSlot).action_type == action:
		result.append(node as HardeningInteractionSlot)
	for child in node.get_children():
		_collect_slots(child, action, result)


func reserve_available_slot(action: StringName, actor: HardeningActor) -> HardeningInteractionSlot:
	var best: HardeningInteractionSlot
	var best_score := -INF
	for slot in all_slots(action):
		if not slot.accepts(actor):
			continue
		var score := float(slot.priority) * 100000.0 \
			- actor.global_position.distance_to(slot.approach_anchor().global_position)
		if score > best_score:
			best = slot
			best_score = score
	if best != null and best.reserve(actor):
		return best
	return null


func find_slot_on_object(object_id: StringName, action: StringName) -> HardeningInteractionSlot:
	var object := find_object(object_id)
	if object == null:
		return null
	var found: Array[HardeningInteractionSlot] = []
	_collect_slots(object, action, found)
	return found[0] if not found.is_empty() else null


func find_object(id: StringName) -> HardeningWorldObject:
	var found := _find_object(objects, id)
	if found == null and event_active:
		found = _find_object(event_layer, id)
	return found


func _find_object(node: Node, id: StringName) -> HardeningWorldObject:
	if node is HardeningWorldObject and (node as HardeningWorldObject).stable_id == id:
		return node as HardeningWorldObject
	for child in node.get_children():
		var found := _find_object(child, id)
		if found != null:
			return found
	return null


func _watch_objects(node: Node) -> void:
	if node is HardeningWorldObject:
		node.tree_exiting.connect(_on_object_exiting, CONNECT_ONE_SHOT)
	for child in node.get_children():
		_watch_objects(child)


func _on_object_exiting() -> void:
	if not is_queued_for_deletion():
		call_deferred("rebuild_navigation")


func move_object(id: StringName, new_global_position: Vector2) -> bool:
	var object := find_object(id)
	if object == null:
		return false
	object.global_position = new_global_position
	if not rebuild_navigation():
		return false
	print("HARDENING moved %s to %s nav=%d" % [id, str(new_global_position), navigation.revision])
	return true


func validate_placement(id: StringName, position: Vector2, angle: float = 0.0) -> bool:
	## Conservative decoration-placement gate; does not silently move authored objects.
	var object := find_object(id)
	if object == null:
		return false
	var footprint := object.get_node_or_null("PhysicalFootprint") as HardeningFootprint
	if footprint == null:
		return false
	var candidate := PackedVector2Array()
	var transform := Transform2D(angle, position)
	for corner in footprint.navigation_outline():
		candidate.append(transform * object.to_local(corner))
	for corner in candidate:
		if not navigation.walkable_bounds.has_point(corner):
			return false
	var occupied: Array[HardeningFootprint] = []
	_collect_footprints(objects, occupied)
	if event_active:
		_collect_footprints(event_layer, occupied)
	for other in occupied:
		if other == footprint:
			continue
		if not Geometry2D.intersect_polygons(candidate, other.navigation_outline()).is_empty():
			return false
	return true


func _collect_footprints(node: Node, result: Array[HardeningFootprint]) -> void:
	if node is HardeningFootprint:
		result.append(node as HardeningFootprint)
	for child in node.get_children():
		_collect_footprints(child, result)


func place_object(id: StringName, position: Vector2, angle: float) -> bool:
	if not validate_placement(id, position, angle):
		return false
	var object := find_object(id)
	object.global_position = position
	object.global_rotation = angle
	return rebuild_navigation()


func placement_snapshot() -> Array[Dictionary]:
	## Seed shape for a future save format; no persistence system is implemented.
	var snapshot: Array[Dictionary] = []
	_append_placements(objects, snapshot)
	if event_active:
		_append_placements(event_layer, snapshot)
	return snapshot


func _append_placements(node: Node, result: Array[Dictionary]) -> void:
	if node is HardeningWorldObject:
		var object := node as HardeningWorldObject
		result.append({"id": String(object.stable_id), "kind": String(object.kind),
			"position": object.global_position, "rotation": object.global_rotation})
	for child in node.get_children():
		_append_placements(child, result)


func _refresh_actors_after_world_move() -> void:
	for actor in actors.get_children():
		if actor is HardeningActor:
			(actor as HardeningActor).refresh_target_after_world_move()


func _refresh_after_navigation_sync(expected_revision: int) -> void:
	await get_tree().physics_frame
	if expected_revision != navigation.revision:
		return
	# This isolated room requests immediate paths after moves. Flush the pending
	# region upload and map rebuild; production should debounce and await sync.
	NavigationServer2D.map_force_update(navigation.get_navigation_map())
	NavigationServer2D.map_force_update(navigation.get_navigation_map())
	_refresh_actors_after_world_move()


func rebuild_navigation() -> bool:
	if not navigation.rebuild(objects, event_layer):
		return false
	_refresh_after_navigation_sync(navigation.revision)
	return true


func set_event_active(active: bool) -> void:
	event_active = active
	if not is_node_ready():
		return
	var display := event_layer.get_node_or_null("SeasonalDisplay") as HardeningWorldObject
	if display != null:
		var inspect := display.get_node("InspectSlot") as HardeningInteractionSlot
		inspect.enabled = active
	event_layer.visible = active
	rebuild_navigation()
	event_variant_changed.emit(active)
	print("HARDENING event variant=%s" % active)


func run_multi_agent_demo() -> bool:
	if demo_running:
		return false
	demo_running = true
	demo_started.emit()
	var worker := actors.get_node("Worker") as HardeningActor
	var customer_a := actors.get_node("CustomerA") as HardeningActor
	var customer_b := actors.get_node("CustomerB") as HardeningActor
	var cat_a := actors.get_node("CatA") as HardeningActor
	var cat_b := actors.get_node("CatB") as HardeningActor
	var cat_c := actors.get_node("CatC") as HardeningActor
	var results := [
		customer_a.request_interaction(&"sit"),
		customer_b.request_interaction(&"sit"),
		cat_a.request_interaction(&"rest"),
		cat_b.request_interaction(&"rest"),
		cat_b.request_interaction(&"sniff"),
		cat_c.request_interaction(&"scratch"),
		worker.request_interaction(&"work_coffee"),
	]
	print("HARDENING demo requests=%s" % str(results))
	_wait_demo_end()
	return results == [true, true, true, false, true, true, true]


func _wait_demo_end() -> void:
	while demo_running:
		await get_tree().physics_frame
		var all_idle := true
		for actor in actors.get_children():
			if actor is HardeningActor and (actor as HardeningActor).phase != HardeningActor.Phase.IDLE:
				all_idle = false
		if all_idle:
			demo_running = false
			demo_completed.emit()
			print("HARDENING demo complete; reservations clear=%s" % all_reservations_clear())


func all_reservations_clear() -> bool:
	for action in [&"sit", &"rest", &"sleep", &"sniff", &"scratch", &"stretch", &"work_coffee", &"inspect"]:
		for slot in all_slots(action):
			if slot.use_count() != 0:
				return false
	return true


func _on_worker_action_started(slot: HardeningInteractionSlot) -> void:
	if slot.action_type != &"work_coffee":
		return
	$DepthSortedLayer/WorldObjects/CounterServiceZone/EspressoStation/SteamFXAnchor/Steam.visible = true
	$DepthSortedLayer/WorldObjects/CounterServiceZone/EspressoStation/CupSpawnAnchor/Cup.visible = false
	var brew := HardeningCameraShot.new()
	brew.shot_id = &"brew_closeup"
	brew.zoom = 2.45
	brew.hold_duration = -1.0
	brew.priority = 20
	camera_director.request_shot($DepthSortedLayer/WorldObjects/CounterServiceZone/EspressoStation/CameraBrewFocus, brew)
	print("HARDENING coffee BREWING")


func _on_worker_action_completed(slot: HardeningInteractionSlot) -> void:
	if slot.action_type != &"work_coffee":
		return
	$DepthSortedLayer/WorldObjects/CounterServiceZone/EspressoStation/SteamFXAnchor/Steam.visible = false
	$DepthSortedLayer/WorldObjects/CounterServiceZone/EspressoStation/CupSpawnAnchor/Cup.visible = true
	var reveal := HardeningCameraShot.new()
	reveal.shot_id = &"cup_reveal"
	reveal.zoom = 2.65
	reveal.transition_in = 0.22
	reveal.hold_duration = 0.55
	reveal.transition_out = 0.34
	reveal.priority = 30
	camera_director.request_shot($DepthSortedLayer/WorldObjects/CounterServiceZone/EspressoStation/CameraCupReveal, reveal)
	print("HARDENING coffee READY / CUP REVEAL")


func _on_worker_action_cancelled(slot: HardeningInteractionSlot, _reason: StringName) -> void:
	if slot.action_type == &"work_coffee":
		$DepthSortedLayer/WorldObjects/CounterServiceZone/EspressoStation/SteamFXAnchor/Steam.visible = false
		camera_director.cancel(&"action_cancelled")


func focus_event() -> bool:
	if not event_active:
		return false
	var shot := HardeningCameraShot.new()
	shot.shot_id = &"event_focus"
	shot.zoom = 2.2
	shot.hold_duration = 0.7
	shot.priority = 40
	return camera_director.request_shot(event_layer.get_node("SeasonalDisplay/CameraEventFocus"), shot)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_F6: $CaptureHarness.run_capture()
		KEY_F4:
			(actors.get_node("CustomerA") as HardeningActor).navigate_to_marker($CrossTableTarget)
		KEY_F7:
			$DebugOverlay.visible = not $DebugOverlay.visible
		KEY_F8:
			var ids := [&"espresso_station", &"chair_a", &"cat_bed", &"plant"]
			var id: StringName = ids[_move_step % ids.size()]
			_move_step += 1
			var item := find_object(id)
			move_object(id, item.global_position + Vector2(24, 12))
		KEY_F9: run_multi_agent_demo()
		KEY_F10: set_event_active(not event_active)
		KEY_F11: focus_event()
		KEY_F12: camera_director.cancel(&"debug_cancel")
