extends "res://scripts/dev/riverside_translation/riverside_translation.gd"
## V2 presentation only. Inherited GameplayRoot, nav, actor, route and authority hash stay exact V1.
const V2_KIT:="res://assets/dev_review/riverside_refinement_v2/"
var representative_wind_materials:Array[ShaderMaterial]=[]
func _materials():
 super._materials()
 var shared:Shader=load(V2_KIT+"painted_variation.gdshader")
 for role in materials:
  var m:ShaderMaterial=materials[role].duplicate();m.shader=shared;materials[role]=m
 for role in ["Foliage","Foliage_Light","Foliage_Dark"]:
  materials[role].set_shader_parameter("paint_strength",.40)
  materials[role].set_shader_parameter("pigment_dark",Color("#3D5434"))
  materials[role].set_shader_parameter("pigment_light",Color("#9DAB70"))
 materials.Cream_Stone.set_shader_parameter("palette_color",Color("#C3B29A"))
 materials.Roof_Slate.set_shader_parameter("palette_color",Color("#626C70"))
 materials.QuietEarth.set_shader_parameter("palette_color",Color("#879273"))
func instance(id:String,at:Vector3,turn:=0.0,scale:=Vector3.ONE)->Node3D:
 var path:String=V2_KIT+"glb/WC_RIVER_"+id+".glb"
 if not ResourceLoader.exists(path):path=KIT+"glb/WC_RIVER_"+id+".glb"
 var n:Node3D=load(path).instantiate();n.name=id+"_%d"%instances.size();n.position=at;n.rotation.y=turn;n.scale=scale;geometry.add_child(n)
 for mesh in n.find_children("*","MeshInstance3D",true,false):
  for i in mesh.mesh.get_surface_count():
   var role:String=mesh.get_active_material(i).resource_name.trim_prefix("WC_MAT_")
   assert(materials.has(role),role);mesh.set_surface_override_material(i,materials[role])
  if id.begins_with("Ground") or id.begins_with("Grass") or id.begins_with("Background"):mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 instances.append({"asset_id":"WC_RIVER_"+id,"source":path,"position":[at.x,at.y,at.z],"rotation_y":turn,"scale":[scale.x,scale.y,scale.z],"node":String(n.name)})
 return n
func _ground():
 # Calm route, café forecourt and far-bank continuation; substrate covers tile-to-bank and forecourt joins.
 plane_mesh("StreetStoneSubstrate",Vector2(3.15,16.0),Vector3(.025,-.025,3.0),materials.Cream_Stone)
 plane_mesh("CafeForecourtSubstrate",Vector2(4.4,4.2),Vector3(-3.3,-.025,4.5),materials.Cream_Stone)
 plane_mesh("FarBankSubstrate",Vector2(1.65,14.0),Vector3(6.125,-.025,0),materials.Cream_Stone)
 for z in range(-4,12,2):
  for x in [-.65,.65]:instance("Ground_Stone_"+["A","B","C"][posmod(int(z)+int(x*10),3)],Vector3(x,-.002,z),PI if int(z)%4==0 else 0,Vector3(.65,1,1))
 for z in [3.7,5.7]:
  for x in [-4.6,-2.6]:instance("Ground_Stone_B" if x<-3 else "Ground_Stone_C",Vector3(x,-.003,z),PI if z>4 else 0)
 for z in range(-6,8,2):instance("Ground_Stone_B" if z%4==0 else "Ground_Stone_C",Vector3(6.10,-.002,z),PI if z%4==0 else 0,Vector3(.85,1,1))
 plane_mesh("QuietEarthLeft",Vector2(4.1,17),Vector3(-3.65,-.11,2.5),materials.QuietEarth)
 plane_mesh("QuietEarthFarBank",Vector2(2.2,17),Vector3(6.65,-.115,2.5),materials.QuietEarth)

