extends SceneTree
## Accelerated, frame-rate-independent checks for one complete loop and auto-repeat.

const SCENE_PATH: String = "res://scenes/home/home_scene.tscn"
const EXPECTED_EVENTS: Array[StringName] = [
	&"customer_spawned", &"customer_seated", &"order_created", &"worker_prepares",
	&"coffee_prepared", &"worker_serves", &"reward_granted",
	&"worker_returned_idle", &"customer_exited"
]

var _events: Array[StringName] = []
var _reward_count: int = 0
var _seat_position: Vector2
var _seat_reached_at: Vector2
var _worker_prepared_at: Vector2
var _reward_fx_at: Vector2
var _reward_expected_at: Vector2
var _order_bubble_above_world: bool = false
var _home: HomeScene
var _controller: VerticalSliceController


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _run_single_cycle():
		quit(1)
		return
	if not await _run_auto_repeat():
		quit(1)
		return
	print("--- ALL VERTICAL SLICE 001 CHECKS PASSED ---")
	quit(0)


func _create_test_scene(repeat: bool) -> void:
	_home = (load(SCENE_PATH) as PackedScene).instantiate() as HomeScene
	_controller = _home.get_node("VerticalSliceController") as VerticalSliceController
	_controller.auto_repeat_slice = repeat
	_controller.interaction_mode = VerticalSliceController.InteractionMode.AUTO_LOOP
	_controller.customer_move_speed = 10000.0
	_controller.worker_move_speed = 10000.0
	_controller.timing_config = _controller.timing_config.duplicate_for_testing()
	_controller.timing_config.customer_order_delay = 0.02
	_controller.timing_config.customer_arrival_pause = 0.01
	_controller.timing_config.serve_duration = 0.02
	_controller.timing_config.served_reaction_duration = 0.02
	_controller.timing_config.customer_exit_delay = 0.01
	_controller.timing_config.next_customer_delay = 0.02
	_controller.coffee_order = _controller.coffee_order.duplicate(true) as SliceCoffeeOrder
	_controller.timing_config.coffee_preparation_duration = 0.02
	(_home.get_node("PrototypeDoorController") as PrototypeDoorController).timing_config = _controller.timing_config
	_controller.lifecycle_event.connect(_on_lifecycle_event)
	_controller.wallet.reward_added.connect(_on_reward_added)
	var seat_marker: GameplayMarker = _home.get_node("GameplayNodes/Seats/SeatA") as GameplayMarker
	_seat_position = seat_marker.global_position
	seat_marker.name = "RenamedSeatNodeForIDTest"
	root.add_child(_home)


