class_name SliceMover
extends Node
## Moves the parent character's floor-contact origin through an authored world-space route.

signal destination_reached(position: Vector2)
signal route_completed

@export var movement_speed: float = 240.0

var is_moving: bool = false
var current_target: Vector2 = Vector2.ZERO
var _route: Array[Vector2] = []
var _actor: Node2D


func _ready() -> void:
	_actor = get_parent() as Node2D
	set_process(false)


func move_route(points: Array[Vector2]) -> void:
	cancel()
	if points.is_empty():
		route_completed.emit()
		return
	_route = points.duplicate()
	_advance_target()


func cancel() -> void:
	_route.clear()
	is_moving = false
	current_target = Vector2.ZERO
	set_process(false)


func _process(delta: float) -> void:
	if not is_moving or _actor == null or delta <= 0.0:
		return
	var previous_position: Vector2 = _actor.global_position
	_actor.global_position = previous_position.move_toward(current_target, maxf(movement_speed, 0.0) * delta)
	if not is_equal_approx(_actor.global_position.x, previous_position.x) and _actor.has_method("set_facing_right"):
		_actor.call("set_facing_right", _actor.global_position.x > previous_position.x)
	if _actor.global_position.distance_squared_to(current_target) <= 0.0001:
		_actor.global_position = current_target
		destination_reached.emit(current_target)
		_advance_target()


func _advance_target() -> void:
	if _route.is_empty():
		is_moving = false
		current_target = Vector2.ZERO
		set_process(false)
		route_completed.emit()
		return
	current_target = _route.pop_front()
	is_moving = true
	set_process(true)
