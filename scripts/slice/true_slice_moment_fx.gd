class_name TrueSliceMomentFX
extends Node2D
## One restrained, replaceable world-space accent for key coffee-service moments.

@export var presentation: TrueSlicePresentation
@export var slice_controller: VerticalSliceController
@export var station_slot: Node2D

var current_moment: StringName = &""
var _center: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0
const DURATION: float = 0.55


func _ready() -> void:
	visible = false
	set_process(false)
	if presentation != null:
		presentation.slice_event.connect(_on_slice_event)


func _on_slice_event(event_id: StringName) -> void:
	match event_id:
		&"order_appear", &"coffee_served", &"customer_satisfied":
			if slice_controller.customer == null:
				return
			_center = to_local(slice_controller.customer.global_position + Vector2(0.0, -95.0))
		&"coffee_prepare_started":
			if station_slot == null:
				return
			_center = to_local(station_slot.global_position + Vector2(0.0, -75.0))
		&"coffee_pickup":
			_center = to_local(slice_controller.worker_actor.global_position + Vector2(22.0, -75.0))
		_:
			return
	current_moment = event_id
	_elapsed = 0.0
	visible = true
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DURATION:
		visible = false
		set_process(false)
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	var progress: float = clampf(_elapsed / DURATION, 0.0, 1.0)
	var color: Color = Color("#e8d392") if current_moment in [&"order_appear", &"coffee_prepare_started"] else Color("#b6dea6")
	color.a = (1.0 - progress) * 0.74
	draw_arc(_center, lerpf(20.0, 49.0, progress), 0.0, TAU, 32, color, 3.0)
