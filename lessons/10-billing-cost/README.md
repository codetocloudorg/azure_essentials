# Lesson 10: Billing and Cost Optimisation

> **Duration**: 20 minutes | **Day**: 2

## Overview

Managing cloud costs is essential for sustainable Azure usage. This lesson covers cost management tools, budgets, alerts, and resource tagging strategies.

## Learning Objectives

By the end of this lesson, you will be able to:

- Navigate Azure Cost Management and Billing
- Create and configure budgets with alerts
- Implement resource tagging for cost allocation
- Identify cost optimisation opportunities
- Use Azure Advisor recommendations

---

## Key Concepts

### Azure Cost Management Components

| Component | Description |
|-----------|-------------|
| **Cost Analysis** | Visualise and analyse spending |
| **Budgets** | Set spending limits with alerts |
| **Alerts** | Notifications when thresholds are reached |
| **Recommendations** | Azure Advisor cost suggestions |
| **Exports** | Schedule cost data exports |

### Pricing Models

| Model | Description | Best For |
|-------|-------------|----------|
| **Pay-as-you-go** | Pay for what you use | Variable workloads |
| **Reserved Instances** | 1-3 year commitment, up to 72% savings | Steady-state workloads |
| **Spot VMs** | Up to 90% savings, can be evicted | Fault-tolerant batch jobs |
| **Dev/Test Pricing** | Discounted rates for dev/test | Non-production environments |
| **Hybrid Benefit** | Use existing licenses | Windows/SQL Server migrations |

### Resource Tagging Strategy

Tags help organise and track costs:

| Tag Name | Purpose | Example Values |
|----------|---------|----------------|
| `Environment` | Deployment stage | Development, Staging, Production |
| `Owner` | Responsible team/person | platform-team, john.doe |
| `Project` | Project or application | azure-essentials, customer-portal |
| `CostCenter` | Billing allocation | CC-1234, IT-Infrastructure |
| `Department` | Organisational unit | Engineering, Marketing, Finance |

---

## Hands-on Exercises

### Exercise 10.1: Explore Cost Analysis

**Objective**: Navigate and understand the Cost Analysis dashboard.

1. Navigate to **Cost Management + Billing** in the Azure Portal
2. Select **Cost Management** → **Cost analysis**
3. Explore the following views:
   - **Accumulated costs**: Total spending over time
   - **Daily costs**: Day-by-day breakdown
   - **Cost by service**: Which services cost the most
   - **Cost by resource group**: Spending by resource group
4. Try different filters:
   - Filter by subscription
   - Filter by resource group
   - Filter by tag

### Exercise 10.2: Create a Budget with Alerts

**Objective**: Set up a budget to monitor and control spending.

#### Using Azure CLI

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
BUDGET_NAME="budget-azure-essentials"
AMOUNT=50  # Budget amount in your billing currency

# Get the subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Create a budget
az consumption budget create \
  --budget-name $BUDGET_NAME \
  --amount $AMOUNT \
  --category Cost \
  --time-grain Monthly \
  --start-date $(date -u +"%Y-%m-01") \
  --end-date $(date -u -d "+1 year" +"%Y-%m-01") \
  --resource-group $RESOURCE_GROUP

# Note: For email alerts, use the Azure Portal or add notification thresholds
```

#### Using Azure Portal (Recommended for Alerts)

1. Navigate to **Cost Management + Billing**
2. Select **Budgets** → **Add**
3. Configure the budget:
   - **Name**: `budget-azure-essentials`
   - **Reset period**: Monthly
   - **Amount**: Set your monthly limit
4. Configure alert conditions:
   - **Alert condition 1**: Actual, 50% of budget
   - **Alert condition 2**: Actual, 80% of budget
   - **Alert condition 3**: Actual, 100% of budget
   - **Alert condition 4**: Forecasted, 100% of budget
5. Add alert recipients (email addresses)
6. Select **Create**

### Exercise 10.3: Apply Resource Tags

**Objective**: Tag resources for cost tracking and organisation.

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"

# Tag a resource group
az group update \
  --name $RESOURCE_GROUP \
  --tags \
    Environment=Development \
    Project="Azure Essentials" \
    Owner="Training Team" \
    CostCenter="TRAINING-001"

# View tags on the resource group
az group show \
  --name $RESOURCE_GROUP \
  --query tags

# Tag all resources in a resource group
az resource list \
  --resource-group $RESOURCE_GROUP \
  --query "[].id" \
  --output tsv | while read id; do
    az resource tag \
      --ids "$id" \
      --tags \
        Environment=Development \
        Project="Azure Essentials" \
        Owner="Training Team" \
      2>/dev/null || echo "Could not tag: $id"
done

# List resources with a specific tag
az resource list \
  --tag Environment=Development \
  --output table
```

### Exercise 10.4: Review Azure Advisor Recommendations

**Objective**: Find cost optimisation recommendations.

```bash
# Get cost recommendations from Azure Advisor
az advisor recommendation list \
  --category Cost \
  --output table

# Get detailed recommendation
az advisor recommendation list \
  --category Cost \
  --query "[0]" \
  --output json
```

**In the Azure Portal**:

1. Navigate to **Advisor**
2. Select the **Cost** tab
3. Review recommendations such as:
   - Resize or shut down underutilised VMs
   - Purchase reserved instances
   - Delete unused resources
   - Right-size databases

---

## Cost Optimisation Checklist

| Category | Action |
|----------|--------|
| **Compute** | ☐ Right-size VMs based on usage |
| | ☐ Use auto-shutdown for dev VMs |
| | ☐ Consider reserved instances for production |
| | ☐ Use spot VMs for batch workloads |
| **Storage** | ☐ Use appropriate access tiers (Hot/Cool/Archive) |
| | ☐ Enable lifecycle management policies |
| | ☐ Delete unused snapshots and disks |
| **Database** | ☐ Use serverless for variable workloads |
| | ☐ Right-size DTUs/vCores |
| | ☐ Use reserved capacity for steady-state |
| **Networking** | ☐ Review data transfer costs |
| | ☐ Use VNet peering instead of VPN |
| **General** | ☐ Delete unused resources |
| | ☐ Set up budgets and alerts |
| | ☐ Tag all resources for tracking |

---

## Tagging Policy Example

Create consistent tagging with Azure Policy:

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "tags['Environment']",
          "exists": "false"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
}
```

---

## Key Commands Reference

```bash
# Cost Management
az consumption budget create --budget-name <n> --amount <a>
az consumption budget list
az consumption usage list

# Azure Advisor
az advisor recommendation list --category Cost

# Resource Tags
az group update --name <rg> --tags Key=Value
az resource tag --ids <resource-id> --tags Key=Value
az resource list --tag Key=Value
```

---

## Summary

In this lesson, you learned:

- ✅ Navigating Azure Cost Management
- ✅ Creating budgets with alert thresholds
- ✅ Implementing resource tagging strategies
- ✅ Using Azure Advisor for cost recommendations
- ✅ Best practices for cost optimisation

---

## Next Steps

Continue to [Lesson 11: Azure AI Foundry](../11-ai-foundry/README.md) to explore AI capabilities.

---

## Additional Resources

- [Azure Cost Management Documentation](https://learn.microsoft.com/azure/cost-management-billing/)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Azure Advisor Documentation](https://learn.microsoft.com/azure/advisor/)
- [Resource Tagging Best Practices](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
