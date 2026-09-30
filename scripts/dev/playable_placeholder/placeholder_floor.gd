@tool
extends Node2D
## Runtime floor texture with the authored room bounds left unchanged.

const FLOOR_TEXTURE: Texture2D = preload("res://assets/environment/home_v3/production_batch_a_v1/WILLICAT_ASSET_A01_WARM_WOOD_FLOOR_TILE_V1.png")
const TILE_SCALE := 0.18

@export var room_title := "MAIN CAFÉ"
@export var floor_size := Vector2(640, 1000)
@export var use_wood_tile := false


func _ready() -> void:
	if not use_wood_tile:
		return
	var texture_rect := get_node_or_null("RuntimeFloorTexture") as TextureRect
	if texture_rect == null:
		texture_rect = TextureRect.new()
		texture_rect.name = "RuntimeFloorTexture"
		texture_rect.texture = FLOOR_TEXTURE
		texture_rect.position = Vector2.ZERO
		texture_rect.scale = Vector2.ONE * TILE_SCALE
		texture_rect.size = floor_size / TILE_SCALE
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_TILE
		texture_rect.texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
		texture_rect.modulate = Color(0.86, 0.86, 0.86)
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.z_index = -1
		add_child(texture_rect)
		move_child(texture_rect, 0)
	queue_redraw()


func _draw() -> void:
	if has_node("RuntimeFloorTexture"):
		return
	draw_rect(Rect2(Vector2.ZERO, floor_size), Color("#ddd3bc"))
	draw_rect(Rect2(Vector2.ZERO, floor_size), Color("#6b665e"), false, 8.0)
	draw_rect(Rect2(0, 0, floor_size.x, 90), Color("#b9c5b4"))
