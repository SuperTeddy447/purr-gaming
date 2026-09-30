class_name PlaceholderCafe
extends PlaceholderRoom
## One finite café visit. Slot and actor state remain the existing lab implementation.

signal phase_changed(label: String)
signal reward_earned(order_id: String)
signal visit_completed(success: bool)

var loop_active := false
var _reward_sent := false


func _ready() -> void:
	super._ready()
	var guest := actors.get_node("Customer") as HardeningActor
	guest.visible = false
	guest.collision_layer = 0
	$DepthSortedLayer/Characters/Worker/CarryCup.visible = false
	find_object(&"espresso_station").get_node("SteamFXAnchor/Steam").visible = false
	find_object(&"espresso_station").get_node("CupSpawnAnchor/Cup").visible = false
	$DepthSortedLayer/Characters/Customer/OrderBubble.visible = false


func run_coffee_loop(order_id: String) -> bool:
	if loop_active:
		return false
	loop_active = true
	_reward_sent = false
	var guest := actors.get_node("Customer") as HardeningActor
	var worker := actors.get_node("Worker") as HardeningActor
	guest.global_position = spawn(&"customer_entry").global_position
	guest.visible = true
	guest.collision_layer = 4
	await get_tree().physics_frame
	var okay := await _perform(guest, &"entrance_door", &"enter", "Customer enters")
	if okay:
		okay = await _perform(guest, &"counter_shell", &"order", "Customer orders coffee")
	if okay:
		$DepthSortedLayer/Characters/Customer/OrderBubble.visible = true
		phase_changed.emit("Coffee order → brewing")
		find_object(&"espresso_station").get_node("SteamFXAnchor/Steam").visible = true
		okay = await _perform(worker, &"espresso_station", &"work_coffee", "Mochi prepares coffee")
		find_object(&"espresso_station").get_node("SteamFXAnchor/Steam").visible = false
	if okay:
		find_object(&"espresso_station").get_node("CupSpawnAnchor/Cup").visible = true
		$DepthSortedLayer/Characters/Worker/CarryCup.visible = true
		phase_changed.emit("Coffee ready → carrying")
		okay = await _perform(worker, &"counter_shell", &"serve", "Mochi serves customer")
	if okay:
		$DepthSortedLayer/Characters/Worker/CarryCup.visible = false
		find_object(&"espresso_station").get_node("CupSpawnAnchor/Cup").visible = false
		$DepthSortedLayer/Characters/Customer/OrderBubble.visible = false
		okay = await _perform(guest, &"chair_a", &"sit", "Customer sits")
	if okay:
		okay = await _perform(guest, &"entrance_door", &"leave", "Customer leaves")
	if okay:
		phase_changed.emit("Mochi returns idle")
		okay = worker.navigate_to_marker(find_object(&"counter_shell").get_node("WorkerIdle"))
		if okay:
			for frame in 600:
				await get_tree().physics_frame
				if worker.phase == HardeningActor.Phase.IDLE:
					break
			okay = worker.phase == HardeningActor.Phase.IDLE and not worker.failed_navigation
	if okay and not _reward_sent:
		_reward_sent = true
		reward_earned.emit(order_id)
	guest.visible = false
	guest.collision_layer = 0
	$DepthSortedLayer/Characters/Customer/OrderBubble.visible = false
	$DepthSortedLayer/Characters/Worker/CarryCup.visible = false
	find_object(&"espresso_station").get_node("SteamFXAnchor/Steam").visible = false
	loop_active = false
	phase_changed.emit("Ready for next customer" if okay else "Visit failed; inspect output")
	visit_completed.emit(okay)
	return okay


func _perform(actor: HardeningActor, object_id: StringName, action: StringName, label: String) -> bool:
	phase_changed.emit(label)
	if not actor.request_interaction_on(object_id, action):
		push_warning("Placeholder visit rejected %s on %s" % [action, object_id])
		return false
	for frame in 900:
		await get_tree().physics_frame
		if actor.phase == HardeningActor.Phase.IDLE:
			return not actor.failed_navigation
	actor.cancel_action(&"timeout")
	return false
