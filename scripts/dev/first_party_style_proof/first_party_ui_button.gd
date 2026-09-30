extends Button
## One DEV button family; text remains runtime-owned.

const SHEET := preload("res://assets/first_party/storybook_mini_pack_001/normalized/interaction_button_states.png")


func _ready() -> void:
	custom_minimum_size = Vector2(92, 52)
	for state in ["normal", "pressed", "disabled"]:
		var index := ["normal", "pressed", "disabled"].find(state)
		var region := AtlasTexture.new()
		region.atlas = SHEET
		region.region = Rect2(index * 320, 0, 320, 128)
		var style := StyleBoxTexture.new()
		style.texture = region
		style.texture_margin_left = 40.0
		style.texture_margin_right = 40.0
		style.texture_margin_top = 24.0
		style.texture_margin_bottom = 24.0
		add_theme_stylebox_override(state, style)
	add_theme_color_override("font_color", Color("#173f3a"))
	add_theme_color_override("font_pressed_color", Color("#fff5dc"))
