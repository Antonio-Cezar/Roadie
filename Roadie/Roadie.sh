#!/usr/bin/env bash
set -euo pipefail

export QT_QUICK_BACKEND=software
cd "$(dirname "$0")"

# Start V4L2 bridge if not already running
if command -v libcamera-v4l2 >/dev/null 2>&1; then
  if ! pgrep -x libcamera-v4l2 >/dev/null 2>&1; then
    libcamera-v4l2 --width 1280 --height 720 --framerate 30 >/dev/null 2>&1 &
    sleep 0.5
  fi
fi

if [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 main.py
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python main.py
else
  echo "ERROR: .venv not found. Run: ./install_dependencies.sh"
  exit 1
fi