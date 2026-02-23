#!/usr/bin/env bash
set -euo pipefail

export QT_QUICK_BACKEND=software
cd "$(dirname "$0")"

PI_HOST="pi@192.168.10.150"
PI_IP="192.168.10.150"
RTSP_URL="rtsp://${PI_IP}:8554/cam"

cleanup() {
  ssh -o ConnectTimeout=2 "$PI_HOST" "pkill -f 'ffmpeg.*rtsp://127.0.0.1:8554/cam' || true" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo "Ensuring RTSP stream is running on Pi: $RTSP_URL"

ssh -o ConnectTimeout=4 "$PI_HOST" '
  set -e
  command -v ffmpeg >/dev/null 2>&1 || (sudo apt update && sudo apt install -y ffmpeg)

  # Start MediaMTX (RTSP server) via snap if available
  if command -v snap >/dev/null 2>&1; then
    sudo snap install mediamtx >/dev/null 2>&1 || true
    sudo snap start mediamtx >/dev/null 2>&1 || true
  fi

  # If publisher already running, do nothing
  if pgrep -f "rtsp://127.0.0.1:8554/cam" >/dev/null; then
    exit 0
  fi

  # Start publisher
  nohup bash -lc "libcamera-vid -t 0 --inline --codec h264 -o - | ffmpeg -re -i - -c copy -f rtsp rtsp://127.0.0.1:8554/cam" >/dev/null 2>&1 &
' || echo "Warning: could not start stream on Pi (check SSH user/password/keys)."

# Run app from venv
if [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 main.py
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python main.py
else
  echo "ERROR: .venv not found. Run: ./install_dependencies.sh"
  exit 1
fi