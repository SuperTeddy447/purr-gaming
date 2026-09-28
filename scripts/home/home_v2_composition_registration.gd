extends Node
## V2-only visual registration overlay on the inherited playable Home scene.
## The stable asset slots and Home gameplay remain owned by their existing scene.

const SLOT_REGISTRATION := {
	"table_round_01|table_guest_area_a": {"position": Vector2(250.0, 860.0), "scale": 1.32},
	"table_round_01|table_guest_area_bc": {"position": Vector2(535.0, 1190.0), "scale": 1.38},
	"chair_jade_01|chair_seat_a": {"position": Vector2(155.0, 895.0), "scale": 1.18},
	"chair_jade_01|chair_seat_bc_left": {"position": Vector2(430.0, 1220.0), "scale": 1.18},
	"chair_jade_01|chair_seat_c_right": {"position": Vector2(680.0, 1235.0), "scale": 1.18},
	"sign_main_01|main_sign_frame": {"position": Vector2(372.0, 180.0), "scale": 1.15},
	"sign_hanging_01|hanging_sign_frame": {"position": Vector2(72.0, 345.0), "scale": 1.1},
	"sign_menu_01|menu_sign_frame": {"position": Vector2(725.0, 255.0), "scale": 1.12},
	"sign_freestanding_01|freestanding_sign": {"position": Vector2(805.0, 1530.0), "scale": 1.0},
}

func _ready() -> void:
	call_deferred("apply_registration")


func apply_registration() -> void:
	var home: Node = get_parent()
	if home == null:
		return
	for slot_node in home.get_tree().get_nodes_in_group(&"home_asset_slots"):
		if not home.is_ancestor_of(slot_node) or not slot_node is HomeAssetSlot:
			continue
		var slot := slot_node as HomeAssetSlot
		var key := "%s|%s" % [String(slot.asset_id), String(slot.slot_role)]
		if not SLOT_REGISTRATION.has(key):
			continue
		var transform: Dictionary = SLOT_REGISTRATION[key]
		slot.position = transform["position"]
		slot.scale = Vector2.ONE * float(transform["scale"])
	var foreground_plant := home.get_node_or_null("World/ForegroundOccluderLayer/ForegroundPlantsSlot/FloorPlantRightSlot") as HomeAssetSlot
	if foreground_plant != null:
		foreground_plant.position = Vector2(570.0, 0.0)
	_additional_left_table_chair(home)
	_register_sign_surfaces(home)
	_add_pastry_display_cake(home)


func _additional_left_table_chair(home: Node) -> void:
	var depth := home.get_node_or_null("World/DepthSortedLayer") as Node2D
	if depth == null or depth.get_node_or_null("AdditionalLeftTableChair") != null:
		return
	var texture := load("res://assets/environment/home_v2/chair_jade_home_v2_01.png") as Texture2D
	if texture == null:
		return
	var prop := Node2D.new()
	prop.name = "AdditionalLeftTableChair"
	prop.position = Vector2(335.0, 900.0)
	prop.add_to_group(&"home_modular_visuals")
	prop.set_meta(&"asset_id", &"chair_jade_home_v2_01")
	prop.set_meta(&"slot_role", &"extra_left_table_seat")
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.offset = Vector2(-texture.get_width() * 0.5, -texture.get_height())
	sprite.scale = Vector2.ONE * minf(64.0 / texture.get_width(), 80.0 / texture.get_height()) * 1.18
	prop.add_child(sprite)
	depth.add_child(prop)


func _register_sign_surfaces(home: Node) -> void:
	var surfaces := {
		"DynamicSignage/CafeNameSurface": Rect2(Vector2(317.0, 184.0), Vector2(110.0, 44.0)),
		"DynamicSignage/HangingSignSurface": Rect2(Vector2(22.0, 319.0), Vector2(100.0, 48.0)),
		"DynamicSignage/MenuSloganSurface": Rect2(Vector2(670.0, 218.0), Vector2(110.0, 56.0)),
		"DynamicSignage/FreestandingSignSurface": Rect2(Vector2(750.0, 1390.0), Vector2(110.0, 54.0)),
	}
	for path: String in surfaces:
		var control := home.get_node_or_null(path) as Control
		if control != null:
			var rect: Rect2 = surfaces[path]
			control.position = rect.position
			control.size = rect.size


func _add_pastry_display_cake(home: Node) -> void:
	var case_slot := home.get_node_or_null("World/BackDecorLayer/PastryDisplaySlot") as Node2D
	if case_slot == null or case_slot.get_node_or_null("V2CakeDisplayProp") != null:
		return
	var texture := load("res://assets/environment/home_v2/cake_set_home_v2_01.png") as Texture2D
	if texture == null:
		return
	var prop := Node2D.new()
	prop.name = "V2CakeDisplayProp"
	prop.position = Vector2(0.0, -65.0)
	prop.z_index = 1
	prop.add_to_group(&"home_modular_visuals")
	prop.set_meta(&"asset_id", &"cake_set_home_v2_01")
	prop.set_meta(&"slot_role", &"pastry_case_cake_display")
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.offset = Vector2(-texture.get_width() * 0.5, -texture.get_height())
	sprite.scale = Vector2.ONE * minf(62.0 / texture.get_width(), 58.0 / texture.get_height())
	prop.add_child(sprite)
	case_slot.add_child(prop)
