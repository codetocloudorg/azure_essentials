# Lesson 02: Getting Started with Azure

> **Duration**: 20 minutes | **Day**: 1

## Overview

This lesson covers the foundational organisational concepts in Azure. You will learn how accounts, subscriptions, tenants, and resource groups work together to structure your cloud resources.

## Learning Objectives

By the end of this lesson, you will be able to:

- Explain the Azure account hierarchy
- Describe the relationship between tenants and subscriptions
- Create and manage resource groups
- Apply consistent naming conventions
- Configure the Azure CLI for your environment

---

## Key Concepts

### Azure Account Hierarchy

Azure uses a hierarchical structure to organise resources:

```
Microsoft Entra ID Tenant (formerly Azure AD)
└── Management Groups (optional)
    └── Subscriptions
        └── Resource Groups
            └── Resources
```

### Understanding Each Level

| Component | Description | Purpose |
|-----------|-------------|---------|
| **Tenant** | An instance of Microsoft Entra ID | Identity and access management |
| **Management Group** | Container for subscriptions | Apply governance at scale |
| **Subscription** | Billing boundary and access control | Organise costs and permissions |
| **Resource Group** | Logical container for resources | Group related resources together |
| **Resource** | An Azure service instance | The actual cloud service |

### Resource Group Best Practices

Resource groups help you:

- **Organise**: Group resources by application, environment, or lifecycle
- **Manage access**: Apply role-based access control (RBAC) at the group level
- **Track costs**: View and allocate costs by resource group
- **Deploy together**: Use Infrastructure as Code to deploy all resources in a group

> **Important**: Resources in a group can be in different regions, but the resource group itself has a location for storing metadata.

---

## Hands-on Exercises

### Exercise 2.1: Create Resource Groups

**Objective**: Create resource groups for organising course resources.

#### Using the Azure Portal

1. Navigate to **Resource groups** in the Azure Portal
2. Select **Create**
3. Enter the following:
   - **Subscription**: Select your subscription
   - **Resource group name**: `rg-azure-essentials-dev`
   - **Region**: Select your preferred region
4. Select **Review + create**, then **Create**

#### Using Azure CLI

```bash
# Create a resource group for development
az group create \
  --name rg-azure-essentials-dev \
  --location uksouth \
  --tags Environment=Development Course="Azure Essentials"

# Create a resource group for production exercises
az group create \
  --name rg-azure-essentials-prod \
  --location uksouth \
  --tags Environment=Production Course="Azure Essentials"

# Verify the resource groups were created
az group list --output table
```

### Exercise 2.2: Configure Azure CLI Defaults

**Objective**: Set default values for common CLI parameters.

```bash
# Set default resource group
az config set defaults.group=rg-azure-essentials-dev

# Set default location
az config set defaults.location=uksouth

# View your configuration
az config get

# Now you can omit these parameters in future commands
az group show  # Uses the default resource group
```

### Exercise 2.3: Explore Your Subscription

**Objective**: Understand your subscription details and quotas.

```bash
# View subscription details
az account show --output yaml

# List resource providers
az provider list --output table

# Check quotas for compute resources
az vm list-usage --location uksouth --output table
```

---

## Naming Conventions

Use consistent naming to make resources easy to identify:

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Resource Group | `rg-` | `rg-azure-essentials-dev` |
| Storage Account | `st` | `stazureessentials001` |
| Virtual Network | `vnet-` | `vnet-azure-essentials` |
| Virtual Machine | `vm-` | `vm-web-001` |
| App Service | `app-` | `app-api-prod` |
| Function App | `func-` | `func-processor` |

> **Note**: Storage accounts have special naming rules: 3-24 characters, lowercase letters and numbers only.

---

## Key Commands Reference

```bash
# Resource group commands
az group create --name <name> --location <region>
az group list --output table
az group show --name <name>
az group delete --name <name> --yes

# Subscription commands
az account list --output table
az account set --subscription <name-or-id>
az account show

# Configuration
az config set defaults.group=<name>
az config set defaults.location=<region>
az config get
```

---

## Summary

In this lesson, you learned:

- ✅ The Azure account hierarchy from tenant to resource
- ✅ How to create and manage resource groups
- ✅ Azure CLI configuration for efficient workflows
- ✅ Naming conventions for Azure resources

---

## Next Steps

Continue to [Lesson 03: Storage Services](../03-storage-services/README.md) to learn about Azure storage options.

---

## Additional Resources

- [Azure Resource Naming Conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Resource Group Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Management Groups Overview](https://learn.microsoft.com/azure/governance/management-groups/overview)
