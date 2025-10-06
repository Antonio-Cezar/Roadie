#!/bin/bash
set -e

echo "=== Installing Python and Qt dependencies for PySide6 QML app ==="

# Update package list
sudo apt update

# Install Python and Pip (if not installed)
sudo apt install -y python3 python3-pip python3-venv

# Install PySide6 (Qt for Python)
pip install --upgrade pip
pip install PySide6

# Install system-level Qt runtime modules (ensures QML and Window modules work)
sudo apt install -y \
    qml6-module-qtquick \
    qml6-module-qtquick-window \
    qml6-module-qtqml \
    qt6-base-dev

# Optional: tools for debugging QML or running GUI apps
sudo apt install -y qt6-declarative-dev-tools

echo "=== All dependencies installed successfully! ==="
echo
echo "You can now run your app with:"
echo "  python3 main.py"
