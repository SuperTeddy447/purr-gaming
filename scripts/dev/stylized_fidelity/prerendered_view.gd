extends Control
## DEV comparison still, NOT a production room bitmap or moving gameplay implementation.
func _ready():
 var layer:=CanvasLayer.new();layer.name="BakedPresentation";add_child(layer)
 var image:=TextureRect.new();image.name="SameDioramaOrthographicImage";image.texture=load("res://assets/dev_review/stylized_fidelity_v1/prerender/hero_1008x1792.png");image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(image)
 var controls:=CanvasLayer.new();controls.name="ComparisonControls";add_child(controls)
 var label:=Label.new();label.text="Same 3D diorama · baked 2D still
Feasibility comparison · no moving cat in this branch";label.position=Vector2(18,18);label.add_theme_color_override("font_color",Color("#352C28"));controls.add_child(label)
 var button:=Button.new();button.text="Return to Live Hybrid";button.position=Vector2(18,948);button.pressed.connect(func():get_tree().change_scene_to_file("res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn"));controls.add_child(button)
