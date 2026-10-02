"""First-party bounded hero replacements. Values are DEV design dimensions fitted to V2, not new world authority or production tolerances."""
import bpy,math,json,sys,argparse,hashlib,bmesh
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
p=argparse.ArgumentParser();p.add_argument('--repo',required=True);p.add_argument('--out',required=True);args=p.parse_args(sys.argv[sys.argv.index('--')+1:]);R=Path(args.repo);O=Path(args.out);O.mkdir(parents=True,exist_ok=True)
# Reuse proven Blender axis, UV, lathe, rod and editable-bevel authoring helpers.
helper=(R/'tools/willicat_hybrid_cafe_kit/blender_build.py').read_text();helper=helper[helper.index('def xyz('):helper.index('if args.calibration_only:')]
scene=bpy.context.scene;TEX=R/'assets/dev_review/hybrid_cafe_kit_v1/textures';M={};parts=[];assets=[];OUT=O
exec(helper)
# Reuse exact existing first-party painted inputs, not photographic or generated new textures.
material('Cream_Stone',(.906,.839,.725),'plaster_painted.png',.91);material('Petal_Cream',(.96,.89,.74),'ceramic_painted.png');material('Foliage_Organic',(.38,.50,.28),'foliage_painted.png')
M['Cedar_Light'].node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=(.776,.561,.369,1)
receipts=[]
def clean():
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False);bpy.context.preferences.filepaths.save_version=0
 scene.unit_settings.system='METRIC';scene.unit_settings.scale_length=1

def meshpart(r,name,verts,faces,mat,bevel=0,smooth=False):
 me=bpy.data.meshes.new(name);me.from_pydata([xyz(v) for v in verts],[],faces);me.update();bm=bmesh.new();bm.from_mesh(me);bmesh.ops.remove_doubles(bm,verts=bm.verts,dist=0.0000001);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(me);bm.free();o=bpy.data.objects.new(name,me);scene.collection.objects.link(o);return finish(o,name,mat,r,bevel,smooth)

def curved_beam(r,name,points,width,depth,mat,bevel_ratio=.10):
 # Continuous quad strip; authored section offsets instead of stacked cubes.
 verts=[]
 for x,y,z in points:
  verts.extend([(x,y-width/2,z-depth/2),(x,y+width/2,z-depth/2),(x,y+width/2,z+depth/2),(x,y-width/2,z+depth/2)])
 faces=[(0,3,2,1)]
 for i in range(len(points)-1):
  for j in range(4):faces.append((i*4+j,i*4+(j+1)%4,(i+1)*4+(j+1)%4,(i+1)*4+j))
 faces.append(tuple(range(len(verts)-4,len(verts))));return meshpart(r,name,verts,faces,mat,min(width,depth)*bevel_ratio)

def tapered_member(r,name,a,b,width_a,width_b,mat='Cedar_Mid'):
 a=Vector(a);b=Vector(b);d=(b-a).normalized();s=d.cross(Vector((0,0,1))).normalized();q=d.cross(s).normalized();verts=[]
 for p,w in [(a,width_a),(b,width_b)]:
  for u,v in [(-1,-1),(-1,1),(1,1),(1,-1)]:verts.append(tuple(p+s*u*w/2+q*v*w/2))
 return meshpart(r,name,verts,[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)],mat,min(width_a,width_b)*.16)

