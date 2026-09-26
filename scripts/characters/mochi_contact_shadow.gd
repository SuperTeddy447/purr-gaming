class_name MochiContactShadow
extends Node2D
## Subtle floor-only shadow independent of animation frame artwork.


func _draw() -> void:
	var points := PackedVector2Array()
	for index in range(32):
		var angle: float = TAU * float(index) / 32.0
		points.append(Vector2(cos(angle) * 26.0, sin(angle) * 6.0))
	draw_colored_polygon(points, Color(0.09, 0.09, 0.08, 0.18))
