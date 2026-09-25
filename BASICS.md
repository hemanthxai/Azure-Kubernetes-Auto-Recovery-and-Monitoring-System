# Basics: What This Project Does

## The Problem

You're running Kubernetes in Azure. Sometimes things break:

- A pod crashes and doesn't come back
- Your server runs out of memory and apps stop
- You have no idea what's failing until customers complain
- You spend time manually restarting things that should restart themselves

This project fixes that.

---

## What You Get

### 1. Automatic Pod Restart
Your apps crash sometimes. That's normal. When they do:

```
Pods crashes → system detects it → deletes the broken pod → 
Kubernetes boots a new one → your app is back online (usually in <1 minute)
```

You don't do anything. It just works.

### 2. Health Monitoring
Every hour, the system checks:

- Are my servers running out of memory?
- Are my servers running out of disk space?
- How many servers are actually working right now?

If something looks bad, it tells you.

### 3. Datadog Dashboard
All that health data goes to Datadog (your monitoring dashboard). Now you can:

- See at a glance if your cluster is healthy
- Get alerts when something breaks
- Look at trends (why is memory usage growing?)

### 4. Cache Maintenance
Your Redis cache gets old data cruft. You can:

- Flush it clean
- Restart it
- Keep it running fast

All automated with one command.

---

## How to Use It

### Get ready
You need:
- Azure CLI installed and logged in
- kubectl connected to your cluster
- Datadog account (free or paid)

### Run it
```bash
# See all available commands
make help

# Check for broken pods and fix them
make pod-recovery

# See if your servers are under stress
make node-health

# Send health info to your Datadog dashboard
make datadog

# Flush and restart Redis
make redis
```

That's it.

---

## A Real Day

**Morning:** Everything works. Dashboard is green.

**Noon:** One of your apps has a memory leak. It crashes.
- Your automation detects it within 10 minutes
- Deletes it
- Kubernetes restarts it
- It's running again
- You don't know it happened until you check the logs

**Afternoon:** You want to refresh your cache before the big sale.
- Run `make redis`
- Cache is flushed and restarted in seconds
- No downtime, no drama

**Evening:** You notice memory usage is slowly climbing on one server.
- Check the Datadog dashboard
- See the trend
- Fix the app issue before it crashes
- Crisis prevented

---

## The Philosophy

**Don't fix things manually if a script can do it.**

Stop waiting for problems to blow up. Stop manually restarting things. Let the system handle the mundane stuff so you can focus on real problems.

That's this project.

---

## Files You Actually Need to Know About

**`scripts/aks_pod_recovery.sh`**  
Finds broken pods, deletes them. That's all.

**`scripts/node_health_check.sh`**  
Checks if your servers are under stress. Reports what it finds.

**`scripts/datadog_k8s_monitoring.sh`**  
Sends cluster status to Datadog. Set your API keys and it works.

**`scripts/redis_maintenance.sh`**  
Clears and restarts your Redis. Use when cache needs a refresh.

**`k8s/pod-recovery-cronjob.yaml`**  
The Kubernetes job that runs the pod recovery script every 10 minutes. Deploy this into your cluster once and forget about it.

---

## Common Questions

**Q: How often does it check for broken pods?**  
A: Every 10 minutes by default. Change it in the CronJob if you want.

**Q: What if it restarts a pod that shouldn't be restarted?**  
A: It only restarts pods that are actually broken (not running). If it's running, it leaves it alone.

**Q: Do I need to do anything special to set it up?**  
A: You need to:
1. Run `kubectl apply -f k8s/pod-recovery-cronjob.yaml` to deploy the CronJob
2. Set your Datadog API keys before running monitoring
3. Set your Azure resource group and Redis name before running cache maintenance

**Q: What if I don't have all this set up yet?**  
A: Start simple. Just run the scripts manually first. Get used to them. Then automate when you're ready.

---

## Bottom Line

This is automation that does the boring stuff so you don't have to. Broken pods get fixed. Health gets reported. Cache gets maintained.

