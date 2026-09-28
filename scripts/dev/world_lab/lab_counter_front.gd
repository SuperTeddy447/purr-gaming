@tool
extends Node2D
## Floor-contact pivot is at the lower counter face; normal Y-sort decides occlusion.


func _draw() -> void:
	draw_rect(Rect2(-110, -15, 220, 37), Color("#4d7069"))
	draw_rect(Rect2(-110, -15, 220, 5), Color("#e5bc7b"))
	draw_string(ThemeDB.fallback_font, Vector2(-73, 11), "FRONT OCCLUDER", HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Color.WHITE)

