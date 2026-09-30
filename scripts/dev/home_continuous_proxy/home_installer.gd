extends Node
## Add outdoor terrain and semantic props to the existing proxy café before its nav bake.

const SOURCE := "res://assets/dev_proxy/tiny_swords/"
const ACTOR_SCENE := preload("res://scenes/dev/world_hardening/actor.tscn")
const ACTOR_VISUAL := preload("res://scripts/dev/proxy_cafe/proxy_visual_root.gd")
const TREE_SCENE := preload("res://scenes/dev/home_continuous_proxy/animated_tree_prop.tscn")
const PLANT_SCENE := preload("res://scenes/dev/world_hardening/plant.tscn")
var home: PlaceholderCafe
var grid: ProxyPlacementGrid


func _ready() -> void:
	home = get_parent() as PlaceholderCafe
	home.room_bounds = Rect2(-896, -704, 2176, 2496)
	grid = home.get_node("ProxyInstaller").grid as ProxyPlacementGrid
	grid.cell_bounds = Rect2i(-28, -22, 68, 78)
	_build_terrain()
	_build_semantic_props()
	_build_envelope()
	_add_visitor()
	_add_route_markers()
	(home.get_node("DepthSortedLayer/Characters/Cat") as HardeningActor).position = Vector2(530, -220)


func _area(parent: Node, name: String, bounds: Rect2) -> Node2D:
	var node := Node2D.new()
	node.name = name
	node.set_meta("bounds", bounds)
	parent.add_child(node)
	return node


func _terrain_layer(parent: Node2D, name: String, asset: String, atlas_cell: Vector2i, cells: Rect2i, z: int) -> void:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(64, 64)
	var source := TileSetAtlasSource.new()
	source.texture = load(SOURCE + asset)
	source.texture_region_size = Vector2i(64, 64)
	source.create_tile(atlas_cell)
	var source_id := tile_set.add_source(source)
	var layer := TileMapLayer.new()
	layer.name = name
	layer.tile_set = tile_set
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.z_index = z
	parent.add_child(layer)
	for y in range(cells.position.y, cells.end.y):
		for x in range(cells.position.x, cells.end.x):
			layer.set_cell(Vector2i(x, y), source_id, atlas_cell)


func _build_terrain() -> void:
	var architecture := home.get_node("Architecture") as Node2D
	var outdoors := _area(architecture, "OutdoorTerrain", home.room_bounds)
	_terrain_layer(outdoors, "SharedGrass", "grass_atlas.png", Vector2i(1, 1),
		Rect2i(-14, -11, 34, 39), -13)
	var plaza := _area(outdoors, "FrontPlazaArea", Rect2(0, 1024, 768, 768))
	_terrain_layer(plaza, "PlazaPaving", "ochre_atlas.png", Vector2i(1, 1),
		Rect2i(1, 17, 10, 8), -12)
	_terrain_layer(plaza, "StreetEdge", "ochre_atlas.png", Vector2i(1, 1),
		Rect2i(-10, 26, 29, 2), -12)
	var garden := _area(outdoors, "BackGardenArea", Rect2(0, -704, 896, 704))
	_terrain_layer(garden, "GardenPath", "ochre_atlas.png", Vector2i(1, 1),
		Rect2i(7, -9, 2, 10), -12)
	_terrain_layer(garden, "GardenClearing", "ochre_atlas.png", Vector2i(1, 1),
		Rect2i(4, -8, 6, 3), -12)
	var riverside := _area(outdoors, "RiversideArea", Rect2(-896, 896, 896, 896))
	_terrain_layer(riverside, "RiverPath", "ochre_atlas.png", Vector2i(1, 1),
		Rect2i(-10, 19, 13, 3), -12)
	_terrain_layer(riverside, "Water", "water.png", Vector2i.ZERO,
		Rect2i(-14, -11, 4, 39), -11)
	_terrain_layer(riverside, "GrassBankEdge", "grass_atlas.png", Vector2i(5, 4),
		Rect2i(-10, -11, 1, 39), -10)
	_area(outdoors, "FutureExpansionArea", Rect2(768, 0, 512, 1792))
	# The existing Pixel Crawler café floor and wall remain above outdoor terrain.


