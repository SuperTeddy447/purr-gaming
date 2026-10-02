extends "res://scripts/dev/cafe_interior_kit/cafe_kit.gd"
## Human rejected prior appearance. This is a DEV VISUAL FRAMING PROOF, not canonical camera authority.
const RECOVERY := "res://assets/dev_review/cafe_visual_recovery_v1/runtime/"
const ACTOR_VISUAL_MULTIPLIER := 1.25
const GROUND_Y_PRESENTATION := 0.62 # Candidate DEV projection; not a canonical world measurement.
var projection_applied:=false
var review_focus:StringName=&"cafe"
var counter_unit:=0.0
var counter_span:=0.0
var counter_surface_y:=0.0
var visual_only_contacts:Dictionary={}
func _fit(item:Sprite2D,width:float,contact:Vector2=Vector2.ZERO)->void:
 var size:=item.texture.get_size();item.scale=Vector2.ONE*width/size.x;item.position=contact-Vector2(size.x/2,size.y)*item.scale
func _panel(parent:Node2D,id:String,rect:Rect2,z:int)->NinePatchRect:
 var node:=NinePatchRect.new();node.name="RecoveryPanel_"+id;node.texture=load(KIT+id+".png");node.position=rect.position;node.size=rect.size;node.patch_margin_left=30;node.patch_margin_right=30;node.patch_margin_top=30;node.patch_margin_bottom=30;node.mouse_filter=Control.MOUSE_FILTER_IGNORE;node.z_index=z;parent.add_child(node);return node
func _wood(parent:Node2D,name:String,rect:Rect2,z:int,horizontal:bool=false)->Polygon2D:
 var piece:=Polygon2D.new();piece.name=name;piece.texture=load(RECOVERY+"cedar_post_face.png");piece.polygon=PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
 var uv:=PackedVector2Array([Vector2(0,0),Vector2(82,0),Vector2(82,576),Vector2(0,576)])
 if horizontal:uv=PackedVector2Array([Vector2(0,0),Vector2(0,576),Vector2(82,576),Vector2(82,0)])
 piece.uv=uv;piece.z_index=z;piece.set_meta("recovery_ground_plane",name.contains("Side"));parent.add_child(piece);return piece
