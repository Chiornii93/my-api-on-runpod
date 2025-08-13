#!/usr/bin/env bash

# --- ADDED: Symbolic links to folders from the RunPod volume --- #

# Replacing models with those from the volume
rm -rf /comfyui/models && ln -s /runpod-volume/ComfyUI/models /comfyui/models

# Replacing custom nodes
rm -rf /comfyui/custom_nodes && ln -s /runpod-volume/ComfyUI/custom_nodes /comfyui/custom_nodes

# Replacing input (to be able to see mask.png and face.png)
rm -rf /comfyui/input && ln -s /runpod-volume/ComfyUI/input /comfyui/input

# --- END OF ADDITION --- #

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Serve the API and don't shutdown the container
if [ "$SERVE_API_LOCALLY" == "true" ]; then
    echo "runpod-worker-comfy: Starting ComfyUI"
    python3 /comfyui/main.py --disable-auto-launch --disable-metadata --listen &

    echo "runpod-worker-comfy: Starting RunPod Handler"
    python3 -u /rp_handler.py --rp_serve_api --rp_api_host=0.0.0.0
else
    echo "runpod-worker-comfy: Starting ComfyUI"
    python3 /comfyui/main.py --disable-auto-launch --disable-metadata &

    echo "runpod-worker-comfy: Starting RunPod Handler"
    python3 -u /rp_handler.py
fi
