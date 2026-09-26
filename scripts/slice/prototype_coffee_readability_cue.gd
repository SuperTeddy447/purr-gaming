class_name PrototypeCoffeeReadabilityCue
extends Node2D
## World-space workflow callouts above the counter. The worker and station remain in their locked depth layers.

@export var slice_controller: VerticalSliceController
@export var station_slot: Node2D

var _pulse: float = 0.0


func cue_kind() -> StringName:
	if slice_controller == null or slice_controller.worker_slice == null:
		return &"none"
	if slice_controller.active_order_id != &"" and slice_controller.customer_slice != null \
		and slice_controller.customer_slice.state == SliceCustomer.State.WAITING_FOR_SERVICE \
		and slice_controller.worker_slice.state == SliceWorker.State.IDLE:
		return &"tap_station"
	match slice_controller.worker_slice.state:
		SliceWorker.State.PREPARING_COFFEE:
			return &"brewing"
		SliceWorker.State.WALKING_TO_SERVE, SliceWorker.State.READY_TO_SERVE:
			return &"coffee_ready"
		SliceWorker.State.SERVING:
			return &"serving"
	return &"none"


func _process(delta: float) -> void:
	if slice_controller == null or slice_controller.worker_slice == null or station_slot == null:
		return
	_pulse += delta * 3.5
	queue_redraw()


func _draw() -> void:
	if slice_controller == null or slice_controller.worker_slice == null or station_slot == null:
		return
	var worker: SliceWorker = slice_controller.worker_slice
	if cue_kind() == &"tap_station":
		var station_prompt: Vector2 = to_local(station_slot.global_position + Vector2(0.0, -150.0))
		_draw_plate(station_prompt, "TAP ESPRESSO", Color("#f6d080"))
	elif cue_kind() == &"brewing":
		# Offset beside the station so the callout does not cover Mochi's face.
		var station: Vector2 = to_local(station_slot.global_position + Vector2(-130.0, -155.0))
		_draw_plate(station, "BREWING", Color("#f6d080"))
		var progress: float = clampf(worker.action_progress(), 0.0, 1.0)
		draw_rect(Rect2(station + Vector2(-76.0, 23.0), Vector2(152.0, 9.0)), Color("#244039"), true)
		draw_rect(Rect2(station + Vector2(-74.0, 25.0), Vector2(148.0 * progress, 5.0)), Color("#f6d080"), true)
		for index in range(3):
			var steam_x: float = station.x - 23.0 + float(index) * 23.0
			var steam_y: float = station.y - 33.0 - 4.0 * sin(_pulse + float(index))
			draw_arc(Vector2(steam_x, steam_y), 7.0, PI, TAU, 12, Color("#fff4dc"), 2.0)
	elif cue_kind() in [&"coffee_ready", &"serving"]:
		var carry: Vector2 = to_local(slice_controller.worker_actor.global_position + Vector2(0.0, -185.0))
		_draw_plate(carry, "SERVING" if cue_kind() == &"serving" else "COFFEE READY", Color("#a9df9b"), true)


func _draw_plate(center: Vector2, label: String, accent: Color, cup_icon: bool = false) -> void:
	var bounds := Rect2(center + Vector2(-82.0, -22.0), Vector2(164.0, 40.0))
	draw_rect(bounds, Color(0.13, 0.25, 0.21, 0.91), true)
	draw_rect(bounds, accent, false, 2.0)
	if cup_icon:
		draw_rect(Rect2(center + Vector2(-73.0, -10.0), Vector2(15.0, 17.0)), accent, true)
		draw_arc(center + Vector2(-57.0, -2.0), 5.0, -PI * 0.5, PI * 0.5, 10, accent, 2.0)
	else:
		draw_circle(center + Vector2(-65.0, -2.0), 5.0 + sin(_pulse) * 1.2, accent)
	draw_string(ThemeDB.fallback_font, center + Vector2(-52.0, 5.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, 125.0, 16, Color("#fff9e8"))
