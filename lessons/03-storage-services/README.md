# Lesson 03: Storage Services

> **Duration**: 55 minutes | **Day**: 1

## Overview

Azure Storage provides scalable, durable cloud storage for a wide variety of data objects. This lesson covers the core storage services, redundancy options, and access tiers.

## Learning Objectives

By the end of this lesson, you will be able to:

- Describe the four core Azure storage services
- Choose appropriate redundancy options for different scenarios
- Create and configure a storage account
- Upload and manage blobs
- Work with queues for message-based communication
- Select the right access tier for your data

---

## Key Concepts

### Azure Storage Services

Azure Storage includes four main services:

| Service | Description | Use Cases |
|---------|-------------|-----------|
| **Blob Storage** | Object storage for unstructured data | Images, documents, videos, backups |
| **File Storage** | Managed file shares | Lift-and-shift applications, shared config |
| **Queue Storage** | Message queuing | Decoupling applications, async processing |
| **Table Storage** | NoSQL key-value store | Application data, metadata storage |

### Storage Redundancy Options

| Option | Copies | Scope | Best For |
|--------|--------|-------|----------|
| **LRS** | 3 | Single datacentre | Dev/test, non-critical data |
| **ZRS** | 3 | Across availability zones | Production, high availability |
| **GRS** | 6 | Primary + secondary region | Disaster recovery |
| **GZRS** | 6 | Zones + secondary region | Mission-critical applications |

### Access Tiers

| Tier | Storage Cost | Access Cost | Use Case |
|------|--------------|-------------|----------|
| **Hot** | Highest | Lowest | Frequently accessed data |
| **Cool** | Medium | Medium | Infrequently accessed (30+ days) |
| **Cold** | Lower | Higher | Rarely accessed (90+ days) |
| **Archive** | Lowest | Highest | Long-term retention (180+ days) |

---

## Hands-on Exercises

### Exercise 3.1: Create a Storage Account

**Objective**: Create a storage account using Azure CLI.

```bash
# Variables
STORAGE_NAME="stazessentials$(openssl rand -hex 4)"
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="centralus"

# Create storage account
az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot \
  --https-only true \
  --min-tls-version TLS1_2

# Get the storage account key
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query '[0].value' \
  --output tsv)

echo "Storage account created: $STORAGE_NAME"
```

### Exercise 3.2: Work with Blob Storage

**Objective**: Create containers and upload blobs.

```bash
# Create a container
az storage container create \
  --name samples \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

# Create a sample file
echo "Hello from Azure Essentials!" > sample.txt

# Upload the file
az storage blob upload \
  --container-name samples \
  --name hello.txt \
  --file sample.txt \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

# List blobs in the container
az storage blob list \
  --container-name samples \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY \
  --output table

# Download the blob
az storage blob download \
  --container-name samples \
  --name hello.txt \
  --file downloaded.txt \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

cat downloaded.txt
```

### Exercise 3.3: Work with Queue Storage

**Objective**: Send and receive messages using queues.

```bash
# Create a queue
az storage queue create \
  --name task-queue \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

# Send messages to the queue
az storage message put \
  --queue-name task-queue \
  --content "Process order 001" \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

az storage message put \
  --queue-name task-queue \
  --content "Process order 002" \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

# Peek at messages (without removing them)
az storage message peek \
  --queue-name task-queue \
  --num-messages 5 \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY \
  --output table
```

### Exercise 3.4: Explore Access Tiers

**Objective**: Change blob access tiers.

```bash
# Upload a file to cool tier
az storage blob upload \
  --container-name samples \
  --name archive-data.txt \
  --file sample.txt \
  --tier Cool \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

# Change tier to archive
az storage blob set-tier \
  --container-name samples \
  --name archive-data.txt \
  --tier Archive \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY

# Check the blob tier
az storage blob show \
  --container-name samples \
  --name archive-data.txt \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY \
  --query "properties.blobTier" \
  --output tsv
```

---

## Sample Code

### Python: Upload and Download Blobs

```python
from azure.storage.blob import BlobServiceClient
import os

# Connection string from environment variable
connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
blob_service_client = BlobServiceClient.from_connection_string(connection_string)

# Get container client
container_client = blob_service_client.get_container_client("samples")

# Upload a blob
with open("sample.txt", "rb") as data:
    container_client.upload_blob(name="from-python.txt", data=data)

# Download a blob
blob_client = container_client.get_blob_client("from-python.txt")
with open("downloaded-python.txt", "wb") as download_file:
    download_file.write(blob_client.download_blob().readall())
```

---

## Key Commands Reference

```bash
# Storage account
az storage account create --name <name> --resource-group <rg> --sku Standard_LRS
az storage account list --output table
az storage account keys list --account-name <name>

# Containers
az storage container create --name <name> --account-name <storage>
az storage container list --account-name <storage>

# Blobs
az storage blob upload --container-name <c> --name <n> --file <f>
az storage blob list --container-name <c> --account-name <storage>
az storage blob download --container-name <c> --name <n> --file <f>

# Queues
az storage queue create --name <name> --account-name <storage>
az storage message put --queue-name <q> --content "<message>"
az storage message peek --queue-name <q>
```

---

## Summary

In this lesson, you learned:

- ✅ The four core Azure storage services
- ✅ How to choose redundancy options (LRS, ZRS, GRS, GZRS)
- ✅ Creating and configuring storage accounts
- ✅ Working with blobs and containers
- ✅ Using queues for messaging
- ✅ Managing access tiers for cost optimisation

---

## Next Steps

Continue to [Lesson 04: Networking Services](../04-networking/README.md) to learn about virtual networks and security.

---

## Additional Resources

- [Azure Storage Documentation](https://learn.microsoft.com/azure/storage/)
- [Storage Redundancy Overview](https://learn.microsoft.com/azure/storage/common/storage-redundancy)
- [Blob Storage Best Practices](https://learn.microsoft.com/azure/storage/blobs/storage-performance-checklist)
