#!/bin/zsh
set -euo pipefail
riverside_tools_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
exec /usr/bin/python3 "$riverside_tools_dir/run.py"
