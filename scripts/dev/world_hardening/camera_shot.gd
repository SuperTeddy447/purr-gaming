class_name HardeningCameraShot
extends Resource
## Reusable data, while each physical focus Marker2D belongs to its object.

@export var shot_id: StringName = &"focus"
@export_range(1.0, 3.0) var zoom := 2.25
@export_range(0.0, 4.0) var transition_in := 0.3
@export_range(-1.0, 6.0) var hold_duration := 0.6 # -1 holds until replacement/cancel.
@export_range(0.0, 4.0) var transition_out := 0.35
@export var transition_type := Tween.TRANS_SINE
@export var ease_type := Tween.EASE_IN_OUT
@export var follow_target := true
@export var lock_input := true
@export var hide_hud := false
@export_range(0, 100) var priority := 10
