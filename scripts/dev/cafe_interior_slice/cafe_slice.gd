extends Node
## DEV REVIEW CANDIDATE. Presentation attaches to unchanged continuous Home authority.
const ART := "res://assets/dev_review/cafe_interior_slice_v1/runtime/"
const ORANGE := preload("res://scenes/dev/first_party_style_proof/willicat_orange_protagonist_visual_01.tscn")
const POLISH := preload("res://scripts/dev/cafe_interior_slice/cafe_polish.gd")
var world: HomeContinuousWorld
var ready_for_review := false
var before: Dictionary
var installed_visuals: Array[CanvasItem] = []
var generated_bindings: Array = []
var avatars: Dictionary = {}
var polish
var overview := true
var touring := false
var tour_results: Array = []
var ui_status: Label
var ui_reward: Label
var coffee_button: Button
var walk_button: Button
var view_button: Button
var shots: Array = []
var phase_history: Array = []
var _seat_lift := 0.0
var _customer_sprite_rest_y := 0.0
var _click_marker: Marker2D
signal tour_checkpoint(label:String)

func _ready()->void:call_deferred("install")
func authority()->Dictionary:
 var record:Dictionary={}
 for n in world.objects.find_children("*","HardeningWorldObject",true,false):
  record[String(n.get_path())]={"stable_id":String(n.stable_id),"transform":n.transform,"kind":n.kind}
  var p=n.get_node_or_null("PhysicalFootprint")
  if p!=null:record[String(p.get_path())]={"transform":p.transform,"size":p.footprint_size,"collision_layer":p.collision_layer,"collision_mask":p.collision_mask}
 for m in world.find_children("*","Marker2D",true,false):
  if not String(m.get_path()).contains("CafeInteriorVisualSlice"):record[String(m.get_path())]=m.transform
 for actor in world.actors.get_children():
  if actor is HardeningActor:
   record["actor_identity/"+String(actor.name)]={"category":actor.category,"collision_radius":actor.get_node("CollisionShape2D").shape.radius,"move_speed":actor.move_speed}
 record["nav"]={"walkable_bounds":world.navigation.walkable_bounds,"revision":world.navigation.revision}
 return record
func install()->void:
 world=get_parent() as HomeContinuousWorld
 for i in 14:await get_tree().process_frame
 before=authority()
 world.autoplay_route=false;world._view_mode=&"overview";world.get_node("HUD").visible=false;world.set_process_unhandled_input(false);world.camera_input.set_process_unhandled_input(false);world.camera_director.set_process(false)
 _architecture();_props();_actors();_ui()
 polish=POLISH.new();polish.name="CozyCoffeePolish";polish.z_index=5;polish.fx_anchor=world.find_object(&"espresso_station").get_node("SteamFXAnchor");world.add_child(polish)
 world.phase_changed.connect(_phase);world.reward_earned.connect(_reward);world.visit_completed.connect(_visit_finished)
 _frame();assert(authority()==before,"Visual install modified world authority")
 ready_for_review=true;set_process(true)
func _hide(root:Node)->void:
 for child in root.get_children():
  if child is CanvasItem and String(child.name) in ["RuntimeVisual","VisualRoot","VisualFrontOccluder","FirstPartyVisualRoot"]:child.visible=false
func _sprite(parent:Node2D,id:String,width:float,at:Vector2=Vector2.ZERO,contact:bool=true)->Sprite2D:
 var s:=Sprite2D.new();s.name="Review_"+id;s.texture=load(ART+id+".png");s.centered=false;s.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 var size:=s.texture.get_size();var scale_factor:=width/size.x;s.scale=Vector2.ONE*scale_factor
 s.position=at-Vector2(size.x/2,size.y if contact else size.y/2)*scale_factor
 parent.add_child(s);installed_visuals.append(s)
 generated_bindings.append({"asset":id,"owner":String(parent.get_path()),"local_visual_contact":at,"runtime_scale":scale_factor,"pivot_rule":"bottom_center_floor_or_countertop" if contact else "wall_mount_center"})
 return s
func _shadow(parent:Node2D,width:float,depth:float)->void:
 var shadow:=Sprite2D.new();shadow.name="ReviewContactShadow";shadow.texture=load(ART+"contact_shadow.png");shadow.scale=Vector2(width/128,depth/48);shadow.modulate.a=.58;shadow.z_index=-1;parent.add_child(shadow);installed_visuals.append(shadow)