func _river():
 var m:=ShaderMaterial.new();m.shader=load(V2_KIT+"water.gdshader");m.resource_name="WC_RIVER_MAT_Water"
 water=plane_mesh("QuietMovingRiver",Vector2(3.35,18),Vector3(3.46,-.62,2.0),m)
 for z in [-6,-4,-2,0,4.3,6.3,8.3,10.3]:
  instance("Bank_PathTransition_A" if z==-4 else ("Bank_Vegetation_A" if int(z)%4==0 else "Bank_Straight_A"),Vector3(1.72,0,z),PI/2)
 for z in [-6,-4,-2,0,4.3,6.3,8.3,10.3]:instance("Bank_Straight_B" if int(z)%4==0 else "Bank_Straight_A",Vector3(5.15,0,z),-PI/2)
 # Deliberate bank ends and transition study are visible; no full district bend is fabricated.
 instance("Bank_Inner_A",Vector3(1.72,0,11.3),PI/2)
 instance("Bank_Outer_A",Vector3(5.15,0,-7.0),PI)
 groups.bridge=instance("Bridge_Deck_A",Vector3(3.44,0,2.15))
 instance("Bridge_Rail_A",Vector3(3.44,0,1.24));instance("Bridge_Rail_A",Vector3(3.44,0,3.06))
 instance("Bridge_Abutment_A",Vector3(1.74,0,2.15))
 instance("Bridge_Abutment_A",Vector3(5.14,0,2.15),PI)
 # One coherent low cedar rail rhythm outside the bridge opening.
 for z in [5.1,9.0,-3.0]:instance("Bridge_Rail_A",Vector3(1.72,0,z),PI/2,Vector3(.95,.76,1))

func _buildings():
 groups.cafe=Node3D.new();groups.cafe.name="HomeCafeLandmark";geometry.add_child(groups.cafe)
 # Components are shared actual 3D modular meshes. Named group stores logical home identity only.
 plane_mesh("CafeInteriorGround",Vector2(3.90,3.2),Vector3(-3.55,-.018,1.05),materials.Floor_Wood)
 instance("Wall_Window_A",Vector3(-4.20,0,2.70))
 groups.entrance=instance("Entrance_Open_A",Vector3(-2.14,0,2.70))
 instance("Wall_Plain_A",Vector3(-5.58,0,1.04),PI/2)
 instance("Wall_Plain_A",Vector3(-1.50,0,1.04),-PI/2)
 instance("Wall_Plain_A",Vector3(-3.58,0,-.60),PI,Vector3(1.23,1,1))
 instance("Roof_CedarSlate_A",Vector3(-3.56,2.34,1.05))
 instance("Awning_Jade_A",Vector3(-3.48,2.01,2.95),0,Vector3(1.10,1,1))
 groups.sign=instance("Sign_Blank_A",Vector3(-3.40,2.36,3.02))
 instance("Lamp_Practical_A",Vector3(-1.54,1.76,2.86))
 # Substantial cedar shelf inside the real opening; no flat image of an interior.
 var p:=BoxMesh.new();p.size=Vector3(2.8,.74,.46)
 var c:=MeshInstance3D.new();c.name="InteriorCounterHint";c.mesh=p;c.material_override=materials.Cedar_Mid;c.position=Vector3(-3.6,.38,1.15);geometry.add_child(c)
 instance("Bench_Cedar_A",Vector3(-4.36,0,3.14))
 # One neighbor façade, noticeably quieter and without café signage/awning landmark.
 instance("Wall_Window_A",Vector3(6.1,0,-3.1),0,Vector3(.90,.90,1))
 instance("Wall_Plain_A",Vector3(7.25,0,-4.5),-PI/2,Vector3(.85,.9,1))
 instance("Roof_CedarSlate_A",Vector3(6.15,2.12,-4.2),0,Vector3(.63,.85,.66))
 instance("Background_House_A",Vector3(-3.4,0,-5.6),.11,Vector3(1.15,1.15,1.15))
 instance("Background_House_A",Vector3(2.65,0,-6.8),-.15,Vector3(.84,.84,.84))

