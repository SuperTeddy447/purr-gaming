class_name PlaceholderRoom
extends HardeningWorld
## Isolated playable-room adapter over the proven object/slot/navigation lab.

@export var room_id: StringName
@export var room_bounds := Rect2(0, 0, 640, 1000)
var _baseline_furniture: Dictionary = {}


func _ready() -> void:
	camera_input.camera = $Camera
	camera_director.camera = $Camera
	camera_director.camera_input = camera_input
	camera_director.hud = $HUD
	navigation.walkable_bounds = room_bounds.grow(-18.0)
	rebuild_navigation()
	for actor in actors.get_children():
		if actor is HardeningActor:
			(actor as HardeningActor).bind_world(self)
	_baseline_furniture = _all_furniture_transforms()
	var input := camera_input as PlaceholderCameraInput
	input.room_bounds = room_bounds
	input.set_preset(&"default")


func spawn(spawn_id: StringName) -> Marker2D:
	return $Spawns.get_node_or_null(NodePath(String(spawn_id))) as Marker2D


func apply_overrides(records: Dictionary) -> void:
	for key in records:
		var object := find_object(StringName(key))
		var record: Dictionary = records[key]
		if object == null or not record.has("x") or not record.has("y"):
			continue
		object.position = Vector2(float(record.x), float(record.y))
		object.rotation = float(record.get("angle", 0.0))
	rebuild_navigation()


func _all_furniture_transforms() -> Dictionary:
	var result := {}
	for object in objects.get_children():
		if object is HardeningWorldObject and String(object.kind) in ["table", "chair"]:
			result[String(object.stable_id)] = {
				"x": object.position.x, "y": object.position.y,
				"angle": object.rotation,
			}
	return result


func furniture_overrides() -> Dictionary:
	var result := {}
	var current := _all_furniture_transforms()
	for id in current:
		if current[id] != _baseline_furniture.get(id, {}):
			result[id] = current[id]
	return result


func confirm_furniture_move(id: StringName, candidate: Vector2, angle: float) -> bool:
	var object := find_object(id)
	if object == null or String(object.kind) not in ["table", "chair"]:
		return false
	var old_position := object.global_position
	var old_angle := object.global_rotation
	if not validate_placement(id, candidate, angle):
		object.global_position = old_position
		object.global_rotation = old_angle
		return false
	object.global_position = candidate
	object.global_rotation = angle
	if not rebuild_navigation():
		object.global_position = old_position
		object.global_rotation = old_angle
		rebuild_navigation()
		return false
	if room_id == &"home_cafe_main" and not _required_routes_exist():
		object.global_position = old_position
		object.global_rotation = old_angle
		rebuild_navigation()
		return false
	return true


func _required_routes_exist() -> bool:
	NavigationServer2D.map_force_update(navigation.get_navigation_map())
	var entrance := spawn(&"customer_entry")
	var order := find_slot_on_object(&"counter_shell", &"order")
	var seat := find_slot_on_object(&"chair_a", &"sit")
	var coffee := find_slot_on_object(&"espresso_station", &"work_coffee")
	if entrance == null or order == null or seat == null or coffee == null:
		return false
	for pair in [
		[entrance.global_position, order.approach_anchor().global_position],
		[order.exit_anchor().global_position, seat.approach_anchor().global_position],
		[find_object(&"counter_shell").get_node("WorkerIdle").global_position,
			coffee.approach_anchor().global_position],
	]:
		var path := NavigationServer2D.map_get_path(navigation.get_navigation_map(), pair[0], pair[1], true)
		if path.size() < 2 or path[-1].distance_to(pair[1]) > 18.0:
			return false
	return true
