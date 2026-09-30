extends HardeningWorldObject
## Reusable semantic chair: existing footprint/SeatSlot, authored visual direction.

@export_enum("n", "ne", "e", "se", "s", "sw", "w", "nw") var direction := "s"
const DIRECTIONS := ["n", "ne", "e", "se", "s", "sw", "w", "nw"]
const SHEET := preload("res://assets/first_party/storybook_mini_pack_001/normalized/chair_directions.png")


func _ready() -> void:
	set_direction(direction)


func set_direction(value: String) -> void:
	if not DIRECTIONS.has(value):
		push_error("Unsupported first-party chair direction: " + value)
		return
	direction = value
	var visual := get_node_or_null("VisualRoot/Sprite2D") as Sprite2D
	if visual == null:
		return
	var region := AtlasTexture.new()
	region.atlas = SHEET
	region.region = Rect2(DIRECTIONS.find(value) * 384, 0, 384, 384)
	visual.texture = region
	set_meta("visual_direction", value)
	set_meta("visual_family", "willicat_home_storybook_v1")
