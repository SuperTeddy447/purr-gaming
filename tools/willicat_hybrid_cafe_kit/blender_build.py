"""First-party, deterministic DEV Blender cafe builders. No world-layout ownership."""
import bpy, math, json, argparse, sys, hashlib
from pathlib import Path
from mathutils import Vector
p=argparse.ArgumentParser();p.add_argument('--out',required=True);p.add_argument('--textures',required=True);p.add_argument('--calibration-only',action='store_true');args=p.parse_args(sys.argv[sys.argv.index('--')+1:])
OUT=Path(args.out);TEX=Path(args.textures);OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
scene=bpy.context.scene;scene.unit_settings.system='METRIC';scene.unit_settings.scale_length=1.0
M={};parts=[];assets=[]
def xyz(v):return (v[0],-v[2],v[1])
def material(name,color,texture=None,roughness=.94):
 m=bpy.data.materials.new('WC_MAT_'+name);m.use_nodes=True;n=m.node_tree.nodes.get('Principled BSDF');n.inputs['Base Color'].default_value=(*color,1);n.inputs['Roughness'].default_value=roughness;n.inputs['Metallic'].default_value=0;n.inputs['Specular IOR Level'].default_value=.13
 if texture:
  image=bpy.data.images.load(str(TEX/texture),check_existing=True);image.pack();t=m.node_tree.nodes.new('ShaderNodeTexImage');t.image=image;t.extension='REPEAT';mix=m.node_tree.nodes.new('ShaderNodeMixRGB');mix.blend_type='MULTIPLY';mix.inputs[0].default_value=1;mix.inputs[2].default_value=(*color,1);m.node_tree.links.new(t.outputs['Color'],mix.inputs[1]);m.node_tree.links.new(mix.outputs[0],n.inputs['Base Color'])
 M[name]=m;return m
material('Cedar_Light',(1.0,.99,.96),'cedar_painted.png');material('Cedar_Mid',(.82,.77,.70),'cedar_painted.png');material('Cedar_Dark',(.43,.38,.34),'cedar_painted.png');material('Plaster_Cream',(1,1,1),'plaster_painted.png');material('Sage_Fabric',(1,1,1),'sage_woven.png');material('Ceramic_Offwhite',(1,1,1),'ceramic_painted.png',.84);material('Charcoal_Trim',(.095,.075,.06));material('Restrained_Metal',(.42,.31,.18),roughness=.82);material('Foliage',(1,1,1),'foliage_painted.png');material('Foliage_Light',(1.18,1.12,.90),'foliage_painted.png');material('Foliage_Dark',(.56,.67,.52),'foliage_painted.png');material('Coffee',(.07,.037,.022));material('Paper_Warm',(.94,.84,.66));material('Lantern_Paper',(.98,.76,.43));M['Lantern_Paper'].node_tree.nodes.get('Principled BSDF').inputs['Emission Color'].default_value=(.98,.65,.29,1);M['Lantern_Paper'].node_tree.nodes.get('Principled BSDF').inputs['Emission Strength'].default_value=.14;material('Indigo',(.11,.19,.22),'ceramic_painted.png')
def root(name,origin='ground_contact_center'):
 global parts
 parts=[];r=bpy.data.objects.new(name,None);scene.collection.objects.link(r);r['semantic_origin']=origin;r['coordinate_contract']='Blender X/right Z/up -Y/front -> Godot X/right Y/up +Z/front';return r
def finish(o,name,mat,r,bevel=0,smooth=False):
 o.name=name;o.data.name=name+'_Mesh';o.data.materials.append(M[mat]);o.parent=r
 if bevel:
  b=o.modifiers.new('SoftAuthoredBevel','BEVEL');b.width=bevel;b.segments=2;b.affect='EDGES';b.harden_normals=True
  w=o.modifiers.new('FaceWeightedNormals','WEIGHTED_NORMAL');w.keep_sharp=True;w.weight=50
 for f in o.data.polygons:f.use_smooth=smooth
 # UV0 generated from local painted material axes, not arbitrary per-asset unique maps.
 if not o.data.uv_layers:o.data.uv_layers.new(name='UV0')
 uv=o.data.uv_layers.active;uv.name="UV0"
 for f in o.data.polygons:
  points=[o.data.vertices[i].co for i in f.vertices]
  normal=Vector((0,0,0))
  for index in range(1,len(points)-1):
   candidate=(points[index]-points[0]).cross(points[index+1]-points[0])
   if candidate.length_squared>normal.length_squared:normal=candidate
  axis=max(range(3),key=lambda i:abs(normal[i]));dims=[i for i in range(3) if i!=axis]
  for j in f.loop_indices:
   v=o.data.vertices[o.data.loops[j].vertex_index].co;uv.data[j].uv=(v[dims[0]]*.8,v[dims[1]]*.8)
 parts.append(o);return o