func _run_single_cycle() -> bool:
	_events.clear()
	_reward_count = 0
	_create_test_scene(false)
	if not _controller.has_marker_id(GameplayID.SEAT_MAIN_A) or \
		_controller.get_marker_position(GameplayID.SEAT_MAIN_A) != _seat_position:
		return _fail("Seat lookup depends on the node name instead of the semantic marker ID")
	if _controller.customer == null or _controller.customer.scene_file_path != \
		"res://scenes/characters/customer_placeholder.tscn":
		return _fail("Customer was not instantiated from its reusable PackedScene")
	var camera: CameraController = _home.get_node("CameraRig") as CameraController
	camera.set_zoom_target(camera.max_zoom)
	camera.target_position = camera.pan_bounds.position + camera.pan_bounds.size * 0.6
	var customer_ref: WeakRef = weakref(_controller.customer)
	if not await _wait_for_cycles(1, 600):
		return _fail("Single cycle did not complete within 600 simulated frames; events=%s" % [_events])
	await process_frame
	if not _check_event_order():
		return false
	if _seat_reached_at.distance_to(_seat_position) > 0.01:
		return _fail("Customer did not stop at semantic Seat A")
	if _worker_prepared_at.distance_to(_controller.get_marker_position(GameplayID.STATION_COFFEE)) > 0.01:
		return _fail("Worker did not prepare at the semantic coffee marker")
	if not _order_bubble_above_world:
		return _fail("Runtime order bubble did not render above the world layer")
	if _reward_count != 1 or _controller.wallet.coins != 5:
		return _fail("One coffee order did not grant exactly one 5-coin reward")
	if _reward_fx_at.distance_to(_reward_expected_at) > 0.01:
		return _fail("Reward FX did not spawn at the served customer")
	if _controller.worker_slice.state != SliceWorker.State.IDLE or \
		_controller.worker_actor.global_position.distance_to(
			_controller.get_marker_position(GameplayID.WORKER_IDLE)) > 0.01:
		return _fail("Worker did not end at WorkerIdle")
	if _controller.customer != null or customer_ref.get_ref() != null or \
		_home.get_node("World/DepthSortedLayer").get_node_or_null("CustomerPlaceholder") != null:
		return _fail("Customer was not freed at the end of the cycle")
	if _home.get_node("World/DepthSortedLayer").z_index >= \
		_home.get_node("World/ForegroundOccluderLayer").z_index or \
		_home.get_node("World/FXLayer").z_index <= \
		_home.get_node("World/ForegroundOccluderLayer").z_index:
		return _fail("Depth/occlusion order regressed")
	for frame in range(240):
		await process_frame
	if _controller.completed_cycles != 1 or _controller.customer != null:
		return _fail("Auto-repeat disabled did not stop after one cycle")
	print("[PASS] Complete event order, semantic markers, one reward, worker idle, freed customer, depth order, camera-independent movement.")
	_home.queue_free()
	await process_frame
	return true


func _run_auto_repeat() -> bool:
	_events.clear()
	_reward_count = 0
	_create_test_scene(true)
	if not await _wait_for_cycles(2, 1200):
		return _fail("Auto-repeat did not finish two cycles within 1200 simulated frames")
	if _reward_count != 2 or _controller.wallet.coins != 10:
		return _fail("Auto-repeat granted an unexpected number of rewards")
	print("[PASS] Auto-repeat completes two cycles without overlapping customers; coins=%d." % _controller.wallet.coins)
	_home.queue_free()
	await process_frame
	return true


func _wait_for_cycles(count: int, frame_limit: int) -> bool:
	for frame in range(frame_limit):
		await process_frame
		var active_customers: int = 0
		for child in _home.get_node("World/DepthSortedLayer").get_children():
			if child is CharacterPlaceholder and (child as CharacterPlaceholder).role == "Customer" and child.visible:
				active_customers += 1
		if active_customers > 1:
			return false
		if _controller.completed_cycles >= count:
			return true
	return false


func _on_lifecycle_event(event_name: StringName) -> void:
	_events.append(event_name)
	if event_name == &"customer_seated":
		_seat_reached_at = _controller.customer.global_position
	elif event_name == &"order_created":
		var bubble: PrototypeOrderBubble = _controller.customer.get_node("OrderBubble") as PrototypeOrderBubble
		_order_bubble_above_world = bubble != null and bubble.z_index > 0 and \
			bubble.get_parent() == _controller.customer
	elif event_name == &"worker_prepares":
		_worker_prepared_at = _controller.worker_actor.global_position
	elif event_name == &"reward_granted":
		_reward_expected_at = _controller.customer.global_position + Vector2(0.0, -140.0)
		var fx_children: Array[Node] = _controller.fx_layer.get_children()
		_reward_fx_at = (fx_children.back() as SliceRewardFX).global_position


func _on_reward_added(_amount: int, _total: int, _order_id: StringName) -> void:
	_reward_count += 1


func _check_event_order() -> bool:
	var previous_index: int = -1
	for expected_event in EXPECTED_EVENTS:
		var actual_index: int = _events.find(expected_event)
		if actual_index <= previous_index:
			return _fail("Missing or out-of-order event %s; events=%s" % [expected_event, _events])
		previous_index = actual_index
	return true


func _fail(message: String) -> bool:
	printerr("[FAIL] " + message)
	return false
