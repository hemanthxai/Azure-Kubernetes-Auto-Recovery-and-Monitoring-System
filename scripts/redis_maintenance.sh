#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-prod}"
REDIS_NAME="${REDIS_NAME:-aks-cache}"

az account show >/dev/null 2>&1 || {
  echo "Azure CLI is not authenticated. Please run 'az login' first."
  exit 1
}

echo "Flushing Azure Cache for Redis: $REDIS_NAME"
az redis flush --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP" --yes

echo "Restarting Azure Cache for Redis: $REDIS_NAME"
az redis restart --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP"

echo "Redis maintenance completed."
