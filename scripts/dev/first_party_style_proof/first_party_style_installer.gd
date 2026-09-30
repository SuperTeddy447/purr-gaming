extends Node
## Presentation-only swap on the existing continuous Home semantic world.

const ART := "res://assets/first_party/storybook_mini_pack_001/normalized/"
var world: HomeContinuousWorld
var visitor: HardeningActor
var cat_sprite: AnimatedSprite2D
var coffee_fx: AnimatedSprite2D
var facing := "down"


func _ready() -> void:
	call_deferred("_install")


func _install() -> void:
	world = get_parent() as HomeContinuousWorld
	_swap_terrain()
	_swap_trees()
	_swap_seating()
	_install_shell()
	_install_character()
	_install_water_ripple()
	_install_coffee_fx()
	_style_route_button()
	set_process(true)


func _atlas(path: String, x: int, size: Vector2i) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = load(ART + path)
	frame.region = Rect2(x * size.x, 0, size.x, size.y)
	return frame


func _animated_sheet(path: String, animation: String, count: int, fps: float, size: Vector2i) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation(animation)
	frames.set_animation_speed(animation, fps)
	frames.set_animation_loop(animation, true)
	for i in count:
		frames.add_frame(animation, _atlas(path, i, size))
	return frames


func _replace_tiles(path: String, tile_path: String, cell_world_size: float = 64.0) -> void:
	var layer := world.get_node(path) as TileMapLayer
	var occupied := layer.get_used_cells()
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(256, 256)
	var source := TileSetAtlasSource.new()
	source.texture = load(ART + tile_path)
	source.texture_region_size = Vector2i(256, 256)
	source.create_tile(Vector2i.ZERO)
	var source_id := tiles.add_source(source)
	layer.clear()
	layer.tile_set = tiles
	layer.scale = Vector2.ONE * (cell_world_size / 256.0)
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for cell in occupied:
		layer.set_cell(cell, source_id, Vector2i.ZERO)


func _swap_terrain() -> void:
	var base := "Architecture/OutdoorTerrain/"
	_replace_tiles("Architecture/FloorTiles", "cafe_floor_tile.png", 32.0)
	_replace_tiles(base + "SharedGrass", "grass_tile.png")
	for path in ["FrontPlazaArea/PlazaPaving", "FrontPlazaArea/StreetEdge",
		"BackGardenArea/GardenPath", "BackGardenArea/GardenClearing", "RiversideArea/RiverPath"]:
		_replace_tiles(base + path, "path_tile.png")
	_replace_tiles(base + "RiversideArea/Water", "water_base_tile.png")
	_replace_bank(base + "RiversideArea/GrassBankEdge")


func _replace_bank(path: String) -> void:
	var layer := world.get_node(path) as TileMapLayer
	var occupied := layer.get_used_cells()
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(256, 256)
	var source := TileSetAtlasSource.new()
	source.texture = load(ART + "river_bank_vertical.png")
	source.texture_region_size = Vector2i(256, 256)
	source.create_tile(Vector2i.ZERO)
	source.create_tile(Vector2i(1, 0))
	var source_id := tiles.add_source(source)
	layer.clear()
	layer.tile_set = tiles
	layer.scale = Vector2.ONE * 0.25
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for cell in occupied:
		layer.set_cell(cell, source_id, Vector2i(posmod(cell.y, 2), 0))


func _swap_trees() -> void:
	for id in ["plaza_tree_west", "plaza_tree_east", "garden_tree_west", "garden_tree_east", "river_depth_tree", "river_tree_north"]:
		var tree := world.find_object(StringName(id)) as HomeAnimatedTreeProp
		if tree == null:
			push_warning("Missing tree for first-party skin: " + id)
			continue
		var sprite := tree.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
		sprite.sprite_frames = _animated_sheet("tree_gentle_breeze.png", "gentle_breeze", 4, 5.0, Vector2i(512, 640))
		sprite.scale = Vector2.ONE * 0.4
		sprite.position = Vector2(0, -112)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.play("gentle_breeze")
		sprite.frame = int(absf(tree.position.x + tree.position.y)) % 4
		var shadow := tree.get_node("ShadowVisual") as Sprite2D
		shadow.texture = load(ART + "contact_shadow.png")
		shadow.scale = Vector2.ONE * 0.32
		shadow.position = Vector2(0, -5)
		shadow.modulate.a = 0.38
		tree.set_meta("visual_family", "willicat_home_storybook_v1")


