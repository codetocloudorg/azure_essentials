# Lesson 09: Database Services

> **Time:** 45 minutes | **Difficulty:** Medium | **Cost:** ~$1-5/day depending on choices

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created an Azure Cosmos DB account
- Added and queried data
- Understood different Azure database options
- Learned when to use each database type

---

## 🗄️ Azure Database Options

Azure offers many database services. Here's when to use each:

| Service | Type | Best For |
|---------|------|----------|
| **Cosmos DB** | NoSQL (multi-model) | Global apps, flexible schema |
| **SQL Database** | Relational | Traditional apps, ACID transactions |
| **MySQL/PostgreSQL** | Relational (open source) | Migrating existing apps |
| **Table Storage** | Key-value | Simple, cheap storage |
| **Redis Cache** | In-memory | Caching, sessions |

---

## 🌍 Azure Cosmos DB

Cosmos DB is Microsoft's globally-distributed, multi-model database.

### Why Cosmos DB?

| Feature | Benefit |
|---------|---------|
| **Global distribution** | Data replicated worldwide |
| **Multi-model** | Documents, graphs, key-value |
| **99.999% SLA** | Five 9s availability |
| **Serverless option** | Pay only for what you use |
| **Automatic indexing** | No index management needed |

---

## 🏗️ Create Cosmos DB Account

### Step 1: Set Up

```bash
# Variables
RG_NAME="rg-database-lesson"
LOCATION="centralus"
COSMOS_ACCOUNT="cosmos-demo-$RANDOM"  # Must be globally unique
DATABASE_NAME="TodoDB"
CONTAINER_NAME="Items"

# Create resource group
az group create --name $RG_NAME --location $LOCATION
```

### Step 2: Create Cosmos Account

```bash
az cosmosdb create \
  --resource-group $RG_NAME \
  --name $COSMOS_ACCOUNT \
  --kind GlobalDocumentDB \
  --locations regionName=$LOCATION \
  --default-consistency-level Session \
  --enable-free-tier true
```

> ⏱️ **Note:** This takes 3-5 minutes to provision.

### Step 3: Create Database and Container

```bash
# Create database
az cosmosdb sql database create \
  --resource-group $RG_NAME \
  --account-name $COSMOS_ACCOUNT \
  --name $DATABASE_NAME

# Create container with partition key
az cosmosdb sql container create \
  --resource-group $RG_NAME \
  --account-name $COSMOS_ACCOUNT \
  --database-name $DATABASE_NAME \
  --name $CONTAINER_NAME \
  --partition-key-path "/category" \
  --throughput 400
```

---

## 📝 Understanding Partition Keys

A **partition key** determines how data is distributed. Choose wisely!

### Good Partition Keys

| Scenario | Good Key | Why |
|----------|----------|-----|
| Todo app | `/userId` | Data grouped by user |
| E-commerce | `/category` | Products spread evenly |
| IoT data | `/deviceId` | Each device's data together |

### Bad Partition Keys

| Key | Problem |
|-----|---------|
| `/timestamp` | Hot partition (all writes go to "now") |
| `/country` | Uneven (most users in few countries) |
| Boolean values | Only 2 partitions! |

---

## ➕ Add Data

### Using Azure CLI

```bash
# Get the connection endpoint
ENDPOINT=$(az cosmosdb show --name $COSMOS_ACCOUNT --resource-group $RG_NAME --query documentEndpoint -o tsv)

# Get the primary key
KEY=$(az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG_NAME --query primaryMasterKey -o tsv)

echo "Endpoint: $ENDPOINT"
echo "Key: $KEY"
```

### Using the Portal (Data Explorer)

1. Go to your Cosmos DB account in the portal
2. Click **"Data Explorer"**
3. Expand `TodoDB` → `Items`
4. Click **"New Item"**
5. Add JSON:

```json
{
  "id": "1",
  "category": "work",
  "title": "Learn Azure",
  "completed": false,
  "priority": "high"
}
```

6. Click **"Save"**

### Using Python

```python
from azure.cosmos import CosmosClient

# Connection info (from above)
ENDPOINT = "https://cosmos-demo-xxxxx.documents.azure.com:443/"
KEY = "your-primary-key-here"

# Connect
client = CosmosClient(ENDPOINT, KEY)
database = client.get_database_client("TodoDB")
container = database.get_container_client("Items")

# Create item
item = {
    "id": "2",
    "category": "personal",
    "title": "Call mom",
    "completed": False,
    "priority": "high"
}
container.create_item(item)
print("Item created!")
```

