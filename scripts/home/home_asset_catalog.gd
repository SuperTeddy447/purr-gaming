class_name HomeAssetCatalog
extends Resource
## Lightweight lookup table; intentionally not an inventory or global system.

@export var definitions: Array[HomeAssetDefinition] = []

var _by_id: Dictionary = {}


func _init() -> void:
	_rebuild_index()


func _rebuild_index() -> void:
	_by_id.clear()
	for definition in definitions:
		if definition != null and definition.asset_id != &"":
			_by_id[definition.asset_id] = definition


func find_asset(asset_id: StringName) -> HomeAssetDefinition:
	if _by_id.is_empty() and not definitions.is_empty():
		_rebuild_index()
	return _by_id.get(asset_id) as HomeAssetDefinition


func stable_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for definition in definitions:
		if definition != null:
			result.append(definition.asset_id)
	return result


func validate_unique_ids() -> bool:
	var seen: Dictionary = {}
	for definition in definitions:
		if definition == null or definition.asset_id == &"" or seen.has(definition.asset_id):
			return false
		seen[definition.asset_id] = true
	return true


func validate_complete_contracts() -> bool:
	if not validate_unique_ids():
		return false
	for definition in definitions:
		if definition == null or not definition.validate_slot_contracts():
			return false
	return true
