extends SceneTree
## Contract coverage and ten clean MANUAL/AUTO loops through the real shared Home state machine.

const HOME_SCENE: String = "res://scenes/home/home_scene.tscn"
const CATALOG_PATH: String = "res://data/home_visual_asset_catalog.tres"
const REQUIRED_IDS: Array[StringName] = [
	&"architecture_home_01", &"counter_basic_01", &"espresso_basic_01",
	&"grinder_basic_01", &"pos_basic_01", &"pastry_case_basic_01",
	&"pastry_set_basic_01", &"table_round_01", &"chair_jade_01",
	&"plant_floor_01", &"plant_counter_01", &"vase_basic_01",
	&"entrance_door_01", &"sign_main_01", &"sign_hanging_01",
	&"sign_menu_01", &"sign_freestanding_01"
]
const LOOP_TARGET: int = 10

var _home: HomeScene
var _controller: VerticalSliceController
var _interaction: HomeInteractionController
var _mode: VerticalSliceController.InteractionMode
var _completed_count: int = 0
var _coffee_starts: int = 0
var _serves: int = 0
var _rewards: int = 0
var _max_customers: int = 0
var _errors: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _check_asset_contracts():
		quit(1)
		return
	if not await _run_repeated_mode(VerticalSliceController.InteractionMode.MANUAL):
		quit(1)
		return
	if not await _run_repeated_mode(VerticalSliceController.InteractionMode.AUTO_LOOP):
		quit(1)
		return
	if not await _check_development_controls():
		quit(1)
		return
	print("--- ALL HOME PLAYTEST-READY CORE LOOP V1 CHECKS PASSED ---")
	quit(0)


