@tool
extends Node2D
## Small object-owned doorway marker; the portal slots stay on the parent object.

@export var foreground_entrance := false


func _draw() -> void:
	if foreground_entrance:
		_draw_foreground_entrance()
		return
	var frame := Color("#765d43")
	var panel := Color("#315e58")
	var inset := Color("#f0dec1")
	draw_rect(Rect2(-29, -62, 58, 62), frame)
	draw_rect(Rect2(-24, -57, 48, 52), panel)
	draw_rect(Rect2(-17, -50, 34, 27), inset)
	draw_line(Vector2(-30, 0), Vector2(30, 0), Color("#b88b50"), 3.0)
	draw_circle(Vector2(13, -17), 2.5, Color("#b88b50"))


func _draw_foreground_entrance() -> void:
	var frame := Color("#5f493b")
	var trim := Color("#b88b50")
	var panel := Color("#315e58")
	var inset := Color("#d9c3a0")
	draw_rect(Rect2(-46, -94, 92, 94), frame)
	draw_rect(Rect2(-40, -88, 80, 88), trim, false, 4.0)
	draw_rect(Rect2(-35, -82, 32, 82), panel)
	draw_rect(Rect2(3, -82, 32, 82), panel)
	draw_rect(Rect2(-29, -74, 20, 25), inset)
	draw_rect(Rect2(9, -74, 20, 25), inset)
	draw_line(Vector2(0, -82), Vector2(0, -3), trim, 3.0)
	draw_circle(Vector2(-6, -40), 2.5, trim)
	draw_circle(Vector2(6, -40), 2.5, trim)
	draw_line(Vector2(-55, 2), Vector2(55, 2), trim, 4.0)
	draw_line(Vector2(-45, 7), Vector2(45, 7), Color("#7b5e49"), 2.0)
