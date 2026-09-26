class_name MochiLayeredIdleVisual
extends Node2D
## Procedural, presentation-only idle layers. Never moves the gameplay root.

signal eye_state_changed(state: StringName)
signal procedural_event(event_id: StringName)

const DEFAULT_CONFIG: MochiLayeredIdleConfig = preload("res://data/mochi_layered_idle_config.tres")
const EYE_OPEN: StringName = &"OPEN"
const EYE_HALF: StringName = &"HALF"
const EYE_CLOSED: StringName = &"CLOSED"

@export var config: MochiLayeredIdleConfig = DEFAULT_CONFIG
@export var canonical_reference_texture: Texture2D
@export var body_motion: Node2D
@export var body_base: Sprite2D
@export var tail_pivot: Node2D
@export var tail_sprite: Sprite2D
@export var ear_pivot: Node2D
@export var ear_sprite: Sprite2D
@export var face_layers: Node2D
@export var eyes_open: Sprite2D
@export var eyes_half: Sprite2D
@export var eyes_closed: Sprite2D

var current_action: StringName = &""
var current_eye_state: StringName = EYE_OPEN
var is_idle_active: bool = false
var is_paused: bool = false
var production_layers_complete: bool = false
var presentation_status: String = "TEMP / FALLBACK"

var _rng := RandomNumberGenerator.new()
var _character_scale: float = 1.0
var _breathing_clock: float = 0.0
var _breathing_phase: float = 0.0
var _activity_multiplier: float = 1.0
var _blink_wait: float = 0.0
var _blink_remaining: float = 0.0
var _blink_step: int = -1
var _tail_wait: float = 0.0
var _ear_wait: float = 0.0
var _tail_neutral_rotation: float = 0.0
var _ear_neutral_rotation: float = 0.0
var _tail_tween: Tween
var _ear_tween: Tween
var _initial_timing_snapshot: Dictionary = {}


func _ready() -> void:
	if config == null:
		config = DEFAULT_CONFIG
	if body_base == null or body_motion == null:
		push_error("Mochi layered idle visual requires BodyMotion and BodyBase.")
		return
	if canonical_reference_texture == null:
		canonical_reference_texture = body_base.texture
	_tail_neutral_rotation = tail_pivot.rotation if tail_pivot != null else 0.0
	_ear_neutral_rotation = ear_pivot.rotation if ear_pivot != null else 0.0
	_rng.seed = config.rng_seed
	_apply_config_art()
	_apply_registration()
	set_process(false)


func install_config(next_config: MochiLayeredIdleConfig) -> void:
	if next_config == null:
		return
	var resume_action: StringName = current_action
	var was_active: bool = is_idle_active
	stop_idle()
	config = next_config
	_rng.seed = config.rng_seed
	_apply_config_art()
	_apply_registration()
	if was_active:
		start_idle(resume_action, true)


func set_character_scale(next_scale: float) -> void:
	_character_scale = maxf(absf(next_scale), 0.0001)
	if body_base != null:
		body_base.scale = Vector2.ONE * _character_scale
	if tail_pivot != null:
		tail_pivot.scale = Vector2.ONE * _character_scale
	if ear_pivot != null:
		ear_pivot.scale = Vector2.ONE * _character_scale
	if face_layers != null:
		face_layers.scale = Vector2.ONE * _character_scale


func start_idle(action_id: StringName, force_restart: bool = false) -> void:
	if action_id not in [&"idle", &"ambient_idle"]:
		show_static_fallback()
		return
	if is_idle_active and current_action == action_id and not force_restart:
		return
	_reset_procedural_state()
	current_action = action_id
	is_idle_active = true
	is_paused = false
	visible = true
	body_base.visible = true
	if tail_pivot != null:
		tail_pivot.visible = production_layers_complete
	if ear_pivot != null:
		ear_pivot.visible = production_layers_complete
	if face_layers != null:
		face_layers.visible = production_layers_complete
	_activity_multiplier = config.ambient_activity_multiplier if action_id == &"ambient_idle" else 1.0
	_breathing_phase = _rng.randf_range(0.0, TAU)
	_blink_wait = _next_interval(config.blink_interval_min, config.blink_interval_max)
	_tail_wait = _next_interval(config.tail_interval_min, config.tail_interval_max)
	_ear_wait = _next_interval(config.ear_interval_min, config.ear_interval_max)
	_initial_timing_snapshot = {
		"blink": _blink_wait, "tail": _tail_wait, "ear": _ear_wait,
		"breathing_phase": _breathing_phase
	}
	set_process(true)


func stop_idle() -> void:
	_reset_procedural_state()
	current_action = &""
	is_idle_active = false
	is_paused = false
	set_process(false)


