extends Node3D
## DEV-only presentation projection of the untouched 2D Home gameplay authority.
const WORLD=preload("res://scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn")
const G=preload("res://scripts/dev/hybrid_diorama/diorama_geometry.gd")
const UNIT:=.01 # Reversible DEV presentation unit. Not a new gameplay measurement.
var authority_world
var slice
var actor:HardeningActor
var source_sprite:AnimatedSprite2D
var cat:AnimatedSprite3D
var contact:Sprite3D
var camera:Camera3D
var environment:WorldEnvironment
var key_light:DirectionalLight3D
var practical:OmniLight3D
var geometry:Node3D
var groups:Dictionary={}
var materials:Dictionary={}
var ready_for_review:=false
var baseline_authority:Dictionary
var touring:=false
var tour_results:Array=[]
var trace:Array=[]
var click_marker:Marker2D
var status:Label
var baseline_mode:=false
var cat_mode:="camera_facing"
var lighting_mode:="key_ambient_practical"
var unbatched_triangle_count:=0
var batched_triangle_count:=0
signal checkpoint(label:String)
func _ready():install.call_deferred()
func project_point(point:Vector2,elevation:=0.0)->Vector3:return Vector3(point.x*UNIT,elevation,point.y*UNIT)
func unproject_point(point:Vector3)->Vector2:return Vector2(point.x,point.z)/UNIT
func pick(screen:Vector2)->Variant:
 var o:=camera.project_ray_origin(screen);var d:=camera.project_ray_normal(screen)
 return Plane(Vector3.UP,0).intersects_ray(o,d)
func group(id:String,point:=Vector3.ZERO)->Node3D:
 var n:=Node3D.new();n.name=id;n.position=point;geometry.add_child(n);groups[id]=n;return n
func install():
 authority_world=WORLD.instantiate();authority_world.name="GameplayAuthority2D";add_child(authority_world);slice=authority_world.get_node("CafeInteriorVisualSlice")
 for i in 180:
  await get_tree().process_frame
  if slice.projection_applied and slice.ready_for_review:break
 assert(slice.projection_applied and slice.ready_for_review)
 baseline_authority=slice.authority().duplicate(true)
 authority_world.visible=false;slice.get_node("CafeReviewControls").visible=false;slice.set_process_unhandled_input(false)
 actor=authority_world.actors.get_node("Visitor");source_sprite=slice.avatars.Visitor.find_children("*","AnimatedSprite2D",true,false)[0]
 geometry=Node3D.new();geometry.name="DioramaVisualRoot";add_child(geometry)
 _materials();_architecture();_counter();_table();_chair("chair_a");_chair("chair_b");_plant();_lamp();_batch_static();_camera_lights();_cat();_ui()
 ready_for_review=true;assert(slice.authority()==baseline_authority)
func _materials():
 var cedar=load("res://assets/dev_review/cafe_visual_recovery_v1/runtime/cedar_post_face.png")
 var plaster=load("res://assets/dev_review/cafe_interior_kit_v1/runtime/wall_plain.png")
 var cloth=load("res://assets/dev_review/cafe_visual_recovery_v1/runtime/seating_rug.png")
 materials.wood=G.material(Color("#C68F5E"),cedar,Vector4(.2,.1,.6,.8),Vector2(.7,1.2),.50)
 materials.wood_dark=G.material(Color("#583F2E"),cedar,Vector4(.2,.1,.6,.8),Vector2.ONE,.4)
 materials.wood_light=G.material(Color("#D0A173"),cedar,Vector4(.2,.1,.6,.8),Vector2(.4,1.0),.45)
 materials.plaster=G.material(Color("#F3DEC7"),plaster,Vector4(.23,.18,.54,.60),Vector2.ONE,.15)
 materials.fabric=G.material(Color("#768658"),cloth,Vector4(.30,.30,.2,.2),Vector2.ONE,.25)
 materials.ceramic=G.material(Color("#CAAF93"));materials.trim=G.material(Color("#352C28"));materials.paper=G.material(Color("#FAE5C7"))
 materials.leaf=G.material(Color("#657D49"));materials.leaf_light=G.material(Color("#768658"));materials.leaf_dark=G.material(Color("#415A3E"))
 var floor:=StandardMaterial3D.new();floor.albedo_texture=load("res://assets/dev_review/cafe_interior_kit_v1/runtime/floor_quiet.png");floor.uv1_scale=Vector3(4,6,1);floor.texture_repeat=true;floor.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;floor.roughness=.96;floor.specular_mode=BaseMaterial3D.SPECULAR_DISABLED;materials.floor=floor
