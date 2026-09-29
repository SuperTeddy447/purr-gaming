extends Node2D
## Dev-only rendering diagnostics. Coordinates are authored in the lab scene.

@export var lamp_path: NodePath
@export var window_path: NodePath
@export var director_path: NodePath


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	var lamp := get_node_or_null(lamp_path) as AtmosphereLamp
	var window := get_node_or_null(window_path) as WindowLightingController
	var director := get_node_or_null(director_path) as WorldAtmosphereDirector
	if lamp == null or window == null or director == null:
		return
	var lamp_at := to_local(lamp.global_position)
	var window_at := to_local(window.global_position)
	draw_arc(lamp_at, lamp.radius, 0, TAU, 48, Color(1.0, 0.66, 0.17, 0.64), 2)
	draw_circle(lamp_at, 6, Color(1.0, 0.61, 0.16, 0.95))
	draw_rect(Rect2(window_at + Vector2(-22, -85), Vector2(44, 170)),
		Color(0.13, 0.82, 1.0, 0.9), false, 2)
	draw_line(Vector2(320, 105), Vector2(320, 105) + Vector2.RIGHT.rotated(director.output.sun_angle) * 65,
		Color(1.0, 0.78, 0.2, 0.9), 3)