func _architecture()->void:
 super._architecture()
 var a:Node2D=world.get_node("Architecture")
 for n in a.get_children():
  if n is CanvasItem and String(n.name) not in ["ReviewCedarFloorModules","ReviewPracticalLightAccent"]:n.visible=false
 # Rear mounting planes project above the existing world ground boundary. Art heights are DEV choices.
 _panel(a,"wall_plain",Rect2(16,-244,304,244),-8)
 _panel(a,"wall_framed",Rect2(320,-244,304,244),-8)
 for x in [16.0,314.0,608.0]:_wood(a,"RecoveryRearPost",Rect2(x,-252,20,260),-7)
 _wood(a,"RecoveryRearHeader",Rect2(16,-252,608,25),-6,true)
 _wood(a,"RecoveryRearSill",Rect2(16,-8,608,18),-6,true)
 # Side framing covers the same original wall envelope, not a new navigation surface.
 for side in [0,1]:
  var x:=0.0 if side==0 else 612.0
  for j in 5:
   var y:=float(j)*200
   var panel:=Polygon2D.new();panel.name="RecoverySideMountingPlane";panel.texture=load(KIT+"wall_plain.png");panel.z_index=-7;panel.color=Color(.94,.91,.85)
   panel.polygon=PackedVector2Array([Vector2(x,y-105),Vector2(x+28,y-87),Vector2(x+28,y+130),Vector2(x,y+112)]);panel.uv=PackedVector2Array([Vector2(28,28),Vector2(480,28),Vector2(480,265),Vector2(28,265)]);panel.set_meta("recovery_ground_plane",true);a.add_child(panel)
  _wood(a,"RecoverySidePost",Rect2(x+5,110,14,790),-6)
 var window:=_kit(a,"window_shoji",144,Vector2(100,-106),false);window.z_index=-5
 var menu:=_panel(a,"menu_blank",Rect2(230,-213,300,126),-5);menu.texture=load(RECOVERY+"menu_flat.png")
 var title:=Label.new();title.name="RecoveryCafeSign";title.text="WilliCat";title.position=Vector2(250,-183);title.add_theme_font_size_override("font_size",27);title.add_theme_color_override("font_color",Color("#FAE5C7"));title.z_index=-4;a.add_child(title)
 var sub:=Label.new();sub.text="Riverside café · Coffee & Tea";sub.position=Vector2(251,-142);sub.add_theme_font_size_override("font_size",12);sub.add_theme_color_override("font_color",Color("#EADAC2"));sub.z_index=-4;a.add_child(sub)
 var art:=_kit(a,"art_framed",70,Vector2(577,-130),false);art.z_index=-5
 for row in [{"id":"shelf_ceramics","w":194.0,"point":Vector2(339,-6)},{"id":"shelf_ceramics","w":125.0,"point":Vector2(541,-17)}]:
  var shelf:=_kit(a,row.id,row.w,row.point);shelf.z_index=-5
 var shelf:=_kit(a,"shelf_empty",155,Vector2(105,-10));shelf.z_index=-5
 var ceramics:=_kit(a,"ceramic_service",80,Vector2(88,-36));ceramics.z_index=-4
 var flower:=_kit(a,"flower_small",31,Vector2(148,-31));flower.z_index=-4
 for row in [Vector2(197,-79),Vector2(488,-68)]:
  var lamp:=_kit(a,"lamp_pendant",48,row);lamp.z_index=-3
  var glow:=Sprite2D.new();glow.texture=load(ART+"practical_light.png");glow.position=row-Vector2(0,15);glow.scale=Vector2.ONE*.90;glow.modulate=Color(1,.88,.64,.32);glow.z_index=-2;a.add_child(glow)
 var hanging:=_kit(a,"plant_hanging",55,Vector2(218,20));hanging.z_index=-3
 a.get_node("ReviewPracticalLightAccent").modulate.a=.1
 a.get_node("ReviewCedarFloorModules").modulate=Color(1.055,1.0,.925)
 _seating_rug(a,&"table_a",[&"chair_a",&"chair_b"])
 _seating_rug(a,&"table_b",[&"chair_c",&"chair_d"])
 var door=world.find_object(&"entrance_door");var mat:=Sprite2D.new();mat.name="RecoveryEntryMat";mat.texture=load(RECOVERY+"entry_mat.png");mat.centered=false;mat.scale=Vector2.ONE*64.0/mat.texture.get_width();mat.position=door.get_node("EnterSlot/ActionAnchor").global_position+Vector2(-32,30)-Vector2(0,mat.texture.get_height()*mat.scale.y);mat.z_index=-4;a.add_child(mat)
 # Hanging edge clusters occupy the existing wall plane, with no invented floor blockers.
 for row in [{"x":18.0,"y":350.0},{"x":622.0,"y":570.0},{"x":20.0,"y":760.0}]:
  var decor:=Node2D.new();decor.name="RecoveryWallGarden";decor.position=Vector2(row.x,row.y);decor.set_meta("recovery_billboard",true);world.objects.add_child(decor)
  var p:=_kit(decor,"plant_hanging",72,Vector2.ZERO);p.modulate=Color(.94,.97,.91)
 # Front planter pots reuse existing obstructed front-wall areas; the64-unit aperture stays clear.
 for id in [&"front_wall_west",&"front_wall_east"]:
  var wall=world.find_object(id);var decoration:=Node2D.new();decoration.name="RecoveryFrontGarden";decoration.position=Vector2(-25,-4) if id==&"front_wall_west" else Vector2(32,-4);wall.add_child(decoration)
  _shadow(decoration,77,19);_sprite(decoration,"planter",132)
