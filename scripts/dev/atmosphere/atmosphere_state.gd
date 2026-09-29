class_name AtmosphereState
extends Resource

@export var location_id: StringName = &"japan_reference"
@export var season_id: StringName = &"spring"
@export var time_id: StringName = &"morning"
@export var weather_id: StringName = &"clear"
@export var event_id: StringName = &""


func duplicate_state() -> AtmosphereState:
	var next := AtmosphereState.new()
	next.location_id = location_id
	next.season_id = season_id
	next.time_id = time_id
	next.weather_id = weather_id
	next.event_id = event_id
	return next
