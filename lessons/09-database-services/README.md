# Lesson 09: Database and Data Services

> **Duration**: 60 minutes | **Day**: 2

## Overview

Azure offers a comprehensive suite of database and data services for different workloads. This lesson covers relational databases, Cosmos DB for NoSQL, and introduces Microsoft Fabric for analytics.

## Learning Objectives

By the end of this lesson, you will be able to:

- Compare Azure database options for different scenarios
- Create and configure a Cosmos DB account
- Perform CRUD operations with Cosmos DB
- Understand Microsoft Fabric components
- Choose the right data service for your workload

---

## Key Concepts

### Azure Database Options

| Service | Type | Best For |
|---------|------|----------|
| **Azure SQL Database** | Relational (PaaS) | Enterprise apps, existing SQL workloads |
| **Azure SQL Managed Instance** | Relational (PaaS) | Lift-and-shift SQL Server |
| **PostgreSQL Flexible Server** | Relational (PaaS) | Open-source PostgreSQL apps |
| **MySQL Flexible Server** | Relational (PaaS) | Open-source MySQL apps |
| **Cosmos DB** | NoSQL (PaaS) | Global distribution, multiple data models |
| **Table Storage** | NoSQL | Simple key-value, low cost |

### Cosmos DB APIs

Cosmos DB supports multiple APIs for different data models:

| API | Data Model | Use Case |
|-----|------------|----------|
| **NoSQL** | Document (JSON) | Modern applications, flexible schema |
| **MongoDB** | Document | MongoDB compatibility |
| **PostgreSQL** | Relational | Distributed PostgreSQL |
| **Apache Cassandra** | Wide-column | High-scale write workloads |
| **Table** | Key-value | Azure Table Storage migration |
| **Apache Gremlin** | Graph | Relationship-heavy data |

### Cosmos DB Consistency Levels

| Level | Consistency | Performance | Use Case |
|-------|-------------|-------------|----------|
| **Strong** | Highest | Lowest | Financial transactions |
| **Bounded Staleness** | High | Medium | Inventory systems |
| **Session** | Medium | Medium | User sessions (default) |
| **Consistent Prefix** | Low | High | Social updates |
| **Eventual** | Lowest | Highest | Analytics, metrics |

---

## Hands-on Exercises

### Exercise 9.1: Create a Cosmos DB Account

**Objective**: Create a Cosmos DB account with the NoSQL API.

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="centralus"
COSMOS_ACCOUNT="cosmos-essentials-$(openssl rand -hex 4)"
DATABASE_NAME="azure-essentials"
CONTAINER_NAME="items"

# Create Cosmos DB account (serverless for cost efficiency)
az cosmosdb create \
  --name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --locations regionName=$LOCATION \
  --capabilities EnableServerless \
  --default-consistency-level Session

# Create a database
az cosmosdb sql database create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --name $DATABASE_NAME

# Create a container with partition key
az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --database-name $DATABASE_NAME \
  --name $CONTAINER_NAME \
  --partition-key-path "/category"

# Get the connection string
az cosmosdb keys list \
  --name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --type connection-strings \
  --query "connectionStrings[0].connectionString" \
  --output tsv
```

### Exercise 9.2: Work with Data in Cosmos DB

**Objective**: Perform CRUD operations using Python.

Create the test application:

```bash
mkdir -p cosmos-test-app && cd cosmos-test-app

cat > app.py << 'EOF'
"""
Cosmos DB Test Application
Azure Essentials - Lesson 09
"""
from azure.cosmos import CosmosClient, PartitionKey, exceptions
import os
import uuid
from datetime import datetime

# Configuration
ENDPOINT = os.environ.get("COSMOS_ENDPOINT")
KEY = os.environ.get("COSMOS_KEY")
DATABASE_NAME = "azure-essentials"
CONTAINER_NAME = "items"

def get_container():
    """Get the Cosmos DB container client."""
    client = CosmosClient(ENDPOINT, KEY)
    database = client.get_database_client(DATABASE_NAME)
    container = database.get_container_client(CONTAINER_NAME)
    return container

def create_item(container, category: str, name: str, description: str):
    """Create a new item in the container."""
    item = {
        "id": str(uuid.uuid4()),
        "category": category,
        "name": name,
        "description": description,
        "createdAt": datetime.utcnow().isoformat(),
        "status": "active"
    }
    
    result = container.create_item(body=item)
    print(f"Created item: {result['id']}")
    return result

def read_items(container, category: str):
    """Read items from a specific category."""
    query = "SELECT * FROM c WHERE c.category = @category"
    parameters = [{"name": "@category", "value": category}]
    
    items = list(container.query_items(
        query=query,
        parameters=parameters,
        enable_cross_partition_query=False
    ))
    
    print(f"Found {len(items)} items in category '{category}'")
    return items

def update_item(container, item_id: str, category: str, updates: dict):
    """Update an existing item."""
    # Read the item first
    item = container.read_item(item=item_id, partition_key=category)
    
    # Apply updates
    for key, value in updates.items():
        item[key] = value
    item["updatedAt"] = datetime.utcnow().isoformat()
    
    # Replace the item
    result = container.replace_item(item=item_id, body=item)
    print(f"Updated item: {result['id']}")
    return result

