extends SceneTree
## Manual and auto coffee loops on the V2 visual variant, not a second game loop.

const PREVIEW: PackedScene = preload("res://scenes/dev/home_v2_environment_preview.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _loop(VerticalSliceController.InteractionMode.MANUAL):
		quit(1)
		return
	if not await _loop(VerticalSliceController.InteractionMode.AUTO_LOOP):
		quit(1)
		return
	print("--- HOME V2 TRUE SLICE MANUAL/AUTO COMPATIBILITY PASSED ---")
	quit(0)


func _loop(mode: VerticalSliceController.InteractionMode) -> bool:
	var home: HomeScene = PREVIEW.instantiate() as HomeScene
	var slice: VerticalSliceController = home.get_node("VerticalSliceController") as VerticalSliceController
	slice.start_on_ready = false
	slice.auto_repeat_slice = false
	slice.interaction_mode = mode
	slice.customer_move_speed = 10000.0
	slice.worker_move_speed = 10000.0
	slice.timing_config = slice.timing_config.duplicate_for_testing()
	slice.timing_config.set_preset("FAST")
	slice.timing_config.customer_arrival_pause = 0.02
	slice.timing_config.customer_order_delay = 0.02
	slice.timing_config.coffee_preparation_duration = 0.10
	slice.timing_config.serve_duration = 0.02
	slice.timing_config.served_reaction_duration = 0.02
	slice.timing_config.customer_exit_delay = 0.02
	slice.timing_config.door_transition_duration = 0.02
	slice.timing_config.door_hold_open_duration = 0.02
	(home.get_node("PrototypeDoorController") as PrototypeDoorController).timing_config = slice.timing_config
	root.add_child(home)
	await process_frame
	var rewards: Array[int] = []
	slice.wallet.reward_added.connect(func(amount: int, _total: int, _id: StringName) -> void:
		rewards.append(amount))
	slice.start_slice()
	if not await _until(func() -> bool: return slice.active_order_id == &"order_coffee_basic_01"):
		return _fail(home, "Order missing in V2 %s" % str(mode))
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		if not slice.request_coffee_preparation():
			return _fail(home, "Manual coffee request rejected")
	if not await _until(func() -> bool: return slice.worker_slice.state == SliceWorker.State.PREPARING_COFFEE):
		return _fail(home, "Worker did not prepare in V2")
	var steam: Node2D = home.get_node("World/FXLayer/V2EspressoSteam") as Node2D
	if not steam.steam_active:
		return _fail(home, "V2 steam did not follow prepare state")
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		if not await _until(func() -> bool: return slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE):
			return _fail(home, "Manual worker did not reach serve")
		if not slice.request_serve():
			return _fail(home, "Manual serve rejected")
	if not await _until(func() -> bool: return slice.customer == null and slice.cycle_number >= 1):
		return _fail(home, "Customer did not exit V2")
	if rewards.size() != 1 or slice.active_order_id != &"" or slice.worker_slice.state != SliceWorker.State.IDLE:
		return _fail(home, "V2 loop did not settle with exactly one reward")
	if steam.steam_active:
		return _fail(home, "Steam remained after coffee")
	home.queue_free()
	await process_frame
	return true


func _until(predicate: Callable) -> bool:
	for frame in 1200:
		await process_frame
		if predicate.call():
			return true
	return false


func _fail(home: HomeScene, reason: String) -> bool:
	push_error(reason)
	home.queue_free()
	return false
