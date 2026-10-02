extends "res://scripts/dev/hybrid_diorama/hybrid_diorama.gd"
## Isolated high-fidelity presentation. Original Vector2 authority stays untouched.
const F=preload("res://scripts/dev/stylized_fidelity/authored_forms.gd")
var auto_hero:=true
var cat_presentation:="ambient_tinted"
var contact_mode:="hybrid_contact"
var authored_piece_count:=0
var proof_camera_transform:Transform3D
var proof_camera_size:=0.0
func painted(file:String,tint:=Color.WHITE,scale:=1.0)->ShaderMaterial:
 var m:=ShaderMaterial.new();m.shader=load("res://scripts/dev/stylized_fidelity/painted_albedo.gdshader");m.set_shader_parameter("painted_texture",load("res://assets/dev_review/stylized_fidelity_v1/"+file+".png"));m.set_shader_parameter("color_tint",tint);m.set_shader_parameter("tex_scale",scale);return m
func _materials():
 materials.wood=painted("cedar_painted",Color(.98,1.02,1.08),.42)
 materials.wood_light=painted("cedar_painted",Color(1.09,1.13,1.18),.40)
 materials.wood_dark=painted("cedar_painted",Color(.61,.64,.70),.45)
 materials.plaster=painted("plaster_painted",Color.WHITE,1.0)
 materials.fabric=painted("sage_woven",Color.WHITE,3.0)
 materials.ceramic=painted("ceramic_painted",Color.WHITE,2.0)
 materials.paper=painted("plaster_painted",Color(1.03,1.02,.99),1.0)
 materials.trim=G.material(Color("#443A32"))
 materials.leaf=painted("foliage_painted",Color.WHITE,2.8)
 materials.leaf_light=painted("foliage_painted",Color(1.18,1.14,1.06),2.8)
 materials.leaf_dark=painted("foliage_painted",Color(.73,.81,.72),2.8)
 materials.ceramic_indigo=painted("ceramic_painted",Color(.47,.53,.59),2.0)
 materials.glass=G.material(Color("#99B1AB"))
func shadow(parent:Node3D,size:Vector2,at:Vector3,opacity:=.18):
 var n:=Sprite3D.new();n.name="AuthoredContactGrounding";n.texture=load("res://assets/first_party/storybook_mini_pack_001/normalized/contact_shadow.png");n.pixel_size=.01;n.rotation_degrees.x=-90;n.scale=Vector3(size.x/(n.texture.get_width()*.01),size.y/(n.texture.get_height()*.01),1);n.position=at;n.modulate=Color(.52,.45,.35,opacity);n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(n)