def box(r,name,size,at,mat='Cedar_Mid',bevel=.01):
 bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(at));o=bpy.context.object;o.dimensions=(size[0],size[2],size[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);return finish(o,name,mat,r,bevel)
def cylinder(r,name,rad,height,at,mat='Ceramic_Offwhite',vertices=24,bevel=.006):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=rad,depth=height,location=xyz(at));return finish(bpy.context.object,name,mat,r,bevel,True)
def rod(r,name,a,b,rad,mat='Cedar_Mid'):
 va=Vector(xyz(a));vb=Vector(xyz(b));d=vb-va;bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=rad,depth=d.length,location=(va+vb)/2);o=bpy.context.object;o.rotation_mode='QUATERNION';o.rotation_quaternion=d.to_track_quat('Z','Y');bpy.ops.object.transform_apply(location=False,rotation=True,scale=True);return finish(o,name,mat,r,.003,True)
def lathe(r,name,profile,at,mat='Cedar_Mid',segments=32):
 verts=[];faces=[];rings=[]
 for radius,height in profile:
  if radius==0:
   rings.append([len(verts)]);verts.append(xyz((at[0],at[1]+height,at[2])))
  else:
   ring_ids=[]
   for i in range(segments):
    a=i*math.tau/segments;ring_ids.append(len(verts));verts.append(xyz((at[0]+radius*math.cos(a),at[1]+height,at[2]+radius*math.sin(a))))
   rings.append(ring_ids)
 for first,second in zip(rings,rings[1:]):
  for i in range(segments):
   j=(i+1)%segments
   if len(first)==1:faces.append((first[0],second[j],second[i]))
   elif len(second)==1:faces.append((first[i],first[j],second[0]))
   else:faces.append((first[i],first[j],second[j],second[i]))
 mesh=bpy.data.meshes.new(name+'_Mesh');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(name,mesh);scene.collection.objects.link(o)
 # Surface order is authored; recalculate outward normals including hollow rim surfaces.
 import bmesh;bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(mesh);bm.free()
 return finish(o,name,mat,r,0,True)
def ring(r,name,major,minor,at,mat='Cedar_Dark'):
 bpy.ops.mesh.primitive_torus_add(major_segments=32,minor_segments=8,location=xyz(at),major_radius=major,minor_radius=minor);return finish(bpy.context.object,name,mat,r,0,True)
def cup(r,at=(0,0,0),scale=1):
 profile=[(0,0),(.068,0),(.085,.02),(.103,.14),(.097,.153),(.085,.148),(.07,.035),(0,.035)]
 lathe(r,'HollowCup',[(x*scale,y*scale) for x,y in profile],at,'Ceramic_Offwhite',24);cylinder(r,'CoffeeSurface',.083*scale,.002,(at[0],at[1]+.133*scale,at[2]),'Coffee',24,0);lathe(r,'Saucer',[(0,-.009),(.13,-.009),(.148,.008),(.14,.020),(0,.012)],at,'Ceramic_Offwhite',24)
 h=ring(r,'CupHandle',.047*scale,.012*scale,(at[0]+.115*scale,at[1]+.085*scale,at[2]),'Ceramic_Offwhite');h.rotation_euler[1]=math.pi/2

