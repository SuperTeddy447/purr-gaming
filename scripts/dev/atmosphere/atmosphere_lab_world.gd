extends HomeV3Pass01World
## Input lives only in this inherited development scene.

@onready var atmosphere: WorldAtmosphereDirector = $AtmosphereDirector
@onready var atmosphere_debug: Label = $HUD/AtmosphereDebug


func _ready() -> void:
	super._ready()
	atmosphere.atmosphere_changed.connect(_update_atmosphere_debug)
	_update_atmosphere_debug(atmosphere.state)


func _process(_delta: float) -> void:
	atmosphere_debug.visible = get_node("DebugOverlay").visible
	$AtmosphereDebugOverlay.visible = atmosphere_debug.visible


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return super._unhandled_key_input(event)
	match event.keycode:
		KEY_4: _preset(&"japan_reference", &"spring", &"morning", &"clear")
		KEY_5: _preset(&"thailand_reference", &"rainy_season", &"afternoon", &"rain")
		KEY_6: _preset(&"europe_reference", &"autumn", &"evening", &"cloudy")
		KEY_7: _preset(&"china_reference", &"winter", &"night", &"clear")
		KEY_T:
			atmosphere.set_time_of_day(&"night" if atmosphere.state.time_id != &"night" else &"midday")
		KEY_Y:
			atmosphere.set_weather(&"rain" if atmosphere.state.weather_id != &"rain" else &"clear")
		KEY_L:
			var lamp := get_node("Architecture/AtmosphereLamp") as AtmosphereLamp
			lamp.set_manual_override(AtmosphereLamp.Override.FORCE_ON
				if lamp.manual_override != AtmosphereLamp.Override.FORCE_ON
				else AtmosphereLamp.Override.FORCE_OFF)
		KEY_G:
			if atmosphere.state.event_id == &"":
				atmosphere.set_event_lighting(&"lantern_night")
			else:
				atmosphere.clear_event_lighting()
		_:
			super._unhandled_key_input(event)
	_update_atmosphere_debug(atmosphere.state)


func _preset(location_id: StringName, season_id: StringName, time_id: StringName,
		weather_id: StringName) -> void:
	var next := AtmosphereState.new()
	next.location_id = location_id
	next.season_id = season_id
	next.time_id = time_id
	next.weather_id = weather_id
	atmosphere.transition_to_atmosphere(next, 0.8)


func _update_atmosphere_debug(current: AtmosphereState) -> void:
	if current == null or atmosphere_debug == null:
		return
	atmosphere_debug.text = "%s / %s / %s / %s\nRGB %.2f/%.2f/%.2f  SUN %.2f  LAMP %.2f  RAIN %.2f\nWINDOW %s  EVENT %s  OCCLUDERS 0" % [
		current.location_id, current.season_id, current.time_id, current.weather_id,
		atmosphere.output.ambient.r, atmosphere.output.ambient.g,
		atmosphere.output.ambient.b, atmosphere.output.sun_energy,
		atmosphere.output.lamp_energy, atmosphere.output.rain_amount,
		$Architecture/WindowLighting.current_window_profile, current.event_id]
