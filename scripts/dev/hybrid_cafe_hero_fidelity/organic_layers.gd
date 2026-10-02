extends RefCounted
## Authored static leaf/vine grammar. DEV dressing only, no gameplay physics.
static func triangle(st:SurfaceTool,a:Vector3,b:Vector3,c:Vector3,uv_a:Vector2,uv_b:Vector2,uv_c:Vector2,color:=Color.WHITE):
 var pts=[a,b,c];var uvs=[uv_a,uv_b,uv_c]
 for i in 3:st.set_color(color);st.set_uv(uvs[i]);st.add_vertex(pts[i])
static func leaf(st:SurfaceTool,start:Vector3,tip:Vector3,width:float,heart:=false,pigment:=.5):
 var side:Vector3=(tip-start).cross(Vector3.UP).normalized()*width
 if side.length()<.001:side=Vector3.RIGHT*width
 var rows:Array=[]
 for i in 6:
  var t:float=float(i)/5.0;var fullness:float=pow(maxf(sin(PI*t),0.0),.72)
  if heart:fullness*=1.15-.35*t
  var center:Vector3=start.lerp(tip,t)+Vector3(0,sin(PI*t)*width*.43,0)
  rows.append([center-side*fullness,center+Vector3(0,width*.14*fullness,0),center+side*fullness])
 for i in 5:
  for j in 2:
   triangle(st,rows[i][j],rows[i+1][j],rows[i+1][j+1],Vector2(j*.5,i*.2),Vector2(j*.5,(i+1)*.2),Vector2((j+1)*.5,(i+1)*.2),Color(1,pigment,1,1))
   triangle(st,rows[i][j],rows[i+1][j+1],rows[i][j+1],Vector2(j*.5,i*.2),Vector2((j+1)*.5,(i+1)*.2),Vector2((j+1)*.5,i*.2),Color(1,pigment,1,1))
static func twig(st:SurfaceTool,a:Vector3,b:Vector3,radius:=.007):
 var side:Vector3=(b-a).cross(Vector3.FORWARD).normalized()*radius
 triangle(st,a-side,b-side,b+side,Vector2.ZERO,Vector2(0,1),Vector2.ONE,Color(1,0,1,1))
 triangle(st,a-side,b+side,a+side,Vector2.ZERO,Vector2.ONE,Vector2(1,0),Color(1,0,1,1))
static func add(parent:Node3D,role:String,unit_scale:float,materials:Array):
 parent.set_meta("plant_role",role)
 var tools:Array=[]
 for i in 4:
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);tools.append(st)
 var count:=18 if role=="floor_lance" else 14 if role=="shelf_fan" else 11
 if role=="trailing":
  for strand in 3:
   var previous:=Vector3(-.06+strand*.07,.54,.03)
   for step in 8:
    var t:float=float(step)/7.0
    var point:=Vector3(-.07+strand*.08+sin(t*4.1+strand)*.075,.54-t*(.95+strand*.12),.02+t*.27)
    twig(tools[2],previous*unit_scale,point*unit_scale,.009*unit_scale)
    var sign:float=-1.0 if step%2==0 else 1.0
    leaf(tools[step%3],point*unit_scale,(point+Vector3(sign*.16,-.065,.08))*unit_scale,.080*unit_scale,true,[.5,1.0,0.0][step%3])
    previous=point
 for i in count:
  var angle:float=float(i)*2.399+(.3 if role=="shelf_fan" else .0)
  var spread:float=.27+float(i%3)*.043
  var rise:float=.34+float(i%5)*.092
  if role=="floor_lance":spread=.25+float(i%4)*.055;rise=.48+float(i%4)*.15
  if role=="flowering":spread=.23+float(i%3)*.030;rise=.31+float(i%3)*.055
  var start:=Vector3(cos(angle)*.04,.43,sin(angle)*.04)
  var tip:=Vector3(cos(angle)*spread,.43+rise,sin(angle)*spread)
  var width:float=.062 if role=="floor_lance" else .10
  leaf(tools[i%3],start*unit_scale,tip*unit_scale,width*unit_scale,role!="floor_lance",[.5,1.0,0.0][i%3])
  twig(tools[2],start*unit_scale,tip.lerp(start,.52)*unit_scale,.005*unit_scale)
 if role=="flowering":
  for i in 5:
   var center:=Vector3(cos(i*2.0)*.12,.86+float(i%2)*.06,sin(i*2.0)*.10)
   twig(tools[2],Vector3(0,.48,0)*unit_scale,center*unit_scale,.005*unit_scale)
   for p in 5:
    var angle:float=float(p)*TAU/5.0
    leaf(tools[3],center*unit_scale,(center+Vector3(cos(angle)*.095,.01,sin(angle)*.095))*unit_scale,.043*unit_scale,true)
 var pigment:=SurfaceTool.new();pigment.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 3:
  var st:SurfaceTool=tools[i];st.generate_normals();st.index();pigment.append_from(st.commit(),0,Transform3D.IDENTITY)
 var leaf_instance:=MeshInstance3D.new();leaf_instance.name="Organic_"+role+"_Pigment";leaf_instance.mesh=pigment.commit();leaf_instance.material_override=materials[0];parent.add_child(leaf_instance)
 if unit_scale<.6:leaf_instance.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 if role=="flowering":
  var st:SurfaceTool=tools[3];st.generate_normals();st.index();var instance:=MeshInstance3D.new();instance.name="Organic_"+role+"_Petals";instance.mesh=st.commit();instance.material_override=materials[3];instance.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(instance)

static func crescent(parent:Node3D,at:Vector3,turn:float,material:Material):
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var rings:Array=[]
 for i in 13:
  var t:float=float(i)/12.0;var angle:float=-1.9+t*3.8
  var center:=Vector3(sin(angle)*.135,.058,cos(angle)*.105)
  var side:=Vector3(sin(angle),0,cos(angle));var thick:float=.014+.048*pow(maxf(sin(PI*t),0.0),.68)
  var row:Array=[]
  for j in 8:
   var phi:float=float(j)*TAU/8.0
   row.append(center+side*cos(phi)*thick+Vector3.UP*sin(phi)*thick*.64)
  rings.append(row)
 for i in 12:
  for j in 8:
   var k:int=(j+1)%8
   triangle(st,rings[i][j],rings[i+1][j],rings[i+1][k],Vector2(i/12.0,j/8.0),Vector2((i+1)/12.0,j/8.0),Vector2((i+1)/12.0,(j+1)/8.0))
   triangle(st,rings[i][j],rings[i+1][k],rings[i][k],Vector2(i/12.0,j/8.0),Vector2((i+1)/12.0,(j+1)/8.0),Vector2(i/12.0,(j+1)/8.0))
 st.generate_normals();st.index();var n:=MeshInstance3D.new();n.name="SmallPastryCrescent";n.mesh=st.commit();n.material_override=material;n.position=at;n.rotation.y=turn;n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(n)
