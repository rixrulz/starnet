FROM node:22-slim
WORKDIR /app

# Copy only what the sidecar needs — no Tauri/desktop
COPY sidecar/ ./sidecar/
COPY frontend/ ./frontend/
COPY shared/ ./shared/
COPY package.json ./

# Sidecar has zero npm runtime deps — no npm install needed
ENV PORT=8787
ENV STARNET_WORKSPACES=/data/workspaces
ENV OLLAMA_BASE_URL=http://localhost:11434/v1

RUN mkdir -p /data/workspaces

EXPOSE 8787
CMD ["node", "sidecar/index.js"]
