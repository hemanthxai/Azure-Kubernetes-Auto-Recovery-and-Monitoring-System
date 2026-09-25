# AKS Auto-Recovery & Monitoring System

This project is a simple but realistic automation framework for Azure Kubernetes Service (AKS). It demonstrates how to:

- automatically recover failed Kubernetes pods
- monitor node health for memory pressure, disk pressure, and scheduling failure
- send cluster health metrics to Datadog
- automate Azure Cache for Redis maintenance tasks
- reduce manual operations and support self-healing infrastructure

## Project structure

```text
.
├── README.md                      # This file
├── BASICS.md                      # Quick "what does this do" guide
├── Makefile                       # Commands to run scripts
├── azure-pipelines.yml            # Azure DevOps CI/CD pipeline
├── k8s/
│   └── pod-recovery-cronjob.yaml # Kubernetes CronJob for automation
├── scripts/
│   ├── aks_pod_recovery.sh        # Restart broken pods
│   ├── node_health_check.sh       # Check node health
│   ├── datadog_k8s_monitoring.sh  # Send metrics to Datadog
│   └── redis_maintenance.sh       # Flush and restart Redis
└── docs/
    ├── architecture.md             # Detailed technical explanation
    └── AZURE_DEVOPS_SETUP.md       # How to set up the DevOps pipeline
```

## Core components

### 1. Pod recovery automation
A Kubernetes `CronJob` is used to periodically scan for unhealthy pods and trigger a self-healing action.

### 2. Node health checks
The node check script inspects node conditions such as:

- `MemoryPressure`
- `DiskPressure`
- `Ready`
- scheduling failures from recent Kubernetes events

### 3. Datadog integration
The Datadog script posts cluster health data to Datadog so the team can monitor AKS health and alert on issues.

### 4. Redis maintenance automation
The Redis maintenance script uses Azure CLI to flush the cache and restart the Azure Cache for Redis instance.

## Prerequisites

- Azure CLI installed and authenticated
- `kubectl` configured to your AKS cluster
- Datadog API key and application key (for monitoring)
- Access to the target Azure subscription and resource group

## Quick start

```bash
# View available commands
make help

# Run pod recovery check
make pod-recovery

# Run node health check
make node-health

# Push health metrics to Datadog
make datadog

# Flush and restart Azure Cache for Redis
make redis
```

## Azure DevOps Pipeline (Automated)

For **hands-free automation**, use the included Azure DevOps pipeline:

```bash
# The pipeline runs automatically on this schedule:
# - Every 10 minutes: Pod recovery check
# - Every hour: Node health check & Datadog metrics
# - Every Sunday 2 AM: Redis maintenance
```

To set it up, see [AZURE_DEVOPS_SETUP.md](docs/AZURE_DEVOPS_SETUP.md).

Alternatively, run scripts manually with:

```bash
make pod-recovery
make node-health
make datadog
make redis
```

---

## Notes

This project is intentionally minimal and designed for learning and demonstration. In production, you would usually add:

- RBAC permissions for the recovery service account
- alert rules and dashboards in Datadog
- secret management with Azure Key Vault or Kubernetes Secrets
- logging and notification channels such as Teams or email

## Typical workflow

1. A pod fails or enters an unhealthy state.
2. The CronJob detects the bad pod.
3. The script deletes the pod so Kubernetes can recreate it.
4. The node health check monitors pressure and scheduling issues.
5. Datadog receives cluster health metrics.
6. Redis maintenance can be triggered during planned operational windows.

This is a simple self-healing pattern for AKS operations and infrastructure automation.
