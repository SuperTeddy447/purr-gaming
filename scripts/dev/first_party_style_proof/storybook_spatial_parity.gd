extends SceneTree
## Proves visual swap did not move existing Home gameplay coordinates or footprints.

const PROXY := preload("res://scenes/dev/visual_proxy_lab/home_visual_proxy_lab_v1.tscn")
const FIRST := preload("res://scenes/dev/first_party_style_proof/home_first_party_style_proof_001.tscn")
const OBJECTS := ["TableA", "TableB", "ChairA", "ChairB", "ChairC", "ChairD", "EspressoStation", "CounterShell"]
const TREES := ["plaza_tree_west", "plaza_tree_east", "garden_tree_west", "garden_tree_east", "river_depth_tree", "river_tree_north"]
const MARKERS := ["cafe_start", "front_threshold", "front_plaza", "river_front_depth", "river_behind_depth", "riverside", "return_plaza", "cafe_return", "rear_threshold", "back_garden", "final_cafe"]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var proxy: Dictionary = await _snapshot(PROXY)
	var first: Dictionary = await _snapshot(FIRST)
	if proxy != first:
		for key in proxy:
			if not first.has(key) or proxy[key] != first[key]:
				push_error("Spatial mismatch: " + String(key) + " proxy=" + str(proxy[key]) + " first=" + str(first.get(key)))
		quit(1)
		return
	print("SPATIAL_PARITY PASS entries=%d; existing object positions, footprints, actor root, and route markers unchanged" % proxy.size())
	quit(0)


func _snapshot(scene: PackedScene) -> Dictionary:
	var world := scene.instantiate() as HomeContinuousWorld
	world.autoplay_route = false
	root.add_child(world)
	for i in 6:
		await process_frame
	var record := {}
	for name in OBJECTS:
		var object := world.get_node("DepthSortedLayer/WorldObjects/" + name) as HardeningWorldObject
		record["object/" + name] = object.position
		var footprint := object.get_node_or_null("PhysicalFootprint") as HardeningFootprint
		if footprint != null:
			record["footprint/" + name] = footprint.footprint_size
		var slot := object.get_node_or_null("SeatSlot/ActionAnchor") as Marker2D
		if slot != null:
			record["seat_anchor/" + name] = slot.position
	for id in TREES:
		var tree := world.find_object(StringName(id)) as Node2D
		record["tree/" + id] = tree.position
	for name in MARKERS:
		record["marker/" + name] = (world.get_node("Spawns/" + name) as Marker2D).position
	var visitor := world.get_node("DepthSortedLayer/Characters/Visitor") as HardeningActor
	record["visitor/root"] = visitor.position
	record["visitor/collision_radius"] = ((visitor.get_node("CollisionShape2D") as CollisionShape2D).shape as CircleShape2D).radius
	world.queue_free()
	await process_frame
	return record
