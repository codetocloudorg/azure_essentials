# Lesson 09: Database & Data Services - Copy-Paste Commands

> Azure SQL, Cosmos DB, and Microsoft Fabric

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="centralus"
RESOURCE_GROUP="rg-essentials-databases"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
COSMOS_ACCOUNT="cosmos-essentials-${UNIQUE_SUFFIX}"
DATABASE_NAME="essentials-db"
CONTAINER_NAME="items"

# Display the account name (save this!)
echo "Cosmos DB Account: $COSMOS_ACCOUNT"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=09-databases"
```

---

## Step 2: Create Cosmos DB Account

> ⏱️ This takes 5-10 minutes to provision

```bash
# Create Cosmos DB account (Serverless capacity mode)
az cosmosdb create \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --locations regionName="$LOCATION" \
    --capacity-mode Serverless \
    --default-consistency-level Session
```

---

## Step 3: Create Database

```bash
# Create a SQL API database
az cosmosdb sql database create \
    --account-name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DATABASE_NAME"
```

---

## Step 4: Create Container

```bash
# Create a container with partition key
az cosmosdb sql container create \
    --account-name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --database-name "$DATABASE_NAME" \
    --name "$CONTAINER_NAME" \
    --partition-key-path "/category"
```

---

## Step 5: Get Connection String

```bash
# Get the primary connection string
az cosmosdb keys list \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --type connection-strings \
    --query "connectionStrings[0].connectionString" \
    -o tsv
```

```bash
# Get the primary key
az cosmosdb keys list \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query primaryMasterKey \
    -o tsv
```

---

## Step 6: Get Account Endpoint

```bash
# Get the document endpoint
az cosmosdb show \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query documentEndpoint \
    -o tsv
```

---

## Step 7: Insert Sample Documents

```bash
# Store the key for operations
COSMOS_KEY=$(az cosmosdb keys list \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query primaryMasterKey \
    -o tsv)

COSMOS_ENDPOINT=$(az cosmosdb show \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query documentEndpoint \
    -o tsv)
```

### Using Python (in Cloud Shell)

```bash
# Install the SDK
pip install azure-cosmos --quiet

# Create and run a Python script
python3 << 'EOF'
import os
from azure.cosmos import CosmosClient

endpoint = os.environ.get('COSMOS_ENDPOINT')
key = os.environ.get('COSMOS_KEY')

client = CosmosClient(endpoint, key)
database = client.get_database_client("essentials-db")
container = database.get_container_client("items")

# Insert sample items
items = [
    {"id": "1", "name": "Azure VM", "category": "compute", "price": 100},
    {"id": "2", "name": "Azure Functions", "category": "serverless", "price": 50},
    {"id": "3", "name": "Cosmos DB", "category": "database", "price": 75},
    {"id": "4", "name": "Azure Storage", "category": "storage", "price": 25}
]

for item in items:
    container.upsert_item(item)
    print(f"Inserted: {item['name']}")

print("\nDone! Inserted 4 items.")
EOF
```

---

## Step 8: Query Documents

```bash
# Query using Python
python3 << 'EOF'
import os
from azure.cosmos import CosmosClient

endpoint = os.environ.get('COSMOS_ENDPOINT')
key = os.environ.get('COSMOS_KEY')

client = CosmosClient(endpoint, key)
database = client.get_database_client("essentials-db")
container = database.get_container_client("items")

# Query all items
print("All items:")
for item in container.query_items(
    query="SELECT * FROM c",
    enable_cross_partition_query=True
):
    print(f"  - {item['name']} ({item['category']}): ${item['price']}")

# Query by category
print("\nServerless items:")
for item in container.query_items(
    query="SELECT * FROM c WHERE c.category = 'serverless'",
    enable_cross_partition_query=True
):
    print(f"  - {item['name']}: ${item['price']}")
EOF
```

---

## 📊 View Cosmos DB Info

```bash
# Show account details
az cosmosdb show \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, Location:locations[0].locationName, Consistency:consistencyPolicy.defaultConsistencyLevel}" \
    -o table
```

```bash
# List databases
az cosmosdb sql database list \
    --account-name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name}" \
    -o table
```

```bash
# List containers
az cosmosdb sql container list \
    --account-name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --database-name "$DATABASE_NAME" \
    --query "[].{Name:name, PartitionKey:resource.partitionKey.paths[0]}" \
    -o table
```

---

## 📚 Additional Commands

### Create Additional Index

```bash
# Update indexing policy
az cosmosdb sql container update \
    --account-name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --database-name "$DATABASE_NAME" \
    --name "$CONTAINER_NAME" \
    --idx '{"indexingMode":"consistent","includedPaths":[{"path":"/*"}],"excludedPaths":[{"path":"/\"_etag\"/?"}]}'
```

### Delete a Container

```bash
# az cosmosdb sql container delete \
#     --account-name "$COSMOS_ACCOUNT" \
#     --resource-group "$RESOURCE_GROUP" \
#     --database-name "$DATABASE_NAME" \
#     --name "container-to-delete" \
#     --yes
```

### Regenerate Keys

```bash
# Regenerate the primary key
az cosmosdb keys regenerate \
    --name "$COSMOS_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --key-kind primary
```

---

## 🧹 Cleanup

```bash
# Delete the entire resource group
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
| `az cosmosdb create` | Create Cosmos DB account |
| `az cosmosdb sql database create` | Create a database |
| `az cosmosdb sql container create` | Create a container |
| `az cosmosdb keys list` | Get access keys |
| `az cosmosdb show` | Show account details |

---

## 🏗️ Capacity Modes

| Feature | Serverless | Provisioned |
|---------|------------|-------------|
| Scaling | Auto | Manual/Auto |
| Billing | Per request | Per RU/s |
| Best For | Dev/Test, Sporadic | Production |
| Max Storage | 1 TB per container | Unlimited |
| Multi-region | Single region | Yes |

---

## 🔑 Consistency Levels

1. **Strong** - Linearizable reads
2. **Bounded Staleness** - Reads lag writes by K versions or T time
3. **Session** - Consistent within a session (default)
4. **Consistent Prefix** - Reads never see out-of-order writes
5. **Eventual** - No ordering guarantee, lowest latency
