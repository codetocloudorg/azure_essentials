"""
Cosmos DB Test Application
Azure Essentials - Lesson 09: Database and Data Services
Code to Cloud
"""
from azure.cosmos import CosmosClient, PartitionKey, exceptions
import os
import uuid
from datetime import datetime


# Configuration from environment variables
ENDPOINT = os.environ.get("COSMOS_ENDPOINT")
KEY = os.environ.get("COSMOS_KEY")
DATABASE_NAME = "azure-essentials"
CONTAINER_NAME = "items"


def get_container():
    """Get the Cosmos DB container client."""
    if not ENDPOINT or not KEY:
        raise ValueError(
            "Please set COSMOS_ENDPOINT and COSMOS_KEY environment variables"
        )

    client = CosmosClient(ENDPOINT, KEY)
    database = client.get_database_client(DATABASE_NAME)
    container = database.get_container_client(CONTAINER_NAME)
    return container


def create_item(container, category: str, name: str, description: str) -> dict:
    """
    Create a new item in the container.

    Args:
        container: The Cosmos DB container client
        category: The category (partition key)
        name: The item name
        description: The item description

    Returns:
        The created item
    """
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


def read_items(container, category: str) -> list:
    """
    Read items from a specific category.

    Args:
        container: The Cosmos DB container client
        category: The category to query

    Returns:
        List of items in the category
    """
    query = "SELECT * FROM c WHERE c.category = @category"
    parameters = [{"name": "@category", "value": category}]

    items = list(container.query_items(
        query=query,
        parameters=parameters,
        enable_cross_partition_query=False
    ))

    print(f"Found {len(items)} items in category '{category}'")
    return items


def update_item(container, item_id: str, category: str, updates: dict) -> dict:
    """
    Update an existing item.

    Args:
        container: The Cosmos DB container client
        item_id: The item ID
        category: The category (partition key)
        updates: Dictionary of fields to update

    Returns:
        The updated item
    """
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


def delete_item(container, item_id: str, category: str) -> None:
    """
    Delete an item.

    Args:
        container: The Cosmos DB container client
        item_id: The item ID
        category: The category (partition key)
    """
    container.delete_item(item=item_id, partition_key=category)
    print(f"Deleted item: {item_id}")


def main():
    """Run CRUD demonstration."""
    print("=" * 50)
    print("Cosmos DB CRUD Operations Demo")
    print("Azure Essentials - Lesson 09")
    print("=" * 50)

    try:
        container = get_container()
    except ValueError as e:
        print(f"Configuration error: {e}")
        return

    # CREATE
    print("\n1. Creating items...")
    item1 = create_item(
        container,
        "electronics",
        "Laptop",
        "High-performance laptop"
    )
    item2 = create_item(
        container,
        "electronics",
        "Phone",
        "Smartphone with 5G"
    )
    item3 = create_item(
        container,
        "books",
        "Azure Guide",
        "Learn Azure fundamentals"
    )

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

    # Final count
    print("\n6. Final item count...")
    remaining = read_items(container, "electronics")
    print(f"  Remaining electronics: {len(remaining)}")

    print("\n" + "=" * 50)
    print("Demo complete!")
    print("=" * 50)


if __name__ == "__main__":
    main()
