@tool
extends Node2D
## Quiet matte outside the fixed micro-room plate; not an environment sample.


func _draw() -> void:
	draw_rect(Rect2(-200, -100, 1040, 1200), Color(0.68, 0.66, 0.60), true)
