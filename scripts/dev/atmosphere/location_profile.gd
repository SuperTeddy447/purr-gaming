class_name AtmosphereLocationProfile
extends Resource
## An authored local environment tendency, never actor/gameplay behavior.

@export var profile_id: StringName
@export var latitude_band: StringName
@export_range(0.0, 1.0) var humidity := 0.5
@export_range(0.0, 1.0) var haze := 0.15
@export_range(0.0, 1.5) var daylight_contrast := 1.0
@export var sky_bias := Color.WHITE
@export_range(0.0, 1.0) var indoor_balance := 0.5
@export var allowed_seasons := PackedStringArray()
@export var exterior_family: StringName
@export var default_window_profile: StringName