func _props()->void:
 super._props()
 var obj=world.find_object(&"counter_shell");var c=obj.get_node("InteriorReviewVisualRoot")
 for n in c.get_children():
  if n is CanvasItem and n.name!=&"ReviewContactShadow":n.visible=false
 var west:Rect2=obj.get_node("PhysicalFootprint").global_bounds();var east:Rect2=world.find_object(&"grinder_station").get_node("PhysicalFootprint").global_bounds()
 var start:float=west.position.x+14.0;var end:float=east.end.x+9.0;counter_span=end-start;counter_unit=counter_span/768.0
 # Equal material/world scale for left end, two center segments, right end. No stretched whole counter.
 var accumulated:=0.0
 for part in [{"role":"left","name":"left"},{"role":"middle","name":"middle_a"},{"role":"middle","name":"middle_b"},{"role":"right","name":"right"}]:
  var role:String=part.role
  var width:=128.0 if role!= "middle" else 256.0
  for layer in ["top","front"]:
   var item:=Sprite2D.new();item.name="RecoveryCounter_"+String(part.name)+"_"+layer;item.texture=load(RECOVERY+"counter_"+role+"_"+layer+".png");item.centered=false;item.scale=Vector2.ONE*counter_unit;item.position=Vector2(start-obj.global_position.x+accumulated,-217.0*counter_unit);item.z_index=-2 if layer=="top" else 0;item.modulate=Color(1.0,.83,.68) if layer=="top" else Color.WHITE;item.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;c.add_child(item)
  accumulated+=width*counter_unit
 counter_surface_y=obj.global_position.y-(217.0-99.0)*counter_unit
 var shadow=c.get_node("ReviewContactShadow");shadow.position.x=(start+end)/2-obj.global_position.x;shadow.scale=Vector2(counter_span/128,30.0/48)
 _kit(c,"ceramic_service",57,Vector2(98,counter_surface_y-obj.global_position.y+11))
 _kit(c,"flower_small",31,Vector2(-58,counter_surface_y-obj.global_position.y+7))
 for row in [{"id":&"espresso_station","asset":"espresso","w":104.0},{"id":&"grinder_station","asset":"grinder","w":42.0}]:
  var station=world.find_object(row.id);var v=station.get_node("InteriorReviewVisualRoot");v.get_node("Kit_counter_short").visible=false;v.get_node("ReviewContactShadow").visible=false
  _fit(v.get_node("Review_"+row.asset),row.w,Vector2(0,counter_surface_y-station.global_position.y+5))
 var pos=world.find_object(&"pos_station");_fit(pos.get_node("InteriorReviewVisualRoot/Review_pos"),40,Vector2(0,counter_surface_y-pos.global_position.y+10))
 for id in [&"table_a",&"table_b"]:
  var table=world.find_object(id);var v=table.get_node("InteriorReviewVisualRoot" if id==&"table_a" else "KitVisualRoot")
  var floor_edge:float=table.get_node("PhysicalFootprint").global_bounds().end.y-table.global_position.y
  _fit(v.get_node("Review_table_cedar"),176 if id==&"table_a" else 168,Vector2(0,floor_edge))
  v.get_node("ReviewContactShadow").scale=Vector2(131.0/128,28.0/48);v.get_node("ReviewContactShadow").position.y=floor_edge
  visual_only_contacts[String(id)]=Vector2(0,floor_edge)
  for n in v.get_children():
   if n is Sprite2D and n.name.begins_with("Kit_"):
    var at:=Vector2(-19,-89) if n.name.contains("tea_tray") or n.name.contains("ceramic_service") else Vector2(37,-87)
    _fit(n,50 if n.name.contains("tray") or n.name.contains("ceramic_service") else 27,at)
 for id in [&"chair_a",&"chair_b",&"chair_c",&"chair_d"]:
  var chair=world.find_object(id);var v=chair.get_node("InteriorReviewVisualRoot" if id in [&"chair_a",&"chair_b"] else "KitVisualRoot")
  var item=v.get_node("Review_chair_ne" if id in [&"chair_a",&"chair_c"] else "Review_chair_nw")
  var at:=Vector2(6 if id in [&"chair_a",&"chair_c"] else -6,-4)
  _fit(item,73,at);v.get_node("ReviewContactShadow").scale=Vector2(58.0/128,18.0/48);v.get_node("ReviewContactShadow").position=at;visual_only_contacts[String(id)]=at
 var plant=world.find_object(&"plant").get_node("InteriorReviewVisualRoot");_fit(plant.get_node("Review_planter"),112);plant.get_node("ReviewContactShadow").scale=Vector2(73.0/128,18.0/48)
 var bed=world.find_object(&"cat_bed").get_node("KitVisualRoot");_fit(bed.get_node("Kit_cat_bed_empty"),167);bed.get_node("ReviewContactShadow").scale=Vector2(127.0/128,22.0/48)
 var scratch=world.find_object(&"scratch_post").get_node("KitVisualRoot");scratch.get_node("Kit_post_cedar").visible=false
 var scratching:=Sprite2D.new();scratching.name="RecoverySisalPost";scratching.texture=load(RECOVERY+"sisal_post.png");scratching.centered=false;scratch.add_child(scratching);_fit(scratching,49)
 _kit(scratch,"flower_small",30,Vector2(31,0))
 var display=world.find_object(&"pastry_case").get_node("KitVisualRoot");var cabinet:Sprite2D=display.get_node("Kit_counter_short");_fit(cabinet,121);display.get_node("ReviewContactShadow").scale=Vector2(113.0/128,23.0/48)
 _fit(display.get_node("Kit_tea_tray"),71,Vector2(0,cabinet.position.y+42*cabinet.scale.y))
