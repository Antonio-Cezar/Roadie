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

echo "=== Done! ==="
echo
echo "Run your app like this:"
echo "  source .venv/bin/activate"
echo "  python3 main.py"
echo
echo "Optional: to test QML quickly, you can use (from qt6-declarative-dev-tools):"
echo "  qml6scene yourfile.qml"