func _architecture():
 var floor=group("Floor")
 # One L-shaped hero floor section; cropped presentation region, never a new gameplay boundary.
 G.bevel(floor,"RearDioramaPlinth",Vector3(5.7,.20,2.35),materials.wood_dark,Vector3(3,-.12,1.525),.035)
 G.bevel(floor,"FrontDioramaPlinth",Vector3(3.47,.20,4.40),materials.wood_dark,Vector3(1.885,-.12,4.90),.035)
 for row in 22:
  var z:=.35+(row+.5)*.315
  var right:=5.84 if z<2.70 else 3.62
  var boundaries:Array=[.16,1.95,3.98,right] if row%2==0 else [.16,1.2,3.15,4.88,right]
  boundaries=boundaries.filter(func(v):return v<right);boundaries.append(right)
  for j in boundaries.size()-1:
   var lo:float=boundaries[j];var hi:float=boundaries[j+1]
   G.bevel(floor,"FloorPlank",Vector3(hi-lo-.009,.032,.309),materials.wood_light if (row+j)%9==0 else materials.wood,Vector3((lo+hi)/2,-.01,z),.006)
 # Optional single seating textile grounds the furniture without clutter.
 G.bevel(floor,"WovenSeatingRug",Vector3(2.43,.012,1.88),materials.paper,Vector3(1.75,.014,4.72),.005)
 for x in [.59,2.91]:G.bevel(floor,"SageRugBinding",Vector3(.055,.009,1.80),materials.fabric,Vector3(x,.023,4.72),.003)
 for z in [3.84,5.60]:G.bevel(floor,"SageRugBinding",Vector3(2.33,.009,.055),materials.fabric,Vector3(1.75,.023,z),.003)
 var rear=group("RearArchitecture")
 # A genuine recess/opening in a segmented wall, not a window pasted onto a solid box.
 for item in [[Vector3(.52,2.55,.20),Vector3(.45,1.275,.30)],[Vector3(3.93,2.55,.20),Vector3(3.855,1.275,.30)],[Vector3(1.4,.48,.20),Vector3(1.25,.24,.30)],[Vector3(1.4,.44,.20),Vector3(1.25,2.33,.30)]]:
  G.bevel(rear,"QuietPlaster",item[0],materials.plaster,item[1],.018)
 for x in [.18,2.03,5.82]:G.bevel(rear,"CedarJoineryPost",Vector3(.14,2.65,.28),materials.wood_dark,Vector3(x,1.31,.38),.012)
 for y in [.12,1.06,2.56]:G.bevel(rear,"FramedWallRail",Vector3(5.7,.115,.28),materials.wood,Vector3(3,y,.39),.012)
 var w=group("WindowOpening")
 G.bevel(w,"RecessPaper",Vector3(1.37,1.61,.035),materials.paper,Vector3(1.25,1.30,.19),.008)
 for x in [.54,1.96]:G.bevel(w,"WindowJamb",Vector3(.105,1.71,.22),materials.wood_dark,Vector3(x,1.30,.40),.012)
 for y in [.475,2.125]:G.bevel(w,"WindowLintel",Vector3(1.52,.095,.22),materials.wood,Vector3(1.25,y,.40),.012)
 G.bevel(w,"ProjectingSill",Vector3(1.64,.10,.42),materials.wood_light,Vector3(1.25,.47,.43),.015)
 for x in [.8,1.08,1.36,1.65]:G.bevel(w,"ShojiMullion",Vector3(.025,1.56,.075),materials.wood,Vector3(x,1.30,.37),.004)
 for y in [.84,1.23,1.62]:G.bevel(w,"ShojiRail",Vector3(1.40,.025,.075),materials.wood,Vector3(1.25,y,.37),.004)
 var shelf=group("SmallShelf")
 G.bevel(shelf,"ShelfRearFrame",Vector3(2.75,.90,.10),materials.wood_dark,Vector3(3.64,1.88,.46),.018)
 G.bevel(shelf,"ShelfRecess",Vector3(2.57,.74,.055),materials.plaster,Vector3(3.64,1.88,.52),.012)
 G.bevel(shelf,"ShelfPlank",Vector3(2.89,.105,.49),materials.wood_light,Vector3(3.64,1.47,.68),.014)
 for x in [2.49,4.82]:
  G.bevel(shelf,"ShelfBracketVertical",Vector3(.09,.35,.22),materials.wood_dark,Vector3(x,1.29,.50),.01)
  G.rod(shelf,"ShelfBracketDiagonal",Vector3(x,1.17,.49),Vector3(x,1.45,.86),.035,materials.wood)
 for i in 4:
  var pos:=Vector3(2.72+i*.43,1.525,.68)
  F.lathe(shelf,"TeaJar",[Vector2(0,0),Vector2(.10,0),Vector2(.12,.03),Vector2(.125,.22),Vector2(.09,.28),Vector2(.09,.31),Vector2(0,.31)],materials.ceramic if i%2==0 else materials.ceramic_indigo,pos)
  F.ring(shelf,"JarLid",.096,.012,materials.wood_dark,pos+Vector3(0,.30,0))
 for i in 3:G.bevel(shelf,"RecipeBook",Vector3(.065,.36+i*.025,.16),materials.fabric if i==0 else materials.wood_dark,Vector3(4.40+i*.08,1.72,.68),.009)
 # A quiet physical sign; no fantasy UI baked into the world.
 G.bevel(shelf,"QuietCafeNameBoard",Vector3(1.90,.43,.055),materials.trim,Vector3(3.65,2.05,.581),.017)
 var sign=Label3D.new();sign.text="WilliCat
