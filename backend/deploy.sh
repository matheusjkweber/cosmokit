#!/bin/bash
# CosmoKit backend deploy — ACR build + Azure Container Apps update.
#
# The backend is a small Go service that //go:embed's internal/content/data.json
# and serves it over /v1/. It runs on Azure Container Apps (scale-to-zero) behind
# api.usecosmoskittool.com — NOT App Service anymore. To ship a content/code change:
# edit the files, then run this script.
#
#   bash backend/deploy.sh
#
# Requires: `az login` (Azure CLI authenticated to the subscription that owns RG
# `cosmokit`). Builds the image in ACR (no local Docker needed) and rolls the
# container app to it. Re-runnable any time.
set -euo pipefail

ACR="cosmokitapiacr"                 # Azure Container Registry
IMAGE="cosmokit-api"                 # repository
RG="cosmokit"                        # resource group
APP="cosmokit-api"                   # container app

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

# Timestamped, immutable tag (plus :latest) so each deploy is its own revision.
TAG="$(date +%Y%m%d-%H%M%S)"
FQTAG="${ACR}.azurecr.io/${IMAGE}:${TAG}"

echo "▸ Building ${IMAGE}:${TAG} in ACR ${ACR} (context: ${ROOT_DIR})…"
az acr build --registry "$ACR" --image "${IMAGE}:${TAG}" --image "${IMAGE}:latest" .

echo "▸ Rolling container app ${APP} (rg ${RG}) to ${FQTAG}…"
# NOTE: never pipe `az containerapp` through `2>&1` into a captured var — the
# extension prints a WARNING to stderr that pollutes the value.
az containerapp update --name "$APP" --resource-group "$RG" --image "$FQTAG" \
  --query "properties.latestRevisionName" --output tsv

echo "▸ Verifying https://api.usecosmoskittool.com/v1/helper/latest …"
curl -s --retry 5 --retry-delay 2 --retry-all-errors \
  https://api.usecosmoskittool.com/v1/helper/latest || true
echo

echo "✓ Deployed ${IMAGE}:${TAG}"
