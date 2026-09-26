extends SceneTree
## Marker geometry and four complete seat routes without a second gameplay loop.

const HOME_SCENE: String = "res://scenes/home/home_scene.tscn"
const SEATS: Array[StringName] = [GameplayID.SEAT_MAIN_A, GameplayID.SEAT_MAIN_B,
	GameplayID.SEAT_MAIN_C, GameplayID.SEAT_MAIN_D]

var _home: HomeScene
var _slice: VerticalSliceController
var _routes: HomeSpatialRoutes
var _visited_seats: Array[StringName] = []
var _served_seats: Array[StringName] = []
var _worker_arrivals: Array[Vector2] = []
var _errors: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_home = (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	_slice = _home.get_node("VerticalSliceController") as VerticalSliceController
	_slice.start_on_ready = false
	_routes = _home.get_node("SliceWaypoints") as HomeSpatialRoutes
	root.add_child(_home)
	await process_frame
	if not _check_geometry():
		quit(1)
		return
	if not await _check_runtime():
		quit(1)
		return
	print("--- ALL HOME SPATIAL VALIDATION V1 CHECKS PASSED ---")
	quit(0)


func _check_geometry() -> bool:
	var front := _home.get_node("World/ForegroundOccluderLayer/CounterFrontSlot") as HomeAssetSlot
	var occluder := front.visual_node as HomeModularProp
	var serve: Vector2 = _slice.get_marker_position(GameplayID.COUNTER_SERVE)
	if occluder == null or _inside_counter(front, occluder, serve):
		return _fail("ServePoint remains inside the counter-front occlusion region")
	if not _inside_counter(front, occluder, Vector2(518.0, 603.0)):
		return _fail("The old ServePoint comparison no longer reproduces its occlusion cause")
	var idle: Vector2 = _slice.get_marker_position(GameplayID.WORKER_IDLE)
	var coffee: Vector2 = _slice.get_marker_position(GameplayID.STATION_COFFEE)
	var seat_positions: Dictionary = {}
	for seat_id in SEATS:
		var seat: Vector2 = _slice.get_marker_position(seat_id)
		if seat_positions.has(seat):
			return _fail("Two seat markers overlap")
		seat_positions[seat] = true
		var approach: Marker2D = _routes.service_marker(seat_id)
		if approach == null or approach.global_position.distance_to(seat) > 95.0:
			return _fail("Service approach is missing or too far from %s" % String(seat_id))
		var outward: Array[Vector2] = [idle, coffee]
		outward.append_array(_routes.worker_to_service(seat_id, serve))
		var homeward: Array[Vector2] = [approach.global_position]
		homeward.append_array(_routes.worker_to_idle(seat_id, serve, idle))
		var arrival: Array[Vector2] = [_slice.get_marker_position(GameplayID.CUSTOMER_SPAWN)]
		arrival.append_array(_routes.customer_to_seat(seat_id,
			_slice.customer_entry_waypoint.global_position,
			_slice.customer_aisle_waypoint.global_position, seat))
		var departure: Array[Vector2] = [seat]
		departure.append_array(_routes.customer_to_exit(seat_id,
			_slice.customer_aisle_waypoint.global_position,
			_slice.customer_entry_waypoint.global_position,
			_slice.get_marker_position(GameplayID.CUSTOMER_EXIT)))
		if outward.back() != approach.global_position or homeward.back() != idle or \
			arrival.back() != seat or departure.back() != _slice.get_marker_position(GameplayID.CUSTOMER_EXIT):
			return _fail("An authored route does not end at its semantic destination")
		for path in [outward, homeward, arrival, departure]:
			if _crosses_counter_front(path) or _crosses_table_pedestal(path):
				return _fail("A worker/customer route crosses the counter front or a table pedestal: %s" % String(seat_id))
	if _home.get_node("World/BackDecorLayer").z_index >= _home.get_node("World/DepthSortedLayer").z_index or \
		_home.get_node("World/DepthSortedLayer").z_index >= _home.get_node("World/ForegroundOccluderLayer").z_index:
		return _fail("Locked depth architecture changed")
	var route_debug := _home.get_node("World/FXLayer/HomeSpatialRouteDebug") as HomeSpatialRouteDebug
	if route_debug == null or route_debug.visible:
		return _fail("Debug routes must not appear in normal gameplay")
	var debug := _home.get_node("UI/DebugOverlay") as DebugOverlay
	debug.toggle_master_debug()
	if not route_debug.visible:
		return _fail("Debug View did not reveal the spatial routes")
	debug.toggle_master_debug()
	print("[PASS] Four unique seats, authored worker/customer paths, clear service approaches, counter-front avoidance, and debug-only route view.")
	return true


func _inside_counter(slot: HomeAssetSlot, visual: HomeModularProp, point: Vector2) -> bool:
	for local_rect in visual.occlusion_regions_local():
		if Rect2(slot.global_position + local_rect.position, local_rect.size).has_point(point):
			return true
	return false


func _crosses_counter_front(path: Array[Vector2]) -> bool:
	# A back-to-front crossing at the face (y=632) must happen beside, not through, the 560px counter.
	for index in range(1, path.size()):
		var a: Vector2 = path[index - 1]
		var b: Vector2 = path[index]
		if is_equal_approx(a.y, b.y) or (a.y - 632.0) * (b.y - 632.0) > 0.0:
			continue
		var x: float = lerpf(a.x, b.x, (632.0 - a.y) / (b.y - a.y))
		if x >= 185.0 and x <= 745.0:
			return true
	return false


func _crosses_table_pedestal(path: Array[Vector2]) -> bool:
	var pedestal_a := Rect2(236.0, 916.0, 68.0, 22.0)
	var pedestal_b := Rect2(506.0, 1242.0, 68.0, 26.0)
	for index in range(1, path.size()):
		var a: Vector2 = path[index - 1]
		var b: Vector2 = path[index]
		for step in range(51):
			var point: Vector2 = a.lerp(b, float(step) / 50.0)
			if pedestal_a.has_point(point) or pedestal_b.has_point(point):
				return true
	return false


func _check_runtime() -> bool:
	_slice.customer_move_speed = 10000.0
	_slice.worker_move_speed = 10000.0
	_slice.worker_slice.mover.movement_speed = _slice.worker_move_speed
	_slice.timing_config = _slice.timing_config.duplicate_for_testing()
	_slice.timing_config.customer_order_delay = 0.02
	_slice.timing_config.customer_arrival_pause = 0.01
	_slice.timing_config.serve_duration = 0.02
	_slice.timing_config.served_reaction_duration = 0.02
	_slice.timing_config.customer_exit_delay = 0.01
	_slice.timing_config.door_transition_duration = 0.02
	_slice.timing_config.door_hold_open_duration = 0.02
	_slice.timing_config.next_customer_delay = 0.02
	_slice.coffee_order = _slice.coffee_order.duplicate(true) as SliceCoffeeOrder
	_slice.timing_config.coffee_preparation_duration = 0.02
	var door := _home.get_node("PrototypeDoorController") as PrototypeDoorController
	door.timing_config = _slice.timing_config
	_slice.set_interaction_mode(VerticalSliceController.InteractionMode.AUTO_LOOP)
	_slice.auto_repeat_slice = true
	_slice.lifecycle_event.connect(_on_event)
	_slice.worker_slice.mover.destination_reached.connect(_on_worker_destination)
	_slice.start_slice()
	for _frame in range(1600):
		await process_frame
		if _slice.completed_cycles >= 4:
			break
	if _slice.completed_cycles != 4 or _slice.wallet.coins != 20 or \
		_visited_seats != SEATS or _served_seats != SEATS or not _errors.is_empty():
		return _fail("Four-seat runtime loop failed: cycles=%d coins=%d visited=%s served=%s customer=%s worker=%s target=%s errors=%s" % [
			_slice.completed_cycles, _slice.wallet.coins, _visited_seats, _served_seats,
			_slice.customer_slice.state_name() if _slice.customer_slice != null else "none",
			_slice.worker_slice.state_name(), _slice.worker_slice.mover.current_target, _errors])
	if _slice.customer != null or _slice.worker_slice.state != SliceWorker.State.IDLE or \
		_slice.door_controller.state != PrototypeDoorController.State.CLOSED:
		return _fail("Loop did not reset cleanly after four spatial routes")
	var first_route: Array[Vector2] = [_slice.get_marker_position(GameplayID.STATION_COFFEE)]
	first_route.append_array(_routes.worker_to_service(GameplayID.SEAT_MAIN_A,
		_slice.get_marker_position(GameplayID.COUNTER_SERVE)))
	first_route.append_array(_routes.worker_to_idle(GameplayID.SEAT_MAIN_A,
		_slice.get_marker_position(GameplayID.COUNTER_SERVE),
		_slice.get_marker_position(GameplayID.WORKER_IDLE)))
	if _worker_arrivals.size() < first_route.size():
		return _fail("Worker skipped an authored waypoint")
	for index in range(first_route.size()):
		if _worker_arrivals[index].distance_to(first_route[index]) > 0.1:
			return _fail("Worker teleported or skipped the first cycle's authored route at point %d" % index)
	print("[PASS] One shared AUTO loop reaches all four seats and table-side serve points; four rewards, four exits, worker idle, door closed.")
	return true


func _on_event(event_name: StringName) -> void:
	if event_name == &"customer_seated":
		_visited_seats.append(_slice.active_seat_id)
		if _slice.customer.global_position.distance_to(_slice.get_marker_position(_slice.active_seat_id)) > 0.1:
			_errors.append("customer stopped away from assigned seat")
	elif event_name == &"worker_serves":
		_served_seats.append(_slice.active_seat_id)
		if _slice.worker_actor.global_position.distance_to(_routes.service_marker(_slice.active_seat_id).global_position) > 0.1:
			_errors.append("worker served away from assigned customer approach")
		var carry := _slice.worker_actor.get_node_or_null("CarryCupPlaceholder") as PrototypeCarryVisual
		if carry == null or not carry.visible or carry.get_parent() != _slice.worker_actor:
			_errors.append("carried cup lost the worker's depth ownership during service")
		var interaction := _home.get_node("HomeInteractionController") as HomeInteractionController
		var serve_target_at_approach: bool = false
		for target in interaction._all_targets():
			if target.get("id") == &"serve_point" and target.get("node") == _routes.service_marker(_slice.active_seat_id):
				serve_target_at_approach = true
		if not serve_target_at_approach:
			_errors.append("serve interaction target did not follow the active customer's approach")


func _on_worker_destination(point: Vector2) -> void:
	_worker_arrivals.append(point)


func _fail(message: String) -> bool:
	printerr("[SPATIAL FAIL] " + message)
	return false
