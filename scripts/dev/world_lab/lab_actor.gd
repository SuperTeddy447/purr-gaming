extends CharacterBody2D
## Same semantic movement behavior in both labs. No map-specific coordinates.

signal destination_reached(semantic_id: StringName)
signal itinerary_completed(role_name: StringName)

@export_enum("customer", "worker", "cat") var role_name := "customer"
@export_range(30.0, 600.0) var move_speed := 250.0

var visited: Array[StringName] = []
var route_complete := false
var failed := false
var path_queries := 0
var _world: LabWorld
var _itinerary: Array[StringName] = []
var _current_destination: Marker2D
var _current_id: StringName = &""

@onready var _navigation: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	_navigation.path_desired_distance = 5.0
	_navigation.target_desired_distance = 7.0
	set_physics_process(false)


func start_route(world: LabWorld) -> void:
	_world = world
	var start_id: StringName
	match role_name:
		"customer":
			start_id = &"entrance_spawn"
			_itinerary = [&"order_point", &"seat", &"entrance_exit"]
		"worker":
			start_id = &"worker_idle"
			_itinerary = [&"coffee_action", &"serve_point", &"worker_idle"]
		"cat":
			start_id = &"cat_idle"
			_itinerary = [&"cat_rest", &"cat_sniff", &"cat_idle"]
	var start: Marker2D = _world.find_destination(start_id)
	if start == null:
		_fail("missing start " + String(start_id))
		return
	global_position = start.global_position
	visited.append(start_id)
	_begin_next()


func _begin_next() -> void:
	if _itinerary.is_empty():
		route_complete = true
		set_physics_process(false)
		itinerary_completed.emit(StringName(role_name))
		print("WORLD_LAB %s complete: %s" % [role_name, str(visited)])
		return
	_current_id = _itinerary.pop_front()
	_current_destination = _world.find_destination(_current_id)
	if _current_destination == null:
		_fail("missing destination " + String(_current_id))
		return
	_navigation.target_position = _current_destination.global_position
	path_queries += 1
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	if _current_destination == null:
		return
	if global_position.distance_to(_current_destination.global_position) <= 8.0:
		global_position = _current_destination.global_position
		visited.append(_current_id)
		destination_reached.emit(_current_id)
		_begin_next()
		return
	if NavigationServer2D.map_get_iteration_id(_navigation.get_navigation_map()) == 0:
		return
	if _navigation.is_navigation_finished():
		_fail("navigation ended before " + String(_current_id))
		return
	var next: Vector2 = _navigation.get_next_path_position()
	velocity = global_position.direction_to(next) * move_speed
	move_and_slide()
	queue_redraw()


func _fail(message: String) -> void:
	failed = true
	set_physics_process(false)
	push_error("WORLD_LAB %s: %s" % [role_name, message])


func _draw() -> void:
	var color := Color("#8babc0")
	match role_name:
		"worker": color = Color("#d89a68")
		"cat": color = Color("#a89dc5")
	draw_ellipse_shape(Vector2(0, -2), Vector2(19, 7), Color(0.25, 0.20, 0.17, 0.24))
	draw_circle(Vector2(0, -35), 19, color)
	draw_circle(Vector2(0, -63), 17, color.lightened(0.13))
	draw_circle(Vector2(-6, -65), 2.5, Color("#342b27"))
	draw_circle(Vector2(6, -65), 2.5, Color("#342b27"))
	draw_string(ThemeDB.fallback_font, Vector2(-30, -87), role_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 90, 12, Color("#322b26"))


func draw_ellipse_shape(center: Vector2, radii: Vector2, fill: Color) -> void:
	var points := PackedVector2Array()
	for i in 20:
		var angle := TAU * float(i) / 20.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, fill)