def counter(name,w,d):
 r=root(name,'logical_floor_base_center');h=1.08
 # Stone top height exactly 1.08: all existing countertop props retain their authority.
 box(r,'RoundedCreamStoneSlab',(w+.09,.155,d+.10),(0,h-.0775,0),'Cream_Stone',min(d*.07,.042))
 box(r,'CedarUnderTopApron',(w+.025,.065,d+.036),(0,.897,0),'Cedar_Light',d*.018)
 box(r,'CarcassInsideRecess',(w-.07,.82,d-.07),(0,.51,0),'Cedar_Dark',d*.04)
 box(r,'RecessedPlinth',(w-.17,.12,d-.13),(0,.065,0),'Cedar_Dark',d*.018)
 box(r,'RoundedBaseRail',(w-.02,.092,d+.015),(0,.153,0),'Cedar_Mid',d*.026)
 count=max(1,round(w/.59));pw=(w-.15)/count
 for i in range(count):
  x=-w/2+.075+(i+.5)*pw
  # Two-depth broad raised cedar center within recessed panel, no cloth-box substitute.
  box(r,'InsetPanelShadow',(pw-.058,.66,.029),(x,.525,d/2-.012),'Cedar_Dark',.008)
  box(r,'HandmadeRaisedCedarPanel',(pw-.105,.558,.037),(x,.525,d/2+.010),'Cedar_Mid',min(pw*.025,.016))
  for y in [.232,.818]:box(r,'PanelSoftBead',(pw-.079,.030,.032),(x,y,d/2+.035),'Cedar_Light',.009)
  for dx in [-pw/2+.027,pw/2-.027]:box(r,'JoineryStile',(.054,.725,.065),(x+dx,.525,d/2+.025),'Cedar_Light',.012)
 for x in [-w/2+.028,w/2-.028]:
  box(r,'ChamferedEndPost',(.095,.792,d+.035),(x,.54,0),'Cedar_Mid',.025)
  # End panels define side depth; fitted inside the same counter envelope.
  box(r,'SideRecess',(.018,.58,d-.105),(x+(.05 if x>0 else -.05),.525,0),'Cedar_Dark',.009)
  box(r,'SideCedarField',(.025,.51,d-.17),(x+(.056 if x>0 else -.056),.525,0),'Cedar_Mid',.01)
 for y in [.30,.63]:box(r,'ServiceRearRail',(w-.16,.043,.07),(0,y,-d/2+.04),'Cedar_Mid',.006)
 return r

def chair():
 r=root('WC_CAFE_Chair_A')
 # Seat perimeter has broad corner softness; cushion deliberately domed, not a cube.
 box(r,'SoftSeatApron',(.515,.10,.425),(0,.454,0),'Cedar_Mid',.035)
 verts=[];faces=[];N=32
 for y,s in [(.502,.88),(.515,1),(.548,.97),(.564,.77),(.568,0)]:
  for i in range(N):
   a=i*math.tau/N;c=math.cos(a);t=math.sin(a);verts.append((.229*math.copysign(abs(c)**.55,c)*s,y,.184*math.copysign(abs(t)**.55,t)*s-.007))
 for j in range(4):
  for i in range(N):faces.append((j*N+i,j*N+(i+1)%N,(j+1)*N+(i+1)%N,(j+1)*N+i))
 faces.append(tuple(reversed(range(N))));meshpart(r,'UpholsteredDomedSeat',verts,faces,'Sage_Fabric',0,True)
 for x in [-.195,.195]:
  for z in [-.15,.15]:tapered_member(r,'SplayedTaperedLeg',(x*1.14,.018,z*1.14),(x,.445,z),.042,.062,'Cedar_Dark')
  tapered_member(r,'RakedBackPost',(x,.438,-.15),(x*1.12,1.07,-.235),.058,.053)
  rod(r,'SideStretcher',(x*1.08,.218,-.17),(x*1.08,.218,.17),.014,'Cedar_Mid')
 # Swept cedar crest and saddle lower rail: authored curved continuous topology.
 pts=[(-.277+i*.554/12,1.035+.043*math.cos((i/12-.5)*math.pi),-.228-.038*(1-((i/6)-1)**2)) for i in range(13)]
 curved_beam(r,'SweptBackCrest',pts,.086,.079,'Cedar_Light',.22)
 pts=[(-.208+i*.416/8,.710+.015*math.cos((i/8-.5)*math.pi),-.201-.025*math.sin(i/8*math.pi)) for i in range(9)]
 curved_beam(r,'CurvedLowerBackRail',pts,.038,.062,'Cedar_Mid',.20)
 # Narrow spindle silhouettes and cloth insert leave clear framed negative space.
 for x in [-.153,.153]:tapered_member(r,'InsetBackStile',(x,.72,-.213),(x*.96,1.012,-.255),.027,.023,'Cedar_Mid')
 box(r,'SageBackPad',(.285,.237,.064),(0,.875,-.239),'Sage_Fabric',.030)
 for x in [-.232,.232]:
  o=cylinder(r,'HandmadeJoineryPeg',.012,.012,(x,1.04,-.178),'Cedar_Dark',12,0);o.rotation_euler[0]=math.pi/2
 return r

