extends RefCounted
## Small DEV modelling grammar. Heights/bevels are presentation choices, not Home geometry.
static func material(color:Color, texture:Texture2D=null, crop:=Vector4(0,0,1,1), grain:=Vector2.ONE, strength:=.3)->Material:
 if texture==null:
  var m:=StandardMaterial3D.new();m.albedo_color=color;m.roughness=.95;m.metallic=0;m.specular_mode=BaseMaterial3D.SPECULAR_DISABLED;m.vertex_color_use_as_albedo=true;return m
 var m:=ShaderMaterial.new();m.shader=load("res://scripts/dev/hybrid_diorama/painted_surface.gdshader")
 m.set_shader_parameter("surface_texture",texture);m.set_shader_parameter("painted_color",color);m.set_shader_parameter("texture_crop",crop);m.set_shader_parameter("grain_scale",grain);m.set_shader_parameter("texture_strength",strength);return m
static func node(parent:Node3D,name:String,mesh:Mesh,mat:Material,at:Vector3)->MeshInstance3D:
 var n:=MeshInstance3D.new();n.name=name;n.mesh=mesh;n.material_override=mat;n.position=at;parent.add_child(n);return n
static func bevel(parent:Node3D,name:String,size:Vector3,mat:Material,at:Vector3,edge:=.02)->MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var b:=minf(edge,minf(size.x,minf(size.y,size.z))*.28)
 var rings:Array=[]
 for j in 4:
  var inset:=b if j==0 or j==3 else 0.0
  var x:=size.x/2-inset;var z:=size.z/2-inset
  var y:float=[-size.y/2,-size.y/2+b,size.y/2-b,size.y/2][j]
  var cut:=minf(b,minf(x,z)*.35)
  rings.append([Vector3(-x+cut,y,-z),Vector3(x-cut,y,-z),Vector3(x,y,-z+cut),Vector3(x,y,z-cut),Vector3(x-cut,y,z),Vector3(-x+cut,y,z),Vector3(-x,y,z-cut),Vector3(-x,y,-z+cut)])
 for j in 3:
  for i in 8:
   var next: int=(i+1)%8
   quad(st,rings[j][i],rings[j][next],rings[j+1][next],rings[j+1][i],Color(.96,.96,.96) if j==1 else Color(1.045,1.025,.99))
 for i in 8:
  tri(st,Vector3(0,size.y/2,0),rings[3][i],rings[3][(i+1)%8],Color.WHITE)
  tri(st,Vector3(0,-size.y/2,0),rings[0][(i+1)%8],rings[0][i],Color(.91,.91,.91))
 st.generate_normals();return node(parent,name,st.commit(),mat,at)
static func tri(st:SurfaceTool,a:Vector3,b:Vector3,c:Vector3,color:Color):
 for p in [a,b,c]:st.set_color(color);st.set_uv(Vector2(p.x+p.z*.31,p.y+p.z*.57));st.add_vertex(p)
static func quad(st:SurfaceTool,a:Vector3,b:Vector3,c:Vector3,d:Vector3,color:Color):tri(st,a,b,c,color);tri(st,a,c,d,color)
static func cylinder(parent:Node3D,name:String,top:float,bottom:float,height:float,mat:Material,at:Vector3,segments:=24)->MeshInstance3D:
 var mesh:=CylinderMesh.new();mesh.top_radius=top;mesh.bottom_radius=bottom;mesh.height=height;mesh.radial_segments=segments;mesh.rings=1;return node(parent,name,mesh,mat,at)
static func sphere(parent:Node3D,name:String,size:Vector3,mat:Material,at:Vector3)->MeshInstance3D:
 var mesh:=SphereMesh.new();mesh.radius=.5;mesh.height=1;mesh.radial_segments=12;mesh.rings=6;var n:=node(parent,name,mesh,mat,at);n.scale=size;return n
static func rod(parent:Node3D,name:String,a:Vector3,b:Vector3,radius:float,mat:Material)->MeshInstance3D:
 var n:=cylinder(parent,name,radius,radius,a.distance_to(b),mat,(a+b)/2,12)
 n.quaternion=Quaternion(Vector3.UP,(b-a).normalized());return n
