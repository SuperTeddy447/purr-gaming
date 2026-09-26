class_name MochiAnimationPreview
extends Node2D
## Independent development preview for the runtime visual presenter; no café gameplay.

const ACTIONS: Array[StringName] = [
	&"idle", &"ambient_idle", &"walk", &"prepare_coffee",
	&"carry_coffee", &"serve", &"return_idle"
]
const WALK_SIDE_PROTOTYPE_CLIP: StringName = &"walk_side"
const WALK_SIDE_PROTOTYPE_FRAME_COUNT: int = 8
const WALK_SIDE_PROTOTYPE_FRAME_SIZE: Vector2i = Vector2i(320, 320)

@export var actor: Node2D
@export var static_sprite: Sprite2D
@export var presenter: MochiVisualPresenter
@export var carry_anchor: Marker2D
@export var info_label: Label
@export var walk_side_prototype_frames: SpriteFrames

var show_guides: bool = true
var _original_animation_set: MochiAnimationSet
var _walk_side_prototype_active: bool = false


func _ready() -> void:
	if actor == null or static_sprite == null or presenter == null or static_sprite.texture == null:
		push_error("Mochi preview is missing its canonical sprite or visual presenter.")
		return
	var reference: Texture2D = presenter.canonical_reference_texture if presenter.canonical_reference_texture != null else static_sprite.texture
	var used: Rect2i = reference.get_image().get_used_rect()
	_original_animation_set = presenter.animation_set
	presenter.set_character_scale(150.0 / maxf(float(used.size.y), 1.0))
	actor.position = Vector2(get_viewport_rect().size.x * 0.5, get_viewport_rect().size.y * 0.58)
	presenter.play_action(&"idle")
	_update_label()


func _process(_delta: float) -> void:
	_update_label()
	if show_guides:
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: Key = event.keycode
	if key >= KEY_1 and key <= KEY_7:
		presenter.play_action(ACTIONS[int(key) - int(KEY_1)])
	elif key == KEY_A:
		presenter.set_direction(&"LEFT")
	elif key == KEY_D:
		presenter.set_direction(&"RIGHT")
	elif key == KEY_W:
		presenter.set_direction(&"UP")
	elif key == KEY_S:
		presenter.set_direction(&"DOWN")
	elif key == KEY_SPACE:
		presenter.set_paused(not presenter.is_paused)
	elif key == KEY_R:
		presenter.restart_action()
	elif key == KEY_G:
		show_guides = not show_guides
		queue_redraw()
	elif key == KEY_8:
		_toggle_spritecook_walk()
	else:
		return
	_update_label()
	get_viewport().set_input_as_handled()


func _update_label() -> void:
	if info_label == null or presenter == null:
		return
	var walk_test_state: String = "ON" if _walk_side_prototype_active else "OFF"
	var prototype_frame_status: String = ""
	if _walk_side_prototype_active and presenter.animated_sprite.visible:
		prototype_frame_status = "Prototype frame %d/%d at 8 FPS" % [presenter.animated_sprite.frame + 1, WALK_SIDE_PROTOTYPE_FRAME_COUNT]
	elif presenter.animated_sprite.visible and presenter.animated_sprite.sprite_frames != null:
		var anim: StringName = presenter.animated_sprite.animation
		if presenter.animated_sprite.sprite_frames.has_animation(anim):
			var count: int = presenter.animated_sprite.sprite_frames.get_frame_count(anim)
			var fps: float = presenter.animated_sprite.sprite_frames.get_animation_speed(anim)
			prototype_frame_status = "Action frame %d/%d at %.0f FPS (%s)" % [presenter.animated_sprite.frame + 1, count, fps, String(anim)]
	info_label.text = "MOCHI ANIMATION — DEV PREVIEW\n%s\nIdle layers: %s\n%s\n1 idle  •  2 ambient_idle  •  3 walk  •  4 prepare  •  5 carry  •  6 serve  •  7 return_idle\n8 toggle RIGHT walk_side prototype (%s)\nW/A/S/D direction  •  Space pause/play  •  R restart  •  G guides" % [presenter.status_line(), presenter.layered_idle.status_line(), prototype_frame_status, walk_test_state]


