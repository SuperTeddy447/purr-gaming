extends SceneTree
## End-to-end presentation contract on the real Home loop, in both interaction modes.

const HOME: PackedScene = preload("res://scenes/home/home_scene.tscn")

var _home: HomeScene
var _slice: VerticalSliceController
var _presentation: TrueSlicePresentation
var _interaction: HomeInteractionController
var _ambient: LivingCafeAmbientController
var _events: Array[StringName] = []
var _worker_actions: Array[StringName] = []
var _customer_actions: Array[StringName] = []
var _audio: Array[StringName] = []
var _haptics: Array[StringName] = []
var _progress: Array[float] = []
var _rewards: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _run_loop(VerticalSliceController.InteractionMode.MANUAL):
		quit(1)
		return
	if not await _run_loop(VerticalSliceController.InteractionMode.AUTO_LOOP):
		quit(1)
		return
	if not await _check_default_startup():
		quit(1)
		return
	print("--- ALL TRUE VERTICAL SLICE 001 CHECKS PASSED ---")
	quit(0)


func _setup(mode: VerticalSliceController.InteractionMode) -> void:
	_events.clear()
	_worker_actions.clear()
	_customer_actions.clear()
	_audio.clear()
	_haptics.clear()
	_progress.clear()
	_rewards = 0
	_home = HOME.instantiate() as HomeScene
	_slice = _home.get_node("VerticalSliceController") as VerticalSliceController
	_slice.start_on_ready = false
	_slice.auto_repeat_slice = false
	_slice.interaction_mode = mode
	_slice.customer_move_speed = 10000.0
	_slice.worker_move_speed = 10000.0
	_slice.timing_config = _slice.timing_config.duplicate_for_testing()
	_slice.timing_config.set_preset("FAST")
	_slice.timing_config.customer_arrival_pause = 0.02
	_slice.timing_config.customer_order_delay = 0.04
	_slice.timing_config.coffee_preparation_duration = 0.12
	_slice.timing_config.serve_duration = 0.04
	_slice.timing_config.served_reaction_duration = 0.04
	_slice.timing_config.customer_exit_delay = 0.02
	_slice.timing_config.door_transition_duration = 0.04
	_slice.timing_config.door_hold_open_duration = 0.03
	(_home.get_node("PrototypeDoorController") as PrototypeDoorController).timing_config = _slice.timing_config
	root.add_child(_home)
	_presentation = _home.get_node("TrueSlicePresentation") as TrueSlicePresentation
	_interaction = _home.get_node("HomeInteractionController") as HomeInteractionController
	_ambient = _home.get_node("LivingCafeAmbientController") as LivingCafeAmbientController
	_presentation.slice_event.connect(func(id: StringName) -> void: _events.append(id))
	_presentation.mochi_action_changed.connect(func(id: StringName) -> void: _worker_actions.append(id))
	_presentation.customer_action_changed.connect(func(id: StringName) -> void: _customer_actions.append(id))
	_presentation.audio_cue.connect(func(id: StringName) -> void: _audio.append(id))
	_presentation.haptic_cue.connect(func(id: StringName) -> void: _haptics.append(id))
	_presentation.coffee_prepare_progress.connect(func(value: float) -> void: _progress.append(value))
	_slice.wallet.reward_added.connect(func(_amount: int, _total: int, _id: StringName) -> void: _rewards += 1)


