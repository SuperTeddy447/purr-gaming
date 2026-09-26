class_name VerticalSliceController
extends Node
## One deterministic café loop. This is intentionally local to HomeScene.

signal lifecycle_event(event_name: StringName)
signal cycle_completed(cycle_number: int)
signal interaction_mode_changed(mode: InteractionMode)

enum InteractionMode { MANUAL, AUTO_LOOP }

@export_group("Scene References")
@export var depth_layer: Node2D
@export var marker_root: Node
@export var worker_actor: Node2D
@export var fx_layer: Node2D
@export var coins_label: Label
@export var customer_entry_waypoint: Marker2D
@export var customer_aisle_waypoint: Marker2D
@export var spatial_routes: HomeSpatialRoutes
@export var customer_scene: PackedScene = preload("res://scenes/characters/customer_placeholder.tscn")
@export var coffee_order: SliceCoffeeOrder = preload("res://data/slice_coffee_order.tres")
@export var timing_config: PrototypeTimingConfig = preload("res://data/home_prototype_timing.tres")
@export var door_controller: PrototypeDoorController

@export_group("Prototype Loop")
@export var start_on_ready: bool = true
@export var auto_repeat_slice: bool = true
@export var interaction_mode: InteractionMode = InteractionMode.MANUAL
@export_range(1.0, 10000.0, 1.0) var customer_move_speed: float = 260.0
@export_range(1.0, 10000.0, 1.0) var worker_move_speed: float = 250.0

var cycle_number: int = 0
var completed_cycles: int = 0
var active_order_id: StringName = &""
var active_order_instance_id: StringName = &""
var active_seat_id: StringName = &""
var customer: CharacterPlaceholder
var customer_slice: SliceCustomer
var customer_mover: SliceMover
var worker_slice: SliceWorker
var wallet: SliceRewardState = SliceRewardState.new()
var seat_occupancy: Dictionary = {}

var _markers: Dictionary = {}
var _seat_ids: Array[StringName] = [
	GameplayID.SEAT_MAIN_A, GameplayID.SEAT_MAIN_B, GameplayID.SEAT_MAIN_C, GameplayID.SEAT_MAIN_D
]
var _next_seat_index: int = 0
var _phase_timer: Timer
var _timer_phase: StringName = &""
var _reward_granted: bool = false
var _post_serve_elapsed: bool = false
var _exit_delay_elapsed: bool = false
var _exit_pending_door_close: bool = false


func _ready() -> void:
	if not _validate_references() or not _index_markers():
		push_error("Vertical Slice 001 cannot start: scene references or semantic markers are invalid.")
		return
	worker_slice = worker_actor.get_node("SliceWorker") as SliceWorker
	worker_slice.mover.movement_speed = worker_move_speed
	worker_actor.global_position = get_marker_position(GameplayID.WORKER_IDLE)
	worker_slice.mover.route_completed.connect(_on_worker_route_completed)
	worker_slice.coffee_prepared.connect(_on_coffee_prepared)
	worker_slice.serve_finished.connect(_on_serve_finished)
	wallet.reward_added.connect(_on_reward_added)
	if door_controller != null:
		door_controller.state_changed.connect(_on_door_state_changed)
	coins_label.text = "COINS: 0"
	_phase_timer = Timer.new()
	_phase_timer.one_shot = true
	_phase_timer.timeout.connect(_on_phase_timeout)
	add_child(_phase_timer)
	if start_on_ready:
		start_slice()


func _validate_references() -> bool:
	return depth_layer != null and marker_root != null and worker_actor != null and fx_layer != null \
		and coins_label != null and customer_entry_waypoint != null and customer_aisle_waypoint != null \
		and customer_scene != null and coffee_order != null and timing_config != null and spatial_routes != null


func _index_markers() -> bool:
	_markers.clear()
	if not _collect_markers(marker_root):
		return false
	for required_id in [GameplayID.CUSTOMER_SPAWN, GameplayID.CUSTOMER_EXIT,
		GameplayID.STATION_COFFEE, GameplayID.COUNTER_SERVE, GameplayID.WORKER_IDLE] + _seat_ids:
		if not _markers.has(required_id):
			push_error("Missing Vertical Slice marker ID: %s" % String(required_id))
			return false
	return true


func _collect_markers(node: Node) -> bool:
	if node is GameplayMarker:
		var marker: GameplayMarker = node as GameplayMarker
		if marker.marker_id == &"" or _markers.has(marker.marker_id):
			push_error("Empty or duplicate Vertical Slice marker ID: %s" % String(marker.marker_id))
			return false
		_markers[marker.marker_id] = marker
	for child in node.get_children():
		if not _collect_markers(child):
			return false
	return true


