extends Node
## Development-only V2 candidate skin over the existing playable Home scene.
## Slots retain their stable V1 semantic IDs, transforms, depth owners and gameplay.

const TEXTURE_ROOT := "res://assets/environment/home_v2/"
const SLOT_TEXTURES := {
	"architecture_home_01|architecture_full_canvas": "architecture_home_v2_01",
	"counter_basic_01|counter_back": "counter_home_v2_01",
	"counter_basic_01|counter_front": "counter_front_occluder_home_v2_01",
	"espresso_basic_01|espresso_machine": "espresso_home_v2_01",
	"grinder_basic_01|grinder": "grinder_home_v2_01",
	"pos_basic_01|pos_terminal": "pos_home_v2_01",
	"pastry_case_basic_01|pastry_case_shell": "pastry_case_home_v2_01",
	"table_round_01|table_guest_area_a": "table_round_home_v2_01",
	"table_round_01|table_guest_area_bc": "table_round_home_v2_01",
	"chair_jade_01|chair_seat_a": "chair_jade_home_v2_01",
	"chair_jade_01|chair_seat_bc_left": "chair_jade_home_v2_01",
	"chair_jade_01|chair_seat_c_right": "chair_jade_home_v2_01",
	"plant_floor_01|floor_plant_left": "plant_floor_home_v2_01",
	"plant_floor_01|floor_plant_right": "plant_floor_home_v2_01",
	"plant_counter_01|counter_plant": "plant_small_home_v2_01",
	"vase_basic_01|table_a_vase": "flower_vase_home_v2_01",
	"sign_main_01|main_sign_frame": "signage_blank_home_v2_01",
	"sign_hanging_01|hanging_sign_frame": "signage_blank_home_v2_01",
	"sign_menu_01|menu_sign_frame": "signage_blank_home_v2_01",
}

var installed_count: int = 0


func _ready() -> void:
	call_deferred("install_candidates")


func install_candidates() -> void:
	var home: Node = get_parent()
	if home == null:
		return
	installed_count = 0
	for node: Node in home.get_tree().get_nodes_in_group(&"home_asset_slots"):
		if not home.is_ancestor_of(node) or not node is HomeAssetSlot:
			continue
		var slot: HomeAssetSlot = node as HomeAssetSlot
		var key: String = "%s|%s" % [String(slot.asset_id), String(slot.slot_role)]
		if not SLOT_TEXTURES.has(key):
			continue
		var asset_name: String = SLOT_TEXTURES[key]
		var texture: Texture2D = load(TEXTURE_ROOT + asset_name + ".png") as Texture2D
		if texture == null:
			push_error("Missing V2 candidate texture: %s" % asset_name)
			continue
		slot.apply_candidate_texture(texture)
		installed_count += 1
	var master: Sprite2D = home.get_node_or_null("World/StructuralBase/DEV_VISUAL_MASTER") as Sprite2D
	if master != null:
		master.texture = load("res://docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_PRODUCTION_STYLE_LOCK_V1.png") as Texture2D
	print("Home V2 visual candidates installed in %d existing semantic slots." % installed_count)
