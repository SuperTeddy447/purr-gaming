@tool
extends Node2D
## Greybox counter lip. It remains object-owned; no actor z-index override.


func _draw() -> void:
	if get_parent() != null and get_parent().has_node("RuntimeVisual"):
		return
	draw_rect(Rect2(-112, -1, 224, 14), Color("#745744"))
	draw_line(Vector2(-112, -1), Vector2(112, -1), Color("#d4ac7c"), 3.0)
