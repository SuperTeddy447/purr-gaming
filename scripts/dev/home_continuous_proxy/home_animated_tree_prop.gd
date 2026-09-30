class_name HomeAnimatedTreeProp
extends HardeningWorldObject
## DEV semantic tree. Authored frames animate; the trunk alone blocks travel.

const SOURCE := "res://assets/dev_proxy/tiny_swords/"
@export_range(1, 2) var tree_variant := 1


func _ready() -> void:
	stable_id = StringName(name.to_snake_case()) if stable_id == &"" else stable_id
	kind = "plant"
	var frames := SpriteFrames.new()
	frames.add_animation("sway")
	frames.set_animation_speed("sway", 10.0)
	frames.set_animation_loop("sway", true)
	var sheet := load(SOURCE + ("tree2.png" if tree_variant == 2 else "tree1.png")) as Texture2D
	for frame_index in 8:
		var region := AtlasTexture.new()
		region.atlas = sheet
		region.region = Rect2(frame_index * 192, 0, 192, 256)
		frames.add_frame("sway", region)
	var sprite := $VisualRoot/AnimatedSprite2D as AnimatedSprite2D
	sprite.sprite_frames = frames
	sprite.position.y = -120.0 if tree_variant == 2 else -112.0
	sprite.play("sway")
	sprite.frame = int(absf(position.x + position.y)) % 8
