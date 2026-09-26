class_name SliceCustomer
extends Node
## One-customer prototype state and world-space order bubble.

signal state_changed(state: State)

enum State { SPAWNING, WALKING_TO_SEAT, SEATED, WAITING_FOR_ORDER, WAITING_FOR_SERVICE, READY_FOR_SERVE, SERVED, LEAVING, COMPLETE }

var state: State = State.SPAWNING
var mover: SliceMover
var character: CharacterPlaceholder
var _order_bubble: PrototypeOrderBubble


func _ready() -> void:
	character = get_parent() as CharacterPlaceholder
	mover = character.get_node("SliceMover") as SliceMover


func set_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	if state == State.SEATED or state == State.WAITING_FOR_ORDER or state == State.WAITING_FOR_SERVICE or \
		state == State.READY_FOR_SERVE or state == State.SERVED:
		character.character_scale = 0.88
		character.idle_bob_enabled = false
	else:
		character.character_scale = 1.0
		character.idle_bob_enabled = true
	character.queue_redraw()
	state_changed.emit(state)


func state_name() -> String:
	return State.keys()[state]


func readable_state_name() -> String:
	match state:
		State.SPAWNING, State.WALKING_TO_SEAT:
			return "Entering / Walking to Seat"
		State.SEATED, State.WAITING_FOR_ORDER:
			return "Waiting for Order"
		State.WAITING_FOR_SERVICE:
			return "Waiting for Coffee"
		State.READY_FOR_SERVE:
			return "Ready for Serve"
		State.SERVED:
			return "Served"
		State.LEAVING:
			return "Leaving"
		State.COMPLETE:
			return "Gone"
	return "At Café"


func show_order_bubble() -> void:
	clear_order_bubble()
	_order_bubble = PrototypeOrderBubble.new()
	_order_bubble.name = "OrderBubble"
	character.add_child(_order_bubble)
	_order_bubble.set_ready_for_serve(state == State.READY_FOR_SERVE)


func set_order_ready(is_ready: bool) -> void:
	if is_instance_valid(_order_bubble):
		_order_bubble.set_ready_for_serve(is_ready)


func clear_order_bubble() -> void:
	if is_instance_valid(_order_bubble):
		_order_bubble.queue_free()
	_order_bubble = null
