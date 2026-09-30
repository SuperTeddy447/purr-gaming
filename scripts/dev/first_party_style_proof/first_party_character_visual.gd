extends Node2D
## VisualRoot adapter; parent actor retains CharacterBody2D and NavigationAgent2D.

const ART := "res://assets/first_party/storybook_mini_pack_001/normalized/"
var actor: HardeningActor
var sprite: AnimatedSprite2D
var facing := "down"


func _ready() -> void:
	actor = get_parent() as HardeningActor
	var frames := SpriteFrames.new()
	for direction in ["down", "up", "left", "right"]:
		var count := 3 if direction == "down" else 4
		var sheet := load(ART + "orange_" + direction + ".png")
		for motion in ["idle", "walk"]:
			var key: String = String(motion) + "_" + String(direction)
			frames.add_animation(key)
			frames.set_animation_speed(key, 2.0 if motion == "idle" else 8.0)
			frames.set_animation_loop(key, true)
			for i in range(0 if motion == "idle" else 1, 1 if motion == "idle" else count):
				var region := AtlasTexture.new()
				region.atlas = sheet
				region.region = Rect2(i * 256, 0, 256, 256)
				frames.add_frame(key, region)
	sprite = $AnimatedSprite2D as AnimatedSprite2D
	sprite.sprite_frames = frames
	sprite.position = Vector2(0, -35.36)
	sprite.scale = Vector2.ONE * 0.34
	sprite.play("idle_down")


func _process(_delta: float) -> void:
	if actor == null:
		return
	var walking := actor.velocity.length_squared() > 4.0
	if walking:
		var v := actor.velocity
		if absf(v.x) > absf(v.y):
			facing = "left" if v.x < 0 else "right"
		else:
			facing = "up" if v.y < 0 else "down"
	var key: String = ("walk_" if walking else "idle_") + facing
	if sprite.animation != key:
		sprite.play(key)
