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
material('Cream_Stone',(.75,.64,.50));material('Roof_Slate',(.27,.32,.34));material('Jade',(.31,.44,.38));material('Aged_Brass',(.47,.34,.20))
old_finish=finish
def finish(o,name,mat,r,bevel=0,smooth=False):
    o=old_finish(o,name,mat,r,bevel,smooth)
    col=o.data.color_attributes.new(name='PigmentCavity',type='FLOAT_COLOR',domain='CORNER')
    o.data.color_attributes.active_color=col
    rng=random.Random(name+str(len(parts)))
    pigment=.3+rng.random()*.45
    for f in o.data.polygons:
        for j in f.loop_indices:col.data[j].color=(.95,pigment,.5,1)
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
asset('Ground_Stone_A','ground',ground,[2,.16,2])
asset('Bank_Straight_A','river',lambda r:course(r,0,0),[2,.9,.45],{'origin':'cap_line_center_at_walk_ground','connectors':[{'id':'left','profile':'river_bank_course_v1','position':[-1,0,0]},{'id':'right','profile':'river_bank_course_v1','position':[1,0,0]}]})
def corner(r,inside):
    course(r,-.5,0,1,'x');course(r,0,.5 if inside else -.5,1,'z')
    stone(r,(0,.005,0),(.45,.13,.45),70)
asset('Bank_Inner_A','river',lambda r:corner(r,True),[1.45,.9,1.45],{'corner_role':'inside','shared_profile':'river_bank_course_v1'})
asset('Bank_Outer_A','river',lambda r:corner(r,False),[1.45,.9,1.45],{'corner_role':'outside','shared_profile':'river_bank_course_v1'})
def transition(r):
    course(r,0,0)
    for row in range(2):
        for i in range(4):stone(r,(-.75+i*.5,-.04,-.47-row*.43),(.48,.08,.41),i+row*4)
asset('Bank_PathTransition_A','river',transition,[2,.9,1.3],{'shared_profile':'river_bank_course_v1','ground_contact_y':0})
def vegbank(r):
    course(r,0,0)
    for i in range(7):cloud(r,'LowerMoss_'+str(i),(-.8+i*.26,-.39,.205),(.13,.05,.05),'Foliage_Dark')
asset('Bank_Vegetation_A','river',vegbank,[2,.9,.50],{'shared_profile':'river_bank_course_v1','plant_zone':'below coping; route cap clear'})
def deck(r):
    for z in [-.72,.72]:box(r,'LongCedarBeam',(3.4,.22,.13),(0,-.14,z),'Cedar_Dark',.025)
    for i in range(17):box(r,'DeckPlank_'+str(i),(.193,.12,1.84),(-1.6+i*.2,-.06,0),'Cedar_Light' if i%4 else 'Cedar_Mid',.018)
    for x in [-1.65,1.65]:box(r,'EndCap',(.11,.17,1.91),(x,-.095,0),'Cedar_Mid',.020)
asset('Bridge_Deck_A','bridge',deck,[3.4,.25,1.91],{'walk_surface_y':0,'endpoints':[[-1.7,0,0],[1.7,0,0]]})
def rail(r):
    for x in [-1.65,-.55,.55,1.65]:
        box(r,'HandmadePost',(.105,.72,.13),(x,.36,0),'Cedar_Mid',.016)
        box(r,'CharcoalPostCap',(.14,.06,.16),(x,.73,0),'Charcoal_Trim',.015)
    for y in [.31,.66]:box(r,'RoundedRail',(3.5,.10,.085),(0,y,0),'Cedar_Light',.020)
asset('Bridge_Rail_A','bridge',rail,[3.5,.76,.16])
def abutment(r):
    for row in range(3):
        for i in range(4):stone(r,(-.15,-.68+row*.25,-.75+i*.5),(.5,.235,.485),i+row*4)
    box(r,'ApproachSlab',(.7,.14,1.86),(-.20,-.07,0),'Cream_Stone',.028)
asset('Bridge_Abutment_A','bridge',abutment,[.75,.88,1.86])
def window(r):
    box(r,'CreamWall',(2.7,2.3,.18),(0,1.15,0),'Plaster_Cream',.025)
    box(r,'WindowRecess',(2.20,1.37,.06),(0,1.30,.12),'Cedar_Dark',.016)
    box(r,'QuietWarmGlass',(2.08,1.25,.05),(0,1.30,.17),'Paper_Warm',.012)
    for x in [-1.26,1.26]:box(r,'TimberPost',(.13,2.38,.24),(x,1.19,.02),'Cedar_Dark',.020)
    for y in [.18,.61,1.95,2.20]:box(r,'WindowCedarRail',(2.70,.105,.24),(0,y,.10),'Cedar_Mid',.015)
    for x in [-1.02,-.51,0,.51,1.02]:box(r,'DeepWindowMullion',(.044,1.28,.11),(x,1.30,.21),'Cedar_Mid',.008)
    for y in [.87,1.30,1.73]:box(r,'WindowCrossbar',(2.13,.038,.11),(0,y,.21),'Cedar_Mid',.006)
    box(r,'AuthoredSill',(2.87,.12,.40),(0,.64,.22),'Cedar_Light',.025)
