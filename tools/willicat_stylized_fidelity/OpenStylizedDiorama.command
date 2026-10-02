#!/bin/zsh
set -e
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 "$TOOL_DIR/run.py" --mode live
