"""Render an actual Blender kit contact sheet; presentation transforms never alter asset sources."""
import bpy,math,json,sys,argparse
from pathlib import Path
from mathutils import Vector
p=argparse.ArgumentParser();p.add_argument('--source',required=True);p.add_argument('--out',required=True);a=p.parse_args(sys.argv[sys.argv.index('--')+1:]);B=Path(a.source);O=Path(a.out);O.mkdir(parents=True,exist_ok=True)
bpy.context.preferences.filepaths.save_version=0;bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
v=json.loads((B/'build_receipt.json').read_text());rows=[]
for i,row in enumerate(v['assets']):
 with bpy.data.libraries.load(str(B/row['source_blend']),link=False) as (available,data):data.objects=list(available.objects)
 objs=[o for o in data.objects if o is not None]
 for o in objs:bpy.context.scene.collection.objects.link(o)
 roots=[o for o in objs if o.parent is None];assert len(roots)==1
 r=roots[0];k=.20 if row['family']=='architecture' and 'Floor_' in row['asset_id'] else 1;r.scale=(k,k,k);r.location=((i%5)*3.6,-(i//5)*3.25,0)
 bpy.context.view_layer.update();dg=bpy.context.evaluated_depsgraph_get();low=min((o.matrix_world @ Vector(corner)).z for o in r.children_recursive if o.type=='MESH' for corner in o.evaluated_get(dg).bound_box);r.location.z-=low
 label=bpy.data.curves.new('Label','FONT');label.body=row['asset_id'].replace('WC_CAFE_','');label.size=.23;label.align_x='CENTER';obj=bpy.data.objects.new('CatalogLabel',label);bpy.context.scene.collection.objects.link(obj);obj.location=(r.location.x+.5,r.location.y-1.45,.025)
 # Blender text remains upright in the catalogue camera; it is not exported with any asset.
 rows.append({'asset_id':row['asset_id'],'catalog_scale':k,'source':row['source_blend']})
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=32;scene.cycles.use_denoising=True;scene.render.resolution_x=1600;scene.render.resolution_y=1600;scene.render.resolution_percentage=100
scene.world.color=(.55,.52,.46);scene.view_settings.view_transform='Standard';scene.view_settings.look='Medium High Contrast' if 'Medium High Contrast' in [x.name for x in []] else 'None';scene.view_settings.exposure=0;scene.view_settings.gamma=1
bpy.ops.mesh.primitive_plane_add(size=100,location=(7,-8,-.04));floor=bpy.context.object;mat=bpy.data.materials.new('CatalogNeutral');mat.diffuse_color=(.77,.71,.61,1);floor.data.materials.append(mat)
bpy.ops.object.light_add(type='AREA',location=(3,-5,18));bpy.context.object.data.energy=2400;bpy.context.object.data.shape='DISK';bpy.context.object.data.size=15
bpy.ops.object.camera_add(location=(12,-26,26));cam=bpy.context.object;target=Vector((7,-7.8,.5));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=24;scene.camera=cam
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(O/'01_BLENDER_ASSET_KIT.png');bpy.ops.wm.save_as_mainfile(filepath=str(B/'WC_CAFE_Kit_Catalog.blend'),check_existing=False,compress=True);bpy.ops.render.render(write_still=True)
(O/'diagnostics/blender_catalog_receipt.json').write_text(json.dumps({'blender_version':bpy.app.version_string,'engine':scene.render.engine,'samples':32,'scope':'Blender asset catalogue only, not Godot runtime or Hero composition','assets':rows},indent=2)+'\n')
