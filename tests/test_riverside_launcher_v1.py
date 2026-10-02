"""DEV intake destination and byte-identity boundaries; no production writes."""
import unittest,tempfile,importlib.util,hashlib
from pathlib import Path
import sys
sys.dont_write_bytecode=True
SOURCE=Path(sys.argv.pop(1)) if len(sys.argv)>1 and not sys.argv[1].startswith("-") else Path(__file__).resolve().parents[1]
class LaunchSafety(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.repo=Path('/Users/teddywoot/willi-cat')
  cls.source=SOURCE
  spec=importlib.util.spec_from_file_location('riverside_runner',cls.source/'tools/willicat_riverside_translation/run.py');cls.runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(cls.runner)
 def setUp(self):self.temp=tempfile.TemporaryDirectory(prefix='riverside_launch_test_',dir='/private/tmp');self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
 def reject(self,dst):
  with self.assertRaises(ValueError):self.runner.prepare(self.repo,dst,self.source)
 def test_relative(self):self.reject('relative/project')
 def test_traversal(self):self.reject(self.root/'a/../project')
 def test_protected_repository(self):self.reject(self.repo/'test_forbidden_DEV_output')
 def test_existing_destination(self):self.reject(self.root)
 def test_symlink_destination(self):
  (self.root/'link').symlink_to(self.repo,target_is_directory=True);self.reject(self.root/'link')
 def test_symlink_parent_escape(self):
  (self.root/'link').symlink_to(self.repo,target_is_directory=True);self.reject(self.root/'link'/'forbidden_project')
 def test_fresh_intake_preserves_art(self):
  dst=self.root/'project';r=self.runner.prepare(self.repo,dst,self.source)
  self.assertFalse(r['original_home_loaded']);self.assertFalse((dst/'scenes/dev/home_continuous_world').exists())
  for rel,expected in r['source_hashes'].items():self.assertEqual(hashlib.sha256((dst/rel).read_bytes()).hexdigest(),expected)
if __name__=='__main__':unittest.main()
