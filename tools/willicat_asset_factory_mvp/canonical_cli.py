"""Read-only canonical continuation inspection. No grant, compile or publication CLI."""
import argparse,json
from .canonical import (Continuation,confirm_pins,approved_observations,check_refs,ref,sha,
    validate_manifest,transition_allowed,RIGHTS_REVISION,production_ready)
from .archive import verify_archive

def inspect(repo,root):
    c=Continuation(repo,root);s=c.store
    pointer=json.loads(s.read('current_canonical.json'))
    if sha(s.read(pointer['artifact_ref']))!=pointer['sha256']:raise ValueError('canonical pointer mismatch')
    m=json.loads(s.read(pointer['artifact_ref']));validate_manifest(m);confirm_pins(c.original,m)
    artifacts=s.artifacts();check_refs(m,artifacts)
    approved_observations(s,c.original,json.loads(s.read('canonical/evidence/human_decision_binding.json')))
    stages=['resumed_structurally_validated','motion_validated','visual_qa','preview','prefab','runtime_validated']
    for before,after in zip(stages,stages[1:]):
        a=json.loads(s.read('canonical/journal/'+before+'.json'));b=json.loads(s.read('canonical/journal/'+after+'.json'))
        if not transition_allowed(a,b,RIGHTS_REVISION,artifacts,{}):raise ValueError('canonical journal transition invalid')
    receipt=json.loads(s.read(m['candidate_bundle']['receipt_ref']))
    h=verify_archive(s,receipt)
    if h!=m['candidate_bundle']['candidate_bundle_hash'] or h!=m['runtime_proof']['runtime_proof_bundle_hash']:raise ValueError('candidate/proof hash mismatch')
    return {'stage':m['lifecycle_stage'],'attempt_id':m['attempt_id'],'source_sha256':m['source']['files'][0]['sha256'],'bundle_hash':h,'gates':{k:v['status'] for k,v in m['gates'].items()},'integrity':'passed','derived_production_ready':production_ready(m,{}, {},artifacts),'production_context':'Unavailable protected production context: frozen predicate fails closed','publication':'blocked'}

def main():
    p=argparse.ArgumentParser(description='Read-only canonical tree pilot integrity inspection')
    p.add_argument('--repo',required=True);p.add_argument('--root',required=True)
    a=p.parse_args();print(json.dumps(inspect(a.repo,a.root),indent=2))
if __name__=='__main__':main()
