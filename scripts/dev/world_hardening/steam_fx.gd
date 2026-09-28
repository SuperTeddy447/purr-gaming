@tool
extends Node2D
## Tiny placeholder steam wisps, not final art or audio.


func _draw() -> void:
	for x in [-10, 0, 10]:
		draw_arc(Vector2(x, -10), 8, PI * 0.2, PI * 1.25, 10, Color(0.86, 0.9, 0.85, 0.8), 2.0)