def create_round_table(name='WC_CAFE_Table_Round_A',width=1.65,height=.89):
 r=root(name);k=width/1.65
 lathe(r,'AuthoredRoundedTop',[(0,height-.11),(.75*k,height-.11),(.81*k,height-.092),(.825*k,height-.055),(.81*k,height-.012),(.76*k,height),(0,height)],(0,0,0),'Cedar_Light',48)
 ring(r,'ApronBead',.73*k,.016,(0,height-.115,0))
 lathe(r,'TurnedPedestal',[(0,0),(.13,0),(.17,.05),(.14,.14),(.105,.20),(.105,height-.25),(.19,height-.19),(.24,height-.13),(0,height-.13)],(0,0,0),'Cedar_Mid',32)
 for i in range(4):
  a=i*math.tau/4+.24;rod(r,'ShapedSplayedFoot',(0,.18,0),(.43*math.cos(a),.07,.43*math.sin(a)),.055,'Cedar_Dark')
 return r

def export_asset(r,family,dimensions,registration):
 target=OUT/family;target.mkdir(parents=True,exist_ok=True)
 bpy.ops.object.select_all(action='DESELECT');r.select_set(True)
 for o in r.children_recursive:o.select_set(True)
 bpy.context.view_layer.objects.active=r
 # Selection export includes no catalog camera/light/helper, applies bevel and exports UV0/normals/materials.
 bpy.ops.wm.save_as_mainfile(filepath=str(target/(r.name+'.blend')),check_existing=False,compress=True)
 # Bake modifiers only in the export working scene, after saving editable source.
 for o in list(r.children_recursive):
  if o.type=='MESH':
   bpy.context.view_layer.objects.active=o
   for modifier in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=modifier.name)
 meshes=[o for o in r.children_recursive if o.type=='MESH']
 bpy.ops.object.select_all(action='DESELECT')
 for o in meshes:o.select_set(True)
 if meshes:
  bpy.context.view_layer.objects.active=meshes[0];bpy.ops.object.join();meshes[0].name=r.name+'_RenderMesh'
 bpy.ops.object.select_all(action='DESELECT');r.select_set(True)
 for o in r.children_recursive:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(target/(r.name+'.glb')),export_format='GLB',use_selection=True,export_apply=True,export_yup=True,export_normals=True,export_texcoords=True,export_cameras=False,export_lights=False,export_extras=True)
 dg=bpy.context.evaluated_depsgraph_get();tris=0
 for o in r.children_recursive:
  if o.type=='MESH':
   m=o.evaluated_get(dg).to_mesh();m.calc_loop_triangles();tris+=len(m.loop_triangles);o.evaluated_get(dg).to_mesh_clear()
 coords=[xyz((c[0],c[2],-c[1])) for o in r.children_recursive if o.type=='MESH' for c in [(o.matrix_world @ v.co) for v in o.data.vertices]]
 # Convert Blender coordinates to Godot explicitly for measurement only; export still owns conversion.
 coords=[(q[0],q[2],-q[1]) for o in r.children_recursive if o.type=='MESH' for q in [(o.matrix_world @ v.co) for v in o.data.vertices]]
 lo=[min(q[i] for q in coords) for i in range(3)];hi=[max(q[i] for q in coords) for i in range(3)]
 row={'measured_aabb_godot':{'position':lo,'size':[hi[i]-lo[i] for i in range(3)]},'asset_id':r.name,'family':family,'source_blend':family+'/'+r.name+'.blend','runtime_glb':family+'/'+r.name+'.glb','origin':r['semantic_origin'],'nominal_design_dimensions_godot':dimensions,'registration':registration,'mesh_parts':len(r.children_recursive),'triangles_evaluated':tris,'uv0':True,'uv2':'not authored; generate nonoverlapping unwrap on evaluated export mesh in Godot Advanced Import before a later LightmapGI bake','root_transform_identity':True}
 assets.append(row);return row

if args.calibration_only:
 r=create_round_table('WC_CAFE_Calibration_Table_A');export_asset(r,'calibration',[1.65,.89,1.65],{'origin':'ground_contact_center','gameplay_collision':'none in imported GLB; existing 2D footprint is authority'})
 (OUT/'build_receipt.json').write_text(json.dumps({'blender_version':bpy.app.version_string,'build_hash':bpy.app.build_hash.decode(),'background':bpy.app.background,'bpy_execution':True,'assets':assets,'source_textures':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in TEX.glob('*.png')}},indent=2)+'\n')
 print('WILLICAT CALIBRATION BUILD COMPLETE')

