class_name HomeSpatialRoutes
extends Node2D
## Authored Home waypoints only. The Vertical Slice still owns every gameplay state.

@onready var counter_exit_rear: Marker2D = $CounterExitRear
@onready var counter_exit_front: Marker2D = $CounterExitFront
@onready var worker_floor_aisle: Marker2D = $WorkerFloorAisle
@onready var right_aisle: Marker2D = $RightAisle
@onready var service_a: Marker2D = $ServiceApproachA
@onready var service_b: Marker2D = $ServiceApproachB
@onready var service_c: Marker2D = $ServiceApproachC
@onready var service_d: Marker2D = $ServiceApproachD


func worker_to_service(seat_id: StringName, serve_point: Vector2) -> Array[Vector2]:
	var route: Array[Vector2] = [counter_exit_rear.global_position, counter_exit_front.global_position, serve_point]
	if seat_id != GameplayID.SEAT_MAIN_A:
		route.append(worker_floor_aisle.global_position)
	if seat_id == GameplayID.SEAT_MAIN_C:
		route.append(right_aisle.global_position)
	var approach: Marker2D = service_marker(seat_id)
	if approach != null:
		route.append(approach.global_position)
	return route


func worker_to_idle(seat_id: StringName, serve_point: Vector2, worker_idle: Vector2) -> Array[Vector2]:
	var route: Array[Vector2] = []
	if seat_id == GameplayID.SEAT_MAIN_C:
		route.append(right_aisle.global_position)
	if seat_id != GameplayID.SEAT_MAIN_A:
		route.append(worker_floor_aisle.global_position)
	route.append_array([serve_point, counter_exit_front.global_position,
		counter_exit_rear.global_position, worker_idle])
	return route


func customer_to_seat(seat_id: StringName, entry: Vector2, aisle: Vector2, seat: Vector2) -> Array[Vector2]:
	var route: Array[Vector2] = [entry, aisle]
	if seat_id == GameplayID.SEAT_MAIN_C:
		route.append(right_aisle.global_position)
	route.append(seat)
	return route


func customer_to_exit(seat_id: StringName, aisle: Vector2, entry: Vector2, exit: Vector2) -> Array[Vector2]:
	var route: Array[Vector2] = []
	if seat_id == GameplayID.SEAT_MAIN_C:
		route.append(right_aisle.global_position)
	route.append_array([aisle, entry, exit])
	return route


func service_marker(seat_id: StringName) -> Marker2D:
	match seat_id:
		GameplayID.SEAT_MAIN_A:
			return service_a
		GameplayID.SEAT_MAIN_B:
			return service_b
		GameplayID.SEAT_MAIN_C:
			return service_c
		GameplayID.SEAT_MAIN_D:
			return service_d
	return null