func _architecture()->void:
 var a:Node2D=world.get_node("Architecture")
 for n in a.get_children():
  if n is CanvasItem and (String(n.name) in ["Floor","FloorTiles","WallModule","WallTiles","OutdoorTerrain","FirstPartyWaterRipple"] or String(n.name).begins_with("Window_") or String(n.name).begins_with("FirstPartyCafe")):n.visible=false
 for n in world.objects.get_children():
  if String(n.name).begins_with("FirstPartyFrontRail") or String(n.name) in ["FrontPlazaProps","BackGardenProps","RiversideProps"]:n.visible=false
 var floor:=Sprite2D.new();floor.name="ReviewCedarFloorModules";floor.texture=load(ART+"floor_cedar.png");floor.centered=false;floor.region_enabled=true;floor.region_rect=Rect2(0,0,1280,2000);floor.scale=Vector2.ONE*.5;floor.texture_repeat=CanvasItem.TEXTURE_REPEAT_MIRROR;floor.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;floor.z_index=-10;a.add_child(floor);installed_visuals.append(floor)
 var wall:=_sprite(a,"wall_plaster",640,Vector2(320,14),false);wall.z_index=-8;wall.modulate=Color(.94,.94,.92)
 # Side walls use the same authored module as a textured architectural plane.
 # They cover the original envelope boundary; no floor/collision coordinates change.
 for side in [0,1]:
  for j in 5:
   var panel:=Polygon2D.new();panel.name="ReviewSideWall_%d_%d"%[side,j];panel.texture=load(ART+"wall_plaster.png");panel.z_index=-7;panel.color=Color(.87,.86,.84)
   var x:=0.0 if side==0 else 612.0;var y:=float(j)*200
   panel.polygon=PackedVector2Array([Vector2(x,y),Vector2(x+28,y+18),Vector2(x+28,y+218),Vector2(x,y+200)])
   panel.uv=PackedVector2Array([Vector2(0,0),Vector2(0,164),Vector2(512,164),Vector2(512,0)])
   a.add_child(panel);installed_visuals.append(panel)
 for id in [&"front_wall_west",&"front_wall_east"]:
  var boundary=world.find_object(id);var root:=Node2D.new();root.name="ReviewFrontArchitecture";boundary.add_child(root)
  _sprite(root,"wall_plaster",288,Vector2(0,-30),false)
 var glow:=Sprite2D.new();glow.name="ReviewPracticalLightAccent";glow.texture=load(ART+"practical_light.png");glow.position=world.find_object(&"counter_shell").get_node("WorkerIdle").global_position+Vector2(0,-55);glow.scale=Vector2(1.3,.6);glow.modulate.a=.42;glow.z_index=-6;a.add_child(glow);installed_visuals.append(glow)
func _props()->void:
 var ids=[&"counter_shell",&"espresso_station",&"grinder_station",&"pos_station",&"table_a",&"chair_a",&"chair_b",&"plant",&"entrance_door"]
 for id in ids:
  var obj=world.find_object(id)
  if obj==null:continue
  _hide(obj);var root:=Node2D.new();root.name="InteriorReviewVisualRoot";obj.add_child(root)
  match id:
   &"counter_shell":
    _shadow(root,224,25);var worktop:=_sprite(root,"counter_top",224);worktop.z_index=-2;_sprite(root,"counter_front",224)
   &"espresso_station":
    _shadow(root,73,14);var plinth:=_sprite(root,"counter_cedar",73);plinth.scale.y*=2.2;plinth.position.y*=2.2;_sprite(root,"espresso",86,Vector2(0,-42))
   &"grinder_station":
    _shadow(root,48,12);var plinth:=_sprite(root,"counter_cedar",48);plinth.scale.y*=3.0;plinth.position.y*=3.0;_sprite(root,"grinder",34,Vector2(0,-35))
   &"pos_station":_sprite(root,"pos",40,Vector2(0,-48))
   &"table_a":_shadow(root,98,24);_sprite(root,"table_cedar",134)
   &"chair_a":_shadow(root,48,15);_sprite(root,"chair_ne",58)
   &"chair_b":_shadow(root,48,15);_sprite(root,"chair_nw",58)
   &"plant":_shadow(root,50,13);_sprite(root,"planter",70)
   &"entrance_door":
    var boundary=world.find_object(&"front_wall_west").get_node("PhysicalFootprint").global_bounds()
    var east=world.find_object(&"front_wall_east").get_node("PhysicalFootprint").global_bounds()
    var span:float=east.position.x-boundary.end.x
    # Measured alpha opening [89,304) in the 384px export; align to authoritative wall aperture.
    var width:float=span*384.0/215.0
    var at:=Vector2((boundary.end.x+east.position.x)/2-obj.global_position.x-4.5*width/384.0,boundary.get_center().y-obj.global_position.y)
    _sprite(root,"entrance_frame",width,at)
 # Keep legacy groups as honest muted context outside the productionized table.
 for name in ["TableB","ChairC","ChairD","CatBed","ScratchPost","PastryCase"]:
  var old=world.objects.get_node(name)
  if old.has_node("VisualRoot"):old.get_node("VisualRoot").modulate=Color(.86,.84,.79,.85)
