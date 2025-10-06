#!/usr/bin/env bash
# run_roadie.sh — setup and run the Roadie GUI (PySide6 + QML)

set -euo pipefail

# ---- Config (change if your paths differ) ----
PROJECT_NAME="Roadie"
ENTRY_PY="/main.py"   # your main Python launcher
VENV_DIR=".venv"            # local virtual env directory
PYTHON_BIN="${PYTHON_BIN:-python3}"
PIP_OPTS="${PIP_OPTS:-}"
# QT platform: xcb works on Ubuntu/X11; set to wayland/eglfs if you know your stack
QT_QPA_PLATFORM_DEFAULT="${QT_QPA_PLATFORM_DEFAULT:-xcb}"

# ---- Helpers ----
die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }

# Move to script’s directory (repo root)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Basic checks
[[ -f "$ENTRY_PY" ]] || die "Could not find entry script at '$ENTRY_PY'. Adjust ENTRY_PY in this script."

# Optional flags
DO_CLEAN=0
DO_ONLY_SETUP=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean) DO_CLEAN=1; shift;;
    --setup) DO_ONLY_SETUP=1; shift;;
    --help|-h)
      cat <<EOF
Usage: ./run_roadie.sh [--clean] [--setup]
  --clean   Remove existing virtual env and reinstall dependencies
  --setup   Only set up environment and exit (don’t run the app)

Environment variables:
  PYTHON_BIN                 Python interpreter to use (default: python3)
  PIP_OPTS                   Extra pip flags (e.g. "-i https://pypi.org/simple")
  QT_QPA_PLATFORM_DEFAULT    Default Qt platform plugin (xcb/wayland/eglfs). Default: xcb
EOF
      exit 0
      ;;
    *) die "Unknown option: $1";;
  </case>
done

# Clean venv if requested
if [[ $DO_CLEAN -eq 1 && -d "$VENV_DIR" ]]; then
  info "Removing existing virtual environment: $VENV_DIR"
  rm -rf "$VENV_DIR"
fi

# Ensure Python exists
command -v "$PYTHON_BIN" >/dev/null 2>&1 || die "Python not found: $PYTHON_BIN"

# Create venv if missing
if [[ ! -d "$VENV_DIR" ]]; then
  info "Creating virtual environment: $VENV_DIR"
  "$PYTHON_BIN" -m venv "$VENV_DIR" || die "Failed to create venv"
fi

# Activate venv
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# Upgrade pip
info "Upgrading pip..."
python -m pip install --upgrade pip wheel ${PIP_OPTS:-}

# Install dependencies
if [[ -f "requirements.txt" ]]; then
  info "Installing from requirements.txt"
  pip install -r requirements.txt ${PIP_OPTS:-}
else
  info "Installing PySide6 (no requirements.txt found)…"
  pip install PySide6 ${PIP_OPTS:-}
fi

# Quick import test
python - <<'PY' || { deactivate; die "PySide6 import test failed."; }
import PySide6, PySide6.QtGui, PySide6.QtQml
print("PySide6 import OK")
PY
ok "Dependencies ready."

if [[ $DO_ONLY_SETUP -eq 1 ]]; then
  ok "Setup completed. Not launching app because --setup was specified."
  exit 0
fi

# Qt platform (allow user override)
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-$QT_QPA_PLATFORM_DEFAULT}"

# Optional tip for common plugin issue
if [[ "${QT_QPA_PLATFORM}" == "xcb" ]]; then
  warn "If you hit 'could not load Qt platform plugin xcb', install X11 deps:
  sudo apt update && sudo apt install -y libxkbcommon-x11-0 libxcb-xinerama0 libxcb-icccm4 \\
      libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-util1 libxcb-xfixes0"
fi

# Launch
info "Launching ${PROJECT_NAME} (QT_QPA_PLATFORM=${QT_QPA_PLATFORM})..."
exec python "$ENTRY_PY"
