#!/usr/bin/env bash
set -e

MODEL_URL="https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/Qwen-Rapid-AIO-v2.safetensors?download=true"
MODEL_PATH="/app/ComfyUI/models/checkpoints/Qwen-Rapid-AIO-v2.safetensors"

mkdir -p /app/ComfyUI/models/checkpoints
mkdir -p "${HF_HOME}"

# Download model only if missing
if [ ! -f "${MODEL_PATH}" ]; then
  echo "Downloading Rapid-AIO checkpoint to ${MODEL_PATH} ..."
  wget -O "${MODEL_PATH}.tmp" "${MODEL_URL}"
  mv "${MODEL_PATH}.tmp" "${MODEL_PATH}"
  echo "Download complete."
else
  echo "Model already present: ${MODEL_PATH}"
fi

cd /app/ComfyUI
echo "Starting ComfyUI on 0.0.0.0:${PORT}"
python3 main.py --listen 0.0.0.0 --port "${PORT}"