func has_marker_id(marker_id: StringName) -> bool:
	return _markers.has(marker_id)


func get_marker_position(marker_id: StringName) -> Vector2:
	var marker: GameplayMarker = _markers.get(marker_id) as GameplayMarker
	return marker.global_position if marker != null else Vector2.ZERO


func get_marker(marker_id: StringName) -> GameplayMarker:
	return _markers.get(marker_id) as GameplayMarker


func is_manual_mode() -> bool:
	return interaction_mode == InteractionMode.MANUAL


func set_interaction_mode(next_mode: InteractionMode) -> void:
	if interaction_mode == next_mode:
		return
	interaction_mode = next_mode
	interaction_mode_changed.emit(interaction_mode)
	_emit_event(&"mode_manual" if is_manual_mode() else &"mode_auto")
	if not is_manual_mode() and customer_slice != null and active_order_id != &"":
		if worker_slice.state == SliceWorker.State.IDLE:
			_begin_coffee_preparation()
		elif worker_slice.state == SliceWorker.State.READY_TO_SERVE:
			worker_slice.begin_serve(timing_config.resolve_duration(timing_config.serve_duration))


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_F7:
			var next_mode: InteractionMode = InteractionMode.MANUAL if not is_manual_mode() else InteractionMode.AUTO_LOOP
			set_interaction_mode(next_mode)
			get_viewport().set_input_as_handled()
		KEY_F8:
			timing_config.toggle_preset()
			_emit_event(&"timing_preset_changed")
			get_viewport().set_input_as_handled()


func start_slice() -> void:
	if customer != null or worker_slice == null or worker_slice.state != SliceWorker.State.IDLE:
		return
	if _phase_timer != null:
		_phase_timer.stop()
	_clear_reward_feedback()
	var assigned_seat: StringName = _claim_next_seat()
	if assigned_seat == &"":
		push_warning("No free semantic seat is available; customer spawn was skipped.")
		return
	cycle_number += 1
	_reward_granted = false
	_post_serve_elapsed = false
	_exit_delay_elapsed = false
	_exit_pending_door_close = false
	active_order_id = &""
	active_order_instance_id = &""
	active_seat_id = assigned_seat
	if door_controller != null:
		door_controller.open_door()
	customer = customer_scene.instantiate() as CharacterPlaceholder
	if customer == null:
		_release_active_seat()
		push_error("Customer scene root must be a CharacterPlaceholder.")
		return
	customer.name = "CustomerPlaceholder"
	depth_layer.add_child(customer)
	customer.global_position = get_marker_position(GameplayID.CUSTOMER_SPAWN)
	customer_slice = customer.get_node("SliceCustomer") as SliceCustomer
	customer_mover = customer_slice.mover
	customer_mover.movement_speed = customer_move_speed
	customer_mover.route_completed.connect(_on_customer_route_completed)
	customer_mover.destination_reached.connect(_on_customer_destination_reached)
	_emit_event(&"customer_spawned")
	_start_phase(&"customer_arrival", timing_config.customer_arrival_pause)


func _claim_next_seat() -> StringName:
	for offset in range(_seat_ids.size()):
		var index: int = (_next_seat_index + offset) % _seat_ids.size()
		var seat_id: StringName = _seat_ids[index]
		if not seat_occupancy.has(seat_id):
			seat_occupancy[seat_id] = true
			_next_seat_index = (index + 1) % _seat_ids.size()
			return seat_id
	return &""


func _release_active_seat() -> void:
	if active_seat_id == &"":
		return
	seat_occupancy.erase(active_seat_id)
	_emit_event(&"seat_released")
	active_seat_id = &""


func _on_customer_destination_reached(position: Vector2) -> void:
	if customer_slice == null:
		return
	if position.distance_to(customer_entry_waypoint.global_position) <= 0.1 and door_controller != null:
		if customer_slice.state == SliceCustomer.State.LEAVING:
			door_controller.notify_threshold_crossed(&"exit")
		else:
			door_controller.notify_threshold_crossed(&"entry")
			door_controller.close_after(timing_config.door_hold_open_duration)


