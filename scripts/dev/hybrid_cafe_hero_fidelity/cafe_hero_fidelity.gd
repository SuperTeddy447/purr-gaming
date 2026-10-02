extends "res://scripts/dev/hybrid_cafe_art_direction/cafe_art_direction.gd"
const HERO_KIT="res://scenes/dev/hybrid_cafe_hero_fidelity/prefabs/"
const ORGANIC=preload("res://scripts/dev/hybrid_cafe_hero_fidelity/organic_layers.gd")
const HERO_MATS="res://assets/dev_review/hybrid_cafe_hero_fidelity_v2/materials/"
var organic_roles:Array=[]
var pruned_foliage_triangles:=0
func asset(id:String,parent:Node3D,at:=Vector3.ZERO,turn:=0.0,stretch:=Vector3.ONE)->Node3D:
 var n=load(HERO_KIT+"WC_CAFE_"+id+".tscn").instantiate();n.position=at;n.rotation.y=turn;n.scale=stretch;parent.add_child(n);placements.append({"asset":id,"parent":String(parent.name),"local":at,"rotation_y":turn,"scale":stretch});return n
func _materials():manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_hero_fidelity_v2/kit_manifest.json"))
func organic_variant(n:Node3D,role:String,unit_scale:float):
 # Reuse imported ceramic pot/soil/stem; remove only original generic foliage surfaces.
 for instance in n.find_children("*","MeshInstance3D",true,false):
  var mesh:=ArrayMesh.new();var kept:Array=[]
  for i in instance.mesh.get_surface_count():
   var material:Material=instance.get_active_material(i)
   if material.resource_name.begins_with("WC_MAT_Foliage"):
    var arrays:Array=instance.mesh.surface_get_arrays(i);pruned_foliage_triangles+=arrays[Mesh.ARRAY_INDEX].size()/3
    continue
   mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,instance.mesh.surface_get_arrays(i));kept.append(material)
  instance.mesh=mesh
  for i in kept.size():instance.set_surface_override_material(i,kept[i])
 var mat:Array=[]
 for name in ["Foliage_Organic","Foliage_Light","Foliage_Dark","Petal_Cream"]:mat.append(load(HERO_MATS+"WC_MAT_"+name+".tres"))
 ORGANIC.add(n,role,unit_scale,mat);organic_roles.append({"role":role,"parent":n.get_parent().name,"local_position":n.position,"unit_scale":unit_scale})
func _architecture():
 super._architecture()
 # Replace repeated generic rear plants with three distinct authored roles on existing surfaces.
 var rear=groups.RearArchitecture
 for n in rear.get_children():
  if n.get_script()==preload("res://scripts/dev/hybrid_cafe_hero_fidelity/asset_wrapper.gd") and n.asset_id=="WC_CAFE_Planter_Table_A":rear.remove_child(n);n.free()
 var small=asset("Planter_Table_A",rear,Vector3(.38,.555,.43),.25);organic_variant(small,"shelf_fan",.43)
 var flowering=asset("Planter_Table_A",rear,Vector3(1.27,.555,.43),-.18);organic_variant(flowering,"flowering",.43)
 var trailing=asset("Planter_Table_A",rear,Vector3(2.27,2.295,.53),.18);organic_variant(trailing,"trailing",.43)
 var quiet=asset("Planter_Table_A",rear,Vector3(4.53,2.295,.49),-.35);organic_variant(quiet,"shelf_fan",.36)
 # All additional trim belongs to the same rear spans; leave x4.80..5.44 aperture clear.
 for n in rear.get_children():
  if n.get_script()==preload("res://scripts/dev/hybrid_cafe_hero_fidelity/asset_wrapper.gd") and n.asset_id=="WC_CAFE_Ceramic_Jar_A" and n.position.x>3.25 and n.position.x<4.2:
   for mesh in n.find_children("*","MeshInstance3D",true,false):
    for i in mesh.mesh.get_surface_count():
     if mesh.get_active_material(i).resource_name=="WC_MAT_Ceramic_Offwhite":mesh.set_surface_override_material(i,load(HERO_MATS+"WC_MAT_Indigo.tres"))
 asset("Cup_Saucer_A",rear,Vector3(2.79,2.295,.55),.22,Vector3(.72,.72,.72))
 for x in [0.12,1.52,3.12,4.68,5.55,6.28]:
  G.bevel(rear,"ModestJointCap",Vector3(.095,.08,.04),load(HERO_MATS+"WC_MAT_Cedar_Mid.tres"),Vector3(x,2.48,.312),.006)
