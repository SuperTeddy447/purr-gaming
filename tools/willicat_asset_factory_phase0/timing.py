"""Diagnostic wrapper over existing Forge writer; legacy Forge remains unchanged."""
from pathlib import Path
from .contracts import load_contract

def compile_timing(atlas_path,frame_map,durations_ms):
    from willicat_asset_forge.godot_export import generate_sprite_frames_tres
    if len(frame_map)!=len(durations_ms) or not frame_map:raise ValueError('timing parity')
    if any(type(d) is not int or not 1<=d<=16777216 for d in durations_ms):raise ValueError('outside exact binary32 ms domain')
    w,h=frame_map[0]['atlas_rect_px'][2:]
    if any(f['atlas_rect_px']!=[i*w,0,w,h] for i,f in enumerate(frame_map)):raise ValueError('Phase 0 wrapper supports explicit horizontal cells only')
    text=generate_sprite_frames_tres(atlas_path,len(frame_map),w,h,1000.0,True,'diagnostic_nonuniform')
    for d in durations_ms:text=text.replace('"duration": 1.0','"duration": '+str(d)+'.0',1)
    return text
