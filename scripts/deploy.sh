#!/usr/bin/env bash
set -euo pipefail

APP_NAME="devops-pucrs-api"
IMAGE_TAG="${1:-latest}"
PORT="${PORT:-5000}"
AWS_REGION="${AWS_REGION:-us-east-1}"
ECR_REGISTRY="${ECR_REGISTRY:-048839920083.dkr.ecr.us-east-1.amazonaws.com}"
ECR_REPO="${ECR_REPO:-devops-pucrs-fase1-repo}"

echo "============================================================"
echo "[CD Deploy] Iniciando entrega contínua do serviço: ${APP_NAME}:${IMAGE_TAG}"
echo "============================================================"

# 1. Preservar versão anterior para eventual Rollback (Blue-Green / Imutabilidade)
if docker image inspect "${APP_NAME}:latest" >/dev/null 2>&1; then
  echo "[CD Deploy] Salvando imagem estável anterior como ${APP_NAME}:previous..."
  docker tag "${APP_NAME}:latest" "${APP_NAME}:previous" || true
fi

# 2. Build da nova versão da imagem Docker
echo "[CD Deploy] Construindo imagem Docker ${APP_NAME}:${IMAGE_TAG}..."
docker build -t "${APP_NAME}:${IMAGE_TAG}" -t "${APP_NAME}:latest" .

# 3. Publicação opcional no Amazon ECR (se credenciais AWS estiverem configuradas)
if [ -n "${AWS_ACCESS_KEY_ID:-}" ] && command -v aws >/dev/null 2>&1; then
  echo "[CD Deploy] Credenciais AWS detectadas. Autenticando no Amazon ECR (${ECR_REGISTRY})..."
  if aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}" 2>/dev/null; then
    docker tag "${APP_NAME}:${IMAGE_TAG}" "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
    docker tag "${APP_NAME}:latest" "${ECR_REGISTRY}/${ECR_REPO}:latest"
    docker push "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}" || true
    docker push "${ECR_REGISTRY}/${ECR_REPO}:latest" || true
    echo "[CD Deploy] Imagem publicada com sucesso no Amazon ECR."
  else
    echo "[CD Deploy] Aviso: Sessão AWS Academy inativa ou sem permissão ECR. Seguindo com deploy local em container."
  fi
fi

# 4. Substituição controlada do container (Rolling / Blue-Green local)
if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
  echo "[CD Deploy] Removendo instância anterior do container ${APP_NAME}..."
  docker rm -f "${APP_NAME}" >/dev/null 2>&1 || true
fi

echo "[CD Deploy] Inicializando novo container orquestrado na porta ${PORT}..."
docker run -d \
  --name "${APP_NAME}" \
  --restart unless-stopped \
  -p "${PORT}:5000" \
  "${APP_NAME}:${IMAGE_TAG}"

# 5. Smoke Test Pós-Deploy e Monitoramento de Saúde
echo "[CD Deploy] Aguardando inicialização para Smoke Test..."
sleep 4

if curl --silent --fail "http://localhost:${PORT}/health" >/dev/null && \
   curl --silent --fail "http://localhost:${PORT}/metrics" >/dev/null && \
   curl --silent --fail "http://localhost:${PORT}/calcular/10/25" >/dev/null; then
  echo "[CD Deploy] Smoke Test APROVADO! Endpoints /health, /metrics e /calcular operacionais."
  curl --silent "http://localhost:${PORT}/health"
  echo ""
  curl --silent "http://localhost:${PORT}/metrics"
  echo ""
else
  echo "[CD Deploy] ERRO: Falha no Smoke Test pós-deploy! Acionando Rollback automático..."
  bash "$(dirname "$0")/rollback.sh"
  exit 1
fi

echo "============================================================"
echo "[CD Deploy] Entrega Contínua concluída com sucesso!"
echo "============================================================"