def espresso():
 r=root('WC_CAFE_Espresso_A','countertop_contact_center')
 # Shaped, stepped casing uses extruded side profile, not rectangular shell.
 profile=[(-.218,.078),(-.218,.451),(-.197,.528),(-.145,.566),(.165,.566),(.224,.521),(.233,.344),(.155,.344),(.153,.124),(-.175,.124)]
 verts=[(x,y,z) for x in [-.424,.424] for z,y in profile];n=len(profile);faces=[tuple(reversed(range(n))),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
 meshpart(r,'SweptCreamEnamelHousing',verts,faces,'Cream_Stone',.025)
 box(r,'GroundedMachineBase',(.893,.059,.50),(0,.030,.010),'Charcoal_Trim',.019)
 box(r,'CupDeck',(.795,.030,.348),(0,.569,-.007),'Restrained_Metal',.014)
 box(r,'RaisedFrontControls',(.755,.138,.047),(0,.445,.243),'Charcoal_Trim',.018)
 box(r,'ExtractionCavity',(.704,.186,.016),(0,.239,.159),'Charcoal_Trim',.022)
 box(r,'DripPlatform',(.848,.046,.273),(0,.071,.251),'Restrained_Metal',.017)
 for i in range(7):box(r,'BroadDripGroove',(.011,.008,.202),(-.295+i*.098,.099,.260),'Charcoal_Trim',.003)
 for x in [-.204,.204]:
  rod(r,'GroupHeadNeck',(x,.355,.175),(x,.337,.264),.054,'Restrained_Metal')
  o=cylinder(r,'GroupExtractionRing',.060,.026,(x,.330,.270),'Restrained_Metal',20,.004)
  rod(r,'PortafilterHandle',(x,.324,.274),(x+.015,.311,.438),.020,'Cedar_Dark')
  cup(r,(x,.096,.263),.64)
  for dx in [-.045,.042]:box(r,'TactileCeramicButton',(.042,.041,.027),(x+dx,.451,.274),'Ceramic_Offwhite',.010)
 for x in [-.328,.328]:
  o=cylinder(r,'RoundSteamDial',.041,.023,(x,.445,.284),'Cedar_Dark',20,.005);o.rotation_euler[0]=math.pi/2
  box(r,'DialIndicator',(.007,.030,.007),(x,.447,.301),'Cream_Stone',.002)
 # Central analog gauge and shaped steam wand distinguish café equipment at portrait scale.
 for radius,z,mat in [(.046,.278,'Restrained_Metal'),(.036,.293,'Paper_Warm')]:
  o=cylinder(r,'AnalogGauge',radius,.014,(0,.456,z),mat,20,0);o.rotation_euler[0]=math.pi/2
 rod(r,'GaugeHand',(-.008,.447,.305),(.012,.471,.305),.0025,'Charcoal_Trim')
 for a,b in [((.361,.356,.269),(.417,.319,.312)),((.417,.319,.312),(.418,.170,.372)),((.418,.170,.372),(.389,.142,.380))]:rod(r,'BentSteamWand',a,b,.010,'Restrained_Metal')
 # Deck holds same two cups as V2, no added density.
 cup(r,(-.17,.592,-.025),.73);cup(r,(.17,.592,-.025),.73)
 for x in [-.417,.417]:box(r,'RoundedCedarSideBadge',(.016,.205,.232),(x,.294,-.045),'Cedar_Mid',.014)
 return r

def window():
 r=root('WC_CAFE_Wall_Window_A','structural_left_ground_corner');w=1.6;h=2.54
 for size,at in [((.165,h,.20),(.0825,h/2,0)),((.165,h,.20),(w-.0825,h/2,0)),((1.27,.52,.20),(.8,.26,0)),((1.27,.30,.20),(.8,h-.15,0))]:box(r,'WarmPlasterReturn',size,at,'Plaster_Cream',.015)
 for x in [.054,1.546]:box(r,'ContinuousCedarWallPost',(.108,h,.252),(x,h/2,.027),'Cedar_Dark',.022)
 for y in [.095,.875,2.405]:box(r,'WallCedarTie',(w,.088,.251),(.8,y,.052),'Cedar_Mid',.014)
 # Nested deep jamb and inset paper, bounded by the existing module, not an added façade.
 for x in [.180,1.420]:
  box(r,'DeepWindowJamb',(.114,1.76,.289),(x,1.37,.027),'Cedar_Mid',.022)
  box(r,'LightJambBead',(.026,1.66,.029),(x+(.060 if x<.8 else -.060),1.37,.184),'Cedar_Light',.008)
 for y in [.518,2.223]:box(r,'ThickWindowLintel',(1.354,.114,.292),(.8,y,.027),'Cedar_Light',.024)
 box(r,'InsetShojiPaper',(1.10,1.577,.014),(.8,1.37,-.118),'Paper_Warm',.004)
 # Fewer, thicker mullions give readable constructed rhythm instead of thin dense grid.
 for x in [.435,.8,1.165]:box(r,'DepthMullion',(.034,1.577,.057),(x,1.37,.083),'Cedar_Mid',.009)
 for y in [.93,1.45,1.97]:box(r,'ShojiCrossRail',(1.10,.030,.057),(.8,y,.086),'Cedar_Mid',.008)
 # Integrated inner ledge above unchanged separate Window_Sill_A support surface.
 box(r,'InteriorChamferedLedge',(1.30,.058,.19),(.8,.578,.140),'Cedar_Light',.016)
 for x in [.205,1.395]:box(r,'JoineryShoulder',(.16,.055,.057),(x,2.135,.188),'Cedar_Dark',.010)
 return r

def broad_leaf(r,a,b,width,pigment,index):
 # Five cross sections, five transverse samples: soft lobed mass and folded midrib.
 a=Vector(a);b=Vector(b);axis=b-a;side=axis.cross(Vector((0,1,0))).normalized();verts=[];faces=[];N=8;W=2
 for i in range(N+1):
  t=i/N;shape=math.sin(math.pi*t)**.60*(1+.055*math.sin(t*math.pi*4+index));center=a.lerp(b,t)+Vector((0,math.sin(math.pi*t)*axis.length*.16,0))
  for j in range(W+1):
   u=j/W*2-1;v=center+side*u*width*shape+Vector((0,(1-u*u)*width*.24*shape,0));verts.append(tuple(v))
 for i in range(N):
  for j in range(W):q=i*(W+1)+j;faces.append((q,q+1,q+W+2,q+W+1))
 o=meshpart(r,'SoftBroadLeaf',verts,faces,'Foliage_Organic',0,True);o['pigment']=pigment
 return o

def stem(r,name,a,b,rad):
 va=Vector(xyz(a));vb=Vector(xyz(b));d=vb-va;bpy.ops.mesh.primitive_cylinder_add(vertices=6,radius=rad,depth=d.length,location=(va+vb)/2);o=bpy.context.object;o.rotation_mode='QUATERNION';o.rotation_quaternion=d.to_track_quat('Z','Y');bpy.ops.object.transform_apply(location=False,rotation=True,scale=True);finish(o,name,'Foliage_Organic',r,0,True);o['pigment']=.22

def pot_ring(r,radius,y):
 bpy.ops.mesh.primitive_torus_add(major_segments=24,minor_segments=4,major_radius=radius,minor_radius=.005,location=xyz((0,y,0)));finish(bpy.context.object,'PaintedIndigoPotRim','Indigo',r,0,True)

def plant(role):
 name={'floor':'Planter_Floor_A','shelf':'Planter_Table_A','trailing':'Plant_Trailing_A','flowering':'Plant_Flowering_A'}[role];r=root('WC_CAFE_'+name);k=1 if role=='floor' else .43
 # Same nominal pot envelope .53x.425, shared origin/scale with V2.
 lathe(r,'HandThrownSoftPot',[(0,0),(.122,0),(.139,.034),(.243,.30),(.261,.386),(.258,.421),(.239,.437),(.221,.411),(.129,.066),(0,.066)],(0,0,0),'Ceramic_Offwhite',28)
 cylinder(r,'QuietPotSoil',.219,.012,(0,.383,0),'Coffee',24,0)
 for y,rad in [(.117,.163),(.363,.256)]:pot_ring(r,rad,y)
 if role=='floor':
  for i in range(15):
   a=i*2.399;level=i%5;start=(math.cos(a)*.045,.42+level*.078,math.sin(a)*.045);radius=.24+(i%3)*.073;tip=(math.cos(a)*radius,.82+level*.094-(.09 if i%4==0 else 0),math.sin(a)*radius)
   stem(r,'QuietPetiole',(0,.395,0),start,.007);broad_leaf(r,start,tip,.093+(i%3)*.018,.20+(i%4)*.20,i)
 elif role in ['shelf','flowering']:
  for i in range(12):
   a=i*2.399;start=(0,.406+(i%3)*.055,0);tip=(math.cos(a)*(.22+(i%3)*.024),.62+(i%4)*.064,math.sin(a)*(.22+(i%3)*.024));broad_leaf(r,start,tip,.092,.22+(i%4)*.19,i)
  if role=='flowering':
   for i in range(5):
    a=i*2.399;at=(math.cos(a)*.142,.78+(i%2)*.11,math.sin(a)*.142);stem(r,'FlowerStem',(0,.414,0),at,.006)
    for j in range(5):
     b=j*math.tau/5;pos=(at[0]+math.cos(b)*.052,at[1],at[2]+math.sin(b)*.052)
     bpy.ops.mesh.primitive_uv_sphere_add(segments=8,ring_count=4,radius=1,location=xyz(pos));o=bpy.context.object;o.scale=(.049,.040,.016);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);finish(o,'RoundedCreamPetal','Petal_Cream',r,0,True)
    cylinder(r,'MutedFlowerCenter',.020,.013,at,'Paper_Warm',12,0)
 else:
  for i in range(7):
   a=i*2.399;start=(0,.416,0);tip=(math.cos(a)*.23,.56+(i%3)*.047,math.sin(a)*.23);broad_leaf(r,start,tip,.099,.32+(i%3)*.22,i)
  for branch in range(3):
   x=-.16+branch*.155;prev=(x,.425,.13)
   for j in range(8):
    at=(x+math.sin(j*.8+branch)*.036,.41-j*.108,.17+math.sin(j*.5)*.045);stem(r,'TrailingStem',prev,at,.006);prev=at
    side=-1 if j%2 else 1;tip=(at[0]+side*.14,at[1]-.063,at[2]+.055);broad_leaf(r,at,tip,.066,.26+(j%4)*.18,j)
 for o in r.children:o.location*=k;o.scale*=k
 r['plant_role']=role;r['template_unit_scale']=k;return r