func _hide_visual_children(root: Node) -> void:
	for child in root.get_children():
		if child is CanvasItem:
			(child as CanvasItem).visible = false


func _add_contact_shadow(parent: Node2D, scale_amount: float) -> void:
	var shadow := Sprite2D.new()
	shadow.name = "FirstPartyContactShadow"
	shadow.texture = load(ART + "contact_shadow.png")
	shadow.scale = Vector2.ONE * scale_amount
	shadow.position = Vector2(0, -4)
	shadow.z_index = -1
	shadow.modulate.a = 0.35
	parent.add_child(shadow)


func _swap_seating() -> void:
	var objects := world.get_node("DepthSortedLayer/WorldObjects")
	for table_name in ["TableA", "TableB"]:
		var table := objects.get_node(table_name) as HardeningWorldObject
		var root := table.get_node("VisualRoot") as Node2D
		_hide_visual_children(root)
		_add_contact_shadow(root, 0.32)
		var sprite := Sprite2D.new()
		sprite.name = "FirstPartyTableVisual"
		sprite.texture = load(ART + "table_round.png")
		sprite.scale = Vector2.ONE * 0.2
		sprite.position = Vector2(0, -44.8)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		root.add_child(sprite)
		table.set_meta("visual_family", "willicat_home_storybook_v1")
	for chair_name in ["ChairA", "ChairB", "ChairC", "ChairD"]:
		var chair := objects.get_node(chair_name) as HardeningWorldObject
		var root := chair.get_node("VisualRoot") as Node2D
		_hide_visual_children(root)
		_add_contact_shadow(root, 0.2)
		var direction := "ne" if chair_name in ["ChairA", "ChairC"] else "nw"
		var directions := ["n", "ne", "e", "se", "s", "sw", "w", "nw"]
		var sprite := Sprite2D.new()
		sprite.name = "FirstPartyChairVisual"
		sprite.texture = _atlas("chair_directions.png", directions.find(direction), Vector2i(384, 384))
		sprite.scale = Vector2.ONE * 0.18
		sprite.position = Vector2(0, -30.96)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		root.add_child(sprite)
		chair.set_meta("visual_family", "willicat_home_storybook_v1")
		chair.set_meta("visual_direction", direction)


func _install_shell() -> void:
	var architecture := world.get_node("Architecture") as Node2D
	architecture.get_node("WallTiles").visible = false
	for node in architecture.get_children():
		if node.name.begins_with("Window_"):
			(node as CanvasItem).visible = false
	var back := Sprite2D.new()
	back.name = "FirstPartyCafeBackWall"
	back.texture = load(ART + "cafe_back_wall.png")
	back.position = Vector2(320, 140)
	back.scale = Vector2.ONE * 0.625
	back.z_index = -8
	architecture.add_child(back)
	var objects := world.get_node("DepthSortedLayer/WorldObjects") as Node2D
	for side in ["left", "right"]:
		var rail := Node2D.new()
		rail.name = "FirstPartyFrontRail" + side.capitalize()
		rail.position = Vector2(144 if side == "left" else 496, 992)
		objects.add_child(rail)
		var sprite := Sprite2D.new()
		sprite.texture = load(ART + "cafe_front_" + side + ".png")
		sprite.scale = Vector2.ONE * 0.55
		sprite.position = Vector2(0, -71.5)
		rail.add_child(sprite)


