# AKS Auto-Recovery & Monitoring System - Detailed Explanation

## What is this project?

This is a **self-healing automation framework** for Azure Kubernetes Service (AKS). Think of it as a **24/7 automated assistant** that:

- Watches your Kubernetes cluster continuously
- Fixes broken pods automatically
- Checks server health for problems
- Reports everything to your monitoring dashboard
- Maintains your Redis cache without human intervention

---

## How does it work? (Simple Analogy)

Imagine you're running a busy restaurant:

- **Your servers (Kubernetes nodes)** sometimes get tired and can't cook anymore (memory pressure, disk full)
- **Your workers (pods)** sometimes call in sick and can't finish their jobs
- **Your recipe book (applications)** needs checking to make sure everything is working

Instead of **you** calling the restaurant to fix every problem, you hire a **night shift manager** (automation) who:

1. **Checks on workers** every few minutes and rehires if someone is not working
2. **Monitors the kitchen** for any signs of stress (too hot, too crowded)
3. **Reports everything** to headquarters (Datadog monitoring)
4. **Cleans/restocks** the fridge (Redis cache maintenance) on a schedule

---

## The 4 Core Layers Explained

### Layer 1: Pod Recovery (Auto-Restart Broken Applications)

**What it does:**
- Watches all running applications (pods) in Kubernetes
- Detects pods that are **not healthy** (crashed, stuck, failed)
- Automatically **deletes** the broken pod
- Kubernetes **automatically recreates** the pod (like rehiring a worker)

**Real example:**
```
Your web app crashes → Script detects it's not running
→ Script deletes it → Kubernetes sees it's gone
→ Kubernetes restarts it → App is live again in seconds
```

**How often:** Every 10 minutes (adjustable)

**File:** `scripts/aks_pod_recovery.sh` | `k8s/pod-recovery-cronjob.yaml`

---

### Layer 2: Node Health Checks (Monitor Server Condition)

**What it does:**
- Checks the **physical servers** (nodes) that run your apps
- Looks for warning signs:
  - **MemoryPressure** = Server running out of RAM (like overloaded kitchen)
  - **DiskPressure** = Server running out of storage (like full garbage can)
  - **NotReady** = Server is having problems (like server offline)
