extends SceneTree
func _initialize():run.call_deferred()
func run():
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_hero_replacement_v1/kit_manifest.json"));var checks:Dictionary={};var measurements:Array=[]
 for row in manifest.assets:
  if not row.has("cavity"):continue
  var app=load("res://"+row.godot_prefab).instantiate();root.add_child(app);var count:=0;var varied:=false;var bounded:=true;var low:=1.0;var high:=0.0
  for mesh in app.find_children("*","MeshInstance3D",true,false):
   for i in mesh.mesh.get_surface_count():
    var array=mesh.mesh.surface_get_arrays(i);var colors=array[Mesh.ARRAY_COLOR]
    if colors==null:bounded=false;continue
    bounded=bounded and colors.size()==array[Mesh.ARRAY_VERTEX].size()
    for color in colors:count+=1;low=minf(low,color.r);high=maxf(high,color.r);bounded=bounded and color.r>=0 and color.r<=1
  varied=high>low;checks[row.asset_id+"_exported_cavity_colors"]=count>0 and bounded and varied;measurements.append({"asset":row.asset_id,"vertex_colors":count,"min":low,"max":high});app.queue_free();await process_frame
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify({"passed":checks.values().all(func(x):return x),"count":checks.size(),"checks":checks,"measurements":measurements},"\t"));f.close();print("CAVITY COLOR CHECKS ",checks);quit(0 if checks.values().all(func(x):return x) else 1)
