"""Bounded refinement of existing V1 blend assets. No new family/layout authority."""
import bpy,sys,argparse,json,math,hashlib
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
p=argparse.ArgumentParser();p.add_argument('--repo',required=True);p.add_argument('--out',required=True);a=p.parse_args(sys.argv[sys.argv.index('--')+1:]);R=Path(a.repo);O=Path(a.out);O.mkdir(parents=True,exist_ok=True);bpy.context.preferences.filepaths.save_version=0
manifest=json.loads((R/'assets/dev_review/hybrid_cafe_kit_v1/kit_manifest.json').read_text());selected=['Counter_Straight_A','Counter_End_A','Counter_Short_A','Table_Round_A','Chair_A','Wall_Window_A','Window_Recess_A','Shelf_A','Shelf_Short_A','Planter_Floor_A','Planter_Table_A','Lamp_Hanging_A','Espresso_A'];receipts=[]
def xyz(v):return (v[0],-v[2],v[1])
def finish(o,name,mat,root,bevel=.006):
 o.name=name;o.parent=root;o.data.materials.append(bpy.data.materials['WC_MAT_'+mat]);uv=o.data.uv_layers.active or o.data.uv_layers.new(name='UV0');uv.name='UV0'
 for f in o.data.polygons:
  pts=[o.data.vertices[i].co for i in f.vertices];normal=(pts[1]-pts[0]).cross(pts[-1]-pts[0]);axis=max(range(3),key=lambda i:abs(normal[i]));ds=[i for i in range(3) if i!=axis]
  for j in f.loop_indices:
   v=o.data.vertices[o.data.loops[j].vertex_index].co;uv.data[j].uv=(v[ds[0]]*.8,v[ds[1]]*.8)
 if bevel:
  m=o.modifiers.new('PolishBevel','BEVEL');m.width=bevel;m.segments=2;m.harden_normals=True;w=o.modifiers.new('PolishNormals','WEIGHTED_NORMAL');w.keep_sharp=True
 return o
