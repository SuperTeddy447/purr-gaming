class_name AtmosphereOutput
extends RefCounted
## Evaluated rendering values. Never serialize this; persist profile IDs instead.

var ambient := Color.WHITE
var sun_color := Color.WHITE
var sun_energy := 0.0
var sun_angle := 0.0
var lamp_energy := 0.0
var window_color := Color.WHITE
var window_energy := 0.0
var exterior_color := Color.WHITE
var rain_amount := 0.0
var haze := 0.0
var wetness := 0.0
var shadow_softness := 0.0
var foliage_amount := 0.0
var exterior_family: StringName = &""
var window_profile: StringName = &""
var weather_fx: StringName = &"none"
var atmosphere_fx: StringName = &"none"
var event_fx: StringName = &"none"


func blended(other: AtmosphereOutput, weight: float) -> AtmosphereOutput:
	var t := clampf(weight, 0.0, 1.0)
	var result := AtmosphereOutput.new()
	result.ambient = ambient.lerp(other.ambient, t)
	result.sun_color = sun_color.lerp(other.sun_color, t)
	result.sun_energy = lerpf(sun_energy, other.sun_energy, t)
	result.sun_angle = lerp_angle(sun_angle, other.sun_angle, t)
	result.lamp_energy = lerpf(lamp_energy, other.lamp_energy, t)
	result.window_color = window_color.lerp(other.window_color, t)
	result.window_energy = lerpf(window_energy, other.window_energy, t)
	result.exterior_color = exterior_color.lerp(other.exterior_color, t)
	result.rain_amount = lerpf(rain_amount, other.rain_amount, t)
	result.haze = lerpf(haze, other.haze, t)
	result.wetness = lerpf(wetness, other.wetness, t)
	result.shadow_softness = lerpf(shadow_softness, other.shadow_softness, t)
	result.foliage_amount = lerpf(foliage_amount, other.foliage_amount, t)
	result.exterior_family = other.exterior_family if t >= 0.5 else exterior_family
	result.window_profile = other.window_profile if t >= 0.5 else window_profile
	result.weather_fx = other.weather_fx if t >= 0.5 else weather_fx
	result.atmosphere_fx = other.atmosphere_fx if t >= 0.5 else atmosphere_fx
	result.event_fx = other.event_fx if t >= 0.5 else event_fx
	return result
