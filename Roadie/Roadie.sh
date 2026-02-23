#!/usr/bin/env bash
set -euo pipefail

export QT_QUICK_BACKEND=software
cd "$(dirname "$0")"

if [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 main.py
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python main.py
else
  echo "ERROR: .venv not found. Run: ./install_dependencies.sh"
  exit 1
fi