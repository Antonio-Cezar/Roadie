#!/usr/bin/env bash
set -euo pipefail

export QT_QUICK_BACKEND=software
cd "$(dirname "$0")"

# Start camera stream if libcamera-vid exists
CAM_PID=""
cleanup() {
  if [ -n "${CAM_PID:-}" ] && kill -0 "$CAM_PID" 2>/dev/null; then
    kill "$CAM_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

if command -v libcamera-vid >/dev/null 2>&1; then
  # Only start if nothing is already listening on 8888
  if ! ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE '(:|\.)8888$'; then
    echo "Starting camera stream on tcp://0.0.0.0:8888 ..."
    libcamera-vid -t 0 --inline --listen -o tcp://0.0.0.0:8888 >/dev/null 2>&1 &
    CAM_PID=$!
    sleep 0.3
  else
    echo "Camera stream already running on port 8888."
  fi
else
  echo "libcamera-vid not found; skipping camera stream."
fi

# Run app from venv
if [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 main.py
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python main.py
else
  echo "ERROR: .venv not found. Run: ./install_dependencies.sh"
  exit 1
fi