class_name PrototypeCustomerReadabilityCue
extends Node2D
## Prototype-only customer state cue; never owns or advances gameplay state.

var customer: SliceCustomer
var _pulse: float = 0.0


func _ready() -> void:
	customer = get_parent().get_node_or_null("SliceCustomer") as SliceCustomer
	if customer != null:
		customer.state_changed.connect(_on_state_changed)
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	_pulse += delta * 3.2
	queue_redraw()


func _on_state_changed(next_state: SliceCustomer.State) -> void:
	visible = next_state != SliceCustomer.State.SPAWNING and next_state != SliceCustomer.State.COMPLETE
	queue_redraw()


func _draw() -> void:
	if customer == null or not visible:
		return
	var ready: bool = customer.state == SliceCustomer.State.READY_FOR_SERVE
	var ring_color: Color = Color("#78bd77") if ready else Color("#f6cf77")
	var alpha: float = 0.45 + 0.18 * sin(_pulse)
	draw_arc(Vector2(0.0, -5.0), 35.0 + 3.0 * sin(_pulse), 0.0, TAU, 48,
		Color(ring_color.r, ring_color.g, ring_color.b, alpha), 4.0 if ready else 2.5)
	var label: String = ""
	match customer.state:
		SliceCustomer.State.WALKING_TO_SEAT:
			label = "ARRIVING"
		SliceCustomer.State.SEATED, SliceCustomer.State.WAITING_FOR_ORDER:
			label = "WAITING"
		SliceCustomer.State.SERVED:
			label = "THANK YOU!"
		SliceCustomer.State.READY_FOR_SERVE:
			label = "SERVE TARGET"
		SliceCustomer.State.LEAVING:
			label = "LEAVING"
	if label == "":
		return
	var plate_y: float = -215.0 if customer.state == SliceCustomer.State.SERVED else -175.0
	if ready:
		plate_y = -215.0
	var plate := Rect2(-55.0, plate_y, 110.0, 31.0)
	draw_rect(plate, Color(0.14, 0.24, 0.20, 0.86), true)
	draw_string(ThemeDB.fallback_font, Vector2(-49.0, plate_y + 21.0), label,
		HORIZONTAL_ALIGNMENT_CENTER, 98.0, 15, Color("#fff4dc"))
