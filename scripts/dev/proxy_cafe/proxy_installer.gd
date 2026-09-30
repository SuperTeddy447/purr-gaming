extends Node
## Installs a local-dev visual skin on the proven Main Café scene.
const SOURCE := "res://assets/dev_proxy/pixel_crawler/"
const ACTOR_VISUAL := preload("res://scripts/dev/proxy_cafe/proxy_visual_root.gd")
var room: PlaceholderCafe
var grid := ProxyPlacementGrid.new()

func _ready() -> void:
    room = get_parent() as PlaceholderCafe
    room.get_node("Architecture/Floor").visible = false
    room.get_node("Architecture/WallModule").visible = false
    room.get_node("DepthSortedLayer/WorldObjects/BackDoor").position = Vector2(512, 130)
    room.get_node("DepthSortedLayer/WorldObjects/Grinder").position = Vector2(555, 210)
    _build_shell()
    _skin_objects()
    _skin_actors()
    _register_initial_footprints()

func _build_shell() -> void:
    var architecture := room.get_node("Architecture") as Node2D
    _make_tiles(architecture, "FloorTiles", "floor_wood", -10, false)
    _make_tiles(architecture, "WallTiles", "wall_stone", -9, true)
    for x in [96, 320]:
        var window := Sprite2D.new()
        window.name = "Window_%d" % x
        window.texture = load(SOURCE + "window.png")
        window.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        window.scale = Vector2(2, 2)
        window.position = Vector2(x, 58)
        window.z_index = -8
        architecture.add_child(window)

func _make_tiles(parent: Node2D, node_name: String, basename: String, z: int, wall: bool) -> void:
    var tile_set := TileSet.new()
    tile_set.tile_size = Vector2i(16, 16)
    var source := TileSetAtlasSource.new()
    source.texture = load(SOURCE + basename + ".png")
    source.texture_region_size = Vector2i(16, 16)
    source.create_tile(Vector2i.ZERO)
    var source_id := tile_set.add_source(source)
    var layer := TileMapLayer.new()
    layer.name = node_name
    layer.tile_set = tile_set
    layer.scale = Vector2(2, 2)
    layer.position = Vector2(16, 16)
    layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    layer.z_index = z
    parent.add_child(layer)
    for y in 32:
        for x in 20:
            var place := true
            if wall:
                place = y < 3 or x == 0 or x == 19 or y >= 30
                if (y >= 30 and x in [9, 10]) or (y < 3 and x in [15, 16]):
                    place = false
            if place:
                layer.set_cell(Vector2i(x, y), source_id, Vector2i.ZERO)

func _skin_objects() -> void:
    _visual("CounterShell", "counter", 2.5, Vector2(0, 30))
    var counter := room.get_node("DepthSortedLayer/WorldObjects/CounterShell") as Node2D
    counter.get_node("OrderSlot/ApproachAnchor").position = Vector2(-70, 65)
    counter.get_node("OrderSlot/ActionAnchor").position = Vector2(-70, 37)
    counter.get_node("OrderSlot/ExitAnchor").position = Vector2(-70, 65)
    counter.get_node("ServeSlot/ApproachAnchor").position = Vector2(-25, -75)
    counter.get_node("ServeSlot/ActionAnchor").position = Vector2(-25, -30)
    counter.get_node("ServeSlot/ExitAnchor").position = Vector2(0, -75)
    counter.get_node("WorkerIdle").position = Vector2(40, -88)
    _visual("EspressoStation", "espresso", 1.6, Vector2(0, 0))
    _visual("POS", "pos", 1.7, Vector2(0, 0))
    _visual("Grinder", "grinder", 1.7, Vector2(0, 0))
    _visual("PastryCase", "pastry", 1.5, Vector2(0, 0))
    for object_name in ["TableA", "TableB"]:
        _visual(object_name, "table_round", 3.0, Vector2(0, 0))
    for object_name in ["ChairA", "ChairB", "ChairC", "ChairD"]:
        _visual(object_name, "chair", 2.4, Vector2(0, 0))
    _visual("CatBed", "cat_bed", 1.7, Vector2(0, 0))
    _visual("ScratchPost", "scratch", 0.85, Vector2(0, 0))
    var post := room.get_node("DepthSortedLayer/WorldObjects/ScratchPost/VisualRoot/TemporaryProxySprite") as Sprite2D
    post.scale.x = 2.2
    post.position.x = -post.texture.get_width() * post.scale.x * 0.5
    _visual("Plant", "plant", 2.0, Vector2(0, 0))
    _visual("Entrance", "door", 2.0, Vector2(0, 0))
    _visual("BackDoor", "door", 1.5, Vector2(0, 0))
    _seating_rug(Vector2(175, 500))
    _seating_rug(Vector2(455, 605))
    # Descriptive grouping keeps gameplay objects direct children for save deltas.
    _composition("CafeServiceBarSmall", ["CounterShell", "POS", "PastryCase", "EspressoStation", "Grinder"])
    _composition("CafeTableSet2_A", ["TableA", "ChairA", "ChairB"])
    _composition("CafeTableSet2_B", ["TableB", "ChairC", "ChairD"])
    _composition("CatLifeCornerSmall", ["CatBed", "ScratchPost", "Plant"])

