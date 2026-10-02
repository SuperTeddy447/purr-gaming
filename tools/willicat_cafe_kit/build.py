"""Small reproducible kit recipe composing existing Forge extraction/packaging.
No generation calls. Immutable family sources; explicit semantic role map.
"""
import json,sys,hashlib,shutil
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageEnhance,ImageFilter
sys.dont_write_bytecode=True

def build(repo,root,specs):
 repo=Path(repo);root=Path(root);sys.path.insert(0,str(repo/'tools'))
 from willicat_asset_forge.sprite_sheet import detect_content_strips,extract_content_strip_frames
 from willicat_asset_forge.static_prop import package_static_prop
 from willicat_asset_forge.image_processing import resize_frame,add_safe_padding
 asset=root/'assets/dev_review/cafe_interior_kit_v1';src=asset/'source';cuts=asset/'extracted';pack=asset/'packaged';runtime=asset/'runtime';qa=root/'artifacts/prototype_review/cafe_interior_kit_v1'
 for p in [src,cuts,pack,runtime,qa]:p.mkdir(parents=True,exist_ok=True)
 for p in [src,cuts,pack]:(p/'.gdignore').write_text('')
 reports=[];cellmap={}
 for spec in specs:
  raw=src/(spec['id']+'.png')
  if not raw.exists():shutil.copy2(spec['generated_path'],raw)
  im=Image.open(raw).convert('RGBA')
  cells=[]
  if spec['id']=='decor_family_v1':
   columns=detect_content_strips(im,3,alpha_threshold=16,min_gap_width=8)
   for x0,x1 in columns:
    column=im.crop((x0,0,x1,im.height))
    bands=detect_content_strips(column.transpose(Image.Transpose.TRANSPOSE),2,alpha_threshold=16,min_gap_width=1)
    for y0,y1 in bands:cells.append([x0,y0,x1,y1])
   cells.sort(key=lambda c:(0 if c[1]<400 else 1,c[0]))
  else:
   rowbounds=detect_content_strips(im.transpose(Image.Transpose.TRANSPOSE),spec['rows'],alpha_threshold=16,min_gap_width=8)
   for y0,y1 in rowbounds:
    row=im.crop((0,y0,im.width,y1))
    bands=detect_content_strips(row,spec['cols'],alpha_threshold=16,min_gap_width=8)
    for x0,x1 in bands:cells.append([x0,y0,x1,y1])
  if len(cells)!=len(spec['names']):raise ValueError('semantic cell-count mismatch')
  cellmap[spec['id']]=cells
  for name,cell in zip(spec['names'],cells):
   x0,y0,x1,y1=cell
   # Take safe margins from verified full transparent gutters; no neighboring art may enter.
   crop=add_safe_padding(im.crop((x0,y0,x1,y1)),6)
   cp=cuts/(name+'.png');crop.save(cp)
   pivot='WALL_MOUNT_CENTER' if name.startswith(('wall_','window_','beam_','menu_','art_','shelf_')) else 'FLOOR_CONTACT_BOTTOM_CENTER'
   r=package_static_prop(cp,name,pack,pivot,status='CANDIDATE',padding=16,alpha_threshold=16)
   pi=Image.open(pack/(name+'.png'));targetw=512 if name in ['wall_plain','wall_framed','counter_main','beam_cedar'] else 256
   out=resize_frame(pi,(targetw,round(pi.height*targetw/pi.width)));out.save(runtime/(name+'.png'))
   r.update(family_id=spec['id'],source_sheet_rect_px=cell,runtime_repo_path='assets/dev_review/cafe_interior_kit_v1/runtime/'+name+'.png',final_dimensions=list(out.size),final_pivot_px=[out.width/2,out.height/2 if pivot=='WALL_MOUNT_CENTER' else out.height],final_hash=hashlib.sha256((runtime/(name+'.png')).read_bytes()).hexdigest());reports.append(r)
 # Artist-inspected wall face endpoints define a documented deshear, preserving canvas content.
 # This straightens the wall mounting plane; world geometry remains untouched.
 for name,slope in [('wall_plain',63/476),('wall_framed',69/477)]:
  wi=Image.open(runtime/(name+'.png')).convert('RGBA').convert('RGBa')
  wi=wi.transform(wi.size,Image.Transform.AFFINE,(1,0,0,slope,1,-slope*18),Image.Resampling.BICUBIC).convert('RGBA')
  bb=wi.getchannel('A').point(lambda a:255 if a>16 else 0).getbbox()
  wi=add_safe_padding(wi.crop(bb),16);wi=resize_frame(wi,(512,round(wi.height*512/wi.width)));wi.save(runtime/(name+'.png'))
  r=next(r for r in reports if r['asset_id']==name);r.update(final_dimensions=list(wi.size),final_pivot_px=[wi.width/2,wi.height/2],wall_mount_deshear={'source_y_per_x':slope,'basis':'artist-inspected painted wall-frame endpoints; DEV registration authoring, not a Home measurement'},final_hash=hashlib.sha256((runtime/(name+'.png')).read_bytes()).hexdigest())
 # Registered front/top split is defined after inspected source contours; do not infer from sheet shape.
 p=Image.open(runtime/'counter_main.png').convert('RGBA');frontpoly=[[0,70],[512,116],[512,p.height],[0,p.height]]
 mask=Image.new('L',p.size,0);ImageDraw.Draw(mask).polygon([tuple(x) for x in frontpoly],fill=255)
 alpha=np.array(p.getchannel('A'));fm=np.array(mask)>0
 for name,m in [('counter_front',fm),('counter_top',~fm)]:
  out=p.copy();out.putalpha(Image.fromarray(np.where(m,alpha,0).astype('uint8')));out.save(runtime/(name+'.png'))
 # Quiet flooring is a permitted deterministic derivative of the existing immutable generated floor.
 floor=Image.open(repo/'assets/dev_review/cafe_interior_slice_v1/source/floor_cedar.png').convert('RGB');floor=ImageEnhance.Contrast(floor).enhance(.72);floor=ImageEnhance.Color(floor).enhance(.82);floor=floor.resize((64,64),Image.Resampling.LANCZOS).filter(ImageFilter.GaussianBlur(.35))
 atlas=Image.new('RGB',(128,128));atlas.paste(floor,(0,0));atlas.paste(floor.transpose(Image.Transpose.FLIP_LEFT_RIGHT),(64,0));atlas.paste(floor.transpose(Image.Transpose.FLIP_TOP_BOTTOM),(0,64));atlas.paste(floor.transpose(Image.Transpose.ROTATE_180),(64,64));atlas.save(runtime/'floor_quiet.png')
 seam=np.array(atlas);assert np.array_equal(seam[:,0],seam[:,-1]) and np.array_equal(seam[0],seam[-1])
 sheet=Image.new('RGB',(900,((len(reports)+3)//4)*205),(238,232,218));d=ImageDraw.Draw(sheet)
 for i,r in enumerate(reports):
  im=Image.open(runtime/(r['asset_id']+'.png'));im.thumbnail((210,165));x=(i%4)*225;y=(i//4)*205;sheet.paste(im,(x+(225-im.width)//2,y),im);d.text((x+8,y+174),r['asset_id'],fill=(52,44,40))
 sheet.save(qa/'kit_contact_sheet.png')
 data={'scope':'DEV_REVIEW_CANDIDATE','family_cell_rects_px':cellmap,'sheet_semantics':'explicit ordered asset names; rows/columns are packaging, NOT timeline/direction inference','reports':reports,'counter_front_polygon_px':frontpoly,'floor_processing':{'reused_source':'assets/dev_review/cafe_interior_slice_v1/source/floor_cedar.png','contrast':.72,'saturation':.82,'base_px':64,'mirror_atlas_px':128,'opposite_edges_exactly_equal':True,'all_pixels_are_processed_source_not_target_board_crops':True}}
 (asset/'processing_report.json').write_text(json.dumps(data,indent=2)+'\n');return data
if __name__=='__main__':build(sys.argv[1],sys.argv[2],json.loads(Path(sys.argv[3]).read_text()))
