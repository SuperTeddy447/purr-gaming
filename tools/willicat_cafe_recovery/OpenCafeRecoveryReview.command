#!/bin/zsh
set -eu
TASK_TOOL_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
TASK_REPO="$(cd -- "$TASK_TOOL_DIR/../.." && pwd)"
export PYTHONDONTWRITEBYTECODE=1
exec "$TASK_REPO/tools/willicat_asset_forge/.venv/bin/python" "$TASK_TOOL_DIR/run.py" --repo "$TASK_REPO"
