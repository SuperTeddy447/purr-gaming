extends Node2D
## Separate candidate FX attachment; reacts to the existing slice's brew lifecycle.

var steam_active: bool = false
var _elapsed: float = 0.0
var _station: Node2D


func _ready() -> void:
	var home: Node = get_parent().get_parent().get_parent()
	_station = home.get_node_or_null("World/BackDecorLayer/EspressoStationSlot") as Node2D
	var slice: VerticalSliceController = home.get_node_or_null("VerticalSliceController") as VerticalSliceController
	if slice != null:
		slice.lifecycle_event.connect(_on_lifecycle_event)


func _on_lifecycle_event(event_name: StringName) -> void:
	if event_name == &"worker_prepares":
		steam_active = true
		_elapsed = 0.0
	elif event_name in [&"coffee_prepared", &"worker_serves", &"customer_exited"]:
		steam_active = false
	queue_redraw()


func _process(delta: float) -> void:
	if steam_active:
		_elapsed += delta
		queue_redraw()


func _draw() -> void:
	if not steam_active or _station == null:
		return
	var origin: Vector2 = to_local(_station.global_position) + Vector2(12.0, -95.0)
	for trail in 3:
		var points := PackedVector2Array()
		for step in 7:
			var rise: float = float(step) * 7.0
			var drift: float = sin(_elapsed * 2.5 + float(trail) * 1.7 + float(step) * 0.7) * 4.0
			points.append(origin + Vector2(float(trail - 1) * 10.0 + drift, -rise))
		draw_polyline(points, Color(0.98, 0.94, 0.84, 0.35), 2.0, true)
