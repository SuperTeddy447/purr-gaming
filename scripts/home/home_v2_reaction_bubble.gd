class_name HomeV2ReactionBubble
extends Node2D
## Character-local, non-interactive placeholder for semantic feline reactions.

const SYMBOLS := {
	&"surprise": "!",
	&"question": "?",
	&"heart": "♥",
	&"sleep": "Z",
	&"story": "…",
}

var reaction: StringName = &""
var _remaining: float = 0.0


func show_reaction(kind: StringName, duration: float = 1.5) -> void:
	if not SYMBOLS.has(kind):
		push_warning("Unknown feline reaction: %s" % String(kind))
		return
	reaction = kind
	_remaining = maxf(duration, 0.01)
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	_remaining -= delta
	if _remaining <= 0.0:
		visible = false
		reaction = &""
		queue_redraw()


func _draw() -> void:
	if reaction == &"":
		return
	draw_circle(Vector2.ZERO, 21.0, Color(0.99, 0.94, 0.82, 0.96))
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color(0.23, 0.39, 0.35), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(-9.0, 10.0), SYMBOLS[reaction],
		HORIZONTAL_ALIGNMENT_CENTER, 18.0, 26, Color(0.20, 0.35, 0.32))
