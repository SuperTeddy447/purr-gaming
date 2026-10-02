extends Node2D
## Same restrained family, with explicit projected-world to local registration.
## Cheap semantic steam / completion sparkles / practical dust; no global postprocess.
var time := 0.0
var brew := false
var completed := false
var pulse := 0.0
var particles := 0
var machine: Node2D
var fx_anchor: Marker2D
var active_frames := 0
var completion_count := 0
var practical_origin := Vector2(294,70)
func _process(delta:float)->void:
 time+=delta;pulse=maxf(0,pulse-delta)
 if brew or pulse>0:active_frames+=1
 queue_redraw()
func on_phase(phase:String)->void:
 brew=phase.begins_with("Coffee order") or phase.begins_with("Mochi prepares")
 if phase.begins_with("Coffee ready"):
  brew=false;completed=true;pulse=1.8;completion_count+=1
func _draw()->void:
 if fx_anchor==null:return
 var origin:=to_local(fx_anchor.global_position)+Vector2(0,-33)
 var emphasis:=1.0+0.20*pulse
 # Ambient is always quiet, active brewing raises visibility. Fixed emitter anchor.
 for j in 3:
  var phase:=fmod(time*.20+float(j)/3.0,1.0)
  var points:=PackedVector2Array()
  for i in 12:
   var u:=float(i)/11.0
   points.append(origin+Vector2(sin(u*7+time*.6+j)*3.2*emphasis+j*4-4,-phase*21-u*16))
  draw_polyline(points,Color(.75,.74,.70,(.06 if not brew else .50)*sin(phase*PI)),1.6,true)
 particles=3
 if pulse>0:
  for j in 3:
   var a:=float(j)*TAU/3+0.3
   var v:=origin+Vector2(cos(a)*13,-12+sin(a)*9)*(1.0+(1.8-pulse)*.2)
   var c:=Color("#F7C483");c.a=.55*minf(pulse,1.0)
   draw_line(v-Vector2(2,0),v+Vector2(2,0),c,1.1,true);draw_line(v-Vector2(0,2),v+Vector2(0,2),c,1.1,true)
  particles+=3
 # Sparse motes have bounded count and no blur/multipass.
 for j in 4:
  var p:=to_local(practical_origin)+Vector2(sin(time*.14+j*1.9)*24,cos(time*.11+j)*17)
  draw_circle(p,.7,Color(0.96,.78,.52,.18))
 particles+=4
