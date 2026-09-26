class_name PrototypePreparationFeedback
extends Node2D
## Small machine-side brew progress cue and future FX attachment point.

@export var debug_overlay: DebugOverlay

var worker: SliceWorker
var coffee_fx_attachment: Marker2D


func _ready() -> void:
	position = Vector2(0.0, -78.0)
	visible = false
	coffee_fx_attachment = Marker2D.new()
	coffee_fx_attachment.name = "CoffeeFXAttachment"
	coffee_fx_attachment.position = Vector2(0.0, 24.0)
	add_child(coffee_fx_attachment)
	worker = get_tree().get_first_node_in_group(&"prototype_worker") as SliceWorker
	if worker == null:
		call_deferred("_find_worker")
	set_process(true)


func _find_worker() -> void:
	worker = get_tree().get_first_node_in_group(&"prototype_worker") as SliceWorker


func _process(_delta: float) -> void:
	var preparing: bool = worker != null and worker.state == SliceWorker.State.PREPARING_COFFEE
	if visible != preparing:
		visible = preparing
	queue_redraw()


func _draw() -> void:
	if worker == null:
		return
	var center := Vector2.ZERO
	draw_arc(center, 22.0, 0.0, TAU, 32, Color(0.20, 0.16, 0.13, 0.35), 4.0)
	var progress: float = clampf(worker.action_progress(), 0.0, 1.0)
	draw_arc(center, 22.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 32, Color("#c07845"), 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(-36.0, 44.0), "BREWING", HORIZONTAL_ALIGNMENT_CENTER, 72.0, 12, Color("#4a3528"))
	if debug_overlay != null and debug_overlay.master_debug_active:
		draw_string(ThemeDB.fallback_font, Vector2(-28.0, 60.0), "%d%%" % roundi(progress * 100.0),
			HORIZONTAL_ALIGNMENT_CENTER, 56.0, 11, Color("#4a3528"))
