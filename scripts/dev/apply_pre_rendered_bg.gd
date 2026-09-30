@tool
extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	print("Applying pre-rendered background to authoring lab...")
	var packed = load("res://scenes/dev/home_v3_world_authoring_lab.tscn")
	var scene = packed.instantiate()
	
	var arch = scene.get_node("Architecture")
	
	# Add the background
	var bg = Sprite2D.new()
	bg.name = "PreRenderedArt"
	bg.texture = load("res://assets/textures/backgrounds/cafe_background.jpg")
	bg.centered = false
	# Calculations from capture:
	# viewport 539x959, zoom 0.84, camera at 320, 650
	bg.scale = Vector2(1.0 / 0.84, 1.0 / 0.84)
	bg.position = Vector2(320.0 - (539.0 / 0.84) / 2.0, 650.0 - (959.0 / 0.84) / 2.0)
	bg.z_index = -5 # Just above the old debug floor
	
	arch.add_child(bg)
	bg.owner = scene
	
	# Hide the old debug floor drawing
	if arch.has_node("Floor"):
		arch.get_node("Floor").visible = false
	
	# Make all world objects purely invisible collision/depth masks
	var objs = scene.get_node("DepthSortedLayer/WorldObjects")
	for child in objs.get_children():
		if child is Node2D:
			# If we set modulate alpha to 0, they become invisible
			# but still affect Y-sort and navigation!
			child.modulate = Color(1, 1, 1, 0)
			
	# Save the updated scene
	var new_packed = PackedScene.new()
	new_packed.pack(scene)
	ResourceSaver.save(new_packed, "res://scenes/dev/home_v3_world_authoring_lab.tscn")
	print("Successfully applied background and hid debug objects!")
	quit()
