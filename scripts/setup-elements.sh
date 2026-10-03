#!/usr/bin/env bash
set -euo pipefail
ELEMENTS="/Volumes/Elements SE"
REPO="$ELEMENTS/starnet"
DATA="$ELEMENTS/starnet-data"

echo "🌟 StarNet — Elements SE setup"
[ ! -d "$ELEMENTS" ] && echo "❌ Elements SE not mounted" && exit 1

echo "Cloning StarNet..."
rm -rf "$REPO"
git clone https://github.com/rixrulz/starnet.git --branch feat/harness-backend --depth 1 "$REPO"
cd "$REPO"

echo "Installing dependencies..."
npm ci 2>&1 | tail -3
echo "✓ Dependencies ready"

mkdir -p "$DATA/workspaces"

# Install launchd
PLIST="$HOME/Library/LaunchAgents/com.starnet.sidecar.plist"
cp "$REPO/scripts/com.starnet.sidecar.plist" "$PLIST"
NODE_PATH=$(which node || echo "/opt/homebrew/bin/node")
sed -i '' "s|/opt/homebrew/bin/node|$NODE_PATH|g" "$PLIST"
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "✓ Starts on every boot"

sleep 4
IP=$(ipconfig getifaddr en0 2>/dev/null || echo "192.168.50.90")
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  StarNet LIVE                            ║"
echo "╠══════════════════════════════════════════╣"
echo "║  Mac:   http://localhost:8787            ║"
echo "║  Phone: http://$IP:8787            ║"
echo "╚══════════════════════════════════════════╝"
echo "Pick OLLAMA → llama3.1:8b in the browser"
