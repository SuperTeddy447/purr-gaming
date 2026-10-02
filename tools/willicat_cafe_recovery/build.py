"""Reproduce DEV recovery exports from immutable sources; never generate art."""
import sys,json,hashlib
from pathlib import Path
from PIL import Image,ImageOps
import numpy as np
sys.dont_write_bytecode=True

def build_textiles(repo, out):
 from willicat_asset_forge.sprite_sheet import detect_content_strips
 from willicat_asset_forge.static_prop import package_static_prop
 from willicat_asset_forge.image_processing import resize_frame, add_safe_padding
 a=Path(out)/'assets/dev_review/cafe_visual_recovery_v1'
 src=a/'source/textile_catlife_family_v1.png'
 if not src.exists():
  import shutil
  original=Path(repo)/'assets/dev_review/cafe_visual_recovery_v1/source/textile_catlife_family_v1.png'
  src.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(original,src)
 (src.parent/'.gdignore').write_text('')
 packaged=a/'packaged';packaged.mkdir(parents=True,exist_ok=True);(packaged/'.gdignore').write_text('')
 runtime=a/'runtime';runtime.mkdir(parents=True,exist_ok=True)
 im=Image.open(src).convert('RGBA')
 bands=detect_content_strips(im,3,alpha_threshold=16,min_gap_width=8)
 records=[]
 for name,(x0,x1) in zip(['seating_rug','entry_mat','sisal_post'],bands):
  cut=add_safe_padding(im.crop((x0,0,x1,im.height)),6)
  extracted=packaged/(name+'_extracted.png');cut.save(extracted)
  report=package_static_prop(extracted,name,packaged,'FLOOR_CONTACT_BOTTOM_CENTER',status='CANDIDATE',padding=16,alpha_threshold=16)
  records.append(report)
  full=Image.open(packaged/(name+'.png')).convert('RGBA')
  full=resize_frame(full,(512,round(full.height*512/full.width)));full.save(runtime/(name+'.png'))
 data={'scope':'DEV_REVIEW_CANDIDATE','generation_calls_for_source':1,'regenerations':0,'source_path':'assets/dev_review/cafe_visual_recovery_v1/source/textile_catlife_family_v1.png','source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'alpha_source_edges':'all four outer edges alpha0; no source-edge clipping','semantic_cell_roles':['seating_rug','entry_mat','sisal_post'],'cell_rects_x_px':bands,'forge_reports':records,'recipe_code_hash':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
 (a/'textile_processing.json').write_text(json.dumps(data,indent=2)+'\n')
 return data

def build(repo,out):
 repo=Path(repo);out=Path(out);sys.path.insert(0,str(repo/'tools'))
 from willicat_asset_forge.image_processing import resize_frame
 build_textiles(repo,out)
 a=out/'assets/dev_review/cafe_visual_recovery_v1';p=a/'runtime';p.mkdir(parents=True,exist_ok=True)
 source=repo/'assets/dev_review/cafe_interior_kit_v1/runtime/counter_main.png'
 im=Image.open(source).convert('RGBA');canvas=Image.new('RGBA',(512,290));canvas.paste(im,(0,60))
 # Artist-inspected front frame rises50px across450px in the approved reuse candidate.
 # Keep a large temporary canvas before flattening the mounting plane; no source pixel edits.
 slope=50/450
 canvas=canvas.convert('RGBa').transform(canvas.size,Image.Transform.AFFINE,(1,0,0,slope,1,0),Image.Resampling.BICUBIC).convert('RGBA')
 alpha=np.array(canvas.getchannel('A'));contact=int(np.where(alpha[:,100:380]>16)[0].max())
 split_y=122 # Artist-authored front/top contour after source-plane correction; not a world measurement.
 pieces=[]
 for name,x0,x1 in [('left',0,128),('middle',128,384),('right',384,512)]:
  clip=canvas.crop((x0,0,x1,290));al=np.array(clip.getchannel('A'))
  for layer in ['top','front']:
   m=np.indices(al.shape)[0]>=split_y if layer=='front' else np.indices(al.shape)[0]<split_y
   frame=clip.copy();frame.putalpha(Image.fromarray(np.where(m,al,0).astype('uint8')));frame.save(p/('counter_'+name+'_'+layer+'.png'))
  pieces.append({'piece_id':name,'source_rect_after_deshear_px':[x0,0,x1,290],'canvas_px':[x1-x0,290],'pivot_px':[0,contact],'registration':'left-edge, common authored ground contact','mirror_policy':'middle material segment may be mirrored horizontally; this is not a furniture directional view'})
 canvas.save(p/'counter_aligned.png')
 # Deskew the blank wall sign into a reusable mounting plane before nine-slice layout.
 board=Image.open(repo/'assets/dev_review/cafe_interior_kit_v1/runtime/menu_blank.png').convert('RGBA')
 bc=Image.new('RGBA',(256,270));bc.paste(board,(0,60));bc=bc.convert('RGBa').transform(bc.size,Image.Transform.AFFINE,(1,0,0,37/194,1,0),Image.Resampling.BICUBIC).convert('RGBA')
 bb=bc.getchannel('A').point(lambda a:255 if a>16 else 0).getbbox();bc=ImageOps.expand(bc.crop(bb),16);bc.save(p/'menu_flat.png')
 # Reuse the pale tabletop as an independent rectangular material patch on long wall shelves.
 surface=canvas.crop((135,83,375,112));surface=resize_frame(surface,(512,64));surface.save(p/'counter_surface_material.png')
 # Cedar front face, excluding painted perspective side and exterior margins, for structural plane mapping.
 post=Image.open(repo/'assets/dev_review/cafe_interior_kit_v1/runtime/post_cedar.png').convert('RGBA')
 face=post.crop((91,116,173,692));face.save(p/'cedar_post_face.png')
 data={'scope':'DEV_VISUAL_FRAMING_PROOF','generation_calls':0,'source_path':str(source.relative_to(repo)),'source_hash':hashlib.sha256(source.read_bytes()).hexdigest(),'counter_plane_slope':slope,'slope_basis':'artist-inspected existing painted front-frame endpoints','front_top_partition_y_px':split_y,'pieces':pieces,'material_crops':{'counter_surface_material':[135,83,375,112],'cedar_post_face':[91,116,173,692]},'recipe_code_hash':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'output_hashes':{x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in p.glob('*.png')},'geometry_and_calibration_thresholds':'no new canonical values; visual recipe choices only'}
 (a/'processing_recipe.json').write_text(json.dumps(data,indent=2)+'\n');return data
if __name__=='__main__':print(json.dumps(build(sys.argv[1],sys.argv[2])))
