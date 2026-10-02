extends Node3D
## DEV-only district authority is separate from the existing continuous Home.
## Existing HardeningActor/Vector2 navigation drives visuals; no second 3D gameplay body.
const UNIT:=.01
const KIT:="res://assets/dev_review/riverside_translation_v1/"
const SURFACE:="res://assets/dev_review/hybrid_cafe_painted_surface_v1/"
const ART:="res://assets/first_party/storybook_mini_pack_001/normalized/"
var geometry:Node3D
var gameplay:Node2D
var actor:HardeningActor
var npc:HardeningActor
var source_sprite:AnimatedSprite2D
var cat:AnimatedSprite3D
var npc_cat:AnimatedSprite3D
var contact:Sprite3D
var camera:Camera3D
var key_light:DirectionalLight3D
var practical:OmniLight3D
var environment:WorldEnvironment
var water:MeshInstance3D
var materials:Dictionary={}
var instances:Array=[]
var route_outline:PackedVector2Array
var route_world:PackedVector2Array
var ready_for_review:=false
var touring:=false
var tour_results:Array=[]
var trace:Array=[]
var controls:CanvasLayer
var debug_route:MeshInstance3D
var groups:Dictionary={}
var status:Label
var initial_authority_hash:String
var ticks:=0
signal checkpoint(label:String)

func _ready():install.call_deferred()
func point(xy:Vector2)->Vector3:return Vector3(xy.x*UNIT,0,xy.y*UNIT)
func xy(p:Vector3)->Vector2:return Vector2(p.x,p.z)/UNIT
func install():
 geometry=Node3D.new();geometry.name="RiversideVisualRoot";add_child(geometry)
 _materials();_ground();_river();_buildings();_vegetation();_camera_lights();_gameplay();_cat();_ui();_debug()
 for i in 6:await get_tree().physics_frame
 initial_authority_hash=authority_hash();ready_for_review=true;status.text="DEV · click path to walk"

func _materials():
 var map:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(SURFACE+"material_manifest.json")).material_map
 for role in map:materials[String(role).trim_prefix("WC_MAT_")]=load(SURFACE+"materials/"+map[role]+".tres")
 for row in [["Cream_Stone","Cream_Stone",Color("#CAAF93")],["Roof_Slate","Charcoal_Trim",Color("#626B71")],["Jade","Sage_Fabric",Color("#648171")],["Aged_Brass","Cedar_Mid",Color("#A18A62")]]:
  var m:ShaderMaterial=materials[row[1]].duplicate();m.resource_name="WC_RIVER_MAT_"+row[0];m.set_shader_parameter("palette_color",row[2]);m.set_shader_parameter("cedar_surface",false);m.set_shader_parameter("material_roughness",.95);materials[row[0]]=m
 var earth:ShaderMaterial=materials.Sage_Fabric.duplicate();earth.resource_name="WC_RIVER_MAT_QuietEarth";earth.set_shader_parameter("palette_color",Color("#87916D"));earth.set_shader_parameter("paint_strength",.12);materials.QuietEarth=earth
 var wind_shader:Shader=load(KIT+"foliage_sway.gdshader")
 for role in ["Foliage","Foliage_Light","Foliage_Dark"]:
  var m:ShaderMaterial=materials[role].duplicate();m.shader=wind_shader;m.resource_name="WC_RIVER_MAT_"+role;m.set_shader_parameter("wind_amount",.016);materials[role]=m

func instance(id:String,at:Vector3,turn:=0.0,scale:=Vector3.ONE)->Node3D:
 var n:Node3D=load(KIT+"glb/WC_RIVER_"+id+".glb").instantiate();n.name=id+"_%d"%instances.size();n.position=at;n.rotation.y=turn;n.scale=scale;geometry.add_child(n)
 for mesh in n.find_children("*","MeshInstance3D",true,false):
  for i in mesh.mesh.get_surface_count():
   var role:String=mesh.get_active_material(i).resource_name.trim_prefix("WC_MAT_")
   assert(materials.has(role),role);mesh.set_surface_override_material(i,materials[role])
  if id.begins_with("Ground") or id.begins_with("Grass") or id.begins_with("Background"):mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 instances.append({"asset_id":"WC_RIVER_"+id,"position":[at.x,at.y,at.z],"rotation_y":turn,"scale":[scale.x,scale.y,scale.z],"node":String(n.name)})
 return n
