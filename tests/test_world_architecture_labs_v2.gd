extends SceneTree
## Reusable scene ownership and semantic navigation acceptance for both layouts.

const LABS := [
	"res://scenes/dev/world_architecture_lab_a.tscn",
	"res://scenes/dev/world_architecture_lab_b.tscn",
]
const EXPECTED := {
	"Worker": [&"worker_idle", &"coffee_action", &"serve_point", &"worker_idle"],
	"Customer": [&"entrance_spawn", &"order_point", &"seat", &"entrance_exit"],
	"AmbientCat": [&"cat_idle", &"cat_rest", &"cat_sniff", &"cat_idle"],
}

var _valid := true
var _positions: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for scene_path in LABS:
		var world := (load(scene_path) as PackedScene).instantiate() as LabWorld
		root.add_child(world)
		await physics_frame
		await physics_frame
		_check(world.get_node("DepthSortedLayer").y_sort_enabled, "Depth layer lost Y-sort")
		_check(world.get_node("DepthSortedLayer/WorldObjects").y_sort_enabled,
			"Nested objects lost Y-sort")
		var counter := world.get_node("DepthSortedLayer/WorldObjects/CounterStation") as Node2D
		_check(counter.y_sort_enabled, "Counter front not in local Y-sort")
		_check((counter.get_node("VisualBack") as CanvasItem).z_index < 0,
			"Counter back visual not behind actors")
		_check((counter.get_node("FrontOccluder") as CanvasItem).z_index == 0,
			"Counter front uses a z-index override")
		var positions := {
			"counter": counter.position,
			"table": (world.get_node("DepthSortedLayer/WorldObjects/TableRound") as Node2D).position,
			"bed": (world.get_node("DepthSortedLayer/WorldObjects/CatBed") as Node2D).position,
		}
		_positions.append(positions)
		for tuple in [
			["CounterStation", "CoffeeAction", &"coffee_action"],
			["CounterStation", "WorkerIdle", &"worker_idle"],
			["CounterStation", "OrderPoint", &"order_point"],
			["CounterStation", "ServePoint", &"serve_point"],
			["ChairA", "SeatAnchor", &"seat"],
			["CatBed", "RestAnchor", &"cat_rest"],
			["Plant", "SniffAnchor", &"cat_sniff"],
			["TableRound", "TableApproach", &"table_approach"],
		]:
			var object := world.get_node("DepthSortedLayer/WorldObjects/%s" % tuple[0]) as Node2D
			var anchor := object.get_node(tuple[1]) as Marker2D
			_check(world.find_destination(tuple[2]) == anchor, "Semantic lookup failed: %s" % tuple[2])
			var before := anchor.global_position
			object.position += Vector2(11, -7)
			_check(anchor.global_position.is_equal_approx(before + Vector2(11, -7)),
				"Object move did not move %s" % tuple[2])
			object.position -= Vector2(11, -7)
		var objects := world.get_node("DepthSortedLayer/WorldObjects")
		for name in ["CounterStation", "TableRound", "ChairA", "CatBed", "Plant"]:
			_check((objects.get_node(name) as Node).scene_file_path.begins_with("res://scenes/dev/world_lab/"),
				"Object is not a reusable PackedScene: %s" % name)
		var nav := world.get_node("Navigation") as NavigationRegion2D
		_check(nav.navigation_polygon != null and nav.navigation_polygon.get_polygon_count() > 0,
			"No walkable navigation polygon")
		for frame in 1200:
			var report := world.route_report()
			if report.size() == 3 and report["Worker"].complete and report["Customer"].complete \
					and report["AmbientCat"].complete:
				break
			await physics_frame
		var report := world.route_report()
		for role in EXPECTED:
			_check(report.has(role), "%s missing from %s" % [role, scene_path])
			if report.has(role):
				_check(report[role].complete and not report[role].failed, "%s did not complete %s" % [role, scene_path])
				_check(report[role].visited == EXPECTED[role], "%s visited wrong destinations" % role)
				_check(report[role].path_queries == 3, "%s did not use navigation for every leg" % role)
		world.queue_free()
		await process_frame
	_check(_positions.size() == 2 and _positions[0] != _positions[1], "Lab B did not relocate the map")
	var source := FileAccess.get_file_as_string("res://scripts/dev/world_lab/lab_actor.gd")
	_check(source.contains("_world.find_destination("),
		"Generic actor behavior stopped resolving semantic destinations")
	if _valid:
		print("--- WORLD ARCHITECTURE LABS V2 PASSED ---")
	quit(0 if _valid else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_valid = false
		push_error(message)
