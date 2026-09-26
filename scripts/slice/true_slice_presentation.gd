class_name TrueSlicePresentation
extends Node
## Presentation adapter only: observes the existing Slice, never advances gameplay.

signal mochi_action_changed(action_id: StringName)
signal customer_action_changed(action_id: StringName)
signal slice_event(event_id: StringName)
signal coffee_prepare_progress(progress: float)
signal audio_cue(cue_id: StringName)
signal haptic_cue(cue_id: StringName)

@export var slice_controller: VerticalSliceController
@export var ambient_controller: LivingCafeAmbientController
@export var door_controller: PrototypeDoorController
@export var interaction_controller: HomeInteractionController
@export var mochi_animation_slot: Node2D
@export var debug_overlay: DebugOverlay

var mochi_action: StringName = &"idle"
var customer_action: StringName = &"none"
var _customer_source: SliceCustomer
var _progress_step: int = -1


func _ready() -> void:
	if slice_controller == null or ambient_controller == null or door_controller == null:
		push_error("True Slice presentation requires the existing Slice, ambience, and door controllers.")
		return
	slice_controller.lifecycle_event.connect(_on_lifecycle_event)
	slice_controller.worker_slice.state_changed.connect(_on_worker_state_changed)
	ambient_controller.ambient_changed.connect(_on_ambient_changed)
	door_controller.presentation_event.connect(_on_door_event)
	door_controller.threshold_crossed.connect(_on_threshold_crossed)
	if interaction_controller != null:
		interaction_controller.interaction_resolved.connect(_on_interaction_resolved)
	if debug_overlay != null:
		debug_overlay.master_debug_toggled.connect(slice_controller.worker_slice.set_debug_action_label_visible)
		slice_controller.worker_slice.set_debug_action_label_visible(debug_overlay.master_debug_active)
	if door_controller.state == PrototypeDoorController.State.OPENING:
		_on_door_event(&"door_open")
	elif door_controller.state == PrototypeDoorController.State.OPEN:
		_on_door_event(&"door_open_complete")
	_bind_customer()
	if slice_controller.customer_slice != null:
		_emit_slice_event(&"customer_enter")
	_on_worker_state_changed(slice_controller.worker_slice.state)


func _process(_delta: float) -> void:
	if slice_controller == null or slice_controller.worker_slice == null:
		return
	if slice_controller.worker_slice.state != SliceWorker.State.PREPARING_COFFEE:
		_progress_step = -1
		return
	var progress: float = slice_controller.worker_slice.action_progress()
	var step: int = clampi(floori(progress * 20.0), 0, 20)
	if step != _progress_step:
		_progress_step = step
		coffee_prepare_progress.emit(progress)


func _bind_customer() -> void:
	var current: SliceCustomer = slice_controller.customer_slice
	if current != null and _customer_source == current:
		return
	if is_instance_valid(_customer_source) and _customer_source.state_changed.is_connected(_on_customer_state_changed):
		_customer_source.state_changed.disconnect(_on_customer_state_changed)
	_customer_source = current
	if current != null:
		current.state_changed.connect(_on_customer_state_changed)
		_on_customer_state_changed(current.state)
	else:
		_set_customer_action(&"none")


func _on_worker_state_changed(state: SliceWorker.State) -> void:
	var next_action: StringName = &"idle"
	match state:
		SliceWorker.State.IDLE:
			var mochi: LivingCafeAmbientController.Agent = ambient_controller.agent_for(&"Mochi")
			if mochi != null and mochi.activity not in [&"IDLE", &"WORK_PRIORITY"]:
				next_action = &"walk" if mochi.activity == &"ROAM" else &"ambient_idle"
		SliceWorker.State.WALKING_TO_COFFEE:
			next_action = &"walk"
		SliceWorker.State.PREPARING_COFFEE:
			next_action = &"prepare_coffee"
		SliceWorker.State.WALKING_TO_SERVE, SliceWorker.State.READY_TO_SERVE:
			next_action = &"carry_coffee"
		SliceWorker.State.SERVING:
			next_action = &"serve"
		SliceWorker.State.RETURNING_TO_IDLE:
			next_action = &"return_idle"
	_set_mochi_action(next_action)
	if state == SliceWorker.State.PREPARING_COFFEE:
		_emit_slice_event(&"coffee_prepare_started")
		_audio(&"espresso_start")
		_audio(&"espresso_loop")
	elif state == SliceWorker.State.WALKING_TO_SERVE:
		_emit_slice_event(&"coffee_pickup")
		_audio(&"coffee_ready")
		_haptic(&"coffee_ready")
	elif state == SliceWorker.State.SERVING:
		_emit_slice_event(&"serve_started")


