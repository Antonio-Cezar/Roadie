#!/bin/bash
set -e

# Kill any running instance of the app
pkill -f main.py 2>/dev/null || true

# Go to script directory
cd "$(dirname "$0")"

# Run the app
python3 main.py
