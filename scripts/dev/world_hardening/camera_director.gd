class_name HardeningCameraDirector
extends Node
## Temporary ownership of an existing gameplay Camera2D; never owns actor AI.

signal shot_started(shot_id: StringName)
signal shot_holding(shot_id: StringName)
signal shot_ended(shot_id: StringName, reason: StringName)

enum Mode { GAMEPLAY, FOCUS_SHOT, STORY, EVENT, DEBUG }

@export var camera: Camera2D
@export var camera_input: HardeningCameraInput
@export var hud: CanvasLayer

var mode := Mode.GAMEPLAY
var current_shot_id: StringName = &""
var current_priority := -1
var _saved_position := Vector2.ZERO
var _saved_zoom := Vector2.ONE
var _saved_offset := Vector2.ZERO
var _saved_hud_visible := true
var _saved_input_enabled := true
var _target: Marker2D
var _tween: Tween
var _serial := 0
var _holding := false
var _follow_target := false


func is_holding() -> bool:
	return _holding


func request_shot(target: Marker2D, config: HardeningCameraShot) -> bool:
	if target == null or not is_instance_valid(target) or not target.is_inside_tree() or config == null:
		return false
	if mode != Mode.GAMEPLAY and config.priority <= current_priority:
		return false
	if mode == Mode.GAMEPLAY:
		_saved_position = camera.global_position
		_saved_zoom = camera.zoom
		_saved_offset = camera.offset
		_saved_hud_visible = hud.visible if hud != null else true
		_saved_input_enabled = camera_input.input_enabled if camera_input != null else true
	else:
		_detach_target()
		if _tween != null and _tween.is_running():
			_tween.kill()
	_serial += 1
	var serial := _serial
	_target = target
	_target.tree_exiting.connect(_on_target_exiting.bind(target), CONNECT_ONE_SHOT)
	current_shot_id = config.shot_id
	current_priority = config.priority
	mode = Mode.FOCUS_SHOT
	_holding = false
	_follow_target = config.follow_target
	if camera_input != null and config.lock_input:
		camera_input.input_enabled = false
	if hud != null and config.hide_hud:
		hud.visible = false
	shot_started.emit(current_shot_id)
	_play_shot(serial, config)
	return true


func _play_shot(serial: int, config: HardeningCameraShot) -> void:
	_tween = create_tween().set_trans(config.transition_type).set_ease(config.ease_type)
	_tween.set_parallel(true)
	_tween.tween_property(camera, "global_position", _target.global_position, config.transition_in)
	_tween.tween_property(camera, "zoom", Vector2.ONE * config.zoom, config.transition_in)
	await _tween.finished
	if serial != _serial or mode == Mode.GAMEPLAY:
		return
	_holding = true
	shot_holding.emit(current_shot_id)
	if config.hold_duration < 0.0:
		return
	var elapsed := 0.0
	while elapsed < config.hold_duration:
		await get_tree().process_frame
		if serial != _serial or mode == Mode.GAMEPLAY:
			return
		elapsed += get_process_delta_time()
	_restore(config.transition_out, &"complete")


func _process(_delta: float) -> void:
	if _holding and _follow_target and _target != null and is_instance_valid(_target):
		camera.global_position = _target.global_position


func cancel(reason: StringName = &"cancel") -> void:
	if mode == Mode.GAMEPLAY:
		return
	_restore(0.0, reason)


func _restore(duration: float, reason: StringName) -> void:
	var completed_shot := current_shot_id
	_serial += 1
	var serial := _serial
	_holding = false
	_follow_target = false
	_detach_target()
	if _tween != null and _tween.is_running():
		_tween.kill()
	if duration <= 0.0:
		_finish_restore(serial, completed_shot, reason)
		return
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.set_parallel(true)
	_tween.tween_property(camera, "global_position", _saved_position, duration)
	_tween.tween_property(camera, "zoom", _saved_zoom, duration)
	_finish_after_tween(serial, completed_shot, reason)


func _finish_after_tween(serial: int, shot_id: StringName, reason: StringName) -> void:
	await _tween.finished
	if serial == _serial:
		_finish_restore(serial, shot_id, reason)


func _finish_restore(serial: int, shot_id: StringName, reason: StringName) -> void:
	if serial != _serial:
		return
	camera.global_position = _saved_position
	camera.zoom = _saved_zoom
	camera.offset = _saved_offset
	if hud != null:
		hud.visible = _saved_hud_visible
	if camera_input != null:
		camera_input.input_enabled = _saved_input_enabled
	mode = Mode.GAMEPLAY
	current_priority = -1
	current_shot_id = &""
	shot_ended.emit(shot_id, reason)


func _on_target_exiting(target: Marker2D) -> void:
	if _target == target:
		cancel(&"target_removed")


func _detach_target() -> void:
	if _target != null and is_instance_valid(_target):
		var callback := _on_target_exiting.bind(_target)
		if _target.tree_exiting.is_connected(callback):
			_target.tree_exiting.disconnect(callback)
	_target = null


func _exit_tree() -> void:
	if mode != Mode.GAMEPLAY:
		cancel(&"scene_exit")
