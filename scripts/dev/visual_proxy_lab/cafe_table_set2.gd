extends Node2D
## Reusable visual binding for an existing table and its two semantic chairs.

const CHAIR_VISUAL := preload("res://scenes/dev/visual_proxy_lab/cafe_directional_chair_visual.tscn")
const TABLE_ATLAS := "res://assets/dev_proxy/retro_interior/TopDownHouse_FurnitureState1.png"

@export var table_name := "TableA"
@export var left_chair_name := "ChairA"
@export var right_chair_name := "ChairB"


func bind(world: Node) -> void:
	var group := world.get_node("DepthSortedLayer/WorldObjects")
	var table := group.get_node(table_name) as HardeningWorldObject
	_skin_table(table)
	for chair_name in [left_chair_name, right_chair_name]:
		var chair := group.get_node(chair_name) as HardeningWorldObject
		var visual_root := chair.get_node("VisualRoot") as Node2D
		visual_root.get_node("TemporaryProxySprite").visible = false
		var visual := CHAIR_VISUAL.instantiate()
		visual.name = "DirectionalFurnitureVisual"
		visual.set("direction", &"ne" if chair.global_position.x < table.global_position.x else &"nw")
		visual_root.add_child(visual)
		chair.set_meta("visual_family", "cozy_coffee/chair_wood")
		chair.set_meta("visual_direction", visual.get("direction"))
		chair.set_meta("visual_sheet_cell", Vector2i(384, 384))
		chair.set_meta("visual_pivot", Vector2(192, 380))
		chair.set_meta("visual_world_scale", visual.get("world_scale"))
	set_meta("semantic_members", [table_name, left_chair_name, right_chair_name])


func _skin_table(table: HardeningWorldObject) -> void:
	var visual_root := table.get_node("VisualRoot") as Node2D
	visual_root.get_node("TemporaryProxySprite").visible = false
	var frame := AtlasTexture.new()
	frame.atlas = load(TABLE_ATLAS)
	frame.region = Rect2(84, 44, 24, 21)
	var sprite := Sprite2D.new()
	sprite.name = "RetroInteriorTableVisual"
	sprite.texture = frame
	sprite.centered = false
	sprite.scale = Vector2.ONE * 3.0
	sprite.position = Vector2(-36, -63)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual_root.add_child(sprite)
	table.set_meta("visual_family", "retro_interior/round_table")
	table.set_meta("visual_world_scale", 3.0)
	table.set_meta("visual_pivot", Vector2(12, 21))
