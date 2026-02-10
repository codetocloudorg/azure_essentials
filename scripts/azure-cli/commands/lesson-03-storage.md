# Lesson 03: Storage Services - Copy-Paste Commands

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="centralus"
RESOURCE_GROUP="rg-essentials-storage"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
STORAGE_ACCOUNT="stessentials${UNIQUE_SUFFIX}"

# Display the storage account name (save this!)
echo "Storage Account: $STORAGE_ACCOUNT"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=03-storage"
```

---

## Step 2: Create Storage Account

```bash
# Create a general-purpose v2 storage account
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --access-tier Hot \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --https-only true
```

---

## Step 3: Assign RBAC Role for Azure AD Authentication

Modern Azure subscriptions may disable shared key access. Using Azure AD (OAuth) authentication is the recommended approach:

```bash
# Get your user ID
USER_ID=$(az ad signed-in-user show --query id -o tsv)

# Assign Storage Blob Data Contributor role
az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee "$USER_ID" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"

# Assign Storage Queue Data Contributor role
az role assignment create \
    --role "Storage Queue Data Contributor" \
    --assignee "$USER_ID" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"

# Assign Storage Table Data Contributor role
az role assignment create \
    --role "Storage Table Data Contributor" \
    --assignee "$USER_ID" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"

echo "RBAC roles assigned. Waiting 30 seconds for propagation..."
sleep 30
```

---

## Step 4: Create Blob Containers

```bash
# Create 'documents' container
az storage container create \
    --name "documents" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login
```

```bash
# Create 'images' container
az storage container create \
    --name "images" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login
```

```bash
# Create 'backups' container
az storage container create \
    --name "backups" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login
```

---

## Step 5: Create a Queue

```bash
# Create a storage queue
az storage queue create \
    --name "messages" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login
```

---

## Step 6: Create a Table

```bash
# Create a storage table
az storage table create \
    --name "logs" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login
```

---

## Step 7: Create a File Share

```bash
# Create a file share with 5 GB quota (using Resource Manager API)
az storage share-rm create \
    --name "files" \
    --storage-account "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --quota 5
```

---

## Step 8: Upload a Sample Blob

```bash
# Create a sample file
echo "Hello from Azure Essentials!" > /tmp/sample.txt

# Upload the blob
az storage blob upload \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login \
    --container-name "documents" \
    --name "sample.txt" \
    --file /tmp/sample.txt \
    --overwrite

# Clean up temp file
rm /tmp/sample.txt
```

---

## Step 9: List Blobs

```bash
# List blobs in the documents container
az storage blob list \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login \
    --container-name "documents" \
    --query "[].{Name:name, Size:properties.contentLength}" \
    -o table
```

---

## Step 10: Download a Blob

```bash
# Download the sample blob
az storage blob download \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login \
    --container-name "documents" \
    --name "sample.txt" \
    --file /tmp/downloaded-sample.txt

# View the contents
cat /tmp/downloaded-sample.txt
```

---

## 📊 View Storage Account Info

```bash
# Show storage account details
az storage account show \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, Location:location, SKU:sku.name, Kind:kind}" \
    -o table
```

```bash
# Get the blob endpoint URL
az storage account show \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query primaryEndpoints.blob \
    -o tsv
```

---

## 🧹 Cleanup

```bash
# Delete the entire resource group (includes all resources)
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo "Cleanup initiated - resources deleting in background"
```

---

## 🔗 Quick Reference

| Command | Description |
|---------|-------------|
| `az storage account create` | Create storage account |
| `az storage container create --auth-mode login` | Create blob container (OAuth) |
| `az storage blob upload --auth-mode login` | Upload a file (OAuth) |
| `az storage blob download --auth-mode login` | Download a file (OAuth) |
| `az storage blob list --auth-mode login` | List blobs (OAuth) |
| `az storage queue create --auth-mode login` | Create queue (OAuth) |
| `az storage table create --auth-mode login` | Create table (OAuth) |
| `az storage share-rm create` | Create file share (Resource Manager) |
| `az role assignment create` | Assign RBAC role for storage access |
