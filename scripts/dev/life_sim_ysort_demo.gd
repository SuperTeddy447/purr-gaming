extends Node2D

var player: Sprite2D
var speed = 200.0

func _ready() -> void:
	# 1. Enable Y-Sort on the main root so all children overlap correctly based on Y-position
	y_sort_enabled = true
	
	# 2. Setup a background floor (drawn underneath everything, no Y-sort needed for it)
	var floor_rect = ColorRect.new()
	floor_rect.size = Vector2(2000, 2000)
	floor_rect.position = Vector2(-1000, -1000)
	floor_rect.color = Color("#d8c3a5") # Warm wood color
	floor_rect.z_index = -1 # Push it behind the Y-sorted layer
	add_child(floor_rect)
	
	# 3. Create a static Counter Object
	_create_furniture("Cafe Counter", Vector2(400, 300), Vector2(250, 100), Color("#476856"))
	
	# 4. Create some tables
	_create_furniture("Table A", Vector2(200, 500), Vector2(80, 80), Color("#8e6b52"))
	_create_furniture("Table B", Vector2(600, 600), Vector2(80, 80), Color("#8e6b52"))
	
	# 5. Create a Cat Bed
	_create_furniture("Cat Bed", Vector2(200, 700), Vector2(60, 40), Color("#567572"))
	
	# 6. Create the Player (or a Cat) that can walk around
	player = Sprite2D.new()
	player.y_sort_enabled = true
	player.position = Vector2(400, 500)
	
	# We draw a simple capsule for the player visually
	# The key to Y-sorting is that the character's FEET must be at (0,0) of the node.
	# So we shift the visual drawing UP using an offset.
	var tex = PlaceholderTexture2D.new()
	tex.size = Vector2(40, 80)
	player.texture = tex
	player.modulate = Color("#e98074") # Player color
	player.offset = Vector2(0, -40) # Shift visuals up so the bottom (feet) is at the Node's Y-position!
	
	add_child(player)
	
	# 7. Add some instructions on screen
	var label = Label.new()
	label.text = "Life Sim Y-Sort Demo\nUse Arrow Keys / WASD to move the pink player.\nNotice how you walk BEHIND the counter when you go up,\nand IN FRONT of it when you go down.\nThis fixes the 'floating sticker' look!"
	label.modulate = Color.BLACK
	label.position = Vector2(20, 20)
	label.z_index = 100
	add_child(label)

func _create_furniture(obj_name: String, pos: Vector2, size: Vector2, color: Color) -> void:
	# A container Node2D with Y-Sort enabled
	var obj = Node2D.new()
	obj.name = obj_name
	obj.position = pos
	obj.y_sort_enabled = true
	
	# The visual shape (shifted up so the "base" is at the Node's exact position)
	var sprite = Sprite2D.new()
	var tex = PlaceholderTexture2D.new()
	tex.size = size
	sprite.texture = tex
	sprite.modulate = color
	# Shift the visual sprite UP by half its height. 
	# This aligns the bottom edge of the sprite with the (0,0) of the parent node.
	sprite.offset = Vector2(0, -size.y / 2.0)
	
	obj.add_child(sprite)
	add_child(obj)

func _process(delta: float) -> void:
	# Simple player movement
	var dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): dir.x += 1
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S): dir.y += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W): dir.y -= 1
	
	if dir != Vector2.ZERO:
		dir = dir.normalized()
		player.position += dir * speed * delta
