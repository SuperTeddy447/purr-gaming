@tool
extends Node2D
## Small owned-anchor marker for the greybox; not production FX.

@export var tint := Color("#c48e6e"):
	set(value):
		tint = value
		queue_redraw()
@export var short_label := "FX":
	set(value):
		short_label = value
		queue_redraw()


func _draw() -> void:
	draw_arc(Vector2.ZERO, 10, 0, TAU, 20, tint, 2.0)
	draw_circle(Vector2.ZERO, 3, tint)
	draw_string(ThemeDB.fallback_font, Vector2(13, 4), short_label,
		HORIZONTAL_ALIGNMENT_LEFT, 84, 10, tint)