def paint_contact(r):
 dg=bpy.context.evaluated_depsgraph_get();verts=[];faces=[];meshes=[o for o in r.children_recursive if o.type=='MESH']
 for o in meshes:
  e=o.evaluated_get(dg);me=e.to_mesh();offset=len(verts);verts.extend(o.matrix_world@v.co for v in me.vertices);faces.extend(tuple(offset+i for i in f.vertices) for f in me.polygons);e.to_mesh_clear()
 bvh=BVHTree.FromPolygons(verts,faces);lo=1.;hi=0.;radius=.065 if 'Planter_Table' in r.name or 'Plant_' in r.name else .10
 for oi,o in enumerate(meshes):
  a=o.data.color_attributes.new(name='CavityPaint',type='FLOAT_COLOR',domain='POINT');o.data.color_attributes.active_color=a;normmat=o.matrix_world.to_3x3().inverted().transposed()
  for i,v in enumerate(o.data.vertices):
   normal=(normmat@v.normal).normalized();pos=o.matrix_world@v.co;side=normal.cross(Vector((0,0,1)))
   if side.length<.01:side=normal.cross(Vector((1,0,0)))
   side.normalize();other=normal.cross(side);hits=0
   for j in range(8):
    angle=j*math.tau/8;direction=(normal*.85+side*math.cos(angle)*.52+other*math.sin(angle)*.52).normalized();hits+=bvh.ray_cast(pos+normal*.001,direction,radius)[0] is not None
   value=1-.17*hits/8;green=float(o.get('pigment',.40+(oi%5)*.04));a.data[i].color=(value,green,.50,1);lo=min(lo,value);hi=max(hi,value)
 return {'method':'short-range deterministic geometric cavity in red; authored foliage pigment in green','measured_min':lo,'measured_max':hi,'dev_radius':radius,'not_a_calibration_threshold':True}

