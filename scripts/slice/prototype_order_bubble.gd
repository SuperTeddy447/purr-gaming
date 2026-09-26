class_name PrototypeOrderBubble
extends Node2D
## Temporary world-space order/readiness cue attached to the active customer.

var ready_for_serve: bool = false
var _pop_elapsed: float = 0.0


func _ready() -> void:
	position = Vector2(0.0, -162.0)
	z_index = 2
	scale = Vector2.ONE * 0.82
	queue_redraw()


func _process(delta: float) -> void:
	_pop_elapsed = minf(_pop_elapsed + delta, 0.22)
	var progress: float = _pop_elapsed / 0.22
	var eased: float = 1.0 - pow(1.0 - progress, 3.0)
	scale = Vector2.ONE * lerpf(0.82, 1.0, eased)
	if _pop_elapsed >= 0.22:
		set_process(false)


func set_ready_for_serve(is_ready: bool) -> void:
	ready_for_serve = is_ready
	queue_redraw()


func _draw() -> void:
	var fill: Color = Color("#fff4dc") if not ready_for_serve else Color("#e8f2cf")
	var outline: Color = Color("#694732") if not ready_for_serve else Color("#38634b")
	var box := Rect2(-82.0, -42.0, 164.0, 56.0)
	draw_rect(box, fill, true)
	draw_rect(box, outline, false, 3.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-9.0, 14.0), Vector2(9.0, 14.0), Vector2(0.0, 28.0)
	]), fill)
	draw_line(Vector2(-9.0, 14.0), Vector2(0.0, 28.0), outline, 2.0)
	draw_line(Vector2(0.0, 28.0), Vector2(9.0, 14.0), outline, 2.0)
	# A deliberately plain cup remains recognizable at default phone framing.
	draw_rect(Rect2(-68.0, -25.0, 21.0, 23.0), Color("#a85b3e"), true)
	draw_rect(Rect2(-64.0, -23.0, 13.0, 7.0), Color("#fff4dc"), true)
	draw_arc(Vector2(-45.0, -15.0), 7.0, -PI * 0.5, PI * 0.5, 12, outline, 2.5)
	var title: String = "READY!" if ready_for_serve else "COFFEE ORDER"
	draw_string(ThemeDB.fallback_font, Vector2(-34.0, -16.0), title,
		HORIZONTAL_ALIGNMENT_LEFT, 112.0, 16, Color("#263c31") if ready_for_serve else Color("#3f3329"))
	draw_string(ThemeDB.fallback_font, Vector2(-34.0, 2.0), "TAP TO SERVE" if ready_for_serve else "TAP ESPRESSO",
		HORIZONTAL_ALIGNMENT_LEFT, 112.0, 11, Color("#5f5948"))
