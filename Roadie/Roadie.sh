#!/usr/bin/env bash
set -euo pipefail

export QT_QUICK_BACKEND=software
cd "$(dirname "$0")"

# Stop anything that might already own the camera
pkill -f libcamera-hello || true
pkill -f libcamera-vid || true
pkill -f rpicam-vid || true

# Start V4L2 bridge (creates /dev/video0) and log output
if command -v libcamera-v4l2 >/dev/null 2>&1; then
  if ! pgrep -x libcamera-v4l2 >/dev/null 2>&1; then
    echo "Starting libcamera-v4l2 bridge..."
    libcamera-v4l2 --width 1280 --height 720 --framerate 30 >libcamera-v4l2.log 2>&1 &
    sleep 1
    echo "Bridge PID: $!"
    echo "Bridge log (last 20 lines):"
    tail -n 20 libcamera-v4l2.log || true
  else
    echo "libcamera-v4l2 already running."
  fi
else
  echo "libcamera-v4l2 not installed."
fi

echo "Video devices:"
ls -l /dev/video* 2>/dev/null || echo "No /dev/video devices"

# Run app from venv
if [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 main.py
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python main.py
else
  echo "ERROR: .venv not found. Run: ./install_dependencies.sh"
  exit 1
fi