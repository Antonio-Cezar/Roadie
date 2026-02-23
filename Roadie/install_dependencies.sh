#!/bin/bash
set -euo pipefail

echo "=== Installing dependencies for PySide6 + QML (Ubuntu) ==="

sudo apt update

# Required system deps
sudo apt install -y python3 python3-pip python3-venv network-manager \
  libxcb-cursor0 libxkbcommon-x11-0

# Optional: Qt tools (qml6scene) - safe to keep
sudo apt install -y qt6-declarative-dev-tools || true

echo "=== Creating virtual environment and installing PySide6 ==="
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install PySide6
deactivate || true

echo "=== Making project scripts executable ==="
chmod +x install_dependencies.sh 2>/dev/null || true
chmod +x roadie_menu.sh 2>/dev/null || true
chmod +x Roodiesh 2>/dev/null || true

echo "=== Done! ==="
echo "Run menu: ./roadie_menu.sh"
echo "Run app : source .venv/bin/activate && python3 main.py"