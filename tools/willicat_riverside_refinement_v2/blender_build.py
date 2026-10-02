"""First-party DEV Riverside geometry; original concept interpretation, no production authority."""
import bpy,math,json,sys,argparse,hashlib,random,bmesh
from pathlib import Path
from mathutils import Vector
p=argparse.ArgumentParser();p.add_argument('--repo',required=True);p.add_argument('--out',required=True);args=p.parse_args(sys.argv[sys.argv.index('--')+1:])
R=Path(args.repo);OUT=Path(args.out);OUT.mkdir(parents=True,exist_ok=True)
scene=bpy.context.scene;M={};parts=[];assets=[];TEX=R/'assets/dev_review/hybrid_cafe_kit_v1/textures'
helper=(R/'tools/willicat_hybrid_cafe_kit/blender_build.py').read_text();helper=helper[helper.index('def xyz('):helper.index('if args.calibration_only:')]
# Geometry exports carry semantic slots, not embedded duplicate textures. Runtime binds the current painted library.
exec(helper.replace('if texture:', 'if False and texture:').replace("export_extras=True", "export_extras=True,export_vertex_color='NAME',export_vertex_color_name='PigmentCavity',export_all_vertex_colors=False"))
material('QuietEarth',(.45,.50,.36));material('Cream_Stone',(.75,.64,.50));material('Roof_Slate',(.27,.32,.34));material('Jade',(.31,.44,.38));material('Aged_Brass',(.47,.34,.20))
old_finish=finish
def finish(o,name,mat,r,bevel=0,smooth=False):
    o=old_finish(o,name,mat,r,bevel,smooth)
    col=o.data.color_attributes.new(name='PigmentCavity',type='FLOAT_COLOR',domain='CORNER')
    o.data.color_attributes.active_color=col
    rng=random.Random(name+str(len(parts)))
    pigment=.3+rng.random()*.45
    shade=.36+rng.random()*.30
    for mod in o.modifiers:
        if mod.type=='BEVEL':mod.segments=1
    for f in o.data.polygons:
        for j in f.loop_indices:col.data[j].color=(.95,pigment,shade,1)
    return o
def clean():
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    bpy.context.preferences.filepaths.save_version=0
    scene.unit_settings.system='METRIC';scene.unit_settings.scale_length=1
def meshpart(r,name,verts,faces,mat,bevel=0,smooth=False):
    me=bpy.data.meshes.new(name);me.from_pydata([xyz(v) for v in verts],[],faces);me.update()
    bm=bmesh.new();bm.from_mesh(me);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(me);bm.free()
    o=bpy.data.objects.new(name,me);scene.collection.objects.link(o);return finish(o,name,mat,r,bevel,smooth)
def cloud(r,name,at,scale,mat='Foliage'):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=7,location=xyz(at));o=bpy.context.object
    rng=random.Random(name)
    for v in o.data.vertices:
        q=v.co.copy();q*=1+rng.uniform(-.065,.065);v.co=(q.x*scale[0],q.y*scale[2],q.z*scale[1])
    return finish(o,name,mat,r,0,True)
def stone(r,at,size,i=0):
    o=box(r,'RoundedStone_'+str(i),size,at,'Cream_Stone',.035)
    o.rotation_euler[2]=math.sin(i*2.3)*.009;return o
def course(r,x,z,length=2,along='x'):
    # Ground cap top at +.07, wall down to -.85; explicit profile shared by every river piece.
    for row in range(3):
        for i in range(4):
            u=-length/2+(i+.5)*length/4
            size=(length/4-.018,.235,.35)
            at=(x+u,-.68+row*.25,z)
            if along=='z':size=(.35,.235,length/4-.018);at=(x,-.68+row*.25,z+u)
            stone(r,at,size,i+row*4)
    for i in range(4):
        u=-length/2+(i+.5)*length/4
        size=(length/4-.010,.13,.45);at=(x+u,.005,z)
        if along=='z':size=(.45,.13,length/4-.010);at=(x,.005,z+u)
        stone(r,at,size,i+20)
