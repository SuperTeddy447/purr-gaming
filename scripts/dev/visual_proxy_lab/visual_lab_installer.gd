extends Node
## Visual comparison overlay; Home gameplay and base scene remain untouched.

const TABLE_SET := preload("res://scenes/dev/visual_proxy_lab/CafeTableSet2.tscn")


func _ready() -> void:
	var world := get_parent()
	for child in world.get_node("Architecture").get_children():
		if child is Sprite2D and child.texture != null and \
				String(child.texture.resource_path).ends_with("/seating_rug.png"):
			child.visible = false
	for names in [["TableA", "ChairA", "ChairB"], ["TableB", "ChairC", "ChairD"]]:
		var composition := TABLE_SET.instantiate()
		composition.name = "Directional" + names[0] + "Set"
		composition.table_name = names[0]
		composition.left_chair_name = names[1]
		composition.right_chair_name = names[2]
		add_child(composition)
		composition.bind(world)