func _actors()->void:
 for name in ["Worker","Customer"]:
  var actor:HardeningActor=world.actors.get_node(name);_hide(actor)
  var v=ORANGE.instantiate();v.name="CafeCanonicalOrange";actor.add_child(v);avatars[name]=v
 _customer_sprite_rest_y=avatars["Customer"].get_node("AnimatedSprite2D").position.y
 world.actors.get_node("Cat").visible=false
 avatars["Visitor"]=world.actors.get_node("Visitor").get_node("FirstPartyVisualRoot")
func _style_button(b:Button)->void:
 for state in ["normal","hover","pressed","disabled"]:
  var sb:=StyleBoxFlat.new();sb.bg_color=Color("#526F4E") if state!="pressed" else Color("#415A3E");sb.set_corner_radius_all(12);sb.content_margin_left=14;sb.content_margin_right=14;sb.content_margin_top=10;sb.content_margin_bottom=10;b.add_theme_stylebox_override(state,sb)
 b.add_theme_font_size_override("font_size",15);b.add_theme_color_override("font_color",Color("#FAE5C7"));b.add_theme_color_override("font_hover_color",Color("#FAE5C7"));b.add_theme_color_override("font_pressed_color",Color("#FAE5C7"))
 b.button_down.connect(func():b.modulate=Color(.91,.91,.91));b.button_up.connect(func():b.modulate=Color.WHITE)
func _ui()->void:
 var layer:=CanvasLayer.new();layer.name="CafeReviewControls";add_child(layer)
 var top:=MarginContainer.new();top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE);top.add_theme_constant_override("margin_left",24);top.add_theme_constant_override("margin_top",12);layer.add_child(top)
 var header:=VBoxContainer.new();top.add_child(header)
 var title:=Label.new();title.text="WilliCat · Riverside café";title.add_theme_font_size_override("font_size",24);title.add_theme_color_override("font_color",Color("#352C28"));header.add_child(title)
 ui_status=Label.new();ui_status.text="A small café. A cup made with care.";ui_status.add_theme_font_size_override("font_size",14);ui_status.add_theme_color_override("font_color",Color("#583F2E"));header.add_child(ui_status)
 var bottom:=MarginContainer.new();bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);bottom.offset_top=-112;bottom.add_theme_constant_override("margin_left",24);bottom.add_theme_constant_override("margin_right",24);bottom.add_theme_constant_override("margin_bottom",14);layer.add_child(bottom)
 var stack:=VBoxContainer.new();bottom.add_child(stack);ui_reward=Label.new();ui_reward.text="Tap the floor to walk · DEV playable review";ui_reward.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;ui_reward.add_theme_font_size_override("font_size",13);ui_reward.add_theme_color_override("font_color",Color("#583F2E"));stack.add_child(ui_reward)
 var row:=HBoxContainer.new();row.add_theme_constant_override("separation",10);stack.add_child(row)
 for text in ["Make coffee","Depth walk","Closer view"]:
  var b:=Button.new();b.text=text;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;_style_button(b);row.add_child(b)
  if text=="Make coffee":coffee_button=b;b.pressed.connect(start_coffee)
  elif text=="Depth walk":walk_button=b;b.pressed.connect(start_tour)
  else:view_button=b;b.pressed.connect(toggle_view)
func _phase(label:String)->void:
 phase_history.append({"phase":label,"time_ms":Time.get_ticks_msec()});ui_status.text=label.replace("Mochi","Willi")
 polish.on_phase(label)
 var bubble=world.actors.get_node("Customer").get_node_or_null("OrderBubble")
 if bubble!=null:bubble.visible=false
 var station=world.find_object(&"espresso_station")
 station.get_node("SteamFXAnchor/Steam").visible=false
 station.get_node("FirstPartyCoffeeCompleteFX").visible=false
 if label.begins_with("Coffee ready"):
  var m=world.find_object(&"espresso_station").get_node("InteriorReviewVisualRoot/Review_espresso")
  var t:=create_tween();t.tween_property(m,"modulate",Color(1.07,1.04,.98),.12);t.tween_property(m,"modulate",Color.WHITE,.4)
func _reward(_order:String)->void:
 ui_reward.text="One cup, one happy visit · %d coins"%int(world.session.coins)
 var t:=create_tween();t.tween_property(ui_reward,"modulate",Color(1.05,.96,.80),.12);t.tween_property(ui_reward,"modulate",Color.WHITE,.35)
