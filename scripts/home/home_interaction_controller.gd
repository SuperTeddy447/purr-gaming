class_name HomeInteractionController
extends Node2D
## Semantic hit testing and contextual actions for the Home playtest only.

signal interaction_resolved(target_id: StringName, accepted: bool)

const MIN_TOUCH_TARGET_PX: float = 52.0

@export var camera_controller: CameraController
@export var slice_controller: VerticalSliceController
@export var debug_overlay: DebugOverlay
@export var feedback_label: Label
@export var selection_feedback: PrototypeSelectionFeedback
@export var door_controller: PrototypeDoorController
@export var ambient_controller: LivingCafeAmbientController

var last_interaction_id: StringName = &""
var last_interaction_accepted: bool = false
var interaction_count: int = 0
var show_hit_areas: bool = false
var _static_targets: Array[Dictionary] = []


func _ready() -> void:
	add_to_group(&"home_interaction_controller")
	if camera_controller != null:
		camera_controller.tap_unhandled.connect(interact_at_world)
	if debug_overlay != null:
		debug_overlay.master_debug_toggled.connect(_on_debug_toggled)
		show_hit_areas = debug_overlay.master_debug_active
	if slice_controller != null:
		slice_controller.interaction_mode_changed.connect(_on_mode_changed)
		slice_controller.lifecycle_event.connect(_on_lifecycle_event)
	call_deferred("_build_static_targets")
	_on_mode_changed(slice_controller.interaction_mode if slice_controller != null else VerticalSliceController.InteractionMode.MANUAL)


func _build_static_targets() -> void:
	_static_targets.clear()
	for item in get_tree().get_nodes_in_group(&"home_asset_slots"):
		var slot := item as HomeAssetSlot
		if slot == null or slot.definition == null:
			continue
		if slot.get_parent() is HomeAssetSlot:
			continue
		if slot.asset_id == &"architecture_home_01":
			continue
		var target_id: StringName = StringName("%s@%s" % [String(slot.asset_id), slot.name])
		var kind: StringName = &"inspect"
		var size: Vector2 = slot.contract.target_bounds
		var priority: int = 8
		match slot.asset_id:
			&"espresso_basic_01":
				target_id = &"espresso_station"
				kind = &"coffee_station"
				size = Vector2(112.0, 126.0)
				priority = 1
			&"pastry_case_basic_01":
				target_id = &"pastry_case"
				kind = &"inspect"
				size = Vector2(180.0, 126.0)
				priority = 3
			&"pos_basic_01":
				target_id = &"pos"
				size = Vector2(84.0, 76.0)
				priority = 4
			&"counter_basic_01":
				if slot.variant_override != &"counter_front":
					continue
				target_id = &"counter"
				size = Vector2(210.0, 78.0)
				priority = 7
			&"table_round_01":
				target_id = &"table"
				size = Vector2(126.0, 96.0)
				priority = 6
			&"chair_jade_01":
				target_id = &"chair"
				size = Vector2(72.0, 88.0)
				priority = 5
			&"entrance_door_01":
				if slot.variant_override != &"door_left":
					continue
				target_id = &"entrance_door"
				kind = &"door"
				size = Vector2(132.0, 146.0)
				priority = 2
		_static_targets.append(_make_target(target_id, kind, slot, size, priority, slot.asset_id))
	for marker_id in [GameplayID.SEAT_MAIN_A, GameplayID.SEAT_MAIN_B, GameplayID.SEAT_MAIN_C, GameplayID.SEAT_MAIN_D]:
		var marker: GameplayMarker = slice_controller.get_marker(marker_id)
		if marker == null:
			continue
		_static_targets.append(_make_target(marker_id, &"seat", marker, Vector2(72.0, 72.0), 0, marker_id))
	queue_redraw()


