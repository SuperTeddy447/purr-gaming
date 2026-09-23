class_name GameplayMarker
extends Marker2D
## Specialized Marker2D node with semantic ID, category, and debug visualization.
## Easy to adjust directly in the Godot 2D editor without altering gameplay logic.

@export_group("Identification")
@export var marker_id: StringName = &""
@export var category: StringName = &"general"
@export var display_name: String = ""

@export_group("Debug Visuals")
@export var gizmo_color: Color = Color(0.2, 0.9, 0.4, 0.9)
@export var gizmo_radius: float = 14.0
@export var show_debug_gizmo: bool = false:
	set(value):
		show_debug_gizmo = value
		queue_redraw()


func _draw() -> void:
	if not show_debug_gizmo:
		return

	# Draw concentric marker target matching the spatial overlay specification
	draw_circle(Vector2.ZERO, gizmo_radius, Color(gizmo_color.r, gizmo_color.g, gizmo_color.b, 0.25))
	draw_arc(Vector2.ZERO, gizmo_radius, 0.0, TAU, 24, gizmo_color, 2.0)
	draw_circle(Vector2.ZERO, gizmo_radius * 0.35, Color(1.0, 1.0, 1.0, 0.95))

	var label_text: String = display_name if not display_name.is_empty() else String(marker_id)
	if not label_text.is_empty():
		draw_string(
			ThemeDB.fallback_font,
			Vector2(-gizmo_radius * 2.0, -gizmo_radius - 4.0),
			label_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			gizmo_radius * 4.0,
			11,
			gizmo_color
		)