Install SDK: `pip install azure-cosmos`

---

## 🔍 Query Data

### SQL-like Queries

Cosmos DB uses SQL syntax!

```sql
-- Get all items
SELECT * FROM c

-- Get incomplete work items
SELECT * FROM c 
WHERE c.category = "work" 
AND c.completed = false

-- Get just titles
SELECT c.title FROM c

-- Count items
SELECT VALUE COUNT(1) FROM c
```

### In Data Explorer

1. Click **"New SQL Query"**
2. Type your query
3. Click **"Execute Query"**

### In Python

```python
# Query items
query = "SELECT * FROM c WHERE c.category = @category"
parameters = [{"name": "@category", "value": "work"}]

items = container.query_items(
    query=query,
    parameters=parameters,
    enable_cross_partition_query=True
)

for item in items:
    print(item['title'])
```

---

## 📊 Consistency Levels

Cosmos DB offers 5 consistency levels:

| Level | Consistency | Performance |
|-------|-------------|-------------|
| **Strong** | Always see latest | Slowest |
| **Bounded Staleness** | Almost latest (within N seconds) | Slower |
| **Session** | Consistent for your session | Balanced ⭐ |
| **Consistent Prefix** | No out-of-order reads | Faster |
| **Eventual** | May see stale data briefly | Fastest |

**Recommendation:** Start with **Session** (the default).

---

## 💰 Understanding RU/s

Cosmos DB charges in **Request Units per second (RU/s)**.

| Operation | Approximate Cost |
|-----------|------------------|
| Read 1KB item | 1 RU |
| Write 1KB item | 5 RUs |
| Query (depends on complexity) | 2-1000+ RUs |

### Provisioned vs Serverless

| Mode | Best For | Cost |
|------|----------|------|
| **Provisioned** | Steady workloads | Pay for reserved RU/s |
| **Serverless** | Variable/dev workloads | Pay per request |
| **Autoscale** | Unpredictable spikes | Auto-adjusts RU/s |

---

## 🔌 Azure SQL Database

For relational data (tables, joins, transactions):

### Create SQL Database

```bash
SQL_SERVER="sql-demo-$RANDOM"
SQL_DB="MyDatabase"
SQL_USER="sqladmin"
SQL_PASS="P@ssw0rd1234!"  # Use a strong password!

# Create SQL Server
az sql server create \
  --resource-group $RG_NAME \
  --name $SQL_SERVER \
  --admin-user $SQL_USER \
  --admin-password $SQL_PASS \
  --location $LOCATION

# Create database
az sql db create \
  --resource-group $RG_NAME \
  --server $SQL_SERVER \
  --name $SQL_DB \
  --tier Basic
```

### Allow Your IP

```bash
MY_IP=$(curl -s ifconfig.me)

az sql server firewall-rule create \
  --resource-group $RG_NAME \
  --server $SQL_SERVER \
  --name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP
```

---

## 🆚 Cosmos DB vs SQL Database

| Feature | Cosmos DB | SQL Database |
|---------|-----------|--------------|
| Schema | Flexible (NoSQL) | Fixed (relational) |
| Scaling | Horizontal | Vertical |
| Global distribution | Built-in | Manual |
| Query language | SQL-like | Full T-SQL |
| Transactions | Limited | Full ACID |
| Joins | Limited | Full support |

### Choose Cosmos DB When:
- You need global distribution
- Schema changes frequently
- You want automatic scaling
- You're building new modern apps

### Choose SQL When:
- You need complex joins
- You have existing SQL skills/apps
- You need full ACID transactions
- Data relationships are important

---

## 🧹 Clean Up

```bash
az group delete --name $RG_NAME --yes
```

---

## ⚠️ Common Mistakes

| Mistake | Fix |
|---------|-----|
| 400 error on insert | Check partition key is included |
| Query returns nothing | Use `enable_cross_partition_query=True` |
| High RU usage | Check query plan, add indexes |
| Can't connect to SQL | Add firewall rule for your IP |

---

## ✅ What You Learned

- 🗄️ Different Azure database options
- 🌍 How to create and use Cosmos DB
- 📝 How partition keys work
- 🔍 How to query data with SQL-like syntax
- 💰 How RU/s pricing works

---

## ➡️ Next Steps

Let's understand how much this all costs!

👉 **[Lesson 10: Billing & Cost Management](Lesson-10-Billing-Cost)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