def asset(name,family,build,dim,reg=None):
    clean();r=root('WC_RIVER_'+name);build(r)
    row=export_asset(r,family,dim,reg or {'origin':'local_ground_contact','scope':'DEV design dimensions only; not Home measurements'})
    row.update({'status':'experimental_DEV_only','construction_origin':'deterministic authored Blender geometry; agent scripted, no image-to-mesh generator','concept_authority':'artifacts/world_design/riverside_home_district_v1/WILLICAT_RIVERSIDE_HOME_DISTRICT_MASTER_CONCEPT_V1.png','asset_design_authority':'artifacts/world_design/riverside_home_district_v1/WILLICAT_RIVERSIDE_ASSET_FAMILY_BOARD_V1.png','derivative_helpers':'tools/willicat_hybrid_cafe_kit/blender_build.py','texture_embedding':'none; Godot maps material slots to reused painted-surface textures','reusable_family':family})
    return row
def ground(r):
    box(r,'StoneSubstrate',(2,.14,2),(0,-.1,0),'Cream_Stone',.015)
    rng=random.Random(777)
    grid={}
    for j in range(5):
        for i in range(4):
            grid[i,j]=(-1+i*2/3+(rng.uniform(-.09,.09) if 0<i<3 else 0),-1+j*.5+(rng.uniform(-.07,.07) if 0<j<4 else 0))
    for j in range(4):
        for i in range(3):
            q=[grid[i,j],grid[i+1,j],grid[i+1,j+1],grid[i,j+1]]
            cx=sum(t[0] for t in q)/4;cz=sum(t[1] for t in q)/4
            q=[(cx+(x-cx)*.96,cz+(z-cz)*.96) for x,z in q]
            perimeter=[]
            for k,(x,z) in enumerate(q):
                a=q[(k-1)%4];b=q[(k+1)%4]
                perimeter.extend([(x+(a[0]-x)*.12,z+(a[1]-z)*.12),(x+(b[0]-x)*.12,z+(b[1]-z)*.12)])
            verts=[(x,y,z) for y in [-.065,0] for x,z in perimeter]
            faces=[tuple(range(7,-1,-1)),tuple(range(8,16))]+[(k,(k+1)%8,(k+1)%8+8,k+8) for k in range(8)]
            meshpart(r,'HandcutPaving_'+str(i+j*3),verts,faces,'Cream_Stone',.014)

def corner(r,inside):
    course(r,-.5,0,1,'x');course(r,0,.5 if inside else -.5,1,'z')
    stone(r,(0,.005,0),(.45,.13,.45),70)
def bench(r):
    for i in range(3):box(r,'SeatPlank',(1.4,.07,.12),(0,.43,-.14+i*.14),'Cedar_Light',.018)
    for x in [-.48,.48]:box(r,'BenchLeg',(.13,.40,.35),(x,.20,0),'Cedar_Dark',.020)
    box(r,'BenchApron',(1.25,.1,.30),(0,.34,0),'Cedar_Mid',.018)
def lamp(r):
    box(r,'WallBracket',(.10,.24,.09),(0,0,0),'Charcoal_Trim',.015)
    rod(r,'AgedBrassArm',(0,.09,.05),(0,.03,.25),.025,'Aged_Brass')
    cylinder(r,'Shade',.13,.06,(0,.02,.25),'Aged_Brass',20,.015)
    cloud(r,'WarmBulb',(0,-.065,.25),(.068,.075,.068),'Lantern_Paper')

# V2: broad handcut stone grammar, unchanged 2m module pitch and walk surface.
def paving(r,variant=0):
    box(r,'QuietMortar',(2,.11,2),(0,-.085,0),'Cream_Stone',.01)
    rng=random.Random(1400+variant);rows=[-1,-.34,.29,1];cuts=[[[-1,-.45,.36,1],[-1,-.05,1],[-1,-.37,.43,1]],[[-1,.15,1],[-1,-.40,.40,1],[-1,-.16,1]],[[-1,-.25,.52,1],[-1,.25,1],[-1,-.52,.18,1]]][variant]
    for row in range(3):
        for i in range(len(cuts[row])-1):
            a,b=cuts[row][i:i+2];z0,z1=rows[row:row+2]
            q=[(a+.014,z0+.014),(b-.014,z0+.018),(b-.025,z1-.018),(a+.022,z1-.015)]
            # Broad chamfered corners are authored into the polygon, no tiny bevel subdivisions.
            per=[]
            for k,(x,z) in enumerate(q):
                prev,nxt=q[(k-1)%4],q[(k+1)%4];t=.065+rng.random()*.04
                per.extend([(x+(prev[0]-x)*t,z+(prev[1]-z)*t),(x+(nxt[0]-x)*t,z+(nxt[1]-z)*t)])
            verts=[(x,y,z) for y in [-.07,0] for x,z in per]
            faces=[tuple(range(7,-1,-1)),tuple(range(8,16))]+[(k,(k+1)%8,(k+1)%8+8,k+8) for k in range(8)]
            meshpart(r,'BroadHandcut_%d_%d'%(row,i),verts,faces,'Cream_Stone',.006)