def box(root,name,size,at,mat,bevel=.006):
 bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(at));o=bpy.context.object;o.dimensions=(size[0],size[2],size[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);return finish(o,name,mat,root,bevel)
def torus(root,name,radius,tube,at,mat):
 bpy.ops.mesh.primitive_torus_add(major_segments=32,minor_segments=6,major_radius=radius,minor_radius=tube,location=xyz(at));o=bpy.context.object
 for f in o.data.polygons:f.use_smooth=True
 return finish(o,name,mat,root,0)
def leaf(root,start,tip,width,mat):
 start=Vector(start);tip=Vector(tip);along=tip-start;side=along.cross(Vector((0,1,0))).normalized()*width;verts=[];faces=[]
 for i in range(11):
  t=i/10;w=math.sin(math.pi*t)**.68;center=start.lerp(tip,t)+Vector((0,math.sin(math.pi*t)*.045,0))
  for j in [-1,0,1]:verts.append(xyz(center+side*j*w+Vector((0,.035*(1-abs(j))*w,0))))
 for i in range(10):
  for j in range(2):q=i*3+j;faces.append((q,q+1,q+4,q+3))
 mesh=bpy.data.meshes.new('PolishedLeaf');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('LayeredCurvedLeaf',mesh);bpy.context.scene.collection.objects.link(o)
 for f in mesh.polygons:f.use_smooth=True
 finish(o,o.name,mat,root,0)
def bake_contact(root):
 # Short-range geometric occlusion, independent of scene lights. DEV authoring radius only.
 dg=bpy.context.evaluated_depsgraph_get();verts=[];faces=[]
 meshes=[o for o in root.children_recursive if o.type=='MESH']
 for o in meshes:
  evaluated=o.evaluated_get(dg);m=evaluated.to_mesh();offset=len(verts);verts.extend(o.matrix_world@v.co for v in m.vertices);faces.extend(tuple(offset+i for i in f.vertices) for f in m.polygons);evaluated.to_mesh_clear()
 bvh=BVHTree.FromPolygons(verts,faces,all_triangles=False);minimum=1.;maximum=0.
 for o in meshes:
  attr=o.data.color_attributes.get('CavityPaint') or o.data.color_attributes.new(name='CavityPaint',type='FLOAT_COLOR',domain='POINT');o.data.color_attributes.active_color=attr
  matrix=o.matrix_world.to_3x3().inverted().transposed()
  for i,v in enumerate(o.data.vertices):
   normal=(matrix@v.normal).normalized();pos=o.matrix_world@v.co;axis=normal.cross(Vector((0,0,1)))
   if axis.length<.01:axis=normal.cross(Vector((1,0,0)))
   axis.normalize();other=normal.cross(axis);hits=0
   for j in range(8):
    angle=j*math.tau/8;direction=(normal*.78+axis*math.cos(angle)*.62+other*math.sin(angle)*.62).normalized();hits+=bvh.ray_cast(pos+normal*.001,direction,.13)[0] is not None
   value=1.-.18*(hits/8);attr.data[i].color=(value,value,value,1);minimum=min(minimum,value);maximum=max(maximum,value)
 return {'method':'8 deterministic hemisphere rays / vertex; geometric local contact only, no scene-light cast bake','radius_dev_art_units':.13,'max_darkening_dev_art_choice':.18,'measured_min':minimum,'measured_max':maximum}
for row in manifest['assets']:
 short=row['asset_id'].removeprefix('WC_CAFE_')
 if short not in selected:continue
 source=R/'assets_src/3d/cafe_kit_v1'/row['source_blend'];bpy.ops.wm.open_mainfile(filepath=str(source));scene=bpy.context.scene;bpy.context.preferences.filepaths.save_version=0;root=bpy.data.objects[row['asset_id']]
 for o in root.children_recursive:
  if o.type!='MESH':continue
  for mod in o.modifiers:
   if mod.type=='BEVEL':mod.width*=1.16;mod.segments=3 if any(t in o.name for t in ['Top','Seat','Crown','Housing']) else 2
 if short.startswith('Counter_'):
  width={'Counter_Straight_A':2.24,'Counter_End_A':.73,'Counter_Short_A':.48}[short];depth={'Counter_Straight_A':.55,'Counter_End_A':.45,'Counter_Short_A':.35}[short]
  top=next(o for o in root.children_recursive if o.name.startswith('CreamCedarTop'));top.scale.z=1.16;top.location.z-=.009 # Top surface height preserved.
  count=max(1,round(width/.55));panel=(width-.10)/count
  for i in range(count):
   x=-width/2+.05+(i+.5)*panel
   box(root,'InnerPanelUpperBead',(panel-.087,.024,.020),(x,.864,depth/2+.045),'Cedar_Light',.004)
   box(root,'InnerPanelLowerBead',(panel-.087,.024,.020),(x,.196,depth/2+.045),'Cedar_Dark',.004)
  box(root,'SoftCounterBaseMoulding',(width-.07,.042,depth-.055),(0,.105,0),'Cedar_Mid',.006)
 if short=='Table_Round_A':
  torus(root,'WarmTableEdgeBead',.790,.010,(0,.834,0),'Cedar_Mid');torus(root,'PedestalCollar',.137,.008,(0,.21,0),'Cedar_Light')
 if short=='Chair_A':
  # Piping and corner pegs provide fabric thickness without high subdivision.
  for x in [-.21,.21]:box(root,'SeatPiping',(.012,.012,.31),(x,.554,-.01),'Sage_Fabric',.004)
  box(root,'BackrestLowerCedarRail',(.43,.025,.075),(0,.66,-.218),'Cedar_Mid',.005)
 if short in ['Wall_Window_A','Window_Recess_A']:
  width=1.6 if short=='Wall_Window_A' else 1.5;y=.53 if short=='Wall_Window_A' else .03
  box(root,'WindowInnerSillBead',(width-.29,.026,.10),(width/2,y,.105),'Cedar_Light',.005)
 if short.startswith('Shelf'):
  width=1.8 if short=='Shelf_A' else .85;box(root,'ShelfLowerEdgeBead',(width,.019,.045),(width/2,-.046,.32),'Cedar_Dark',.004)
 if short.startswith('Planter_'):
  small=short=='Planter_Table_A';k=.43 if small else 1.
  # Existing pot/trunk/plant retained. Interleave rounder foliage and modest trailing clusters.
  for i in range(30):
   angle=i*2.399;h=.54+(i%5)*.10;start=(math.cos(angle)*.07,h,math.sin(angle)*.07);reach=.27+(i%3)*.035;tip=(math.cos(angle)*reach,h+.10-(.12 if i%5==0 else 0),math.sin(angle)*reach)
   leaf(root,tuple(x*k for x in start),tuple(x*k for x in tip),(.085+(i%3)*.011)*k,['Foliage_Dark','Foliage','Foliage_Light'][i%3])
 if short=='Espresso_A':
  box(root,'SoftServiceHousingFoot',(.85,.047,.38),(0,.026,0),'Cedar_Dark',.012);box(root,'WarmMachineHeader',(.80,.023,.045),(0,.54,.245),'Restrained_Metal',.005)
 if short=='Lamp_Hanging_A':
  torus(root,'SoftLanternLowerCollar',.092,.009,(0,-.607,0),'Restrained_Metal')
 bpy.context.view_layer.update();contact=bake_contact(root)
 source_dest=O/'source'/row['source_blend'];source_dest.parent.mkdir(parents=True,exist_ok=True);bpy.ops.wm.save_as_mainfile(filepath=str(source_dest),compress=True,check_existing=False)
 for o in list(root.children_recursive):
  if o.type=='MESH':
   bpy.context.view_layer.objects.active=o
   for mod in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
 meshes=[o for o in root.children_recursive if o.type=='MESH'];bpy.ops.object.select_all(action='DESELECT')
 for o in meshes:o.select_set(True)
 bpy.context.view_layer.objects.active=meshes[0];bpy.ops.object.join();mesh=meshes[0];mesh.name=root.name+'_PolishedRenderMesh';mesh.data.calc_loop_triangles();tris=len(mesh.data.loop_triangles)
 bpy.ops.object.select_all(action='DESELECT');root.select_set(True);mesh.select_set(True)
 export=O/'glb'/row['runtime_glb'];export.parent.mkdir(parents=True,exist_ok=True);bpy.ops.export_scene.gltf(filepath=str(export),export_format='GLB',use_selection=True,export_yup=True,export_normals=True,export_texcoords=True,export_extras=True,export_vertex_color="NAME",export_vertex_color_name="CavityPaint",export_all_vertex_colors=False)
 coords=[(q.x,q.z,-q.y) for q in [mesh.matrix_world@v.co for v in mesh.data.vertices]];lo=[min(q[i] for q in coords) for i in range(3)];hi=[max(q[i] for q in coords) for i in range(3)]
 receipts.append({**row,'original_blend_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_blend_sha256':hashlib.sha256(source_dest.read_bytes()).hexdigest(),'glb_sha256':hashlib.sha256(export.read_bytes()).hexdigest(),'triangles_evaluated':tris,'measured_aabb_godot':{'position':lo,'size':[hi[i]-lo[i] for i in range(3)]},'cavity':contact})
(O/'refinement_receipt.json').write_text(json.dumps({'blender_version':bpy.app.version_string,'build_hash':bpy.app.build_hash.decode(),'original_kit_reused':True,'refined_assets':receipts,'unchanged_geometry_assets':27-len(receipts),'scope':'DEV art direction only; original kit source files untouched'},indent=2)+'\n');print('ART DIRECTION REFINEMENTS COMPLETE',len(receipts))