# Family builders use Godot-space dimensions; xyz() is the single authored-axis bridge.
def create_wall_module(name,width=1.6,height=2.48,window=False):
 r=root(name,'structural_left_ground_corner');d=.18
 if window:
  for size,at in [((.15,height,d),(.075,height/2,0)),((.15,height,d),(width-.075,height/2,0)),((width-.3,.52,d),(width/2,.26,0)),((width-.3,.30,d),(width/2,height-.15,0))]:box(r,'PlasterAroundOpening',size,at,'Plaster_Cream',.012)
 else:box(r,'CreamPlaster', (width,height,d),(width/2,height/2,0),'Plaster_Cream',.014)
 for x in [.05,width-.05]:box(r,'CedarRegistrationStile',(.10,height+.06,.24),(x,(height+.06)/2,.025),'Cedar_Dark',.01)
 for y in [.10,.87,height-.07]:box(r,'HorizontalCedarRail',(width,.095,.23),(width/2,y,.045),'Cedar_Mid',.009)
 if window:
  box(r,'QuietShojiPaper',(width-.32,1.58,.025),(width/2,1.35,-.085),'Paper_Warm',.005)
  for x in [.15,width-.15]:box(r,'RecessedWindowJamb',(.085,1.7,.24),(x,1.35,.02),'Cedar_Mid',.01)
  for y in [.50,2.20]:box(r,'WindowLintel',(width-.2,.085,.24),(width/2,y,.02),'Cedar_Light',.012)
  for i in range(1,5):box(r,'ShojiMullion',(.025,1.58,.085),(.15+(width-.3)*i/5,1.35,.09),'Cedar_Mid',.004)
  for y in [.82,1.22,1.62,2.02]:box(r,'ShojiCrossbar',(width-.31,.025,.085),(width/2,y,.09),'Cedar_Mid',.004)
 return r

def create_beam(name,width=1.6,height=.12,depth=.20):
 r=root(name,'structural_left_endpoint');box(r,'SoftCedarBeam',(width,height,depth),(width/2,height/2,0),'Cedar_Mid',.012);return r

def create_window(name='WC_CAFE_Window_Recess_A',width=1.50,height=1.70):
 r=root(name,'wall_insertion_lower_left')
 for x in [0,width]:box(r,'WindowJamb',(.09,height,.23),(x,height/2,0),'Cedar_Mid',.01)
 for y in [0,height]:box(r,'WindowHeader',(width+.10,.09,.23),(width/2,y,0),'Cedar_Light',.012)
 box(r,'QuietPaperBacking',(width-.10,height-.10,.02),(width/2,height/2,-.11),'Paper_Warm',.005)
 for i in range(1,5):box(r,'ShojiVertical',(.025,height-.10,.055),(width*i/5,height/2,0),'Cedar_Mid',.003)
 for i in range(1,4):box(r,'ShojiHorizontal',(width-.10,.025,.055),(width/2,height*i/4,0),'Cedar_Mid',.003)
 return r

def create_door_frame(name='WC_CAFE_Entrance_Open_A',opening=.64,height=1.90):
 r=root(name,'authoritative_aperture_ground_center')
 height=1.70
 for x in [-opening/2-.065,opening/2+.065]:
  box(r,'DoorRegistrationPost',(.13,height,.24),(x,height/2,0),'Cedar_Dark',.012);box(r,'InsetPostFace',(.075,height-.15,.035),(x,height/2,.13),'Cedar_Mid',.005)
 verts=[];faces=[]
 for i in range(25):
  a=i*math.pi/24
  for rad,z in [(opening/2,-.12),(opening/2+.14,-.12),(opening/2,.12),(opening/2+.14,.12)]:verts.append(xyz((math.cos(a)*rad,height+math.sin(a)*rad,z)))
 for i in range(24):
  q=i*4
  for j,k in [(0,1),(2,3),(0,2),(1,3)]:faces.append((q+j,q+k,q+k+4,q+j+4))
 faces += [(0,2,3,1),(96,97,99,98)]
 mesh=bpy.data.meshes.new('AuthoredArch');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('BeveledEntranceArch',mesh);scene.collection.objects.link(o)
 import bmesh;bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(mesh);bm.free();finish(o,o.name,'Cedar_Mid',r,.009)

 return r

