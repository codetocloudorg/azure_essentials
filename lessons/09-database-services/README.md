# Lesson 09: Database Services - Azure Cosmos DB

> **Duration**: 45 minutes | **Day**: 2

## What You'll Learn

In this lesson, you'll work with **Azure Cosmos DB**, a globally distributed NoSQL database. By the end, you'll be able to:

- Create a Cosmos DB account and understand serverless vs provisioned pricing
- Store and query JSON documents using Data Explorer
- Use partition keys for efficient data distribution
- Perform CRUD operations with the Python SDK

## Why Cosmos DB?

| Challenge             | How Cosmos DB Solves It                                   |
| --------------------- | --------------------------------------------------------- |
| Need flexible schema  | Store any JSON structure - no migrations needed           |
| Global users          | Automatic multi-region replication                        |
| Unpredictable traffic | Serverless mode scales to zero and auto-scales up         |
| Different data models | One service supports documents, graphs, key-value, tables |

**Real-world example**: E-commerce product catalogs, user profiles, IoT telemetry, gaming leaderboards - anywhere you need flexible, scalable data storage.

---

## Quick Start

```
┌─────────────────────────────────────────────────────────────────┐
│                    Lesson 09 Workflow                           │
├─────────────────────────────────────────────────────────────────┤
│  1. PORTAL: Create Cosmos DB account (5 min)                    │
│  2. PORTAL: Create database and container (3 min)               │
│  3. PORTAL: Add data using Data Explorer (5 min)                │
│  4. TERMINAL: Run Python app to test CRUD operations (10 min)   │
│  5. PORTAL: Query data with SQL syntax (5 min)                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- Completed infrastructure deployment (`azd up`)
- Azure Portal access

---

## Part 1: Create Cosmos DB (Azure Portal)

### Step 1: Create Cosmos DB Account

1. Go to [Azure Portal](https://portal.azure.com)
2. Search **"Cosmos DB"** → Click **Create**
3. Select **Azure Cosmos DB for NoSQL** → **Create**
4. Fill in:
   | Setting | Value |
   |---------|-------|
   | Subscription | Your subscription |
   | Resource Group | `rg-azure-essentials-dev` (or create new) |
   | Account Name | `cosmos-yourname-dev` (must be globally unique) |
   | Location | Same as other resources |
   | Capacity mode | **Serverless** (pay per request - best for learning) |

5. Click **Review + create** → **Create**
6. Wait for deployment (~3 minutes)

### Step 2: Create Database and Container

1. Go to your Cosmos DB account
2. Click **Data Explorer** in the left menu
3. Click **New Container**
4. Fill in:
   | Setting | Value |
   |---------|-------|
   | Database id | `azure-essentials` (check "Create new") |
   | Container id | `items` |
   | Partition key | `/category` |

5. Click **OK**

### Step 3: Add Test Data

1. In Data Explorer, expand **azure-essentials** → **items**
2. Click **Items** → **New Item**
3. Replace the JSON with:

```json
{
  "id": "1",
  "category": "electronics",
  "name": "Laptop",
  "description": "High-performance laptop",
  "price": 999.99
}
```

4. Click **Save**
5. Add a second item:

```json
{
  "id": "2",
  "category": "electronics",
  "name": "Phone",
  "description": "Smartphone with 5G",
  "price": 799.99
}
```

6. Add a third item in a different category:

```json
{
  "id": "3",
  "category": "books",
  "name": "Azure Guide",
  "description": "Learn Azure fundamentals",
  "price": 49.99
}
```

### Step 4: Query Your Data

1. In Data Explorer, click **New SQL Query**
2. Try these queries:

```sql
-- Get all items
SELECT * FROM c

-- Get items by category (uses partition key - efficient!)
SELECT * FROM c WHERE c.category = "electronics"

-- Get item names and prices
SELECT c.name, c.price FROM c

-- Filter by price
SELECT * FROM c WHERE c.price > 100
```

3. Click **Execute Query** to run each one

---

## Part 2: Test with Python App (Terminal)

### Option A: Bash/Zsh (macOS/Linux/Cloud Shell)

```bash
# 1. Auto-discover your Cosmos DB account
COSMOS_ACCOUNT=$(az cosmosdb list --query "[0].name" -o tsv)
RG=$(az cosmosdb list --query "[0].resourceGroup" -o tsv)
echo "Found: $COSMOS_ACCOUNT in $RG"

# 2. Get credentials
export COSMOS_ENDPOINT=$(az cosmosdb show --name $COSMOS_ACCOUNT --resource-group $RG --query documentEndpoint -o tsv)
export COSMOS_KEY=$(az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG --query primaryMasterKey -o tsv)

# 3. Clone repo and run the test app
git clone https://github.com/codetocloudorg/azure_essentials.git 2>/dev/null || true
cd azure_essentials/lessons/09-database-services/src/cosmos-test-app

# 4. Install dependencies and run
pip install --user -r requirements.txt
python app.py
```

### Option B: PowerShell (Windows)

```powershell
# 1. Auto-discover your Cosmos DB account
$cosmosAccount = (az cosmosdb list --query "[0].name" -o tsv)
$rg = (az cosmosdb list --query "[0].resourceGroup" -o tsv)
Write-Host "Found: $cosmosAccount in $rg"