func _make_target(target_id: StringName, kind: StringName, node: Node2D, size: Vector2,
		priority: int, asset_id: StringName) -> Dictionary:
	return {
		"id": target_id,
		"kind": kind,
		"node": node,
		"size": size,
		"offset": Vector2.ZERO,
		"priority": priority,
		"asset_id": asset_id
	}


func _all_targets() -> Array[Dictionary]:
	var targets: Array[Dictionary] = _static_targets.duplicate()
	if slice_controller == null or slice_controller.worker_actor == null:
		return targets
	targets.append(_make_target(&"mochi", &"worker", slice_controller.worker_actor, Vector2(100.0, 176.0), 0, &"mochi_worker"))
	var worker_target: Dictionary = targets.back()
	worker_target["offset"] = Vector2(0.0, -78.0)
	if slice_controller.customer != null and is_instance_valid(slice_controller.customer):
		var customer_target := _make_target(&"active_customer", &"customer", slice_controller.customer,
			Vector2(116.0, 224.0), 0, &"customer_placeholder")
		customer_target["offset"] = Vector2(0.0, -112.0)
		targets.append(customer_target)
		if slice_controller.spatial_routes != null:
			var approach: Marker2D = slice_controller.spatial_routes.service_marker(slice_controller.active_seat_id)
			if approach != null:
				targets.append(_make_target(&"serve_point", &"serve_target", approach,
					Vector2(88.0, 76.0), 0, GameplayID.COUNTER_SERVE))
	if ambient_controller != null:
		for agent in ambient_controller.agents:
			if agent.cat_id == &"Mochi":
				continue
			var cat_target := _make_target(agent.cat_id, &"ambient_cat", agent.actor,
				Vector2(90.0, 125.0), 0, agent.cat_id)
			cat_target["offset"] = Vector2(0.0, -58.0)
			targets.append(cat_target)
	return targets


func _target_rect(target: Dictionary) -> Rect2:
	var node := target.get("node") as Node2D
	if node == null or not is_instance_valid(node):
		return Rect2()
	var size: Vector2 = target.get("size", Vector2(64.0, 64.0))
	var transform_scale: float = get_viewport().get_canvas_transform().basis_xform(Vector2.RIGHT).length()
	var minimum_world_size: float = MIN_TOUCH_TARGET_PX / maxf(transform_scale, 0.001)
	size = Vector2(maxf(size.x, minimum_world_size), maxf(size.y, minimum_world_size))
	var center: Vector2 = node.global_position + target.get("offset", Vector2.ZERO)
	return Rect2(center - size * 0.5, size)


func _is_target_visible(target: Dictionary) -> bool:
	var node := target.get("node") as Node2D
	if node == null or not is_instance_valid(node):
		return false
	return not node is CanvasItem or (node as CanvasItem).is_visible_in_tree()


