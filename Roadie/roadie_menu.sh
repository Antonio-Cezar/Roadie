#!/usr/bin/env bash
set -euo pipefail

PS3="Choose: "

options=(
  "Scan Wi-Fi"
  "Show active connection"
  "Restart NetworkManager"
  "Run my app"
  "Exit"
)

select opt in "${options[@]}"; do
  case "$REPLY" in
    1) nmcli dev wifi rescan || true; nmcli dev wifi list | less ;;
    2) nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' || echo "Not connected"; read -r ;;
    3) sudo systemctl restart NetworkManager; echo "Restarted."; sleep 1 ;;
    4) cd "$(dirname "$0")"; source .venv/bin/activate 2>/dev/null || true; python3 main.py ;;
    5) exit 0 ;;
    *) echo "Invalid choice";;
  esac
done