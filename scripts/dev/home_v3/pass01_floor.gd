@tool
extends Node2D
## Continuous layout sketch for Pass 01; object scenes still own every floor footprint.

const ROOM := Rect2(0, 0, 640, 1320)


func _draw() -> void:
	draw_rect(ROOM, Color("#e8e0d4"))
	# Fixed edge hints stay outside the playable nav region; these are not
	# gameplay collision or generated environment art.
	draw_rect(Rect2(0, 72, 640, 84), Color("#c5b3a0"))
	draw_rect(Rect2(26, 156, 20, 1110), Color("#d2c1ab"))
	draw_rect(Rect2(594, 156, 20, 1110), Color("#d2c1ab"))
	# A small service backdrop, rather than a full-width horizontal zone.
	draw_rect(Rect2(50, 194, 252, 252), Color("#d9c9b5"))
	draw_rect(Rect2(311, 225, 265, 236), Color("#ddd0bd"))
	# Window/perch corner and its modest pool of light.
	draw_rect(Rect2(565, 360, 40, 172), Color("#9db9b4"))
	draw_rect(Rect2(572, 369, 25, 153), Color("#dcebe5"))
	draw_line(Vector2(584, 369), Vector2(584, 522), Color("#7b9993"), 3)
	draw_line(Vector2(572, 445), Vector2(597, 445), Color("#7b9993"), 3)
	_draw_ellipse(Vector2(506, 556), Vector2(100, 105), Color("#d9dfd4"))
	# Interwoven seating islands and a protected, left-wall rest pocket.
	_draw_ellipse(Vector2(208, 700), Vector2(145, 126), Color("#ead2b9"))
	_draw_ellipse(Vector2(442, 843), Vector2(140, 117), Color("#e3cbb1"))
	draw_rect(Rect2(48, 482, 184, 135), Color("#ded9cc"))
	draw_rect(Rect2(48, 482, 124, 11), Color("#b8aa98"))
	_draw_ellipse(Vector2(168, 552), Vector2(87, 62), Color("#e7d4c0"))
	# A second cat-life landmark by the entry, not a separate cat zone.
	draw_rect(Rect2(48, 903, 94, 117), Color("#dfd2c0"))
	# Event nook touches the active café/entry edge, with open route beside it.
	_draw_ellipse(Vector2(507, 1090), Vector2(92, 92), Color("#e1d3cc"))
	draw_rect(Rect2(265, 1122, 110, 120), Color("#efe6da"))
	draw_rect(ROOM, Color("#877e72"), false, 5.0)


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 40:
		var angle := TAU * float(i) / 40.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
