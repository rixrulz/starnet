#!/usr/bin/env bash
ELEMENTS="/Volumes/Elements SE"
REPO="$ELEMENTS/starnet"
DATA="$ELEMENTS/starnet-data"

mkdir -p "$DATA/workspaces"
pkill -f "sidecar/index.js" 2>/dev/null || true
sleep 1

STARNET_WORKSPACES="$DATA/workspaces" \
OLLAMA_BASE_URL="http://localhost:11434/v1" \
SKYNET_OLLAMA_MAX_TOKENS=4096 \
PORT=8787 \
  nohup node "$REPO/sidecar/index.js" > /tmp/starnet.log 2>&1 &

echo $! > /tmp/starnet.pid
sleep 3
curl -s http://localhost:8787/api/health && echo "" || echo "Starting..."
echo "Dashboard: http://localhost:8787"
echo "Phone:     http://192.168.50.90:8787"
echo "Logs:      tail -f /tmp/starnet.log"
