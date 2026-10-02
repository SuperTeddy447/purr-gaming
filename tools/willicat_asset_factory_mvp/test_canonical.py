"""Canonical continuation acceptance tests; never sign or publish a real asset."""
import copy,json,tempfile,unittest,shutil,os
from pathlib import Path
from .canonical import (Continuation,approved_observations,confirm_pins,RIGHTS_REVISION,POLICY_VERSION,sha,canonical)
from .store import Store
from willicat_asset_factory_phase0.contracts import (validate_manifest,transition_allowed,scopes_permitted,production_ready,verify_approval,projection_hash)
from willicat_asset_factory_phase0.filesystem import check_bundle
REPO=Path('/Users/teddywoot/willi-cat')
ATTEMPT=Path(os.environ.get('WILLICAT_CANONICAL_TEST_ATTEMPT',str(REPO/'artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt')))
class CanonicalTest(unittest.TestCase):
 def setUp(self):
  self.c=Continuation(REPO,ATTEMPT);self.s=self.c.store;self.c.load_prefab();self.m=self.c.m
  self.grant=json.loads(self.s.read('canonical/evidence/human_decision_binding.json'))
 def test_same_reviewed_identity(self):confirm_pins(self.c.original,self.m)
 def test_exact_measurements_reproduced(self):self.assertEqual(approved_observations(self.s,self.c.original,self.grant)['total_loop_ms'],3030)
 def test_other_attempt_rejected(self):
  n=copy.deepcopy(self.c.original);n['attempt_id']='not-reviewed'
  with self.assertRaises(PermissionError):approved_observations(self.s,n,self.grant)
 def test_declined_human_cannot_pass(self):
  g=copy.deepcopy(self.grant);g['decisions']['technical_animation']='rejected'
  with self.assertRaises(PermissionError):approved_observations(self.s,self.c.original,g)
 def test_animation_identity_mismatch_rejected(self):
  n=copy.deepcopy(self.c.original);n['animation']['durations_ms'][0]+=1
  with self.assertRaises(PermissionError):approved_observations(self.s,n,self.grant)
 def test_global_policy_not_rewritten(self):
  from willicat_asset_factory_phase0.contracts import load_contract
  self.assertEqual(load_contract('tree_profile')['calibration_status'],'CANDIDATE_REQUIRES_CALIBRATION')
  self.assertTrue(all(x['policy_version']==POLICY_VERSION for x in self.m['motion_policy_results']))
 def test_numeric_checks_alone_insufficient(self):
  n=copy.deepcopy(self.m);n['motion_review']['criteria_results'][0]['result']='failed'
  with self.assertRaises(ValueError):validate_manifest(n)
 def test_adjacent_journal_valid(self):
  paths=['resumed_structurally_validated','motion_validated','visual_qa','preview','prefab']
  ms=[json.loads(self.s.read('canonical/journal/'+p+'.json')) for p in paths]
  for a,b in zip(ms,ms[1:]):self.assertTrue(transition_allowed(a,b,RIGHTS_REVISION,self.s.artifacts(),{}))
 def test_cannot_skip_stage(self):
  a=json.loads(self.s.read('canonical/journal/resumed_structurally_validated.json'))
  self.assertFalse(transition_allowed(a,self.m,RIGHTS_REVISION,self.s.artifacts(),{}))
 def test_action_scoped_rights(self):
  self.assertTrue(scopes_permitted(self.m,'candidate_compile',RIGHTS_REVISION));self.assertTrue(scopes_permitted(self.m,'integration_proof',RIGHTS_REVISION));self.assertFalse(scopes_permitted(self.m,'publish',RIGHTS_REVISION));self.assertFalse(scopes_permitted(self.m,'integration_proof','revoked'))
 def test_bundle_matches_compiled_receipt(self):
  receipt=json.loads(self.s.read('canonical/candidate_bundle_receipt.json'))
  from .archive import verify_archive
  self.assertEqual(verify_archive(self.s,receipt),self.m['candidate_bundle']['candidate_bundle_hash'])
 def test_bundle_tamper_rejected(self):
  with tempfile.TemporaryDirectory(dir='/private/tmp') as d:
   dest=Path(d)/'bundle';shutil.copytree(self.s.root/'canonical/bundle',dest)
   p=next(dest.rglob('tree.png'));p.chmod(0o600);p.write_bytes(b'tamper')
   with self.assertRaises(ValueError):check_bundle(dest,json.loads(self.s.read('canonical/candidate_bundle_receipt.json')))
 def test_compile_once(self):
  self.c.m=json.loads(self.s.read('canonical/journal/preview.json'))
  with self.assertRaises(FileExistsError):self.c.compile()
 def test_forged_role_not_production_credential(self):self.assertFalse(verify_approval({'role':'human','result':'passed'},{'credentials':{}}))
 def test_no_production_ready_override(self):
  n=copy.deepcopy(self.m);n['production_ready']=True
  with self.assertRaises(Exception):validate_manifest(n)
  self.assertFalse(production_ready(self.m,{}, {},self.s.artifacts()))
 def test_authority_projection_semantics(self):
  a=copy.deepcopy(self.m['world_authority']['projection']);h=projection_hash(a);a['unrelated_home_decoration']='edit';self.assertEqual(projection_hash(a),h);a['global_transform'][4]='-321';self.assertNotEqual(projection_hash(a),h)
 def test_new_source_refuses_review(self):
  n=copy.deepcopy(self.c.original);n['source']['files'][0]['sha256']='0'*64
  with self.assertRaises(PermissionError):approved_observations(self.s,n,self.grant)
class ArchiveTest(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory(dir='/private/tmp');self.store=Store(self.tmp.name,REPO)
  self.store.once('canonical/bundle/assets/tree.json',b'original')
  self.receipt={'bundle_format_version':'tree-candidate-1','resource_map':[{'logical_path':'res://assets/tree.json','member_path':'assets/tree.json'}],'members':[{'path':'assets/tree.json','sha256':sha(b'original')}],'registration_hash':'1'*64,'rights_reference_hash':'2'*64,'timing_recipe_version':'godot-ms-weight-1','toolchain_fingerprint_hash':'3'*64}
 def tearDown(self):self.tmp.cleanup()
 def test_unlisted_archive_member_rejected(self):
  from .archive import verify_archive
  self.store.once('canonical/bundle/extra.json',b'changed')
  with self.assertRaises(ValueError):verify_archive(self.store,self.receipt)
 def test_duplicate_mapping_rejected(self):
  from .archive import verify_archive
  self.receipt['resource_map']*=2
  with self.assertRaises(ValueError):verify_archive(self.store,self.receipt)
 def test_archive_symlink_rejected(self):
  from .archive import verify_archive
  (self.store.root/'canonical/bundle/escape').symlink_to(REPO/'assets',target_is_directory=True)
  with self.assertRaises(ValueError):verify_archive(self.store,self.receipt)
if __name__=='__main__':unittest.main(verbosity=2)
