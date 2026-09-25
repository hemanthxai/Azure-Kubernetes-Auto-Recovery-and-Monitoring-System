#!/usr/bin/env bash
set -euo pipefail

NODE_LIST=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

if [[ -z "$NODE_LIST" ]]; then
  echo "No Kubernetes nodes were found."
  exit 1
fi

for node in $NODE_LIST; do
  memory=$(kubectl get node "$node" -o jsonpath='{.status.conditions[?(@.type=="MemoryPressure")].status}')
  disk=$(kubectl get node "$node" -o jsonpath='{.status.conditions[?(@.type=="DiskPressure")].status}')
  ready=$(kubectl get node "$node" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')

  echo "Node: $node"
  echo "  MemoryPressure: ${memory:-Unknown}"
  echo "  DiskPressure: ${disk:-Unknown}"
  echo "  Ready: ${ready:-Unknown}"

  if [[ "$memory" == "True" || "$disk" == "True" || "$ready" != "True" ]]; then
    echo "  WARNING: node $node is unhealthy or under pressure."
  fi

done

echo "Checking recent Kubernetes scheduling events..."
kubectl get events --all-namespaces --sort-by=.lastTimestamp | grep -Ei "FailedScheduling|failed scheduling|out of memory|disk pressure|memory pressure" || echo "No scheduling or pressure issues were detected."