for v in range(3):asset('Ground_Stone_'+chr(65+v),'ground',lambda r,v=v:paving(r,v),[2,.14,2],{'walk_surface_y':0,'module_pitch':[2,2],'variation':'authored broad stone layout; deterministic pigment per stone'})

def bank(r,variant=0,vegetated=False):
    rng=random.Random(77+variant)
    for row in range(3):
        widths=[.68,.49,.83] if row%2==0 else [.42,.86,.72]
        x=-1
        for i,w in enumerate(widths):
            # Walk-side rear plane never projects beyond the V1 rear plane (-.175).
            depth=.35+(.025+.075*rng.random())*(i%2)
            stone(r,(x+w/2,-.68+row*.25,(depth-.35)/2),(w-.02,.235,depth),row*3+i+variant*20);x+=w
    x=-1
    for i,w in enumerate([.56,.78,.66]):
        h=.13+(.012 if i==1 else -.006)*(-1 if variant%2 else 1)
        stone(r,(x+w/2,h/2-.06,.025*(i%2)),(w-.01,h,.45+.05*(i%2)),30+i+variant*20);x+=w
    if vegetated:
        for i in range(3):
            crown(r,'MossPocket_'+str(i),(-.58+i*.54,-.32,.24),(.21,.095,.105),'Foliage_Dark',100+i)
        stone(r,(.72,-.60,.23),(.52,.33,.33),50)
reg={'origin':'cap_line_center_at_walk_ground','connectors':[{'id':'left','profile':'river_bank_course_v1','position':[-1,0,0]},{'id':'right','profile':'river_bank_course_v1','position':[1,0,0]}],'route_side_limit_local_z':-.225,'variation':'river-side outsets only; connectors and walking route fixed'}
# Crown is a sculpted lobed lens with unequal shoulders, never a UV sphere.
def crown(r,name,at,scale,mat,seed):
    rng=random.Random(seed);n=12;verts=[(at[0]-.12*scale[0],at[1]-.52*scale[1],at[2])]
    radii=[1+rng.uniform(-.14,.13)+.14*math.sin(i*2.5+seed) for i in range(n)]
    for ring,(rad,y) in enumerate([(.70,-.22),(1,.04),(.72,.47)]):
        for i in range(n):
            a=i*math.tau/n;rr=rad*radii[i]
            verts.append((at[0]+math.cos(a)*scale[0]*rr,at[1]+scale[1]*(y+.085*math.sin(a*2+seed)),at[2]+math.sin(a)*scale[2]*rr))
    verts.append((at[0]+.13*scale[0],at[1]+.69*scale[1],at[2]-.13*scale[2]));top=len(verts)-1
    faces=[(0,1+(i+1)%n,1+i) for i in range(n)]
    for ring in range(2):
        for i in range(n):a=1+ring*n+i;b=1+ring*n+(i+1)%n;faces.append((a,b,b+n,a+n))
    faces.extend((top,1+2*n+i,1+2*n+(i+1)%n) for i in range(n))
    return meshpart(r,name,verts,faces,mat,0,True)
for v in range(2):asset('Bank_Straight_'+chr(65+v),'river',lambda r,v=v:bank(r,v),[2,.93,.56],reg)
asset('Bank_Vegetation_A','river',lambda r:bank(r,1,True),[2,.94,.66],reg)
def transition2(r):
    bank(r)
    for row in range(2):
        for i in range(3):stone(r,(-.66+i*.66,-.045,-.46-row*.43),(.64,.09,.41),i+row*3)
