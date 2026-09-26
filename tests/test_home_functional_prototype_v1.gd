extends SceneTree
## End-to-end checks for the manual Home prototype and the shared automatic loop.

const HOME_SCENE: String = "res://scenes/home/home_scene.tscn"

var _home: HomeScene
var _controller: VerticalSliceController
var _interaction: HomeInteractionController
var _reward_count: int = 0
var _serve_count: int = 0
var _coffee_start_count: int = 0
var _maximum_active_customers: int = 0
var _spawned_seats: Array[StringName] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _run_manual_loop():
		quit(1)
		return
	if not await _run_auto_loop():
		quit(1)
		return
	if not await _run_gesture_tests():
		quit(1)
		return
	print("--- ALL HOME FUNCTIONAL PROTOTYPE V1 CHECKS PASSED ---")
	quit(0)


func _create_home(mode: VerticalSliceController.InteractionMode, repeat: bool) -> void:
	_reward_count = 0
	_serve_count = 0
	_coffee_start_count = 0
	_maximum_active_customers = 0
	_spawned_seats.clear()
	_home = (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	_controller = _home.get_node("VerticalSliceController") as VerticalSliceController
	_controller.interaction_mode = mode
	_controller.auto_repeat_slice = repeat
	_controller.customer_move_speed = 10000.0
	_controller.worker_move_speed = 10000.0
	_controller.timing_config = _controller.timing_config.duplicate_for_testing()
	_controller.timing_config.customer_order_delay = 0.04
	_controller.timing_config.customer_arrival_pause = 0.01
	_controller.timing_config.serve_duration = 0.04
	_controller.timing_config.served_reaction_duration = 0.04
	_controller.timing_config.customer_exit_delay = 0.01
	_controller.timing_config.door_hold_open_duration = 0.02
	_controller.timing_config.door_transition_duration = 0.02
	_controller.timing_config.next_customer_delay = 0.05
	_controller.coffee_order = _controller.coffee_order.duplicate(true) as SliceCoffeeOrder
	_controller.timing_config.coffee_preparation_duration = 0.08
	var door := _home.get_node("PrototypeDoorController") as PrototypeDoorController
	door.timing_config = _controller.timing_config
	_controller.lifecycle_event.connect(_on_lifecycle_event)
	_controller.wallet.reward_added.connect(_on_reward_added)
	root.add_child(_home)


func _run_manual_loop() -> bool:
	_create_home(VerticalSliceController.InteractionMode.MANUAL, false)
	await process_frame
	await process_frame
	_interaction = _home.get_node("HomeInteractionController") as HomeInteractionController
	var mochi := _home.get_node("World/DepthSortedLayer/MochiScaleTestDEV") as MochiScaleTest
	if _controller.interaction_mode != VerticalSliceController.InteractionMode.MANUAL or \
		_controller.worker_slice.get_parent() != mochi:
		return _fail("Default Home did not start in manual mode with the existing SliceWorker attached to canonical Mochi")
	if _home.get_node("World/DepthSortedLayer").get_node_or_null("WorkerCatPlaceholder") != null or \
		get_nodes_in_group(&"prototype_worker").size() != 1:
		return _fail("Home must use only one active Vertical Slice worker state machine")
	print("[PASS] Default manual mode uses the same single SliceWorker/Mover on canonical Mochi.")

	if _interaction.interact_with_target(&"espresso_station"):
		return _fail("Espresso tap without an order must not start preparation")
	if _controller.worker_slice.state != SliceWorker.State.IDLE or _controller.wallet.coins != 0:
		return _fail("Invalid Espresso interaction changed worker or reward state")
	print("[PASS] Invalid Espresso interaction before an order is harmless.")

	if not await _wait_for_order(300):
		return _fail("Manual customer did not enter, claim a seat, and place the coffee order")
	var order_bubble := _controller.customer.get_node_or_null("OrderBubble") as PrototypeOrderBubble
	if order_bubble == null or order_bubble.ready_for_serve or _controller.active_order_id != &"order_coffee_basic_01":
		return _fail("Waiting customer did not receive the expected temporary coffee-order bubble")
	var customer_cue := _controller.customer.get_node_or_null("CustomerReadabilityCue") as PrototypeCustomerReadabilityCue
	var coffee_cue := _home.get_node_or_null("World/FXLayer/PrototypeCoffeeReadabilityCue") as PrototypeCoffeeReadabilityCue
	if customer_cue == null or not customer_cue.visible or coffee_cue == null or \
		order_bubble.position.y < -180.0 or _controller.customer.show_role_badge:
		return _fail("Normal-view order feedback is missing, detached, or obscured by the old customer debug badge")
	if coffee_cue.cue_kind() != &"tap_station":
		return _fail("Waiting coffee order must visibly prompt the player to tap Espresso Station")
	if not _controller.seat_occupancy.has(_controller.active_seat_id):
		return _fail("Assigned semantic seat is not marked occupied")
	if _controller.worker_slice.state != SliceWorker.State.IDLE:
		return _fail("Manual order creation started preparation without a player action")
	_interaction.interact_with_target(&"active_customer")
	if _controller.worker_slice.state != SliceWorker.State.IDLE:
		return _fail("Selecting a waiting customer should only show state, not start gameplay")
	print("[PASS] Customer arrives, gets an A–D semantic seat, displays Coffee Order, and waits for Espresso interaction.")

	if not _interaction.interact_with_target(&"espresso_station"):
		return _fail("Valid Espresso interaction did not start coffee preparation")
	_interaction.interact_with_target(&"espresso_station")
	if not await _wait_for_preparation_and_ready(300):
		return _fail("Mochi did not prepare coffee and reach the serve point")
	if _coffee_start_count != 1:
		return _fail("Rapid Espresso taps started more than one preparation action")
	if _controller.customer_slice.state != SliceCustomer.State.READY_FOR_SERVE or not order_bubble.ready_for_serve:
		return _fail("Customer order was not updated to its ready-to-serve feedback state")
	if not customer_cue.visible or coffee_cue.cue_kind() != &"coffee_ready":
		return _fail("Ready coffee or customer serve-target cue is missing in normal view")
	var carry := mochi.get_node("CarryCupPlaceholder") as PrototypeCarryVisual
	if not carry.visible:
		return _fail("Ready coffee is not visibly carried with Mochi")
	print("[PASS] Espresso tap starts one brew, machine progress feedback appears, and the cup follows Mochi to ServePoint.")

	if not _interaction.interact_with_target(&"active_customer"):
		return _fail("Tapping the waiting customer at the serve point did not begin service")
	_interaction.interact_with_target(&"active_customer")
	if not await _wait_for_cycles(1, 500):
		return _fail("Manual loop did not finish service, reward, customer exit, and door close")
	await process_frame
	if _reward_count != 1 or _serve_count != 1 or _controller.wallet.coins != _controller.coffee_order.reward_coins:
		return _fail("Rapid/repeated serve interaction granted anything other than one reward")
	if _controller.customer != null or not _controller.seat_occupancy.is_empty() or _controller.active_seat_id != &"":
		return _fail("Customer exit did not release its seat and clear the active customer")
	if _controller.worker_slice.state != SliceWorker.State.IDLE or \
		_controller.worker_actor.global_position.distance_to(_controller.get_marker_position(GameplayID.WORKER_IDLE)) > 0.1:
		return _fail("Mochi did not return to WorkerIdle after service")
	if _home.get_node("PrototypeDoorController").state != PrototypeDoorController.State.CLOSED:
		return _fail("Entrance door did not return to CLOSED after customer exit")
	if carry.visible:
		return _fail("Carried coffee placeholder survived after service/reset")
	if coffee_cue.cue_kind() != &"none":
		return _fail("World-space coffee readiness cue survived loop reset")
	if is_instance_valid(order_bubble):
		return _fail("Order bubble survived after service")
	_controller.call("_on_serve_finished")
	if _reward_count != 1 or _controller.wallet.coins != _controller.coffee_order.reward_coins:
		return _fail("Repeated serve completion callback duplicated the reward")
	if not _controller.wallet.add_reward(_controller.coffee_order.reward_coins, StringName("%s#%d" % [
		String(_controller.coffee_order.order_id), _controller.cycle_number])):
		print("[PASS] Reward ledger rejects a duplicate order-instance reward.")
	else:
		return _fail("Reward ledger accepted the same order-instance ID twice")
	print("[PASS] One serve gives exactly one reward; order/cup disappear, seat releases, Mochi idles, and door closes.")
	_home.queue_free()
	await process_frame
	return true


func _run_auto_loop() -> bool:
	_create_home(VerticalSliceController.InteractionMode.AUTO_LOOP, true)
	if not await _wait_for_cycles(2, 1000):
		return _fail("AUTO LOOP did not complete two cycles without taps")
	if _reward_count != 2 or _controller.completed_cycles != 2 or _maximum_active_customers > 1:
		return _fail("AUTO LOOP reward count or one-customer-at-a-time safety regressed")
	if _controller.worker_slice.get_parent() != _controller.worker_actor or \
		(_controller.customer_slice != null and not (_controller.customer_slice is SliceCustomer)):
		return _fail("Manual and automatic modes did not share the same customer/worker state components")
	if _spawned_seats.size() < 2 or _spawned_seats[0] != GameplayID.SEAT_MAIN_A or _spawned_seats[1] != GameplayID.SEAT_MAIN_B:
		return _fail("Seat A–D allocation did not advance/reuse semantic seat IDs deterministically")
	if not _controller.seat_occupancy.is_empty() or _controller.worker_slice.state != SliceWorker.State.IDLE:
		return _fail("AUTO LOOP ended a cycle with a stale seat or non-idle worker")
	print("[PASS] AUTO LOOP completes two cycles in the same shared state machine, rotates seats, and never overlaps customers.")
	_home.queue_free()
	await process_frame
	return true


func _run_gesture_tests() -> bool:
	_create_home(VerticalSliceController.InteractionMode.MANUAL, false)
	await process_frame
	await process_frame
	_interaction = _home.get_node("HomeInteractionController") as HomeInteractionController
	var camera := _home.get_node("CameraRig") as CameraController
	var debug := _home.get_node("UI/DebugOverlay") as DebugOverlay
	var mode_toggle := InputEventKey.new()
	mode_toggle.keycode = KEY_F7
	mode_toggle.pressed = true
	_controller.call("_unhandled_input", mode_toggle)
	if _controller.interaction_mode != VerticalSliceController.InteractionMode.AUTO_LOOP:
		return _fail("F7 did not switch from manual mode to AUTO LOOP")
	_controller.call("_unhandled_input", mode_toggle)
	if _controller.interaction_mode != VerticalSliceController.InteractionMode.MANUAL:
		return _fail("F7 did not switch back to PROTOTYPE MANUAL")
	var station := _home.get_node("World/BackDecorLayer/EspressoStationSlot") as Node2D
	var point: Vector2 = camera.get_canvas_transform() * station.global_position
	var initial_interactions: int = _interaction.interaction_count
	if _interaction.show_hit_areas:
		return _fail("Interaction hit areas should be hidden when Debug View is OFF")
	debug.toggle_master_debug()
	if not _interaction.show_hit_areas:
		return _fail("Debug View did not reveal the interaction hit regions")
	_interaction.interact_with_target(&"espresso_station")
	var inspector_text: String = _home.get_node("UI/TopHUDSafeArea/PrototypeStatusLabel").text
	if not inspector_text.contains("Asset ID: espresso_basic_01") or not inspector_text.contains("Layer: BackDecorLayer") \
		or not inspector_text.contains("Interaction: COFFEE_STATION"):
		return _fail("Debug inspection did not include asset ID, slot layer, and interaction role")
	debug.toggle_master_debug()
	if _interaction.show_hit_areas:
		return _fail("Interaction hit areas remained visible after Debug View was turned OFF")
	initial_interactions = _interaction.interaction_count
	_simulate_touch_drag(camera, point)
	if _interaction.interaction_count != initial_interactions:
		return _fail("Touch drag/pan was misread as a station tap")
	_simulate_pinch(camera, point)
	if _interaction.interaction_count != initial_interactions:
		return _fail("Pinch zoom was misread as an object tap")
	_simulate_mouse_drag(camera, point)
	if _interaction.interaction_count != initial_interactions:
		return _fail("Mouse drag/pan was misread as an object tap")
	_simulate_clean_mouse_tap(camera, point)
	if _interaction.interaction_count != initial_interactions + 1 or _interaction.last_interaction_id != &"espresso_station":
		return _fail("Clean desktop mouse tap did not resolve the world-space Espresso hit area")
	if _controller.interaction_mode == VerticalSliceController.InteractionMode.MANUAL and \
		(_home.get_node("World/DepthSortedLayer").get_node("MochiScaleTestDEV") as MochiScaleTest).rendered_height_px() < 149.0:
		return _fail("Mochi canonical gameplay scale changed during interaction setup")
	print("[PASS] Screen-space touch/mouse thresholds cancel drags and pinch; clean tap resolves a semantic world hit area.")
	_home.queue_free()
	await process_frame
	return true


func _wait_for_order(frame_limit: int) -> bool:
	for _frame in range(frame_limit):
		await process_frame
		if _controller.active_order_id != &"":
			return true
	return false


func _wait_for_preparation_and_ready(frame_limit: int) -> bool:
	var saw_preparing: bool = false
	var saw_feedback: bool = false
	var feedback := _home.get_node("World/BackDecorLayer/EspressoStationSlot/PreparationFeedback") as PrototypePreparationFeedback
	var readability_cue := _home.get_node("World/FXLayer/PrototypeCoffeeReadabilityCue") as PrototypeCoffeeReadabilityCue
	for _frame in range(frame_limit):
		await process_frame
		if _controller.worker_slice.state == SliceWorker.State.PREPARING_COFFEE:
			saw_preparing = true
			if readability_cue.cue_kind() != &"brewing":
				return false
			if not feedback.visible:
				await process_frame
			if not saw_feedback and feedback.visible and feedback.worker != null and feedback.worker.action_progress() >= 0.0:
				print("[PASS] Preparation feedback is attached to the Espresso Station with a live progress value.")
				saw_feedback = true
		if _controller.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
			return saw_preparing and saw_feedback and feedback.worker != null
	return false


func _wait_for_cycles(target_count: int, frame_limit: int) -> bool:
	for _frame in range(frame_limit):
		await process_frame
		var active: int = 0
		for child in _home.get_node("World/DepthSortedLayer").get_children():
			if child is CharacterPlaceholder and (child as CharacterPlaceholder).role == "Customer" and child.visible:
				active += 1
		_maximum_active_customers = maxi(_maximum_active_customers, active)
		if _controller.completed_cycles >= target_count:
			return true
	return false


func _on_lifecycle_event(event_name: StringName) -> void:
	if event_name == &"coffee_start":
		_coffee_start_count += 1
	elif event_name == &"worker_serves":
		_serve_count += 1
	elif event_name == &"customer_spawned":
		_spawned_seats.append(_controller.active_seat_id)


func _on_reward_added(_amount: int, _total: int, _order_instance_id: StringName) -> void:
	_reward_count += 1


func _simulate_touch_drag(camera: CameraController, point: Vector2) -> void:
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.position = point
	down.pressed = true
	camera.call("_handle_screen_touch", down)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = point + Vector2(18.0, 0.0)
	drag.relative = Vector2(18.0, 0.0)
	camera.call("_handle_screen_drag", drag)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.position = drag.position
	up.pressed = false
	camera.call("_handle_screen_touch", up)


func _simulate_pinch(camera: CameraController, point: Vector2) -> void:
	var first := InputEventScreenTouch.new()
	first.index = 0
	first.position = point
	first.pressed = true
	camera.call("_handle_screen_touch", first)
	var second := InputEventScreenTouch.new()
	second.index = 1
	second.position = point + Vector2(100.0, 0.0)
	second.pressed = true
	camera.call("_handle_screen_touch", second)
	var pinch := InputEventScreenDrag.new()
	pinch.index = 1
	pinch.position = point + Vector2(120.0, 0.0)
	pinch.relative = Vector2(20.0, 0.0)
	camera.call("_handle_screen_drag", pinch)
	first.pressed = false
	camera.call("_handle_screen_touch", first)
	second.pressed = false
	camera.call("_handle_screen_touch", second)


func _simulate_mouse_drag(camera: CameraController, point: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = point
	down.pressed = true
	camera.call("_handle_mouse_button", down)
	var motion := InputEventMouseMotion.new()
	motion.position = point + Vector2(20.0, 0.0)
	motion.relative = Vector2(20.0, 0.0)
	camera.call("_handle_mouse_motion", motion)
	down.position = motion.position
	down.pressed = false
	camera.call("_handle_mouse_button", down)


func _simulate_clean_mouse_tap(camera: CameraController, point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = true
	camera.call("_handle_mouse_button", event)
	event.pressed = false
	camera.call("_handle_mouse_button", event)


func _fail(message: String) -> bool:
	printerr("[FAIL] " + message)
	if is_instance_valid(_home):
		_home.queue_free()
	return false
