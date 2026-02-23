#!/usr/bin/env bash
set -euo pipefail

export QT_QUICK_BACKEND=software
cd "$(dirname "$0")"

# Stop any old bridge
pkill -x libcamera-v4l2 2>/dev/null || true

# Find libcamera-v4l2 binary
LIBCAM_V4L2="$(command -v libcamera-v4l2 || true)"
if [ -z "$LIBCAM_V4L2" ]; then
  LIBCAM_V4L2="$(dpkg -L libcamera-v4l2 2>/dev/null | grep -E '/libcamera-v4l2$' | head -n 1 || true)"
fi

if [ -n "$LIBCAM_V4L2" ] && [ -x "$LIBCAM_V4L2" ]; then
  echo "Starting libcamera-v4l2 bridge: $LIBCAM_V4L2"
  "$LIBCAM_V4L2" --width 1280 --height 720 --framerate 30 > libcamera-v4l2.log 2>&1 &
  sleep 1
else
  echo "libcamera-v4l2 binary not found."
fi

echo "Bridge running?"; pgrep -a libcamera-v4l2 || true
echo "Video devices:"; ls -l /dev/video* 2>/dev/null || echo "No /dev/video devices"
echo "Bridge log (last 30 lines):"; tail -n 30 libcamera-v4l2.log 2>/dev/null || true

# Run app from venv
if [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 main.py
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python main.py
else
  echo "ERROR: .venv not found. Run: ./install_dependencies.sh"
  exit 1
fi