#!/usr/bin/env python3
"""Small deterministic normalizer and QA gate for Storybook Mini Pack 001."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/source_assets/first_party_storybook_mini_pack_001/source"
OUT = ROOT / "assets/first_party/storybook_mini_pack_001/normalized"
QA = ROOT / "docs/source_assets/first_party_storybook_mini_pack_001/qa"
SPEC = ROOT / "docs/source_assets/first_party_storybook_mini_pack_001/specs/pack_manifest.json"
THRESHOLD = 12
records = {}
failures = []


def image(name):
    return Image.open(SOURCE / name).convert("RGBA")


def clean(im, threshold=THRESHOLD):
    im = im.copy()
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            if px[x, y][3] < threshold:
                px[x, y] = (0, 0, 0, 0)
    return im


def bounds(im):
    return im.getchannel("A").getbbox()


def extract(im, region, label, guard=0, threshold=THRESHOLD):
    cell = clean(im.crop(region), threshold)
    box = bounds(cell)
    if box is None:
        failures.append(f"{label}: missing artwork")
        return cell
    if box[0] <= guard or box[1] <= guard or box[2] >= cell.width - guard or box[3] >= cell.height - guard:
        failures.append(f"{label}: source touches extraction cell edge {box}/{cell.size}")
    records[label] = {"source_region": region, "alpha_bounds": box, "cell_size": cell.size}
    return cell.crop(box)


def normalize(crop, canvas, target, baseline):
    # Preserve aspect and register at the semantic floor baseline.
    scale = min(target[0] / crop.width, target[1] / crop.height)
    size = (round(crop.width * scale), round(crop.height * scale))
    resized = crop.resize(size, Image.Resampling.LANCZOS)
    result = Image.new("RGBA", canvas)
    result.alpha_composite(resized, ((canvas[0] - size[0]) // 2, baseline - size[1]))
    return result


def write_strip(name, frames):
    w, h = frames[0].size
    sheet = Image.new("RGBA", (w * len(frames), h))
    for i, frame in enumerate(frames):
        sheet.alpha_composite(frame, (w * i, 0))
    sheet.save(OUT / name)
    return sheet


def qa_strip(name, frames, labels):
    w, h = frames[0].size
    sample = min(280 / w, 280 / h, 1)
    cw, ch = round(w * sample), round(h * sample)
    contact = Image.new("RGB", (cw * len(frames), ch + 32), "#eee7d7")
    d = ImageDraw.Draw(contact)
    for i, frame in enumerate(frames):
        checker = Image.new("RGBA", frame.size, "#eee7d7")
        checker.alpha_composite(frame)
        contact.paste(checker.convert("RGB").resize((cw, ch)), (i*cw, 0))
        d.text((i*cw+8, ch+7), labels[i], fill="#233c37")
    contact.save(QA / name)


def audit_frames(label, frames, canvas, baseline=None, height_drift=0.25):
    boxes = [bounds(frame) for frame in frames]
    records[label + "_normalized"] = {"canvas": canvas, "frame_count": len(frames), "alpha_bounds": boxes,
                                       "sha256": [hashlib.sha256(frame.tobytes()).hexdigest() for frame in frames]}
    if any(frame.size != canvas for frame in frames) or any(box is None for box in boxes):
        failures.append(label + ": missing frame or canvas mismatch")
        return
    if len(set(records[label + "_normalized"]["sha256"])) != len(frames):
        failures.append(label + ": duplicate normalized frames")
    if baseline is not None and any(abs(box[3] - baseline) > 2 for box in boxes):
        failures.append(label + ": floor baseline registration drift")
    heights = [box[3] - box[1] for box in boxes]
    if (max(heights) - min(heights)) / max(heights) > height_drift:
        failures.append(label + ": perceived height drift")


def grid4(im, label, splits=None, guard=0, threshold=THRESHOLD):
    if splits is None:
        splits = (im.width // 2, im.height // 2)
    sx, sy = splits
    regions = [(0,0,sx,sy),(sx,0,im.width,sy),(0,sy,sx,im.height),(sx,sy,im.width,im.height)]
    return [extract(im, r, f"{label}_{i}", guard, threshold) for i,r in enumerate(regions)]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    QA.mkdir(parents=True, exist_ok=True)
    spec = json.loads(SPEC.read_text())
    assert len(spec["assets"]) == 10

    tree = grid4(image("tree_sheet_v3.png"), "tree", guard=8)
    tree_frames = [normalize(c,(512,640),(460,550),600) for c in tree]
    audit_frames("tree",tree_frames,(512,640),600,0.12)
    write_strip("tree_gentle_breeze.png",tree_frames)
    qa_strip("tree_contact.png",tree_frames,["frame 0","frame 1","frame 2","frame 3"])

    # Source row gaps vary, so split each authored sheet at its measured empty gutter.
    # The four source poses per sheet are not raster rotations.
    chair_back=grid4(image("chair_back_sheet_v3.png"),"chair_back",(768,490))
    chair_front=grid4(image("chair_front_sheet_v3.png"),"chair_front",(768,525))
    chair_crops={"n":chair_back[0],"ne":chair_back[1],"e":chair_back[2],"se":chair_back[3],
                 "s":chair_front[0],"sw":chair_front[1],"w":chair_front[2],"nw":chair_front[3]}
    chair_frames=[normalize(chair_crops[k],(384,384),(334,326),364) for k in ["n","ne","e","se","s","sw","w","nw"]]
    audit_frames("chair",chair_frames,(384,384),364,0.20)
    write_strip("chair_directions.png",chair_frames)
    qa_strip("chair_directions.png",chair_frames,["N","NE","E","SE","S","SW","W","NW"])

    table_src=Image.open(ROOT/"assets/environment/home_v3/production_batch_a_v1/WILLICAT_ASSET_A06_ROUND_CAFE_TABLE_V1.png").convert("RGBA")
    table=clean(table_src)
    table=table.crop(bounds(table))
    table=normalize(table,(512,512),(460,450),480)
    table.save(OUT/"table_round.png")

    shadow=clean(image("contact_shadow_source_v1.png"))
    shadow_box=bounds(shadow)
    if shadow_box is None:
        failures.append("contact_shadow: empty source")
    else:
        shadow=normalize(shadow.crop(shadow_box),(256,128),(230,90),104)
        shadow.save(OUT/"contact_shadow.png")
        qa_strip("contact_shadow.png",[shadow],["neutral shadow"])

    for name,source_name in [("water_ripple","water_ripple_source_v1.png"),("coffee_fx","coffee_fx_source_v1.png")]:
        crops=grid4(image(source_name),name,threshold=32 if name=="water_ripple" else THRESHOLD)
        frames=[normalize(c,(256,256),(220,205),224) for c in crops]
        audit_frames(name,frames,(256,256),224,0.28)
        write_strip(name+".png",frames)
        qa_strip(name+"_contact.png",frames,[str(i) for i in range(4)])

    # Image generation labelled the profiles opposite to their visible facing.
    # Correct mapping is verified on the QA strips rather than inferred from prompts.
    row_split={"down":587,"up":543,"left":550,"right":520}
    source_direction={"down":"down","up":"up","left":"right","right":"left"}
    for direction in ["down","up","left","right"]:
        im=image(f"orange_{source_direction[direction]}_source_v1.png")
        if direction == "down":
            sx,sy=im.width//2,row_split[direction]
            regions=[(0,0,sx,sy),(sx,0,im.width,sy),(0,sy,sx,im.height)]
            crops=[extract(im,r,f"orange_down_{i}") for i,r in enumerate(regions)]
            records["orange_down_rejected_pose"]="bottom-right frame overlaps the row boundary; two authored walk poses retained"
        else:
            crops=grid4(im,"orange_"+direction,(im.width//2,row_split[direction]))
        frames=[normalize(c,(256,256),(232,210),232) for c in crops]
        audit_frames("orange_"+direction,frames,(256,256),232,0.25)
        write_strip(f"orange_{direction}.png",frames)
        qa_strip(f"orange_{direction}_contact.png",frames,["idle","walk 0","walk 1","walk 2"][:len(frames)])

    ui=image("button_source_v1.png")
    # Three equal rows; retain only authored button silhouettes.
    ui_frames=[]
    for i in range(3):
        cell=extract(ui,(0,ui.height*i//3,ui.width,ui.height*(i+1)//3),f"button_{i}")
        ui_frames.append(normalize(cell,(320,128),(300,105),116))
    write_strip("interaction_button_states.png",ui_frames)
    audit_frames("button",ui_frames,(320,128),116,0.12)
    qa_strip("button_states.png",ui_frames,["NORMAL","PRESSED","DISABLED"])

    # Terrain source images are whole authored textures; center crop to the tile unit.
    for name,source_name in [("grass","grass_source_v1.png"),("water_base","water_base_source_v1.png"),
                             ("cafe_floor","cafe_floor_source_v1.png"),("path","path_source_v1.png")]:
        src=image(source_name)
        side=min(src.size)
        region=src.crop(((src.width-side)//2,(src.height-side)//2,(src.width+side)//2,(src.height+side)//2))
        tile=region.resize((256,256),Image.Resampling.LANCZOS)
        tile.save(OUT/(name+"_tile.png"))
        adjacency=Image.new("RGBA",(768,768))
        for y in range(3):
            for x in range(3): adjacency.alpha_composite(tile,(x*256,y*256))
        adjacency.save(QA/(name+"_adjacency.png"))
        l=list(tile.crop((0,0,1,256)).getdata());r=list(tile.crop((255,0,256,256)).getdata())
        seam=sum(sum(abs(a[j]-b[j]) for j in range(3)) for a,b in zip(l,r))/(256*3)
        records[name+"_seam_mean_rgb"] = round(seam,2)

    bank_image=image("river_bank_source_v1.png")
    bank_regions=[(0,0,880,530),(880,0,1536,530),(0,530,740,1024),(740,530,1536,1024)]
    bank=[extract(bank_image,r,f"river_bank_{i}") for i,r in enumerate(bank_regions)]
    bank_frames=[normalize(c,(256,256),(240,215),236) for c in bank]
    write_strip("river_bank_pieces.png",bank_frames)
    qa_strip("river_bank_contact.png",bank_frames,["straight","outer L","outer R","shore"])
    # The authored straight bank is a long strip. Tile from its middle rather
    # than from the padded contact-sheet cell, whose transparent end gaps would
    # create repeated breaks along the river.
    grass_back = Image.open(OUT/"grass_tile.png").convert("RGBA")
    water_back = Image.open(OUT/"water_base_tile.png").convert("RGBA")
    bank_tiles = []
    for x0 in [250, 500]:
        bank_mid = clean(bank_image.crop((x0, 180, x0+256, 436)))
        bank_vertical = bank_mid.rotate(270, expand=False)
        bank_back = Image.new("RGBA", (256,256))
        bank_back.alpha_composite(water_back.crop((0,0,128,256)),(0,0))
        bank_back.alpha_composite(grass_back.crop((128,0,256,256)),(128,0))
        bank_back.alpha_composite(bank_vertical)
        bank_tiles.append(bank_back)
    bank_atlas = Image.new("RGBA",(512,256))
    for i,tile in enumerate(bank_tiles): bank_atlas.alpha_composite(tile,(i*256,0))
    bank_atlas.save(OUT/"river_bank_vertical.png")
    bank_adjacency = Image.new("RGBA",(256,768))
    for i in range(3): bank_adjacency.alpha_composite(bank_tiles[i % 2],(0,i*256))
    bank_adjacency.save(QA/"river_bank_vertical_adjacency.png")

    wall=clean(image("cafe_back_wall_source_v2.png"))
    wall=wall.crop(bounds(wall))
    normalize(wall,(1024,512),(960,430),472).save(OUT/"cafe_back_wall.png")
    rail=image("cafe_front_rail_source_v2.png")
    half=rail.width//2
    rail_left=extract(rail,(0,0,half,rail.height),"cafe_front_left")
    rail_right=extract(rail,(half,0,rail.width,rail.height),"cafe_front_right")
    normalize(rail_left,(512,320),(480,255),290).save(OUT/"cafe_front_left.png")
    normalize(rail_right,(512,320),(480,255),290).save(OUT/"cafe_front_right.png")
    records["direction_correction"]={"left":"orange_right_source_v1","right":"orange_left_source_v1"}
    records["frame_counts"]={"tree":4,"water_ripple":4,"coffee_fx":4,"orange_down":3,"orange_up":4,"orange_left":4,"orange_right":4}
    for asset in spec["assets"]:
        for name in asset["output_names"]:
            if not (OUT/name).is_file():
                failures.append(asset["asset_id"] + ": missing normalized output " + name)
        target = ROOT/asset["godot_prefab_target"]
        if not target.is_file():
            failures.append(asset["asset_id"] + ": missing prefab target " + str(target))
    expected = {"tree":spec["assets"][3]["frame_count"],
                "water_ripple":spec["assets"][2]["frame_count"],
                "coffee_fx":spec["assets"][8]["frame_count"]}
    for key,count in expected.items():
        if records["frame_counts"][key] != count:
            failures.append(key + ": spec frame count mismatch")
    if len(chair_frames) != len(spec["assets"][4]["directions"]):
        failures.append("chair: direction completeness mismatch")
    records["source_sha256"]={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in SOURCE.glob("*.png")}
    records["failures"] = failures
    (QA/"validation_report.json").write_text(json.dumps(records,indent=2)+"\n")
    print(json.dumps({"failures":failures,"outputs":len(list(OUT.glob('*.png')))},indent=2))
    return 1 if failures else 0


if __name__ == "__main__": sys.exit(main())
