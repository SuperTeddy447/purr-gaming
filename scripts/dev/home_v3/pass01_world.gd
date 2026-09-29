class_name HomeV3Pass01World
extends HomeV3World
## Layout-specific playtest staging only. Generic actor/slot behavior is unchanged.

const CROWD_ACTOR := preload("res://scenes/dev/world_hardening/actor.tscn")

var crowd_running := false
var crowd_phase: StringName = &"idle"
var crowd_trace: Array[StringName] = []
var crowd_rejections := {"entrance": false, "order": false, "seat": false}
var crowd_spawned: Array[HardeningActor] = []


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F5:
		if not crowd_running:
			_print_crowd_sanity()
		return
	super._unhandled_key_input(event)


func _print_crowd_sanity() -> void:
	await run_crowd_sanity()


func run_crowd_sanity() -> bool:
	if crowd_running or v3_demo_running:
		return false
	crowd_running = true
	crowd_trace.clear()
	for key in crowd_rejections:
		crowd_rejections[key] = false
	var result := await _stage_crowd_sanity()
	for actor in crowd_spawned:
		if is_instance_valid(actor):
			actor.cancel_action(&"crowd_end")
			actor.queue_free()
	crowd_spawned.clear()
	crowd_phase = &"complete" if result else &"failed"
	crowd_running = false
	print("HOME V3 PASS 01 CROWD %s trace=%s rejection=%s" % [
		"PASS" if result else "FAIL", str(crowd_trace), str(crowd_rejections)])
	return result


func _stage_crowd_sanity() -> bool:
	var customer_a := actors.get_node("CustomerA") as HardeningActor
	var customer_b := actors.get_node("CustomerB") as HardeningActor
	var customer_c := _spawn_crowd_customer("CustomerC", &"waiting_spot")
	var customer_d := _spawn_crowd_customer("CustomerD", &"waiting_spot_b")
	var customer_e := _spawn_crowd_customer("CustomerE", &"waiting_spot_c")
	var worker := actors.get_node("Worker") as HardeningActor
	var cat_a := actors.get_node("CatA") as HardeningActor
	var cat_b := actors.get_node("CatB") as HardeningActor
	var cat_c := actors.get_node("CatC") as HardeningActor
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee") \
			or not cat_a.request_interaction_on(&"cat_bed", &"rest") \
			or not cat_b.request_interaction_on(&"plant", &"sniff") \
			or not cat_c.request_interaction_on(&"scratch_post", &"scratch"):
		return false
	if not customer_a.request_interaction_on(&"entrance_door", &"enter"):
		return false
	crowd_rejections["entrance"] = not customer_b.request_interaction_on(&"entrance_door", &"enter")
	if not crowd_rejections["entrance"]:
		return false
	if not customer_c.request_interaction_on(&"waiting_spot", &"wait") \
			or not customer_d.request_interaction_on(&"waiting_spot_b", &"wait") \
			or not customer_e.request_interaction_on(&"waiting_spot_c", &"wait"):
		return false
	crowd_phase = &"entry"
	crowd_trace.append(&"five_customers_three_cats_one_worker")
	if not await _crowd_wait_idle(customer_a, 700):
		return false
	if not await _crowd_perform(customer_b, &"entrance_door", &"enter"):
		return false
	for actor in [customer_c, customer_d, customer_e]:
		if not await _crowd_wait_idle(actor, 350):
			return false
	if not customer_a.request_interaction_on(&"counter_shell", &"order"):
		return false
	crowd_rejections["order"] = not customer_c.request_interaction_on(&"counter_shell", &"order")
	if not crowd_rejections["order"] or not await _crowd_wait_idle(customer_a, 650):
		return false
	crowd_trace.append(&"order_capacity")
	if not await _crowd_perform(customer_c, &"counter_shell", &"order"):
		return false
	# Four seat reservations are requested in one frame; the fifth actor must
	# wait for a real release, rather than being offset to a map-specific pixel.
	if not customer_d.request_interaction_on(&"chair_a", &"sit") \
			or not customer_e.request_interaction_on(&"chair_c", &"sit") \
			or not customer_b.request_interaction_on(&"chair_d", &"sit") \
			or not customer_c.request_interaction_on(&"chair_b", &"sit"):
		return false
	crowd_rejections["seat"] = not customer_a.request_interaction(&"sit")
	if not crowd_rejections["seat"]:
		return false
	crowd_phase = &"seating"
	crowd_trace.append(&"four_seats_reserved_fifth_waits")
	for actor in [customer_b, customer_c, customer_d, customer_e]:
		if not await _crowd_wait_idle(actor, 750):
			return false
	if not await _crowd_perform(customer_a, &"chair_a", &"sit"):
		return false
	if not await _crowd_wait_idle(worker, 450) \
			or not await _crowd_perform(worker, &"counter_shell", &"serve"):
		return false
	for actor in [customer_a, customer_b, customer_c, customer_d, customer_e]:
		if not await _crowd_perform(actor, &"entrance_door", &"leave"):
			return false
	if not await _crowd_wait_idle(cat_a, 300) \
			or not await _crowd_wait_idle(cat_b, 300) \
			or not await _crowd_wait_idle(cat_c, 300):
		return false
	crowd_trace.append(&"five_exits_clear")
	return all_reservations_clear() and _extra_reservations_clear()


func _spawn_crowd_customer(actor_name: String, spot_id: StringName) -> HardeningActor:
	var actor := CROWD_ACTOR.instantiate() as HardeningActor
	actor.name = actor_name
	actor.category = "customer"
	actors.add_child(actor)
	actor.global_position = find_slot_on_object(spot_id, &"wait").action_anchor().global_position
	actor.bind_world(self)
	crowd_spawned.append(actor)
	return actor


func _crowd_perform(actor: HardeningActor, object_id: StringName, action: StringName) -> bool:
	if not actor.request_interaction_on(object_id, action):
		return false
	if not await _crowd_wait_idle(actor, 850):
		return false
	crowd_trace.append(action)
	return true


func _crowd_wait_idle(actor: HardeningActor, frames: int) -> bool:
	for i in frames:
		if actor.phase == HardeningActor.Phase.IDLE:
			return not actor.failed_navigation
		await get_tree().physics_frame
	return false
