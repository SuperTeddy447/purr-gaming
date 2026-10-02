#!/bin/zsh
set -e
TASK_REPO="$(cd "$(dirname "$0")/../.." && pwd)"
exec "$TASK_REPO/tools/willicat_asset_forge/.venv/bin/python" "$TASK_REPO/tools/willicat_cafe_kit/run.py" --repo "$TASK_REPO"
