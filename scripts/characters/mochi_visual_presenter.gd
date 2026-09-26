class_name MochiVisualPresenter
extends Node2D
## Single visual endpoint for the True Slice's semantic Mochi actions.
## Never owns movement, timers, work completion, or reward state.

signal clip_resolved(action_id: StringName, source: StringName, clip: StringName)

@export var animation_set: MochiAnimationSet = preload("res://assets/characters/mochi/runtime/mochi_animation_set.tres")
@export var static_sprite: Sprite2D
@export var animated_sprite: AnimatedSprite2D
@export var layered_idle: MochiLayeredIdleVisual
@export var canonical_reference_texture: Texture2D
@export var carry_anchor: Marker2D
@export var contact_shadow: Node2D

var requested_action: StringName = &"idle"
var direction: StringName = &"DOWN"
var resolved_source: StringName = &"STATIC"
var resolved_clip: StringName = &""
var resolved_action: StringName = &"idle"
var used_fallback: bool = true
var is_paused: bool = false
var presentation_mode: StringName = &"LAYERED_IDLE"

var _actor: Node2D
var _mover: SliceMover
var _base_carry_x: float = 28.0
var _base_carry_y: float = -80.0
var _canonical_height_px: float = 150.0
var _geometry_cache: Dictionary = {}


func _ready() -> void:
	_actor = get_parent() as Node2D
	_mover = _actor.get_node_or_null("SliceMover") as SliceMover
	if animation_set == null or static_sprite == null or animated_sprite == null or layered_idle == null:
		push_error("Mochi visual presenter requires the semantic set, BodyBase fallback, layered idle and ActionAnimatedSprite.")
		return
	if canonical_reference_texture == null:
		canonical_reference_texture = static_sprite.texture
	if canonical_reference_texture != null:
		var reference_bounds: Rect2i = canonical_reference_texture.get_image().get_used_rect()
		_canonical_height_px = maxf(float(reference_bounds.size.y), 1.0)
	layered_idle.canonical_reference_texture = canonical_reference_texture
	layered_idle.set_character_scale(static_sprite.scale.x)
	if carry_anchor != null:
		_base_carry_x = absf(carry_anchor.position.x)
		_base_carry_y = carry_anchor.position.y
	animated_sprite.visible = false
	animated_sprite.centered = false
	if contact_shadow != null:
		contact_shadow.visible = true
	play_action(requested_action)


func _process(_delta: float) -> void:
	if _mover == null or not _mover.is_moving:
		return
	var travel: Vector2 = _mover.current_target - _actor.global_position
	if travel.length_squared() < 0.01:
		return
	if absf(travel.x) > absf(travel.y) * 1.1:
		set_direction(&"RIGHT" if travel.x > 0.0 else &"LEFT")
	else:
		set_direction(&"DOWN" if travel.y > 0.0 else &"UP")


func play_action(action_id: StringName) -> void:
	requested_action = action_id if animation_set.is_semantic_action(action_id) else &"idle"
	_apply_resolution(false)


func set_direction(next_direction: StringName) -> void:
	if next_direction not in [&"DOWN", &"UP", &"LEFT", &"RIGHT", &"SIDE"] or direction == next_direction:
		return
	direction = next_direction
	_apply_resolution(false)


func restart_action() -> void:
	if presentation_mode == &"LAYERED_IDLE":
		layered_idle.restart()
		return
	_apply_resolution(true)


func set_paused(paused: bool) -> void:
	is_paused = paused
	if presentation_mode == &"LAYERED_IDLE":
		layered_idle.set_paused(paused)
		return
	if not animated_sprite.visible:
		return
	if paused:
		animated_sprite.pause()
	else:
		animated_sprite.play()


func refresh_scale() -> void:
	if static_sprite != null:
		set_character_scale(static_sprite.scale.x)


func set_character_scale(uniform_scale: float) -> void:
	if static_sprite == null:
		return
	static_sprite.scale = Vector2.ONE * absf(uniform_scale)
	if layered_idle != null:
		layered_idle.set_character_scale(absf(uniform_scale))
	_sync_attachment_scale()
	if animated_sprite.visible:
		_sync_clip_geometry()


func canonical_height_px() -> float:
	return _canonical_height_px


func install_animation_set(next_set: MochiAnimationSet) -> void:
	if next_set == null:
		return
	animation_set = next_set
	_geometry_cache.clear()
	_apply_resolution(true)


func status_line() -> String:
	if presentation_mode == &"LAYERED_IDLE":
		return "%s → %s" % [String(requested_action), layered_idle.status_line()]
	return "%s %s → %s:%s%s" % [
		String(requested_action), String(direction), String(resolved_source),
		String(resolved_clip) if resolved_clip != &"" else "canonical static",
		" (fallback)" if used_fallback else ""
	]