def create_counter(name='WC_CAFE_Counter_Straight_A',width=2.24,depth=.55,height=1.08):
 r=root(name,'logical_floor_base_center')
 box(r,'DarkRecessedCarcass',(width-.06,height-.14,depth-.05),(0,(height-.14)/2+.07,0),'Cedar_Dark',.02)
 box(r,'CreamCedarTop',(width+.09,.11,depth+.10),(0,height-.055,0),'Cedar_Light',.018)
 box(r,'CedarTopNosing',(width+.09,.045,.045),(0,height-.12,depth/2+.025),'Cedar_Mid',.01)
 count=max(1,round(width/.55));panel=(width-.10)/count
 for i in range(count):
  x=-width/2+.05+(i+.5)*panel;box(r,'RecessedSagePanel',(panel-.065,.68,.024),(x,.53,depth/2),'Sage_Fabric',.004)
  for dx in [-panel/2+.024,panel/2-.024]:box(r,'PanelCedarStile',(.044,.78,.055),(x+dx,.53,depth/2+.03),'Cedar_Mid',.006)
  for y in [.14,.92]:box(r,'PanelRaisedRail',(panel,.06,.055),(x,y,depth/2+.03),'Cedar_Mid',.007)
  for dx in [-panel/2+.045,panel/2-.045]:box(r,'RestrainedBrassPanelLine',(.008,.64,.007),(x+dx,.53,depth/2+.038),'Restrained_Metal',.001)
 for x in [-width/2+.04,width/2-.04]:box(r,'CounterCornerPost',(.08,height-.12,depth),(x,(height-.12)/2+.025,0),'Cedar_Mid',.014)
 box(r,'ToeKick',(width-.13,.10,depth-.12),(0,.05,0),'Cedar_Dark',.007)
 # Authored rear service shelves, recessed; no arbitrary solid extension into free paths.
 for y in [.30,.63]:box(r,'ServiceRearRail',(width-.15,.045,.09),(0,y,-depth/2+.04),'Cedar_Mid',.006)
 return r

def create_chair(name='WC_CAFE_Chair_A'):
 r=root(name)
 box(r,'SculptedSeatFrame',(.52,.085,.43),(0,.46,0),'Cedar_Mid',.020);box(r,'SageSeat',(.46,.065,.37),(0,.525,-.01),'Sage_Fabric',.025)
 for x in [-.195,.195]:
  for z in [-.15,.15]:rod(r,'TaperedLeg',(x*1.07,.025,z*1.05),(x,.445,z),.032,'Cedar_Dark')
  rod(r,'SideStretcher',(x,.21,-.15),(x,.21,.15),.016,'Cedar_Mid');rod(r,'ShapedBackStile',(x,.445,-.15),(x*1.08,1.02,-.23),.032,'Cedar_Mid')
 box(r,'RoundedBackCrown',(.54,.08,.095),(0,1.035,-.23),'Cedar_Light',.020);box(r,'SageBackrest',(.36,.32,.072),(0,.83,-.205),'Sage_Fabric',.022)
 for x in [-.135,0,.135]:box(r,'BackSpindle',(.025,.37,.08),(x,.82,-.25),'Cedar_Mid',.006)
 return r

def create_shelf(name='WC_CAFE_Shelf_A',width=1.80):
 r=root(name,'left_wall_mount_endpoint')
 box(r,'ShelfSlab',(width,.085,.37),(width/2,0,.16),'Cedar_Mid',.012);box(r,'ShelfLip',(width,.08,.055),(width/2,.02,.36),'Cedar_Light',.008)
 for x in [.15,width-.15]:
  box(r,'WallMount',(.06,.33,.09),(x,-.14,-.04),'Cedar_Dark',.009);rod(r,'ShelfDiagonal',(x,-.30,-.04),(x,-.035,.29),.025,'Cedar_Mid')
 return r