func _on_customer_route_completed() -> void:
	if customer_slice == null:
		return
	if customer_slice.state == SliceCustomer.State.WALKING_TO_SEAT:
		customer_slice.set_state(SliceCustomer.State.SEATED)
		_emit_event(&"customer_seated")
		customer_slice.set_state(SliceCustomer.State.WAITING_FOR_ORDER)
		_start_phase(&"order_delay", timing_config.customer_order_delay)
	elif customer_slice.state == SliceCustomer.State.LEAVING:
		customer_slice.set_state(SliceCustomer.State.COMPLETE)
		customer_slice.clear_order_bubble()
		customer.queue_free()
		customer = null
		customer_slice = null
		customer_mover = null
		active_order_id = &""
		active_order_instance_id = &""
		_release_active_seat()
		_exit_pending_door_close = true
		if door_controller != null:
			door_controller.close_door()
			if door_controller.state == PrototypeDoorController.State.CLOSED:
				_finalize_customer_exit()
		else:
			_finalize_customer_exit()


func _on_phase_timeout() -> void:
	var finished_phase: StringName = _timer_phase
	_timer_phase = &""
	match finished_phase:
		&"customer_arrival":
			if customer_slice != null and customer_slice.state == SliceCustomer.State.SPAWNING:
				customer_slice.set_state(SliceCustomer.State.WALKING_TO_SEAT)
				customer_mover.move_route(spatial_routes.customer_to_seat(active_seat_id,
					customer_entry_waypoint.global_position, customer_aisle_waypoint.global_position,
					get_marker_position(active_seat_id)))
		&"order_delay":
			_create_order()
		&"post_serve":
			_post_serve_elapsed = true
			_start_phase(&"customer_exit_delay", timing_config.customer_exit_delay)
		&"customer_exit_delay":
			_exit_delay_elapsed = true
			_try_customer_departure()
		&"next_customer":
			if auto_repeat_slice:
				start_slice()


func _start_phase(phase: StringName, duration: float) -> void:
	_timer_phase = phase
	_phase_timer.start(timing_config.resolve_duration(duration))


func _create_order() -> void:
	if customer_slice == null or customer_slice.state != SliceCustomer.State.WAITING_FOR_ORDER:
		return
	active_order_id = coffee_order.order_id
	active_order_instance_id = StringName("%s#%d" % [String(active_order_id), cycle_number])
	customer_slice.show_order_bubble()
	customer_slice.set_state(SliceCustomer.State.WAITING_FOR_SERVICE)
	_emit_event(&"order_created")
	if not is_manual_mode():
		_begin_coffee_preparation()


func request_coffee_preparation() -> bool:
	if not is_manual_mode() or active_order_id == &"" or customer_slice == null \
		or customer_slice.state != SliceCustomer.State.WAITING_FOR_SERVICE \
		or worker_slice.state != SliceWorker.State.IDLE:
		return false
	_begin_coffee_preparation()
	return true


func _begin_coffee_preparation() -> void:
	if active_order_id == &"" or customer_slice == null or worker_slice.state != SliceWorker.State.IDLE:
		return
	worker_slice.set_state(SliceWorker.State.ORDER_RECEIVED)
	worker_slice.set_state(SliceWorker.State.WALKING_TO_COFFEE)
	_emit_event(&"coffee_start")
	worker_slice.mover.move_route([get_marker_position(GameplayID.STATION_COFFEE)])


func request_serve() -> bool:
	if not is_manual_mode() or active_order_id == &"" or customer_slice == null \
		or customer_slice.state != SliceCustomer.State.READY_FOR_SERVE \
		or worker_slice.state != SliceWorker.State.READY_TO_SERVE:
		return false
	worker_slice.begin_serve(timing_config.resolve_duration(timing_config.serve_duration))
	return true


func _on_worker_route_completed() -> void:
	match worker_slice.state:
		SliceWorker.State.WALKING_TO_COFFEE:
			_emit_event(&"worker_prepares")
			worker_slice.begin_preparation(timing_config.resolve_duration(timing_config.coffee_preparation_duration))
		SliceWorker.State.WALKING_TO_SERVE:
			if customer != null and worker_actor.has_method("set_facing_right"):
				worker_actor.call("set_facing_right", customer.global_position.x > worker_actor.global_position.x)
			if is_manual_mode():
				worker_slice.set_state(SliceWorker.State.READY_TO_SERVE)
				_emit_event(&"worker_ready_to_serve")
			else:
				worker_slice.begin_serve(timing_config.resolve_duration(timing_config.serve_duration))
		SliceWorker.State.RETURNING_TO_IDLE:
			worker_slice.set_state(SliceWorker.State.IDLE)
			_emit_event(&"worker_returned_idle")
			_try_customer_departure()