asset('Wall_Window_A','architecture',window,[2.87,2.38,.43])
def door(r):
    # Actual opening, no opaque picture posing as architecture.
    for x in [-.60,.60]:
        box(r,'PlasterSide',(.18,2.3,.18),(x,1.15,0),'Plaster_Cream',.015)
        box(r,'DeepCedarJamb',(.12,2.30,.29),(x,1.15,.04),'Cedar_Mid',.018)
    box(r,'Lintel',(1.4,.22,.26),(0,2.22,0),'Cedar_Dark',.020)
    box(r,'StoneThreshold',(1.3,.08,.65),(0,-.04,.15),'Cream_Stone',.022)
    box(r,'DoorLeaf',(.48,1.98,.06),(.56,1,-.35),'Cedar_Mid',.012).rotation_euler[2]=math.radians(-72)
asset('Entrance_Open_A','architecture',door,[1.4,2.33,.74],{'visual_aperture_local':[-.54,0,1.08,2.11],'dev_walkable_opening_width':1.08,'navigation_source':'DEV-only Vector2 polygon; never Home navigation'})
def plain(r):
    box(r,'CreamField',(3.4,2.30,.18),(0,1.15,0),'Plaster_Cream',.018)
    for x in [-1.62,0,1.62]:box(r,'CedarPost',(.12,2.36,.23),(x,1.18,.01),'Cedar_Dark',.020)
    for y in [.17,1.02,2.21]:box(r,'TimberRail',(3.4,.09,.23),(0,y,.035),'Cedar_Mid',.012)
asset('Wall_Plain_A','architecture',plain,[3.4,2.36,.23])
def roof(r):
    # Two authored sloping planes with rounded tile strips; roof local floor at zero.
    w=4.6;d=3.8;rise=.68
    verts=[(-w/2,0,-d/2),(w/2,0,-d/2),(-w/2,rise,0),(w/2,rise,0),(-w/2,0,d/2),(w/2,0,d/2)]
    meshpart(r,'RoofSolidPlanes',verts,[(0,1,3,2),(2,3,5,4)],'Roof_Slate',0)
    # Broad low relief tiles, enough profile for form, not detailed realistic shingles.
    for side in [-1,1]:
        for row in range(5):
            z=side*((row+.5)*d/10);y=rise*(1-abs(z)/(d/2))+.022
            for i in range(11):
                x=-w/2+(i+.5)*w/11
                o=box(r,'RoofTile',(.405,.048,.41),(x,y,z),'Roof_Slate',.018)
                o.rotation_euler[0]=side*math.atan(rise/(d/2))
        box(r,'CedarEave',(w+.10,.12,.17),(0,-.03,side*d/2),'Cedar_Dark',.022)
    rod(r,'SoftRoofRidge',(-w/2-.06,rise+.055,0),(w/2+.06,rise+.055,0),.075,'Roof_Slate')
    for x in [-w/2,w/2]:
        rod(r,'GableTrim',(x,.015,-d/2),(x,rise+.015,0),.055,'Cedar_Mid')
        rod(r,'GableTrim',(x,rise+.015,0),(x,.015,d/2),.055,'Cedar_Mid')
asset('Roof_CedarSlate_A','architecture',roof,[4.8,.82,3.95])
def awning(r):
    for i in range(7):
        x=-1.8+(i+.5)*3.6/7
        o=box(r,'CanvasPanel',(3.6/7-.008,.04,.70),(x,-.10,.34),'Jade',.012);o.rotation_euler[0]=math.radians(13)
        box(r,'CanvasValance',(3.6/7-.008,.16,.045),(x,-.245,.685),'Sage_Fabric',.022)
    for x in [-1.76,1.76]:rod(r,'AwningBracket',(x,0,0),(x,-.25,.66),.022,'Cedar_Dark')
asset('Awning_Jade_A','architecture',awning,[3.6,.34,.74])
def sign(r):
    box(r,'BlankRuntimeSign',(1.65,.36,.08),(0,0,0),'Plaster_Cream',.036)
    for x in [-.79,.79]:box(r,'CedarSignCap',(.105,.43,.11),(x,0,.01),'Cedar_Mid',.023)