def delete_item(container, item_id: str, category: str):
    """Delete an item."""
    container.delete_item(item=item_id, partition_key=category)
    print(f"Deleted item: {item_id}")

def main():
    """Run CRUD demonstration."""
    print("=" * 50)
    print("Cosmos DB CRUD Operations Demo")
    print("=" * 50)
    
    container = get_container()
    
    # CREATE
    print("\n1. Creating items...")
    item1 = create_item(container, "electronics", "Laptop", "High-performance laptop")
    item2 = create_item(container, "electronics", "Phone", "Smartphone with 5G")
    item3 = create_item(container, "books", "Azure Guide", "Learn Azure fundamentals")
    
    # READ
    print("\n2. Reading items...")
    electronics = read_items(container, "electronics")
    for item in electronics:
        print(f"  - {item['name']}: {item['description']}")
    
    # UPDATE
    print("\n3. Updating item...")
    update_item(container, item1['id'], "electronics", {
        "description": "Updated: High-performance gaming laptop",
        "price": 1299.99
    })
    
    # READ again to verify
    print("\n4. Verifying update...")
    updated = container.read_item(item=item1['id'], partition_key="electronics")
    print(f"  Updated description: {updated['description']}")
    print(f"  New price: ${updated.get('price', 'N/A')}")
    
    # DELETE
    print("\n5. Deleting item...")
    delete_item(container, item2['id'], "electronics")
    
    print("\n" + "=" * 50)
    print("Demo complete!")
    print("=" * 50)

if __name__ == "__main__":
    main()
EOF

cat > requirements.txt << 'EOF'
azure-cosmos==4.7.0
EOF

cd ..
```

Run the application:

```bash
# Get Cosmos DB credentials
COSMOS_ENDPOINT=$(az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query documentEndpoint \
  --output tsv)

COSMOS_KEY=$(az cosmosdb keys list \
  --name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query primaryMasterKey \
  --output tsv)

# Set environment variables
export COSMOS_ENDPOINT
export COSMOS_KEY

# Install dependencies and run
cd cosmos-test-app
pip install -r requirements.txt
python app.py
cd ..
```

### Exercise 9.3: Explore Data in the Portal

**Objective**: Use the Azure Portal to explore your Cosmos DB data.

1. Navigate to your Cosmos DB account in the Azure Portal
2. Select **Data Explorer** from the left menu
3. Expand your database and container
4. Select **Items** to view your data
5. Try the following:
   - Click **New Item** to add data manually
   - Use **New SQL Query** to run queries
   - Explore the **Scale & Settings** for the container

### Exercise 9.4: Microsoft Fabric Overview

**Objective**: Understand the components of Microsoft Fabric.

Microsoft Fabric is an end-to-end analytics platform:

| Component | Description |
|-----------|-------------|
| **Data Factory** | Data integration and ETL pipelines |
| **Synapse Data Engineering** | Big data processing with Spark |
| **Synapse Data Warehouse** | Enterprise data warehousing |
| **Synapse Data Science** | Machine learning workflows |
| **Synapse Real-Time Analytics** | Stream processing and analytics |
| **Power BI** | Business intelligence and visualisation |
| **OneLake** | Unified data lake storage |

> **Note**: Microsoft Fabric requires a separate license. In this course, we focus on understanding its architecture and use cases.

---

## Choosing the Right Database

Use this decision guide:

```
Is your data relational (tables, joins)?
├── Yes → Do you need SQL Server compatibility?
│         ├── Yes → Azure SQL Database or Managed Instance
│         └── No → PostgreSQL or MySQL Flexible Server
│
└── No → Is global distribution required?
          ├── Yes → Cosmos DB
          └── No → What's your priority?
                    ├── Low cost → Table Storage
                    ├── Flexible schema → Cosmos DB
                    └── Graph relationships → Cosmos DB (Gremlin)
```

---

## Key Commands Reference

```bash
# Cosmos DB
az cosmosdb create --name <n> --capabilities EnableServerless
az cosmosdb sql database create --account-name <a> --name <db>
az cosmosdb sql container create --database-name <db> --name <c>
az cosmosdb keys list --name <n> --type connection-strings

# Azure SQL (reference)
az sql server create --name <n> --admin-user <u>
az sql db create --server <s> --name <db>
```

---

## Summary

In this lesson, you learned:

- ✅ Azure database options comparison
- ✅ Cosmos DB APIs and consistency models
- ✅ Creating and configuring Cosmos DB
- ✅ CRUD operations with Cosmos DB SDK
- ✅ Microsoft Fabric components overview

---

## Next Steps

Continue to [Lesson 10: Billing and Cost Optimisation](../10-billing-cost/README.md) to manage Azure spending.

---

## Additional Resources

- [Cosmos DB Documentation](https://learn.microsoft.com/azure/cosmos-db/)
- [Azure SQL Documentation](https://learn.microsoft.com/azure/azure-sql/)
- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
