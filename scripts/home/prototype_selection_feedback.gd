class_name PrototypeSelectionFeedback
extends Node2D
## Brief ring/highlight confirming the world object that received a tap.

var bounds: Rect2 = Rect2(-36.0, -36.0, 72.0, 72.0)
var message: String = ""
var tint: Color = Color("#77a779")
var _elapsed: float = 0.0
var _duration: float = 1.15


func _ready() -> void:
	visible = false
	set_process(false)


func show_feedback(world_bounds: Rect2, text: String, accepted: bool = true) -> void:
	bounds = world_bounds
	message = text
	tint = Color("#77a779") if accepted else Color("#ca7455")
	_elapsed = 0.0
	visible = true
	set_process(true)
	queue_redraw()


func clear_feedback() -> void:
	visible = false
	set_process(false)
	message = ""
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()
	if _elapsed >= _duration:
		visible = false
		set_process(false)


func _draw() -> void:
	if not visible:
		return
	var opacity: float = 1.0 - clampf(_elapsed / _duration, 0.0, 1.0)
	var box := Rect2(bounds.position - global_position, bounds.size)
	draw_rect(box, Color(tint.r, tint.g, tint.b, 0.92 * opacity), false, 4.0)
	var plate := Rect2(box.position.x, box.position.y - 34.0, maxf(box.size.x, 124.0), 29.0)
	draw_rect(plate, Color(0.13, 0.24, 0.20, 0.88 * opacity), true)
	draw_string(ThemeDB.fallback_font, plate.position + Vector2(8.0, 21.0), message,
		HORIZONTAL_ALIGNMENT_LEFT, plate.size.x - 12.0, 17,
		Color(1.0, 0.97, 0.87, opacity))
