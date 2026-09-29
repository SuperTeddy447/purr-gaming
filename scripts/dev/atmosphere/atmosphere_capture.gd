extends Node
## Real viewport capture; deterministic state selection, never a second game simulation.

const OUTPUT := "res://artifacts/prototype_review/world_atmosphere_lighting_lab_v2/"
var running := false
var saved: Array[String] = []
@onready var world: Node2D = get_parent()
@onready var director: WorldAtmosphereDirector = world.get_node("AtmosphereDirector")


func _ready() -> void:
	if "--capture-atmosphere" in OS.get_cmdline_user_args():
		call_deferred("run_capture")


func run_capture() -> void:
	if running:
		return
	running = true
	_capture_sequence()


func _capture_sequence() -> void:
	saved.clear()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var debug := world.get_node("DebugOverlay") as CanvasItem
	var lamp := world.get_node("Architecture/AtmosphereLamp") as AtmosphereLamp
	debug.visible = false
	director.set_neutral_base()
	await _save("01_neutral_base.png")
	await _state("japan_reference", "spring", "morning", "clear", "02_japan_spring_morning_clear.png")
	await _state("thailand_reference", "rainy_season", "afternoon", "rain", "03_thailand_rainy_afternoon_rain.png")
	await _state("europe_reference", "autumn", "evening", "cloudy", "04_europe_autumn_evening_cloudy.png")
	await _state("china_reference", "winter", "night", "clear", "05_china_winter_night_clear.png")
	lamp.set_manual_override(AtmosphereLamp.Override.FORCE_OFF)
	await _save("06_lamp_off.png")
	lamp.set_manual_override(AtmosphereLamp.Override.FORCE_ON)
	await _save("07_lamp_on.png")
	lamp.set_manual_override(AtmosphereLamp.Override.AUTO)
	await _state("japan_reference", "spring", "midday", "clear", "08_day.png")
	await _state("japan_reference", "spring", "night", "clear", "09_night.png")
	await _state("japan_reference", "spring", "afternoon", "clear", "10_clear.png")
	await _state("japan_reference", "spring", "afternoon", "rain", "11_rain.png")
	debug.visible = true
	await _state("japan_reference", "spring", "morning", "clear", "12_debug_japan.png")
	await _state("thailand_reference", "rainy_season", "afternoon", "rain", "13_debug_rain.png")
	debug.visible = false
	await _state("japan_reference", "summer", "afternoon", "clear", "15_japan_summer_afternoon_clear.png")
	await _state("thailand_reference", "summer", "afternoon", "clear", "16_thailand_summer_afternoon_clear.png")
	print("ATMOSPHERE CAPTURE COMPLETE %d files=%s" % [saved.size(), str(saved)])
	running = false
	if "--capture-atmosphere" in OS.get_cmdline_user_args():
		get_tree().quit(0 if saved.size() == 15 else 1)


func _state(location: String, season: String, daytime: String, weather: String,
		filename: String) -> void:
	var state := AtmosphereState.new()
	state.location_id = StringName(location)
	state.season_id = StringName(season)
	state.time_id = StringName(daytime)
	state.weather_id = StringName(weather)
	if not director.apply_state(state):
		push_error("Capture rejected profile: %s" % filename)
		return
	await _save(filename)


func _save(filename: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png(OUTPUT + filename)
	if result == OK:
		saved.append(filename)
	else:
		push_error("Capture PNG failed: %s code=%d" % [filename, result])
