class_name LabWorld
extends Node2D
## Level owns placement and navigation; objects own their semantic child anchors.

var _destinations: Dictionary = {}
var _actors: Array[CharacterBody2D] = []
var depth_probe_step := 0


func _ready() -> void:
	_reindex_destinations()
	call_deferred("_start_lab")


func _reindex_destinations() -> void:
	_destinations.clear()
	_collect_destinations($DepthSortedLayer/WorldObjects)
	_collect_destinations($LevelAnchors)


func _collect_destinations(node: Node) -> void:
	if node is LabDestination:
		var semantic_id: StringName = (node as LabDestination).semantic_id
		if semantic_id != &"":
			if not _destinations.has(semantic_id):
				_destinations[semantic_id] = []
			_destinations[semantic_id].append(node)
	for child in node.get_children():
		_collect_destinations(child)


func find_destination(semantic_id: StringName, index: int = 0) -> Marker2D:
	var found: Array = _destinations.get(semantic_id, [])
	if index < 0 or index >= found.size():
		return null
	return found[index] as Marker2D


func _start_lab() -> void:
	await get_tree().physics_frame
	for child in $DepthSortedLayer.get_children():
		if child.has_method("start_route"):
			_actors.append(child as CharacterBody2D)
			child.start_route(self)


func route_report() -> Dictionary:
	var report := {}
	for actor in _actors:
		report[actor.name] = {"visited": actor.get("visited"), "complete": actor.get("route_complete"),
			"path_queries": actor.get("path_queries"), "failed": actor.get("failed")}
	return report


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		set_depth_probe((depth_probe_step % 4) + 1)
		get_viewport().set_input_as_handled()


func set_depth_probe(step: int) -> void:
	## Dev-only visual test. Neither production Home nor generic actor routing uses this.
	depth_probe_step = clampi(step, 1, 4)
	var worker := $DepthSortedLayer/Worker as CharacterBody2D
	var counter := $DepthSortedLayer/WorldObjects/CounterStation as Node2D
	var table := $DepthSortedLayer/WorldObjects/TableRound as Node2D
	worker.set_physics_process(false)
	match depth_probe_step:
		1: worker.global_position = counter.global_position + Vector2(0, -65)
		2: worker.global_position = counter.global_position + Vector2(0, 76)
		3: worker.global_position = table.global_position + Vector2(0, -55)
		4: worker.global_position = table.global_position + Vector2(0, 58)
	worker.queue_redraw()
	print("WORLD_LAB depth probe %d: worker feet %s" % [depth_probe_step, str(worker.global_position)])