Riverside Café";sign.font_size=38;sign.pixel_size=.0032;sign.modulate=Color("#E8D6B9");sign.outline_size=0;sign.position=Vector3(3.65,2.05,.622);sign.shaded=false;shelf.add_child(sign)
func _counter():
 var obj=authority_world.find_object(&"counter_shell");var bounds:Rect2=obj.get_node("PhysicalFootprint").global_bounds();var c=group("counter_shell",project_point(obj.global_position));c.set_meta("stable_id",obj.stable_id)
 # Visual service span follows recovered joined-counter artwork, not a rewritten footprint.
 var center:Vector3=project_point(bounds.get_center())-c.position+Vector3(1.10,0,0);var width:=4.38;var depth:=.55
 var body_center:Vector3=project_point(bounds.get_center())-c.position;var body_width:float=bounds.size.x*UNIT
 G.bevel(c,"CounterCore",Vector3(body_width,.91,depth),materials.wood_dark,body_center+Vector3(0,.49,0),.03)
 G.bevel(c,"ServiceSlab",Vector3(width+.13,.12,depth+.15),materials.wood_light,center+Vector3(0,1.02,0),.023)
 for i in 3:
  var panel_width:float=body_width/3
  var x:float=body_center.x-body_width/2+(i+.5)*panel_width
  G.bevel(c,"RecessedCedarPanel",Vector3(panel_width-.09,.72,.035),materials.wood,Vector3(x,.52,body_center.z+.28),.014)
  for ox in [-panel_width/2+.023,panel_width/2-.023]:G.bevel(c,"PanelStile",Vector3(.046,.83,.07),materials.wood_light,Vector3(x+ox,.51,body_center.z+.29),.008)
  for y in [.105,.915]:G.bevel(c,"PanelRail",Vector3(panel_width-.02,.055,.055),materials.wood,Vector3(x,y,body_center.z+.29),.01)
 for side in [-1,1]:G.bevel(c,"SideRecess",Vector3(.030,.71,.40),materials.wood,body_center+Vector3(side*(body_width/2-.017),.51,0),.01)
 G.bevel(c,"InsetToeKick",Vector3(body_width-.10,.07,.49),materials.trim,body_center+Vector3(0,.065,0),.012)
 shadow(c,Vector2(body_width,.72),body_center+Vector3(0,.008,0),.12)
 # The exact existing espresso obstruction supports the other end of the same bar.
 # The canonical gap remains genuinely open below the connecting countertop.
 var espresso=authority_world.find_object(&"espresso_station");var eb:Rect2=espresso.get_node("PhysicalFootprint").global_bounds()
 var support=group("espresso_station",project_point(espresso.global_position));support.set_meta("stable_id",espresso.stable_id)
 var support_center:Vector3=project_point(eb.get_center())-support.position
 G.bevel(support,"RegisteredMachineCabinet",Vector3(eb.size.x*UNIT,.93,eb.size.y*UNIT),materials.wood_dark,support_center+Vector3(0,.49,0),.028)
 G.bevel(support,"CabinetFrontPanel",Vector3(eb.size.x*UNIT-.09,.73,.026),materials.wood,support_center+Vector3(0,.51,eb.size.y*UNIT/2-.017),.014)
 shadow(support,eb.size*UNIT,support_center+Vector3(0,.009,0),.13)
 var machine=group("EspressoMachine",project_point(espresso.global_position,1.08));machine.position.z+=support_center.z
 G.bevel(machine,"CedarMachineSide",Vector3(1.02,.55,.47),materials.wood_dark,Vector3(0,.295,0),.055)
 G.bevel(machine,"CreamMachineFace",Vector3(.92,.29,.035),materials.ceramic,Vector3(0,.425,.257),.018)
 G.bevel(machine,"DarkExtractionRecess",Vector3(.84,.19,.035),materials.trim,Vector3(0,.19,.258),.025)
 G.bevel(machine,"DripTray",Vector3(.95,.045,.29),materials.trim,Vector3(0,.065,.265),.016)
 for i in 8:G.bevel(machine,"TrayGroove",Vector3(.022,.008,.24),materials.wood_dark,Vector3(-.36+i*.1,.093,.27),.002)
 for x in [-.23,.23]:
  G.cylinder(machine,"GroupHead",.065,.065,.075,materials.trim,Vector3(x,.325,.28),20)
  G.rod(machine,"PortafilterGrip",Vector3(x,.295,.31),Vector3(x+.035,.28,.49),.022,materials.wood_dark)
  cup(machine,Vector3(x,.092,.29),.60)
 for x in [-.35,.35]:
  var gauge=G.cylinder(machine,"Gauge",.055,.055,.025,materials.wood_dark,Vector3(x,.46,.286),24);gauge.rotation_degrees.x=90
  var dial=G.cylinder(machine,"GaugeFace",.042,.042,.028,materials.paper,Vector3(x,.46,.305),24);dial.rotation_degrees.x=90
  G.rod(machine,"DialHand",Vector3(x-.01,.45,.323),Vector3(x+.017,.475,.323),.004,materials.trim)
 for x in [-.14,0,.14]:G.sphere(machine,"ControlButton",Vector3(.033,.033,.015),materials.trim,Vector3(x,.45,.292))
 G.rod(machine,"SteamWand",Vector3(.46,.32,.25),Vector3(.51,.12,.38),.012,materials.trim)
 for i in 2:cup(machine,Vector3(-.22+i*.40,.57,-.01),.75)
 var tray=group("ServiceCeramics",Vector3(1.72,1.08,1.67));G.bevel(tray,"WoodServingTray",Vector3(.60,.03,.36),materials.wood_dark,Vector3.ZERO,.012);cup(tray,Vector3(-.13,.019,0),.85);cup(tray,Vector3(.13,.019,0),.85)
