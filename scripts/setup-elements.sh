#!/usr/bin/env bash
# Run this once on your Mac to set up StarNet on Elements SE
set -euo pipefail

ELEMENTS="/Volumes/Elements SE"
REPO="$ELEMENTS/starnet"
DATA="$ELEMENTS/starnet-data"

echo "🌟 StarNet setup on Elements SE"
echo ""

# Check Elements SE is mounted
if [ ! -d "$ELEMENTS" ]; then
  echo "❌ Elements SE not mounted. Plug in the drive and try again."
  exit 1
fi

# Clear old copy if exists, fresh clone
echo "Cloning StarNet to Elements SE..."
rm -rf "$REPO"
git clone https://github.com/rixrulz/starnet.git \
  --branch feat/harness-backend --depth 1 "$REPO"
echo "✓ Cloned to $REPO"

# Create data dir on Elements SE (keeps all agent data off internal SSD)
mkdir -p "$DATA/workspaces"
echo "✓ Data dir: $DATA"

# Install launchd so StarNet starts on every boot
PLIST="$HOME/Library/LaunchAgents/com.starnet.sidecar.plist"
cp "$REPO/scripts/com.starnet.sidecar.plist" "$PLIST"

# Fix node path for this machine
NODE_PATH=$(which node || echo "/usr/local/bin/node")
sed -i '' "s|/usr/local/bin/node|$NODE_PATH|g" "$PLIST"

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "✓ LaunchAgent installed — StarNet will start on every boot"

sleep 3

# Verify
if curl -s http://localhost:8787/api/health | grep -q "ok\|status"; then
  echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║  StarNet is LIVE                                     ║"
  echo "╠══════════════════════════════════════════════════════╣"
  echo "║  Dashboard: http://localhost:8787                    ║"
  echo "║  Phone:     http://192.168.50.90:8787               ║"
  echo "║  Data:      $ELEMENTS/starnet-data      ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo ""
  echo "In the browser: pick OLLAMA as provider, llama3.1:8b is ready"
else
  echo ""
  echo "Starting manually..."
  STARNET_WORKSPACES="$DATA/workspaces" \
  OLLAMA_BASE_URL="http://localhost:11434/v1" \
  PORT=8787 node "$REPO/sidecar/index.js" &
  sleep 3
  echo "Open: http://localhost:8787"
fi