func _on_coffee_prepared() -> void:
	if customer_slice == null or active_order_id == &"":
		return
	_emit_event(&"coffee_prepared")
	customer_slice.set_state(SliceCustomer.State.READY_FOR_SERVE)
	customer_slice.set_order_ready(true)
	worker_slice.set_state(SliceWorker.State.WALKING_TO_SERVE)
	worker_slice.mover.move_route(spatial_routes.worker_to_service(active_seat_id,
		get_marker_position(GameplayID.COUNTER_SERVE)))


func _on_serve_finished() -> void:
	if customer_slice == null or active_order_id == &"" or _reward_granted:
		return
	_reward_granted = true
	customer_slice.clear_order_bubble()
	customer_slice.set_state(SliceCustomer.State.SERVED)
	_emit_event(&"worker_serves")
	if not wallet.add_reward(coffee_order.reward_coins, active_order_instance_id):
		_emit_event(&"reward_duplicate_blocked")
	active_order_id = &""
	worker_slice.set_state(SliceWorker.State.RETURNING_TO_IDLE)
	worker_slice.mover.move_route(spatial_routes.worker_to_idle(active_seat_id,
		get_marker_position(GameplayID.COUNTER_SERVE), get_marker_position(GameplayID.WORKER_IDLE)))
	_start_phase(&"post_serve", timing_config.served_reaction_duration)


func _on_reward_added(amount: int, total: int, _order_id: StringName) -> void:
	coins_label.text = "COINS: %d" % total
	var reward_fx: SliceRewardFX = SliceRewardFX.new()
	reward_fx.amount = amount
	if customer != null:
		reward_fx.position = customer.global_position + Vector2(0.0, -140.0)
	fx_layer.add_child(reward_fx)
	_emit_event(&"reward_granted")


func _clear_reward_feedback() -> void:
	if fx_layer == null:
		return
	for child in fx_layer.get_children():
		if child is SliceRewardFX:
			(child as CanvasItem).visible = false
			child.queue_free()


func _try_customer_departure() -> void:
	if not _post_serve_elapsed or not _exit_delay_elapsed or worker_slice.state != SliceWorker.State.IDLE or customer_slice == null \
		or customer_slice.state != SliceCustomer.State.SERVED:
		return
	customer_slice.set_state(SliceCustomer.State.LEAVING)
	if door_controller != null:
		door_controller.open_door()
	customer_mover.move_route(spatial_routes.customer_to_exit(active_seat_id,
		customer_aisle_waypoint.global_position, customer_entry_waypoint.global_position,
		get_marker_position(GameplayID.CUSTOMER_EXIT)))


func _on_door_state_changed(next_state: PrototypeDoorController.State) -> void:
	if next_state == PrototypeDoorController.State.CLOSED and _exit_pending_door_close:
		_finalize_customer_exit()


func _finalize_customer_exit() -> void:
	if not _exit_pending_door_close:
		return
	_exit_pending_door_close = false
	completed_cycles += 1
	_reward_granted = false
	_post_serve_elapsed = false
	_exit_delay_elapsed = false
	_timer_phase = &""
	_emit_event(&"customer_exited")
	cycle_completed.emit(completed_cycles)
	if auto_repeat_slice:
		_start_phase(&"next_customer", timing_config.next_customer_delay)


func _emit_event(event_name: StringName) -> void:
	lifecycle_event.emit(event_name)


func debug_summary() -> String:
	var customer_state: String = customer_slice.readable_state_name() if customer_slice != null else "No customer"
	var worker_state: String = worker_slice.readable_state_name() if worker_slice != null else "Unavailable"
	var movement_target: String = "-"
	if customer_mover != null and customer_mover.is_moving:
		movement_target = "Customer %s" % customer_mover.current_target
	elif worker_slice != null and worker_slice.mover.is_moving:
		movement_target = "Worker %s" % worker_slice.mover.current_target
	return "Loop #%d | Mode: %s | Timing: %s | Customer: %s | Worker: %s\nOrder: %s | Seat: %s | Prototype coins: %d | Route target: %s" % [
		cycle_number, "MANUAL" if is_manual_mode() else "AUTO LOOP", timing_config.preset,
		customer_state, worker_state,
		String(active_order_id) if active_order_id != &"" else "-",
		String(active_seat_id) if active_seat_id != &"" else "-", wallet.coins, movement_target
	]
