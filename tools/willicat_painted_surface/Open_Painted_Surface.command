#!/bin/zsh
set -e
cd "$(dirname "$0")/../.."
PYTHONDONTWRITEBYTECODE=1 tools/willicat_asset_forge/.venv/bin/python tools/willicat_painted_surface/run.py
