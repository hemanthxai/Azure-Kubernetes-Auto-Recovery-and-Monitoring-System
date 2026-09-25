.PHONY: help pod-recovery node-health datadog redis

help:
	@echo "Available targets:"
	@echo "  make pod-recovery   - restart unhealthy AKS pods"
	@echo "  make node-health    - check memory/disk pressure and scheduling failures"
	@echo "  make datadog        - push cluster health data to Datadog"
	@echo "  make redis          - flush and restart Azure Cache for Redis"

pod-recovery:
	bash ./scripts/aks_pod_recovery.sh default

node-health:
	bash ./scripts/node_health_check.sh

datadog:
	bash ./scripts/datadog_k8s_monitoring.sh

redis:
	bash ./scripts/redis_maintenance.sh
