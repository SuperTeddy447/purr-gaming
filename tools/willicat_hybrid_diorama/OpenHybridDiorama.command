#!/bin/zsh
set -e
WILLICAT_TOOL_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
WILLICAT_REPO_DIR="$(cd -- "$WILLICAT_TOOL_DIR/../.." && pwd)"
PYTHONDONTWRITEBYTECODE=1 "$WILLICAT_REPO_DIR/tools/willicat_asset_forge/.venv/bin/python" "$WILLICAT_TOOL_DIR/run.py" --repo "$WILLICAT_REPO_DIR"
