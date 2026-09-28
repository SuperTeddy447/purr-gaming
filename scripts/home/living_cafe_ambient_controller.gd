class_name LivingCafeAmbientController
extends Node2D
## Local, low-priority ambience. The Vertical Slice remains the only work authority.

signal ambient_changed(cat_id: StringName, activity: StringName, zone: StringName)

class Agent:
	extends RefCounted
	var actor: Node2D
	var mover: SliceMover
	var cat_id: StringName
	var profile: StringName
	var zone: StringName
	var target_zone: StringName = &""
	var activity: StringName = &"IDLE"
	var time_left: float = 0.0
	var work_priority: bool = false

@export var slice_controller: VerticalSliceController
@export var depth_layer: Node2D
@export var debug_overlay: DebugOverlay
@export var timing: AmbientTimingConfig = preload("res://data/home_ambient_timing.tres")
@export var enabled: bool = true

var agents: Array[Agent] = []
var reservations: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _zones: Dictionary = {}


func _ready() -> void:
	if not enabled or slice_controller == null or depth_layer == null or timing == null:
		set_process(false)
		return
	set_seed(timing.deterministic_seed)
	_zones = {
		&"WORKER_IDLE": slice_controller.get_marker_position(GameplayID.WORKER_IDLE),
		&"COUNTER_IDLE": slice_controller.get_marker_position(GameplayID.WORKER_IDLE) + Vector2(80.0, 0.0),
		&"OPEN_FLOOR": slice_controller.get_marker_position(GameplayID.AMBIENT_MAIN_A),
		&"WINDOW_LOOK": slice_controller.get_marker_position(GameplayID.AMBIENT_MAIN_B),
		&"PLANT_INSPECT": slice_controller.get_marker_position(GameplayID.AMBIENT_MAIN_C),
	}
	var mochi := Agent.new()
	mochi.actor = slice_controller.worker_actor
	mochi.mover = slice_controller.worker_slice.mover
	mochi.cat_id = &"Mochi"
	mochi.profile = &"WORKER_CALM"
	mochi.zone = &"WORKER_IDLE"
	mochi.time_left = timing.duration(_rng, timing.idle_min, timing.idle_max)
	agents.append(mochi)
	reservations[mochi.zone] = mochi.cat_id
	_spawn_cat(&"PrototypeCatA", &"CALM", &"WINDOW_LOOK", Color(0.72, 0.66, 0.83))
	_spawn_cat(&"PrototypeCatB", &"CURIOUS", &"PLANT_INSPECT", Color(0.88, 0.66, 0.42))
	slice_controller.lifecycle_event.connect(_on_slice_event)
	slice_controller.worker_slice.state_changed.connect(_on_worker_state_changed)
	if debug_overlay != null:
		debug_overlay.master_debug_toggled.connect(_on_debug_toggled)
	_on_debug_toggled(debug_overlay.master_debug_active if debug_overlay != null else false)


func _spawn_cat(cat_id: StringName, profile: StringName, start_zone: StringName, color: Color) -> void:
	var actor := CharacterPlaceholder.new()
	actor.name = String(cat_id)
	actor.character_id = cat_id
	actor.character_name = String(cat_id)
	actor.role = "Ambient"
	actor.primary_color = color
	actor.show_role_badge = false
	actor.character_scale = 0.9
	actor.global_position = _zones[start_zone]
	depth_layer.add_child(actor)
	var mover := SliceMover.new()
	mover.name = "SliceMover"
	mover.movement_speed = timing.ambient_move_speed
	actor.add_child(mover)
	var agent := Agent.new()
	agent.actor = actor
	agent.mover = mover
	agent.cat_id = cat_id
	agent.profile = profile
	agent.zone = start_zone
	agent.activity = &"SIT_REST" if profile == &"CALM" else &"PLANT_INSPECT"
	agent.time_left = timing.duration(_rng, timing.activity_min, timing.activity_max)
	agents.append(agent)
	reservations[start_zone] = cat_id
	mover.route_completed.connect(_on_route_completed.bind(agent))


func set_seed(value: int) -> void:
	_rng.seed = value


func _process(delta: float) -> void:
	if delta <= 0.0:
		return
	for agent in agents:
		if agent.work_priority or agent.mover.is_moving:
			continue
		agent.time_left -= delta
	_try_social_event()
	for agent in agents:
		if agent.work_priority or agent.mover.is_moving or agent.time_left > 0.0:
			continue
		_choose_next(agent)
	queue_redraw()


