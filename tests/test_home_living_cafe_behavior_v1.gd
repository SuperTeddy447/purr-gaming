extends SceneTree
## Living Café integration checks against the real Home and Vertical Slice.

const HOME: PackedScene = preload("res://scenes/home/home_scene.tscn")

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _check_ambient_and_manual():
		quit(1)
		return
	if not await _check_ten_auto_loops():
		quit(1)
		return
	print("--- ALL HOME LIVING CAFE BEHAVIOR V1 CHECKS PASSED ---")
	quit(0)


func _make_home(mode: VerticalSliceController.InteractionMode) -> HomeScene:
	var home := HOME.instantiate() as HomeScene
	var slice := home.get_node("VerticalSliceController") as VerticalSliceController
	slice.start_on_ready = false
	slice.interaction_mode = mode
	slice.customer_move_speed = 10000.0
	slice.worker_move_speed = 10000.0
	slice.timing_config = slice.timing_config.duplicate_for_testing()
	slice.timing_config.set_preset("FAST")
	slice.timing_config.customer_arrival_pause = 0.02
	slice.timing_config.customer_order_delay = 0.02
	slice.timing_config.coffee_preparation_duration = 0.08
	slice.timing_config.serve_duration = 0.02
	slice.timing_config.served_reaction_duration = 0.02
	slice.timing_config.customer_exit_delay = 0.02
	slice.timing_config.next_customer_delay = 0.02
	var ambient := home.get_node("LivingCafeAmbientController") as LivingCafeAmbientController
	ambient.timing = ambient.timing.duplicate(true) as AmbientTimingConfig
	ambient.timing.idle_min = 0.08
	ambient.timing.idle_max = 0.10
	ambient.timing.activity_min = 0.08
	ambient.timing.activity_max = 0.10
	ambient.timing.roam_delay = 0.04
	ambient.timing.ambient_move_speed = 900.0
	var door := home.get_node("PrototypeDoorController") as PrototypeDoorController
	door.timing_config = slice.timing_config
	return home


func _check_ambient_and_manual() -> bool:
	var home := _make_home(VerticalSliceController.InteractionMode.MANUAL)
	root.add_child(home)
	await process_frame
	var slice := home.get_node("VerticalSliceController") as VerticalSliceController
	var ambient := home.get_node("LivingCafeAmbientController") as LivingCafeAmbientController
	var interaction := home.get_node("HomeInteractionController") as HomeInteractionController
	var mochi: LivingCafeAmbientController.Agent = ambient.agent_for(&"Mochi")
	var a: LivingCafeAmbientController.Agent = ambient.agent_for(&"PrototypeCatA")
	var b: LivingCafeAmbientController.Agent = ambient.agent_for(&"PrototypeCatB")
	if not _check(ambient.agents.size() == 3 and mochi != null and a != null and b != null,
		"Three runtime cats should exist"):
		return false
	if not _check(a.actor.get_parent() == slice.depth_layer and b.actor.get_parent() == slice.depth_layer \
		and (slice.depth_layer as Node2D).y_sort_enabled, "All cats must share the depth owner"):
		return false
	if not _check(not ambient.reservations.has(&"STATION_COFFEE") and not ambient.reservations.has(&"COUNTER_SERVE") \
		and not ambient.reservations.has(slice.active_seat_id), "Work and seat points must not be ambient zones"):
		return false
	if not _check(ambient.occupied_zone_count() == 3 and a.zone != b.zone, "Initial zones must be exclusive"):
		return false
	if not _check(_guest_zones_clear_of_routes(slice, ambient),
		"Ambient destinations must stay clear of customer seats and the authored customer corridor"):
		return false
	if not _check(interaction.interact_with_target(&"PrototypeCatA") \
		and interaction.last_interaction_id == &"PrototypeCatA", "Ambient cats must be tappable"):
		return false
	var sequence: Array[String] = []
	for _index in range(8):
		mochi.time_left = 0.0
		ambient._choose_next(mochi)
		sequence.append("%s/%s" % [String(mochi.activity), String(mochi.target_zone)])
		mochi.mover.cancel()
		if mochi.target_zone != &"":
			ambient.reservations.erase(mochi.target_zone)
			ambient.reservations[mochi.zone] = mochi.cat_id
			mochi.target_zone = &""
	if not _check(sequence.has("ROAM/COUNTER_IDLE"), "Mochi must be able to roam between work-safe idle points"):
		return false
	ambient.set_seed(777)
	var first: Array[String] = []
	for _index in range(6):
		ambient._choose_next(mochi)
		first.append("%s/%s" % [String(mochi.activity), String(mochi.target_zone)])
		mochi.mover.cancel()
		ambient.reservations.erase(mochi.target_zone)
		ambient.reservations[mochi.zone] = mochi.cat_id
		mochi.target_zone = &""
	ambient.set_seed(777)
	for entry in first:
		ambient._choose_next(mochi)
		if not _check(entry == "%s/%s" % [String(mochi.activity), String(mochi.target_zone)],
			"Equal seeds must produce equal choices"):
			return false
		mochi.mover.cancel()
		ambient.reservations.erase(mochi.target_zone)
		ambient.reservations[mochi.zone] = mochi.cat_id
		mochi.target_zone = &""
	# A real order must cancel a pending ambient route, then use the existing work machine.
	mochi.target_zone = &"COUNTER_IDLE"
	mochi.activity = &"ROAM"
	ambient.reservations.erase(mochi.zone)
	ambient.reservations[mochi.target_zone] = mochi.cat_id
	mochi.mover.move_route([ambient._zones[&"COUNTER_IDLE"]])
	slice.start_slice()
	if not await _wait_for_order(slice):
		return _check(false, "Manual order did not become actionable")
	if not _check(mochi.work_priority and mochi.target_zone == &"" and not mochi.mover.is_moving \
		and not ambient.reservations.has(&"COUNTER_IDLE"), "Order must clear ambient movement and reservation"):
		return false
	if not _check(interaction.interact_with_target(&"espresso_station"), "Manual coffee tap should work after interruption"):
		return false
	for _frame in range(900):
		await process_frame
		if slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
			break
	if not _check(slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE \
		and mochi.work_priority and mochi.target_zone == &"", "Ambient must stay suspended throughout coffee work"):
		return false
	if not _check(interaction.interact_with_target(&"active_customer"), "Manual serve tap should work"):
		return false
	for _frame in range(1200):
		await process_frame
		if slice.completed_cycles >= 1:
			break
	if not _check(slice.completed_cycles == 1 and slice.wallet.coins == slice.coffee_order.reward_coins \
		and slice.worker_slice.state == SliceWorker.State.IDLE and not mochi.work_priority,
		"Manual loop should finish once and ambience should resume"):
		return false
	if not _check(ambient.reservations.get(&"WORKER_IDLE") == &"Mochi" and a.zone != b.zone,
		"Work completion must restore a valid idle reservation"):
		return false
	# Exercise the optional social cue without changing gameplay or reservation ownership.
	a.actor.global_position = ambient._zones[&"OPEN_FLOOR"]
	b.actor.global_position = ambient._zones[&"WINDOW_LOOK"]
	a.mover.cancel()
	b.mover.cancel()
	a.time_left = 0.0
	b.time_left = 0.0
	var social_seen: bool = false
	for _attempt in range(100):
		ambient._try_social_event()
		if a.activity == &"SOCIAL_PAUSE" and b.activity == &"SOCIAL_PAUSE":
			social_seen = true
			break
	if not _check(social_seen and a.time_left > 0.0 and b.time_left > 0.0,
		"Nearby cats should be able to pause and face one another"):
		return false
	home.queue_free()
	await process_frame
	print("[PASS] Manual interruption, no stale target, reward once, return to ambience, tap, zones, depth, seeded choices")
	return true


