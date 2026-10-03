#!/usr/bin/env bash
# Run once on your Mac to set up StarNet on Elements SE
set -euo pipefail

ELEMENTS="/Volumes/Elements SE"
REPO="$ELEMENTS/starnet"
DATA="$ELEMENTS/starnet-data"

echo "🌟 StarNet setup on Elements SE"
echo ""

if [ ! -d "$ELEMENTS" ]; then
  echo "❌ Elements SE not mounted."
  exit 1
fi

# Clone to Elements SE
echo "Cloning StarNet to Elements SE..."
rm -rf "$REPO"
git clone https://github.com/rixrulz/starnet.git \
  --branch feat/harness-backend --depth 1 "$REPO"
cd "$REPO"
echo "✓ Cloned"

# Install npm deps (node-pty builds natively on Mac — needs Xcode tools)
echo "Installing dependencies..."
npm ci 2>&1 | tail -3
echo "✓ Dependencies installed"

# Data on Elements SE
mkdir -p "$DATA/workspaces"
echo "✓ Data dir: $DATA"

# Install launchd boot service
PLIST="$HOME/Library/LaunchAgents/com.starnet.sidecar.plist"
cp "$REPO/scripts/com.starnet.sidecar.plist" "$PLIST"
NODE_PATH=$(which node)
sed -i '' "s|/usr/local/bin/node|$NODE_PATH|g" "$PLIST"
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "✓ LaunchAgent installed — starts on every boot"

sleep 4

if curl -s http://localhost:8787/api/health 2>/dev/null | grep -q "."; then
  LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "192.168.50.90")
  echo ""
  echo "╔════════════════════════════════════════════╗"
  echo "║  StarNet is LIVE                           ║"
  echo "╠════════════════════════════════════════════╣"
  echo "║  Mac:   http://localhost:8787              ║"
  echo "║  Phone: http://$LOCAL_IP:8787          ║"
  echo "║  Data:  $DATA  ║"
  echo "╚════════════════════════════════════════════╝"
  echo ""
  echo "Pick OLLAMA as provider → llama3.1:8b is ready"
else
  echo "Starting manually..."
  STARNET_WORKSPACES="$DATA/workspaces" \
  OLLAMA_BASE_URL="http://localhost:11434/v1" \
  PORT=8787 nohup node "$REPO/sidecar/index.js" > /tmp/starnet.log 2>&1 &
  sleep 3
  echo "Open: http://localhost:8787"
  echo "Phone: http://192.168.50.90:8787"
fi