def leaf(r,start,tip,width,mat):
 a=Vector(start);b=Vector(tip);along=b-a;side=along.cross(Vector((0,1,0))).normalized()*width;verts=[];faces=[]
 for i in range(7):
  t=i/6;center=a.lerp(b,t)+Vector((0,math.sin(math.pi*t)*.08,0));w=math.sin(math.pi*t)**.8
  for j in [-1,0,1]:verts.append(xyz(center+side*j*w+Vector((0,.025*(1-abs(j))*w,0))))
 for i in range(6):
  for j in range(2):q=i*3+j;faces.append((q,q+1,q+4,q+3))
 mesh=bpy.data.meshes.new('CurvedLeafMesh');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('AuthoredCurvedLeaf',mesh);scene.collection.objects.link(o);finish(o,o.name,mat,r,0,True)

def create_planter(name='WC_CAFE_Planter_Floor_A',small=False):
 r=root(name);k=.43 if small else 1
 lathe(r,'ThrownCeramicPot',[(0,0),(.11,0),(.13,.025),(.255,.32),(.265,.40),(.245,.425),(.222,.397),(.12,.06),(0,.06)],(0,0,0),'Ceramic_Offwhite',32)
 for y in [.10,.35]:ring(r,'PaintedPotBand',.165 if y<.2 else .258,.006,(0,y,0),'Indigo')
 cylinder(r,'PotSoil',.22,.013,(0,.378,0),'Coffee',24,0)
 for branch in range(5):
  a=branch*2.399;top=(math.cos(a)*.11,.83+branch*.04,math.sin(a)*.12);rod(r,'Branch',(0,.37,0),top,.009,'Foliage_Dark')
  for level in range(4):
   aa=a+level*1.6;h=.48+level*.13;start=(top[0]*(h-.37)/(.5+branch*.04),h,top[2]*(h-.37)/(.5+branch*.04));tip=(start[0]+math.cos(aa)*(.32-level*.024),h+.16,start[2]+math.sin(aa)*(.29-level*.022));leaf(r,start,tip,.077,['Foliage','Foliage_Light','Foliage_Dark'][(branch+level)%3])
 if small:
  for o in r.children:o.scale*=k;o.location*=k
 return r

def create_ceramic_pot(name='WC_CAFE_Ceramic_Jar_A'):
 r=root(name);lathe(r,'CeramicJar',[(0,0),(.075,0),(.105,.05),(.105,.19),(.087,.23),(.083,.26),(0,.26)],(0,0,0),'Ceramic_Offwhite',24);cylinder(r,'CedarLid',.09,.027,(0,.274,0),'Cedar_Mid',24);box(r,'BlankPaperLabel',(.12,.095,.008),(0,.14,.104),'Paper_Warm',.004);return r

def create_lamp(name='WC_CAFE_Lamp_Hanging_A',wall=False):
 r=root(name,'mounting_point')
 if wall:
  cylinder(r,'MountRose',.07,.025,(0,0,0),'Restrained_Metal',20);rod(r,'CurvedBracket',(0,0,0),(0,.04,.20),.014,'Restrained_Metal');at=(0,-.12,.22)
 else:rod(r,'HangingCord',(0,0,0),(0,-.26,0),.009,'Charcoal_Trim');at=(0,-.46,0)
 lathe(r,'QuietPaperLantern',[(0,-.15),(.09,-.15),(.13,-.11),(.145,0),(.12,.13),(.08,.17),(0,.17)],at,'Lantern_Paper',32)
 for i in range(5):ring(r,'LanternCedarRib',.116+(.024 if i==2 else .010),.006,(at[0],at[1]-.10+i*.053,at[2]),'Cedar_Mid')
 cylinder(r,'LanternCap',.085,.025,(at[0],at[1]+.19,at[2]),'Restrained_Metal',20);return r

