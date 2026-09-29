class_name AtmosphereTimeProfile
extends Resource

@export var profile_id: StringName
@export var ambient_color := Color.WHITE
@export_range(0.3, 1.2) var ambient_energy := 1.0
@export var direct_color := Color.WHITE
@export_range(0.0, 1.5) var direct_energy := 0.5
@export_range(-180.0, 180.0) var sun_angle_degrees := -35.0
@export_range(0.0, 1.5) var window_energy := 0.5
@export_range(0.0, 1.5) var exterior_brightness := 0.9
@export_range(0.0, 1.0) var lamp_demand := 0.0
@export_range(0.0, 1.0) var shadow_strength := 0.5