func _actors()->void:
 super._actors()
 for id in ["Visitor","Worker","Customer"]:
  var node=avatars[id];var sprite=node.find_children("*","AnimatedSprite2D",true,false)[0]
  sprite.scale*=ACTOR_VISUAL_MULTIPLIER;sprite.position*=ACTOR_VISUAL_MULTIPLIER
  var shadow=node.get_node_or_null("ContactShadow")
  if shadow==null:shadow=node.get_node_or_null("FirstPartyContactShadow")
  if shadow!=null:shadow.scale*=ACTOR_VISUAL_MULTIPLIER
 _customer_sprite_rest_y=avatars.Customer.get_node("AnimatedSprite2D").position.y
func _ui()->void:
 super._ui()
 var header=get_node("CafeReviewControls").get_child(0);header.offset_top=7;header.add_theme_constant_override("margin_top",0);header.get_child(0).get_child(0).add_theme_font_size_override("font_size",16);ui_status.add_theme_font_size_override("font_size",11)
 var bottom=get_node("CafeReviewControls").get_child(1);bottom.offset_top=-75;ui_reward.add_theme_font_size_override("font_size",11)
 for b in [coffee_button,walk_button,view_button]:b.add_theme_font_size_override("font_size",12)
 view_button.text="Seating view";ui_reward.text="Walk inside · Café visual review"
func _frame()->void:
 var camera:Camera2D=world.get_node("Camera");var view:=world.get_viewport_rect().size
 if overview:
  camera.global_position=Vector2(320,365);var z:=minf((view.x+22)/656,(view.y-100)/940);camera.zoom=Vector2(z,z*GROUND_Y_PRESENTATION)
 else:
  camera.global_position=Vector2(320,220 if review_focus==&"service" else 490 if review_focus==&"seating" else 330);var z:=minf((view.x-12)/620,(view.y-126)/720);camera.zoom=Vector2(z,z*GROUND_Y_PRESENTATION)
func toggle_view()->void:
 overview=not overview;view_button.text="Seating view" if overview else "Full café";_frame()
func _process(delta:float)->void:
 super._process(delta)
 if not ready_for_review:return
 var guest:HardeningActor=world.actors.get_node("Customer")
 if guest.phase==HardeningActor.Phase.ACTION and guest.last_action==&"sit":
  _seat_lift=move_toward(_seat_lift,42,delta*100);avatars.Customer.get_node("AnimatedSprite2D").position.y=_customer_sprite_rest_y-_seat_lift

func _seating_rug(a:Node2D,table_id:StringName,seats:Array)->void:
 var table=world.find_object(table_id);var tb:Rect2=table.get_node("PhysicalFootprint").global_bounds();var union:=tb
 for id in seats:union=union.merge(world.find_object(id).get_node("PhysicalFootprint").global_bounds())
 var left:float=union.position.x-30;var right:float=union.end.x+30;var back:float=tb.position.y-9;var front:float=union.end.y+20
 var rug:=Polygon2D.new();rug.name="RecoveryGroundRug_"+String(table_id);rug.texture=load(RECOVERY+"seating_rug.png");rug.z_index=-4
 rug.polygon=PackedVector2Array([Vector2(left+18,back),Vector2(right-18,back),Vector2(right+9,front),Vector2(left-9,front)])
 # Authored source outer textile corners: mapping a planar material, not rotating a furniture direction.
 rug.uv=PackedVector2Array([Vector2(93,7),Vector2(440,7),Vector2(506,147),Vector2(6,147)]);rug.modulate=Color(1,.98,.94,.94);a.add_child(rug)
 visual_only_contacts["rug_"+String(table_id)]={"source_uv":rug.uv,"world_quad":rug.polygon,"basis":"existing cluster footprints plus recorded DEV visual margins; no collision/navigation change"}

