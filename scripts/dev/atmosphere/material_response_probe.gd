extends Node2D
## Isolated material trial using the existing Home V2 chair sprite, not new artwork.

const CHAIR := preload("res://assets/environment/home_v2/chair_jade_home_v2_01.png")
const OUTPUT := "res://artifacts/prototype_review/world_atmosphere_lighting_lab_v2/14_material_response_probe.png"


func _ready() -> void:
	var tint := CanvasModulate.new()
	tint.color = Color(0.63, 0.65, 0.72)
	add_child(tint)
	var headings := ["A  PAINTED + LIGHT", "B  SIMPLE NORMAL + LIGHT", "C  STYLIZED SHADER + LIGHT"]
	for i in 3:
		var column := Node2D.new()
		column.position = Vector2(90 + 180 * i, 470)
		add_child(column)
		var sprite := Sprite2D.new()
		sprite.texture = CHAIR
		sprite.scale = Vector2.ONE * 0.17
		column.add_child(sprite)
		if i == 1:
			var canvas_texture := CanvasTexture.new()
			canvas_texture.diffuse_texture = CHAIR
			canvas_texture.normal_texture = _make_soft_normal_map()
			sprite.texture = canvas_texture
		elif i == 2:
			var shader := Shader.new()
			shader.code = "shader_type canvas_item; uniform float light_bias = 0.18; void fragment() { vec4 base = texture(TEXTURE, UV); float broad_highlight = smoothstep(0.15, 0.85, 1.0 - UV.x); COLOR = vec4(base.rgb * (0.89 + light_bias * broad_highlight), base.a); }"
			var material := ShaderMaterial.new()
			material.shader = shader
			sprite.material = material
		var light := PointLight2D.new()
		light.position = Vector2(50, -75)
		light.texture = _make_light_texture()
		light.texture_scale = 1.5
		light.energy = 0.5
		light.shadow_enabled = false
		column.add_child(light)
		var label := Label.new()
		label.text = headings[i]
		label.position = Vector2(-75, -220)
		label.add_theme_font_size_override("font_size", 11)
		column.add_child(label)
	var note := Label.new()
	note.text = "Same existing chair art; illustrative technical probe only. No mobile benchmark."
	note.position = Vector2(24, 740)
	note.add_theme_font_size_override("font_size", 12)
	add_child(note)
	if "--capture-material" in OS.get_cmdline_user_args():
		call_deferred("capture")


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F6:
		capture()


func _make_soft_normal_map() -> ImageTexture:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in 64:
		for x in 64:
			var nx := clampf((float(x) - 31.5) / 85.0, -0.36, 0.36)
			var ny := clampf((float(y) - 31.5) / 130.0, -0.24, 0.24)
			image.set_pixel(x, y, Color(0.5 + nx * 0.5, 0.5 + ny * 0.5, 1.0, 1.0))
	return ImageTexture.create_from_image(image)


func _make_light_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 0.85, 0.64, 0.8))
	gradient.set_color(1, Color(1, 0.85, 0.64, 0))
	var texture := GradientTexture2D.new()
	texture.width = 256
	texture.height = 256
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1, 0.5)
	return texture


func capture() -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(OUTPUT)
	print("MATERIAL RESPONSE CAPTURE %s" % ("PASS" if error == OK else "FAIL"))
