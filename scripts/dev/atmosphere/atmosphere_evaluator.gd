class_name AtmosphereEvaluator
extends RefCounted
## Pure profile composition. No room coordinates, actor logic, or geographical branches.


static func evaluate(catalog: AtmosphereCatalog, state: AtmosphereState) -> AtmosphereOutput:
	if catalog == null or state == null or not catalog.accepts(state.location_id, state.season_id):
		return null
	var location := catalog.find_location(state.location_id)
	var season := catalog.find_season(state.season_id)
	var daytime := catalog.find_time(state.time_id)
	var weather := catalog.find_weather(state.weather_id)
	if season == null or daytime == null or weather == null:
		return null
	var event: AtmosphereEventLightingModifier
	if state.event_id != &"":
		event = catalog.find_event(state.event_id)
		if event == null:
			return null
	var out := AtmosphereOutput.new()
	var haze_total: float = clampf(location.haze + season.extra_haze + weather.extra_haze
		+ location.humidity * 0.04, 0.0, 1.0)
	var sky_mix: Color = daytime.ambient_color * location.sky_bias
	sky_mix = sky_mix.lerp(weather.diffuse_color, weather.cloud_cover * 0.28)
	var grey: float = (sky_mix.r + sky_mix.g + sky_mix.b) / 3.0
	sky_mix = Color(grey, grey, grey).lerp(sky_mix, season.ambient_saturation)
	var ambient_strength: float = clampf(daytime.ambient_energy * weather.diffuse_multiplier
		* (1.0 - haze_total * 0.08), 0.44, 1.08)
	out.ambient = Color(
		clampf(sky_mix.r * ambient_strength, 0.38, 1.0),
		clampf(sky_mix.g * ambient_strength, 0.38, 1.0),
		clampf(sky_mix.b * ambient_strength, 0.42, 1.0), 1.0)
	var daylight_bias: float = 1.0 + season.daylight_duration_bias * 0.25
	var direct_factor: float = (weather.direct_multiplier * location.daylight_contrast
		* (1.0 - haze_total * 0.22) * daylight_bias)
	out.sun_energy = clampf(daytime.direct_energy * direct_factor, 0.0, 1.3)
	out.sun_angle = deg_to_rad(daytime.sun_angle_degrees * season.sun_elevation_bias)
	out.sun_color = daytime.direct_color.lerp(Color(1.0, 0.76, 0.55),
		clampf((season.sun_warmth - 1.0) * 0.6, 0.0, 0.35))
	out.lamp_energy = clampf(daytime.lamp_demand * (0.55 + location.indoor_balance * 0.55)
		+ weather.cloud_cover * 0.18 + (event.lamp_bonus if event else 0.0), 0.0, 1.0)
	out.window_energy = clampf(daytime.window_energy * season.window_multiplier * daylight_bias
		* (0.65 + weather.direct_multiplier * 0.35), 0.0, 1.4)
	out.window_color = daytime.direct_color.lerp(weather.diffuse_color, weather.cloud_cover * 0.75)
	var exterior_base: Color = daytime.ambient_color * location.sky_bias * season.exterior_palette
	out.exterior_color = exterior_base.lerp(weather.diffuse_color,
		weather.cloud_cover * 0.38) * daytime.exterior_brightness
	out.rain_amount = weather.rain_amount
	out.wetness = weather.wetness
	out.haze = haze_total
	out.shadow_softness = weather.shadow_softness
	out.foliage_amount = season.foliage_amount
	out.exterior_family = location.exterior_family
	out.window_profile = location.default_window_profile
	out.weather_fx = weather.weather_fx
	out.atmosphere_fx = season.atmosphere_fx
	if event:
		out.ambient = out.ambient.lerp(out.ambient * event.ambient_tint, event.ambient_weight)
		out.window_color = out.window_color.lerp(out.window_color * event.window_tint,
			event.window_weight)
		out.event_fx = event.local_fx
	return out
