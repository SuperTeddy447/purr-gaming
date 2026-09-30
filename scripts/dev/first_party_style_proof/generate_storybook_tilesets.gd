extends SceneTree
## Reproducible tile resources; placement and walkability remain in the Home scene.

const ART := "res://assets/first_party/storybook_mini_pack_001/normalized/"
const DEST := "res://scenes/dev/first_party_style_proof/"


func _initialize() -> void:
	_write("grass_tile.png", "willicat_grass_tileset_01.tres", 1)
	_write("water_base_tile.png", "willicat_river_tileset_01.tres", 1)
	_write("river_bank_vertical.png", "willicat_river_bank_tileset_01.tres", 2)
	quit()


func _write(source_name: String, destination: String, count: int) -> void:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(256, 256)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load(ART + source_name)
	atlas.texture_region_size = Vector2i(256, 256)
	for i in count:
		atlas.create_tile(Vector2i(i, 0))
	tiles.add_source(atlas)
	var error := ResourceSaver.save(tiles, DEST + destination)
	if error != OK:
		push_error("Could not save first-party tileset: " + destination)
