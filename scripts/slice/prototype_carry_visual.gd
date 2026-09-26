class_name PrototypeCarryVisual
extends Node2D
## Temporary cup placeholder whose depth and movement follow Mochi's actor root.

var worker: SliceWorker
@export var carry_anchor: Marker2D


func _ready() -> void:
	worker = get_parent().get_node_or_null("SliceWorker") as SliceWorker
	visible = false
	if worker != null:
		worker.state_changed.connect(_on_worker_state_changed)
		_sync_visibility(worker.state)
	_sync_anchor()


func _process(_delta: float) -> void:
	if visible:
		_sync_anchor()


func _sync_anchor() -> void:
	if carry_anchor != null:
		position = carry_anchor.position
		scale = carry_anchor.scale


func _on_worker_state_changed(next_state: SliceWorker.State) -> void:
	_sync_visibility(next_state)


func _sync_visibility(next_state: SliceWorker.State) -> void:
	visible = next_state in [SliceWorker.State.WALKING_TO_SERVE, SliceWorker.State.READY_TO_SERVE, SliceWorker.State.SERVING]
	_sync_anchor()
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	var cup := PackedVector2Array([Vector2(0.0, 0.0), Vector2(22.0, 0.0), Vector2(18.0, 25.0), Vector2(4.0, 25.0)])
	draw_colored_polygon(cup, Color("#fff4dc"))
	draw_polyline(PackedVector2Array([cup[0], cup[1], cup[2], cup[3], cup[0]]), Color("#594033"), 2.0)
	draw_rect(Rect2(4.0, 7.0, 14.0, 4.0), Color("#9a5338"), true)
	draw_line(Vector2(22.0, 6.0), Vector2(28.0, 6.0), Color("#594033"), 2.0)
	draw_line(Vector2(28.0, 6.0), Vector2(28.0, 17.0), Color("#594033"), 2.0)
	draw_line(Vector2(28.0, 17.0), Vector2(20.0, 17.0), Color("#594033"), 2.0)
