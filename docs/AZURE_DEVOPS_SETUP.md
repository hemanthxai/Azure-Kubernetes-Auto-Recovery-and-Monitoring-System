# Azure DevOps Pipeline Setup Guide

## What This Is

The `azure-pipelines.yml` file is a **CI/CD pipeline** for Azure DevOps. It automatically runs your AKS automation scripts on a schedule without you having to manually trigger them.

Think of it as: **Set it and forget it automation**

---

## How It Works

The pipeline runs these stages automatically:

### Pre-Checks
Verifies that Azure CLI and kubectl are available before doing anything.

### Pod Recovery *(every 10 minutes)*
- Finds broken/unhealthy pods
- Deletes them
- Kubernetes restarts them

### Node Health Check *(every hour)*
- Checks if servers have memory pressure
- Checks if servers have disk pressure
- Reports status

### Datadog Metrics *(every hour)*
- Sends cluster health data to Datadog
- Updates your monitoring dashboard

### Redis Maintenance *(every Sunday at 2 AM)*
- Flushes the Redis cache
- Restarts Redis
- Keeps cache fast

### Notify Results *(always)*
- Sends completion notification (Slack, email, or just logs)

---

## Setup in Azure DevOps (Step-by-Step)

### Step 1: Create a new pipeline

1. Go to Azure DevOps → **Pipelines** → **New Pipeline**
2. Select **Azure Repos Git** (or GitHub)
3. Choose your repository
4. Click **Existing Azure Pipelines YAML file**
5. Select `azure-pipelines.yml`
6. Click **Continue** → **Save and run**

### Step 2: Create a Variable Group for secrets

Secrets like API keys should NOT be in code. Store them in Azure DevOps:

1. Go to **Pipelines** → **Library** → **Variable groups**
2. Click **+ Variable group**
3. Name it: `AKS-AutoRecovery-Secrets`
4. Add these variables:
   - `DD_API_KEY` - Your Datadog API key (mark as secret ✓)
   - `DD_APP_KEY` - Your Datadog App key (mark as secret ✓)
   - `kubeConfigSecret` - Your kubeconfig file content (mark as secret ✓)
   - `SLACK_WEBHOOK` - Your Slack webhook URL (mark as secret ✓)

5. Click **Save**

### Step 3: Link the Variable Group to the pipeline

1. Go to your pipeline → **Edit**
2. Click **...** (more options) → **Triggers**
3. Click **Variables** → **Variable groups**
4. Click **Link variable group**
5. Select `AKS-AutoRecovery-Secrets`
6. Click **Link**

### Step 4: Create Service Connections

Service connections let the pipeline authenticate to Azure and Kubernetes:

#### For Azure:
1. Go to **Project Settings** → **Service connections**
2. Click **New service connection** → **Azure Resource Manager**
3. Choose **Service principal (automatic)**
4. Select your subscription
5. Name it: `Azure`
6. Click **Save**

#### For Kubernetes:
1. Go to **Project Settings** → **Service connections**
2. Click **New service connection** → **Kubernetes**
3. Connection Name: `aks-cluster`
4. Server URL: Your AKS cluster URL (get from `kubectl cluster-info`)
5. Kubeconfig: Paste your kubeconfig content
6. Click **Save** and **Verify**

### Step 5: Update pipeline variables

Edit the pipeline and update these to match YOUR resources:

```yaml
variables:
  clusterName: "aks-prod"        # Your AKS cluster name
  resourceGroup: "rg-prod"       # Your Azure resource group
  redisName: "aks-cache"         # Your Redis cache name
  notificationEmail: "you@company.com"  # Your email
```

### Step 6: Navigate to your pipeline and save

1. Go to your pipeline
2. Click **Edit**
3. Make sure all the variable names match your setup
4. Click **Save**

---

## How to Run It

### Option 1: Automatic (Scheduled)
The pipeline runs automatically on this schedule:

- **Every 10 minutes** - Pod recovery check
- **Every hour** - Node health check & Datadog metrics
- **Every Sunday at 2 AM** - Redis maintenance

No action needed. It just happens.

### Option 2: Manual Trigger
Run the pipeline anytime you want:

1. Go to **Pipelines** → Select your pipeline
2. Click **Run pipeline**
3. Click **Run**

---

## Understanding the Schedule

The schedule section uses **cron expressions**:

| Expression | Meaning |
|-----------|---------|
| `*/10 * * * *` | Every 10 minutes |
| `0 * * * *` | Every hour at :00 |
| `0 2 * * 0` | Every Sunday at 2 AM |

Want to change the frequency? Edit the `azure-pipelines.yml` and update those times.

---

## Common Setup Issues

### Issue: "Service connection not found"
**Fix:** Make sure you created the Service connection in Azure DevOps and the name matches in the pipeline.

### Issue: "kubeConfig not set"
**Fix:** Add the kubeconfig to your Variable Group as `kubeConfigSecret` and make sure it's marked as a secret.

### Issue: "Datadog metrics not appearing"
**Fix:** Verify your `DD_API_KEY` and `DD_APP_KEY` are correct in the Variable Group.

### Issue: "Pipeline fails on kubectl commands"
**Fix:** Make sure your Kubernetes Service Connection is properly authenticated.

---

## What Gets Logged

Every pipeline run produces logs you can check:

1. Go to **Pipelines** → Your pipeline
2. Click on the run number
3. Click on each stage to see detailed logs
4. Scroll through the logs to see what happened

---

## Optional: Notifications

### Enable Slack notifications:
1. Create a Slack webhook URL in your Slack workspace
2. Add it to Variable Group as `SLACK_WEBHOOK`
3. In the pipeline, change `enabled: false` to `enabled: true` in the Slack task

### Enable Email notifications:
1. In the pipeline, change `enabled: false` to `enabled: true` in the Email task
2. Update `notificationEmail` variable
3. Make sure your Azure DevOps has email configured

---

## Real-World Example

**Monday morning, 8:00 AM:**

- Pipeline runs automatically
- Pod recovery check → finds 2 broken pods → deletes them → Kubernetes restarts them
- Node health check → all nodes healthy
- Datadog metrics → dashboard updated
- Logs appear in Azure DevOps
- Team can see "everything is fine" in the dashboard

**If something was wrong:**

- Alert sent to Slack/email
- Team investigates
- Pipeline logs show exactly what happened and when

---

## Tips

✅ **Start with manual runs** — Click "Run Pipeline" to test before relying on schedules

✅ **Check logs frequently** — Logs tell you exactly what's happening

✅ **Use Variable Groups** — Keep secrets out of code

✅ **Test Service Connections** — Click "Verify" on each service connection before trusting it

✅ **Start with longer schedules** — Run every hour first, then move to every 10 minutes once you trust it

---

## Summary

This pipeline:
- ✅ Runs automatically on a schedule
- ✅ Restarts broken pods
- ✅ Checks node health
- ✅ Sends metrics to Datadog
- ✅ Maintains Redis
- ✅ Logs everything for visibility
- ✅ Can notify you when done

Set it up once, then let it run 24/7 without manual intervention.
