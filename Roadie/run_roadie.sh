#!/bin/bash
set -e
pkill -f main.py 2>/dev/null
cd "$(dirname "$0")"
python3 main.py
