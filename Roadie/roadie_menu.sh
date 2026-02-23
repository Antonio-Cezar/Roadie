#!/usr/bin/env bash
set -euo pipefail

# -------- Dependency checks --------
check_cmd() { command -v "$1" >/dev/null 2>&1; }
check_pkg() { dpkg -s "$1" >/dev/null 2>&1; }

check_pyside() {
  # Prefer venv python (since PySide6 is installed there)
  if [ -x ".venv/bin/python3" ]; then
    .venv/bin/python3 -c "import PySide6" >/dev/null 2>&1
  elif [ -x ".venv/bin/python" ]; then
    .venv/bin/python -c "import PySide6" >/dev/null 2>&1
  else
    return 1
  fi
}

dep_ready() {
  check_cmd python3 &&
  check_cmd pip3 &&
  check_pkg python3-venv &&
  check_cmd nmcli &&
  check_pyside
}

while true; do
  clear

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

  read -r -p "Select an option: " choice

  case "$choice" in
    1)
      chmod +x install_dependencies.sh
      ./install_dependencies.sh
      ;;
    2)
      ;;
    3)
      ;;
    4)
      ;;
    x|X)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      sleep 1
      ;;
  esac
done