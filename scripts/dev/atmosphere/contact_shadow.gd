extends Node2D
## A movable prop's ground contact remains local to its owner.


func _ready() -> void:
	show_behind_parent = true
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2(0, 5), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 25, Color(0.12, 0.09, 0.07, 0.24))
