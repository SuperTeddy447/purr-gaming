import copy,json,unittest,os
from .canonical_cli import inspect
from .canonical import Continuation,RIGHTS_REVISION,PREFIX,sha
from willicat_asset_factory_phase0.contracts import validate_manifest,transition_allowed,production_ready
REPO='/Users/teddywoot/willi-cat';ROOT=os.environ.get('WILLICAT_CANONICAL_TEST_ATTEMPT',REPO+'/artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt')
class RuntimeTest(unittest.TestCase):
 def setUp(self):self.c=Continuation(REPO,ROOT);self.s=self.c.store;self.m=json.loads(self.s.read('canonical/journal/runtime_validated.json'));self.a=self.s.artifacts()
 def test_runtime_schema(self):validate_manifest(self.m)
 def test_runtime_adjacent_transition(self):self.assertTrue(transition_allowed(json.loads(self.s.read('canonical/journal/prefab.json')),self.m,RIGHTS_REVISION,self.a,{}))
 def test_live_integrity(self):self.assertEqual(inspect(REPO,ROOT)['integrity'],'passed')
 def test_all_actual_runtime_checks(self):self.assertTrue(all(json.loads(self.s.read('canonical/evidence/canonical_integration_proof.json'))['checks'].values()))
 def test_no_false_production_eligibility(self):self.assertFalse(production_ready(self.m,{}, {},self.a));self.assertNotIn('human_approval',self.m);self.assertNotIn('publication',self.m)
 def test_runtime_evidence_tamper_blocks_transition(self):
  a=dict(self.a);a['canonical/evidence/canonical_integration_proof.json']=b'changed';self.assertFalse(transition_allowed(json.loads(self.s.read('canonical/journal/prefab.json')),self.m,RIGHTS_REVISION,a,{}))
 def test_authority_changed_blocks_transition(self):
  n=copy.deepcopy(self.m);n['world_authority']['projection']['global_transform'][4]='-321';self.assertFalse(transition_allowed(json.loads(self.s.read('canonical/journal/prefab.json')),n,RIGHTS_REVISION,self.a,{}))
 def test_candidate_pngs_are_approved_bytes(self):
  for src,dst in [('normalized/tree.png','tree.png'),('normalized/shadow.png','shadow.png')]:self.assertEqual(self.s.read(src),self.s.read('canonical/bundle/'+PREFIX+dst))
 def test_compiler_receipt_matches_actual_code(self):
  from pathlib import Path
  from . import canonical as implementation
  receipt=json.loads(self.s.read('canonical/bundle/'+PREFIX+'compiler_receipt.json'));self.assertEqual(receipt['compiler_code_hash'],sha(Path(implementation.__file__).read_bytes()))
if __name__=='__main__':unittest.main(verbosity=2)
