#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-default}"

echo "Checking for unhealthy pods in namespace: $NAMESPACE"

pods=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | awk '$3 != "Running" {print $1}')

if [[ -z "$pods" ]]; then
  echo "No unhealthy pods found."
  exit 0
fi

for pod in $pods; do
  echo "Deleting pod $NAMESPACE/$pod to trigger self-healing"
  kubectl delete pod "$pod" -n "$NAMESPACE" --grace-period=30 || true
  sleep 2
done

echo "Recovery process completed."
