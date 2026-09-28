@tool
class_name HardeningFootprint
extends StaticBody2D
## Floor occupancy; intentionally independent of transparent sprite bounds.

@export var footprint_size := Vector2(60, 30):
	set(value):
		footprint_size = value
		_update_shape()
		queue_redraw()


func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	_update_shape()


func _update_shape() -> void:
	if not is_node_ready() or not has_node("CollisionShape2D"):
		return
	var rect := RectangleShape2D.new()
	rect.size = footprint_size
	$CollisionShape2D.shape = rect


func navigation_outline() -> PackedVector2Array:
	var half := footprint_size * 0.5
	return PackedVector2Array([
		global_transform * Vector2(-half.x, -half.y),
		global_transform * Vector2(half.x, -half.y),
		global_transform * Vector2(half.x, half.y),
		global_transform * Vector2(-half.x, half.y),
	])


func global_bounds() -> Rect2:
	var outline := navigation_outline()
	var bounds := Rect2(outline[0], Vector2.ZERO)
	for point in outline:
		bounds = bounds.expand(point)
	return bounds


func _draw() -> void:
	if not Engine.is_editor_hint() and not get_tree().debug_collisions_hint:
		return
	var rect := Rect2(-footprint_size * 0.5, footprint_size)
	draw_rect(rect, Color(0.8, 0.25, 0.1, 0.16))
	draw_rect(rect, Color(0.8, 0.25, 0.1, 0.7), false, 1.0)