func _architecture():
 var floor=group("Floor");G.bevel(floor,"FloorEdge",Vector3(6.4,.18,10.0),materials.wood_dark,Vector3(3.2,-.09,5.0),.025)
 var plane:=PlaneMesh.new();plane.size=Vector2(6.4,10.0);G.node(floor,"CedarFloor",plane,materials.floor,Vector3(3.2,.002,5.0))
 var rear=group("RearArchitecture")
 G.bevel(rear,"CreamPlaster",Vector3(6.4,2.48,.14),materials.plaster,Vector3(3.2,1.24,-.08))
 for x in [.05,3.2,6.35]:G.bevel(rear,"CedarPost",Vector3(.14,2.62,.22),materials.wood_dark,Vector3(x,1.31,.02))
 for y in [.15,1.10,2.46]:G.bevel(rear,"CedarRail",Vector3(6.4,.12,.22),materials.wood,Vector3(3.2,y,.035))
 # Optional single shoji window and shelf, constructed as genuine volumes, no imported image of a room.
 G.bevel(rear,"ShojiPaper",Vector3(1.30,1.42,.055),materials.paper,Vector3(1.13,1.43,.025))
 for x in [.48,.805,1.13,1.455,1.78]:G.bevel(rear,"WindowVertical",Vector3(.042,1.48,.085),materials.wood,Vector3(x,1.43,.073),.004)
 for y in [.69,1.06,1.43,1.80,2.17]:G.bevel(rear,"WindowHorizontal",Vector3(1.38,.042,.085),materials.wood,Vector3(1.13,y,.073),.004)
 G.bevel(rear,"SingleShelf",Vector3(2.65,.11,.35),materials.wood,Vector3(4.57,1.30,.22))
 for x in [3.5,5.6]:G.bevel(rear,"ShelfBracket",Vector3(.085,.28,.22),materials.wood_dark,Vector3(x,1.13,.14))
 for i in 5:G.cylinder(rear,"CeramicJar",.09,.10,.21,materials.ceramic,Vector3(3.72+i*.39,1.46,.21),16)
func _counter():
 var obj=authority_world.find_object(&"counter_shell");var bounds:Rect2=obj.get_node("PhysicalFootprint").global_bounds()
 var c=group("counter_shell",project_point(obj.global_position));c.set_meta("stable_id",obj.stable_id)
 var size:=Vector3(bounds.size.x*UNIT,1.04,bounds.size.y*UNIT);var center:Vector3=project_point(bounds.get_center())-c.position
 G.bevel(c,"CounterBody",Vector3(size.x,.97,size.z),materials.wood_dark,center+Vector3(0,.515,0))
 G.bevel(c,"CounterTop",Vector3(size.x+.12,.10,size.z+.13),materials.wood_light,center+Vector3(0,1.045,0))
 var count:=maxi(3,roundi(size.x/.19))
 for i in count:G.bevel(c,"CedarFaceBoard",Vector3(size.x/count-.014,.81,.035),materials.wood,center+Vector3(-size.x/2+(i+.5)*size.x/count,.54,size.z/2+.019),.007)
 G.bevel(c,"BottomRail",Vector3(size.x,.08,.055),materials.wood_light,center+Vector3(0,.115,size.z/2+.035),.008)
 G.bevel(c,"FaceHeader",Vector3(size.x,.065,.05),materials.wood,center+Vector3(0,.975,size.z/2+.03),.008)
 # Tiny ceramic tray, no additional gameplay object or machine semantics.
 G.cylinder(c,"Cup",.07,.055,.105,materials.paper,center+Vector3(.2,1.145,.13),20)
 G.cylinder(c,"Saucer",.105,.105,.018,materials.ceramic,center+Vector3(.2,1.10,.13),24)