func _toggle_spritecook_walk() -> void:
	if _walk_side_prototype_active:
		presenter.install_animation_set(_original_animation_set)
		_walk_side_prototype_active = false
		presenter.play_action(&"idle")
		return
	if not _is_walk_side_prototype_valid():
		push_warning("Walk-side prototype requires its validated 8-frame, 320x320 SpriteFrames resource.")
		return
	var dev_set: MochiAnimationSet = _original_animation_set.duplicate(true) as MochiAnimationSet
	dev_set.temp_frames = walk_side_prototype_frames.duplicate(true) as SpriteFrames
	dev_set.allow_side_mirror = false
	presenter.install_animation_set(dev_set)
	presenter.set_direction(&"RIGHT")
	presenter.play_action(&"walk")
	_walk_side_prototype_active = true


func _is_walk_side_prototype_valid() -> bool:
	if walk_side_prototype_frames == null \
		or not walk_side_prototype_frames.has_animation(WALK_SIDE_PROTOTYPE_CLIP) \
		or walk_side_prototype_frames.get_frame_count(WALK_SIDE_PROTOTYPE_CLIP) != WALK_SIDE_PROTOTYPE_FRAME_COUNT \
		or not walk_side_prototype_frames.get_animation_loop(WALK_SIDE_PROTOTYPE_CLIP) \
		or not is_equal_approx(walk_side_prototype_frames.get_animation_speed(WALK_SIDE_PROTOTYPE_CLIP), 8.0):
		return false
	for frame_index in range(WALK_SIDE_PROTOTYPE_FRAME_COUNT):
		var texture: Texture2D = walk_side_prototype_frames.get_frame_texture(WALK_SIDE_PROTOTYPE_CLIP, frame_index)
		if texture == null or texture.get_size() != Vector2(WALK_SIDE_PROTOTYPE_FRAME_SIZE):
			return false
	return true


func _draw() -> void:
	if not show_guides or actor == null:
		return
	var foot: Vector2 = actor.position
	draw_line(foot + Vector2(-110.0, 0.0), foot + Vector2(110.0, 0.0), Color(0.48, 0.83, 0.7, 0.8), 2.0)
	draw_circle(foot, 4.0, Color(0.48, 0.83, 0.7))
	draw_line(foot + Vector2(-95.0, 0.0), foot + Vector2(-95.0, -150.0), Color(0.9, 0.72, 0.45, 0.8), 2.0)
	draw_line(foot + Vector2(-102.0, -150.0), foot + Vector2(-88.0, -150.0), Color(0.9, 0.72, 0.45, 0.8), 2.0)
	draw_string(ThemeDB.fallback_font, foot + Vector2(-180.0, -160.0), "150 px @ 1x", HORIZONTAL_ALIGNMENT_LEFT, 95.0, 15, Color(0.9, 0.72, 0.45))
	if carry_anchor != null:
		var carry: Vector2 = foot + carry_anchor.position
		draw_circle(carry, 6.0, Color(0.95, 0.83, 0.4, 0.85))
		draw_string(ThemeDB.fallback_font, carry + Vector2(10.0, -9.0), "CarryAnchor", HORIZONTAL_ALIGNMENT_LEFT, 110.0, 14, Color(0.95, 0.83, 0.4))
	if presenter != null and presenter.layered_idle != null:
		_draw_pivot(presenter.layered_idle.debug_tail_pivot_global(), "Tail pivot (TEMP guide)", Color(0.92, 0.55, 0.34))
		_draw_pivot(presenter.layered_idle.debug_ear_pivot_global(), "Ear pivot (TEMP guide)", Color(0.66, 0.78, 0.95))
		draw_string(ThemeDB.fallback_font, foot + Vector2(-180.0, -185.0), presenter.layered_idle.status_line(), HORIZONTAL_ALIGNMENT_LEFT, 460.0, 13, Color(0.88, 0.9, 0.88))


func _draw_pivot(global_pivot: Vector2, label: String, color: Color) -> void:
	var point: Vector2 = to_local(global_pivot)
	draw_line(point + Vector2(-7.0, 0.0), point + Vector2(7.0, 0.0), color, 2.0)
	draw_line(point + Vector2(0.0, -7.0), point + Vector2(0.0, 7.0), color, 2.0)
	draw_string(ThemeDB.fallback_font, point + Vector2(9.0, -7.0), label, HORIZONTAL_ALIGNMENT_LEFT, 190.0, 12, color)
