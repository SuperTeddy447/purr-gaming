extends "res://scripts/dev/hybrid_cafe_hero_replacement/cafe_hero_replacement.gd"
const SURFACE="res://assets/dev_review/hybrid_cafe_painted_surface_v1/"
var surface_bindings:Array=[]
var edge_measurements:Array=[]
func _batch_static():
 super._batch_static()
 var map:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(SURFACE+"material_manifest.json")).material_map
 # Material-only handoff: original mesh resources and every geometry array remain untouched.
 for instance in geometry.find_children("*","MeshInstance3D",true,false):
  if instance.material_override:
   var role:String=instance.material_override.resource_name;assert(map.has(role),role)
   instance.material_override=load(SURFACE+"materials/"+map[role]+".tres")
   surface_bindings.append({"node":instance.name,"surface":"all","material":instance.material_override.resource_name})
   continue
  for i in instance.mesh.get_surface_count():
   var old:Material=instance.get_active_material(i);assert(map.has(old.resource_name),old.resource_name)
   var m:Material=load(SURFACE+"materials/"+map[old.resource_name]+".tres");instance.set_surface_override_material(i,m)
   surface_bindings.append({"node":instance.name,"surface":i,"material":m.resource_name})
 edge_measurements.append({"method":"existing red cavity and green pigment preserved; subtle normal-derivative edge proxy in shader, no mesh/vertex-color rewrite"})
func _camera_lights():
 super._camera_lights()
 key_light.light_color=Color("#FFF4E7");key_light.light_energy=.93;key_light.shadow_opacity=.45;key_light.shadow_bias=.012;key_light.shadow_normal_bias=.14
 environment.environment.ambient_light_color=Color("#E5E9E6");environment.environment.ambient_light_energy=.40
 practical.light_color=Color("#F3DBB9");practical.light_energy=.70;practical.omni_range=1.9
func _ui():
 super._ui();status.text="WilliCat · Painted surface / light spike · DEV"
