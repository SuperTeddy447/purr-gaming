class_name AtmosphereWeatherProfile
extends Resource

@export var profile_id: StringName
@export_range(0.0, 1.2) var direct_multiplier := 1.0
@export_range(0.5, 1.3) var diffuse_multiplier := 1.0
@export var diffuse_color := Color.WHITE
@export_range(0.0, 1.0) var cloud_cover := 0.0
@export_range(0.0, 1.0) var rain_amount := 0.0
@export_range(0.0, 1.0) var wetness := 0.0
@export_range(0.0, 1.0) var extra_haze := 0.0
@export_range(0.0, 1.0) var shadow_softness := 0.2
@export var weather_fx: StringName = &"none"
