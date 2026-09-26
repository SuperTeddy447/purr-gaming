class_name HomeSpatialRouteDebug
extends Node2D
## Development-only route/foot-pivot view; deliberately absent from normal play.

@export var slice_controller: VerticalSliceController
@export var spatial_routes: HomeSpatialRoutes
@export var debug_overlay: DebugOverlay


func _ready() -> void:
	visible = false
	if debug_overlay != null:
		debug_overlay.master_debug_toggled.connect(_on_debug_toggled)
		_on_debug_toggled(debug_overlay.master_debug_active)


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _on_debug_toggled(enabled: bool) -> void:
	visible = enabled
	queue_redraw()


func _draw() -> void:
	if not visible or slice_controller == null or spatial_routes == null:
		return
	var seat_id: StringName = slice_controller.active_seat_id
	if seat_id == &"":
		seat_id = GameplayID.SEAT_MAIN_A
	var idle: Vector2 = slice_controller.get_marker_position(GameplayID.WORKER_IDLE)
	var coffee: Vector2 = slice_controller.get_marker_position(GameplayID.STATION_COFFEE)
	var serve: Vector2 = slice_controller.get_marker_position(GameplayID.COUNTER_SERVE)
	var worker_path: Array[Vector2] = [idle, coffee]
	worker_path.append_array(spatial_routes.worker_to_service(seat_id, serve))
	_draw_path(worker_path, Color(0.32, 1.0, 0.56, 0.9), "WORKER")
	var customer_path: Array[Vector2] = [slice_controller.get_marker_position(GameplayID.CUSTOMER_SPAWN)]
	customer_path.append_array(spatial_routes.customer_to_seat(seat_id,
		slice_controller.customer_entry_waypoint.global_position,
		slice_controller.customer_aisle_waypoint.global_position,
		slice_controller.get_marker_position(seat_id)))
	_draw_path(customer_path, Color(0.32, 0.72, 1.0, 0.85), "CUSTOMER")
	if slice_controller.worker_actor != null:
		draw_circle(to_local(slice_controller.worker_actor.global_position), 7.0, Color("#a9efaa"))
	if slice_controller.customer != null:
		draw_circle(to_local(slice_controller.customer.global_position), 7.0, Color("#8ad6ff"))
	if slice_controller.worker_slice != null and slice_controller.worker_slice.mover.is_moving:
		draw_arc(to_local(slice_controller.worker_slice.mover.current_target), 14.0,
			0.0, TAU, 24, Color("#e7ff9a"), 3.0)
	if slice_controller.customer_mover != null and slice_controller.customer_mover.is_moving:
		draw_arc(to_local(slice_controller.customer_mover.current_target), 14.0,
			0.0, TAU, 24, Color("#d6e9ff"), 3.0)


func _draw_path(points: Array[Vector2], tint: Color, label: String) -> void:
	if points.size() < 2:
		return
	for index in range(1, points.size()):
		draw_line(to_local(points[index - 1]), to_local(points[index]), tint, 3.0)
	for point in points:
		draw_circle(to_local(point), 4.0, tint)
	draw_string(ThemeDB.fallback_font, to_local(points[0] + Vector2(13.0, -10.0)), label,
		HORIZONTAL_ALIGNMENT_LEFT, 100.0, 15, tint)