asset('Bank_PathTransition_A','river',transition2,[2,.93,1.3],reg)
asset('Bank_Inner_A','river',lambda r:corner(r,True),[1.45,.9,1.45],{'corner_role':'inside','shared_profile':'river_bank_course_v1'})
asset('Bank_Outer_A','river',lambda r:corner(r,False),[1.45,.9,1.45],{'corner_role':'outside','shared_profile':'river_bank_course_v1'})
def deck2(r):
    for z in [-.73,.73]:box(r,'SubstantialLongBeam',(3.4,.26,.18),(0,-.19,z),'Cedar_Dark',.04)
    for i in range(14):
        x=-1.7+(i+.5)*3.4/14;box(r,'BroadDeckPlank_'+str(i),(3.4/14-.009,.14,1.84),(x,-.07,0),'Cedar_Light' if i%3 else 'Cedar_Mid',.022)
    for x in [-1.65,1.65]:box(r,'ShapedEndCap',(.10,.23,1.90),(x,-.115,0),'Cedar_Mid',.028)
    for x in [-1.32,1.32]:box(r,'CrossSupport',(.17,.16,1.74),(x,-.34,0),'Cedar_Dark',.025)
asset('Bridge_Deck_A','bridge',deck2,[3.4,.44,1.9],{'walk_surface_y':0,'endpoints':[[-1.7,0,0],[1.7,0,0]],'clear_gameplay_route':'unchanged V1 bridge corridor'})
def rail2(r):
    for x in [-1.63,0,1.63]:
        box(r,'HandcraftedTimberPost',(.145,.73,.15),(x,.365,0),'Cedar_Mid',.024)
        box(r,'WarmPostCrown',(.17,.055,.18),(x,.75,0),'Cedar_Dark',.019)
        box(r,'IronFoot',(.165,.10,.17),(x,.05,0),'Charcoal_Trim',.014)
    for y in [.29,.66]:
        for i in range(4):
            x=-1.70+(i+.5)*.85;box(r,'SoftenedContinuousRail',(.86,.105,.115),(x,y+.012*math.sin(i*1.3),0),'Cedar_Light',.028)
    for x in [-1.6,1.6]:cylinder(r,'RestrainedJointPin',.025,.012,(x,.665,.064),'Aged_Brass',10,0).rotation_euler[0]=math.pi/2
asset('Bridge_Rail_A','bridge',rail2,[3.48,.78,.18],{'role':'visual rail outside unchanged walk corridor; no new navigation'})
def abutment2(r):
    for row in range(3):
        for i in range(3):stone(r,(-.15,-.68+row*.25,-.62+i*.62),(.54,.235,.60),i+row*3)
    box(r,'HeavyApproachSlab',(.70,.14,1.86),(-.20,-.07,0),'Cream_Stone',.025)
asset('Bridge_Abutment_A','bridge',abutment2,[.75,.88,1.86])

def window2(r):
    for size,at in [((2.7,.56,.21),(0,.28,0)),((2.7,.36,.21),(0,2.12,0)),((.19,1.38,.21),(-1.255,1.25,0)),((.19,1.38,.21),(1.255,1.25,0))]:box(r,'PlasterAroundRealOpening',size,at,'Plaster_Cream',.017)
    for x in [-1.26,1.26]:box(r,'DeepCedarPost',(.14,2.38,.28),(x,1.19,.035),'Cedar_Dark',.024)
    for y in [.13,.56,1.95,2.24]:box(r,'CedarStructuralRail',(2.73,.11,.30),(0,y,.06),'Cedar_Mid',.018)
    for x in [-1.09,1.09]:box(r,'RecessedWindowJamb',(.10,1.39,.35),(x,1.25,-.035),'Cedar_Mid',.015)
    for x in [-.72,0,.72]:box(r,'WindowMullion',(.042,1.31,.10),(x,1.255,.08),'Cedar_Mid',.008)
    for y in [.98,1.48]:box(r,'WindowCrossbar',(2.20,.033,.10),(0,y,.08),'Cedar_Mid',.005)
    box(r,'ThickSculptedSill',(2.90,.14,.47),(0,.56,.13),'Cedar_Light',.028)
    # Actual warm, low-detail interior depth behind the opening; no texture posing as glass.
    box(r,'WarmInteriorRear',(2.18,1.35,.06),(0,1.26,-.70),'Paper_Warm',.01)
    box(r,'InteriorShelf',(2.10,.085,.29),(0,1.03,-.45),'Cedar_Mid',.015)
    for x in [-.83,-.28,.45,.78]:
        lathe(r,'QuietCeramicJar',[(0,0),(.065,0),(.09,.06),(.08,.22),(.07,.24),(0,.24)],(x,1.07,-.42),'Ceramic_Offwhite',12)
    for i in range(6):box(r,'CedarLowerPanel',(.38,.37,.055),(-1.13+i*.45,.32,.15),'Cedar_Mid',.008)
    for i in range(4):stone(r,(-1.015+i*.677,-.015,.035),(.655,.11,.31),i)
