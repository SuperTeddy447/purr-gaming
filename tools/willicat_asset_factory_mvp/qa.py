"""Live deterministic artifact checks; diagnostics never replace frozen gate decisions."""
import io,json
from PIL import Image
from willicat_asset_factory_phase0.contracts import sha,canonical,validate_manifest,load_contract
from .pipeline import structural,DURATIONS
from .store import Store

def inspect_live(repo,root):
    store=Store(root,repo)
    m=json.loads(store.read('human_hold_manifest.json'));validate_manifest(m)
    pointer=json.loads(store.read('current.json'))
    if sha(store.read(pointer['artifact_ref']))!=pointer['sha256']:raise ValueError('current pointer/hash changed')
    if pointer['artifact_ref']!='human_hold_manifest.json':raise ValueError('pointer does not identify human hold')
    for row in m['source']['files']+m['normalized']['files']:
        if sha(store.read(row['path']))!=row['sha256']:raise ValueError('source/normalized artifact changed: '+row['path'])
    fingerprint=m['normalized']['toolchain_fingerprint']
    frames=[Image.open(io.BytesIO(store.read(f'normalized/frames/{i:02}.png'))).convert('RGBA') for i in range(len(DURATIONS))]
    if m['animation']['durations_ms']!=DURATIONS or len(m['animation']['frame_map'])!=len(frames):raise ValueError('manifest timing/frame parity changed')
    report=structural(frames,json.loads(store.read('evidence/template.json')))
    if report['result']!='PASS':raise ValueError('Live structural diagnostic failed')
    atlas=Image.open(io.BytesIO(store.read('normalized/tree.png'))).convert('RGBA')
    for i,f in enumerate(frames):
        if f.tobytes()!=atlas.crop((i*512,0,(i+1)*512,640)).tobytes():raise ValueError('frame/atlas parity changed')
    for g in ['motion','visual']:
        if m['gates'][g]['status']!='pending':raise ValueError('DEV slice cannot declare human gate pass')
    for g in ['runtime','human']:
        if m['gates'][g]['status']!='not_started':raise ValueError('DEV proof cannot declare canonical gate pass')
    if m['lifecycle_stage']!='structurally_validated' or m['disposition']!='human_hold':raise ValueError('wrong frozen human hold')
    if any(k in m for k in ['candidate_bundle','runtime_proof','human_approval','publication','production_ready']):raise ValueError('canonical publication evidence forbidden in DEV output')
    return {'asset_id':m['asset_id'],'asset_version':m['asset_version'],'attempt_id':m['attempt_id'],'category':m['category'],'style':m['style_calibration'],'template':m['template'],'authority_projection_hash':m['world_authority']['world_authority_projection_hash'],'canonical_stage':m['lifecycle_stage'],'disposition':m['disposition'],'gates':m['gates'],'source_and_atlas_hash_integrity':'PASS','diagnostic_evidence_root':str(store.root),'production_eligibility':'BLOCKED','human_reviews':'PENDING'}
