@tool
extends Node2D
## Placeholder only; not a production carry drink or art asset.


func _draw() -> void:
	draw_rect(Rect2(-10, -11, 20, 22), Color("#f1e8d5"))
	draw_arc(Vector2(11, -2), 7, -PI * 0.5, PI * 0.5, 12, Color("#f1e8d5"), 3.0)
	draw_rect(Rect2(-10, -12, 20, 4), Color("#8e5640"))
