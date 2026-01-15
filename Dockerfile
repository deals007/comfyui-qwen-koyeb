# ComfyUI on Koyeb GPU + Qwen Rapid-AIO v2 preloaded (multi-image-ready)

FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HF_HOME=/tmp/hf \
    PORT=8000

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python + Torch (new enough for Qwen attention features)
RUN python3 -m pip install --upgrade pip
RUN pip install --index-url https://download.pytorch.org/whl/cu121 \
    torch==2.5.1 torchvision==0.20.1

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI
WORKDIR /app/ComfyUI

# Install ComfyUI requirements
RUN pip install -r requirements.txt

# Extra common deps
RUN pip install accelerate safetensors huggingface-hub pillow einops

# (Optional) remove audio nodes that throw torchaudio import errors (not needed for image workflows)
RUN rm -f /app/ComfyUI/comfy_extras/nodes_audio.py \
         /app/ComfyUI/comfy_extras/nodes_lt_audio.py \
         /app/ComfyUI/comfy_extras/nodes_audio_encoder.py || true

# Patch Qwen nodes for Rapid-AIO (better scaling + multi-image behavior)
RUN wget -O /app/ComfyUI/comfy_extras/nodes_qwen.py \
  "https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/fixed-textencode-node/nodes_qwen.v2.py"

# Download Qwen Rapid-AIO v2 checkpoint into ComfyUI checkpoints folder
RUN mkdir -p /app/ComfyUI/models/checkpoints && \
    wget -O "/app/ComfyUI/models/checkpoints/Qwen-Rapid-AIO-v2.safetensors" \
    "https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/Qwen-Rapid-AIO-v2.safetensors?download=true"

# Start ComfyUI
EXPOSE 8000
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8000"]