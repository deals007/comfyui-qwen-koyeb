FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HF_HOME=/tmp/hf \
    PORT=8000

RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN python3 -m pip install --upgrade pip

# PyTorch (CUDA 12.1)
RUN pip install --index-url https://download.pytorch.org/whl/cu121 \
    torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1

# ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI
WORKDIR /app/ComfyUI
RUN pip install -r requirements.txt
RUN pip install accelerate safetensors huggingface-hub pillow einops

# Patch Qwen nodes (from Rapid-AIO HF repo)
RUN wget -O /app/ComfyUI/comfy_extras/nodes_qwen.py \
  "https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/fixed-textencode-node/nodes_qwen.v2.py"

# -----------------------------
# Install required custom nodes
# -----------------------------
WORKDIR /app/ComfyUI/custom_nodes

# rgthree (Anything Everywhere3 + Image Comparer)
RUN git clone https://github.com/rgthree/rgthree-comfy.git

# Ultimate SD Upscale (clone recursive is recommended)
RUN git clone --recursive https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git

# ComfyUI-Easy-Use (easy cleanGpuUsed etc.)
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git

# Install any per-node requirements if present (won't fail build if none)
RUN pip install -r /app/ComfyUI/custom_nodes/rgthree-comfy/requirements.txt || true
RUN pip install -r /app/ComfyUI/custom_nodes/ComfyUI_UltimateSDUpscale/requirements.txt || true
RUN pip install -r /app/ComfyUI/custom_nodes/ComfyUI-Easy-Use/requirements.txt || true

WORKDIR /app/ComfyUI

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8000
CMD ["/app/start.sh"]