func plane_mesh(name:String,size:Vector2,at:Vector3,mat:Material)->MeshInstance3D:
 var n:=MeshInstance3D.new();n.name=name;var p:=PlaneMesh.new();p.size=size;n.mesh=p;n.material_override=mat;n.position=at;n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;geometry.add_child(n);return n
func _ground():
 # Calm route, café forecourt and far-bank continuation; substrate covers tile-to-bank and forecourt joins.
 plane_mesh("StreetStoneSubstrate",Vector2(3.15,16.0),Vector3(.025,-.025,3.0),materials.Cream_Stone)
 plane_mesh("CafeForecourtSubstrate",Vector2(4.4,4.2),Vector3(-3.3,-.025,4.5),materials.Cream_Stone)
 plane_mesh("FarBankSubstrate",Vector2(1.65,14.0),Vector3(6.125,-.025,0),materials.Cream_Stone)
 for z in range(-4,12,2):
  for x in [-.65,.65]:instance("Ground_Stone_A",Vector3(x,-.002,z),0,Vector3(.65,1,1))
 for z in [3.7,5.7]:
  for x in [-4.6,-2.6]:instance("Ground_Stone_A",Vector3(x,-.003,z))
 for z in range(-6,8,2):instance("Ground_Stone_A",Vector3(6.10,-.002,z),0,Vector3(.85,1,1))
 plane_mesh("QuietEarthLeft",Vector2(4.1,17),Vector3(-3.65,-.11,2.5),materials.QuietEarth)
 plane_mesh("QuietEarthFarBank",Vector2(2.2,17),Vector3(6.65,-.115,2.5),materials.QuietEarth)

func _river():
 var m:=ShaderMaterial.new();m.shader=load(KIT+"water.gdshader");m.resource_name="WC_RIVER_MAT_Water"
 water=plane_mesh("QuietMovingRiver",Vector2(3.35,18),Vector3(3.46,-.62,2.0),m)
 for z in [-6,-4,-2,0,4.3,6.3,8.3,10.3]:
  instance("Bank_PathTransition_A" if z==-4 else ("Bank_Vegetation_A" if int(z)%4==0 else "Bank_Straight_A"),Vector3(1.72,0,z),PI/2)
 for z in [-6,-4,-2,0,4.3,6.3,8.3,10.3]:instance("Bank_Straight_A",Vector3(5.15,0,z),PI/2)
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
 instance("Background_House_A",Vector3(6.1,0,-6.0),-.15,Vector3(.84,.84,.84))

func _vegetation():
 groups.tree=instance("Tree_Medium_A",Vector3(-3.2,0,8.6))
 instance("Tree_Small_A",Vector3(-5.4,0,-3.8),.4)
 instance("Tree_Medium_A",Vector3(-4.5,0,-4.6),.6,Vector3(.65,.65,.65))
 instance("Tree_Medium_A",Vector3(7.3,0,-5.3),-.5,Vector3(.60,.60,.60))
 instance("Tree_Small_A",Vector3(7.0,0,5.8),-.7)
 instance("Potted_Plant_A",Vector3(-2.86,0,3.20))
 instance("Potted_Plant_A",Vector3(-5.34,0,3.23),.6,Vector3(.8,.8,.8))
 for z in [-6,-1,5.6,9.8]:instance("Grass_Bank_A",Vector3(1.70,-.38,z),.3)
 instance("Bench_Cedar_A",Vector3(-2.40,0,7.35),-.1)

