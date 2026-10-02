extends "res://scripts/dev/hybrid_diorama/hybrid_diorama.gd"
const KIT="res://scenes/dev/hybrid_cafe_kit/prefabs/"
var manifest:Dictionary
var extra_cats:Array=[]
var placements:Array=[]
var asset_checks:Dictionary={}
func asset(id:String,parent:Node3D,at:=Vector3.ZERO,turn:=0.0,stretch:=Vector3.ONE)->Node3D:
 var n=load(KIT+"WC_CAFE_"+id+".tscn").instantiate();n.position=at;n.rotation.y=turn;n.scale=stretch;parent.add_child(n);placements.append({"asset":id,"parent":String(parent.name),"local":at,"rotation_y":turn,"scale":stretch});return n
func attach(id:String,model:String,offset:=Vector3.ZERO,turn:=0.0,stretch:=Vector3.ONE)->Node3D:
 var obj=authority_world.find_object(StringName(id));assert(obj!=null)
 var g=group(id,project_point(obj.global_position));g.set_meta("stable_id",obj.stable_id)
 asset(model,g,offset,turn,stretch);return g
func footcenter(id:String)->Vector3:
 var obj=authority_world.find_object(StringName(id));var b:Rect2=obj.get_node("PhysicalFootprint").global_bounds();return project_point(b.get_center())-project_point(obj.global_position)
func contact_shadow(parent:Node3D,at:Vector3,size:=Vector2(.55,.30),opacity:=.20):
 var s:=Sprite3D.new();s.texture=load("res://assets/first_party/storybook_mini_pack_001/normalized/contact_shadow.png");s.pixel_size=.005;s.rotation_degrees.x=-90;s.scale=Vector3(size.x/(s.texture.get_width()*.005),size.y/(s.texture.get_height()*.005),1);s.modulate=Color(1,1,1,opacity);s.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;s.position=at+Vector3(0,.009,0);parent.add_child(s)
func _materials():manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_kit_v1/kit_manifest.json"))
func _architecture():
 var floor=group("Floor");asset("Floor_Section_A",floor)
 var rear=group("RearArchitecture")
 # Exact existing rear walls span x0..480 and544..640; garden gap480..544 stays open.
 for i in 3:asset("Wall_Window_A" if i==0 else "Wall_Cream_A",rear,Vector3(i*1.6,0,.14))
 asset("Wall_Cream_A",rear,Vector3(5.44,0,.14),0,Vector3(.60,1,1))
 asset("Window_Sill_A",rear,Vector3(.0,.50,.16));asset("Sign_Blank_A",rear,Vector3(3.20,1.84,.30))
 for x in [2.15,3.95]:
  asset("Shelf_A" if x<3 else "Shelf_Short_A",rear,Vector3(x,1.07,.31));asset("Shelf_A" if x<3 else "Shelf_Short_A",rear,Vector3(x,2.24,.31))
  for i in (4 if x<3 else 2):asset("Ceramic_Jar_A",rear,Vector3(x+.20+i*.39,1.125,.54))
  for i in (3 if x<3 else 1):asset("Ceramic_Jar_A",rear,Vector3(x+.28+i*.40,2.295,.53))
 asset("Planter_Table_A",rear,Vector3(.37,.555,.43));asset("Planter_Table_A",rear,Vector3(1.27,.555,.43));asset("Planter_Table_A",rear,Vector3(4.53,2.295,.49))
 # Side/front architecture reads the real envelope; cutaway HEIGHT is a visual choice only.
 var sides=group("SideArchitecture")
 for side in [0.16,6.24]:
  for i in range(6):asset("Wall_Cream_A",sides,Vector3(side,0,i*1.6),-PI/2,Vector3(1,.55 if i<2 else .27,1))
 for side in [0.16,6.24]:asset("Wall_Cream_A",sides,Vector3(side,0,9.6),-PI/2,Vector3(.4,.27,1))
 var front=group("FrontArchitecture")
 for id in ["front_wall_west","front_wall_east"]:
  var b:Rect2=authority_world.find_object(StringName(id)).get_node("PhysicalFootprint").global_bounds();asset("Wall_Cream_A",front,project_point(Vector2(b.position.x,b.get_center().y)),0,Vector3(b.size.x*UNIT/1.6,.23,1))
 var door=authority_world.find_object(&"entrance_door");var b:Rect2=authority_world.find_object(&"front_wall_west").get_node("PhysicalFootprint").global_bounds();var d=group("entrance_door",project_point(door.global_position));asset("Entrance_Open_A",d,Vector3(0,0,(b.get_center().y-door.global_position.y)*UNIT))
 asset("Lamp_Wall_A",front,Vector3(2.37,1.04,9.83));asset("Lamp_Wall_A",front,Vector3(4.03,1.04,9.83))
 # World labels stay editable; sign textures contain no text.
 var label:=Label3D.new();label.text="WilliCat\nRiverside café";label.font_size=48;label.pixel_size=.003;label.position=Vector3(3.2,1.85,.36);label.modulate=Color("#E9D7B5");label.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;rear.add_child(label)
