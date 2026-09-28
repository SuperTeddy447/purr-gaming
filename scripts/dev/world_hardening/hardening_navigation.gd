class_name HardeningNavigation
extends NavigationRegion2D
## Room-owned navmesh, rebuilt from object-owned floor footprints.

signal rebuilt(revision: int)

@export var walkable_bounds := Rect2(20, 20, 480, 810)
@export_range(0.0, 32.0) var agent_clearance := 11.0

var revision := 0


func rebuild(objects_root: Node, event_root: Node = null) -> bool:
	var polygon := NavigationPolygon.new()
	polygon.agent_radius = agent_clearance
	polygon.cell_size = 2.0
	var a := walkable_bounds.position
	var b := walkable_bounds.end
	polygon.add_outline(PackedVector2Array([
		Vector2(a.x, a.y), Vector2(b.x, a.y),
		Vector2(b.x, b.y), Vector2(a.x, b.y),
	]))
	var geometry := NavigationMeshSourceGeometryData2D.new()
	_add_footprints(objects_root, geometry)
	if event_root != null and event_root.visible:
		_add_footprints(event_root, geometry)
	NavigationServer2D.bake_from_source_geometry_data(polygon, geometry)
	if polygon.get_polygon_count() == 0:
		push_error("Hardening navigation bake produced no walkable polygons")
		return false
	navigation_polygon = polygon
	revision += 1
	rebuilt.emit(revision)
	print("HARDENING nav revision=%d polygons=%d obstructions=%d" % [
		revision, polygon.get_polygon_count(), geometry.get_obstruction_outlines().size()])
	return true


func _add_footprints(node: Node, geometry: NavigationMeshSourceGeometryData2D) -> void:
	if node is HardeningFootprint:
		geometry.add_obstruction_outline((node as HardeningFootprint).navigation_outline())
	for child in node.get_children():
		_add_footprints(child, geometry)