func _camera_lights():
 camera=Camera3D.new();camera.name="PortraitGameplayCamera";camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.keep_aspect=Camera3D.KEEP_WIDTH;camera.size=13.4;camera.near=.1;camera.far=60;add_child(camera);camera.position=Vector3(5.5,13.0,21.0);camera.look_at(Vector3(.65,.75,3.2));camera.current=true
 environment=WorldEnvironment.new();environment.name="QuietOutdoorEnvironment";var e:=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color("#EAE6DA");e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color("#E5E9E6");e.ambient_light_energy=.47;e.reflected_light_source=Environment.REFLECTION_SOURCE_DISABLED;e.tonemap_mode=Environment.TONE_MAPPER_LINEAR;e.glow_enabled=false;e.ssao_enabled=false;e.fog_enabled=false;environment.environment=e;add_child(environment)
 key_light=DirectionalLight3D.new();key_light.name="LateMorningSoftKey";key_light.rotation_degrees=Vector3(-58,-28,0);key_light.light_color=Color("#FFF7ED");key_light.light_energy=.90;key_light.shadow_enabled=true;key_light.shadow_opacity=.40;key_light.shadow_blur=4;key_light.shadow_bias=.012;key_light.shadow_normal_bias=.14;key_light.directional_shadow_max_distance=45;key_light.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL;add_child(key_light)
 practical=OmniLight3D.new();practical.name="CafePracticalAccent";practical.position=Vector3(-1.54,1.64,3.10);practical.light_color=Color("#F3DBB9");practical.light_energy=.32;practical.omni_range=1.6;practical.shadow_enabled=false;add_child(practical)

func _gameplay():
 gameplay=Node2D.new();gameplay.name="GameplayRootDEV_Vector2Authority";gameplay.visible=false;add_child(gameplay)
 var rectangles:Array=[Rect2(-1.45,-4.8,2.8,15.6),Rect2(-5.5,2.90,4.4,3.4),Rect2(1.0,1.38,4.7,1.54),Rect2(5.4,-6.2,1.4,13.0),Rect2(-2.61,1.53,1.01,2.6)]
 var merged:Array=[]
 for r in rectangles:
  var p:=PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
  if merged.is_empty():merged=[p]
  else:merged=Geometry2D.merge_polygons(merged[0],p)
  assert(merged.size()==1,"DEV walkable corridors must form one connected polygon")
 route_world=merged[0];route_outline=PackedVector2Array()
 for v in route_world:route_outline.append(v/UNIT)
 var nav:=NavigationRegion2D.new();nav.name="DEVRouteNavigation";var poly:=NavigationPolygon.new();poly.agent_radius=11;poly.cell_size=2;poly.add_outline(route_outline);var source:=NavigationMeshSourceGeometryData2D.new();NavigationServer2D.bake_from_source_geometry_data(poly,source);nav.navigation_polygon=poly;gameplay.add_child(nav)
 actor=make_actor("OrangeProtagonist",Vector2(-.1,9.0)/UNIT)
 npc=make_actor("FutureNPCWidthProxy",Vector2(.55,5.0)/UNIT)
 npc.visible=false
func make_actor(label:String,at:Vector2)->HardeningActor:
 var a:=HardeningActor.new();a.name=label;a.position=at;a.move_speed=175
 var agent:=NavigationAgent2D.new();agent.name="NavigationAgent2D";agent.radius=9;a.add_child(agent)
 var col:=CollisionShape2D.new();col.name="CollisionShape2D";var circle:=CircleShape2D.new();circle.radius=9;col.shape=circle;a.add_child(col);gameplay.add_child(a);return a

func spriteframes()->SpriteFrames:
 var frames:=SpriteFrames.new()
 for direction in ["down","up","left","right"]:
  var count:=3 if direction=="down" else 4
  for action in ["idle","walk"]:
   var key:String=action+"_"+direction;frames.add_animation(key);frames.set_animation_speed(key,2.0 if action=="idle" else 8.0);frames.set_animation_loop(key,true)
   for i in range(0 if action=="idle" else 1,1 if action=="idle" else count):
    var region:=AtlasTexture.new();region.atlas=load(ART+"orange_"+direction+".png");region.region=Rect2(i*256,0,256,256);frames.add_frame(key,region)
 return frames