func _check_asset_contracts() -> bool:
	var catalog := load(CATALOG_PATH) as HomeAssetCatalog
	if catalog == null or catalog.definitions.size() != REQUIRED_IDS.size() \
		or not catalog.validate_unique_ids() or not catalog.validate_complete_contracts():
		return _fail("Catalog must contain exactly 17 unique IDs with complete contracts")
	for asset_id in REQUIRED_IDS:
		var definition: HomeAssetDefinition = catalog.find_asset(asset_id)
		if definition == null or not definition.validate_slot_contracts():
			return _fail("Stable asset ID has an incomplete contract: %s" % String(asset_id))
	var home := (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	(home.get_node("VerticalSliceController") as VerticalSliceController).start_on_ready = false
	root.add_child(home)
	await process_frame
	var seen_roles: Dictionary = {}
	var count: int = 0
	var expected_contract_count: int = 0
	for definition in catalog.definitions:
		expected_contract_count += definition.slot_contracts.size()
	for item in get_nodes_in_group(&"home_asset_slots"):
		var slot := item as HomeAssetSlot
		if slot == null or slot.asset_id == &"":
			continue
		count += 1
		var key: StringName = StringName("%s::%s" % [String(slot.asset_id), String(slot.slot_role)])
		if slot.contract == null or seen_roles.has(key) or not slot.contract.has_valid_contract():
			home.queue_free()
			return _fail("Missing/duplicate runtime slot contract: %s" % String(key))
		seen_roles[key] = true
		var variant: StringName = slot.variant_override if slot.variant_override != &"" else slot.definition.visual_variant
		if variant != slot.contract.visual_variant or slot.position.distance_to(slot.contract.default_local_position) > 0.01:
			home.queue_free()
			return _fail("Variant or authored anchor does not match slot contract: %s" % String(key))
		if _actual_layer(slot) != slot.contract.owner_layer:
			home.queue_free()
			return _fail("Runtime layer does not match the slot contract: %s" % String(key))
		if slot.contract.target_bounds.x <= 0.0 or slot.contract.target_bounds.y <= 0.0 \
			or slot.contract.pivot_type.is_empty() or slot.contract.replaceability not in [
				"REPLACEABLE_VISUAL", "REPLACEABLE_FULL_CANVAS", "STRUCTURAL_RUNTIME"] \
			or slot.contract.status != "TEMP PLACEHOLDER" or not slot.contract.final_art_required:
			home.queue_free()
			return _fail("Slot is missing usable target bounds, pivot or replacement policy: %s" % String(key))
	if count != 26 or expected_contract_count != count or seen_roles.size() != expected_contract_count:
		home.queue_free()
		return _fail("Expected a one-to-one match across 26 role contracts and scene instances; found %d/%d" % [count, expected_contract_count])
	var counter_back := home.get_node("World/BackDecorLayer/CounterBackSlot") as HomeAssetSlot
	var counter_front := home.get_node("World/ForegroundOccluderLayer/CounterFrontSlot") as HomeAssetSlot
	var espresso := home.get_node("World/BackDecorLayer/EspressoStationSlot") as HomeAssetSlot
	var pastry := home.get_node("World/BackDecorLayer/PastryDisplaySlot") as HomeAssetSlot
	var grinder := home.get_node("World/BackDecorLayer/GrinderSlot") as HomeAssetSlot
	var pos := home.get_node("World/BackDecorLayer/POSSlot") as HomeAssetSlot
	if counter_back.contract.occlusion_role != &"COUNTER_BACK_SURFACE" \
		or counter_front.contract.occlusion_role != &"COUNTER_FRONT_OCCLUDER" \
		or espresso.get_parent() != home.get_node("World/BackDecorLayer") \
		or pastry.get_parent() != home.get_node("World/BackDecorLayer") \
		or grinder.get_parent() != home.get_node("World/BackDecorLayer") \
		or pos.get_parent() != home.get_node("World/BackDecorLayer"):
		home.queue_free()
		return _fail("Counter visual parts must remain separate from station/display props")
	var floor_table := home.get_node("World/DepthSortedLayer/Table1Slot") as HomeAssetSlot
	var door_leaf := home.get_node("World/DepthSortedLayer/EntranceDoorLeftLeafSlot") as HomeAssetSlot
	var chair := home.get_node("World/DepthSortedLayer/ChairTable1LeftSlot") as HomeAssetSlot
	var sign := home.get_node("World/DepthSortedLayer/SignFreestandingSlot") as HomeAssetSlot
	if not floor_table.contract.y_sort_required or not door_leaf.contract.y_sort_required \
		or not chair.contract.y_sort_required \
		or floor_table.contract.pivot_type != "FLOOR_CONTACT_BOTTOM_CENTER" \
		or sign.contract.pivot_type != "FLOOR_CONTACT_BOTTOM_CENTER" or not sign.contract.y_sort_required \
		or not (home.get_node("World/DepthSortedLayer") as Node2D).y_sort_enabled:
		home.queue_free()
		return _fail("Depth-sensitive floor assets must keep bottom-center pivots and the existing DepthSortedLayer")
	var dynamic_signs := home.get_node_or_null("DynamicSignage")
	if dynamic_signs == null or home.get_node("DynamicSignage/CafeNameSurface").get_text() != "" \
		or home.get_node("DynamicSignage/MenuSloganSurface").get_text() != "":
		home.queue_free()
		return _fail("Sign copy must remain runtime-driven and blank in the graybox")
	home.queue_free()
	await process_frame
	print("[PASS] 17 stable IDs have 26 unique slot contracts; bounds/pivots/layers/variants remain authored, counter parts are separate, and sign text stays runtime-driven.")
	return true


func _run_repeated_mode(mode: VerticalSliceController.InteractionMode) -> bool:
	_reset_counts()
	_mode = mode
	_home = (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	_controller = _home.get_node("VerticalSliceController") as VerticalSliceController
	_controller.start_on_ready = false
	_controller.auto_repeat_slice = true
	_controller.interaction_mode = mode
	_controller.customer_move_speed = 10000.0
	_controller.worker_move_speed = 10000.0
	_controller.timing_config = _controller.timing_config.duplicate_for_testing()
	_controller.timing_config.set_preset("FAST")
	_controller.timing_config.customer_arrival_pause = 0.02
	_controller.timing_config.customer_order_delay = 0.02
	_controller.timing_config.coffee_preparation_duration = 0.06
	_controller.timing_config.serve_duration = 0.02
	_controller.timing_config.served_reaction_duration = 0.02
	_controller.timing_config.customer_exit_delay = 0.02
	_controller.timing_config.door_transition_duration = 0.04
	_controller.timing_config.door_hold_open_duration = 0.02
	_controller.timing_config.next_customer_delay = 0.02
	var door := _home.get_node("PrototypeDoorController") as PrototypeDoorController
	door.timing_config = _controller.timing_config
	root.add_child(_home)
	await process_frame
	await process_frame
	_interaction = _home.get_node("HomeInteractionController") as HomeInteractionController
	_controller.lifecycle_event.connect(_on_lifecycle_event)
	_controller.cycle_completed.connect(_on_cycle_completed)
	_controller.wallet.reward_added.connect(_on_reward_added)
	_controller.worker_slice.state_changed.connect(_on_worker_state_changed)
	_controller.start_slice()
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		if _interaction.interact_with_target(&"espresso_station"):
			return _fail("Invalid Espresso tap without an order should be rejected")
		if _controller.worker_slice.state != SliceWorker.State.IDLE or _rewards != 0:
			return _fail("Invalid Espresso tap changed worker or reward state")
	for _frame in range(10000):
		await process_frame
		_max_customers = maxi(_max_customers, _active_customer_count())
		if _completed_count >= LOOP_TARGET:
			break
	if _completed_count != LOOP_TARGET or _controller.completed_cycles != LOOP_TARGET \
		or _rewards != LOOP_TARGET or _serves != LOOP_TARGET or _max_customers > 1 or not _errors.is_empty():
		_home.queue_free()
		return _fail("%s repeated loops failed: loops=%d rewards=%d serves=%d max_customers=%d errors=%s" % [
			"MANUAL" if mode == VerticalSliceController.InteractionMode.MANUAL else "AUTO",
			_completed_count, _rewards, _serves, _max_customers, _errors
		])
	if mode == VerticalSliceController.InteractionMode.MANUAL and _coffee_starts != LOOP_TARGET:
		_home.queue_free()
		return _fail("MANUAL loop accepted a repeated espresso action or missed an order")
	var label: String = "MANUAL" if mode == VerticalSliceController.InteractionMode.MANUAL else "AUTO"
	print("[PASS] %s mode completes ten consecutive loops with one reward/order, no overlap, and clean customer/order/cup/seat/door/worker/route reset per cycle." % label)
	_home.queue_free()
	await process_frame
	return true


func _on_lifecycle_event(event_name: StringName) -> void:
	if event_name == &"customer_spawned":
		for child in _home.get_node("World/FXLayer").get_children():
			if child is SliceRewardFX and not child.is_queued_for_deletion():
				_errors.append("A previous reward callout survived into the next customer loop")
	elif event_name == &"coffee_start":
		_coffee_starts += 1
	elif event_name == &"worker_serves":
		_serves += 1
	elif event_name == &"order_created" and _mode == VerticalSliceController.InteractionMode.MANUAL:
		_interaction.interact_with_target(&"espresso_station")
		_interaction.interact_with_target(&"espresso_station")
	elif event_name == &"worker_ready_to_serve" and _mode == VerticalSliceController.InteractionMode.MANUAL:
		_interaction.interact_with_target(&"pastry_case")
		if _controller.worker_slice.state != SliceWorker.State.READY_TO_SERVE:
			_errors.append("An invalid wrong-object tap changed the ready-to-serve state")
		_interaction.interact_with_target(&"active_customer")
		_interaction.interact_with_target(&"active_customer")


func _on_cycle_completed(cycle: int) -> void:
	if cycle != _completed_count + 1:
		_errors.append("Cycle completion signal skipped or repeated a loop number")
	_completed_count = cycle
	if _controller.customer != null or _controller.customer_slice != null \
		or _controller.customer_mover != null or _controller.active_order_id != &"" \
		or _controller.active_order_instance_id != &"" or _controller.active_seat_id != &"" \
		or not _controller.seat_occupancy.is_empty() or _controller._reward_granted \
		or _controller._exit_pending_door_close or _controller._timer_phase != &"":
		_errors.append("Cycle %d retained customer, order, reward, seat, or timer state" % cycle)
	if _controller.worker_slice.state != SliceWorker.State.IDLE \
		or _controller.worker_slice.mover.is_moving \
		or _controller.worker_slice.mover.current_target != Vector2.ZERO \
		or _controller.worker_actor.global_position.distance_to(_controller.get_marker_position(GameplayID.WORKER_IDLE)) > 0.1:
		_errors.append("Cycle %d did not return Mochi and its route target to idle" % cycle)
	if _controller.door_controller.state != PrototypeDoorController.State.CLOSED:
		_errors.append("Cycle %d left the entrance door open" % cycle)
	var carry := _controller.worker_actor.get_node_or_null("CarryCupPlaceholder") as PrototypeCarryVisual
	if carry == null or carry.visible:
		_errors.append("Cycle %d left the temporary carry visual visible" % cycle)
	var selection := _home.get_node("World/FXLayer/PrototypeSelectionFeedback") as PrototypeSelectionFeedback
	if selection.visible:
		_errors.append("Cycle %d retained the previous selection highlight" % cycle)
	if _controller.wallet.coins != cycle * _controller.coffee_order.reward_coins:
		_errors.append("Cycle %d did not award exactly one reward" % cycle)
	if _active_customer_count() > 0:
		_errors.append("Cycle %d overlapped the previous customer" % cycle)


func _on_reward_added(_amount: int, _total: int, _order_id: StringName) -> void:
	_rewards += 1


func _on_worker_state_changed(state: SliceWorker.State) -> void:
	if _mode == VerticalSliceController.InteractionMode.AUTO_LOOP and state == SliceWorker.State.READY_TO_SERVE:
		_errors.append("AUTO loop unexpectedly waited for a manual serve action")


func _active_customer_count() -> int:
	var count: int = 0
	for child in _home.get_node("World/DepthSortedLayer").get_children():
		if child is CharacterPlaceholder and (child as CharacterPlaceholder).role == "Customer" \
			and child.visible and not child.is_queued_for_deletion():
			count += 1
	return count


func _actual_layer(slot: HomeAssetSlot) -> StringName:
	var current: Node = slot.get_parent()
	while current != null:
		if current.name in [&"StructuralBase", &"RoomSkinLayer", &"BackDecorLayer", &"DepthSortedLayer",
			&"ForegroundOccluderLayer", &"FXLayer"]:
			return StringName(current.name)
		current = current.get_parent()
	return &""


func _check_development_controls() -> bool:
	_home = (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	_controller = _home.get_node("VerticalSliceController") as VerticalSliceController
	_controller.start_on_ready = false
	_controller.timing_config = _controller.timing_config.duplicate_for_testing()
	root.add_child(_home)
	await process_frame
	if _controller.timing_config.preset != "NORMAL" or _controller.timing_config.resolve_duration(2.0) != 2.0:
		_home.queue_free()
		return _fail("NORMAL timing preset must preserve the authored duration")
	var f8 := InputEventKey.new()
	f8.keycode = KEY_F8
	f8.pressed = true
	_controller.call("_unhandled_input", f8)
	if _controller.timing_config.preset != "FAST" or not is_equal_approx(
		_controller.timing_config.resolve_duration(2.0), 0.4) \
		or not _controller.debug_summary().contains("Timing: FAST"):
		_home.queue_free()
		return _fail("F8 must switch to the shared FAST timing preset and expose it in debug status")
	_controller.call("_unhandled_input", f8)
	if _controller.timing_config.preset != "NORMAL":
		_home.queue_free()
		return _fail("F8 must toggle timing back to NORMAL")
	_home.queue_free()
	await process_frame
	print("[PASS] F8 toggles centralized NORMAL/FAST timing; debug state reports loop, route, mode and timing preset.")
	return true


func _reset_counts() -> void:
	_completed_count = 0
	_coffee_starts = 0
	_serves = 0
	_rewards = 0
	_max_customers = 0
	_errors.clear()


func _fail(message: String) -> bool:
	printerr("[PLAYTEST CORE LOOP FAIL] " + message)
	return false