func _seating_rug(center: Vector2) -> void:
    var rug := Sprite2D.new()
    rug.name = "SeatingRug"
    rug.texture = load(SOURCE + "seating_rug.png")
    rug.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    rug.scale = Vector2(3.4, 3.4)
    rug.position = center
    rug.z_index = -7
    room.get_node("Architecture").add_child(rug)

func _visual(object_name: String, asset_name: String, scale_factor: float, offset: Vector2) -> void:
    var object := room.get_node("DepthSortedLayer/WorldObjects/" + object_name) as Node2D
    var old := object.get_node_or_null("RuntimeVisual") as CanvasItem
    if old != null:
        old.visible = false
    var root := Node2D.new()
    root.name = "VisualRoot"
    object.add_child(root)
    var sprite := Sprite2D.new()
    sprite.name = "TemporaryProxySprite"
    sprite.texture = load(SOURCE + asset_name + ".png")
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.centered = false
    sprite.scale = Vector2.ONE * scale_factor
    sprite.position = Vector2(-sprite.texture.get_width() * scale_factor * 0.5, -sprite.texture.get_height() * scale_factor) + offset
    root.add_child(sprite)

func _composition(id: String, members: Array[String]) -> void:
    var marker := Node2D.new()
    marker.name = id
    marker.set_meta("semantic_members", members)
    add_child(marker)

func _skin_actors() -> void:
    for actor_name in ["Worker", "Customer"]:
        var actor := room.get_node("DepthSortedLayer/Characters/" + actor_name) as HardeningActor
        actor.visual_offset = Vector2(10000, 10000)
        actor.queue_redraw()
        var visual := Node2D.new()
        visual.name = "VisualRoot"
        visual.set_script(ACTOR_VISUAL)
        actor.add_child(visual)

func _register_initial_footprints() -> void:
    # Assembly check only. The existing footprint/nav system remains runtime authority.
    var records := [
        ["table_a", "TableA", Vector2i(3, 3)],
        ["chair_a", "ChairA", Vector2i(1, 1)],
        ["chair_b", "ChairB", Vector2i(1, 1)],
        ["table_b", "TableB", Vector2i(3, 3)],
        ["chair_c", "ChairC", Vector2i(1, 1)],
        ["chair_d", "ChairD", Vector2i(1, 1)],
        ["cat_bed", "CatBed", Vector2i(2, 2)],
        ["scratch_post", "ScratchPost", Vector2i(1, 1)],
        ["plant", "Plant", Vector2i(1, 1)],
    ]
    for record in records:
        var object := room.get_node("DepthSortedLayer/WorldObjects/" + String(record[1])) as Node2D
        var size: Vector2i = record[2]
        var origin := grid.world_to_cell(object.position) - Vector2i(size.x / 2, size.y / 2)
        if not grid.occupy(StringName(record[0]), origin, size):
            push_error("Proxy placement grid overlap: " + String(record[0]))