func _props_area(parent: Node2D, name: String) -> Node2D:
	var group := Node2D.new()
	group.name = name
	group.y_sort_enabled = true
	parent.add_child(group)
	return group


func _add_tree(parent: Node2D, id: String, point: Vector2, variant: int) -> void:
	var tree := TREE_SCENE.instantiate() as HomeAnimatedTreeProp
	tree.name = id.to_pascal_case()
	tree.stable_id = StringName(id)
	tree.tree_variant = variant
	tree.position = point
	parent.add_child(tree)
	var origin := grid.world_to_cell(point) - Vector2i.ONE
	if not grid.occupy(StringName(id), origin, Vector2i(2, 2)):
		push_warning("Outdoor tree placement overlap: " + id)


func _visual_prop(parent: Node2D, id: String, point: Vector2, asset: String,
		frame_size: Vector2i = Vector2i.ZERO, frame_count: int = 1) -> HardeningWorldObject:
	var prop := HardeningWorldObject.new()
	prop.name = id.to_pascal_case()
	prop.stable_id = StringName(id)
	prop.kind = "plant"
	prop.position = point
	parent.add_child(prop)
	var runtime := Node2D.new()
	runtime.name = "RuntimeVisual"
	runtime.visible = false
	prop.add_child(runtime)
	var visual := Node2D.new()
	visual.name = "VisualRoot"
	prop.add_child(visual)
	var texture := load(SOURCE + asset) as Texture2D
	if frame_count > 1:
		var frames := SpriteFrames.new()
		frames.add_animation("ambient")
		frames.set_animation_speed("ambient", 10.0)
		frames.set_animation_loop("ambient", true)
		for i in frame_count:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
			frames.add_frame("ambient", atlas)
		var animation := AnimatedSprite2D.new()
		animation.name = "TemporaryProxySprite"
		animation.sprite_frames = frames
		animation.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		animation.position = Vector2(0, -frame_size.y * 0.5)
		visual.add_child(animation)
		animation.play("ambient")
	else:
		var sprite := Sprite2D.new()
		sprite.name = "TemporaryProxySprite"
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if frame_size != Vector2i.ZERO:
			sprite.region_enabled = true
			sprite.region_rect = Rect2(Vector2.ZERO, frame_size)
		sprite.position.y = -15.0 if frame_size.x == 128 else -texture.get_height() * 0.35
		visual.add_child(sprite)
	return prop


func _build_semantic_props() -> void:
	var objects := home.get_node("DepthSortedLayer/WorldObjects") as Node2D
	var plaza := _props_area(objects, "FrontPlazaProps")
	var garden := _props_area(objects, "BackGardenProps")
	var river := _props_area(objects, "RiversideProps")
	_add_tree(plaza, "plaza_tree_west", Vector2(80, 1330), 1)
	_add_tree(plaza, "plaza_tree_east", Vector2(710, 1430), 2)
	_add_tree(garden, "garden_tree_west", Vector2(170, -390), 1)
	_add_tree(garden, "garden_tree_east", Vector2(745, -490), 2)
	_add_tree(river, "river_depth_tree", Vector2(-320, 1270), 1)
	_add_tree(river, "river_tree_north", Vector2(-470, 1030), 2)
	for point in [Vector2(70, 1550), Vector2(625, 1150), Vector2(70, -230), Vector2(360, -580)]:
		var area := garden if point.y < 0 else plaza
		_visual_prop(area, "bush_%d_%d" % [point.x, point.y], point,
			"bush1.png", Vector2i(128, 128))
	for point in [Vector2(-520, 1430), Vector2(-540, 1090)]:
		_visual_prop(river, "river_rock_%d" % point.y, point, "rock1.png")
	_visual_prop(river, "water_rock_ambient", Vector2(-770, 1280),
		"water_rock1.png", Vector2i(64, 64), 16)
	var look := _visual_prop(river, "river_look", Vector2(-520, 1220), "rock1.png")
	look.set_meta("future_interaction", "FishWatch / RiverLook (DEV anchor)")
	var sniff := PLANT_SCENE.instantiate() as HardeningWorldObject
	sniff.name = "CatSniff"
	sniff.stable_id = &"cat_sniff"
	sniff.position = Vector2(610, -360)
	garden.add_child(sniff)
	var old := Node2D.new()
	old.name = "RuntimeVisual"
	old.visible = false
	sniff.add_child(old)
	var visual := Node2D.new()
	visual.name = "VisualRoot"
	sniff.add_child(visual)
	var bush := Sprite2D.new()
	bush.texture = load(SOURCE + "bush1.png")
	bush.region_enabled = true
	bush.region_rect = Rect2(0, 0, 128, 128)
	bush.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bush.position.y = -15
	visual.add_child(bush)


