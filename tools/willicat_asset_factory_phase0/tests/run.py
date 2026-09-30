"""Record actual unittest results; no fabricated gate passes."""
import json,os,unittest
from pathlib import Path
class ReceiptResult(unittest.TextTestResult):
    def __init__(self,*a,**kw):super().__init__(*a,**kw);self.cases=[]
    def addSuccess(self,test):super().addSuccess(test);self.cases.append({'test_id':test.id(),'result':'passed'})
    def addFailure(self,test,error):super().addFailure(test,error);self.cases.append({'test_id':test.id(),'result':'failed'})
    def addError(self,test,error):super().addError(test,error);self.cases.append({'test_id':test.id(),'result':'error'})
suite=unittest.defaultTestLoader.discover(str(Path(__file__).parent),pattern='test_*.py')
r=unittest.TextTestRunner(verbosity=2,resultclass=ReceiptResult).run(suite)
Path(os.environ['PHASE0_EVIDENCE_DIR'],'contract_test_results.json').write_text(json.dumps({'scope':'TEST FIXTURE ONLY; NOT PRODUCTION ASSET APPROVAL','tests_run':r.testsRun,'failures':len(r.failures),'errors':len(r.errors),'cases':r.cases},indent=2)+'\n')
raise SystemExit(0 if r.wasSuccessful() else 1)
