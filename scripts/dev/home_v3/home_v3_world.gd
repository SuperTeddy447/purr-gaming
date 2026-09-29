class_name HomeV3World
extends HardeningWorld
## Godot-authored character-first greybox. Stages existing semantic actors/slots;
## no production Home state machine or character artwork is touched.

signal v3_demo_finished(success: bool)

var v3_demo_running := false
var v3_trace: Array[StringName] = []
var _emotion_actor: HardeningActor


func _ready() -> void:
	super._ready()
	var worker := actors.get_node("Worker") as HardeningActor
	worker.action_started.connect(_on_v3_worker_started)
	worker.action_completed.connect(_on_v3_worker_completed)
	worker.action_cancelled.connect(_on_v3_worker_cancelled)
	for name in ["CatA", "CatB", "CatC"]:
		var cat := actors.get_node(name) as HardeningActor
		cat.action_started.connect(_on_v3_cat_started)
		cat.action_completed.connect(_on_v3_cat_completed)
		cat.action_cancelled.connect(_on_v3_cat_cancelled)
	camera_director.shot_ended.connect(_on_v3_shot_ended)


func _espresso() -> HardeningWorldObject:
	return find_object(&"espresso_station")


func _bed() -> HardeningWorldObject:
	return find_object(&"cat_bed")


func _on_v3_worker_started(slot: HardeningInteractionSlot) -> void:
	if slot.action_type == &"work_coffee":
		_espresso().get_node("BrewFXAnchor/Preview").visible = true


func _on_v3_worker_completed(slot: HardeningInteractionSlot) -> void:
	if slot.action_type == &"work_coffee":
		_espresso().get_node("BrewFXAnchor/Preview").visible = false
		_espresso().get_node("CupRevealFXAnchor/Preview").visible = true
	elif slot.action_type == &"serve":
		_espresso().get_node("CupRevealFXAnchor/Preview").visible = false
		_espresso().get_node("CupSpawnAnchor/Cup").visible = false


func _on_v3_worker_cancelled(slot: HardeningInteractionSlot, _reason: StringName) -> void:
	if slot.action_type == &"work_coffee":
		_espresso().get_node("BrewFXAnchor/Preview").visible = false


func _on_v3_cat_started(slot: HardeningInteractionSlot) -> void:
	if slot.action_type in [&"rest", &"sleep"]:
		_bed().get_node("SleepFXAnchor/Preview").visible = true


func _on_v3_cat_completed(slot: HardeningInteractionSlot) -> void:
	if slot.action_type in [&"rest", &"sleep"]:
		_bed().get_node("SleepFXAnchor/Preview").visible = false


func _on_v3_cat_cancelled(slot: HardeningInteractionSlot, _reason: StringName) -> void:
	_on_v3_cat_completed(slot)


func focus_cat(cat: HardeningActor) -> bool:
	if cat == null or not cat.is_inside_tree():
		return false
	var shot := HardeningCameraShot.new()
	shot.shot_id = &"cat_emotion"
	shot.zoom = maxf(camera_director.camera.zoom.x * 1.25, 1.8)
	shot.transition_in = 0.25
	shot.hold_duration = 0.55
	shot.transition_out = 0.28
	shot.priority = 35
	if not camera_director.request_shot(cat.get_node("CameraEmotionFocus") as Marker2D, shot):
		return false
	_emotion_actor = cat
	cat.get_node("HeartFX/Preview").visible = true
	cat.get_node("PurrFX/Preview").visible = true
	return true


func _on_v3_shot_ended(shot_id: StringName, _reason: StringName) -> void:
	if shot_id != &"cat_emotion" or not is_instance_valid(_emotion_actor):
		return
	_emotion_actor.get_node("HeartFX/Preview").visible = false
	_emotion_actor.get_node("PurrFX/Preview").visible = false
	_emotion_actor = null


func run_v3_demo() -> bool:
	if v3_demo_running:
		return false
	v3_demo_running = true
	v3_trace.clear()
	var success := await _stage_v3_demo()
	v3_demo_running = false
	v3_demo_finished.emit(success)
	print("HOME V3 DEMO %s trace=%s" % ["PASS" if success else "FAIL", str(v3_trace)])
	return success


func _stage_v3_demo() -> bool:
	var worker := actors.get_node("Worker") as HardeningActor
	var customer_a := actors.get_node("CustomerA") as HardeningActor
	var customer_b := actors.get_node("CustomerB") as HardeningActor
	var cat_a := actors.get_node("CatA") as HardeningActor
	var cat_b := actors.get_node("CatB") as HardeningActor
	var cat_c := actors.get_node("CatC") as HardeningActor
	if not worker.request_interaction_on(&"espresso_station", &"work_coffee"):
		return false
	if not cat_a.request_interaction_on(&"cat_bed", &"rest"):
		return false
	if not cat_b.request_interaction_on(&"plant", &"sniff"):
		return false
	if not cat_c.request_interaction_on(&"scratch_post", &"scratch"):
		return false
	for action in [
		[customer_a, &"entrance_door", &"enter"],
		[customer_a, &"waiting_spot", &"wait"],
		[customer_a, &"counter_shell", &"order"],
		[customer_a, &"chair_a", &"sit"],
		[customer_b, &"entrance_door", &"enter"],
		[customer_b, &"counter_shell", &"order"],
		[customer_b, &"chair_c", &"sit"],
	]:
		if not await _perform_action(action[0], action[1], action[2]):
			return false
	for frame in 600:
		if worker.phase == HardeningActor.Phase.IDLE:
			break
		await get_tree().physics_frame
	if worker.phase != HardeningActor.Phase.IDLE or worker.failed_navigation:
		return false
	v3_trace.append(&"work_coffee")
	if not await _perform_action(worker, &"counter_shell", &"serve"):
		return false
	if not await _perform_action(customer_a, &"entrance_door", &"leave"):
		return false
	if not await _perform_action(customer_b, &"entrance_door", &"leave"):
		return false
	for cat in [cat_a, cat_b, cat_c]:
		for frame in 500:
			if cat.phase == HardeningActor.Phase.IDLE:
				break
			await get_tree().physics_frame
		if cat.phase != HardeningActor.Phase.IDLE or cat.failed_navigation:
			return false
	return all_reservations_clear() and _extra_reservations_clear()


func _perform_action(actor: HardeningActor, object_id: StringName, action: StringName) -> bool:
	var started := false
	for frame in 240:
		if actor.phase == HardeningActor.Phase.IDLE \
				and actor.request_interaction_on(object_id, action):
			started = true
			break
		await get_tree().physics_frame
	if not started:
		return false
	for frame in 900:
		if actor.phase == HardeningActor.Phase.IDLE:
			if actor.failed_navigation:
				return false
			v3_trace.append(action)
			return true
		await get_tree().physics_frame
	return false


func _extra_reservations_clear() -> bool:
	for action in [&"enter", &"leave", &"story", &"order", &"serve", &"wait", &"watch",
			&"browse", &"grind", &"operate_pos"]:
		for slot in all_slots(action):
			if slot.use_count() != 0:
				return false
	return true


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		if not v3_demo_running:
			_print_v3_demo()
		return
	super._unhandled_key_input(event)


func _print_v3_demo() -> void:
	await run_v3_demo()
