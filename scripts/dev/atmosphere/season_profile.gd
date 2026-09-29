class_name AtmosphereSeasonProfile
extends Resource

@export var profile_id: StringName
@export_range(-0.4, 0.4) var daylight_duration_bias := 0.0
@export_range(0.5, 1.5) var sun_warmth := 1.0
@export_range(0.5, 1.5) var sun_elevation_bias := 1.0
@export_range(0.5, 1.5) var ambient_saturation := 1.0
@export_range(0.0, 1.0) var foliage_amount := 0.5
@export_range(0.0, 0.5) var extra_haze := 0.0
@export_range(0.5, 1.5) var window_multiplier := 1.0
@export var exterior_palette := Color.WHITE
@export var atmosphere_fx: StringName = &"none"
