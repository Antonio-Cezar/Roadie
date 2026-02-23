#!/usr/bin/env bash
set -euo pipefail

export QT_QUICK_BACKEND=software
cd "$(dirname "$0")"

PI_HOST="pi@raspberrypi.local"
RTSP_URL="rtsp://raspberrypi.local:8554/cam"

cleanup() {
  # Stop remote publisher (best effort)
  ssh -o ConnectTimeout=2 "$PI_HOST" "pkill -f 'ffmpeg.*rtsp://127.0.0.1:8554/cam' || true" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo "Ensuring RTSP stream is running on Pi: $RTSP_URL"

# Start RTSP server on Pi (snap mediamtx) - best effort
ssh -o ConnectTimeout=4 "$PI_HOST" '
  set -e
  command -v ffmpeg >/dev/null 2>&1 || sudo apt update && sudo apt install -y ffmpeg
  if command -v mediamtx >/dev/null 2>&1; then
    true
  else
    # try snap install (ignore if snap not available)
    if command -v snap >/dev/null 2>&1; then
      sudo snap install mediamtx || true
    fi
  fi
  # start server if installed
  if command -v mediamtx >/dev/null 2>&1; then
    nohup mediamtx >/dev/null 2>&1 &
  elif command -v snap >/dev/null 2>&1; then
    sudo snap start mediamtx >/dev/null 2>&1 || true
  fi

  # start publisher if not running
  if pgrep -f "rtsp://127.0.0.1:8554/cam" >/dev/null; then
    exit 0
  fi

  nohup bash -lc "libcamera-vid -t 0 --inline --codec h264 -o - | ffmpeg -re -i - -c copy -f rtsp rtsp://127.0.0.1:8554/cam" >/dev/null 2>&1 &
' >/dev/null || echo "Warning: could not start stream on Pi (check SSH/permissions)."

# Run app from venv
if [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 main.py
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python main.py
else
  echo "ERROR: .venv not found. Run: ./install_dependencies.sh"
  exit 1
fi