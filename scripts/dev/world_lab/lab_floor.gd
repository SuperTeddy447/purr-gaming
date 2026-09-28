@tool
extends Node2D
## A neutral floor allows movement and depth to be judged without art.


func _draw() -> void:
	draw_rect(Rect2(0, 0, 520, 850), Color("#e8ded0"))
	draw_rect(Rect2(0, 0, 520, 850), Color("#9b8c79"), false, 5)
	draw_string(ThemeDB.fallback_font, Vector2(20, 38), "WORLD ARCHITECTURE LAB", HORIZONTAL_ALIGNMENT_LEFT, 350, 23, Color("#514638"))

