@tool
extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	print("Aligning layout to match proof_v1_3...")
	var packed = load("res://scenes/dev/home_v3_world_authoring_lab.tscn")
	var scene = packed.instantiate()
	
	var objs = scene.get_node("DepthSortedLayer/WorldObjects")
	var chars = scene.get_node("DepthSortedLayer/Characters")
	
	# Service Zone (Top Left / Top Center)
	var service = objs.get_node("CounterServiceZone")
	# Align back wall items
	service.get_node("EspressoStation").position = Vector2(300, 180)
	service.get_node("GrinderStation").position = Vector2(450, 180)
	# Align front counter items
	service.get_node("POSStation").position = Vector2(120, 300)
	service.get_node("PastryCase").position = Vector2(280, 300)
	service.get_node("CounterShell").position = Vector2(200, 300)
	
	# Table A (Mid Left)
	objs.get_node("TableA").position = Vector2(200, 520)
	objs.get_node("ChairA").position = Vector2(100, 540) # Left of table
	objs.get_node("ChairB").position = Vector2(300, 540) # Right of table
	
	# Table B (Mid Right, slightly lower)
	objs.get_node("TableB").position = Vector2(480, 680)
	objs.get_node("ChairC").position = Vector2(380, 700) # Left
	objs.get_node("ChairD").position = Vector2(580, 700) # Right
	
	# Window Perch (Mid Right)
	objs.get_node("WindowPerch").position = Vector2(560, 380)
	
	# Cat Bed (Mid-Lower Left)
	objs.get_node("CatBed").position = Vector2(120, 750)
	
	# Plant & Scratch Post (Mid-Lower Right - matching V1.3 AI hallucination which user liked)
	objs.get_node("Plant").position = Vector2(540, 850)
	objs.get_node("ScratchPost").position = Vector2(460, 870)
	
	# Entrance
	objs.get_node("EntranceDoor").position = Vector2(320, 1080)
	objs.get_node("WaitingSpot").position = Vector2(320, 950)
	
	# Characters
	chars.get_node("Worker").position = Vector2(250, 230) # Behind counter
	chars.get_node("CustomerA").position = Vector2(320, 1000) # Entering
	chars.get_node("CustomerB").position = Vector2(200, 600) # Near Table A
	chars.get_node("CatA").position = Vector2(120, 780) # Near bed
	chars.get_node("CatB").position = Vector2(520, 420) # Near window perch
	chars.get_node("CatC").position = Vector2(320, 750) # Walking in center
	
	var new_packed = PackedScene.new()
	new_packed.pack(scene)
	ResourceSaver.save(new_packed, "res://scenes/dev/home_v3_world_authoring_lab.tscn")
	print("Layout aligned and saved!")
	quit()