func _vegetation():
 groups.tree=instance("Tree_Medium_A",Vector3(-3.2,0,8.6))
 # Exactly ONE motion instance: only the representative tree foliage; trunk/shrub/pots/background static.
 for mesh in groups.tree.find_children("*","MeshInstance3D",true,false):
  for i in mesh.mesh.get_surface_count():
   var m:ShaderMaterial=mesh.get_active_material(i)
   if m.get_shader_parameter("foliage_pigment")==true:
    var wind:ShaderMaterial=m.duplicate();wind.shader=load(V2_KIT+"foliage_sway.gdshader");wind.set_shader_parameter("wind_amount",.012);representative_wind_materials.append(wind);mesh.set_surface_override_material(i,wind)
 instance("Tree_Small_A",Vector3(-5.4,0,-3.8),.4)
 instance("Tree_Medium_A",Vector3(-4.5,0,-4.6),.6,Vector3(.65,.65,.65))
 instance("Tree_Medium_A",Vector3(4.4,0,-7.1),-.5,Vector3(.60,.60,.60))
 instance("Tree_Small_A",Vector3(7.0,0,5.8),-.7)
 instance("Potted_Plant_A",Vector3(-2.86,0,3.20))
 instance("Potted_Plant_A",Vector3(-5.34,0,3.23),.6,Vector3(.8,.8,.8))
 for z in [-6,-1,5.6,9.8]:instance("Grass_Bank_A",Vector3(1.70,-.38,z),.3)
 instance("Bench_Cedar_A",Vector3(-2.40,0,7.35),-.1)

 instance("Shrub_Riverside_A",Vector3(-5.23,0,6.9),.3)
 instance("Shrub_Riverside_A",Vector3(7.20,0,.10),-.4,Vector3(.83,.83,.83))
 instance("Shrub_Riverside_A",Vector3(-4.95,0,-2.3),.6)
 instance("Background_Rise_A",Vector3(1.0,-.06,-6.9),0,Vector3(.85,1,1))
 instance("Tree_Small_A",Vector3(.6,0,-6.8),.8,Vector3(.8,.8,.8))
func _camera_lights():
 camera=Camera3D.new();camera.name="PortraitGameplayCamera";camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.keep_aspect=Camera3D.KEEP_WIDTH;camera.size=13.2;camera.near=.1;camera.far=60;add_child(camera);camera.position=Vector3(8.35,16.5,21.0);camera.look_at(Vector3(1.05,.75,2.80));camera.current=true
 environment=WorldEnvironment.new();environment.name="QuietOutdoorEnvironment";var e:=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color("#EAE6DA");e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color("#E5E9E6");e.ambient_light_energy=.47;e.reflected_light_source=Environment.REFLECTION_SOURCE_DISABLED;e.tonemap_mode=Environment.TONE_MAPPER_LINEAR;e.glow_enabled=false;e.ssao_enabled=false;e.fog_enabled=false;environment.environment=e;add_child(environment)
 key_light=DirectionalLight3D.new();key_light.name="LateMorningSoftKey";key_light.rotation_degrees=Vector3(-58,-28,0);key_light.light_color=Color("#FFF7ED");key_light.light_energy=.90;key_light.shadow_enabled=true;key_light.shadow_opacity=.40;key_light.shadow_blur=4;key_light.shadow_bias=.012;key_light.shadow_normal_bias=.14;key_light.directional_shadow_max_distance=45;key_light.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL;add_child(key_light)
 practical=OmniLight3D.new();practical.name="CafePracticalAccent";practical.position=Vector3(-1.54,1.64,3.10);practical.light_color=Color("#F3DBB9");practical.light_energy=.32;practical.omni_range=1.6;practical.shadow_enabled=false;add_child(practical)

func triangle_contributors()->Array:
 var totals:Dictionary={}
 for row in instances:
  var n:Node3D=geometry.get_node(NodePath(row.node));var t:=0
  for m in n.find_children("*","MeshInstance3D",true,false):t+=m.mesh.get_faces().size()/3
  var id:String=row.asset_id
  if not totals.has(id):totals[id]={"asset_id":id,"instances":0,"triangles_per_instance":t,"scene_triangles":0}
  totals[id].instances+=1;totals[id].scene_triangles+=t
 for n in geometry.get_children():
  if n is MeshInstance3D and n.mesh!=null:totals[String(n.name)]={"asset_id":String(n.name),"instances":1,"triangles_per_instance":n.mesh.get_faces().size()/3,"scene_triangles":n.mesh.get_faces().size()/3}
 var rows:Array=totals.values();rows.sort_custom(func(a,b):return a.scene_triangles>b.scene_triangles);return rows