func install()->void:
 await super.install()
 _apply_projection()
 # A separate visual emitter follows billboarded art. Canonical marker stays untouched.
 var machine:Sprite2D=world.find_object(&"espresso_station").get_node("InteriorReviewVisualRoot/Review_espresso")
 polish.fx_anchor.position=machine.global_position+Vector2(machine.texture.get_width()*machine.scale.x*.55,35.0/GROUND_Y_PRESENTATION)
 var old_polish=polish;var new_polish=load("res://scripts/dev/cafe_visual_recovery/recovery_polish.gd").new()
 new_polish.name="RecoveryCozyCoffeePolish";new_polish.z_index=5;new_polish.fx_anchor=old_polish.fx_anchor;new_polish.scale.y=1.0/GROUND_Y_PRESENTATION;world.add_child(new_polish);polish=new_polish;old_polish.queue_free()
 _frame();assert(authority()==before,"DEV projection changed gameplay authority")
func _apply_projection()->void:
 if projection_applied:return
 projection_applied=true
 # Ground geometry is compressed by the DEV camera. Upright art billboards compensate globally.
 # GameplayRoot transforms, physics, marker positions and Y-sort authority stay untouched.
 for object in world.objects.get_children():
  for visual in object.get_children():
   if visual is Node2D and String(visual.name) in ["InteriorReviewVisualRoot","KitVisualRoot","ReviewFrontArchitecture","RecoveryFrontGarden"]:
    if visual.name==&"RecoveryFrontGarden":visual.position.y*=GROUND_Y_PRESENTATION
    visual.scale.y/=GROUND_Y_PRESENTATION
    var shadow=visual.get_node_or_null("ReviewContactShadow")
    if shadow!=null:shadow.scale.y*=GROUND_Y_PRESENTATION
  if object.get_meta("recovery_billboard",false):object.scale.y/=GROUND_Y_PRESENTATION
 for id in ["Visitor","Worker","Customer"]:
  var visual=avatars[id];visual.scale.y/=GROUND_Y_PRESENTATION
  var shadow=visual.get_node_or_null("ContactShadow")
  if shadow==null:shadow=visual.get_node_or_null("FirstPartyContactShadow")
  if shadow!=null:shadow.position.y*=GROUND_Y_PRESENTATION;shadow.scale.y*=GROUND_Y_PRESENTATION
 # Ground-contact offsets are projected; the height of upright painted furniture is preserved.
 for id in [&"table_a",&"table_b"]:
  var v=world.find_object(id).get_node("InteriorReviewVisualRoot" if id==&"table_a" else "KitVisualRoot")
  var contact:Vector2=visual_only_contacts[String(id)];contact.y*=GROUND_Y_PRESENTATION
  _fit(v.get_node("Review_table_cedar"),176 if id==&"table_a" else 168,contact);v.get_node("ReviewContactShadow").position=contact
 for id in [&"chair_a",&"chair_b",&"chair_c",&"chair_d"]:
  var v=world.find_object(id).get_node("InteriorReviewVisualRoot" if id in [&"chair_a",&"chair_b"] else "KitVisualRoot")
  var at:Vector2=visual_only_contacts[String(id)];at.y*=GROUND_Y_PRESENTATION
  _fit(v.get_node("Review_chair_ne" if id in [&"chair_a",&"chair_c"] else "Review_chair_nw"),73,at);v.get_node("ReviewContactShadow").position=at
 for row in [{"id":&"espresso_station","asset":"espresso","w":104.0},{"id":&"grinder_station","asset":"grinder","w":42.0}]:
  var station=world.find_object(row.id);var counter_y:float=world.find_object(&"counter_shell").global_position.y
  var at:=Vector2(0,(counter_y-station.global_position.y)*GROUND_Y_PRESENTATION-(counter_y-counter_surface_y)+5)
  _fit(station.get_node("InteriorReviewVisualRoot/Review_"+row.asset),row.w,at)
 var entrance=world.find_object(&"entrance_door").get_node("InteriorReviewVisualRoot/Review_entrance_frame");entrance.position.y+=(GROUND_Y_PRESENTATION-1.0)*82.0
 var a=world.get_node("Architecture");var wall_art:=Node2D.new();wall_art.name="RecoveryUprightArchitecture";a.add_child(wall_art)
 for n in a.get_children():
  if n==wall_art or not n is CanvasItem or not n.visible:continue
  if String(n.name).contains("Floor") or String(n.name).contains("GroundRug") or String(n.name).contains("EntryMat") or n.get_meta("recovery_ground_plane",false):continue
  n.reparent(wall_art)
 wall_art.scale.y=1.0/GROUND_Y_PRESENTATION