func _install_character() -> void:
	visitor = world.get_node("DepthSortedLayer/Characters/Visitor") as HardeningActor
	visitor.get_node("VisualRoot").visible = false
	var visual := Node2D.new()
	visual.name = "FirstPartyVisualRoot"
	visitor.add_child(visual)
	_add_contact_shadow(visual, 0.17)
	var frames := SpriteFrames.new()
	for direction in ["down", "up", "left", "right"]:
		var count := 3 if direction == "down" else 4
		for motion in ["idle", "walk"]:
			var key: String = String(motion) + "_" + String(direction)
			frames.add_animation(key)
			frames.set_animation_speed(key, 2.0 if motion == "idle" else 8.0)
			frames.set_animation_loop(key, true)
			if motion == "idle":
				frames.add_frame(key, _atlas("orange_" + direction + ".png", 0, Vector2i(256, 256)))
			else:
				for i in range(1, count):
					frames.add_frame(key, _atlas("orange_" + direction + ".png", i, Vector2i(256, 256)))
	cat_sprite = AnimatedSprite2D.new()
	cat_sprite.name = "OrangeProtagonistVisual"
	cat_sprite.sprite_frames = frames
	cat_sprite.position = Vector2(0, -35.36)
	cat_sprite.scale = Vector2.ONE * 0.34
	cat_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	visual.add_child(cat_sprite)
	cat_sprite.play("idle_down")
	visitor.set_meta("visual_family", "willicat_home_storybook_v1")


func _install_water_ripple() -> void:
	var ripple := AnimatedSprite2D.new()
	ripple.name = "FirstPartyWaterRipple"
	ripple.sprite_frames = _animated_sheet("water_ripple.png", "calm", 4, 6.67, Vector2i(256, 256))
	ripple.position = Vector2(-770, 1280)
	ripple.scale = Vector2.ONE * 0.25
	ripple.z_index = -9
	world.get_node("Architecture").add_child(ripple)
	ripple.play("calm")


func _install_coffee_fx() -> void:
	var station := world.get_node("DepthSortedLayer/WorldObjects/EspressoStation") as Node2D
	coffee_fx = AnimatedSprite2D.new()
	coffee_fx.name = "FirstPartyCoffeeCompleteFX"
	coffee_fx.sprite_frames = _animated_sheet("coffee_fx.png", "complete", 4, 11.11, Vector2i(256, 256))
	coffee_fx.sprite_frames.set_animation_loop("complete", false)
	coffee_fx.scale = Vector2.ONE * 0.2
	coffee_fx.position = Vector2(0, -70)
	coffee_fx.visible = false
	station.add_child(coffee_fx)
	coffee_fx.animation_finished.connect(func(): coffee_fx.visible = false)
	world.phase_changed.connect(_on_phase_changed)


func _on_phase_changed(label: String) -> void:
	if label.begins_with("Coffee ready"):
		coffee_fx.visible = true
		coffee_fx.play("complete")


func _style_route_button() -> void:
	for node in world.get_node("HUD").find_children("*", "Button", true, false):
		var button := node as Button
		if button.text != "ROUTE":
			continue
		for state in ["normal", "pressed", "disabled"]:
			var index := ["normal", "pressed", "disabled"].find(state)
			var style := StyleBoxTexture.new()
			style.texture = _atlas("interaction_button_states.png", index, Vector2i(320, 128))
			style.texture_margin_left = 40.0
			style.texture_margin_right = 40.0
			style.texture_margin_top = 24.0
			style.texture_margin_bottom = 24.0
			button.add_theme_stylebox_override(state, style)
		button.add_theme_color_override("font_color", Color("#173f3a"))
		button.add_theme_color_override("font_pressed_color", Color("#fff5dc"))
		button.custom_minimum_size = Vector2(92, 52)
		button.set_meta("visual_family", "willicat_home_storybook_v1")
		break


func _process(_delta: float) -> void:
	if visitor == null or cat_sprite == null:
		return
	var moving := visitor.velocity.length_squared() > 4.0
	if moving:
		var velocity := visitor.velocity
		if absf(velocity.x) > absf(velocity.y):
			facing = "left" if velocity.x < 0.0 else "right"
		else:
			facing = "up" if velocity.y < 0.0 else "down"
	var key: String = ("walk_" if moving else "idle_") + facing
	if cat_sprite.animation != key:
		cat_sprite.play(key)