func _table():
 var obj=authority_world.find_object(&"table_a");var t=group("table_a",project_point(obj.global_position));t.set_meta("stable_id",obj.stable_id)
 # Ground extent follows the authoritative footprint; 2D artwork extent is not a 3D collision size.
 var bounds:Rect2=obj.get_node("PhysicalFootprint").global_bounds()
 var shape:=Node3D.new();shape.name="FootprintRegisteredTable";shape.position=project_point(bounds.get_center())-t.position;shape.scale=Vector3(bounds.size.x*UNIT/1.76,1,bounds.size.y*UNIT/1.76);t.add_child(shape);t=shape
 G.cylinder(t,"TableTop",.87,.88,.10,materials.wood_light,Vector3(0,.85,0),48)
 G.cylinder(t,"TableLip",.86,.85,.055,materials.wood_dark,Vector3(0,.777,0),48)
 G.cylinder(t,"TurnedPedestal",.12,.15,.59,materials.wood,Vector3(0,.43,0),24)
 G.cylinder(t,"PedestalCollar",.22,.15,.09,materials.wood_light,Vector3(0,.715,0),24)
 for i in 4:
  var a:=i*TAU/4;G.rod(t,"SplayedFoot",Vector3(0,.23,0),Vector3(cos(a)*.45,.065,sin(a)*.45),.065,materials.wood_dark)
 # Separate shallow ceramic cup and saucer give scale, without copying the reference composition.
 G.cylinder(t,"Saucer",.14,.14,.022,materials.ceramic,Vector3(.18,.915,-.12),24)
 G.cylinder(t,"Cup",.095,.073,.15,materials.paper,Vector3(.18,1.005,-.12),24)
 G.cylinder(t,"Coffee",.084,.084,.004,materials.trim,Vector3(.18,1.083,-.12),24)
func _chair(id:String):
 var obj=authority_world.find_object(StringName(id));var c=group(id,project_point(obj.global_position));c.set_meta("stable_id",obj.stable_id)
 # The two existing chair roots/seat anchors are read only. DEV mesh facing matches their authored pair.
 c.rotation.y=-.32 if id=="chair_a" else .32
 G.bevel(c,"SeatCedar",Vector3(.52,.075,.49),materials.wood,Vector3(0,.45,0))
 G.bevel(c,"SageCushion",Vector3(.46,.07,.43),materials.fabric,Vector3(0,.52,0),.032)
 for x in [-.205,.205]:
  for z in [-.18,.18]:G.rod(c,"ChairLeg",Vector3(x*1.16,.04,z*1.12),Vector3(x,.45,z),.035,materials.wood_dark)
 for x in [-.24,.24]:G.rod(c,"BackPost",Vector3(x,.46,.22),Vector3(x,1.00,.25),.033,materials.wood)
 G.bevel(c,"TopBackRail",Vector3(.55,.10,.075),materials.wood_light,Vector3(0,1.005,.25))
 for x in [-.14,0,.14]:G.bevel(c,"BackSlat",Vector3(.04,.36,.035),materials.wood,Vector3(x,.78,.235),.007)
func _plant():
 var obj=authority_world.find_object(&"plant");var p=group("plant",project_point(obj.global_position));p.set_meta("stable_id",obj.stable_id)
 G.cylinder(p,"StonewarePot",.27,.19,.46,materials.ceramic,Vector3(0,.23,0),32)
 G.cylinder(p,"PotRim",.29,.27,.06,materials.paper,Vector3(0,.465,0),32)
 G.cylinder(p,"Soil",.245,.245,.01,materials.wood_dark,Vector3(0,.46,0),24)
 for i in 11:
  var angle:=i*2.399;var height:=.71+.13*sin(i*1.47);var tip:=Vector3(cos(angle)*.35,height,sin(angle)*.33)
  G.rod(p,"PlantStem",Vector3(0,.46,0),tip,.01,materials.leaf_dark)
  var leaf=G.sphere(p,"Leaf",Vector3(.18,.10,.44),[materials.leaf,materials.leaf_light,materials.leaf_dark][i%3],tip);leaf.rotation=Vector3(.3*cos(angle),angle,.18*sin(angle))
func _lamp():
 var l=group("PracticalLamp",Vector3(4.15,0,.45))
 G.rod(l,"Cord",Vector3(0,2.8,0),Vector3(0,2.16,0),.012,materials.trim)
 var shade=G.cylinder(l,"PaperLantern",.15,.19,.37,materials.paper,Vector3(0,1.98,0),32)
 for i in 7:
  var mesh:=TorusMesh.new();mesh.inner_radius=.170;mesh.outer_radius=.178;mesh.rings=32;mesh.ring_segments=8
  G.node(l,"LanternRib",mesh,materials.wood_light,Vector3(0,1.83+i*.046,0))
 practical=OmniLight3D.new();practical.name="WarmPractical";practical.position=Vector3(0,1.81,.20);practical.light_color=Color("#F7C483");practical.light_energy=.33;practical.omni_range=2.1;practical.shadow_enabled=false;l.add_child(practical)