# 2. Get credentials
$env:COSMOS_ENDPOINT = (az cosmosdb show --name $cosmosAccount --resource-group $rg --query documentEndpoint -o tsv)
$env:COSMOS_KEY = (az cosmosdb keys list --name $cosmosAccount --resource-group $rg --query primaryMasterKey -o tsv)

# 3. Clone repo and run the test app
git clone https://github.com/codetocloudorg/azure_essentials.git 2>$null
cd azure_essentials/lessons/09-database-services/src/cosmos-test-app

# 4. Install dependencies and run
pip install --user -r requirements.txt
python app.py
```

**Expected Output:**

```
==================================================
Cosmos DB CRUD Operations Demo
==================================================

1. Creating items...
Created item: abc123-...

2. Reading items...
Found 2 items in category 'electronics'
  - Laptop: High-performance laptop
  - Phone: Smartphone with 5G

3. Updating item...
Updated item: abc123-...

4. Verifying update...
  Updated description: Updated: High-performance gaming laptop
  New price: $1299.99

5. Deleting item...
Deleted item: def456-...

==================================================
Demo complete!
==================================================
```

---

## Part 3: Verify in Portal

1. Go back to **Data Explorer** in Azure Portal
2. Click **Refresh** on the container
3. You should see new items created by the Python app
4. Run a query to see all items:

```sql
SELECT * FROM c ORDER BY c.createdAt DESC
```

---

## Understanding the Code

The Python app in `src/cosmos-test-app/app.py` demonstrates CRUD operations:

| Operation  | Method                     | Description                            |
| ---------- | -------------------------- | -------------------------------------- |
| **Create** | `container.create_item()`  | Adds a new JSON document               |
| **Read**   | `container.query_items()`  | Queries with SQL syntax                |
| **Update** | `container.replace_item()` | Replaces entire document               |
| **Delete** | `container.delete_item()`  | Removes document by id + partition key |

### Key Code Patterns

**Connect to Cosmos DB:**

```python
from azure.cosmos import CosmosClient

client = CosmosClient(ENDPOINT, KEY)
database = client.get_database_client("azure-essentials")
container = database.get_container_client("items")
```

**Create an item:**

```python
item = {
    "id": str(uuid.uuid4()),       # Unique ID (required)
    "category": "electronics",      # Partition key (required)
    "name": "Laptop",
    "price": 999.99
}
container.create_item(body=item)
```

**Query items (using partition key for efficiency):**

```python
query = "SELECT * FROM c WHERE c.category = @category"
items = container.query_items(
    query=query,
    parameters=[{"name": "@category", "value": "electronics"}]
)
```

---

## Key Concepts

### Cosmos DB Basics

| Concept           | Description                                          |
| ----------------- | ---------------------------------------------------- |
| **Account**       | Top-level resource, globally unique name             |
| **Database**      | Logical container for multiple containers            |
| **Container**     | Where your data lives (like a table)                 |
| **Partition Key** | Property used to distribute data (e.g., `/category`) |
| **Item**          | A single JSON document                               |

### Why Serverless?

| Mode            | Best For                               | Billing             |
| --------------- | -------------------------------------- | ------------------- |
| **Serverless**  | Development, learning, spiky workloads | Pay per request     |
| **Provisioned** | Production, predictable workloads      | Reserved throughput |

### Consistency Levels

| Level        | Guarantee            | Use Case                    |
| ------------ | -------------------- | --------------------------- |
| **Strong**   | Always read latest   | Financial transactions      |
| **Session**  | Read your own writes | Most applications (default) |
| **Eventual** | May read stale data  | Analytics, metrics          |

---

## Troubleshooting

### "Permission denied" when installing packages

Use `--user` flag or a virtual environment:

```bash
# Option 1: Install for current user only
pip install --user -r requirements.txt

# Option 2: Use a virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows
pip install -r requirements.txt
```

### "Environment variable not set"

**Bash/Zsh:**

```bash
# Verify credentials are set
echo $COSMOS_ENDPOINT
echo $COSMOS_KEY
```

**PowerShell:**

```powershell
$env:COSMOS_ENDPOINT
$env:COSMOS_KEY
```

### "Database/Container not found"

The app expects:

- Database: `azure-essentials`
- Container: `items`
- Partition key: `/category`

Create them in Data Explorer if they don't exist.

### "Request rate too large (429)"

Serverless has request limits. Wait a moment and retry.

---

## Cleanup

Delete the Cosmos DB account when done:

**Bash/Zsh:**

```bash
az cosmosdb delete --name $COSMOS_ACCOUNT --resource-group $RG --yes
```

**PowerShell:**

```powershell
az cosmosdb delete --name $cosmosAccount --resource-group $rg --yes
```

---

## Summary

| Task                                   | Completed |
| -------------------------------------- | --------- |
| Created Cosmos DB account (Serverless) | ✅        |
| Created database and container         | ✅        |
| Added data via Portal                  | ✅        |
| Queried data with SQL                  | ✅        |
| Tested CRUD with Python app            | ✅        |

---

## Next Steps

Continue to [Lesson 10: Billing and Cost Optimisation](../10-billing-cost/README.md)

- [Cosmos DB Documentation](https://learn.microsoft.com/azure/cosmos-db/)
- [Azure SQL Documentation](https://learn.microsoft.com/azure/azure-sql/)
- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
