#!/bin/bash
set -euo pipefail

echo "=== Installing Python and Qt dependencies for a PySide6 + QML app (Ubuntu) ==="

# Update package list
sudo apt update

# Install Python and venv
sudo apt install -y python3 python3-pip python3-venv

# System-level Qt 6 runtime & dev packages (QML + Quick + Controls2)
sudo apt install -y \
  qt6-base-dev \
  qt6-declarative-dev \
  qt6-declarative-dev-tools \
  qml6-module-qtqml \
  qml6-module-qtquick \
  qml6-module-qtquick-window \
  qml6-module-qtquick-controls2 \
  qml6-module-qtquick-templates2

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
echo
echo "Run your menu:"
echo "  ./roadie_menu.sh"
echo
echo "Run your app:"
echo "  source .venv/bin/activate && python3 main.py"
echo
echo "Optional QML test:"
echo "  qml6scene main.qml"