#!/usr/bin/env bash
set -e

cd /app/ComfyUI

echo "Starting ComfyUI on 0.0.0.0:${PORT}"
python3 main.py --listen 0.0.0.0 --port ${PORT}