#!/usr/bin/env bash
set -euo pipefail

echo "=== Removing Roadie dependencies ==="

# -------- Remove virtual environment --------
if [ -d ".venv" ]; then
  echo "Removing .venv..."
  rm -rf .venv
else
  echo ".venv not found (already removed)"
fi

# -------- Remove apt packages installed by installer --------
echo "Removing system packages..."

# Cleanup unused deps
sudo apt autoremove -y

echo "=== Done ==="
echo "Roadie dependencies removed."