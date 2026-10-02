"""Open the isolated painted-surface/light DEV variant. No production publication."""
from pathlib import Path
import argparse,sys,subprocess,shutil,json,tempfile,hashlib,os
sys.dont_write_bytecode=True
REPO=Path(__file__).resolve().parents[2]
GODOT='/Applications/Godot.app/Contents/MacOS/Godot'
def prepare(repo,project,source=None):
 repo=Path(repo).resolve();source=Path(source or repo).resolve();raw=Path(project)
 if not raw.is_absolute() or '..' in raw.parts or raw.is_symlink():raise ValueError('Fresh isolated /private/tmp destination required')
 target=raw.resolve()
 if target.exists() or Path('/private/tmp').resolve() not in target.parents:raise ValueError('Existing/protected destinations refused')
 sys.path.insert(0,str(repo/'tools'));from willicat_hero_asset_replacement.run import prepare as kit_prepare
 receipt=kit_prepare(repo,target)
 for rel in ['assets/dev_review/hybrid_cafe_painted_surface_v1','scenes/dev/hybrid_cafe_painted_surface','scripts/dev/hybrid_cafe_painted_surface']:
  origin=source/rel
  if source not in origin.resolve().parents or any(p.is_symlink() for p in origin.rglob('*')):raise ValueError('Symlink/path escape refused')
  shutil.copytree(origin,target/rel)
 for name in ['capture_painted_surface_v1.gd','profile_painted_surface_v1.gd','test_painted_surface_input_v1.gd','test_painted_surface_materials_v1.gd']:shutil.copy2(source/'tests'/name,target/'tests'/name)
 config=target/'project.godot';config.write_text(config.read_text().replace('scenes/dev/hybrid_cafe_hero_replacement/hybrid_cafe_hero_replacement_v1.tscn','scenes/dev/hybrid_cafe_painted_surface/hybrid_cafe_painted_surface_v1.tscn').replace('WilliCatCafeHeroReplacementDEVV1','WilliCatCafePaintedSurfaceDEVV1').replace('WilliCat Cafe Art Direction DEV','WilliCat Cafe Painted Surface DEV'))
 receipt.update({'scope':'ISOLATED_DEV_PAINTED_SURFACE_V1; human visual decision pending; no production publication','distinct_save_namespace':'WilliCatCafePaintedSurfaceDEVV1','art_variant_hashes':{str(p.relative_to(source)):hashlib.sha256(p.read_bytes()).hexdigest() for rel in ['assets/dev_review/hybrid_cafe_painted_surface_v1','scripts/dev/hybrid_cafe_painted_surface','scenes/dev/hybrid_cafe_painted_surface'] for p in (source/rel).rglob('*') if p.is_file() and p.suffix not in ['.uid','.import']}})
 (target/'painted_surface_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');return receipt

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--repo',default=str(REPO));parser.add_argument('--project');parser.add_argument('--prepare-only',action='store_true');args=parser.parse_args()
 try:import numpy;from PIL import Image
 except ImportError:
  python=Path(args.repo)/'tools/willicat_asset_forge/.venv/bin/python'
  if python.exists() and str(python)!=sys.executable:raise SystemExit(subprocess.call([str(python),__file__,*sys.argv[1:]],env={**os.environ,'PYTHONDONTWRITEBYTECODE':'1'}))
  raise RuntimeError('Existing Forge Pillow/NumPy environment required')
 project=Path(args.project) if args.project else Path(tempfile.mkdtemp(prefix='willicat_cafe_art_review_',dir='/private/tmp'))/'project';prepare(args.repo,project);print('Isolated art review project:',project,flush=True)
 if args.prepare_only:return
 subprocess.run([GODOT,'--headless','--editor','--import','--path',str(project),'--quit'],check=True)
 subprocess.run([GODOT,'--path',str(project),'--rendering-method','mobile','--rendering-driver','metal'],check=True)
if __name__=='__main__':main()