func cup(parent:Node3D,at:Vector3,scale_value:=1.0):
 var c:=Node3D.new();c.position=at;c.scale=Vector3.ONE*scale_value;parent.add_child(c)
 F.lathe(c,"CupBody",[Vector2(0,0),Vector2(.067,0),Vector2(.085,.025),Vector2(.101,.13),Vector2(.106,.145),Vector2(.092,.147),Vector2(.088,.132),Vector2(.073,.04),Vector2(0,.035)],materials.ceramic,Vector3.ZERO)
 G.cylinder(c,"CoffeeSurface",.088,.088,.002,materials.trim,Vector3(0,.127,0),24)
 var handle=F.ring(c,"CupHandle",.053,.013,materials.ceramic,Vector3(.117,.084,0));handle.rotation_degrees.z=90
 F.lathe(c,"Saucer",[Vector2(0,0),Vector2(.12,0),Vector2(.145,.014),Vector2(.14,.025),Vector2(.08,.02),Vector2(0,.019)],materials.ceramic,Vector3(0,-.01,0))
func _table():
 var obj=authority_world.find_object(&"table_a");var t=group("table_a",project_point(obj.global_position));t.set_meta("stable_id",obj.stable_id);var bounds:Rect2=obj.get_node("PhysicalFootprint").global_bounds();var at:Vector3=project_point(bounds.get_center())-t.position
 F.lathe(t,"BeveledTabletop",[Vector2(0,.78),Vector2(.76,.78),Vector2(.815,.797),Vector2(.825,.833),Vector2(.810,.875),Vector2(.75,.892),Vector2(0,.892)],materials.wood_light,at,64)
 F.ring(t,"TableApronBead",.73,.015,materials.wood_dark,at+Vector3(0,.775,0))
 F.lathe(t,"TurnedCedarPedestal",[Vector2(0,0),Vector2(.16,0),Vector2(.18,.07),Vector2(.13,.16),Vector2(.105,.22),Vector2(.115,.52),Vector2(.17,.61),Vector2(.26,.68),Vector2(.27,.74),Vector2(.19,.78),Vector2(0,.78)],materials.wood,at,32)
 for i in 4:
  var a:=i*TAU/4+.3;var n=G.bevel(t,"ShapedPedestalFoot",Vector3(.59,.105,.18),materials.wood_dark,at+Vector3(cos(a)*.22,.077,sin(a)*.22),.035);n.rotation.y=-a
 cup(t,at+Vector3(.22,.902,-.13),1.0)
 var vase:=at+Vector3(-.27,.90,.1);F.lathe(t,"SmallBudVase",[Vector2(0,0),Vector2(.065,0),Vector2(.105,.09),Vector2(.075,.16),Vector2(.035,.23),Vector2(.035,.28),Vector2(0,.28)],materials.ceramic_indigo,vase,24)
 for i in 3:
  var tip:=vase+Vector3((i-1)*.04,.39+i*.023,(i-1)*.04);G.rod(t,"FlowerStem",vase+Vector3(0,.26,0),tip,.006,materials.leaf_dark)
  for j in 5:G.sphere(t,"CreamPetal",Vector3(.037,.017,.035),materials.paper,tip+Vector3(cos(j*TAU/5)*.03,.01,sin(j*TAU/5)*.03))
 shadow(t,Vector2(.72,.60),at+Vector3(0,.012,0),.23)
