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

manifest=json.loads((R/'assets/dev_review/hybrid_cafe_art_direction_v1/kit_manifest.json').read_text());receipts=[]
for row in manifest['assets']:
 short=row['asset_id'].removeprefix('WC_CAFE_')
 if short not in ['Counter_Straight_A','Counter_End_A','Counter_Short_A','Espresso_A','Grinder_A']:continue
 variant=R/'assets_src/3d/cafe_art_direction_v1'/row['source_blend'];source=variant if variant.exists() else R/'assets_src/3d/cafe_kit_v1'/row['source_blend']
 bpy.ops.wm.open_mainfile(filepath=str(source));bpy.context.preferences.filepaths.save_version=0;root=bpy.data.objects[row['asset_id']]
 # Material reassignment is local to the existing component, not a blanket wrapper override.
 
 for name,color in [('Ceramic_Offwhite',(.90,.80,.65,1)),('Charcoal_Trim',(.10,.08,.065,1)),('Restrained_Metal',(.25,.23,.20,1)),('Cedar_Dark',(.26,.17,.10,1))]:
  if 'WC_MAT_'+name not in bpy.data.materials:
   m=bpy.data.materials.new('WC_MAT_'+name);m.use_nodes=True;m.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=color
 stone=bpy.data.materials.new('WC_MAT_Cream_Stone');stone.use_nodes=True;bs=stone.node_tree.nodes.get('Principled BSDF');bs.inputs['Base Color'].default_value=(.86,.76,.61,1);bs.inputs['Roughness'].default_value=.92
 if short.startswith('Counter_'):
  for o in root.children_recursive:
   if o.name.startswith('CreamCedarTop'):o.data.materials.clear();o.data.materials.append(stone)
 if short=='Espresso_A':
  # Keep existing machine, two heads, gauges, tray, wand, cups and registered base.
  for o in root.children_recursive:
   if o.name.startswith('MatteMachineHousing'):
    o.data.materials.clear();o.data.materials.append(stone)
   if o.name.startswith('CreamFrontFace'):
    o.data.materials.clear();o.data.materials.append(bpy.data.materials['WC_MAT_Charcoal_Trim'])
   if o.name.startswith('Portafilter'):o.data.materials.clear();o.data.materials.append(bpy.data.materials['WC_MAT_Charcoal_Trim'])
  box(root,'RaisedControlHeader',(.76,.065,.025),(0,.542,.26),'Cedar_Dark',.007)
  for x in [-.15,-.045,.065,.175]:box(root,'CreamControlKey',(.050,.043,.016),(x,.468,.260),'Ceramic_Offwhite',.005)
  box(root,'CupDeckRolledLip',(.85,.032,.020),(0,.584,-.195),'Restrained_Metal',.007)
  for x in [-.44,.44]:box(root,'SoftSideCheek',(.038,.33,.38),(x,.31,.016),'Restrained_Metal',.010)
 if short=='Grinder_A':
  box(root,'GrinderControlPanel',(.10,.12,.018),(0,.265,.123),'Ceramic_Offwhite',.008)
  box(root,'GrinderControlKey',(.028,.026,.023),(0,.30,.137),'Charcoal_Trim',.004)
  box(root,'DoseCupSupport',(.16,.025,.10),(0,.115,.168),'Restrained_Metal',.006)
  box(root,'HopperCollar',(.24,.030,.24),(0,.443,0),'Restrained_Metal',.006)
 bpy.context.view_layer.update();contact=bake_contact(root)
 dest=O/'source'/row['source_blend'];dest.parent.mkdir(parents=True,exist_ok=True);bpy.ops.wm.save_as_mainfile(filepath=str(dest),compress=True,check_existing=False)
 for o in list(root.children_recursive):
  if o.type=='MESH':
   bpy.context.view_layer.objects.active=o
   for mod in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
 meshes=[o for o in root.children_recursive if o.type=='MESH'];bpy.ops.object.select_all(action='DESELECT')
 for o in meshes:o.select_set(True)
 bpy.context.view_layer.objects.active=meshes[0];bpy.ops.object.join();mesh=meshes[0];mesh.name=root.name+'_HeroServiceMesh';mesh.data.calc_loop_triangles();tris=len(mesh.data.loop_triangles)
 bpy.ops.object.select_all(action='DESELECT');root.select_set(True);mesh.select_set(True)
 export=O/'glb'/row['runtime_glb'];export.parent.mkdir(parents=True,exist_ok=True);bpy.ops.export_scene.gltf(filepath=str(export),export_format='GLB',use_selection=True,export_yup=True,export_normals=True,export_texcoords=True,export_extras=True,export_vertex_color='NAME',export_vertex_color_name='CavityPaint',export_all_vertex_colors=False)
 pts=[(q.x,q.z,-q.y) for q in [mesh.matrix_world@v.co for v in mesh.data.vertices]];lo=[min(q[i] for q in pts) for i in range(3)];hi=[max(q[i] for q in pts) for i in range(3)]
 receipts.append({**row,'input_source':str(source.relative_to(R)),'input_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_blend_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'glb_sha256':hashlib.sha256(export.read_bytes()).hexdigest(),'triangles_evaluated':tris,'measured_aabb_godot':{'position':lo,'size':[hi[i]-lo[i] for i in range(3)]},'cavity':contact})
(O/'refinement_receipt.json').write_text(json.dumps({'blender_version':bpy.app.version_string,'build_hash':bpy.app.build_hash.decode(),'refined_assets':receipts,'scope':'DEV V2 service material/components; unchanged coordinates/camera/gameplay'},indent=2)+'\n');print('V2 SERVICE REFINEMENTS',len(receipts))
