#!/usr/bin/env bash
set -euo pipefail

echo "---- START.SH DEBUG ----"
echo "PORT=${PORT:-8000}"
echo "HF_HOME=${HF_HOME:-/tmp/hf}"
echo "MODEL_URL(before)=${MODEL_URL:-<unset>}"
echo "MODEL_FILE(before)=${MODEL_FILE:-<unset>}"
echo "------------------------"

: "${PORT:=8000}"
: "${HF_HOME:=/tmp/hf}"

# FORCE these values (do NOT allow env override)
MODEL_URL="https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/v7/Qwen-Rapid-AIO-NSFW-v7.1.safetensors?download=true"
MODEL_FILE="Qwen-Rapid-AIO-NSFW-v7.1.safetensors"

MODEL_DIR="/app/ComfyUI/models/checkpoints"
MODEL_PATH="${MODEL_DIR}/${MODEL_FILE}"

mkdir -p "${MODEL_DIR}" "${HF_HOME}"

echo "Using MODEL_URL=${MODEL_URL}"
echo "Using MODEL_FILE=${MODEL_FILE}"
echo "Target path: ${MODEL_PATH}"

# Delete any wrong model to avoid confusion
if [ -f "${MODEL_DIR}/Qwen-Rapid-AIO-v2.safetensors" ]; then
  echo "Removing old checkpoint: ${MODEL_DIR}/Qwen-Rapid-AIO-v2.safetensors"
  rm -f "${MODEL_DIR}/Qwen-Rapid-AIO-v2.safetensors"
fi

if [ ! -f "${MODEL_PATH}" ]; then
  echo "Downloading checkpoint to ${MODEL_PATH} ..."
  wget -O "${MODEL_PATH}.tmp" "${MODEL_URL}"
  mv "${MODEL_PATH}.tmp" "${MODEL_PATH}"
  echo "Download complete."
else
  echo "Checkpoint already present: ${MODEL_PATH}"
fi

echo "Checkpoints now:"
ls -lh "${MODEL_DIR}"

cd /app/ComfyUI
echo "Starting ComfyUI on 0.0.0.0:${PORT}"
python3 main.py --listen 0.0.0.0 --port "${PORT}"
