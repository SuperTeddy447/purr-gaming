#!/bin/zsh
set -eu
cd "${0:A:h}"
exec /Users/teddywoot/willi-cat/tools/willicat_asset_forge/.venv/bin/python run.py