def save(r,family):
 bpy.context.view_layer.update();cavity=paint_contact(r);bpy.context.view_layer.update()
 dest=O/'source'/family/(r.name+'.blend');dest.parent.mkdir(parents=True,exist_ok=True);bpy.ops.wm.save_as_mainfile(filepath=str(dest),compress=True,check_existing=False)
 for o in list(r.children_recursive):
  if o.type=='MESH':
   bpy.context.view_layer.objects.active=o
   for m in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=m.name)
 meshes=[o for o in r.children_recursive if o.type=='MESH'];bpy.ops.object.select_all(action='DESELECT')
 for o in meshes:o.select_set(True)
 bpy.context.view_layer.objects.active=meshes[0];bpy.ops.object.join();me=meshes[0];me.name=r.name+'_DesignedMesh';me.data.calc_loop_triangles();tris=len(me.data.loop_triangles)
 bpy.ops.object.select_all(action='DESELECT');r.select_set(True);me.select_set(True);glb=O/'glb'/family/(r.name+'.glb');glb.parent.mkdir(parents=True,exist_ok=True)
 bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,export_normals=True,export_texcoords=True,export_extras=True,export_vertex_color='NAME',export_vertex_color_name='CavityPaint',export_all_vertex_colors=False)
 pts=[(v.x,v.z,-v.y) for v in [me.matrix_world@v.co for v in me.data.vertices]];lo=[min(v[i] for v in pts) for i in range(3)];hi=[max(v[i] for v in pts) for i in range(3)]
 receipts.append({'asset_id':r.name,'family':family,'source_blend':family+'/'+r.name+'.blend','runtime_glb':family+'/'+r.name+'.glb','origin':r['semantic_origin'],'root_transform_identity':True,'triangles_evaluated':tris,'measured_aabb_godot':{'position':lo,'size':[hi[i]-lo[i] for i in range(3)]},'source_blend_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'glb_sha256':hashlib.sha256(glb.read_bytes()).hexdigest(),'cavity':cavity,'template_version':'hero-replacement-v1.1','design_values_scope':'DEV fitted visual dimensions; gameplay positions and camera are V2 authority'})
for short,w,d in [('Straight',2.24,.55),('End',.73,.45),('Short',.48,.35)]:clean();save(counter('WC_CAFE_Counter_'+short+'_A',w,d),'furniture')
for fn,family in [(espresso,'equipment'),(chair,'furniture'),(window,'architecture')]:clean();save(fn(),family)
for role in ['floor','shelf','trailing','flowering']:clean();save(plant(role),'plants')
(O/'build_receipt.json').write_text(json.dumps({'blender_version':bpy.app.version_string,'build_hash':bpy.app.build_hash.decode(),'assets':receipts,'new_texture_pixels':False,'scope':'DEV hero assets; no gameplay authority changes'},indent=2)+'\n');print('HERO REPLACEMENTS BUILT',len(receipts))