func show_static_fallback() -> void:
	stop_idle()
	visible = true
	if body_base != null:
		body_base.visible = true
	if tail_pivot != null:
		tail_pivot.visible = false
	if ear_pivot != null:
		ear_pivot.visible = false
	if face_layers != null:
		face_layers.visible = false


func set_paused(paused: bool) -> void:
	is_paused = paused
	_pause_or_resume_tween(_tail_tween, paused)
	_pause_or_resume_tween(_ear_tween, paused)


func restart() -> void:
	if current_action in [&"idle", &"ambient_idle"]:
		_rng.seed = config.rng_seed
		start_idle(current_action, true)


func timing_snapshot() -> Dictionary:
	return _initial_timing_snapshot.duplicate(true)


func status_line() -> String:
	var eye_status: String = String(current_eye_state)
	var activity: String = String(current_action) if current_action != &"" else "inactive"
	return "%s | eyes %s | %s" % [activity, eye_status, presentation_status]


func debug_tail_pivot_global() -> Vector2:
	return tail_pivot.global_position if tail_pivot != null else global_position


func debug_ear_pivot_global() -> Vector2:
	return ear_pivot.global_position if ear_pivot != null else global_position


func _process(delta: float) -> void:
	if not is_idle_active or is_paused:
		return
	_breathing_clock += delta
	var period: float = maxf(config.breathing_period, 0.01)
	var breath: float = sin(TAU * _breathing_clock / period + _breathing_phase) * config.breathing_amount
	if body_motion != null:
		body_motion.scale = Vector2(1.0, 1.0 + breath)
	_advance_blink(delta)
	_advance_tail(delta)
	_advance_ear(delta)


func _advance_blink(delta: float) -> void:
	if not _can_blink():
		return
	if _blink_step >= 0:
		_blink_remaining -= delta
		while _blink_remaining <= 0.0 and _blink_step >= 0:
			_blink_step += 1
			if _blink_step >= 4:
				_blink_step = -1
				_apply_eye_state(EYE_OPEN)
				_blink_wait = _next_interval(config.blink_interval_min, config.blink_interval_max)
				break
			match _blink_step:
				1:
					_apply_eye_state(EYE_CLOSED)
					_blink_remaining += config.blink_closed_duration
				2:
					_apply_eye_state(EYE_HALF)
					_blink_remaining += config.blink_half_duration
				3:
					_apply_eye_state(EYE_OPEN)
					_blink_remaining += config.blink_half_duration
	else:
		_blink_wait -= delta
		if _blink_wait <= 0.0:
			_blink_step = 0
			_apply_eye_state(EYE_HALF)
			_blink_remaining = config.blink_half_duration
			procedural_event.emit(&"blink_started")


func _advance_tail(delta: float) -> void:
	if not _can_move_tail() or (_tail_tween != null and _tail_tween.is_running()):
		return
	_tail_wait -= delta
	if _tail_wait <= 0.0:
		_start_tail_motion()


func _advance_ear(delta: float) -> void:
	if not _can_move_ear() or (_ear_tween != null and _ear_tween.is_running()):
		return
	_ear_wait -= delta
	if _ear_wait <= 0.0:
		_start_ear_motion()


func _start_tail_motion() -> void:
	if tail_pivot == null:
		return
	var angle: float = deg_to_rad(_rng.randf_range(config.tail_angle_min_degrees, config.tail_angle_max_degrees))
	_tail_tween = create_tween()
	_tail_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tail_tween.tween_property(tail_pivot, "rotation", _tail_neutral_rotation + angle, config.tail_motion_duration)
	_tail_tween.tween_property(tail_pivot, "rotation", _tail_neutral_rotation, config.tail_return_duration)
	_tail_tween.finished.connect(_on_tail_motion_finished)
	procedural_event.emit(&"tail_motion_started")


func _start_ear_motion() -> void:
	if ear_pivot == null:
		return
	_ear_tween = create_tween()
	_ear_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_ear_tween.tween_property(ear_pivot, "rotation", _ear_neutral_rotation + deg_to_rad(config.ear_angle_degrees), config.ear_twitch_duration)
	_ear_tween.tween_property(ear_pivot, "rotation", _ear_neutral_rotation, config.ear_return_duration)
	_ear_tween.finished.connect(_on_ear_motion_finished)
	procedural_event.emit(&"ear_twitch_started")


func _on_tail_motion_finished() -> void:
	if tail_pivot != null:
		tail_pivot.rotation = _tail_neutral_rotation
	_tail_tween = null
	_tail_wait = _next_interval(config.tail_interval_min, config.tail_interval_max)


func _on_ear_motion_finished() -> void:
	if ear_pivot != null:
		ear_pivot.rotation = _ear_neutral_rotation
	_ear_tween = null
	_ear_wait = _next_interval(config.ear_interval_min, config.ear_interval_max)


