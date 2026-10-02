import copy,json,os,tempfile,unittest,threading
from pathlib import Path
from PIL import Image,ImageDraw
from .store import Store
from .pipeline import Pipeline,author_frames,measure,structural,normalized_rest,DURATIONS
from willicat_asset_factory_phase0.contracts import verify_approval,sha,canonical,project,projection_hash,validate_manifest
REPO=Path('/Users/teddywoot/willi-cat')
class MVPTest(unittest.TestCase):
 def setUp(self):self.tmp=tempfile.TemporaryDirectory(prefix='WilliCatMVP_',dir='/private/tmp');self.root=Path(self.tmp.name);self.s=Store(self.root,REPO)
 def tearDown(self):self.tmp.cleanup()
 def test_traversal(self):
  for v in ['../out','/tmp/x','a/../../x','a//x','res://x','a\\x','./x','a/./x']:
   with self.assertRaises(ValueError):self.s.once(v,b'x')
 def test_symlink(self):
  (self.root/'escape').symlink_to(REPO/'assets',target_is_directory=True)
  with self.assertRaises(ValueError):self.s.once('escape/bad.png',b'x')
 def test_dangling_symlink(self):
  (self.root/'escape').symlink_to('/private/tmp/missing_mvp_dest')
  with self.assertRaises(ValueError):self.s.once('escape/x',b'x')
 def test_production_root(self):
  for p in [REPO/'assets',REPO/'scenes',REPO/'tools',REPO/'artifacts/other']:
   with self.assertRaises(ValueError):Store(p,REPO)
 def test_symlink_root(self):
  dest=self.root/'real';dest.mkdir();(self.root/'linked').symlink_to(dest,target_is_directory=True)
  with self.assertRaises(ValueError):Store(self.root/'linked',REPO)
 def test_write_once(self):
  self.s.once('a/source',b'original')
  with self.assertRaises(FileExistsError):self.s.once('a/source',b'changed')
  self.assertEqual(self.s.read('a/source'),b'original')
 def test_atomic_pointer_and_serialized_writes(self):
  self.s.pointer('index.json',{'value':0})
  ts=[threading.Thread(target=self.s.pointer,args=('index.json',{'value':i})) for i in range(15)]
  for t in ts:t.start()
  for t in ts:t.join()
  self.assertIn(json.loads(self.s.read('index.json'))['value'],range(15))
 def test_replaced_parent_symlink_rejected(self):
  self.s.once('dir/file',b'x');(self.root/'dir/file').unlink();(self.root/'dir').rmdir();(self.root/'dir').symlink_to(REPO/'assets',target_is_directory=True)
  with self.assertRaises(ValueError):self.s.once('dir/new',b'x')
 def test_forged_human_role(self):self.assertFalse(verify_approval({'role':'human','decision':'approve'},{'credentials':{}}))
 def test_no_publisher(self):
  with self.assertRaises(PermissionError):Pipeline(REPO,self.root).publish()
 def test_invalid_canonical_compile(self):
  with self.assertRaises(Exception):Pipeline(REPO,self.root).canonical_compile({'production_ready':True})
 def test_source_edge_reject(self):
  im=Image.new('RGBA',(100,100));ImageDraw.Draw(im).rectangle((0,1,20,80),fill='green')
  with self.assertRaises(ValueError):normalized_rest(im,{'source_canvas_px':[512,640]})
 def test_empty_source_reject(self):
  with self.assertRaises(ValueError):normalized_rest(Image.new('RGBA',(100,100)),{})
 def tree(self):
  im=Image.new('RGBA',(512,640));d=ImageDraw.Draw(im);d.ellipse((30,156,480,480),fill='#768658');d.rectangle((240,400,270,599),fill='#9B6D44');return im
 def test_root_unchanged_not_whole_scale(self):
  fs=author_frames(self.tree());m=measure(fs);self.assertEqual(m['root_displacement_px'],'0');self.assertTrue(all(f.crop((0,480,512,640)).tobytes()==fs[0].crop((0,480,512,640)).tobytes() for f in fs));self.assertFalse(m['whole_sprite_scale_animation'])
 def test_seam_and_nonuniform_timing(self):
  fs=author_frames(self.tree());self.assertEqual(fs[0].tobytes(),fs[-1].tobytes());self.assertGreater(len(set(DURATIONS)),1);self.assertEqual(len(fs),len(DURATIONS))
 def test_measurements_do_not_pass_motion_gate(self):
  m=measure(author_frames(self.tree()));self.assertEqual(m['policy_state'],'CANDIDATE_REQUIRES_CALIBRATION');self.assertEqual(m['numeric_quality_verdict'],'not_evaluated_no_calibrated_thresholds');self.assertNotIn('canonical_gate_passed',m)
 def test_drift_reject_structural(self):
  fs=author_frames(self.tree());ImageDraw.Draw(fs[2]).rectangle((242,599,250,610),fill='brown');self.assertEqual(structural(fs,{'source_canvas_px':[512,640]})['result'],'FAIL')
 def test_projection_unrelated(self):
  s=json.loads((REPO/'artifacts/asset_factory/phase_0_contract_lock_v1/authority_snapshot.json').read_text());h=projection_hash(s);s['unrelated_decoration']='changed';self.assertEqual(h,projection_hash(s))
 def test_projection_relevant(self):
  s=json.loads((REPO/'artifacts/asset_factory/phase_0_contract_lock_v1/authority_snapshot.json').read_text());h=projection_hash(s);s['global_transform'][4]+=1;self.assertNotEqual(h,projection_hash(s))