func _find_target_at(world_position: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_priority: int = 999
	var best_area: float = INF
	for target in _all_targets():
		if not _is_target_visible(target):
			continue
		var rect: Rect2 = _target_rect(target)
		if not rect.has_point(world_position):
			continue
		var priority: int = target.get("priority", 9)
		var area: float = rect.size.x * rect.size.y
		if priority < best_priority or (priority == best_priority and area < best_area):
			best = target
			best_priority = priority
			best_area = area
	return best


func interact_at_world(world_position: Vector2) -> bool:
	var target: Dictionary = _find_target_at(world_position)
	if target.is_empty():
		return false
	return _interact(target)


func interact_with_target(target_id: StringName) -> bool:
	for target in _all_targets():
		if target.get("id") == target_id or target.get("asset_id") == target_id:
			return _interact(target)
	return false


func _interact(target: Dictionary) -> bool:
	var target_id: StringName = target.get("id", &"unknown")
	var kind: StringName = target.get("kind", &"inspect")
	var accepted: bool = true
	var message: String = ""
	match kind:
		&"ambient_cat":
			var agent: LivingCafeAmbientController.Agent = ambient_controller.agent_for(target_id)
			message = "%s · %s" % [String(agent.cat_id), String(agent.activity).replace("_", " ").capitalize()] if agent != null else "Ambient cat unavailable"
		&"worker":
			var state_text: String = slice_controller.worker_slice.readable_state_name()
			var mochi_agent: LivingCafeAmbientController.Agent = ambient_controller.agent_for(&"Mochi") if ambient_controller != null else null
			message = "MOCHI · %s" % (String(mochi_agent.activity).replace("_", " ").capitalize() if mochi_agent != null and not mochi_agent.work_priority else state_text)
			if slice_controller.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
				message += "\nTap the customer to serve."
		&"customer":
			message = _interact_with_customer()
			accepted = not message.begins_with("No ")
		&"coffee_station":
			message = _interact_with_coffee_station()
			accepted = slice_controller.is_manual_mode() and not message.begins_with("No active")
		&"serve_target":
			message = _interact_with_serve_target()
			accepted = not message.begins_with("No ") and not message.begins_with("Wait")
		&"seat":
			var seat_id: StringName = target.get("asset_id", &"")
			message = "%s · %s" % [_seat_label(seat_id), "Occupied" if slice_controller.seat_occupancy.has(seat_id) else "Free"]
		&"door":
			message = "Entrance Door · %s" % (door_controller.state_name().capitalize() if door_controller != null else "Closed")
		_:
			message = _inspection_message(target)
	if debug_overlay != null and debug_overlay.master_debug_active and target.get("node") is HomeAssetSlot:
		var slot := target.get("node") as HomeAssetSlot
		message += "\nAsset ID: %s\nSlot: %s\n%s\nInteraction: %s" % [
			String(slot.asset_id), String(slot.slot_role), slot.contract_debug_summary(),
			String(slot.contract.interaction_role if slot.contract.interaction_role != &"NONE" else String(kind).to_upper())
		]
	last_interaction_id = target_id
	last_interaction_accepted = accepted
	interaction_count += 1
	interaction_resolved.emit(target_id, accepted)
	_set_feedback(message)
	if selection_feedback != null:
		selection_feedback.show_feedback(_target_rect(target), _short_caption(target_id, message), accepted)
	queue_redraw()
	return accepted


func _interact_with_customer() -> String:
	if slice_controller.customer_slice == null:
		return "No active customer."
	var customer_state: SliceCustomer.State = slice_controller.customer_slice.state
	if customer_state == SliceCustomer.State.READY_FOR_SERVE:
		if slice_controller.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
			if slice_controller.request_serve():
				return "Serving coffee to customer."
		if slice_controller.worker_slice.state == SliceWorker.State.SERVING:
			return "Mochi is serving the coffee."
		return "Coffee is ready · Mochi is walking to the serve point."
	var message: String = "Customer · %s" % slice_controller.customer_slice.readable_state_name()
	if slice_controller.active_order_id != &"":
		message += "\nCoffee Order"
		if slice_controller.worker_slice.state == SliceWorker.State.IDLE:
			message += " · tap Espresso Station"
	return message


func _interact_with_coffee_station() -> String:
	if slice_controller.active_order_id == &"":
		return "No active coffee order."
	if not slice_controller.is_manual_mode():
		return "Mochi is handling this order."
	if slice_controller.request_coffee_preparation():
		return "Mochi is walking to Espresso Station."
	if slice_controller.worker_slice.state == SliceWorker.State.PREPARING_COFFEE:
		return "Coffee is being prepared."
	if slice_controller.worker_slice.state in [SliceWorker.State.WALKING_TO_COFFEE, SliceWorker.State.ORDER_RECEIVED]:
		return "Mochi is on the way to Espresso Station."
	if slice_controller.worker_slice.state in [SliceWorker.State.WALKING_TO_SERVE, SliceWorker.State.READY_TO_SERVE]:
		return "Coffee is ready · tap the customer to serve."
	return "Espresso Station · no new action available."


func _interact_with_serve_target() -> String:
	if slice_controller.active_order_id == &"":
		return "No coffee is waiting to be served."
	if slice_controller.worker_slice.state == SliceWorker.State.READY_TO_SERVE:
		if slice_controller.request_serve():
			return "Serving coffee to customer."
	if slice_controller.worker_slice.state == SliceWorker.State.WALKING_TO_SERVE:
		return "Wait for Mochi to reach the serve point."
	return "Serve Point · not ready yet."


func _inspection_message(target: Dictionary) -> String:
	var title: String = _humanize(String(target.get("asset_id", target.get("id", "Object"))))
	return "%s · future interaction" % title


func _seat_label(seat_id: StringName) -> String:
	return "Seat %s" % String(seat_id).get_slice("_", 2).to_upper()


func _humanize(raw: String) -> String:
	var words: PackedStringArray = raw.replace("_", " ").split(" ", false)
	for index in range(words.size()):
		words[index] = words[index].capitalize()
	return " ".join(words)


func _short_caption(target_id: StringName, message: String) -> String:
	if target_id == &"mochi":
		return "MOCHI"
	if target_id in [&"PrototypeCatA", &"PrototypeCatB"]:
		return String(target_id)
	if target_id == &"active_customer":
		if slice_controller != null and slice_controller.customer_slice != null and \
			slice_controller.customer_slice.state == SliceCustomer.State.READY_FOR_SERVE:
			return "SERVE CUSTOMER"
		return "CUSTOMER"
	if target_id == &"espresso_station":
		return "ESPRESSO"
	if target_id == &"serve_point":
		return "SERVE POINT"
	if message.contains("future interaction"):
		return _humanize(String(target_id))
	return "SELECTED"


func _set_feedback(message: String) -> void:
	if feedback_label != null:
		feedback_label.text = message
		feedback_label.visible = true


func _on_mode_changed(mode: VerticalSliceController.InteractionMode) -> void:
	if feedback_label == null:
		return
	if mode == VerticalSliceController.InteractionMode.MANUAL:
		_set_feedback("Tap the coffee order, then Espresso Station")
	else:
		_set_feedback("Café service is in progress")


func _on_lifecycle_event(event_name: StringName) -> void:
	if event_name in [&"customer_spawned", &"customer_exited"] and selection_feedback != null:
		selection_feedback.clear_feedback()
	match event_name:
		&"customer_spawned":
			_set_feedback("Customer entering the café…")
		&"customer_seated":
			_set_feedback("Customer seated · waiting to order")
		&"order_created":
			_set_feedback("Coffee Order · tap Espresso Station to prepare")
		&"worker_prepares":
			_set_feedback("Mochi is preparing coffee…")
		&"coffee_prepared":
			_set_feedback("Coffee ready · Mochi is carrying it to the counter")
		&"worker_ready_to_serve":
			_set_feedback("Coffee ready · tap the customer to serve")
		&"reward_granted":
			_set_feedback("Reward added · +%d coins" % slice_controller.coffee_order.reward_coins)
		&"customer_exited":
			_set_feedback("Customer left · next customer soon")


func _on_debug_toggled(is_active: bool) -> void:
	show_hit_areas = is_active
	queue_redraw()


func _draw() -> void:
	if not show_hit_areas:
		return
	for target in _all_targets():
		if not _is_target_visible(target):
			continue
		var rect: Rect2 = _target_rect(target)
		var color: Color = Color(0.35, 0.85, 0.65, 0.72)
		if target.get("kind") == &"seat" and slice_controller.seat_occupancy.has(target.get("asset_id")):
			color = Color(0.95, 0.55, 0.3, 0.82)
		draw_rect(Rect2(rect.position - global_position, rect.size), color, false, 2.0)
		draw_string(ThemeDB.fallback_font, rect.position - global_position + Vector2(2.0, 14.0),
			String(target.get("id", &"")), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 10, color)