func _camera_lights():
 camera=Camera3D.new();camera.name="FixedOrthographicCamera";camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.keep_aspect=Camera3D.KEEP_WIDTH;camera.size=7.0;camera.near=.1;camera.far=45
 add_child(camera);camera.position=Vector3(3.2,10.3,17.0);camera.look_at(Vector3(3.2,.45,4.3));camera.current=true
 environment=WorldEnvironment.new();var e:=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color("#EBE3D5");e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color("#EBE7E0");e.ambient_light_energy=.35;e.reflected_light_source=Environment.REFLECTION_SOURCE_DISABLED;e.tonemap_mode=Environment.TONE_MAPPER_LINEAR;e.ssao_enabled=false;e.glow_enabled=false;environment.environment=e;add_child(environment)
 key_light=DirectionalLight3D.new();key_light.name="SingleSoftKey";key_light.rotation_degrees=Vector3(-58,-28,0);key_light.light_color=Color("#FFFDF8");key_light.light_energy=.58;key_light.shadow_enabled=true;key_light.shadow_blur=2.0;key_light.shadow_opacity=.58;key_light.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL;key_light.directional_shadow_max_distance=25;key_light.shadow_bias=.08;key_light.shadow_normal_bias=.7;add_child(key_light)
func _cat():
 cat=AnimatedSprite3D.new();cat.name="ExistingOrangeCat3D";cat.sprite_frames=source_sprite.sprite_frames;cat.pixel_size=source_sprite.scale.x*UNIT;cat.offset=Vector2(0,104);cat.billboard=BaseMaterial3D.BILLBOARD_ENABLED;cat.alpha_cut=SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS;cat.shaded=false;cat.no_depth_test=false;cat.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;cat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;add_child(cat)
 contact=Sprite3D.new();contact.name="FloorContactShadow";contact.texture=load("res://assets/first_party/storybook_mini_pack_001/normalized/contact_shadow.png");contact.pixel_size=.005;contact.rotation_degrees.x=-90;contact.modulate=Color(1,1,1,.32);contact.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(contact)
func set_cat_mode(mode:String):
 cat_mode=mode
 cat.billboard=BaseMaterial3D.BILLBOARD_ENABLED if mode=="camera_facing" else BaseMaterial3D.BILLBOARD_FIXED_Y if mode=="upright" else BaseMaterial3D.BILLBOARD_DISABLED
 if mode=="fixed_facing":cat.rotation=camera.rotation
func set_lighting(mode:String):
 lighting_mode=mode;key_light.visible=mode!="ambient_only";practical.visible=mode=="key_ambient_practical"
func toggle_baseline():
 baseline_mode=not baseline_mode;geometry.visible=not baseline_mode;cat.visible=not baseline_mode;contact.visible=not baseline_mode;authority_world.visible=baseline_mode
 status.text="Approved 2D café baseline" if baseline_mode else "Hybrid 3D feasibility · not production"
func _ui():
 var canvas:=CanvasLayer.new();canvas.name="DiagnosticControls";add_child(canvas)
 var box:=VBoxContainer.new();box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE);box.offset_left=18;box.offset_top=12;canvas.add_child(box)
 var title:=Label.new();title.text="WilliCat · Café diorama";title.add_theme_font_size_override("font_size",20);title.add_theme_color_override("font_color",Color("#352C28"));box.add_child(title)
 status=Label.new();status.text="Hybrid 3D feasibility · not production";status.add_theme_color_override("font_color",Color("#583F2E"));status.add_theme_font_size_override("font_size",12);box.add_child(status)
 var bottom:=HBoxContainer.new();bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);bottom.offset_top=-58;bottom.offset_left=18;bottom.offset_right=-18;bottom.add_theme_constant_override("separation",8);canvas.add_child(bottom)
 for label in ["Depth walk","2D / Hybrid"]:
  var b:=Button.new();b.text=label;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;var sb:=StyleBoxFlat.new();sb.bg_color=Color("#526F4E");sb.set_corner_radius_all(10);sb.content_margin_top=10;sb.content_margin_bottom=10;b.add_theme_stylebox_override("normal",sb);b.add_theme_color_override("font_color",Color("#FAE5C7"));bottom.add_child(b)
  if label=="Depth walk":b.pressed.connect(start_tour)
  else:b.pressed.connect(toggle_baseline)
func _process(_delta:float):
 if ready_for_review:_sync_cat.call_deferred()
