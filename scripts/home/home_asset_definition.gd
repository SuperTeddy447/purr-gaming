class_name HomeAssetDefinition
extends Resource
## Small visual-only mapping from stable semantic ID to replaceable artwork.

@export var asset_id: StringName = &""
@export var display_name: String = ""
@export var visual_scene: PackedScene
@export var texture: Texture2D
@export var texture_variants: Dictionary = {}
@export var visual_variant: StringName = &"default"
@export var semantic_category: StringName = &""
@export var slot_contracts: Array[HomeAssetSlotContract] = []
@export var status: String = "TEMP PLACEHOLDER"
@export var tintable_candidate: bool = false
@export var transparent_alpha_required: bool = true
@export var y_sort_required: bool = false
@export var floor_contact_pivot: bool = false
@export var texture_top_left_origin: bool = false
@export var future_animation_states: PackedStringArray = PackedStringArray()


func find_slot_contract(slot_role: StringName) -> HomeAssetSlotContract:
	for contract in slot_contracts:
		if contract != null and contract.slot_role == slot_role:
			return contract
	return null


func validate_slot_contracts() -> bool:
	if asset_id == &"" or semantic_category == &"" or slot_contracts.is_empty():
		return false
	var seen_roles: Dictionary = {}
	for contract in slot_contracts:
		if contract == null or not contract.has_valid_contract() or seen_roles.has(contract.slot_role):
			return false
		seen_roles[contract.slot_role] = true
	return true
