#!/usr/bin/env bash
set -euo pipefail

# -------- Dependency checks --------
check_cmd() { command -v "$1" >/dev/null 2>&1; }
check_pkg() { dpkg -s "$1" >/dev/null 2>&1; }
check_pip() { python3 -c "import $1" >/dev/null 2>&1; }

dep_ready() {
  check_cmd python3 &&
  check_cmd pip3 &&
  check_pkg python3-venv &&
  check_pkg qt6-base-dev &&
  check_pkg qml6-module-qtquick &&
  check_pip PySide6
}

while true; do

  if dep_ready; then
    STATUS="READY"
  else
    STATUS="NOT READY"
  fi

  echo "=========================="
  echo "   RoadIe MENU  [$STATUS]"
  echo "=========================="
  echo "1) Install dependecies (IF STATUS: NOT READY)"
  echo "2) ..."
  echo "3) ..."
  echo "4) ..."
  echo "x) Exit"
  echo

  read -r -p "Select an option " choice

  case "$choice" in
    1)
      ;;
    2)
      ;;
    3)
      ;;
    4)
      ;;
    x)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      sleep 1
      ;;
  esac
done