func _visit_finished(_success:bool)->void:
 world.actors.get_node("Visitor").visible=true;coffee_button.disabled=false;walk_button.disabled=false
func start_coffee()->void:
 if not ready_for_review or touring or world.loop_active:return
 var visitor:HardeningActor=world.actors.get_node("Visitor");visitor.cancel_action(&"cafe_coffee_view");visitor.visible=false
 coffee_button.disabled=true;walk_button.disabled=true;world.start_customer_loop()
func toggle_view()->void:
 overview=not overview;view_button.text="Full slice" if not overview else "Closer view";_frame()
func _frame()->void:
 var camera:Camera2D=world.get_node("Camera");var view:=world.get_viewport_rect().size
 if overview:
  camera.global_position=Vector2(320,480);camera.zoom=Vector2.ONE*minf((view.x-80)/640,(view.y-200)/1080)
 else:
  camera.global_position=Vector2(300,320);camera.zoom=Vector2.ONE*minf((view.x-65)/640,(view.y-160)/690)
func _process(delta:float)->void:
 if not ready_for_review:return
 _frame()
 var worker:HardeningActor=world.actors.get_node("Worker")
 if worker.phase==HardeningActor.Phase.ACTION:
  # Existing authored idle is the service hold; stale approach velocity must not play a walk pose.
  avatars["Worker"].facing="down";avatars["Worker"].get_node("AnimatedSprite2D").play("idle_down")
 var guest:HardeningActor=world.actors.get_node("Customer")
 # Display elevation derives from the authored chair seat, leaving the actor root/slot intact.
 var sitting:=guest.phase==HardeningActor.Phase.ACTION and guest.last_action==&"sit"
 _seat_lift=move_toward(_seat_lift,30.0 if sitting else 0.0,delta*100.0)
 avatars["Customer"].get_node("AnimatedSprite2D").position.y=_customer_sprite_rest_y-_seat_lift
func tour_points()->Array:
 var table=world.find_object(&"table_a");var b:Rect2=table.get_node("PhysicalFootprint").global_bounds();var radius:float=world.actors.get_node("Visitor").get_node("CollisionShape2D").shape.radius
 return [{"label":"entrance","point":world.find_object(&"entrance_door").get_node("EnterSlot/ExitAnchor").global_position},{"label":"counter_front","point":world.find_object(&"counter_shell").get_node("OrderSlot/ApproachAnchor").global_position},{"label":"counter_back","point":world.find_object(&"counter_shell").get_node("WorkerIdle").global_position},{"label":"table_back","point":Vector2(table.global_position.x,b.position.y-radius-14)},{"label":"table_side","point":Vector2(b.end.x+radius+14,b.get_center().y)},{"label":"table_front","point":Vector2(table.global_position.x,b.end.y+radius+16)}]
func start_tour()->void:
 if not ready_for_review or touring or world.loop_active:return
 touring=true;coffee_button.disabled=true;walk_button.disabled=true;tour_results=[]
 var actor:HardeningActor=world.actors.get_node("Visitor");actor.visible=true;actor.cancel_action(&"depth_walk")
 for row in tour_points():
  var marker:=Marker2D.new();marker.position=row.point;add_child(marker)
  var accepted:=actor.navigate_to_marker(marker)
  if accepted:
   for frame in 900:
    await get_tree().physics_frame
    if actor.phase==HardeningActor.Phase.IDLE:break
  tour_results.append({"label":row.label,"accepted":accepted,"success":accepted and not actor.failed_navigation and actor.phase==HardeningActor.Phase.IDLE,"position":actor.global_position})
  ui_status.text="Willi explores · "+str(row.label).replace("_"," ");tour_checkpoint.emit(row.label);await get_tree().create_timer(.65).timeout;marker.queue_free()
 touring=false;coffee_button.disabled=false;walk_button.disabled=false;ui_status.text="A small café. A cup made with care."
func _unhandled_input(event:InputEvent)->void:
 if not ready_for_review or touring or world.loop_active:return
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
  var point:Vector2=world.get_canvas_transform().affine_inverse()*event.position
  if not Rect2(35,70,570,900).has_point(point):return
  var actor:HardeningActor=world.actors.get_node("Visitor");actor.cancel_action(&"floor_click")
  if is_instance_valid(_click_marker):_click_marker.queue_free()
  var marker:=Marker2D.new();marker.position=point;add_child(marker);_click_marker=marker
  if actor.navigate_to_marker(marker):
   actor.route_completed.connect(marker.queue_free,CONNECT_ONE_SHOT)
  else:marker.queue_free()
