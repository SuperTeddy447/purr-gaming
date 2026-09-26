class_name PrototypeDoorController
extends Node
## Temporary transform-only entrance response on the existing Y-sorted door leaves.

signal state_changed(state: State)
signal presentation_event(event_name: StringName)
signal threshold_crossed(direction: StringName)

enum State { CLOSED, OPENING, OPEN, CLOSING }

@export var left_leaf: Node2D
@export var right_leaf: Node2D
@export var timing_config: PrototypeTimingConfig
@export_range(1.0, 120.0, 1.0) var open_separation: float = 42.0

var state: State = State.CLOSED
var _closed_left: Vector2
var _closed_right: Vector2
var _transition: Tween
var _close_timer: Timer


func _ready() -> void:
	if left_leaf == null or right_leaf == null or timing_config == null:
		push_error("Prototype door requires both existing door leaves and the shared timing config.")
		return
	_closed_left = left_leaf.position
	_closed_right = right_leaf.position
	_close_timer = Timer.new()
	_close_timer.one_shot = true
	_close_timer.timeout.connect(close_door)
	add_child(_close_timer)
	_set_state(State.CLOSED)


func open_door() -> void:
	if _close_timer != null:
		_close_timer.stop()
	if state == State.OPEN or state == State.OPENING:
		return
	_kill_transition()
	_set_state(State.OPENING)
	_transition = create_tween().set_parallel(true)
	var transition_duration: float = timing_config.resolve_duration(timing_config.door_transition_duration)
	_transition.tween_property(left_leaf, "position", _closed_left + Vector2(-open_separation, 0.0), transition_duration)
	_transition.tween_property(right_leaf, "position", _closed_right + Vector2(open_separation, 0.0), transition_duration)
	_transition.finished.connect(func() -> void: _set_state(State.OPEN))


func close_after(duration: float) -> void:
	if _close_timer == null or state == State.CLOSED or state == State.CLOSING:
		return
	_close_timer.start(timing_config.resolve_duration(duration))


func close_door() -> void:
	if _close_timer != null:
		_close_timer.stop()
	if state == State.CLOSED or state == State.CLOSING:
		return
	_kill_transition()
	_set_state(State.CLOSING)
	_transition = create_tween().set_parallel(true)
	var transition_duration: float = timing_config.resolve_duration(timing_config.door_transition_duration)
	_transition.tween_property(left_leaf, "position", _closed_left, transition_duration)
	_transition.tween_property(right_leaf, "position", _closed_right, transition_duration)
	_transition.finished.connect(func() -> void: _set_state(State.CLOSED))


func state_name() -> String:
	return State.keys()[state]


func notify_threshold_crossed(direction: StringName) -> void:
	if direction not in [&"entry", &"exit"]:
		return
	threshold_crossed.emit(direction)


func _kill_transition() -> void:
	if _transition != null and _transition.is_running():
		_transition.kill()


func _set_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	match state:
		State.OPENING:
			presentation_event.emit(&"door_open")
		State.OPEN:
			presentation_event.emit(&"door_open_complete")
		State.CLOSING:
			presentation_event.emit(&"door_close")
		State.CLOSED:
			presentation_event.emit(&"door_close_complete")
	state_changed.emit(state)
