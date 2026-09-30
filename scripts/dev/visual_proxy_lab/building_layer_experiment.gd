extends Node2D
## Isolated projection/occlusion study. Never placed in the continuous Home map.

const SOURCE := "res://assets/dev_proxy/freeassets_building/"
const ACTOR_STRIP := "res://assets/dev_proxy/pixel_crawler/walk_side.png"
const BUILDING_SCALE := 0.6
var walker: AnimatedSprite2D
var elapsed := 0.0


func _ready() -> void:
	var floor_color := ColorRect.new()
	floor_color.color = Color("779e71")
	floor_color.position = Vector2(-90, -80)
	floor_color.size = Vector2(750, 760)
	floor_color.z_index = -2
	add_child(floor_color)
	var base := Sprite2D.new()
	base.name = "BuildingBase"
	base.texture = load(SOURCE + "Building_Restaurant.png")
	base.centered = false
	base.scale = Vector2.ONE * BUILDING_SCALE
	base.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(base)
	var strip := load(ACTOR_STRIP) as Texture2D
	var frames := SpriteFrames.new()
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 9.0)
	for i in 6:
		var crop := AtlasTexture.new()
		crop.atlas = strip
		crop.region = Rect2(i * 64, 0, 64, 64)
		frames.add_frame("walk", crop)
	walker = AnimatedSprite2D.new()
	walker.name = "MovingProxyCharacter"
	walker.sprite_frames = frames
	walker.scale = Vector2.ONE * 1.8
	walker.position = Vector2(225, 390)
	walker.z_index = 1
	walker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(walker)
	walker.play("walk")
	var front := Sprite2D.new()
	front.name = "ForegroundFront"
	front.texture = load(SOURCE + "Building_Restaurant_Front.png")
	front.centered = false
	front.scale = Vector2.ONE * BUILDING_SCALE
	front.z_index = 2
	front.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(front)


func _process(delta: float) -> void:
	elapsed += delta
	walker.position.x = 225.0 + 85.0 * sin(elapsed * 1.1)
	walker.flip_h = cos(elapsed * 1.1) < 0.0