func _check_ten_auto_loops() -> bool:
	var home := _make_home(VerticalSliceController.InteractionMode.AUTO_LOOP)
	root.add_child(home)
	await process_frame
	var slice := home.get_node("VerticalSliceController") as VerticalSliceController
	var ambient := home.get_node("LivingCafeAmbientController") as LivingCafeAmbientController
	var reward_count: Array[int] = [0]
	slice.wallet.reward_added.connect(func(_amount: int, _total: int, _id: StringName) -> void: reward_count[0] += 1)
	slice.start_slice()
	for _frame in range(10000):
		await process_frame
		var a: LivingCafeAmbientController.Agent = ambient.agent_for(&"PrototypeCatA")
		var b: LivingCafeAmbientController.Agent = ambient.agent_for(&"PrototypeCatB")
		if not _check((a.target_zone == &"" or b.target_zone == &"" or a.target_zone != b.target_zone) \
			and ambient.reservations.values().count(a.cat_id) <= 1 \
			and ambient.reservations.values().count(b.cat_id) <= 1,
			"Ambient cats must never reserve the same exclusive zone"):
			return false
		if not _check(a.zone not in [&"WORKER_IDLE", &"COUNTER_IDLE"] \
			and b.zone not in [&"WORKER_IDLE", &"COUNTER_IDLE"], "Guests must stay out of worker-only zones"):
			return false
		if slice.completed_cycles >= 10:
			break
	if not _check(slice.completed_cycles == 10 and reward_count[0] == 10,
		"Ten AUTO cycles with active ambient cats must finish with exactly ten rewards (cycles=%d rewards=%d worker=%s)" % [
			slice.completed_cycles, reward_count[0], slice.worker_slice.state_name()]):
		return false
	home.queue_free()
	await process_frame
	print("[PASS] Ten AUTO loops, exclusive zones, worker-only exclusion")
	return true


func _wait_for_order(slice: VerticalSliceController) -> bool:
	for _frame in range(900):
		await process_frame
		if slice.active_order_id != &"":
			return true
	return false


func _guest_zones_clear_of_routes(slice: VerticalSliceController, ambient: LivingCafeAmbientController) -> bool:
	var entry: Vector2 = slice.customer_entry_waypoint.global_position
	var aisle: Vector2 = slice.customer_aisle_waypoint.global_position
	for zone in [&"OPEN_FLOOR", &"WINDOW_LOOK", &"PLANT_INSPECT"]:
		var point: Vector2 = ambient._zones[zone]
		for seat_id in [GameplayID.SEAT_MAIN_A, GameplayID.SEAT_MAIN_B,
			GameplayID.SEAT_MAIN_C, GameplayID.SEAT_MAIN_D]:
			var seat: Vector2 = slice.get_marker_position(seat_id)
			if point.distance_to(seat) < 90.0:
				return false
			var route: Array[Vector2] = slice.spatial_routes.customer_to_seat(seat_id, entry, aisle, seat)
			var previous: Vector2 = slice.get_marker_position(GameplayID.CUSTOMER_SPAWN)
			for waypoint in route:
				if point.distance_to(Geometry2D.get_closest_point_to_segment(point, previous, waypoint)) < 90.0:
					return false
				previous = waypoint
	return true


func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("[FAIL] %s" % message)
	return condition
