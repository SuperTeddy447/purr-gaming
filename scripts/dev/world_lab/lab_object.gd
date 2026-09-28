@tool
extends Node2D
## Deliberately plain editor-visible silhouettes; no production art or gameplay.

@export_enum("none", "counter", "table", "chair", "bed", "plant", "entrance") var kind := "none":
	set(value):
		kind = value
		queue_redraw()
@export var stable_id: StringName = &""


func _draw() -> void:
	match kind:
		"counter":
			draw_rect(Rect2(-110, -85, 220, 78), Color("#8c6b57"))
			draw_rect(Rect2(-110, -85, 220, 14), Color("#d0aa78"))
			draw_string(ThemeDB.fallback_font, Vector2(-60, -48), "COUNTER", HORIZONTAL_ALIGNMENT_LEFT, 120, 17, Color.WHITE)
		"table":
			draw_rect(Rect2(-7, -39, 14, 39), Color("#715744"))
			draw_circle(Vector2(0, -43), 47, Color("#a67956"))
			draw_circle(Vector2(0, -43), 35, Color("#caa078"))
		"chair":
			draw_rect(Rect2(-22, -38, 44, 34), Color("#537f72"))
			draw_rect(Rect2(-19, -4, 38, 9), Color("#38695e"))
		"bed":
			draw_ellipse_shape(Vector2.ZERO, Vector2(46, 23), Color("#9a7162"))
			draw_ellipse_shape(Vector2(0, -4), Vector2(35, 15), Color("#e8c9a5"))
		"plant":
			draw_rect(Rect2(-13, -25, 26, 24), Color("#b77d55"))
			for offset in [-20, 0, 20]:
				draw_circle(Vector2(offset, -43), 19, Color("#6a9275"))
		"entrance":
			draw_rect(Rect2(-42, -90, 84, 90), Color("#9a806f"), false, 7)
			draw_line(Vector2(0, -84), Vector2(0, 0), Color("#b8a18a"), 4)
			draw_string(ThemeDB.fallback_font, Vector2(-39, -105), "ENTRANCE", HORIZONTAL_ALIGNMENT_LEFT, 90, 13, Color("#544538"))


func draw_ellipse_shape(center: Vector2, radii: Vector2, fill: Color) -> void:
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, fill)