func _wall_rect(parent: Node2D, id: String, center: Vector2, size: Vector2) -> void:
	var wall := HardeningWorldObject.new()
	wall.name = id.to_pascal_case()
	wall.stable_id = StringName(id)
	wall.kind = "entrance"
	wall.position = center
	parent.add_child(wall)
	var dummy := Node2D.new()
	dummy.name = "RuntimeVisual"
	dummy.visible = false
	wall.add_child(dummy)
	var footprint := HardeningFootprint.new()
	footprint.name = "PhysicalFootprint"
	footprint.footprint_size = size
	wall.add_child(footprint)
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	footprint.add_child(collision)
	footprint._update_shape()


func _build_envelope() -> void:
	var envelope := _props_area(home.get_node("DepthSortedLayer/WorldObjects") as Node2D, "CafeEnvelope")
	# Tile shell has two authored visual gaps; these footprints make them real gates.
	_wall_rect(envelope, "west_wall", Vector2(16, 512), Vector2(32, 1024))
	_wall_rect(envelope, "east_wall", Vector2(624, 512), Vector2(32, 1024))
	_wall_rect(envelope, "rear_wall_west", Vector2(240, 28), Vector2(480, 56))
	_wall_rect(envelope, "rear_wall_east", Vector2(592, 28), Vector2(96, 56))
	_wall_rect(envelope, "front_wall_west", Vector2(144, 992), Vector2(288, 64))
	_wall_rect(envelope, "front_wall_east", Vector2(496, 992), Vector2(288, 64))
	_wall_rect(envelope, "river_water_boundary", Vector2(-768, 544), Vector2(256, 2496))


func _add_visitor() -> void:
	var visitor := ACTOR_SCENE.instantiate() as HardeningActor
	visitor.name = "Visitor"
	visitor.category = "customer"
	visitor.position = Vector2(320, 800)
	visitor.visual_offset = Vector2(10000, 10000)
	visitor.move_speed = 230.0
	var visual := Node2D.new()
	visual.name = "VisualRoot"
	visual.set_script(ACTOR_VISUAL)
	visitor.add_child(visual)
	home.get_node("DepthSortedLayer/Characters").add_child(visitor)
	visitor.queue_redraw()


func _add_route_markers() -> void:
	var markers := {
		"cafe_start": Vector2(320, 800),
		"front_threshold": Vector2(320, 1060),
		"front_plaza": Vector2(325, 1280),
		"river_front_depth": Vector2(-320, 1305),
		"river_behind_depth": Vector2(-378, 1165),
		"riverside": Vector2(-520, 1220),
		"return_plaza": Vector2(320, 1150),
		"cafe_return": Vector2(500, 350),
		"rear_threshold": Vector2(512, -90),
		"back_garden": Vector2(550, -400),
		"final_cafe": Vector2(320, 780),
	}
	for key in markers:
		var marker := Marker2D.new()
		marker.name = key
		marker.position = markers[key]
		home.get_node("Spawns").add_child(marker)