- Watches for **scheduling failures** (when Kubernetes can't place new apps)

**Real example:**
```
Node 1 has MemoryPressure → Script logs this
→ Datadog gets alerted → Team checks why memory is filling up
→ They can fix it before everything crashes
```

**File:** `scripts/node_health_check.sh`

---

### Layer 3: Datadog Monitoring Integration (The Dashboard)

**What it does:**
- Collects cluster health metrics (node count, ready nodes, etc.)
- Sends them to **Datadog** (a monitoring and alerting platform)
- Creates a **central dashboard** where:
  - Team can see cluster health in real-time
  - Alerts trigger when something is wrong
  - Historical trends show patterns over time

**Real example:**
```
Every 5 minutes:
- Count total nodes → "We have 5 servers"
- Count healthy nodes → "4 are working, 1 is sick"
- Send to Datadog → Dashboard updates
→ If only 2 working → Alert sent → Team gets notified
```

**File:** `scripts/datadog_k8s_monitoring.sh`

---

### Layer 4: Redis Cache Maintenance (Automated Cleanup)

**What it does:**
- **Azure Cache for Redis** is a high-speed data storage system
- Over time, it accumulates old data and can get slow
- This script automatically:
  - **Flushes** (clears all data) → Gives it a fresh start
  - **Restarts** → Reboots to clean up memory

**Real example:**
```
Redis cache is like your restaurant's freezer.
After months of use, it has old ice buildup, freezer burn:
→ Script empties it (flush) → Script reboots → It runs faster
```

**When:** On-demand or scheduled during low-traffic times

**File:** `scripts/redis_maintenance.sh`

---

## Why This Matters (Benefits)

| Problem | Traditional Way | This Automation |
|---------|-----------------|-----------------|
| Pod crashes at 2 AM | Engineer wakes up, manually restarts | Automatically fixed in 10 minutes |
| Node runs out of memory | Application stops, customers complain | Alert sent, team investigates proactively |
| Cache gets slow | Performance degrades gradually | Scheduled maintenance prevents slowdown |
| No visibility into cluster | Engineers fly blind, react to angry customers | Real-time dashboard shows everything |

**Result:** Your Kubernetes cluster is **more reliable**, **less manual work**, and **faster to fix problems**

---

## Project File Structure Explained

```
Azure Kubernetes Auto-Recovery and Monitoring System/
│
├── README.md                    ← Quick start guide
│
├── Makefile                     ← Easy buttons to run things
│                                   (make pod-recovery, make node-health, etc.)
│
├── k8s/
│   └── pod-recovery-cronjob.yaml ← Kubernetes job that runs every 10 minutes
│                                   This is deployed INTO your cluster
│
├── scripts/
│   ├── aks_pod_recovery.sh      ← Finds and fixes broken pods
│   ├── node_health_check.sh     ← Checks server/node health
│   ├── datadog_k8s_monitoring.sh ← Sends metrics to Datadog
│   └── redis_maintenance.sh     ← Flushes and restarts Redis
│
└── docs/
    └── architecture.md          ← This file (you are here!)
```

---

## How to Use This Project (Step-by-Step)

### Step 1: Prerequisites
Before running anything, you need:
- **Azure CLI** installed and logged in (`az login`)
- **kubectl** installed and connected to your AKS cluster
- **Datadog API key** and **Application key** (for monitoring)
- **Azure Resource Group name** and **Redis cache name** (for Redis maintenance)

### Step 2: Set Environment Variables
```bash
# For Datadog alerting
export DD_API_KEY="your-datadog-api-key"
export DD_APP_KEY="your-datadog-app-key"

# For Redis maintenance
export RESOURCE_GROUP="rg-prod"
export REDIS_NAME="aks-cache"
```

### Step 3: Run Commands
```bash
# See what's available
make help

# Check for unhealthy pods and restart them
make pod-recovery

# Check if nodes are under pressure
make node-health

# Send cluster health to Datadog
make datadog

# Flush and restart Redis
make redis
```

---

## Real-World Scenario

Let's walk through what happens in a typical day:

**9:00 AM** - Cluster is running fine
- All 5 nodes are healthy
- All pods are running
- Redis is performing well

**10:15 AM** - A memory leak in one pod
- Pod crashes and enters "CrashLoopBackOff" state
- Node health check runs: detects issue, logs to Datadog
- 10 minutes later, pod recovery script runs
- Deletes the broken pod
- Kubernetes restarts the pod fresh
- Pod is healthy again by 10:25 AM
- **No manual intervention needed!**

**2:00 PM** - Scheduled Redis maintenance
- Team runs `make redis`
- Redis cache is flushed and restarted
- Old data cleared, fresh start
- Cache performance improves
- Users don't notice a thing (maintenance was fast)

**3:00 PM** - Node running out of memory
- Node health check detects "MemoryPressure"
- Datadog dashboard flashes red
- Alert sent to team Slack: "Node 3 under memory pressure"
- Team investigates: discovers a memory leak in their app
- They fix the code before it crashes
- **Problem caught early!**

---

## Key Concepts Summarized

| Term | Simple Meaning |
|------|----------------|
| **Pod** | A single application running in Kubernetes (like one worker) |
| **Node** | A physical server or VM running pods (like a kitchen worker) |
| **CronJob** | A task that runs on a schedule (like a scheduled meeting) |
| **MemoryPressure** | A server running out of RAM (kitchen getting hot) |
| **DiskPressure** | A server running out of storage space (hard drive full) |
| **Self-healing** | System fixes itself automatically without human help |
| **Datadog** | A monitoring service that watches and alerts you |
| **Redis** | A super-fast cache database (like a kitchen's prep table) |

---

## Summary

This project **automates away pain points** in running Kubernetes:

✅ **Pods fail?** → Automatically restarted  
✅ **Nodes getting stressed?** → Automatically detected & reported  
✅ **Need visibility?** → Dashboard shows everything in real-time  
✅ **Cache needs maintenance?** → Automated on schedule  

**Result:** A **self-healing, self-monitoring Kubernetes cluster** with minimal manual effort.
