class_name WindowLightingController
extends Node2D
## Exterior light/FX hook bound to an authored window; no gameplay anchor changes.

var current_exterior := Color.WHITE
var current_rain := 0.0
var current_haze := 0.0
var current_window_profile: StringName = &""
var current_exterior_family: StringName = &""
var current_foliage := 0.0
@onready var point_light: PointLight2D = $PointLight2D


func _ready() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 0.65))
	gradient.set_color(1, Color(1, 1, 1, 0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 256
	texture.height = 256
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1, 0.5)
	point_light.texture = texture
	point_light.texture_scale = 1.65
	point_light.shadow_enabled = false


func apply_atmosphere(out: AtmosphereOutput) -> void:
	current_exterior = out.exterior_color
	current_rain = out.rain_amount
	current_haze = out.haze
	current_window_profile = out.window_profile
	current_exterior_family = out.exterior_family
	current_foliage = out.foliage_amount
	point_light.color = out.window_color
	point_light.energy = out.window_energy * 0.48
	point_light.enabled = out.window_energy > 0.02
	queue_redraw()


func _draw() -> void:
	# The existing greybox opening remains authoritative; this is an interior-facing overlay.
	draw_rect(Rect2(-19, -82, 38, 164), Color(current_exterior.r,
		current_exterior.g, current_exterior.b, 0.34), true)
	if current_haze > 0.05:
		draw_rect(Rect2(-19, -82, 38, 164), Color(0.91, 0.93, 0.92,
			current_haze * 0.22), true)
	# Deliberately crude exterior foliage hook; a small authored window variant
	# can replace this without replacing the room or moving WindowPerch.
	if current_foliage > 0.01:
		for i in 3:
			draw_circle(Vector2(-11 + i * 11, 57 - (i % 2) * 12),
				4.0 + current_foliage * 5.0,
				Color(0.29, 0.48, 0.39, current_foliage * 0.32))
	if current_rain > 0.0:
		for i in 6:
			var x := -15.0 + float(i) * 6.0
			draw_line(Vector2(x, -68 + (i % 2) * 17),
				Vector2(x - 5, -43 + (i % 2) * 17),
				Color(0.78, 0.88, 0.98, current_rain * 0.82), 1.3)
