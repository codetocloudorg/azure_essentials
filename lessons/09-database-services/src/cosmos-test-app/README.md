# Cosmos DB Test Application

Demonstrates CRUD operations with Azure Cosmos DB.

## Quick Start

### Bash/Zsh (macOS/Linux/Cloud Shell)

```bash
# Auto-discover Cosmos DB and run
COSMOS_ACCOUNT=$(az cosmosdb list --query "[0].name" -o tsv)
RG=$(az cosmosdb list --query "[0].resourceGroup" -o tsv)

export COSMOS_ENDPOINT=$(az cosmosdb show --name $COSMOS_ACCOUNT --resource-group $RG --query documentEndpoint -o tsv)
export COSMOS_KEY=$(az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG --query primaryMasterKey -o tsv)

pip install -r requirements.txt
python app.py
```

### PowerShell (Windows)

```powershell
# Auto-discover Cosmos DB and run
$cosmosAccount = (az cosmosdb list --query "[0].name" -o tsv)
$rg = (az cosmosdb list --query "[0].resourceGroup" -o tsv)

$env:COSMOS_ENDPOINT = (az cosmosdb show --name $cosmosAccount --resource-group $rg --query documentEndpoint -o tsv)
$env:COSMOS_KEY = (az cosmosdb keys list --name $cosmosAccount --resource-group $rg --query primaryMasterKey -o tsv)

pip install -r requirements.txt
python app.py
```

## Requirements

- Python 3.10+
- Azure CLI logged in
- Cosmos DB account with:
  - Database: `azure-essentials`
  - Container: `items` (partition key: `/category`)

## What It Does

1. **Create** - Adds sample items (laptop, phone, book)
2. **Read** - Queries items by category
3. **Update** - Modifies an item's description and price
4. **Delete** - Removes an item
