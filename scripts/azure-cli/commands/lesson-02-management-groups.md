# Lesson 02: Management Groups - Copy-Paste Commands

> ⚠️ **Requires Tenant-level permissions** (Global Admin or Management Group Contributor)

This creates an **Azure Landing Zone style hierarchy** with nested child management groups.

```
📁 mg-{prefix}-root (Organization Root)
├── 📁 mg-{prefix}-platform
│   ├── 📁 mg-{prefix}-identity
│   ├── 📁 mg-{prefix}-connectivity
│   └── 📁 mg-{prefix}-management
├── 📁 mg-{prefix}-workloads
│   ├── 📁 mg-{prefix}-prod
│   └── 📁 mg-{prefix}-nonprod
└── 📁 mg-{prefix}-sandbox
```

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
    --display-name "Organization Root"
```

---

## Step 2: Create Second-Level Management Groups

### Platform (for shared infrastructure)

```bash
az account management-group create \
    --name "${MG_PREFIX}-platform" \
    --display-name "Platform" \
    --parent "${MG_PREFIX}-root"
```

### Workloads (for application subscriptions)

```bash
az account management-group create \
    --name "${MG_PREFIX}-workloads" \
    --display-name "Workloads" \
    --parent "${MG_PREFIX}-root"
```

### Sandbox (for learning/experimentation)

```bash
az account management-group create \
    --name "${MG_PREFIX}-sandbox" \
    --display-name "Sandbox" \
    --parent "${MG_PREFIX}-root"
```

---

## Step 3: Create Platform Child Groups

### Identity (Azure AD, authentication services)

```bash
az account management-group create \
    --name "${MG_PREFIX}-identity" \
    --display-name "Identity" \
    --parent "${MG_PREFIX}-platform"
```

### Connectivity (networking, DNS, firewalls)

```bash
az account management-group create \
    --name "${MG_PREFIX}-connectivity" \
    --display-name "Connectivity" \
    --parent "${MG_PREFIX}-platform"
```

### Management (monitoring, automation)

```bash
az account management-group create \
    --name "${MG_PREFIX}-management" \
    --display-name "Management" \
    --parent "${MG_PREFIX}-platform"
```

---

## Step 4: Create Workloads Child Groups

### Production

```bash
az account management-group create \
    --name "${MG_PREFIX}-prod" \
    --display-name "Production" \
    --parent "${MG_PREFIX}-workloads"
```

### Non-Production

```bash
az account management-group create \
    --name "${MG_PREFIX}-nonprod" \
    --display-name "Non-Production" \
    --parent "${MG_PREFIX}-workloads"
```

---

## Step 5: View Management Groups

```bash
# List all management groups you created
az account management-group list \
    --query "[?contains(name, '${MG_PREFIX}')].{Name:name, DisplayName:displayName}" \
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
    --name "${MG_PREFIX}-sandbox" \
    --subscription "$SUBSCRIPTION_ID"
```

### Remove a Subscription from a Management Group

```bash
az account management-group subscription remove \
    --name "${MG_PREFIX}-sandbox" \
    --subscription "$SUBSCRIPTION_ID"
```

---

## 🧹 Cleanup

> ⚠️ **Delete child groups first, then parents** (deepest children first)

### Delete Platform children

```bash
az account management-group delete --name "${MG_PREFIX}-identity"
az account management-group delete --name "${MG_PREFIX}-connectivity"
az account management-group delete --name "${MG_PREFIX}-management"
```

### Delete Workloads children

```bash
az account management-group delete --name "${MG_PREFIX}-prod"
az account management-group delete --name "${MG_PREFIX}-nonprod"
```

### Delete second-level groups

```bash
az account management-group delete --name "${MG_PREFIX}-platform"
az account management-group delete --name "${MG_PREFIX}-workloads"
az account management-group delete --name "${MG_PREFIX}-sandbox"
```

### Delete root (must be empty)

```bash
az account management-group delete --name "${MG_PREFIX}-root"
```

---

## 🔗 Portal Link

View your management groups in the Azure Portal:
https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups
