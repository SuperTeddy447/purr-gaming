class_name AtmosphereCatalog
extends Resource
## Native Godot-authored profile data; no country branches in actors or room code.

@export var locations: Array[AtmosphereLocationProfile] = []
@export var seasons: Array[AtmosphereSeasonProfile] = []
@export var times: Array[AtmosphereTimeProfile] = []
@export var weathers: Array[AtmosphereWeatherProfile] = []
@export var events: Array[AtmosphereEventLightingModifier] = []


func find_location(id: StringName) -> AtmosphereLocationProfile:
	for profile in locations:
		if profile.profile_id == id:
			return profile
	return null


func find_season(id: StringName) -> AtmosphereSeasonProfile:
	for profile in seasons:
		if profile.profile_id == id:
			return profile
	return null


func find_time(id: StringName) -> AtmosphereTimeProfile:
	for profile in times:
		if profile.profile_id == id:
			return profile
	return null


func find_weather(id: StringName) -> AtmosphereWeatherProfile:
	for profile in weathers:
		if profile.profile_id == id:
			return profile
	return null


func find_event(id: StringName) -> AtmosphereEventLightingModifier:
	for profile in events:
		if profile.profile_id == id:
			return profile
	return null


func accepts(location_id: StringName, season_id: StringName) -> bool:
	var location := find_location(location_id)
	return location != null and (location.allowed_seasons.is_empty()
		or String(season_id) in location.allowed_seasons)
