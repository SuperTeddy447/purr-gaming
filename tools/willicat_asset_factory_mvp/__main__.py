import argparse,json,uuid
from datetime import datetime,timezone
from pathlib import Path
from .pipeline import Pipeline
from .store import Store
from willicat_asset_factory_phase0.contracts import parse_json,validate_manifest

def main():
 p=argparse.ArgumentParser(description='DEV_DIAGNOSTIC only: never publish or confer human approval')
 p.add_argument('--repo',required=True);p.add_argument('--root',required=True);sub=p.add_subparsers(dest='command',required=True)
 r=sub.add_parser('run-diagnostic');
 for name in ['source','template','authority','style','authorization','authoring-receipt']:r.add_argument('--'+name,required=True)
 prep=sub.add_parser('prepare-diagnostic');prep.add_argument('--project',required=True)
 d=sub.add_parser('collect-diagnostic')
 for name in ['project','capture-dir']:d.add_argument('--'+name,required=True)
 sub.add_parser('inspect');sub.add_parser('catalog');sub.add_parser('validate');sub.add_parser('compile');sub.add_parser('publish')
 a=p.parse_args();store=Store(a.root,a.repo)
 if a.command=='run-diagnostic':
  try:result=Pipeline(a.repo,a.root).run(a.source,a.template,a.authority,a.style,a.authorization,a.authoring_receipt)
  except Exception as exc:
   store.json('failures/'+uuid.uuid4().hex+'.json',{'scope':'development_attempt_failure','timestamp':datetime.now(timezone.utc).isoformat(),'error_type':type(exc).__name__,'message':str(exc),'canonical_stage_not_advanced':True});raise
  store.json('diagnostic_status.json',result);print(json.dumps(result,indent=2));return
 if a.command=='prepare-diagnostic':
  from .diagnostics import prepare
  print(json.dumps(prepare(a.repo,a.root,a.project),indent=2));return
 if a.command=='collect-diagnostic':
  from .diagnostics import collect
  print(json.dumps(collect(a.repo,a.root,a.project,a.capture_dir),indent=2));return
 if a.command in ['publish','compile']:raise SystemExit('BLOCKED: this DEV implementation has no canonical compile/publisher capability')
 from .qa import inspect_live
 view=inspect_live(a.repo,a.root)
 if a.command=='validate':print('Live integrity and frozen schema valid; human review gates remain pending');return
 if a.command=='catalog':store.pointer('catalog_index.json',view)
 print(json.dumps(view,indent=2))
if __name__=='__main__':main()