func _counter():
 for row in [{"id":"counter_shell","asset":"Counter_Straight_A"},{"id":"espresso_station","asset":"Counter_End_A"},{"id":"grinder_station","asset":"Counter_Short_A"}]:
  var g=attach(row.id,row.asset,footcenter(row.id));var obj=authority_world.find_object(StringName(row.id));var b:Rect2=obj.get_node("PhysicalFootprint").global_bounds();contact_shadow(g,footcenter(row.id),b.size*UNIT,.16)
 asset("Espresso_A",groups.espresso_station,footcenter("espresso_station")+Vector3(0,1.08,0))
 asset("Grinder_A",groups.grinder_station,footcenter("grinder_station")+Vector3(0,1.08,0))
 var pos=attach("pos_station","POS_A",Vector3(0,1.08,-.18))
 for p in [Vector3(1.88,1.08,1.61),Vector3(2.55,1.08,1.68)]:asset("Cup_Saucer_A",geometry,p)
 # No opaque bridge across the canonical gap between counter and espresso footprint.
func _table():
 for id in ["table_a","table_b"]:
  var g=attach(id,"Table_Round_A",footcenter(id));contact_shadow(g,footcenter(id),Vector2(.65,.52),.20)
  asset("Cup_Saucer_A",g,footcenter(id)+Vector3(.20,.89,-.11));asset("Planter_Table_A",g,footcenter(id)+Vector3(-.28,.89,.04))
func _chair(id:String):
 var turn:float=-.27 if id=="chair_a" else .27
 var g=attach(id,"Chair_A",footcenter(id),turn);contact_shadow(g,footcenter(id),Vector2(.48,.30),.18)
func _plant():
 for id in ["chair_c","chair_d"]:_chair(id)
 var g=attach("plant","Planter_Floor_A",footcenter("plant"));contact_shadow(g,footcenter("plant"),Vector2(.37,.25),.19)
 attach("cat_bed","Cat_Cushion_A",footcenter("cat_bed"));attach("scratch_post","Post_Cedar_A",footcenter("scratch_post"),0,Vector3(1,.30,1))
 # Reuse a small cabinet for the existing pastry-case semantic position.
 var p=attach("pastry_case","Counter_End_A",footcenter("pastry_case"),0,Vector3(.88/.73,1,.32/.45))
 asset("Cup_Saucer_A",p,footcenter("pastry_case")+Vector3(0,1.08,0));asset("Ceramic_Jar_A",p,footcenter("pastry_case")+Vector3(.2,1.08,0))
func _lamp():
 var l=group("PracticalLamp")
 for x in [1.78,4.18]:asset("Lamp_Hanging_A",l,Vector3(x,2.75,1.24))
 practical=OmniLight3D.new();practical.position=Vector3(4.18,2.08,1.24);practical.light_color=Color("#F7C483");practical.light_energy=.25;practical.omni_range=1.9;practical.shadow_enabled=false;l.add_child(practical)
func _batch_static():
 for n in geometry.find_children("*","MeshInstance3D",true,false):batched_triangle_count+=n.mesh.get_faces().size()/3
 unbatched_triangle_count=batched_triangle_count
func _camera_lights():
 super._camera_lights();camera.position=Vector3(5.15,13.2,20.0);camera.look_at(Vector3(3.2,.60,5.0));camera.size=8.05
 environment.environment.ambient_light_energy=.57;environment.environment.background_color=Color("#EAE3D6");key_light.light_energy=.68;key_light.rotation_degrees=Vector3(-62,-32,0);key_light.shadow_opacity=.43;key_light.shadow_blur=3;key_light.shadow_bias=.025;key_light.shadow_normal_bias=.32
func _cat():
 super._cat();set_cat_mode("upright");cat.modulate=Color(.95,.965,.945);cat.scale.y=1/absf(camera.global_basis.y.y)
 for name in ["Worker","Customer"]:
  var logic=authority_world.actors.get_node(name);var art=slice.avatars[name].find_children("*","AnimatedSprite2D",true,false)[0]
  var sprite:=AnimatedSprite3D.new();sprite.sprite_frames=art.sprite_frames;sprite.pixel_size=art.scale.x*UNIT;sprite.offset=Vector2(0,104);sprite.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y;sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS;sprite.shaded=false;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;sprite.scale.y=cat.scale.y;sprite.modulate=cat.modulate;add_child(sprite)
  var sh:=Sprite3D.new();sh.texture=contact.texture;sh.pixel_size=.005;sh.rotation_degrees.x=-90;sh.modulate=Color(1,1,1,.25);sh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(sh);extra_cats.append({"name":name,"logic":logic,"art":art,"sprite":sprite,"shadow":sh})
func _sync_cat():
 super._sync_cat()
 for row in extra_cats:
  row.sprite.position=project_point(row.logic.global_position);row.shadow.position=row.sprite.position+Vector3(0,.009,0)
  if row.sprite.animation!=row.art.animation:row.sprite.animation=row.art.animation
  row.sprite.frame=row.art.frame;row.sprite.frame_progress=row.art.frame_progress
  row.sprite.visible=not baseline_mode and Rect2(0,0,640,1024).has_point(row.logic.global_position) and (row.name=="Worker" or authority_world.loop_active);row.shadow.visible=row.sprite.visible
func _ui():
 super._ui();status.text="Blender café kit · isolated DEV review"
 var button:=Button.new();button.text="Make coffee";button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;button.pressed.connect(func():slice.start_coffee());get_node("DiagnosticControls").find_children("*","HBoxContainer",true,false)[0].add_child(button)
