extends HomeAnimatedTreeProp
## Reuses the proven trunk collider; only replaces authored presentation frames.

const SHEET := preload("res://assets/first_party/storybook_mini_pack_001/normalized/tree_gentle_breeze.png")


func _ready() -> void:
	super._ready()
	var frames := SpriteFrames.new()
	frames.add_animation("gentle_breeze")
	frames.set_animation_speed("gentle_breeze", 5.0)
	frames.set_animation_loop("gentle_breeze", true)
	for i in 4:
		var region := AtlasTexture.new()
		region.atlas = SHEET
		region.region = Rect2(i * 512, 0, 512, 640)
		frames.add_frame("gentle_breeze", region)
	var visual := $VisualRoot/AnimatedSprite2D as AnimatedSprite2D
	visual.sprite_frames = frames
	visual.scale = Vector2.ONE * 0.4
	visual.position = Vector2(0, -112)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	visual.play("gentle_breeze")
	var shadow := $ShadowVisual as Sprite2D
	shadow.texture = load("res://assets/first_party/storybook_mini_pack_001/normalized/contact_shadow.png")
	shadow.scale = Vector2.ONE * 0.32
	shadow.position = Vector2(0, -5)
	shadow.modulate.a = 0.38
	set_meta("visual_family", "willicat_home_storybook_v1")