func _chair(id:String):
 var obj=authority_world.find_object(StringName(id));var c=group(id,project_point(obj.global_position));c.set_meta("stable_id",obj.stable_id);c.rotation.y=-.28 if id=="chair_a" else .28
 G.bevel(c,"RoundedSeatFrame",Vector3(.53,.08,.49),materials.wood,Vector3(0,.44,0),.024)
 G.bevel(c,"SageUpholsteredSeat",Vector3(.46,.072,.42),materials.fabric,Vector3(0,.506,-.006),.025)
 for x in [-.20,.20]:
  for z in [-.18,.18]:
   G.rod(c,"SplayedChairLeg",Vector3(x*1.20,.025,z*1.18),Vector3(x,.445,z),.034,materials.wood_dark)
  G.rod(c,"ChairSideStretcher",Vector3(x,.19,-.19),Vector3(x,.19,.20),.016,materials.wood)
  G.rod(c,"ShapedBackPost",Vector3(x,.41,.19),Vector3(x*1.09,1.10,.28),.035,materials.wood)
 G.bevel(c,"BackCrown",Vector3(.54,.09,.09),materials.wood_light,Vector3(0,1.075,.28),.017)
 G.bevel(c,"InsetSageBack",Vector3(.38,.37,.072),materials.fabric,Vector3(0,.84,.256),.025)
 for x in [-.14,0,.14]:G.bevel(c,"BackCedarSpindle",Vector3(.027,.43,.09),materials.wood,Vector3(x,.83,.30),.007)
 shadow(c,Vector2(.58,.56),Vector3(0,.01,0),.14)
func _plant():
 var obj=authority_world.find_object(&"plant");var p=group("plant",project_point(obj.global_position));p.set_meta("stable_id",obj.stable_id)
 F.lathe(p,"ThrownStonewarePot",[Vector2(0,0),Vector2(.18,0),Vector2(.22,.03),Vector2(.285,.38),Vector2(.30,.43),Vector2(.30,.48),Vector2(.265,.49),Vector2(.245,.43),Vector2(.19,.08),Vector2(0,.08)],materials.ceramic,Vector3.ZERO,40)
 for y in [.075,.12,.41]:F.ring(p,"PotHandmadeBand",.20 if y<.2 else .283,.005,materials.wood_light,Vector3(0,y,0))
 G.cylinder(p,"PotSoil",.246,.246,.01,materials.wood_dark,Vector3(0,.43,0),32)
 for branch in 4:
  var angle:=branch*2.399;var tip:=Vector3(cos(angle)*.19,.84+branch*.10,sin(angle)*.17)
  G.rod(p,"PlantBranch",Vector3(0,.43,0),tip,.010,materials.leaf_dark)
  for j in 5:
   var a:=angle+j*1.35;var pos:=Vector3(0,.47,0).lerp(tip,.42+j*.13)
   F.leaf(p,"AuthoredLeaf",[materials.leaf,materials.leaf_light,materials.leaf_dark][(branch+j)%3],pos,Vector3(-.42,a,.10*cos(a)),.30+j*.017,.10)
 shadow(p,Vector2(.57,.48),Vector3(0,.01,0),.22)
