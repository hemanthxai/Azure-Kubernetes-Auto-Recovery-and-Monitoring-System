#!/usr/bin/env bash
set -euo pipefail

DD_API_KEY="${DD_API_KEY:-}"
DD_APP_KEY="${DD_APP_KEY:-}"
CLUSTER_NAME="${CLUSTER_NAME:-aks-cluster}"

if [[ -z "$DD_API_KEY" || -z "$DD_APP_KEY" ]]; then
  echo "Set DD_API_KEY and DD_APP_KEY before running this script."
  exit 1
fi

NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
READY_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 == "Ready" {count++} END {print count + 0}')
TIMESTAMP=$(date +%s)

curl -sS -X POST "https://api.datadoghq.com/api/v1/series" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<JSON
{
  "series": [
    {
      "metric": "aks.cluster.health",
      "points": [[${TIMESTAMP}, ${READY_COUNT}]],
      "type": "gauge",
      "host": "${CLUSTER_NAME}",
      "tags": ["env:prod", "service:aks"]
    },
    {
      "metric": "aks.node.total",
      "points": [[${TIMESTAMP}, ${NODE_COUNT}]],
      "type": "gauge",
      "host": "${CLUSTER_NAME}",
      "tags": ["env:prod", "service:aks"]
    }
  ]
}
JSON

echo "Cluster health metrics were submitted to Datadog."
