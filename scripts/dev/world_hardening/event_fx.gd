@tool
extends Node2D
## One non-production seasonal FX placeholder.


func _draw() -> void:
	for point in [Vector2(-26, -21), Vector2(30, -32), Vector2(-12, -52), Vector2(25, -63)]:
		draw_circle(point, 3, Color("#e8b8c0"))