class LifecycleTest(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.tmp=tempfile.TemporaryDirectory(prefix='WilliCatMVP_Lifecycle_',dir='/private/tmp');cls.root=Path(cls.tmp.name);inputs=cls.root/'inputs';inputs.mkdir();cls.output=cls.root/'attempt'
  source=Image.new('RGBA',(100,120));d=ImageDraw.Draw(source);d.ellipse((8,10,90,85),fill='#74814e');d.rectangle((44,70,56,110),fill='#9b6d44');source.save(inputs/'source.png')
  (inputs/'prompt.txt').write_text('TEST FIXTURE ONLY: original synthetic geometry; not generated game art')
  (inputs/'authoring.json').write_text(json.dumps({'template_id':'TEST_ONLY_tree','template_version':'1','source_sha256':sha((inputs/'source.png').read_bytes()),'reference_image_inputs':[],'third_party_art_conditioning':False,'prompt_file':'prompt.txt','prompt_sha256':sha((inputs/'prompt.txt').read_bytes())}))
  (inputs/'template.json').write_text(json.dumps({'template_id':'TEST_ONLY_tree','template_version':'1','world_authority_ref':'res://scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn','source_canvas_px':[512,640],'pivot_px':['256','600'],'floor_baseline_px':'600'}))
  (inputs/'auth.txt').write_text('TEST FIXTURE ONLY; no production authorization')
  cls.p=Pipeline(REPO,cls.output)
  cls.result=cls.p.run(inputs/'source.png',inputs/'template.json',REPO/'artifacts/asset_factory/phase_0_contract_lock_v1/authority_snapshot.json',REPO/'docs/asset_factory/style_families/WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1.json',inputs/'auth.txt',inputs/'authoring.json')
 @classmethod
 def tearDownClass(cls):cls.tmp.cleanup()
 def test_frozen_journal_schema_and_human_hold(self):
  from .qa import inspect_live
  for file in (self.output/'journal').glob('*.json'):validate_manifest(json.loads(file.read_text()))
  view=inspect_live(REPO,self.output);self.assertEqual(view['canonical_stage'],'structurally_validated');self.assertEqual(view['disposition'],'human_hold');self.assertEqual(view['gates']['motion']['status'],'pending');self.assertEqual(view['gates']['visual']['status'],'pending')
 def test_dev_result_does_not_complete_canonical_gates(self):
  self.assertEqual(self.result['canonical_candidate_compilation'],'BLOCKED_PENDING_REQUIRED_HUMAN_REVIEWS');self.assertEqual(self.result['canonical_integration_proof'],'NOT_YET_EXECUTED');self.assertEqual(self.result['production'],'BLOCKED')
 def test_production_rights_not_inferred(self):
  m=json.loads((self.output/'human_hold_manifest.json').read_text());evaluations={r['action']:r for r in m['rights_evaluations']}
  self.assertEqual(evaluations['integration_proof']['required_scopes'],['dev_runtime']);self.assertEqual(evaluations['integration_proof']['result'],'passed');self.assertEqual(evaluations['publish']['result'],'failed');self.assertTrue(any(s['outcome']=='unresolved' for s in evaluations['publish']['assessments']))
 def test_canonical_compile_stays_blocked(self):
  m=json.loads((self.output/'human_hold_manifest.json').read_text())
  with self.assertRaises(PermissionError):self.p.canonical_compile(m)
 def test_measurements_cannot_advance_frozen_motion_stage(self):
  from willicat_asset_factory_phase0.contracts import transition_allowed
  m=json.loads((self.output/'human_hold_manifest.json').read_text());n=copy.deepcopy(m);n['lifecycle_stage']='motion_validated';n['gates']['motion']['status']='passed'
  self.assertFalse(transition_allowed(m,n,'dev-human-authorization-v1',self.p.store.artifacts(),{}))
 def test_tampered_source_blocks_live_check(self):
  from .qa import inspect_live
  original=self.p.store.read('source/tree_source_v1.png');p=self.output/'source/tree_source_v1.png';p.chmod(0o600);p.write_bytes(b'tampered')
  try:
   with self.assertRaises(ValueError):inspect_live(REPO,self.output)
  finally:p.write_bytes(original);p.chmod(0o400)
 def test_bundle_and_logical_path_parity(self):
  from .diagnostics import check_bundle
  project=self.root/'TEST_ONLY_project';project.mkdir()
  for row in json.loads((self.output/'diagnostic_bundle_receipt.json').read_text())['members']:
   dest=project/row['member_path'];dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes((self.output/'diagnostic_bundle'/row['member_path']).read_bytes())
  r=check_bundle(self.p.store,project);self.assertFalse(r['canonical_integration_proof'])
  dest=project/'assets/__DEV_DIAGNOSTIC_tree_pilot_v1__/tree.png';dest.write_bytes(b'changed')
  with self.assertRaises(ValueError):check_bundle(self.p.store,project)
 def test_prior_source_and_evidence_cannot_be_overwritten(self):
  with self.assertRaises(FileExistsError):self.p.store.once('source/tree_source_v1.png',b'changed')
  with self.assertRaises(FileExistsError):self.p.store.json('evidence/development_motion_evidence.json',{'result':'passed'})

if __name__=='__main__':unittest.main(verbosity=2)
