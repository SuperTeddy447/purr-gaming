extends Node2D
## Small reusable authored loop, for the river component or one-shot coffee FX.

@export var source_file := "water_ripple.png"
@export var clip_name := "calm"
@export var frame_count := 4
@export var frame_rate := 6.67
@export var loop := true
@export var autoplay := true
@export var visual_scale := 0.25
const ART := "res://assets/first_party/storybook_mini_pack_001/normalized/"


func _ready() -> void:
	var sprite := $AnimatedSprite2D as AnimatedSprite2D
	var frames := SpriteFrames.new()
	frames.add_animation(clip_name)
	frames.set_animation_speed(clip_name, frame_rate)
	frames.set_animation_loop(clip_name, loop)
	var sheet := load(ART + source_file)
	for i in frame_count:
		var region := AtlasTexture.new()
		region.atlas = sheet
		region.region = Rect2(i * 256, 0, 256, 256)
		frames.add_frame(clip_name, region)
	sprite.sprite_frames = frames
	sprite.scale = Vector2.ONE * visual_scale
	if autoplay:
		sprite.play(clip_name)
	else:
		sprite.visible = false
		sprite.animation_finished.connect(func(): sprite.visible = false)


func play_once() -> void:
	var sprite := $AnimatedSprite2D as AnimatedSprite2D
	sprite.visible = true
	sprite.play(clip_name)
