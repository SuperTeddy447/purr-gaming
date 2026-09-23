class_name DynamicSign
extends Control
## Reusable dynamic sign surface component for runtime text display.
## Encapsulates text rendering, safe text area, font sizing, and alignment.
## Does NOT hardcode coordinates or room-specific content.

@export_group("Sign Identification")
@export var sign_id: StringName = &""

@export_group("Text Configuration")
## Debug placeholder text displayed only during development/testing.
@export var debug_placeholder_text: String = ""
@export var font_size: int = 16
@export var font_color: Color = Color(0.95, 0.95, 0.92, 1.0)
@export var text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER
@export var vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER
@export var autowrap_mode: TextServer.AutowrapMode = TextServer.AUTOWRAP_WORD_SMART

@export_group("Debug Visualization")
@export var show_debug_surface: bool = false:
	set(value):
		show_debug_surface = value
		queue_redraw()

var _label: Label


func _ready() -> void:
	# Ensure mouse input passes through sign to the world/camera
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_label()
	if not debug_placeholder_text.is_empty():
		set_text(debug_placeholder_text)


func _setup_label() -> void:
	if _label == null:
		_label = Label.new()
		_label.name = "TextLabel"
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(_label)

	_label.horizontal_alignment = text_alignment
	_label.vertical_alignment = vertical_alignment
	_label.autowrap_mode = autowrap_mode
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", font_color)


## Sets runtime sign text dynamically.
func set_text(new_text: String) -> void:
	if _label == null:
		_setup_label()
	_label.text = new_text


## Retrieves current sign text.
func get_text() -> String:
	return _label.text if _label != null else ""


## Clears sign text.
func clear_text() -> void:
	if _label != null:
		_label.text = ""


func _draw() -> void:
	if show_debug_surface:
		var rect: Rect2 = Rect2(Vector2.ZERO, size)
		draw_rect(rect, Color(0.2, 0.6, 1.0, 0.18), true)
		draw_rect(rect, Color(0.2, 0.6, 1.0, 0.8), false, 1.5)
		draw_string(
			ThemeDB.fallback_font,
			Vector2(4, -4),
			"[%s]" % String(sign_id),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			11,
			Color(0.4, 0.8, 1.0, 0.9)
		)