func _choose_next(agent: Agent) -> void:
	var allowed: Array[StringName] = []
	if agent.cat_id == &"Mochi":
		allowed.assign([&"WORKER_IDLE", &"COUNTER_IDLE"])
	else:
		allowed.assign([&"OPEN_FLOOR", &"WINDOW_LOOK", &"PLANT_INSPECT"])
	var available: Array[StringName] = []
	for zone in allowed:
		if zone == agent.zone or not reservations.has(zone):
			available.append(zone)
	if available.is_empty():
		agent.activity = &"IDLE"
		agent.time_left = timing.duration(_rng, timing.idle_min, timing.idle_max)
		return
	# CALM rests more; CURIOUS travels more. A pause is always a valid outcome.
	var travel_chance: float = 0.35 if agent.profile in [&"CALM", &"WORKER_CALM"] else 0.72
	if _rng.randf() >= travel_chance:
		agent.activity = &"SIT_REST" if agent.profile == &"CALM" else &"LOOK_AROUND"
		agent.time_left = timing.duration(_rng, timing.activity_min, timing.activity_max)
		ambient_changed.emit(agent.cat_id, agent.activity, agent.zone)
		return
	available.erase(agent.zone)
	if available.is_empty():
		agent.activity = &"IDLE"
		agent.time_left = timing.duration(_rng, timing.idle_min, timing.idle_max)
		return
	var destination: StringName = available[_rng.randi_range(0, available.size() - 1)]
	reservations.erase(agent.zone)
	reservations[destination] = agent.cat_id
	agent.target_zone = destination
	agent.activity = &"ROAM"
	agent.time_left = timing.roam_delay
	ambient_changed.emit(agent.cat_id, agent.activity, destination)
	agent.mover.move_route(_route_to(agent, destination))


func _route_to(agent: Agent, destination: StringName) -> Array[Vector2]:
	var route: Array[Vector2] = []
	# The guest cats stay along the right-hand open-floor corridor, not through tables.
	if agent.cat_id != &"Mochi" and agent.zone == &"OPEN_FLOOR" and destination == &"PLANT_INSPECT":
		route.append(_zones[&"WINDOW_LOOK"])
	elif agent.cat_id != &"Mochi" and agent.zone == &"PLANT_INSPECT" and destination == &"OPEN_FLOOR":
		route.append(_zones[&"WINDOW_LOOK"])
	route.append(_zones[destination])
	return route


func _on_route_completed(agent: Agent) -> void:
	if agent.work_priority or agent.target_zone == &"":
		return
	agent.zone = agent.target_zone
	agent.target_zone = &""
	match agent.zone:
		&"WINDOW_LOOK": agent.activity = &"WINDOW_WATCH"
		&"PLANT_INSPECT": agent.activity = &"PLANT_INSPECT"
		&"COUNTER_IDLE": agent.activity = &"COUNTER_IDLE"
		&"OPEN_FLOOR": agent.activity = &"LOOK_AROUND"
		_: agent.activity = &"SIT_REST"
	agent.time_left = timing.duration(_rng, timing.activity_min, timing.activity_max)
	ambient_changed.emit(agent.cat_id, agent.activity, agent.zone)


func _on_slice_event(event_name: StringName) -> void:
	if event_name == &"order_created" or event_name == &"coffee_start":
		_interrupt_mochi()
	elif event_name == &"customer_exited":
		_resume_mochi_after_work()


func _on_worker_state_changed(state: SliceWorker.State) -> void:
	if state != SliceWorker.State.IDLE:
		_interrupt_mochi()
	elif slice_controller.customer == null:
		_resume_mochi_after_work()


func _resume_mochi_after_work() -> void:
	if agents.is_empty() or not agents[0].work_priority \
		or slice_controller.worker_slice.state != SliceWorker.State.IDLE \
		or slice_controller.active_order_id != &"" or slice_controller.customer != null:
		return
	var mochi: Agent = agents[0]
	mochi.work_priority = false
	mochi.zone = &"WORKER_IDLE"
	mochi.activity = &"IDLE"
	mochi.time_left = timing.duration(_rng, timing.idle_min, timing.idle_max)
	reservations[mochi.zone] = mochi.cat_id
	ambient_changed.emit(mochi.cat_id, mochi.activity, mochi.zone)


