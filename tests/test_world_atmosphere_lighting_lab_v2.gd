extends SceneTree
## Lab-only architectural contract; production Home remains untouched.

const SCENE := preload("res://scenes/dev/world_atmosphere_lighting_lab_v2.tscn")
var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := SCENE.instantiate()
	root.add_child(world)
	await physics_frame
	await physics_frame
	var director := world.get_node("AtmosphereDirector") as WorldAtmosphereDirector
	var lamp := world.get_node("Architecture/AtmosphereLamp") as AtmosphereLamp
	var window := world.get_node("Architecture/WindowLighting") as WindowLightingController
	var hud := world.get_node("HUD") as CanvasLayer
	var tint := world.get_node("WorldTint") as CanvasModulate
	_check(director.catalog.locations.size() == 4, "Four location profiles missing")
	_check(director.catalog.seasons.size() == 5 and director.catalog.times.size() == 7,
		"Season/time profile family incomplete")
	_check(hud.layer > 0 and hud.get_parent() == world and tint.get_parent() == world,
		"HUD is not isolated in an upper CanvasLayer")
	_check(window.current_window_profile == &"street_garden", "Window did not initialize")
	var same_japan := AtmosphereState.new()
	same_japan.season_id = &"summer"
	same_japan.time_id = &"afternoon"
	var same_thailand := same_japan.duplicate_state()
	same_thailand.location_id = &"thailand_reference"
	var japan_output := AtmosphereEvaluator.evaluate(director.catalog, same_japan)
	var thailand_output := AtmosphereEvaluator.evaluate(director.catalog, same_thailand)
	_check(japan_output != null and thailand_output != null
		and not japan_output.ambient.is_equal_approx(thailand_output.ambient)
		and japan_output.exterior_family != thailand_output.exterior_family,
		"Location profiles do not differ under the same season/time/weather")
	var initial_color := tint.color
	_check(director.set_time_of_day(&"night"), "Night switch rejected")
	_check(not tint.color.is_equal_approx(initial_color), "Day/night had no rendered change")
	_check(lamp.effective_energy > 0.5, "Night lamp policy did not turn on")
	lamp.set_manual_override(AtmosphereLamp.Override.FORCE_OFF)
	_check(lamp.effective_energy == 0.0, "Manual lamp OFF failed")
	lamp.set_manual_override(AtmosphereLamp.Override.DIMMED)
	_check(is_equal_approx(lamp.effective_energy, 0.35), "Manual DIMMED failed")
	lamp.set_manual_override(AtmosphereLamp.Override.AUTO)
	_check(lamp.effective_energy > 0.5, "Lamp AUTO did not restore")
	_check(director.set_weather(&"rain"), "Rain switch rejected")
	_check(window.current_rain > 0.0, "Window rain profile not updated")
	var base := tint.color
	_check(director.set_event_lighting(&"lantern_night"), "Event modifier rejected")
	_check(not tint.color.is_equal_approx(base), "Event modifier did not compose")
	_check(director.clear_event_lighting(), "Event modifier did not clear")
	_check(tint.color.is_equal_approx(base), "Removing event did not restore underlying state")
	var thai := AtmosphereState.new()
	thai.location_id = &"thailand_reference"
	thai.season_id = &"rainy_season"
	thai.time_id = &"afternoon"
	thai.weather_id = &"rain"
	_check(director.transition_to_atmosphere(thai, 0.08), "Transition request failed")
	await create_timer(0.2).timeout
	_check(director.state.location_id == &"thailand_reference",
		"Transition did not complete")
	_check(window.current_window_profile == &"courtyard", "Window profile did not follow location")
	_check(window.current_exterior_family == &"tropical_garden"
		and window.current_foliage > 0.0, "Seasonal exterior hook did not follow profiles")
	_check(not director.set_season(&"winter"), "Unsupported season should be rejected")
	_check(director.state.season_id == &"rainy_season", "Rejected switch corrupted state")
	var chair := world.find_object(&"chair_a") as Node2D
	var shadow := chair.get_node("ChairContactShadow") as Node2D
	var old_shadow := shadow.global_position
	chair.position += Vector2(7, 4)
	_check(shadow.global_position.is_equal_approx(old_shadow + Vector2(7, 4)),
		"Movable furniture left its shadow behind")
	_check(not (world.get_node("SunLight") as DirectionalLight2D).shadow_enabled,
		"Unbounded directional shadows enabled")
	# The director is identical across locations and contains no map-specific pixel coordinates.
	_check(director.get_script().source_code.find("Vector2(") == -1,
		"Director contains map-specific pixel positions")
	var pending := AtmosphereState.new()
	_check(director.transition_to_atmosphere(pending, 5.0),
		"Long transition for scene-cleanup test rejected")
	var tween := director._transition
	world.queue_free()
	await process_frame
	_check(not is_instance_valid(world), "Lab scene did not clean up")
	_check(not tween.is_running(), "Scene change left an atmosphere transition running")
	if _ok:
		print("--- WORLD ATMOSPHERE LIGHTING LAB V2 PASSED ---")
	quit(0 if _ok else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
