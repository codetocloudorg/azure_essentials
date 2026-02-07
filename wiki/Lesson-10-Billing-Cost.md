# Lesson 10: Billing & Cost Management

> **Time:** 15 minutes | **Difficulty:** Easy | **Cost:** $0 (just viewing!)

## 🎯 What You'll Learn

By the end of this lesson, you'll understand:
- How Azure pricing works
- How to monitor your costs
- How to set up budgets and alerts
- Tips to save money on Azure

---

## 💰 How Azure Pricing Works

### Pay-As-You-Go Model

Azure charges based on what you use. Different resources have different pricing models:

| Resource Type | Pricing Model |
|---------------|---------------|
| **VMs** | Per hour (while running) |
| **Storage** | Per GB stored + transactions |
| **Functions** | Per execution + compute time |
| **Databases** | Per hour or per request unit |
| **Networking** | Outbound data transfer |

### Key Pricing Factors

| Factor | Impact |
|--------|--------|
| **Region** | Some regions cost more |
| **Size/Tier** | Bigger = more expensive |
| **Uptime** | Running 24/7 vs. stopped |
| **Data transfer** | Outbound internet costs money |

---

## 📊 Check Your Current Costs

### Using Azure Portal

1. Go to [portal.azure.com](https://portal.azure.com)
2. Search for **"Cost Management"**
3. Click **"Cost analysis"**

You'll see:
- Total spend by day/month
- Breakdown by resource
- Breakdown by service type

### Using Azure CLI

```bash
# View cost for current billing period
az consumption usage list \
  --query "[].{Name:instanceName, Cost:pretaxCost, Date:usageStart}" \
  --output table
```

---

## 🎯 Set Up Budget Alerts

Don't get surprised by a big bill!

### Create a Budget

```bash
az consumption budget create \
  --budget-name "Learning-Budget" \
  --amount 50 \
  --category Cost \
  --time-grain Monthly \
  --start-date 2024-01-01 \
  --end-date 2024-12-31
```

### In the Portal

1. Go to **Cost Management + Billing**
2. Click **"Budgets"**
3. Click **"+ Add"**
4. Set:
   - Name: `Learning-Budget`
   - Amount: `$50`
   - Reset period: `Monthly`
5. Add alerts at 50%, 80%, 100%
6. Enter your email

Now you'll get emails before you overspend!

---

## 📉 Cost-Saving Tips

### 1. Stop VMs When Not Using

```bash
# Stop (deallocate) a VM - not charged for compute
az vm deallocate --resource-group rg-training --name my-vm

# Start when needed
az vm start --resource-group rg-training --name my-vm
```

> 💡 **Tip:** Stopped VMs still incur storage costs, but no compute costs.

### 2. Use the Right VM Size

| Size | vCPUs | RAM | Cost (approx) |
|------|-------|-----|---------------|
| B1s (burstable) | 1 | 1GB | $8/month |
| B2s | 2 | 4GB | $30/month |
| D2s v3 | 2 | 8GB | $70/month |
| D4s v3 | 4 | 16GB | $140/month |

**Start small, scale up if needed!**

### 3. Delete Unused Resources

Find orphaned resources:
```bash
# List all resources in subscription
az resource list --output table

# Find unattached disks (still charging!)
az disk list --query "[?managedBy==null].{Name:name, Size:diskSizeGb, RG:resourceGroup}" --output table
```

### 4. Use Serverless When Possible

| Traditional | Serverless Alternative |
|-------------|----------------------|
| VM running web app | Azure Container Apps |
| SQL Server 24/7 | Cosmos DB Serverless |
| VM running scripts | Azure Functions |

### 5. Leverage Free Tier

Many services have free tiers:

| Service | Free Tier |
|---------|-----------|
| **App Service** | 10 apps on shared infra |
| **Functions** | 1M executions/month |
| **Cosmos DB** | 1000 RU/s with free tier |
| **Storage** | 5GB blob storage |
| **AI Services** | Various free quotas |

### 6. Use Reserved Instances (Production)

For long-running production workloads:
- **1-year reservation:** ~40% savings
- **3-year reservation:** ~60% savings

Only for workloads you know will run 24/7!

---

## 🏷️ Use Tags for Cost Tracking

Tags help you see costs by project/owner/environment:

```bash
# Add tags to a resource group
az group update \
  --name rg-training \
  --tags environment=learning owner=me project=azure-course

# View costs by tag in Cost Analysis
```

### Recommended Tags

| Tag | Purpose |
|-----|---------|
| `environment` | dev, staging, production |
| `owner` | Who created this? |
| `project` | What project is this for? |
| `department` | For billing back to teams |
| `delete-after` | When can this be deleted? |

---

## 🧹 Clean Up After Each Lesson

The number one way to avoid surprise bills:

```bash
# Delete entire resource group after each lesson
az group delete --name rg-lesson-XX --yes --no-wait
```

### Verify Cleanup

```bash
# List all resource groups
az group list --output table

# Should be empty for training!
```

---

## 📱 Azure Cost Management Mobile App

Download it to check costs on the go:
- [iOS App Store](https://apps.apple.com/app/azure/id1219013620)
- [Google Play Store](https://play.google.com/store/apps/details?id=com.microsoft.azure)

---

## ⚠️ Common Costly Mistakes

| Mistake | How To Avoid |
|---------|--------------|
| Forgot to stop VM | Set up auto-shutdown |
| Left storage blobs | Delete resource group |
| Orphaned disks | Check with `az disk list` |
| High-tier database | Use Basic/free tier for learning |
| VPN Gateway running | These cost ~$30/month even idle |

### Set Up Auto-Shutdown on VMs

```bash
az vm auto-shutdown \
  --resource-group rg-training \
  --name my-vm \
  --time 1900 \
  --location centralus
```

---

## 📊 Cost Estimation Before Deploying

### Azure Pricing Calculator

Before creating resources, estimate costs:
1. Go to [azure.microsoft.com/pricing/calculator](https://azure.microsoft.com/pricing/calculator)
2. Add the resources you plan to create
3. Adjust regions and sizes
4. See estimated monthly cost

### In Bicep/ARM Templates

Add cost tags:
```bicep
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'my-vm'
  tags: {
    'estimated-monthly-cost': '$30'
  }
  // ...
}
```

---

## ✅ What You Learned

- 💰 How Azure pricing works (pay-as-you-go)
- 📊 How to monitor costs in the portal
- 🎯 How to set up budget alerts
- 💡 Tips to save money (stop VMs, use free tiers, clean up)
- 🏷️ How to use tags for cost tracking

---

## ➡️ Next Steps

Let's explore Azure AI services!

👉 **[Lesson 11: AI Foundry](Lesson-11-AI-Foundry)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
