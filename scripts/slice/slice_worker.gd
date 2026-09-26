class_name SliceWorker
extends Node
## Worker action boundaries can later be completed by sprite animations instead of timers.

signal state_changed(state: State)
signal coffee_prepared
signal serve_finished

enum State { IDLE, ORDER_RECEIVED, WALKING_TO_COFFEE, PREPARING_COFFEE, WALKING_TO_SERVE, READY_TO_SERVE, SERVING, RETURNING_TO_IDLE }

var state: State = State.IDLE
var mover: SliceMover
var actor: Node2D
var _action_timer: Timer
var _action_label: Label
var _action_duration: float = 0.0
var show_action_label: bool = false


func _ready() -> void:
	actor = get_parent() as Node2D
	mover = actor.get_node("SliceMover") as SliceMover
	_action_timer = Timer.new()
	_action_timer.one_shot = true
	_action_timer.timeout.connect(_on_action_finished)
	add_child(_action_timer)
	_action_label = actor.get_node_or_null("WorkerActionLabel") as Label
	if _action_label == null:
		_action_label = Label.new()
		_action_label.name = "WorkerActionLabel"
		_action_label.position = Vector2(-72.0, -214.0)
		_action_label.size = Vector2(144.0, 26.0)
		_action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_action_label.z_index = 0
		actor.call_deferred("add_child", _action_label)
	_action_label.visible = false
	add_to_group(&"prototype_worker")


func set_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_changed.emit(state)


func state_name() -> String:
	return State.keys()[state]


func readable_state_name() -> String:
	match state:
		State.IDLE:
			return "Idle"
		State.ORDER_RECEIVED:
			return "Order Received"
		State.WALKING_TO_COFFEE:
			return "Walking to Coffee"
		State.PREPARING_COFFEE:
			return "Preparing Coffee"
		State.WALKING_TO_SERVE:
			return "Carrying Coffee"
		State.READY_TO_SERVE:
			return "Ready to Serve"
		State.SERVING:
			return "Serving"
		State.RETURNING_TO_IDLE:
			return "Returning to Idle"
	return "Working"


func action_progress() -> float:
	if _action_duration <= 0.0 or _action_timer == null or _action_timer.time_left <= 0.0:
		return 1.0
	return clampf(1.0 - _action_timer.time_left / _action_duration, 0.0, 1.0)


func begin_preparation(duration: float) -> void:
	set_state(State.PREPARING_COFFEE)
	_action_duration = maxf(duration, 0.001)
	_action_label.text = "BREWING..."
	_action_label.visible = show_action_label
	_action_timer.start(_action_duration)


func begin_serve(duration: float) -> void:
	set_state(State.SERVING)
	_action_duration = maxf(duration, 0.001)
	_action_label.text = "SERVING..."
	_action_label.visible = show_action_label
	_action_timer.start(_action_duration)


func cancel_action() -> void:
	_action_timer.stop()
	_action_duration = 0.0
	_action_label.visible = false


func set_debug_action_label_visible(is_debug: bool) -> void:
	show_action_label = is_debug
	if _action_label != null:
		_action_label.visible = is_debug and state in [State.PREPARING_COFFEE, State.SERVING]


func _on_action_finished() -> void:
	_action_label.visible = false
	_action_duration = 0.0
	if state == State.PREPARING_COFFEE:
		coffee_prepared.emit()
	elif state == State.SERVING:
		serve_finished.emit()
