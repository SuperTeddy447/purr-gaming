extends Node2D
## Runtime-only inspection drawing: real nav path, footprints, owned slot anchors.


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	var world := get_parent() as HardeningWorld
	if world == null:
		return
	var map := world.navigation.get_navigation_map()
	var start := (world.actors.get_node("CustomerA") as HardeningActor).global_position
	var end := (world.get_node("CrossTableTarget") as Marker2D).global_position
	var path := NavigationServer2D.map_get_path(map, start, end, true)
	for i in range(1, path.size()):
		draw_line(path[i - 1], path[i], Color("#2aa9cf"), 3.0)
	for root in [world.objects, world.event_layer]:
		if root == world.event_layer and not world.event_active:
			continue
		_draw_descendants(root)


func _draw_descendants(node: Node) -> void:
	if node is HardeningFootprint:
		var outline := (node as HardeningFootprint).navigation_outline()
		for i in outline.size():
			draw_line(outline[i], outline[(i + 1) % outline.size()], Color("#e25b43"), 2.0)
	if node is HardeningInteractionSlot:
		var slot := node as HardeningInteractionSlot
		var approach := slot.approach_anchor().global_position
		var action := slot.action_anchor().global_position
		draw_circle(approach, 5, Color("#49b6cf"))
		draw_circle(action, 5, Color("#e4b55f"))
		draw_line(approach, action, Color("#777065"), 1.5)
		draw_string(ThemeDB.fallback_font, action + Vector2(7, -8), String(slot.action_type),
			HORIZONTAL_ALIGNMENT_LEFT, 100, 10, Color("#52423a"))
	for child in node.get_children():
		_draw_descendants(child)
