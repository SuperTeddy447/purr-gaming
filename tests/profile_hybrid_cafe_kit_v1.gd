extends SceneTree
func _initialize():run.call_deferred()
func run():
 var app=load("res://scenes/dev/hybrid_cafe_kit/hybrid_cafe_asset_kit_v1.tscn").instantiate();root.add_child(app)
 await create_timer(3).timeout
 var samples:Array=[]
 for i in 240:
  await process_frame
  if i>=60:samples.append({"process_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"rendered_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)})
 var mesh_count:=0;var triangles:=0;var surfaces:=0;var materials:Dictionary={};var textures:Dictionary={};var transparent:=0
 for n in app.geometry.find_children("*","MeshInstance3D",true,false):
  mesh_count+=1;triangles+=n.mesh.get_faces().size()/3;surfaces+=n.mesh.get_surface_count()
  for i in n.mesh.get_surface_count():
   var m=n.get_active_material(i)
   if m:materials[m.resource_path if not m.resource_path.is_empty() else str(m.get_instance_id())]=true
   if m is BaseMaterial3D:
    if m.albedo_texture:textures[m.albedo_texture.resource_path]=true
    if m.transparency!=BaseMaterial3D.TRANSPARENCY_DISABLED:transparent+=1
 var lights:=0;var shadow_lights:=0
 for n in app.find_children("*","Light3D",true,false):
  lights+=1
  if n.shadow_enabled:shadow_lights+=1
 var sum_process:=0.0;var sum_draw:=0.0;var sum_prim:=0.0
 for x in samples:sum_process+=x.process_ms;sum_draw+=x.draw_calls;sum_prim+=x.rendered_primitives
 var v={"scope":"desktop native Metal steady state; no screenshot readback during sampling; not real-device mobile performance","device":RenderingServer.get_video_adapter_name(),"renderer":RenderingServer.get_current_rendering_method(),"godot":Engine.get_version_info(),"mesh_instances":mesh_count,"triangles_geometry":triangles,"mesh_surfaces":surfaces,"shared_geometry_materials":materials.keys(),"geometry_textures":textures.keys(),"geometry_transparent_surfaces":transparent,"illustrated_cat_sprites":3,"contact_shadows":app.find_children("*","Sprite3D",true,false).size(),"lights":lights,"shadow_casting_lights":shadow_lights,"sample_count":samples.size(),"mean_process_ms":sum_process/samples.size(),"mean_draw_calls":sum_draw/samples.size(),"mean_rendered_primitives":sum_prim/samples.size(),"texture_memory_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),"video_memory_bytes":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),"allocation_caveat":"Includes retained hidden 2D authority, imported embedded materials/textures, avatars and contact-shadow resources; not just five source albedos","samples":samples}
 var f=FileAccess.open(OS.get_cmdline_user_args()[0]+"/profile_native.json",FileAccess.WRITE);f.store_string(JSON.stringify(v,"\t",true,true));f.close();print("KIT PROFILE ",mesh_count," meshes ",triangles," triangles ",sum_draw/samples.size()," drawcalls");quit()
