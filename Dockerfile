FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/tmp/hf \
    PORT=8188

RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN python3 -m pip install --upgrade pip

# Torch new enough for SDPA features used by Qwen/Comfy
RUN pip install --index-url https://download.pytorch.org/whl/cu121 \
    torch==2.5.1 torchvision==0.20.1

# ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI
RUN pip install -r requirements.txt

# extra common deps
RUN pip install accelerate safetensors huggingface-hub pillow einops

# Add start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8188
CMD ["/app/start.sh"]
