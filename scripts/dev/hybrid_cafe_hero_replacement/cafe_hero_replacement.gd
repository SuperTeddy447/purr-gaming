extends "res://scripts/dev/hybrid_cafe_hero_fidelity/cafe_hero_fidelity.gd"
const REPLACEMENT_KIT="res://scenes/dev/hybrid_cafe_hero_replacement/prefabs/"
func asset(id:String,parent:Node3D,at:=Vector3.ZERO,turn:=0.0,stretch:=Vector3.ONE)->Node3D:
 var n=load(REPLACEMENT_KIT+"WC_CAFE_"+id+".tscn").instantiate();n.position=at;n.rotation.y=turn;n.scale=stretch;parent.add_child(n);placements.append({"asset":id,"parent":String(parent.name),"local":at,"rotation_y":turn,"scale":stretch});return n
func _materials():manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_hero_replacement_v1/kit_manifest.json"))
func organic_variant(n:Node3D,role:String,unit_scale:float):
 # Replace complete visual plant; retain exact semantic wrapper position/rotation/scale.
 var id:String={"floor_lance":"Planter_Floor_A","shelf_fan":"Planter_Table_A","trailing":"Plant_Trailing_A","flowering":"Plant_Flowering_A"}[role]
 var visual=n.get_node("VisualRoot")
 for child in visual.get_children():visual.remove_child(child);child.free()
 var imported=load("res://assets/dev_review/hybrid_cafe_hero_replacement_v1/glb/plants/WC_CAFE_"+id+".glb").instantiate();visual.add_child(imported)
 # Plant-role authoring scale is inside VisualRoot; gameplay transform remains untouched.
 imported.scale=Vector3.ONE*(unit_scale/(1.0 if role=="floor_lance" else .43))
 for mesh in imported.find_children("*","MeshInstance3D",true,false):
  for i in mesh.mesh.get_surface_count():
   var material_name:String=mesh.mesh.surface_get_material(i).resource_name.split(".")[0]
   mesh.set_surface_override_material(i,load(HERO_MATS+material_name+".tres"))
 organic_roles.append({"role":role,"parent":n.get_parent().name,"local_position":n.position,"unit_scale":unit_scale,"source":"editable_blender_GL B".replace(" ",""),"asset_id":"WC_CAFE_"+id})
func _ui():
 super._ui();status.text="WilliCat · Hero asset replacement · DEV review"