func _on_customer_state_changed(state: SliceCustomer.State) -> void:
	var next_action: StringName = &"enter"
	match state:
		SliceCustomer.State.WALKING_TO_SEAT: next_action = &"walk"
		SliceCustomer.State.SEATED, SliceCustomer.State.WAITING_FOR_ORDER: next_action = &"sit_wait"
		SliceCustomer.State.WAITING_FOR_SERVICE: next_action = &"order"
		SliceCustomer.State.READY_FOR_SERVE: next_action = &"order"
		SliceCustomer.State.SERVED: next_action = &"receive"
		SliceCustomer.State.LEAVING, SliceCustomer.State.COMPLETE: next_action = &"leave"
	_set_customer_action(next_action)


func _on_ambient_changed(cat_id: StringName, activity: StringName, _zone: StringName) -> void:
	if cat_id != &"Mochi" or slice_controller.worker_slice.state != SliceWorker.State.IDLE:
		return
	_set_mochi_action(&"walk" if activity == &"ROAM" else &"idle" if activity == &"IDLE" else &"ambient_idle")


func _on_lifecycle_event(event_name: StringName) -> void:
	match event_name:
		&"customer_spawned":
			_bind_customer()
			_emit_slice_event(&"customer_enter")
		&"order_created":
			_emit_slice_event(&"order_appear")
			_audio(&"order_appear")
		&"coffee_prepared":
			coffee_prepare_progress.emit(1.0)
			_emit_slice_event(&"coffee_prepare_completed")
			_audio(&"espresso_loop_stop")
		&"worker_serves":
			_emit_slice_event(&"coffee_served")
			_audio(&"serve")
			_haptic(&"serve_success")
			_set_customer_action(&"satisfied")
			_emit_slice_event(&"customer_satisfied")
			_audio(&"customer_satisfied")
		&"reward_granted":
			_emit_slice_event(&"reward")
			_audio(&"reward")
			_haptic(&"reward")
		&"customer_exited":
			_bind_customer()
			_emit_slice_event(&"customer_exit")


func _on_door_event(event_name: StringName) -> void:
	_emit_slice_event(event_name)
	if event_name in [&"door_open", &"door_close"]:
		_audio(event_name)


func _on_threshold_crossed(direction: StringName) -> void:
	_emit_slice_event(&"customer_threshold_entry" if direction == &"entry" else &"customer_threshold_exit")


func _on_interaction_resolved(_target_id: StringName, accepted: bool) -> void:
	if accepted:
		_haptic(&"valid_tap")


func _set_mochi_action(action_id: StringName) -> void:
	if mochi_action == action_id:
		return
	mochi_action = action_id
	if mochi_animation_slot != null and mochi_animation_slot.has_method("play_action"):
		mochi_animation_slot.call("play_action", action_id)
	else:
		_play_if_available(mochi_animation_slot, action_id)
	mochi_action_changed.emit(action_id)


func _set_customer_action(action_id: StringName) -> void:
	if customer_action == action_id:
		return
	customer_action = action_id
	customer_action_changed.emit(action_id)
	if slice_controller.customer != null:
		_play_if_available(slice_controller.customer.get_node_or_null("CustomerAnimationSlot") as Node2D, action_id)


func _play_if_available(slot: Node2D, action_id: StringName) -> void:
	if slot == null:
		return
	for child in slot.get_children():
		var sprite := child as AnimatedSprite2D
		if sprite != null and sprite.sprite_frames != null and sprite.sprite_frames.has_animation(action_id):
			sprite.play(action_id)
			return


func _emit_slice_event(event_id: StringName) -> void:
	slice_event.emit(event_id)


func _audio(cue_id: StringName) -> void:
	audio_cue.emit(cue_id)


func _haptic(cue_id: StringName) -> void:
	haptic_cue.emit(cue_id)
