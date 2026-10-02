extends "res://scripts/dev/cafe_interior_slice/cafe_slice.gd"
## Continuation of the reviewed slice, with separate modular family sprites.
## Layout, navigation, semantic nodes and gameplay remain owned by inherited Home.
const KIT := "res://assets/dev_review/cafe_interior_kit_v1/runtime/"
var kit_sprites:Array[Sprite2D]=[]
var kit_catalog:Dictionary
func _kit(parent:Node2D,id:String,width:float,at:Vector2=Vector2.ZERO,contact:bool=true)->Sprite2D:
 var item:=Sprite2D.new();item.name="Kit_"+id;item.texture=load(KIT+id+".png");item.centered=false;item.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 var size:=item.texture.get_size();item.scale=Vector2.ONE*(width/size.x);item.position=at-Vector2(size.x/2,size.y if contact else size.y/2)*item.scale
 parent.add_child(item);kit_sprites.append(item)
 generated_bindings.append({"asset":id,"family_scope":"DEV_REVIEW_CANDIDATE","owner":String(parent.get_path()),"visual_contact_local":at,"scale":item.scale,"source_canvas":size,"pivot":"bottom_center" if contact else "canvas_center"})
 return item
func _architecture()->void:
 super._architecture()
 var a:Node2D=world.get_node("Architecture")
 a.get_node("ReviewCedarFloorModules").texture=load(KIT+"floor_quiet.png")
 # Existing region/scale/repeat remain; the quiet mirrored atlas has matching outer edges.
 a.get_node("ReviewCedarFloorModules").region_rect=Rect2(0,0,320,500)
 a.get_node("ReviewCedarFloorModules").scale=Vector2.ONE*2.0
 a.get_node("ReviewCedarFloorModules").texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
 a.get_node("Review_wall_plaster").visible=false
 for i in 2:
  var panel:=_kit(a,"wall_plain" if i==0 else "wall_framed",336,Vector2(160+i*320,14),false);panel.z_index=-8;panel.modulate=Color(.97,.97,.96)
 # Three aligned posts share a common architectural baseline and conceal module joining edges.
 for x in [28.0,320.0,612.0]:
  var post:=_kit(a,"post_cedar",62,Vector2(x,112));post.z_index=-7
 var window:=_kit(a,"window_shoji",104,Vector2(86,20),false);window.z_index=-6
 var menu:=_kit(a,"menu_blank",185,Vector2(305,-9),false);menu.z_index=-6
 # Source signage is blank. Real engine text is separate and remains editable.
 var title:=Label.new();title.name="RuntimeCafeSign";title.text="WilliCat\nRiverside café";title.position=Vector2(244,-36);title.add_theme_font_size_override("font_size",18);title.add_theme_color_override("font_color",Color("#FAE5C7"));title.z_index=-5;a.add_child(title)
 var shelf:=_kit(a,"shelf_ceramics",167,Vector2(304,105));shelf.z_index=-6
 var art:=_kit(a,"art_framed",57,Vector2(549,24),false);art.z_index=-6
 var hanging:=_kit(a,"plant_hanging",46,Vector2(474,101));hanging.z_index=-5
 for x in [185.0,414.0]:
  var lamp:=_kit(a,"lamp_pendant",40,Vector2(x,47));lamp.z_index=-4
  var glow:=Sprite2D.new();glow.texture=load(ART+"practical_light.png");glow.position=Vector2(x,30);glow.scale=Vector2.ONE*.65;glow.modulate=Color(1,.94,.83,.25);glow.z_index=-3;a.add_child(glow)
 a.get_node("ReviewPracticalLightAccent").modulate.a=.12
func _props()->void:
 # Keep the existing entrance's measured aperture registration and the canonical character adapter.
 super._props()
 var c=world.find_object(&"counter_shell").get_node("InteriorReviewVisualRoot")
 c.get_node("Review_counter_top").visible=false;c.get_node("Review_counter_front").visible=false
 var top:=_kit(c,"counter_top",224);top.z_index=-2;_kit(c,"counter_front",224)
 _kit(c,"ceramic_service",44,Vector2(55,-56))
 for row in [{"id":&"espresso_station","asset":"espresso","width":86,"support":73},{"id":&"grinder_station","asset":"grinder","width":34,"support":48}]:
  var obj=world.find_object(row.id);var v=obj.get_node("InteriorReviewVisualRoot")
  v.get_node("Review_counter_cedar").visible=false
  var stand:=_kit(v,"counter_short",row.support)
  # Authored countertop contact in the exported sprite; no gameplay anchor is moved.
  var contact_y:float=stand.position.y+42.0*stand.scale.y
  v.get_node("Review_"+row.asset).position.y=contact_y-v.get_node("Review_"+row.asset).texture.get_height()*v.get_node("Review_"+row.asset).scale.y
 world.find_object(&"pos_station").get_node("InteriorReviewVisualRoot/Review_pos").position.y=-72-world.find_object(&"pos_station").get_node("InteriorReviewVisualRoot/Review_pos").texture.get_height()*world.find_object(&"pos_station").get_node("InteriorReviewVisualRoot/Review_pos").scale.y
 var t=world.find_object(&"table_a").get_node("InteriorReviewVisualRoot")
 _kit(t,"tea_tray",39,Vector2(-15,-89));_kit(t,"flower_small",21,Vector2(28,-82))
 # Reuse the already coherent generated furniture for the second existing group.
 for row in [{"id":&"table_b","asset":"table_cedar","width":126},{"id":&"chair_c","asset":"chair_ne","width":58},{"id":&"chair_d","asset":"chair_nw","width":58}]:
  var obj=world.find_object(row.id);_hide(obj);var v:=Node2D.new();v.name="KitVisualRoot";obj.add_child(v);_shadow(v,94 if row.id==&"table_b" else 48,24 if row.id==&"table_b" else 15);_sprite(v,row.asset,row.width)
  if row.id==&"table_b":_kit(v,"ceramic_service",34,Vector2(-10,-84));_kit(v,"flower_small",18,Vector2(30,-78))
 var bed=world.find_object(&"cat_bed");_hide(bed);var rest:=Node2D.new();rest.name="KitVisualRoot";bed.add_child(rest);_shadow(rest,95,18);_kit(rest,"cat_bed_empty",120)
 var post=world.find_object(&"scratch_post");_hide(post);var wood:=Node2D.new();wood.name="KitVisualRoot";post.add_child(wood);_shadow(wood,34,12);_kit(wood,"post_cedar",25)
 var display=world.find_object(&"pastry_case");_hide(display);var dv:=Node2D.new();dv.name="KitVisualRoot";display.add_child(dv);_shadow(dv,91,19);var cabinet:=_kit(dv,"counter_short",94);_kit(dv,"tea_tray",51,Vector2(0,cabinet.position.y+42*cabinet.scale.y))
func install()->void:
 await super.install()
 # Visual emitter follows the new countertop art; canonical SteamFXAnchor is untouched.
 var station=world.find_object(&"espresso_station")
 var machine:Sprite2D=station.get_node("InteriorReviewVisualRoot/Review_espresso")
 var emitter:=Marker2D.new();emitter.name="KitVisualSteamEmitter"
 emitter.position=machine.global_position+Vector2(machine.texture.get_width()*machine.scale.x*.55,47.0)
 add_child(emitter);polish.fx_anchor=emitter
func _process(delta:float)->void:
 super._process(delta)
 if ready_for_review:
  # Original technical FX may re-enable itself during service; only the new restrained polish is shown.
  world.find_object(&"espresso_station").get_node("SteamFXAnchor/Steam").visible=false