func _apply_eye_state(state: StringName) -> void:
	current_eye_state = state
	if eyes_open != null:
		eyes_open.visible = state == EYE_OPEN and eyes_open.texture != null
	if eyes_half != null:
		eyes_half.visible = state == EYE_HALF and eyes_half.texture != null
	if eyes_closed != null:
		eyes_closed.visible = state == EYE_CLOSED and eyes_closed.texture != null
	eye_state_changed.emit(state)


func _apply_config_art() -> void:
	if config == null or body_base == null:
		return
	var complete: bool = config.body_base_texture != null and config.tail_texture != null \
		and config.ear_twitch_texture != null and config.eyes_open_texture != null \
		and config.eyes_half_texture != null and config.eyes_closed_texture != null
	production_layers_complete = complete
	if complete:
		body_base.texture = config.body_base_texture
		presentation_status = "FINAL LAYERED ART"
	else:
		body_base.texture = canonical_reference_texture
		var missing: PackedStringArray = PackedStringArray()
		if config.body_base_texture == null: missing.append("BodyBase")
		if config.tail_texture == null: missing.append("Tail")
		if config.ear_twitch_texture == null: missing.append("EarTwitch")
		if config.eyes_open_texture == null or config.eyes_half_texture == null or config.eyes_closed_texture == null:
			missing.append("EyeStates")
		presentation_status = "TEMP / FALLBACK — missing %s" % ", ".join(missing)
	if tail_sprite != null:
		tail_sprite.texture = config.tail_texture if complete else null
	if ear_sprite != null:
		ear_sprite.texture = config.ear_twitch_texture if complete else null
	if eyes_open != null:
		eyes_open.texture = config.eyes_open_texture if complete else null
	if eyes_half != null:
		eyes_half.texture = config.eyes_half_texture if complete else null
	if eyes_closed != null:
		eyes_closed.texture = config.eyes_closed_texture if complete else null
	_apply_eye_state(EYE_OPEN)


func _apply_registration() -> void:
	if config == null:
		return
	if body_base != null:
		body_base.centered = false
		if production_layers_complete:
			body_base.offset = config.body_base_offset
		elif canonical_reference_texture != null:
			var bounds: Rect2i = canonical_reference_texture.get_image().get_used_rect()
			body_base.offset = Vector2(-canonical_reference_texture.get_width() * 0.5, -float(bounds.end.y))
	if tail_pivot != null:
		tail_pivot.position = config.tail_pivot_position
		tail_pivot.z_index = -1
	if tail_sprite != null:
		tail_sprite.centered = false
		tail_sprite.offset = config.tail_sprite_offset
	if ear_pivot != null:
		ear_pivot.position = config.ear_pivot_position
		ear_pivot.z_index = 1
	if ear_sprite != null:
		ear_sprite.centered = false
		ear_sprite.offset = config.ear_sprite_offset
	for eyes in [eyes_open, eyes_half, eyes_closed]:
		if eyes != null:
			eyes.centered = false
			eyes.position = config.eyes_patch_position
			eyes.offset = config.eyes_sprite_offset
	set_character_scale(_character_scale)


func _reset_procedural_state() -> void:
	if _tail_tween != null and _tail_tween.is_running():
		_tail_tween.kill()
	if _ear_tween != null and _ear_tween.is_running():
		_ear_tween.kill()
	_tail_tween = null
	_ear_tween = null
	if tail_pivot != null:
		tail_pivot.position = config.tail_pivot_position
		tail_pivot.rotation = _tail_neutral_rotation
		tail_pivot.scale = Vector2.ONE * _character_scale
	if ear_pivot != null:
		ear_pivot.position = config.ear_pivot_position
		ear_pivot.rotation = _ear_neutral_rotation
		ear_pivot.scale = Vector2.ONE * _character_scale
	if body_motion != null:
		body_motion.scale = Vector2.ONE
	_breathing_clock = 0.0
	_blink_wait = 0.0
	_blink_remaining = 0.0
	_blink_step = -1
	_tail_wait = 0.0
	_ear_wait = 0.0
	_apply_eye_state(EYE_OPEN)


func _can_blink() -> bool:
	return production_layers_complete and eyes_open != null and eyes_half != null and eyes_closed != null


func _can_move_tail() -> bool:
	return production_layers_complete and tail_pivot != null and tail_sprite != null and tail_sprite.texture != null


func _can_move_ear() -> bool:
	return production_layers_complete and ear_pivot != null and ear_sprite != null and ear_sprite.texture != null


func _next_interval(minimum: float, maximum: float) -> float:
	var low: float = maxf(minf(minimum, maximum), 0.01)
	var high: float = maxf(maxf(minimum, maximum), low)
	return _rng.randf_range(low, high) / maxf(_activity_multiplier, 1.0)


func _pause_or_resume_tween(tween: Tween, pause: bool) -> void:
	if tween == null or not tween.is_running():
		return
	if pause:
		tween.pause()
	else:
		tween.play()