asset('Wall_Window_A','architecture',window2,[2.9,2.38,.96],{'window':'real recessed volume with cedar mullions and warm shelf depth'})
def door2(r):
    for x in [-.60,.60]:
        box(r,'CreamDoorSide',(.18,2.3,.20),(x,1.15,0),'Plaster_Cream',.016)
        box(r,'DeepCedarJamb',(.12,2.30,.32),(x,1.15,.04),'Cedar_Mid',.023)
        box(r,'JambHighlight',(.045,2.14,.026),(x,1.14,.205),'Cedar_Light',.008)
    box(r,'ThickEntranceLintel',(1.43,.22,.34),(0,2.22,0),'Cedar_Dark',.027)
    box(r,'OpenThreshold',(1.3,.08,.68),(0,-.04,.15),'Cream_Stone',.021)
    box(r,'OpenDoorLeaf',(.48,1.98,.085),(.56,1,-.37),'Cedar_Mid',.022).rotation_euler[2]=math.radians(-72)
asset('Entrance_Open_A','architecture',door2,[1.43,2.33,.80],{'visual_aperture_local':[-.54,0,1.08,2.11],'dev_walkable_opening_width':1.08,'authority':'exact V1 opening preserved'})
def plain2(r):
    box(r,'CreamPlasterField',(3.4,2.30,.20),(0,1.15,0),'Plaster_Cream',.02)
    for x in [-1.62,0,1.62]:box(r,'CedarPost',(.13,2.36,.28),(x,1.18,.025),'Cedar_Dark',.022)
    for y in [.14,.93,2.21]:box(r,'TimberRail',(3.4,.105,.28),(0,y,.05),'Cedar_Mid',.018)
    for i in range(5):stone(r,(-1.35+i*.675,-.022,.02),(.65,.12,.27),i)
asset('Wall_Plain_A','architecture',plain2,[3.4,2.36,.28])
def roof2(r):
    w=4.6;d=3.8;rise=.74
    meshpart(r,'SlopedRoofPlanes',[(-w/2,0,-d/2),(w/2,0,-d/2),(-w/2,rise,0),(w/2,rise,0),(-w/2,0,d/2),(w/2,0,d/2)],[(0,1,3,2),(2,3,5,4)],'Roof_Slate')
    for side in [-1,1]:
        for row in range(5):
            z=side*((row+.5)*d/10);y=rise*(1-abs(z)/(d/2))+.022
            for i in range(10):
                x=-w/2+(i+.5)*w/10
                o=box(r,'BroadRoofTile',(.456,.052,.414),(x,y,z),'Roof_Slate',.014);o.rotation_euler[0]=side*math.atan(rise/(d/2))
        box(r,'LayeredCedarEave',(w+.16,.14,.20),(0,-.055,side*d/2),'Cedar_Dark',.028)
        box(r,'EaveLowerProfile',(w+.10,.055,.22),(0,-.145,side*d/2-.045*side),'Cedar_Mid',.016)
    rod(r,'RoundedSlateRidge',(-w/2-.09,rise+.055,0),(w/2+.09,rise+.055,0),.083,'Roof_Slate')
    for x in [-w/2,w/2]:
        meshpart(r,'CreamGable',[(x,0,-d/2),(x,rise,0),(x,0,d/2)],[(0,1,2)],'Plaster_Cream')
        for side in [-1,1]:rod(r,'CedarGableProfile',(x,.01,side*d/2),(x,rise+.02,0),.065,'Cedar_Mid')
        rod(r,'GableVertical',(x,.02,0),(x,rise-.04,0),.045,'Cedar_Dark')
asset('Roof_CedarSlate_A','architecture',roof2,[4.82,.94,4.04])
def awning2(r):
    for i in range(6):
        x=-1.8+(i+.5)*.6;o=box(r,'JadeCanvasPanel',(.598,.045,.75),(x,-.095,.34),'Jade',.013);o.rotation_euler[0]=math.radians(13)
        box(r,'SoftJadeValance',(.598,.14,.055),(x,-.255,.71),'Jade',.030)
    for x in [-1.76,1.76]:rod(r,'CedarBracket',(x,0,0),(x,-.255,.66),.027,'Cedar_Dark')