asset('Sign_Blank_A','architecture',sign,[1.75,.43,.11],{'runtime_text':'separate optional layer, not baked'})
def tree(r,small=False):
    h=1.55 if small else 3.65;k=h/3.65
    rod(r,'LockedRootTrunk',(0,0,0),(.06*k,1.65*k,.03*k),.13*k,'Cedar_Dark')
    for i,(x,y,z) in enumerate([(-.82,2.53,-.10),(.78,2.73,.19),(-.10,3.12,-.24),(-.42,2.10,.38),(.36,2.05,.56)]):
        rod(r,'StableBranch',(.025*k,.95*k,0),(x*.62*k,y*.78*k,z*k),.045*k,'Cedar_Mid')
        cloud(r,'CanopyMass_'+str(i),(x*k,y*k,z*k),(.78*k,.57*k,.63*k),['Foliage','Foliage_Light','Foliage_Dark'][i%3])
        for j in range(5):
            a=j*2.399+i*.47
            cloud(r,'LeafLobe_%d_%d'%(i,j),((x+math.cos(a)*.52)*k,(y+.1*math.sin(j))*k,(z+math.sin(a)*.42)*k),(.27*k,.18*k,.28*k),['Foliage','Foliage_Light'][j%2])
    for i in range(4):
        a=i*math.tau/4;rod(r,'GroundRoot',(0,.10*k,0),(.28*k*math.cos(a),.014,.24*k*math.sin(a)),.045*k,'Cedar_Dark')
asset('Tree_Medium_A','vegetation',lambda r:tree(r),[3.2,3.8,2.4],{'root_lock':'wood surfaces fixed; only foliage shader sways','motion_status':'DEV art setting, no canonical motion calibration'})
asset('Tree_Small_A','vegetation',lambda r:tree(r,True),[1.45,1.62,1.15])
def grass(r):
    for i in range(15):
        a=i*2.399;x=math.cos(a)*(.12+.04*(i%3));z=math.sin(a)*(.12+.04*(i%3));h=.21+(i%5)*.035
        meshpart(r,'ReedLeaf',[(x-.018,0,z),(x+.018,0,z),(x+math.cos(a)*.085,h,z+math.sin(a)*.085)],[(0,1,2)],'Foliage',0,False)
asset('Grass_Bank_A','vegetation',grass,[.65,.36,.65])
def pot(r):
    lathe(r,'RoundedStonewarePot',[(0,0),(.15,0),(.21,.04),(.26,.42),(.28,.44),(.27,.48),(.23,.47),(.21,.08),(0,.08)],(0,0,0),'Ceramic_Offwhite',20)
    cylinder(r,'Soil',.225,.014,(0,.425,0),'Cedar_Dark',16,0)
    for i in range(9):
        a=i*2.399;cloud(r,'PotLeaf_'+str(i),(math.cos(a)*.18,.65+(i%3)*.06,math.sin(a)*.18),(.12,.20,.10),'Foliage' if i%2 else 'Foliage_Light')
asset('Potted_Plant_A','vegetation',pot,[.8,.94,.8])
def bench(r):
    for i in range(3):box(r,'SeatPlank',(1.4,.07,.12),(0,.43,-.14+i*.14),'Cedar_Light',.018)
    for x in [-.48,.48]:box(r,'BenchLeg',(.13,.40,.35),(x,.20,0),'Cedar_Dark',.020)
    box(r,'BenchApron',(1.25,.1,.30),(0,.34,0),'Cedar_Mid',.018)
asset('Bench_Cedar_A','props',bench,[1.4,.47,.4])
def lamp(r):
    box(r,'WallBracket',(.10,.24,.09),(0,0,0),'Charcoal_Trim',.015)
    rod(r,'AgedBrassArm',(0,.09,.05),(0,.03,.25),.025,'Aged_Brass')
    cylinder(r,'Shade',.13,.06,(0,.02,.25),'Aged_Brass',20,.015)
    cloud(r,'WarmBulb',(0,-.065,.25),(.068,.075,.068),'Lantern_Paper')
asset('Lamp_Practical_A','props',lamp,[.28,.25,.38])
def bg(r):
    box(r,'QuietHouse',(2,1.55,1.7),(0,.775,0),'Plaster_Cream',.04)
    meshpart(r,'QuietRoof',[(-1.15,1.52,-.98),(1.15,1.52,-.98),(-1.15,2.1,0),(1.15,2.1,0),(-1.15,1.52,.98),(1.15,1.52,.98)],[(0,1,3,2),(2,3,5,4)],'Roof_Slate')
    for x in [-.53,.53]:box(r,'QuietWindow',(.37,.50,.06),(x,.9,.88),'Cedar_Mid',.015)
asset('Background_House_A','background',bg,[2.3,2.1,1.96],{'role':'noninteractive backdrop, no navigation/collision'})
for a in assets:
    for key in ['source_blend','runtime_glb']:
        a[key+'_sha256']=hashlib.sha256((OUT/a[key]).read_bytes()).hexdigest()
receipt={'scope':'isolated experimental DEV translation','blender_version':bpy.app.version_string,'blender_build_hash':bpy.app.build_hash.decode(),'assets':assets,'authored_dimensions':'DEV prototype choices only; measured bounds exported; not production Home geometry','material_handoff':'semantic slots to existing painted-surface Godot library','source_art_generation_calls':0}
(OUT/'build_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print('RIVERSIDE MODULAR BUILD COMPLETE assets='+str(len(assets)))