func _sync_cat():
 if not ready_for_review:return
 cat.position=project_point(actor.global_position);contact.position=cat.position+Vector3(0,.009,0)
 if cat.animation!=source_sprite.animation:cat.animation=source_sprite.animation
 cat.frame=source_sprite.frame;cat.frame_progress=source_sprite.frame_progress
func start_tour():
 if touring or not ready_for_review:return
 touring=true;tour_results=[]
 # Existing café walk targets, existing actor, original 2D navigation; no 3D body or navigation world.
 var rows:Array=slice.tour_points()
 var chair=authority_world.find_object(&"chair_a");var chair_bounds:Rect2=chair.get_node("PhysicalFootprint").global_bounds();var radius:float=actor.get_node("CollisionShape2D").shape.radius
 rows.insert(4,{"label":"chair_back","point":Vector2(chair.global_position.x,chair_bounds.position.y-radius-14)})
 for row in rows:
  var marker:=Marker2D.new();marker.position=row.point;slice.add_child(marker)
  var accepted:=actor.navigate_to_marker(marker)
  if accepted:
   for i in 1500:
    await get_tree().physics_frame
    trace.append({"time_ms":Time.get_ticks_msec(),"label":row.label,"xy":[actor.global_position.x,actor.global_position.y],"xyz":[cat.position.x,cat.position.y,cat.position.z],"clip":cat.animation,"frame":cat.frame})
    if actor.phase==HardeningActor.Phase.IDLE:break
  var success:=accepted and not actor.failed_navigation and actor.phase==HardeningActor.Phase.IDLE
  tour_results.append({"label":row.label,"accepted":accepted,"success":success,"xy":actor.global_position})
  status.text="Willi explores · "+String(row.label).replace("_"," ");checkpoint.emit(row.label)
  await get_tree().create_timer(.65).timeout;marker.queue_free()
 touring=false;status.text="Hybrid 3D feasibility · not production";assert(slice.authority()==baseline_authority)
func _unhandled_input(event:InputEvent):
 if not ready_for_review or touring or baseline_mode:return
 var screen:Variant=null
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:screen=event.position
 elif event is InputEventScreenTouch and event.pressed:screen=event.position
 if screen==null:return
 var p=pick(screen)
 if p==null:return
 var point:=unproject_point(p)
 if not Rect2(35,70,570,900).has_point(point):return
 if is_instance_valid(click_marker):click_marker.queue_free()
 click_marker=Marker2D.new();click_marker.position=point;slice.add_child(click_marker);actor.cancel_action(&"hybrid_visual_pick");actor.navigate_to_marker(click_marker)

func _batch_static():
 # Merge repeated construction pieces per semantic object/material. Keep depth-test groups inspectable.
 for owner in groups.values():
  var buckets:Dictionary={}
  var nodes=owner.find_children("*","MeshInstance3D",true,false)
  for n in nodes:unbatched_triangle_count+=n.mesh.get_faces().size()/3
  for n in nodes:
   var mat:Material=n.material_override
   if not buckets.has(mat):
    var tool:=SurfaceTool.new();tool.begin(Mesh.PRIMITIVE_TRIANGLES);buckets[mat]=tool
   var transform:Transform3D=owner.global_transform.affine_inverse()*n.global_transform
   for surface in n.mesh.get_surface_count():
    var arrays:Array=n.mesh.surface_get_arrays(surface)
    if arrays[Mesh.ARRAY_COLOR]==null or arrays[Mesh.ARRAY_COLOR].is_empty():
     var colors:=PackedColorArray();colors.resize(arrays[Mesh.ARRAY_VERTEX].size());colors.fill(Color.WHITE);arrays[Mesh.ARRAY_COLOR]=colors
    if arrays[Mesh.ARRAY_INDEX]==null or arrays[Mesh.ARRAY_INDEX].is_empty():
     var indices:=PackedInt32Array();indices.resize(arrays[Mesh.ARRAY_VERTEX].size())
     for i in indices.size():indices[i]=i
     arrays[Mesh.ARRAY_INDEX]=indices
    var normalized:=ArrayMesh.new();normalized.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
    buckets[mat].append_from(normalized,0,transform)
  for n in nodes:n.get_parent().remove_child(n);n.free()
  var index:=0
  for mat in buckets:
   G.node(owner,"StaticMaterialBatch_"+str(index),buckets[mat].commit(),mat,Vector3.ZERO);index+=1

 for n in geometry.find_children("*","MeshInstance3D",true,false):batched_triangle_count+=n.mesh.get_faces().size()/3
 assert(unbatched_triangle_count==batched_triangle_count,"Static batching dropped geometry")