asset('Awning_Jade_A','architecture',awning2,[3.6,.36,.78])
def sign2(r):
    box(r,'BlankSignField',(1.66,.36,.10),(0,0,0),'Plaster_Cream',.026)
    for x in [-.84,.84]:box(r,'SignEndProfile',(.065,.44,.16),(x,0,0),'Cedar_Mid',.018)
    for y in [-.19,.19]:box(r,'SignFrame',(1.7,.045,.15),(0,y,0),'Cedar_Light',.01)
asset('Sign_Blank_A','architecture',sign2,[1.76,.44,.16],{'runtime_text':'blank; separate optional semantic text'})

def branch(r,name,points,radii,mat='Cedar_Dark'):
    verts=[];n=8
    for p,rad in zip(points,radii):
        for i in range(n):a=i*math.tau/n;verts.append((p[0]+rad*math.cos(a),p[1],p[2]+rad*math.sin(a)))
    faces=[tuple(range(n-1,-1,-1)),tuple(range((len(points)-1)*n,len(points)*n))]
    for j in range(len(points)-1):
        for i in range(n):a=j*n+i;b=j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
    meshpart(r,name,verts,faces,mat,0,True)
def tree2(r,small=False):
    k=.54 if small else 1
    branch(r,'LockedTaperedRoot',[(0,0,0),(-.045*k,.68*k,.01),(.14*k,1.40*k,-.05*k),(.06*k,2.2*k,.02*k)],[.14*k,.12*k,.10*k,.036*k])
    groups=[(-.72,2.22,-.15,.84,.48,.67),(.77,2.48,.12,.88,.47,.70),(-.12,2.94,-.18,.88,.54,.67),(-.78,1.84,.46,.62,.36,.53),(.32,1.97,.59,.80,.38,.60),(.27,2.64,-.63,.65,.38,.53)]
    for i,(x,y,z,sx,sy,sz) in enumerate(groups):
        branch(r,'ExposedFork_'+str(i),[(.12*k,1.1*k,0),(.34*x*k,(y-.63)*k,z*.4*k),(x*k,(y-.12)*k,z*k)],[.065*k,.043*k,.013*k],'Cedar_Mid')
        crown(r,'ShadowBough_'+str(i),(x*k,(y-.15)*k,z*k),(sx*k,sy*k,sz*k),'Foliage_Dark',20+i)
        for j in range(6):
            a=j*2.399+i*.4;pos=((x+math.cos(a)*sx*.50)*k,(y+.11+math.sin(a)*.11)*k,(z+math.sin(a)*sz*.52)*k)
            crown(r,'PaintedCrown_%d_%d'%(i,j),pos,(sx*(.40+.04*(j%3))*k,sy*.58*k,sz*.47*k),'Foliage_Light' if j in [1,3] else 'Foliage',i*39+j+80)
    for i in range(4):
        a=i*2.18;branch(r,'GroundRoot_'+str(i),[(0,.1*k,0),(.24*k*math.cos(a),.016,.24*k*math.sin(a))],[.042*k,.012*k])
asset('Tree_Medium_A','vegetation',lambda r:tree2(r),[3.7,3.5,2.5],{'root_lock':'wood fixed; representative instance foliage only DEV sway','motion_status':'DEV low-amplitude art choice; not canonical calibration'})
asset('Tree_Small_A','vegetation',lambda r:tree2(r,True),[2,1.9,1.4])
def shrub(r):
    for i,(x,y,z) in enumerate([(-.27,.27,.04),(.18,.38,-.04),(.40,.21,.14),(-.14,.42,-.18)]):
        crown(r,'ShrubShadow_'+str(i),(x,y-.07,z),(.35,.24,.30),'Foliage_Dark',500+i)
        for j in range(3):crown(r,'ShrubLeafGroup',(x+.17*math.cos(j*2.4),y+.05,z+.13*math.sin(j*2.4)),(.24,.16,.21),'Foliage_Light' if j==1 else 'Foliage',530+i*3+j)
