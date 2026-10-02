extends Node3D
## Material/registration handoff only. No physics, navigation or world-authority writes.
@export var asset_id:String
var material_bindings:Array=[]
func _ready():
 for mesh in get_node("VisualRoot").find_children("*","MeshInstance3D",true,false):
  for i in mesh.mesh.get_surface_count():
   var imported:Material=mesh.mesh.surface_get_material(i)
   assert(imported!=null,"Missing GLB material")
   var name:String=imported.resource_name.split(".")[0]
   var path:="res://assets/dev_review/hybrid_cafe_kit_v1/materials/"+name+".tres"
   assert(ResourceLoader.exists(path),"Unmapped shared material: "+name)
   mesh.set_surface_override_material(i,load(path));material_bindings.append({"surface":i,"material":name,"shared_resource":path})
 set_meta("gameplay_collision_authority","existing GameplayRoot PhysicalFootprint/CollisionShape2D; no imported collision")
