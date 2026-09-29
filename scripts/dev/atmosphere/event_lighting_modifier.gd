class_name AtmosphereEventLightingModifier
extends Resource

@export var profile_id: StringName
@export var ambient_tint := Color.WHITE
@export_range(0.0, 1.0) var ambient_weight := 0.0
@export_range(0.0, 1.0) var lamp_bonus := 0.0
@export var window_tint := Color.WHITE
@export_range(0.0, 1.0) var window_weight := 0.0
@export var local_fx: StringName = &"none"