def create_espresso(name='WC_CAFE_Espresso_A'):
 r=root(name,'countertop_contact_center')
 box(r,'MatteMachineHousing',(.88,.51,.44),(0,.31,0),'Charcoal_Trim',.028);box(r,'CreamFrontFace',(.83,.19,.025),(0,.46,.232),'Ceramic_Offwhite',.014);box(r,'ExtractionRecess',(.73,.19,.020),(0,.23,.232),'Charcoal_Trim',.018)
 for x in [-.22,.22]:
  rod(r,'GroupHead',(x,.32,.23),(x,.29,.30),.051,'Restrained_Metal');rod(r,'Portafilter',(x,.29,.30),(x+.018,.28,.48),.020,'Cedar_Dark');cup(r,(x,.075,.27),.70)
 for x in [-.33,.33]:
  g=cylinder(r,'GaugeRim',.048,.019,(x,.46,.259),'Restrained_Metal',20);g.rotation_euler[0]=math.pi/2
  g=cylinder(r,'GaugeFace',.038,.020,(x,.46,.272),'Paper_Warm',20);g.rotation_euler[0]=math.pi/2
  rod(r,'GaugeNeedle',(x-.013,.448,.286),(x+.015,.473,.286),.003,'Charcoal_Trim')
 box(r,'DripTray',(.86,.03,.30),(0,.055,.27),'Restrained_Metal',.012)
 for i in range(9):box(r,'TrayGroove',(.012,.006,.24),(-.34+i*.085,.074,.27),'Charcoal_Trim',.002)
 rod(r,'SteamWand',(.39,.33,.25),(.44,.14,.35),.012,'Restrained_Metal');cup(r,(-.17,.565,0),.78);cup(r,(.17,.565,0),.78)
 return r

def create_grinder(name='WC_CAFE_Grinder_A'):
 r=root(name,'countertop_contact_center');box(r,'GrinderFoot',(.31,.065,.34),(0,.033,0),'Charcoal_Trim',.018);lathe(r,'MotorBody',[(0,0),(.13,0),(.125,.10),(.10,.32),(.14,.37),(0,.37)],(0,.07,0),'Charcoal_Trim',24);lathe(r,'CoffeeHopper',[(0,0),(.09,0),(.165,.14),(.17,.28),(.15,.30),(0,.30)],(0,.44,0),'Indigo',24);cylinder(r,'HopperLid',.17,.025,(0,.755,0),'Cedar_Dark',24);box(r,'CoffeeNozzle',(.07,.06,.10),(0,.39,.15),'Restrained_Metal',.01);return r

def create_pos(name='WC_CAFE_POS_A'):
 r=root(name,'countertop_contact_center');box(r,'POSBase',(.28,.055,.23),(0,.027,0),'Cedar_Dark',.014);rod(r,'POSStem',(0,.05,0),(0,.18,-.025),.023,'Restrained_Metal');o=box(r,'POSTerminal',(.25,.19,.055),(0,.24,-.018),'Charcoal_Trim',.016);o.rotation_euler[0]=-.18;box(r,'QuietBlankScreen',(.20,.13,.008),(0,.25,.014),'Indigo',.009);return r

def create_sign(name='WC_CAFE_Sign_Blank_A',width=1.55,height=.52):
 r=root(name,'wall_mount_center');box(r,'QuietBlankSign',(width,height,.045),(0,0,0),'Sage_Fabric',.012)
 for x in [-width/2,width/2]:box(r,'SignStile',(.06,height+.06,.07),(x,0,.025),'Cedar_Dark',.01)
 for y in [-height/2,height/2]:box(r,'SignRail',(width+.06,.06,.07),(0,y,.025),'Cedar_Mid',.01)
 for x in [-width/2+.08,width/2-.08]:
  for y in [-height/2+.08,height/2-.08]:box(r,'SmallBrassCorner',(.06,.06,.009),(x,y,.069),'Restrained_Metal',.01)
 return r

def create_rest(name='WC_CAFE_Cat_Cushion_A'):
 r=root(name);box(r,'CedarRestBase',(.82,.17,.36),(0,.09,0),'Cedar_Mid',.025);box(r,'SageCatCushion',(.76,.09,.34),(0,.22,0),'Sage_Fabric',.05);return r

def create_floor(name='WC_CAFE_Floor_Section_A',width=6.4,depth=10.24):
 r=root(name,'cafe_northwest_ground_corner');box(r,'DioramaFoundation',(width,.16,depth),(width/2,-.09,depth/2),'Cedar_Dark',.015)
 for row in range(32):
  edges=[0,.7,2.3,3.9,5.5,width] if row%2 else [0,1.5,3.1,4.7,width]
  for a,b in zip(edges,edges[1:]):box(r,'StaggeredFloorPlank',(b-a-.005,.035,.315),((a+b)/2,-.015,(row+.5)*.32),'Cedar_Light',.003)
 return r

