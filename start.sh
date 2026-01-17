#!/usr/bin/env bash
set -e

: "${PORT:=8000}"
: "${HF_HOME:=/tmp/hf}"

# Default SFW checkpoint (Rapid-AIO v2)
: "${MODEL_URL:=https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/Qwen-Rapid-AIO-v2.safetensors?download=true}"
: "${MODEL_FILE:=Qwen-Rapid-AIO-v2.safetensors}"

MODEL_DIR="/app/ComfyUI/models/checkpoints"
MODEL_PATH="${MODEL_DIR}/${MODEL_FILE}"

mkdir -p "${MODEL_DIR}"
mkdir -p "${HF_HOME}"

if [ ! -f "${MODEL_PATH}" ]; then
  echo "Downloading checkpoint to ${MODEL_PATH} ..."
  wget -O "${MODEL_PATH}.tmp" "${MODEL_URL}"
  mv "${MODEL_PATH}.tmp" "${MODEL_PATH}"
  echo "Download complete."
else
  echo "Checkpoint already present: ${MODEL_PATH}"
fi

cd /app/ComfyUI
echo "Starting ComfyUI on 0.0.0.0:${PORT}"
python3 main.py --listen 0.0.0.0 --port "${PORT}"