func _run_loop(mode: VerticalSliceController.InteractionMode) -> bool:
	_setup(mode)
	await process_frame
	var mochi: LivingCafeAmbientController.Agent = _ambient.agent_for(&"Mochi")
	if not _check(_presentation.mochi_action == &"idle" and mochi != null and not mochi.work_priority,
		"The slice must begin in available Living Café state"):
		return false
	if not _check_mochi_walk_resolution():
		return false
	if not _check(_slice.coffee_order.order_id == &"order_coffee_basic_01" and _slice.customer_scene != null,
		"Slice scope must stay on the single coffee order and customer archetype"):
		return false
	if not _check(_home.get_node_or_null("World/DepthSortedLayer/MochiScaleTestDEV/MochiAnimationSlot") != null \
		and _home.get_node("World/DepthSortedLayer").y_sort_enabled \
		and _home.get_node_or_null("World/FXLayer/TrueSliceMomentFX") != null,
		"Semantic animation slot and locked depth owner must exist"):
		return false
	_slice.start_slice()
	if not await _wait_for_order():
		return _fail("Order did not appear")
	if not _check(_presentation.customer_action == &"order" and mochi.work_priority \
		and _slice.customer.get_node_or_null("CustomerAnimationSlot") != null \
		and _slice.customer.get_node_or_null("OrderBubble") != null,
		"Customer order presentation or ambient interruption is missing"):
		return false
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		if not _check(_interaction.interact_with_target(&"espresso_station"), "Manual espresso tap must start work"):
			return false
	if not await _wait_for_worker(SliceWorker.State.PREPARING_COFFEE):
		return _fail("Mochi did not reach coffee preparation")
	if not _check(_presentation.mochi_action == &"prepare_coffee" and mochi.work_priority \
		and not (_slice.worker_actor.get_node("WorkerActionLabel") as Label).visible,
		"Prepare action must be semantic and developer label hidden in normal view"):
		return false
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		var debug := _home.get_node("UI/DebugOverlay") as DebugOverlay
		debug.toggle_master_debug()
		if not _check((_slice.worker_actor.get_node("WorkerActionLabel") as Label).visible,
			"Developer action label must be visible only in Debug View"):
			return false
		debug.toggle_master_debug()
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		if not await _wait_for_worker(SliceWorker.State.READY_TO_SERVE):
			return _fail("Coffee did not become ready")
	elif not await _wait_for_carry():
		return _fail("AUTO coffee did not enter the carry phase")
	var cup := _slice.worker_actor.get_node("CarryCupPlaceholder") as PrototypeCarryVisual
	if not _check(cup.visible and _presentation.mochi_action == &"carry_coffee" \
		and _slice.customer_slice.state == SliceCustomer.State.READY_FOR_SERVE,
		"Carry presentation did not follow ready coffee"):
		return false
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		if not _check(_interaction.interact_with_target(&"active_customer"), "Manual serve tap must start service"):
			return false
	if not await _wait_for_completion():
		return _fail("Customer did not exit and close the loop")
	if not _check(_rewards == 1 and _events.count(&"coffee_served") == 1 \
		and _events.count(&"reward") == 1, "Serve and reward must each happen once"):
		return false
	if not _check(not _progress.is_empty() and is_equal_approx(_progress.back(), 1.0),
		"Preparation must emit progress and finish at 100%"):
		return false
	if not _check(not cup.visible and _slice.customer == null and _slice.active_order_id == &"" \
		and _slice.active_order_instance_id == &"" and _slice.active_seat_id == &"" \
		and _slice.seat_occupancy.is_empty() and not _slice.worker_slice.mover.is_moving \
		and _slice.worker_slice.state == SliceWorker.State.IDLE \
		and not mochi.work_priority and _ambient.reservations.get(&"WORKER_IDLE") == &"Mochi" \
		and _presentation.customer_action == &"none" \
		and (_home.get_node("PrototypeDoorController") as PrototypeDoorController).state == PrototypeDoorController.State.CLOSED,
		"Reset must clear cup/order/seat/route and return to Living Café (cup=%s customer=%s order=%s instance=%s seat=%s seats=%d moving=%s worker=%s priority=%s reservation=%s customer_action=%s door=%s)" % [
			cup.visible, _slice.customer, String(_slice.active_order_id), String(_slice.active_order_instance_id),
			String(_slice.active_seat_id), _slice.seat_occupancy.size(), _slice.worker_slice.mover.is_moving,
			_slice.worker_slice.state_name(), mochi.work_priority, str(_ambient.reservations.get(&"WORKER_IDLE")),
			String(_presentation.customer_action), (_home.get_node("PrototypeDoorController") as PrototypeDoorController).state_name()]):
		return false
	if not _check(_ordered([&"door_open", &"customer_enter", &"customer_threshold_entry", &"door_close",
		&"order_appear", &"coffee_prepare_started", &"coffee_prepare_completed", &"coffee_pickup",
		&"coffee_served", &"customer_satisfied", &"reward", &"customer_threshold_exit",
		&"door_close_complete", &"customer_exit"]), "Slice/door/coffee events are out of order: %s" % str(_events)):
		return false
	for action in [&"enter", &"walk", &"sit_wait", &"order", &"receive", &"satisfied", &"leave"]:
		if not _check(_customer_actions.has(action), "Missing customer action %s" % String(action)):
			return false
	if not _check(_customer_actions.find(&"receive") < _customer_actions.find(&"satisfied") \
		and _customer_actions.find(&"satisfied") < _customer_actions.find(&"leave"),
		"Customer must receive, react, then leave"):
		return false
	for action in [&"walk", &"prepare_coffee", &"carry_coffee", &"serve", &"return_idle", &"idle"]:
		if action != &"idle" and not _check(_worker_actions.has(action), "Missing Mochi action %s" % String(action)):
			return false
	for cue in [&"door_open", &"door_close", &"order_appear", &"espresso_start", &"espresso_loop",
		&"espresso_loop_stop", &"coffee_ready", &"serve", &"reward", &"customer_satisfied"]:
		if not _check(_audio.has(cue), "Missing semantic audio cue %s" % String(cue)):
			return false
	for cue in [&"coffee_ready", &"serve_success", &"reward"]:
		if not _check(_haptics.has(cue), "Missing optional haptic cue %s" % String(cue)):
			return false
	if mode == VerticalSliceController.InteractionMode.MANUAL and not _check(_haptics.has(&"valid_tap"),
		"Manual mode must emit valid-tap haptic cue"):
		return false
	var catalog := load("res://data/home_visual_asset_catalog.tres") as HomeAssetCatalog
	if not _check(catalog.validate_unique_ids() and catalog.validate_complete_contracts() \
		and catalog.definitions.size() == 17, "TEMP-to-FINAL catalog contracts must stay intact"):
		return false
	_home.queue_free()
	await process_frame
	print("[PASS] %s true slice: semantic actions/events, door, coffee, carry, one reward, audio/haptic hooks, clean ambient reset" % [
		"MANUAL" if mode == VerticalSliceController.InteractionMode.MANUAL else "AUTO"])
	return true