asset('Shrub_Riverside_A','vegetation',shrub,[1.3,.68,.8])
def grass2(r):
    for i in range(11):
        a=i*2.399;x=math.cos(a)*.10;z=math.sin(a)*.10;h=.29+(i%4)*.04;tip=(x+math.cos(a)*.14,h,z+math.sin(a)*.14)
        meshpart(r,'BroadRiverBlade',[(x-.025,0,z),(x+.025,0,z),(tip[0]+.017,tip[1]*.66,tip[2]-.045),(tip[0],tip[1],tip[2]),(tip[0]-.017,tip[1]*.66,tip[2]-.045)],[(0,1,2,4),(4,2,3)],'Foliage' if i%3 else 'Foliage_Light',0,True)
asset('Grass_Bank_A','vegetation',grass2,[.64,.40,.64])
def pot2(r):
    lathe(r,'ThrownOffwhitePot',[(0,0),(.15,0),(.17,.03),(.25,.36),(.27,.41),(.255,.45),(.225,.43),(.17,.07),(0,.07)],(0,0,0),'Ceramic_Offwhite',16)
    cylinder(r,'Soil',.224,.015,(0,.403,0),'Cedar_Dark',12,0)
    branch(r,'PottedStem',[(0,.40,0),(.04,.75,0),(-.04,.9,0)],[.013,.01,.003])
    for i in range(8):
        a=i*2.4;y=.52+(i%3)*.14;crown(r,'BroadPottedLeaf',(math.cos(a)*.17,y,math.sin(a)*.17),(.19,.085,.12),'Foliage_Light' if i%3==0 else 'Foliage',700+i)
asset('Potted_Plant_A','vegetation',pot2,[.85,.96,.75])
# Retain the original bench; the refinement stays inside permitted geometry families.


def house2(r):
    box(r,'QuietCreamHouse',(2,1.55,1.7),(0,.775,0),'Plaster_Cream',.035)
    meshpart(r,'QuietSlateRoof',[(-1.15,1.52,-.98),(1.15,1.52,-.98),(-1.15,2.1,0),(1.15,2.1,0),(-1.15,1.52,.98),(1.15,1.52,.98)],[(0,1,3,2),(2,3,5,4)],'Roof_Slate')
    for x in [-.91,0,.91]:box(r,'QuietCedarFrame',(.065,1.55,.08),(x,.775,.87),'Cedar_Mid',.008)
    for x in [-.52,.52]:
        box(r,'QuietWindow',(.42,.54,.08),(x,.89,.90),'Cedar_Dark',.012)
        box(r,'QuietPaperPane',(.32,.42,.025),(x,.89,.95),'Paper_Warm',.009)
    box(r,'HouseSill',(2.1,.08,.12),(0,.10,.9),'Cedar_Mid',.01)
asset('Background_House_A','background',house2,[2.3,2.1,1.96],{'role':'same two distant noninteractive houses; no new neighborhood'})
def hill(r):
    # Low rolled continuation cue, tapered to the existing earth instead of a rectangular green backdrop.
    outline=[(-5,-1.8),(-3.5,-2.6),(-1.3,-2.8),(1.4,-2.4),(3.7,-2.2),(5,-1.2),(4.3,1.7),(2.7,1.4),(1.2,1.8),(-.7,1.35),(-2.5,1.4),(-4.3,1.8)]
    verts=[(x,-.11,z) for x,z in outline]+[(x*.66,.30+(.22 if i in [1,2,3] else .05),z*.6) for i,(x,z) in enumerate(outline)]+[(-.5,.64,-.65)]
    faces=[];n=len(outline)
    for i in range(n):faces.append((i,(i+1)%n,(i+1)%n+n,i+n));faces.append((i+n,(i+1)%n+n,n*2))
    meshpart(r,'SoftRolledGround',verts,faces,'QuietEarth',0,True)
asset('Background_Rise_A','background',hill,[8.6,1.43,2.7],{'role':'nonwalkable shallow backdrop cue; no route expansion'})
for a in assets:
    for key in ['source_blend','runtime_glb']:a[key+'_sha256']=hashlib.sha256((OUT/a[key]).read_bytes()).hexdigest()
receipt={'scope':'isolated V2 refinement, existing V1 route authority unchanged','blender_version':bpy.app.version_string,'blender_build_hash':bpy.app.build_hash.decode(),'assets':assets,'authored_dimensions':'DEV refinement choices; not invented production Home measurements','material_handoff':'same six painted textures, semantic slots, vertex pigment','source_art_generation_calls':0,'preserved_v1':'V1 files untouched; additive V2 sources'}
(OUT/'build_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print('RIVERSIDE V2 BUILD COMPLETE assets='+str(len(assets)))
