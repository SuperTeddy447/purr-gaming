class_name HomeWorkerRegion
extends Node2D
## Non-physics spatial reference for the counter worker area in Home Mock V0.

@export var bounds: Rect2 = Rect2(0.0, 0.0, 430.0, 250.0)


func contains_world_point(point: Vector2) -> bool:
	return bounds.has_point(to_local(point))
