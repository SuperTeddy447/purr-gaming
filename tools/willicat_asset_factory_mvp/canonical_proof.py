"""Prepare a disposable logical-path-identical project for canonical proof, not Home publication."""
from pathlib import Path
import json,shutil
from .diagnostics import prepare as prepare_diagnostic
from .canonical import Continuation,PREFIX
from willicat_asset_factory_phase0.contracts import sha,scopes_permitted
from .canonical import RIGHTS_REVISION

def prepare(repo,root,project):
    p=Continuation(repo,root);p.load_prefab()
    if not scopes_permitted(p.m,'integration_proof',RIGHTS_REVISION):raise PermissionError('integration proof scope absent')
    base=prepare_diagnostic(repo,root,project)
    project=Path(project)
    # Historical DEV bundle is not the candidate under proof. Remove only its temporary copy.
    shutil.rmtree(project/'assets/__DEV_DIAGNOSTIC_tree_pilot_v1__')
    (project/'DEV_DIAGNOSTIC_tree.gd').unlink()
    # Unused legacy sample WAVs previously emit unrelated importer errors; exclude them from this isolated tree proof.
    excluded=[]
    sounds=project/'assets/Sound'
    if sounds.exists():
        excluded=[str(f.relative_to(project)) for f in sounds.rglob('*') if f.is_file()];shutil.rmtree(sounds)
    bundle=json.loads(p.store.read('canonical/candidate_bundle_receipt.json'))
    for row in bundle['members']:
        rel=row['path'];dest=project/rel
        if dest.exists():raise FileExistsError('candidate destination already exists')
        dest.parent.mkdir(parents=True,exist_ok=True)
        data=p.store.read('canonical/bundle/'+rel)
        if sha(data)!=row['sha256']:raise ValueError('immutable candidate member changed')
        dest.write_bytes(data)
    (project/'CANONICAL_tree_proof.gd').write_bytes((Path(__file__).parent/'CANONICAL_tree_proof.gd').read_bytes())
    proj=project/'project.godot';s=proj.read_text().replace('WilliCat DEV_DIAGNOSTIC Tree Pilot','WilliCat Canonical Candidate Proof').replace('WilliCatMVP_DEV_DIAGNOSTIC','WilliCatMVP_CanonicalProof');proj.write_text(s)
    # Explicit policy is compiled in the bundle. Godot defaults must reproduce it; collector checks all effective params.
    receipt={'scope':'canonical_integration_proof_project','candidate_bundle_hash':p.m['candidate_bundle']['candidate_bundle_hash'],'logical_prefab_path':p.m['candidate_bundle']['logical_prefab_path'],'same_logical_res_paths':True,'suppressed_proxy_textures':base['suppressed_proxy_textures'],'unused_legacy_audio_excluded':excluded,'world_and_gameplay_sources':'unchanged copied authority','production_modified':False}
    (project/'proof_preparation.json').write_text(json.dumps(receipt,indent=2)+'\n')
    return receipt