func _apply_resolution(force_restart: bool) -> void:
	if animation_set == null or static_sprite == null or animated_sprite == null or layered_idle == null:
		return
	if requested_action in [&"idle", &"ambient_idle"]:
		var changed_to_layered: bool = presentation_mode != &"LAYERED_IDLE" or resolved_action != requested_action
		presentation_mode = &"LAYERED_IDLE"
		resolved_action = requested_action
		resolved_source = &"LAYERED_FINAL" if layered_idle.production_layers_complete else &"LAYERED_TEMP"
		resolved_clip = &""
		used_fallback = not layered_idle.production_layers_complete
		static_sprite.flip_h = false
		animated_sprite.visible = false
		layered_idle.visible = true
		layered_idle.start_idle(requested_action, force_restart or changed_to_layered)
		_sync_attachment_scale()
		if changed_to_layered or force_restart:
			clip_resolved.emit(requested_action, resolved_source, &"")
		return
	layered_idle.stop_idle()
	var selection: Dictionary = animation_set.resolve(requested_action, direction)
	var next_source: StringName = selection["source"]
	var next_clip: StringName = selection["clip"]
	var changed: bool = next_source != resolved_source or next_clip != resolved_clip
	resolved_source = next_source
	resolved_clip = next_clip
	resolved_action = selection["resolved_action"]
	used_fallback = selection["used_fallback"]
	var mirror: bool = selection["flip_h"]
	static_sprite.flip_h = mirror
	presentation_mode = &"ACTION_ANIMATION" if next_source != &"STATIC" else &"STATIC_FALLBACK"
	_sync_attachment_scale()
	if next_source == &"STATIC":
		layered_idle.visible = true
		layered_idle.show_static_fallback()
		animated_sprite.visible = false
	else:
		var frames: SpriteFrames = animation_set.frames_for(next_source, next_clip)
		animated_sprite.sprite_frames = frames
		if changed or force_restart:
			animated_sprite.animation = next_clip
			_sync_clip_geometry()
			animated_sprite.play()
			if is_paused:
				animated_sprite.pause()
		animated_sprite.flip_h = mirror
		animated_sprite.visible = true
		layered_idle.visible = false
	if changed or force_restart:
		clip_resolved.emit(requested_action, resolved_source, resolved_clip)


func _sync_attachment_scale() -> void:
	if static_sprite == null or canonical_reference_texture == null:
		return
	var visible_height: float = _canonical_height_px * absf(static_sprite.scale.y)
	var factor: float = visible_height / 150.0
	if carry_anchor != null:
		carry_anchor.position = Vector2((-_base_carry_x if direction == &"LEFT" else _base_carry_x) * factor,
			_base_carry_y * factor)
		carry_anchor.scale = Vector2(-factor if direction == &"LEFT" else factor, factor)
	if contact_shadow != null:
		contact_shadow.scale = Vector2.ONE * factor
		contact_shadow.visible = true


func _sync_clip_geometry() -> void:
	if resolved_source == &"STATIC" or animated_sprite.sprite_frames == null:
		return
	var frames: SpriteFrames = animated_sprite.sprite_frames
	var cache_key: String = "%s:%s" % [String(resolved_source), String(resolved_clip)]
	if not _geometry_cache.has(cache_key):
		var first_texture: Texture2D = frames.get_frame_texture(resolved_clip, 0)
		var first_size: Vector2 = first_texture.get_size()
		var visible_height: float = 0.0
		var foot_y: float = 0.0
		for index in range(frames.get_frame_count(resolved_clip)):
			var texture: Texture2D = frames.get_frame_texture(resolved_clip, index)
			var used: Rect2i = texture.get_image().get_used_rect()
			visible_height = maxf(visible_height, float(used.size.y))
			foot_y = maxf(foot_y, float(used.end.y))
		visible_height = float(animation_set.visible_height_by_clip.get(resolved_clip, visible_height))
		foot_y = float(animation_set.foot_y_by_clip.get(resolved_clip, foot_y))
		_geometry_cache[cache_key] = {
			"width": first_size.x, "visible_height": maxf(visible_height, 1.0), "foot_y": foot_y
		}
	var geometry: Dictionary = _geometry_cache[cache_key]
	var world_height: float = _canonical_height_px * absf(static_sprite.scale.y)
	animated_sprite.scale = Vector2.ONE * (world_height / geometry["visible_height"])
	animated_sprite.offset = Vector2(-geometry["width"] * 0.5, -geometry["foot_y"])
