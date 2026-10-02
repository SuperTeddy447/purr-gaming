extends "res://scripts/dev/hybrid_cafe_kit/cafe_kit_3d.gd"
const ART_KIT="res://scenes/dev/hybrid_cafe_art_direction/prefabs/"
var cat_material_mode:="ambient_tinted"
var grouped_surface_count:=0
var rear_triangles_before:=0
var rear_triangles_after:=0
func asset(id:String,parent:Node3D,at:=Vector3.ZERO,turn:=0.0,stretch:=Vector3.ONE)->Node3D:
 var n=load(ART_KIT+"WC_CAFE_"+id+".tscn").instantiate();n.position=at;n.rotation.y=turn;n.scale=stretch;parent.add_child(n);placements.append({"asset":id,"parent":String(parent.name),"local":at,"rotation_y":turn,"scale":stretch});return n
func _materials():manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_art_direction_v1/kit_manifest.json"))
func _architecture():
 super._architecture()
 var rear=groups.RearArchitecture
 for i in 3:asset("Beam_Cedar_A",rear,Vector3(i*1.6,2.54,.17),0,Vector3(1,1.10,1.25))
 asset("Beam_Cedar_A",rear,Vector3(5.44,2.54,.17),0,Vector3(.60,1.10,1.25))
 # Existing shelf/window surfaces only. No new ground obstruction or aperture crossing.
 asset("Planter_Table_A",rear,Vector3(1.08,2.56,.19));asset("Planter_Table_A",rear,Vector3(2.40,2.295,.50));asset("Planter_Table_A",rear,Vector3(4.04,1.125,.52))
 for n in rear.get_children():
  if n.name.begins_with("WC_CAFE_Ceramic_Jar_A"):
   var index:int=n.get_index();n.scale=Vector3(.88+float(index%3)*.07,.82+float(index%4)*.06,.88+float(index%3)*.07);n.rotation.y=float(index%4)*.12
func _counter():
 super._counter()
 var main=groups.counter_shell
 asset("Ceramic_Jar_A",main,footcenter("counter_shell")+Vector3(-.80,1.08,-.09),.17,Vector3(.80,.85,.80))
 asset("Cup_Saucer_A",main,footcenter("counter_shell")+Vector3(-.61,1.08,.02),-.11,Vector3(.80,.80,.80))
func _table():
 super._table()
 for id in ["table_a","table_b"]:
  var rug:=MeshInstance3D.new();var plane:=PlaneMesh.new();plane.size=Vector2(2.10,1.85);rug.mesh=plane;rug.position=footcenter(id)+Vector3(0,.007,.28);rug.material_override=load("res://assets/dev_review/hybrid_cafe_art_direction_v1/materials/WC_MAT_Woven_Rug.tres");rug.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;groups[id].add_child(rug)
 asset("Cup_Saucer_A",groups.table_a,footcenter("table_a")+Vector3(.32,.89,.20),.3,Vector3(.82,.82,.82))
func _batch_static():
 # Group only decorative rear objects sharing one material. Gameplay object wrappers stay separate.
 var owner=groups.RearArchitecture;var buckets:Dictionary={}
 var original_meshes=owner.find_children("*","MeshInstance3D",true,false)
 for n in original_meshes:
  rear_triangles_before+=n.mesh.get_faces().size()/3
  for i in n.mesh.get_surface_count():
   var m=n.get_active_material(i);var key:String=m.resource_path
   if not buckets.has(key):buckets[key]={"material":m,"parts":[]}
   buckets[key].parts.append({"node":n,"surface":i})
 for bucket in buckets.values():
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for part in bucket.parts:st.append_from(part.node.mesh,part.surface,owner.global_transform.affine_inverse()*part.node.global_transform)
  var mesh=st.commit();mesh.surface_set_material(0,bucket.material);var instance:=MeshInstance3D.new();instance.mesh=mesh;instance.name="GroupedRearSurface";owner.add_child(instance);grouped_surface_count+=1;rear_triangles_after+=mesh.get_faces().size()/3
 for n in original_meshes:n.visible=false
 for n in geometry.find_children("*","MeshInstance3D",true,false):
  if n.is_visible_in_tree():batched_triangle_count+=n.mesh.get_faces().size()/3
func _camera_lights():
 super._camera_lights()
 # Primary matched-comparison camera stays identical to V1. Optional hero framing is separate evidence.
 camera.size=7.65
 environment.environment.ambient_light_color=Color("#E7E9E3");environment.environment.ambient_light_energy=.48
 key_light.light_color=Color("#FFF0DC");key_light.light_energy=.80;key_light.rotation_degrees=Vector3(-57,-28,0);key_light.shadow_opacity=.52;key_light.shadow_blur=4.0
 practical.light_energy=.42;practical.omni_range=2.25
func _cat():
 super._cat();contact.modulate=Color(1,1,1,.31);contact.scale=Vector3(.92,.92,1);set_cat_material_mode("ambient_tinted")
func set_cat_material_mode(mode:String):
 cat_material_mode=mode
 var sprites:Array=[cat]
 for row in extra_cats:sprites.append(row.sprite)
 for sprite in sprites:
  sprite.material_override=null;sprite.shaded=false;sprite.modulate=Color.WHITE if mode=="unshaded" else Color(.94,.945,.925)
  if mode=="lightly_lit":
   var m:=ShaderMaterial.new();m.shader=load("res://assets/dev_review/hybrid_cafe_art_direction_v1/cat_light_touch.gdshader");m.set_shader_parameter("key_facing",clampf((-key_light.global_basis.z).dot(camera.global_basis.z),0,1));sprite.material_override=m;sprite.modulate=Color.WHITE
 _refresh_cat_materials()
func _refresh_cat_materials():
 var sprites:Array=[cat]
 for row in extra_cats:sprites.append(row.sprite)
 for sprite in sprites:
  if sprite.material_override is ShaderMaterial:
   var texture=sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
   sprite.material_override.set_shader_parameter("cat_paint",texture.atlas if texture is AtlasTexture else texture)
func _sync_cat():
 super._sync_cat()
 if cat_material_mode=="lightly_lit":_refresh_cat_materials()
func _ui():
 super._ui();status.text="WilliCat · storybook art pass · DEV review"
