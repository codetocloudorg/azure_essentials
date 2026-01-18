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

## Step 3: Get Storage Account Key

```bash
# Retrieve the storage account key
ACCOUNT_KEY=$(az storage account keys list \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query '[0].value' \
    -o tsv)

echo "Key retrieved successfully"
```

---

## Step 4: Create Blob Containers

```bash
# Create 'documents' container
az storage container create \
    --name "documents" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY"
```

```bash
# Create 'images' container
az storage container create \
    --name "images" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY"
```

```bash
# Create 'backups' container
az storage container create \
    --name "backups" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY"
```

---

## Step 5: Create a Queue

```bash
# Create a storage queue
az storage queue create \
    --name "messages" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY"
```

---

## Step 6: Create a Table

```bash
# Create a storage table
az storage table create \
    --name "logs" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY"
```

---

## Step 7: Create a File Share

```bash
# Create a file share with 5 GB quota
az storage share create \
    --name "files" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY" \
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
    --account-key "$ACCOUNT_KEY" \
    --container-name "documents" \
    --name "sample.txt" \
    --file /tmp/sample.txt

# Clean up temp file
rm /tmp/sample.txt
```

---

## Step 9: List Blobs

```bash
# List blobs in the documents container
az storage blob list \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$ACCOUNT_KEY" \
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
    --account-key "$ACCOUNT_KEY" \
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
| `az storage account keys list` | Get access keys |
| `az storage container create` | Create blob container |
| `az storage blob upload` | Upload a file |
| `az storage blob download` | Download a file |
| `az storage blob list` | List blobs |
| `az storage queue create` | Create queue |
| `az storage table create` | Create table |
| `az storage share create` | Create file share |
