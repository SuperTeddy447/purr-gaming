extends RefCounted
const G=preload("res://scripts/dev/hybrid_diorama/diorama_geometry.gd")
static func lathe(parent:Node3D,label:String,profile:Array,mat:Material,at:Vector3,segments:=32)->MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in profile.size()-1:
  for i in segments:
   var a:=TAU*i/segments;var b:=TAU*(i+1)/segments
   var p:Vector2=profile[j];var q:Vector2=profile[j+1]
   var v=[Vector3(cos(a)*p.x,p.y,sin(a)*p.x),Vector3(cos(b)*p.x,p.y,sin(b)*p.x),Vector3(cos(b)*q.x,q.y,sin(b)*q.x),Vector3(cos(a)*q.x,q.y,sin(a)*q.x)]
   for k in [0,2,1,0,3,2]:
    st.set_color(Color.WHITE);st.set_uv(Vector2(float(i)/segments,float(j)/profile.size()));st.add_vertex(v[k])
 st.generate_normals();return G.node(parent,label,st.commit(),mat,at)
static func ring(parent:Node3D,label:String,radius:float,thickness:float,mat:Material,at:Vector3)->MeshInstance3D:
 var m:=TorusMesh.new();m.inner_radius=radius-thickness;m.outer_radius=radius+thickness;m.rings=32;m.ring_segments=8;return G.node(parent,label,m,mat,at)
static func leaf(parent:Node3D,label:String,mat:Material,at:Vector3,rotation:Vector3,length:float,width:float)->MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in 6:
  var t:=float(j)/6;var u:=float(j+1)/6
  for side in [-1,1]:
   var a:=Vector3(0,sin(t*PI)*.06,t*length);var b:=Vector3(side*sin(t*PI)*width,-sin(t*PI)*.01,t*length);var c:=Vector3(side*sin(u*PI)*width,-sin(u*PI)*.01,u*length);var d:=Vector3(0,sin(u*PI)*.06,u*length)
   for v in [a,b,c,a,c,d]:st.set_color(Color(1.03,1.04,.99) if side==1 else Color(.93,.96,.91));st.set_uv(Vector2(v.x,v.z));st.add_vertex(v)
 st.generate_normals();var n:=G.node(parent,label,st.commit(),mat,at);n.rotation=rotation;return n
