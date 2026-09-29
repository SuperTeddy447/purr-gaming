@tool
extends Node2D
## Neutral spatial sketch, not a new Home image or source artwork.


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 970), Color(0.77, 0.75, 0.69), true)
	draw_rect(Rect2(24, 80, 592, 312), Color(0.84, 0.82, 0.75), true)
	draw_rect(Rect2(24, 390, 592, 540), Color(0.75, 0.72, 0.65), true)
	draw_line(Vector2(24, 391), Vector2(616, 391), Color(0.49, 0.45, 0.38), 4)
	draw_rect(Rect2(258, 274, 322, 145), Color(0.37, 0.43, 0.41, 0.13), false, 2)
	draw_rect(Rect2(52, 656, 354, 200), Color(0.52, 0.48, 0.38, 0.12), false, 2)