func _interrupt_mochi() -> void:
	if agents.is_empty():
		return
	var mochi: Agent = agents[0]
	if mochi.work_priority:
		return
	mochi.mover.cancel()
	if reservations.get(mochi.zone) == mochi.cat_id:
		reservations.erase(mochi.zone)
	if reservations.get(mochi.target_zone) == mochi.cat_id:
		reservations.erase(mochi.target_zone)
	mochi.target_zone = &""
	mochi.activity = &"WORK_PRIORITY"
	mochi.time_left = 0.0
	mochi.work_priority = true
	ambient_changed.emit(mochi.cat_id, mochi.activity, mochi.zone)


func _try_social_event() -> void:
	if agents.size() < 3:
		return
	var a: Agent = agents[1]
	var b: Agent = agents[2]
	if a.mover.is_moving or b.mover.is_moving or a.activity == &"SOCIAL_PAUSE" or b.activity == &"SOCIAL_PAUSE":
		return
	if (a.time_left > 0.0 and b.time_left > 0.0) or a.actor.global_position.distance_to(b.actor.global_position) > 310.0:
		return
	if _rng.randf() > 0.30:
		return
	a.activity = &"SOCIAL_PAUSE"
	b.activity = &"SOCIAL_PAUSE"
	a.time_left = timing.social_duration
	b.time_left = timing.social_duration
	(a.actor as CharacterPlaceholder).facing_right = b.actor.global_position.x > a.actor.global_position.x
	(b.actor as CharacterPlaceholder).facing_right = a.actor.global_position.x > b.actor.global_position.x
	ambient_changed.emit(a.cat_id, a.activity, a.zone)
	ambient_changed.emit(b.cat_id, b.activity, b.zone)


func _on_debug_toggled(_active: bool) -> void:
	queue_redraw()


func _draw() -> void:
	if debug_overlay == null or not debug_overlay.master_debug_active:
		return
	for agent in agents:
		var origin: Vector2 = agent.actor.global_position - global_position + Vector2(-42.0, -138.0)
		draw_string(ThemeDB.fallback_font, origin, "%s [%s] %s / %s / %s" % [
			String(agent.cat_id), String(agent.profile), String(agent.activity), String(agent.zone),
			"WORK" if agent.work_priority else "AMBIENT"], HORIZONTAL_ALIGNMENT_LEFT, 380.0, 12, Color.WHITE)
	for zone in reservations:
		var point: Vector2 = _zones[zone] - global_position
		draw_circle(point, 7.0, Color(0.35, 0.9, 0.7, 0.75))
		draw_string(ThemeDB.fallback_font, point + Vector2(10.0, -6.0), "%s: %s" % [String(zone), String(reservations[zone])],
			HORIZONTAL_ALIGNMENT_LEFT, 250.0, 11, Color(0.35, 0.9, 0.7))


func agent_for(cat_id: StringName) -> Agent:
	for agent in agents:
		if agent.cat_id == cat_id:
			return agent
	return null


func occupied_zone_count() -> int:
	return reservations.size()


func register_optional_zone(zone_id: StringName, world_position: Vector2) -> void:
	## V2-only semantic destinations; base Living Café choice rules are unchanged.
	if zone_id == &"" or _zones.has(zone_id):
		return
	_zones[zone_id] = world_position


func begin_external_ambient_moment(cat_id: StringName, target_zone: StringName) -> bool:
	## Temporarily borrows one non-worker agent without creating another AI loop.
	var agent: Agent = agent_for(cat_id)
	if agent == null or cat_id == &"Mochi" or agent.work_priority or agent.mover.is_moving \
		or not _zones.has(target_zone) or reservations.has(target_zone):
		return false
	if reservations.get(agent.zone) == cat_id:
		reservations.erase(agent.zone)
	reservations[target_zone] = cat_id
	agent.work_priority = true
	agent.target_zone = target_zone
	agent.activity = &"STORY_APPROACH"
	agent.mover.move_route(_route_to(agent, target_zone))
	ambient_changed.emit(cat_id, agent.activity, target_zone)
	return true


func end_external_ambient_moment(cat_id: StringName) -> void:
	var agent: Agent = agent_for(cat_id)
	if agent == null or not agent.work_priority:
		return
	if agent.target_zone != &"":
		agent.zone = agent.target_zone
		agent.target_zone = &""
	agent.work_priority = false
	agent.activity = &"LOOK_AROUND"
	agent.time_left = timing.duration(_rng, timing.activity_min, timing.activity_max)
	ambient_changed.emit(cat_id, agent.activity, agent.zone)
