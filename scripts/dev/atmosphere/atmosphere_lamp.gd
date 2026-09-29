class_name AtmosphereLamp
extends Node2D
## Reusable practical light. The emitted light and fixture follow this node.

enum Override { AUTO, FORCE_OFF, FORCE_ON, DIMMED }

@export var manual_override := Override.AUTO
@export var radius := 168.0
var auto_energy := 0.0
var effective_energy := 0.0

@onready var point_light: PointLight2D = $PointLight2D


func _ready() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 0.83, 0.57, 0.88))
	gradient.set_color(1, Color(1, 0.82, 0.54, 0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 256
	texture.height = 256
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1, 0.5)
	point_light.texture = texture
	point_light.texture_scale = radius * 2.0 / 256.0
	point_light.shadow_enabled = false
	_apply()


func set_auto_energy(value: float) -> void:
	auto_energy = clampf(value, 0.0, 1.0)
	_apply()


func set_manual_override(value: Override) -> void:
	manual_override = value
	_apply()


func _apply() -> void:
	match manual_override:
		Override.FORCE_OFF: effective_energy = 0.0
		Override.FORCE_ON: effective_energy = 1.0
		Override.DIMMED: effective_energy = 0.35
		_: effective_energy = auto_energy
	if is_node_ready():
		point_light.energy = effective_energy * 1.15
		point_light.enabled = effective_energy > 0.01
	queue_redraw()


func _draw() -> void:
	draw_line(Vector2(0, -28), Vector2.ZERO, Color(0.22, 0.18, 0.14), 3)
	draw_colored_polygon(PackedVector2Array([Vector2(-14, 0), Vector2(14, 0),
		Vector2(20, 14), Vector2(-20, 14)]), Color(0.40, 0.36, 0.28))
	draw_circle(Vector2(0, 10), 7, Color(1, 0.84, 0.52, 0.35 + effective_energy * 0.65))
