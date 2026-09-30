class_name VisualLabDirectionalFurniture
extends Node2D
## DEV presentation only. The parent semantic object owns collisions and slots.

const CELL := Vector2i(384, 384)
const PIVOT := Vector2(192, 380)
const DIRECTIONS := [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]
const SOURCE := "res://assets/dev_proxy/cozy_coffee/"

@export var family: StringName = &"chair_wood"
@export var direction: StringName = &"s"
@export var world_scale := 0.18

var sprite: Sprite2D


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.name = "AuthoredDirection"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	_apply()


func set_direction(value: StringName) -> bool:
	if not DIRECTIONS.has(value):
		return false
	direction = value
	if is_node_ready():
		_apply()
	return true


func _apply() -> void:
	var index := DIRECTIONS.find(direction)
	if index < 0:
		push_error("Un-authored furniture direction: " + String(direction))
		return
	var sheet := load(SOURCE + String(family) + "_directions.png") as Texture2D
	if sheet == null or sheet.get_size() != Vector2(1536, 768):
		push_error("Directional sheet missing or registration changed: " + String(family))
		return
	var frame := AtlasTexture.new()
	frame.atlas = sheet
	frame.region = Rect2(Vector2((index % 4) * CELL.x, floori(float(index) / 4.0) * CELL.y), Vector2(CELL))
	sprite.texture = frame
	sprite.scale = Vector2.ONE * world_scale
	sprite.position = -PIVOT * world_scale
