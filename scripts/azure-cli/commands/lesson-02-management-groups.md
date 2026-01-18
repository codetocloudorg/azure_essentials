# Lesson 02: Management Groups - Copy-Paste Commands

> ⚠️ **Requires Tenant-level permissions** (Global Admin or Management Group Contributor)

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
MG_PREFIX="mg-essentials"
```

---

## 🔍 Check Current Tenant

```bash
# View your tenant ID
az account show --query tenantId -o tsv
```

---

## Step 1: Create Root Management Group

```bash
# Create the root management group
az account management-group create \
    --name "${MG_PREFIX}-root" \
    --display-name "Azure Essentials Root"
```

---

## Step 2: Create Child Management Groups

### Production Environment

```bash
# Create Production management group
az account management-group create \
    --name "${MG_PREFIX}-production" \
    --display-name "Production" \
    --parent "${MG_PREFIX}-root"
```

### Development Environment

```bash
# Create Development management group
az account management-group create \
    --name "${MG_PREFIX}-development" \
    --display-name "Development" \
    --parent "${MG_PREFIX}-root"
```

### Sandbox Environment

```bash
# Create Sandbox management group
az account management-group create \
    --name "${MG_PREFIX}-sandbox" \
    --display-name "Sandbox" \
    --parent "${MG_PREFIX}-root"
```

---

## Step 3: View Management Groups

```bash
# List all management groups you created
az account management-group list \
    --query "[?contains(name, 'mg-essentials')].{Name:name, DisplayName:displayName}" \
    -o table
```

```bash
# Show details of a specific management group
az account management-group show --name "${MG_PREFIX}-root"
```

---

## 📚 Additional Commands

### Move a Subscription to a Management Group

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Move subscription to a management group
az account management-group subscription add \
    --name "${MG_PREFIX}-development" \
    --subscription "$SUBSCRIPTION_ID"
```

### Remove a Subscription from a Management Group

```bash
az account management-group subscription remove \
    --name "${MG_PREFIX}-development" \
    --subscription "$SUBSCRIPTION_ID"
```

---

## 🧹 Cleanup

> ⚠️ Delete child management groups first, then the parent

```bash
# Delete Sandbox
az account management-group delete --name "${MG_PREFIX}-sandbox"
```

```bash
# Delete Development
az account management-group delete --name "${MG_PREFIX}-development"
```

```bash
# Delete Production
az account management-group delete --name "${MG_PREFIX}-production"
```

```bash
# Delete Root (must be empty)
az account management-group delete --name "${MG_PREFIX}-root"
```

---

## 🔗 Portal Link

View your management groups in the Azure Portal:
https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups
