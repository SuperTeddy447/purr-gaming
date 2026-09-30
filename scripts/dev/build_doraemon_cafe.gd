@tool
extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	print("Building Doraemon-style Cafe Scene...")
	var root = Node2D.new()
	root.name = "DoraemonStyleCafe"
	root.y_sort_enabled = true
	
	# Background Sprite (Pre-rendered art)
	var bg = Sprite2D.new()
	bg.name = "PreRenderedBackground"
	bg.texture = load("res://assets/textures/backgrounds/cafe_background.jpg")
	# Align the image to the center or top-left. Let's do top-left.
	bg.centered = false
	bg.z_index = -10 # Push far behind the Y-Sort
	root.add_child(bg)
	
	# Y-Sort Layer for the Characters and Fake Collisions
	var y_sort_layer = Node2D.new()
	y_sort_layer.name = "YSortLayer"
	y_sort_layer.y_sort_enabled = true
	root.add_child(y_sort_layer)
	
	# Add a Player Placeholder
	var player = Sprite2D.new()
	player.name = "PlayerPlaceholder"
	player.y_sort_enabled = true
	player.position = Vector2(270, 750) # In the middle of the floor roughly
	var tex = PlaceholderTexture2D.new()
	tex.size = Vector2(40, 80)
	player.texture = tex
	player.modulate = Color("#e98074")
	player.offset = Vector2(0, -40)
	# Add script to move the player
	var script = GDScript.new()
	script.source_code = """
extends Sprite2D
var speed = 200.0
func _process(delta):
	var dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): dir.x += 1
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S): dir.y += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W): dir.y -= 1
	if dir != Vector2.ZERO:
		position += dir.normalized() * speed * delta
"""
	script.reload()
	player.set_script(script)
	y_sort_layer.add_child(player)
	player.owner = root # Need to set owner for packed scene
	
	# Now, we add "Occluders" or "Depth Objects" for the tables and counters in the pre-rendered image.
	# By placing invisible Y-Sorted nodes at the exact coordinates of the furniture, the player will walk behind them!
	
	_add_depth_object(y_sort_layer, root, "CounterDepth", Vector2(270, 310), Vector2(400, 150))
	_add_depth_object(y_sort_layer, root, "TableA_Depth", Vector2(170, 520), Vector2(100, 80))
	_add_depth_object(y_sort_layer, root, "TableB_Depth", Vector2(380, 670), Vector2(100, 80))
	_add_depth_object(y_sort_layer, root, "Plant_Depth", Vector2(420, 480), Vector2(80, 80))
	
	# Save the scene
	var packed = PackedScene.new()
	# Set owners
	bg.owner = root
	y_sort_layer.owner = root
	
	packed.pack(root)
	ResourceSaver.save(packed, "res://scenes/dev/doraemon_style_cafe.tscn")
	print("Scene saved to res://scenes/dev/doraemon_style_cafe.tscn")
	quit()

func _add_depth_object(parent: Node, root: Node, obj_name: String, pos: Vector2, size: Vector2):
	var obj = Node2D.new()
	obj.name = obj_name
	obj.position = pos
	obj.y_sort_enabled = true
	
	# Create an invisible (or semi-transparent debug) shape for the object
	var sprite = Sprite2D.new()
	sprite.name = "DepthSprite"
	var tex = PlaceholderTexture2D.new()
	tex.size = size
	sprite.texture = tex
	# Make it invisible during gameplay, but slightly visible in editor so we can see it
	sprite.modulate = Color(0, 1, 0, 0.3) 
	sprite.offset = Vector2(0, -size.y / 2.0)
	
	obj.add_child(sprite)
	parent.add_child(obj)
	
	obj.owner = root
	sprite.owner = root