if not args.calibration_only:
 definitions=[
 ('architecture',lambda:create_wall_module('WC_CAFE_Wall_Cream_A'),[1.6,2.54,.24]),
 ('architecture',lambda:create_wall_module('WC_CAFE_Wall_Window_A',window=True),[1.6,2.54,.24]),
 ('architecture',lambda:create_beam('WC_CAFE_Beam_Cedar_A'),[1.6,.12,.20]),
 ('architecture',lambda:create_beam('WC_CAFE_Post_Cedar_A',.13,2.54,.22),[.13,2.54,.22]),
 ('architecture',lambda:create_window(),[1.6,1.8,.23]),
 ('architecture',lambda:create_beam('WC_CAFE_Window_Sill_A',1.66,.09,.40),[1.66,.09,.40]),
 ('architecture',lambda:create_door_frame(),[.94,2.16,.25]),
 ('architecture',lambda:create_beam('WC_CAFE_Trim_Cedar_A',1.6,.055,.075),[1.6,.055,.075]),
 ('architecture',lambda:create_floor(),[6.4,.195,10.24]),
 ('counter',lambda:create_counter(),[2.33,1.08,.65]),
 ('counter',lambda:create_counter('WC_CAFE_Counter_End_A',.73,.45),[.82,1.08,.55]),
 ('counter',lambda:create_counter('WC_CAFE_Counter_Short_A',.48,.35),[.57,1.08,.45]),
 ('service',lambda:create_espresso(),[.91,.73,.76]),
 ('service',lambda:create_grinder(),[.34,.78,.34]),
 ('service',lambda:create_pos(),[.28,.34,.23]),
 ('service',lambda:(lambda r:(cup(r),r)[1])(root('WC_CAFE_Cup_Saucer_A')),[.17,.16,.30]),
 ('furniture',lambda:create_round_table(),[1.65,.89,1.65]),
 ('furniture',lambda:create_chair(),[.56,1.08,.43]),
 ('decor',lambda:create_shelf(),[1.8,.35,.44]),
 ('decor',lambda:create_shelf('WC_CAFE_Shelf_Short_A',.85),[.85,.35,.44]),
 ('decor',lambda:create_planter(),[.9,1.22,.9]),
 ('decor',lambda:create_planter('WC_CAFE_Planter_Table_A',True),[.4,.54,.4]),
 ('decor',lambda:create_ceramic_pot(),[.22,.30,.22]),
 ('decor',lambda:create_lamp(),[.30,.81,.30]),
 ('decor',lambda:create_lamp('WC_CAFE_Lamp_Wall_A',True),[.30,.55,.38]),
 ('decor',lambda:create_sign(),[1.61,.58,.08]),
 ('decor',lambda:create_rest(),[.82,.31,.36]),
 ]
 for family,builder,dims in definitions:
  bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
  r=builder();export_asset(r,family,dims,{'semantic_origin':r['semantic_origin'],'world_unit':'.01 per logical unit','dimensions_status':'DEV art/template design; horizontal registration derives from frozen world footprints, heights from existing successful Hybrid/cat scale, not new gameplay geometry'})
 (OUT/'build_receipt.json').write_text(json.dumps({'blender_version':bpy.app.version_string,'build_hash':bpy.app.build_hash.decode(),'background':bpy.app.background,'bpy_execution':True,'assets':assets,'material_library':{name:{'material_name':m.name,'tint':list(m.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value),'roughness':float(m.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value),'source_texture':next((n.image.name for n in m.node_tree.nodes if n.type=='TEX_IMAGE'),None)} for name,m in M.items()},'source_textures':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in TEX.glob('*.png')}},indent=2)+'\n');print('WILLICAT FULL MODULAR KIT BUILD COMPLETE',len(assets))

if not args.calibration_only:
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 for m in M.values():m.use_fake_user=True
 bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'WC_CAFE_Shared_Materials.blend'),check_existing=False,compress=True)
