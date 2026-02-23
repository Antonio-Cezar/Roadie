#!/usr/bin/env bash
set -euo pipefail

# -------- Dependency checks --------
check_cmd() { command -v "$1" >/dev/null 2>&1; }
check_pkg() { dpkg -s "$1" >/dev/null 2>&1; }
check_pip() { python3 -c "import $1" >/dev/null 2>&1; }

dep_status() {
  PY=$(check_cmd python3 && echo "OK" || echo "MISSING")
  PIP=$(check_cmd pip3 && echo "OK" || echo "MISSING")
  VENV=$(check_pkg python3-venv && echo "OK" || echo "MISSING")

  QT=$(check_pkg qt6-base-dev && echo "OK" || echo "MISSING")
  QML=$(check_pkg qml6-module-qtquick && echo "OK" || echo "MISSING")

  PYSIDE=$(check_pip PySide6 && echo "OK" || echo "MISSING")

  echo "Deps: Python[$PY] Pip[$PIP] Venv[$VENV] Qt6[$QT] QML[$QML] PySide6[$PYSIDE]"
}

pause() { read -r -p "Press Enter to continue..." _; }

while true; do
  echo "=========================="
  echo "       RoadIe MENU         "
  echo "=========================="
  echo "1) ..."
  echo "2) ..."
  echo "3) ..."
  echo "4) ..."
  echo "5) Exit"
  echo

  read -r -p "Select an option [1-5]: " choice

  case "$choice" in
    1)
      ;;
    2)
      ;;
    3)
      ;;
    4)
      ;;
    5)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      sleep 1
      ;;
  esac
done