func new_cat(frames:SpriteFrames)->AnimatedSprite3D:
 var s:=AnimatedSprite3D.new();s.sprite_frames=frames;s.pixel_size=.44*UNIT;s.offset=Vector2(0,104);s.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y;s.scale.y=1/absf(camera.global_basis.y.y);s.alpha_cut=SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS;s.shaded=false;s.no_depth_test=false;s.modulate=Color(.97,.985,.97);s.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;s.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;add_child(s);s.play("idle_down");return s
func shadow(at:Vector3)->Sprite3D:
 var s:=Sprite3D.new();s.texture=load(ART+"contact_shadow.png");s.pixel_size=.005;s.rotation_degrees.x=-90;s.modulate=Color(1,1,1,.25);s.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;s.position=at+Vector3(0,.011,0);add_child(s);return s
func _cat():
 source_sprite=AnimatedSprite2D.new();source_sprite.name="OriginalOrangeClips";source_sprite.sprite_frames=spriteframes();gameplay.add_child(source_sprite);source_sprite.play("idle_down")
 cat=new_cat(source_sprite.sprite_frames);cat.name="VisualRootOrangeSprite3D";contact=shadow(point(actor.position))
 npc_cat=new_cat(source_sprite.sprite_frames);npc_cat.name="OptionalNPCScaleProxy";npc_cat.visible=false

func _physics_process(_delta):
 if not ready_for_review:return
 var clip:="idle_down"
 if actor.phase!=HardeningActor.Phase.IDLE:
  var v:Vector2=actor.velocity;var facing:String=("left" if v.x<0 else "right") if absf(v.x)>absf(v.y) else ("up" if v.y<0 else "down");clip="walk_"+facing
 if source_sprite.animation!=clip:source_sprite.play(clip)
 cat.animation=source_sprite.animation;cat.frame=source_sprite.frame;cat.frame_progress=source_sprite.frame_progress;cat.position=point(actor.global_position);contact.position=cat.position+Vector3(0,.011,0);npc_cat.position=point(npc.global_position)
 ticks+=1
 if touring or actor.phase!=HardeningActor.Phase.IDLE:trace.append({"time_ms":Time.get_ticks_msec(),"xy":[actor.position.x,actor.position.y],"xyz":[cat.position.x,cat.position.y,cat.position.z],"clip":String(cat.animation),"frame":cat.frame})

func request_walk(p:Vector2)->bool:
 if not Geometry2D.is_point_in_polygon(p,route_outline):return false
 if actor.phase!=HardeningActor.Phase.IDLE:actor.cancel_action(&"dev_retarget")
 var marker:=Marker2D.new();marker.position=p;gameplay.add_child(marker);actor.route_completed.connect(marker.queue_free,CONNECT_ONE_SHOT);return actor.navigate_to_marker(marker)
func start_tour():
 if touring:return
 touring=true;tour_results=[];trace=[]
 for row in [{"label":"cafe_entrance","point":Vector2(-2.14,2.24)},{"label":"home_street","point":Vector2(-.32,4.70)},{"label":"river_walk","point":Vector2(.85,3.6)},{"label":"bridge_middle","point":Vector2(3.44,2.15)},{"label":"far_bank","point":Vector2(6.1,2.15)},{"label":"continuation","point":Vector2(6.1,-1.20)},{"label":"bridge_return","point":Vector2(3.44,2.15)},{"label":"street_return","point":Vector2(-.15,8.4)}]:
  var accepted:=request_walk(row.point/UNIT)
  for i in 2000:
   await get_tree().physics_frame
   if actor.phase==HardeningActor.Phase.IDLE:break
  var success:bool=accepted and not actor.failed_navigation and actor.phase==HardeningActor.Phase.IDLE
  tour_results.append({"label":row.label,"accepted":accepted,"success":success,"xy":actor.position});status.text="Willi · "+String(row.label).replace("_"," ");checkpoint.emit(row.label);await get_tree().create_timer(.55).timeout
 touring=false;status.text="DEV · click path to walk"

