class_name HardeningActor
extends CharacterBody2D
## Generic actor-to-slot contract. No map-specific destination positions.

signal action_started(slot: HardeningInteractionSlot)
signal action_completed(slot: HardeningInteractionSlot)
signal action_cancelled(slot: HardeningInteractionSlot, reason: StringName)
signal route_completed()

enum Phase { IDLE, APPROACH, ACTION, EXIT, ROUTE }

@export_enum("worker", "customer", "cat") var category := "cat"
@export_range(30.0, 500.0) var move_speed := 175.0

var phase := Phase.IDLE
var path_trace: Array[Vector2] = []
var last_action: StringName = &""
var failed_navigation := false
var _world: HardeningWorld
var _slot: HardeningInteractionSlot
var _route_marker: Marker2D
var _action_elapsed := 0.0
var _target := Vector2.ZERO
var _nav_revision := -1

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	navigation_agent.path_desired_distance = 6.0
	navigation_agent.target_desired_distance = 9.0
	set_physics_process(false)


func actor_category() -> StringName:
	return StringName(category)


func bind_world(world: HardeningWorld) -> void:
	_world = world


func request_interaction(action: StringName) -> bool:
	if _world == null or phase != Phase.IDLE:
		return false
	var selected := _world.reserve_available_slot(action, self)
	if selected == null:
		return false
	_start_reserved_action(selected, action)
	return true


func request_interaction_on(object_id: StringName, action: StringName) -> bool:
	if _world == null or phase != Phase.IDLE:
		return false
	var selected := _world.find_slot_on_object(object_id, action)
	if selected == null or not selected.reserve(self):
		return false
	_start_reserved_action(selected, action)
	return true


func _start_reserved_action(selected: HardeningInteractionSlot, action: StringName) -> void:
	_slot = selected
	last_action = action
	phase = Phase.APPROACH
	failed_navigation = false
	path_trace.clear()
	_set_target(_slot.approach_anchor().global_position)
	set_physics_process(true)


func navigate_to_marker(marker: Marker2D) -> bool:
	if marker == null or phase != Phase.IDLE:
		return false
	_route_marker = marker
	phase = Phase.ROUTE
	failed_navigation = false
	path_trace.clear()
	_set_target(marker.global_position)
	set_physics_process(true)
	return true


func refresh_target_after_world_move() -> void:
	if _slot != null and is_instance_valid(_slot):
		match phase:
			Phase.APPROACH: _set_target(_slot.approach_anchor().global_position)
			Phase.ACTION: global_position = _slot.action_anchor().global_position
			Phase.EXIT: _set_target(_slot.exit_anchor().global_position)
	elif _route_marker != null and is_instance_valid(_route_marker) and phase == Phase.ROUTE:
		_set_target(_route_marker.global_position)


func cancel_action(reason: StringName = &"cancel") -> void:
	if _slot != null and is_instance_valid(_slot):
		var old := _slot
		old.release(self, reason)
		action_cancelled.emit(old, reason)
	_slot = null
	_route_marker = null
	phase = Phase.IDLE
	velocity = Vector2.ZERO
	set_physics_process(false)
	queue_redraw()


func _set_target(target: Vector2) -> void:
	_target = target
	navigation_agent.target_position = target
	_nav_revision = _world.navigation.revision if _world != null else -1


func _physics_process(delta: float) -> void:
	if phase in [Phase.APPROACH, Phase.ACTION, Phase.EXIT] \
			and (not is_instance_valid(_slot) or not _slot.is_reserved_by(self)):
		cancel_action(&"slot_lost")
		return
	if phase == Phase.ACTION:
		global_position = _slot.action_anchor().global_position
		_action_elapsed += delta
		if _action_elapsed >= _slot.action_duration:
			phase = Phase.EXIT
			_set_target(_slot.exit_anchor().global_position)
		return
	if phase == Phase.IDLE:
		return
	if _world != null and _world.navigation.revision != _nav_revision:
		refresh_target_after_world_move()
	if global_position.distance_to(_target) <= 10.0:
		_arrive()
		return
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		failed_navigation = true
		cancel_action(&"navigation_failure")
		return
	var next := navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next) * move_speed
	move_and_slide()
	if path_trace.is_empty() or path_trace[-1].distance_to(global_position) > 4.0:
		path_trace.append(global_position)
	queue_redraw()


func _arrive() -> void:
	global_position = _target
	match phase:
		Phase.APPROACH:
			if not _slot.occupy(self):
				cancel_action(&"occupy_rejected")
				return
			phase = Phase.ACTION
			_action_elapsed = 0.0
			global_position = _slot.action_anchor().global_position
			action_started.emit(_slot)
		Phase.EXIT:
			var finished := _slot
			_slot = null
			phase = Phase.IDLE
			set_physics_process(false)
			finished.release(self, &"complete")
			action_completed.emit(finished)
		Phase.ROUTE:
			_route_marker = null
			phase = Phase.IDLE
			set_physics_process(false)
			route_completed.emit()
	queue_redraw()


func _exit_tree() -> void:
	if _slot != null and is_instance_valid(_slot):
		_slot.release(self, &"actor_removed")
	_slot = null


func _draw() -> void:
	var fill := Color("#b4a8c5")
	match category:
		"worker": fill = Color("#d49a6b")
		"customer": fill = Color("#8eb4c6")
	draw_circle(Vector2(0, -25), 13, fill)
	draw_circle(Vector2(0, -47), 12, fill.lightened(0.11))
	draw_circle(Vector2(-4, -48), 2, Color("#3d3732"))
	draw_circle(Vector2(4, -48), 2, Color("#3d3732"))
	draw_string(ThemeDB.fallback_font, Vector2(-35, -68), name, HORIZONTAL_ALIGNMENT_CENTER, 70, 11, Color("#443b35"))
	if phase == Phase.ACTION:
		draw_arc(Vector2(0, -25), 19, 0, TAU, 24, Color("#e0b363"), 2.0)
