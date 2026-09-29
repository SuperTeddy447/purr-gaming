class_name WorldAtmosphereDirector
extends Node
## Scene-agnostic atmosphere resolver. A room binds its own render nodes in the editor.

signal atmosphere_changed(state: AtmosphereState)
signal transition_finished(state: AtmosphereState)

@export var catalog: AtmosphereCatalog
@export var initial_state: AtmosphereState
@export var canvas_modulate_path: NodePath
@export var sun_path: NodePath
@export var lamp_path: NodePath
@export var window_path: NodePath

var state: AtmosphereState
var output: AtmosphereOutput
var _transition: Tween


func _ready() -> void:
	state = initial_state.duplicate_state() if initial_state else AtmosphereState.new()
	apply_state(state)


func _exit_tree() -> void:
	if _transition and _transition.is_running():
		_transition.kill()


func apply_state(next: AtmosphereState) -> bool:
	var resolved := AtmosphereEvaluator.evaluate(catalog, next)
	if resolved == null:
		return false
	if _transition and _transition.is_running():
		_transition.kill()
	state = next.duplicate_state()
	output = resolved
	_apply_render(output)
	atmosphere_changed.emit(state)
	return true


func set_location(id: StringName) -> bool:
	var next := state.duplicate_state()
	next.location_id = id
	return apply_state(next)


func set_season(id: StringName) -> bool:
	var next := state.duplicate_state()
	next.season_id = id
	return apply_state(next)


func set_time_of_day(id: StringName) -> bool:
	var next := state.duplicate_state()
	next.time_id = id
	return apply_state(next)


func set_weather(id: StringName) -> bool:
	var next := state.duplicate_state()
	next.weather_id = id
	return apply_state(next)


func set_event_lighting(id: StringName) -> bool:
	var next := state.duplicate_state()
	next.event_id = id
	return apply_state(next)


func clear_event_lighting() -> bool:
	return set_event_lighting(&"")


func transition_to_atmosphere(next: AtmosphereState, duration: float) -> bool:
	var target := AtmosphereEvaluator.evaluate(catalog, next)
	if target == null:
		return false
	if duration <= 0.0:
		return apply_state(next)
	if _transition and _transition.is_running():
		_transition.kill()
	var start := output
	var destination := next.duplicate_state()
	_transition = create_tween()
	_transition.tween_method(func(t: float) -> void:
		output = start.blended(target, t)
		_apply_render(output), 0.0, 1.0, duration)
	_transition.finished.connect(func() -> void:
		state = destination
		output = target
		_apply_render(output)
		atmosphere_changed.emit(state)
		transition_finished.emit(state))
	return true


func set_neutral_base() -> void:
	# Capture-only diagnostic: no changes to authored art or profile resources.
	var neutral := AtmosphereOutput.new()
	neutral.ambient = Color.WHITE
	neutral.sun_energy = 0.0
	neutral.window_energy = 0.0
	neutral.lamp_energy = 0.0
	neutral.exterior_color = Color(0.87, 0.87, 0.83)
	output = neutral
	_apply_render(output)


func _apply_render(value: AtmosphereOutput) -> void:
	var ambient := get_node_or_null(canvas_modulate_path) as CanvasModulate
	var sun := get_node_or_null(sun_path) as DirectionalLight2D
	var lamp := get_node_or_null(lamp_path) as AtmosphereLamp
	var window := get_node_or_null(window_path) as WindowLightingController
	if ambient:
		ambient.color = value.ambient
	if sun:
		sun.color = value.sun_color
		# DirectionalLight2D adds uniformly to flat sprites; keep this a restrained
		# daylight cue until normal/material tests justify a stronger response.
		sun.energy = value.sun_energy * 0.18
		sun.rotation = value.sun_angle
		sun.shadow_enabled = false
	if lamp:
		lamp.set_auto_energy(value.lamp_energy)
	if window:
		window.apply_atmosphere(value)