func _check_mochi_walk_resolution() -> bool:
	var actor: Node2D = _slice.worker_actor
	var presenter: MochiVisualPresenter = actor.get_node("MochiAnimationSlot") as MochiVisualPresenter
	var actor_root: Vector2 = actor.global_position
	var shadow_root: Vector2 = (actor.get_node("ContactShadow") as Node2D).global_position
	presenter.play_action(&"walk")
	presenter.set_direction(&"RIGHT")
	if not _check(presenter.resolved_source == &"TEMP" and presenter.resolved_clip == &"walk_side" \
		and not presenter.animated_sprite.flip_h and presenter.animated_sprite.visible,
		"The real Home/True Slice presenter must resolve RIGHT walk to the temporary side clip"):
		return false
	presenter.set_direction(&"LEFT")
	if not _check(presenter.resolved_source == &"TEMP" and presenter.resolved_clip == &"walk_side" \
		and presenter.animated_sprite.flip_h and presenter.animated_sprite.visible,
		"The real Home/True Slice presenter must resolve LEFT walk to mirrored TEMP walk_side"):
		return false
	presenter.set_direction(&"UP")
	if not _check(presenter.resolved_source == &"TEMP" and presenter.resolved_clip == &"walk_up" \
		and not presenter.animated_sprite.flip_h and presenter.animated_sprite.visible,
		"The real Home/True Slice presenter must resolve UP walk to TEMP walk_up"):
		return false
	presenter.set_direction(&"DOWN")
	if not _check(presenter.resolved_source == &"TEMP" and presenter.resolved_clip == &"walk_down" \
		and not presenter.animated_sprite.flip_h and presenter.animated_sprite.visible,
		"The real Home/True Slice presenter must resolve DOWN walk to TEMP walk_down"):
		return false
	presenter.play_action(&"idle")
	if not _check(presenter.presentation_mode == &"LAYERED_IDLE" and presenter.layered_idle.is_idle_active \
		and not presenter.animated_sprite.visible and actor.global_position == actor_root \
		and (actor.get_node("ContactShadow") as Node2D).global_position == shadow_root,
		"Walk-to-idle transition must resume layered idle without moving the actor root or ContactShadow"):
		return false
	return true


func _ordered(required: Array[StringName]) -> bool:
	var next_index: int = 0
	for event in _events:
		if next_index < required.size() and event == required[next_index]:
			next_index += 1
	return next_index == required.size()


func _check_default_startup() -> bool:
	var home := HOME.instantiate() as HomeScene
	root.add_child(home)
	await process_frame
	var slice := home.get_node("VerticalSliceController") as VerticalSliceController
	var presentation := home.get_node("TrueSlicePresentation") as TrueSlicePresentation
	var good: bool = slice.customer != null and presentation.customer_action == &"enter" \
		and (home.get_node("PrototypeDoorController") as PrototypeDoorController).state in [
			PrototypeDoorController.State.OPENING, PrototypeDoorController.State.OPEN]
	home.queue_free()
	await process_frame
	if not _check(good, "Default launch must immediately present customer entry and the opening door"):
		return false
	print("[PASS] Default startup presentation synchronizes with the already-started loop")
	return true


func _wait_for_order() -> bool:
	for _frame in range(900):
		await process_frame
		if _slice.active_order_id != &"":
			return true
	return false


func _wait_for_worker(state: SliceWorker.State) -> bool:
	for _frame in range(900):
		await process_frame
		if _slice.worker_slice.state == state:
			return true
	return false


func _wait_for_completion() -> bool:
	for _frame in range(1500):
		await process_frame
		if _slice.completed_cycles >= 1:
			return true
	return false


func _wait_for_carry() -> bool:
	var cup := _slice.worker_actor.get_node("CarryCupPlaceholder") as PrototypeCarryVisual
	for _frame in range(900):
		await process_frame
		if cup.visible and _presentation.mochi_action == &"carry_coffee":
			return true
	return false


func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("[FAIL] %s" % message)
	return condition


func _fail(message: String) -> bool:
	return _check(false, message)
