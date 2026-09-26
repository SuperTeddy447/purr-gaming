#!/usr/bin/env bash
# WilliCat Asset Forge — launcher script.
# Usage: ./run.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/.venv"

echo "🐱 WilliCat Asset Forge — starting..."

# Create or reuse virtual environment.
if [ ! -d "${VENV_DIR}" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv "${VENV_DIR}"
fi

# Activate.
source "${VENV_DIR}/bin/activate"

# Install/update dependencies.
echo "📦 Checking dependencies..."
pip install -q -r "${SCRIPT_DIR}/requirements.txt"

# Launch Streamlit.
echo "🚀 Launching Asset Forge GUI..."
echo "   URL: http://localhost:8501"
cd "${SCRIPT_DIR}"
python -m streamlit run app.py --server.headless=true