func _lamp():
 var l=group("PracticalLamp",Vector3(4.78,0,1.1));G.rod(l,"LampCord",Vector3(0,2.83,0),Vector3(0,2.26,0),.009,materials.trim)
 F.lathe(l,"PaintedPaperLantern",[Vector2(0,1.84),Vector2(.09,1.84),Vector2(.18,1.89),Vector2(.205,2.0),Vector2(.19,2.15),Vector2(.13,2.22),Vector2(0,2.23)],materials.paper,Vector3.ZERO,40)
 for y in [1.88,1.93,1.98,2.03,2.08,2.13,2.18]:F.ring(l,"LanternThinRib",.193 if y>1.94 and y<2.14 else .16,.003,materials.wood_light,Vector3(0,y,0))
 G.cylinder(l,"LampDarkCap",.09,.085,.05,materials.trim,Vector3(0,2.245,0),24)
 practical=OmniLight3D.new();practical.name="RestrainedWarmPractical";practical.position=Vector3(0,1.82,.08);practical.light_color=Color("#F7C483");practical.light_energy=.22;practical.omni_range=1.8;practical.shadow_enabled=false;l.add_child(practical)
func _camera_lights():
 super._camera_lights();camera.size=7.15;camera.position=Vector3(4.55,12.0,16.1);camera.look_at(Vector3(2.90,.57,3.3));proof_camera_transform=camera.transform;proof_camera_size=camera.size
 environment.environment.background_color=Color("#EAE3D6");environment.environment.ambient_light_color=Color("#F4EEE3");environment.environment.ambient_light_energy=.60
 key_light.rotation_degrees=Vector3(-62,-32,0);key_light.light_energy=.68;key_light.shadow_opacity=.48;key_light.shadow_blur=3;key_light.shadow_normal_bias=.3;key_light.shadow_bias=.03
func _cat():
 super._cat();set_cat_mode("upright");set_cat_presentation("ambient_tinted");set_contact_mode("hybrid_contact")
func set_cat_presentation(mode:String):
 cat_presentation=mode;cat.shaded=false;cat.modulate=Color.WHITE if mode=="unshaded" else Color(.95,.965,.945,1)
func set_contact_mode(mode:String):
 contact_mode=mode;contact.modulate=Color(1,1,1,.32 if mode=="blob" else .22);cat.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON if mode=="card_cast" else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func _batch_static():
 authored_piece_count=geometry.find_children("*","MeshInstance3D",true,false).size();super._batch_static()
func _ui():
 super._ui();status.text="Stylized 3D art study · human decision pending"

func _ready():
 super._ready();enter_hero.call_deferred()
func enter_hero():
 for i in 240:
  await get_tree().process_frame
  if ready_for_review:break
 if not auto_hero:return
 cat.visible=false;contact.visible=false
 for point in [Vector2(325,300),Vector2(325,355)]:
  var marker:=Marker2D.new();marker.position=point;slice.add_child(marker);actor.navigate_to_marker(marker)
  for i in 1800:
   await get_tree().physics_frame
   var on_floor:bool=Rect2(16,35,568,235).has_point(actor.global_position) or Rect2(16,270,346,440).has_point(actor.global_position)
   cat.visible=on_floor;contact.visible=on_floor
   if actor.phase==HardeningActor.Phase.IDLE:break
  marker.queue_free()
func start_tour():
 if touring or not ready_for_review:return
 touring=true;tour_results=[]
 # Existing café walk targets, existing actor, original 2D navigation; no 3D body or navigation world.
 var rows:Array=slice.tour_points().filter(func(r):return r.label!="entrance")
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
 touring=false;status.text="Stylized 3D study · human visual decision pending";assert(slice.authority()==baseline_authority)

func point_in_presented_floor(point:Vector2)->bool:
 return Rect2(16,35,568,235).has_point(point) or Rect2(16,270,346,440).has_point(point)
func _unhandled_input(event:InputEvent):
 if not ready_for_review or touring or baseline_mode:return
 var screen:Variant=null
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:screen=event.position
 elif event is InputEventScreenTouch and event.pressed:screen=event.position
 if screen==null:return
 var p=pick(screen)
 if p==null:return
 var point:=unproject_point(p)
 if not point_in_presented_floor(point):return
 if is_instance_valid(click_marker):click_marker.queue_free()
 click_marker=Marker2D.new();click_marker.position=point;slice.add_child(click_marker);actor.cancel_action(&"hybrid_visual_pick");actor.navigate_to_marker(click_marker)


func set_cat_mode(mode:String):
 super.set_cat_mode(mode)
 cat.scale=Vector3(1.0,1.0/absf(camera.global_basis.y.y),1.0) if mode=="upright" else Vector3.ONE