func _counter():
 super._counter()
 var main=groups.counter_shell;var center:Vector3=footcenter("counter_shell")
 # Reuse existing surface-supported objects: coherent cup/jar pair and a small serving cloth.
 var cloth:=PlaneMesh.new();cloth.size=Vector2(.39,.24)
 var n=G.node(main,"ServiceSageCloth",cloth,load(HERO_MATS+"WC_MAT_Sage_Fabric.tres"),center+Vector3(.61,1.081,.04));n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 asset("Cup_Saucer_A",main,center+Vector3(.60,1.084,.04),.16,Vector3(.75,.75,.75))
 asset("Ceramic_Jar_A",main,center+Vector3(-.98,1.08,-.08),-.22,Vector3(.60,.72,.60))
func _table():
 super._table()
 for id in ["table_a","table_b"]:
  var g=groups[id]
  for n in g.get_children():
   if n.name.begins_with("WC_CAFE_Planter_Table_A"):organic_variant(n,"flowering" if id=="table_a" else "shelf_fan",.35 if id=="table_a" else .40)
   if n is MeshInstance3D and n.mesh is PlaneMesh:n.material_override=load(HERO_MATS+"WC_MAT_Woven_Rug.tres")
func _plant():
 super._plant()
 for n in groups.plant.get_children():
  if n.name.begins_with("WC_CAFE_Planter_Floor_A"):organic_variant(n,"floor_lance",1.0)
 var case_group=groups.pastry_case;var center:Vector3=footcenter("pastry_case")
 # Replace inherited cup/jar display dressing, avoiding interpenetration with the pastry tray.
 for n in case_group.get_children():
  if n.get_script()==preload("res://scripts/dev/hybrid_cafe_hero_fidelity/asset_wrapper.gd") and n.asset_id in ["WC_CAFE_Cup_Saucer_A","WC_CAFE_Ceramic_Jar_A"]:case_group.remove_child(n);n.free()
 var tray=G.bevel(case_group,"SmallCeramicServingTray",Vector3(.55,.025,.25),load(HERO_MATS+"WC_MAT_Ceramic_Offwhite.tres"),center+Vector3(-.03,1.095,.035),.006);tray.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for row in [{"at":Vector3(-.14,1.105,.045),"turn":.20},{"at":Vector3(.10,1.105,.035),"turn":-.24}]:ORGANIC.crescent(case_group,center+row.at,row.turn,load(HERO_MATS+"WC_MAT_Pastry_Warm.tres"))
func _batch_static():
 # SurfaceTool.append_from requires explicit indices; preserve new procedural leaf/trim arrays.
 for instance in groups.RearArchitecture.find_children("*","MeshInstance3D",true,false):
  var normalized:=ArrayMesh.new();var original_materials:Array=[]
  for i in instance.mesh.get_surface_count():
   var arrays:Array=instance.mesh.surface_get_arrays(i);original_materials.append(instance.get_active_material(i))
   if arrays[Mesh.ARRAY_INDEX]==null or arrays[Mesh.ARRAY_INDEX].is_empty():
    var indices:=PackedInt32Array()
    for j in arrays[Mesh.ARRAY_VERTEX].size():indices.append(j)
    arrays[Mesh.ARRAY_INDEX]=indices
   if arrays[Mesh.ARRAY_COLOR]==null or arrays[Mesh.ARRAY_COLOR].is_empty():
    var colors:=PackedColorArray();colors.resize(arrays[Mesh.ARRAY_VERTEX].size());colors.fill(Color.WHITE);arrays[Mesh.ARRAY_COLOR]=colors
   normalized.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
  instance.mesh=normalized
  for i in original_materials.size():instance.set_surface_override_material(i,original_materials[i])
 super._batch_static()
 # Selected small rear foliage has no expensive geometric shadow; cavity/contact stays authored.
 for n in groups.RearArchitecture.find_children("GroupedRearSurface*","MeshInstance3D",true,false):
  if n.get_active_material(0).resource_name in ["WC_MAT_Foliage_Organic","WC_MAT_Petal_Cream"]:n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func _camera_lights():
 super._camera_lights()
 # Exact V1 common orthographic transform/projection/size remains authoritative for this comparison.
 key_light.light_color=Color("#FFF4E4");key_light.light_energy=.92;key_light.shadow_opacity=.46
 environment.environment.ambient_light_color=Color("#E9EBE5");environment.environment.ambient_light_energy=.52
 practical.light_color=Color("#F3CE99");practical.light_energy=.50;practical.omni_range=1.9
func _cat():
 super._cat()
 # Preserve painted identity; slightly less dark tint than V1, never relight/repaint the sprite.
 cat.modulate=Color(.985,.975,.96);contact.modulate=Color(1,1,1,.28)
 for row in extra_cats:row.sprite.modulate=cat.modulate
func set_cat_material_mode(mode:String):
 super.set_cat_material_mode(mode)
 if mode=="ambient_tinted":
  cat.modulate=Color(.985,.975,.96)
  for row in extra_cats:row.sprite.modulate=cat.modulate
func _ui():
 super._ui();status.text="WilliCat · Hero fidelity V2 · DEV review"
