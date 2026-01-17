# Lesson 01: Introduction to Azure

> **Duration**: 55 minutes | **Day**: 1

## Overview

This lesson introduces you to Microsoft Azure and cloud computing fundamentals. You will learn about the different service models, explore the Azure Portal, and get hands-on experience with the Azure CLI.

## Learning Objectives

By the end of this lesson, you will be able to:

- Explain the core concepts of cloud computing
- Distinguish between IaaS, PaaS, SaaS, and serverless models
- Navigate the Azure Portal to find and manage services
- Use Azure CLI and Cloud Shell for basic operations
- Identify which service model applies to common Azure services

---

## Key Concepts

### What is Cloud Computing?

Cloud computing delivers computing services over the internet, including:

- **Compute**: Virtual machines, containers, and serverless functions
- **Storage**: Files, databases, and data lakes
- **Networking**: Virtual networks, load balancers, and CDNs
- **Intelligence**: AI, machine learning, and analytics

### Azure Service Models

| Model | Description | You Manage | Azure Manages | Example |
|-------|-------------|------------|---------------|---------|
| **IaaS** | Infrastructure as a Service | OS, runtime, apps, data | Hardware, networking | Virtual Machines |
| **PaaS** | Platform as a Service | Apps and data | Everything else | App Service |
| **SaaS** | Software as a Service | Data only | Everything else | Microsoft 365 |
| **Serverless** | Event-driven compute | Code only | Everything else | Azure Functions |

### The Shared Responsibility Model

Cloud computing uses a shared responsibility model:

- **Microsoft** is responsible for the physical infrastructure, network, and host security
- **You** are responsible for data, identities, and application security
- **Shared** responsibilities depend on the service model you choose

---

## Hands-on Exercises

### Exercise 1.1: Explore the Azure Portal

**Objective**: Become familiar with the Azure Portal interface.

1. Open your browser and navigate to [portal.azure.com](https://portal.azure.com)
2. Sign in with your Azure account
3. Explore the following areas:
   - **Home**: Your dashboard and recent resources
   - **All services**: Browse the full service catalogue
   - **Resource groups**: Logical containers for resources
   - **Cost Management**: Monitor spending and budgets

**Questions to answer**:

- How many service categories are there?
- Where do you find your subscription information?
- How do you access the marketplace?

### Exercise 1.2: Azure CLI Basics

**Objective**: Run your first Azure CLI commands.

Open Cloud Shell or your local terminal and run:

```bash
# Check your Azure CLI version
az version

# Log in to Azure (if not using Cloud Shell)
az login

# List your subscriptions
az account list --output table

# Set your active subscription
az account set --subscription "<your-subscription-name>"

# List available regions
az account list-locations --output table
```

### Exercise 1.3: Identify Service Models

**Objective**: Categorise Azure services by their service model.

Match each service to its primary model:

| Service | IaaS | PaaS | SaaS | Serverless |
|---------|------|------|------|------------|
| Azure Virtual Machines | | | | |
| Azure App Service | | | | |
| Azure Functions | | | | |
| Azure SQL Database | | | | |
| Microsoft 365 | | | | |
| Azure Kubernetes Service | | | | |
| Cosmos DB | | | | |

---

## Key Commands Reference

```bash
# Azure CLI essentials
az login                          # Authenticate with Azure
az account show                   # Show current subscription
az account list                   # List all subscriptions
az group list                     # List resource groups
az resource list                  # List all resources
az interactive                    # Start interactive mode
```

---

## Summary

In this lesson, you learned:

- ✅ Cloud computing fundamentals and benefits
- ✅ The four Azure service models: IaaS, PaaS, SaaS, and serverless
- ✅ How to navigate the Azure Portal
- ✅ Basic Azure CLI commands

---

## Next Steps

Continue to [Lesson 02: Getting Started with Azure](../02-getting-started/README.md) to learn about accounts, subscriptions, and resource groups.

---

## Additional Resources

- [Azure Fundamentals Learning Path](https://learn.microsoft.com/training/paths/azure-fundamentals/)
- [Azure CLI Documentation](https://learn.microsoft.com/cli/azure/)
- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)
