#!/usr/bin/env bash
set -euo pipefail

APP_NAME="devops-pucrs-api"
PORT="${PORT:-5000}"

echo "============================================================"
echo "[CD Rollback] Iniciando procedimento de reversão (Rollback)..."
echo "============================================================"

if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
  docker rm -f "${APP_NAME}" >/dev/null 2>&1 || true
fi

if docker image inspect "${APP_NAME}:previous" >/dev/null 2>&1; then
  echo "[CD Rollback] Restaurando container a partir da imagem estável ${APP_NAME}:previous..."
  docker tag "${APP_NAME}:previous" "${APP_NAME}:latest"
  docker run -d \
    --name "${APP_NAME}" \
    --restart unless-stopped \
    -p "${PORT}:5000" \
    "${APP_NAME}:previous"
  sleep 3
  curl --silent --fail "http://localhost:${PORT}/health"
  echo ""
  echo "[CD Rollback] Rollback concluído com sucesso! Serviço restaurado."
else
  echo "[CD Rollback] Nenhuma imagem anterior (${APP_NAME}:previous) encontrada para restaurar."
  exit 1
fi