func _unhandled_input(event:InputEvent):
 if not ready_for_review or touring:return
 var screen:Variant=null
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:screen=event.position
 elif event is InputEventScreenTouch and event.pressed:screen=event.position
 if screen==null:return
 var hit:Variant=Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
 if hit!=null:request_walk(xy(hit))

func _ui():
 controls=CanvasLayer.new();controls.name="DEVControls";add_child(controls)
 status=Label.new();status.text="WilliCat · Riverside DEV";status.position=Vector2(18,16);status.add_theme_font_size_override("font_size",15);status.add_theme_color_override("font_color",Color("#352C28"));controls.add_child(status)
 var row:=HBoxContainer.new();row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);row.offset_top=-52;row.offset_left=14;row.offset_right=-14;controls.add_child(row)
 for title in ["Walk route","Route debug","NPC width"]:
  var b:=Button.new();b.text=title;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(b)
  if title=="Walk route":b.pressed.connect(start_tour)
  elif title=="Route debug":b.pressed.connect(func():debug_route.visible=not debug_route.visible)
  else:b.pressed.connect(func():npc_cat.visible=not npc_cat.visible)
func _debug():
 var mesh:=ImmediateMesh.new();mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
 for v in route_world:mesh.surface_add_vertex(Vector3(v.x,.075,v.y))
 mesh.surface_add_vertex(Vector3(route_world[0].x,.075,route_world[0].y));mesh.surface_end()
 var m:=StandardMaterial3D.new();m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;m.albedo_color=Color("#4DE9C7");debug_route=MeshInstance3D.new();debug_route.name="DEVWalkableOutline";debug_route.mesh=mesh;debug_route.material_override=m;debug_route.visible=false;add_child(debug_route)
func authority_hash()->String:
 var payload:={"scope":"DEV authority only; continuous Home never instantiated or changed","route":route_outline,"actor_radius":9,"mapping":UNIT,"cafe_aperture":[-2.68,-1.60,2.70],"bridge_endpoints":[1.74,5.14,2.15]}
 var h:=HashingContext.new();h.start(HashingContext.HASH_SHA256);h.update(var_to_bytes(payload));return h.finish().hex_encode()

func complexity()->Dictionary:
 var meshes:=0;var tris:=0;var surfaces:=0;var mats:Dictionary={};var tex:Dictionary={};var shaders:Dictionary={};var transparent:=0;var casters:=0
 for n in geometry.find_children("*","MeshInstance3D",true,false):
  if not n.is_visible_in_tree():continue
  meshes+=1;tris+=n.mesh.get_faces().size()/3;surfaces+=n.mesh.get_surface_count()
  if n.cast_shadow!=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:casters+=1
  for i in n.mesh.get_surface_count():
   var mat:Material=n.get_active_material(i);mats[mat.get_instance_id()]=mat.resource_name
   if mat is ShaderMaterial:
    shaders[mat.shader.get_instance_id()]=mat.shader.resource_path
    var t=mat.get_shader_parameter("painted_albedo")
    if t is Texture2D:tex[t.resource_path]=[t.get_width(),t.get_height()]
   elif mat is BaseMaterial3D and mat.transparency!=BaseMaterial3D.TRANSPARENCY_DISABLED:transparent+=1
 return {"visible_mesh_instances":meshes,"geometry_triangles":tris,"surfaces":surfaces,"active_materials":mats.size(),"material_names":mats.values(),"geometry_texture_sources":tex,"geometry_shader_variants":shaders.values(),"transparent_geometry_surfaces":transparent,"mesh_shadow_casters":casters,"lights":2,"shadow_lights":1,"actor_sprite_texture_sources":5,"runtime_draw_indicator":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"renderer":RenderingServer.get_current_rendering_method(),"driver":RenderingServer.get_current_rendering_driver_name(),"device":RenderingServer.get_video_adapter_name(),"godot":Engine.get_version_info()}
