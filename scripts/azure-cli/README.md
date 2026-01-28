# Azure CLI Deployment Scripts

This folder contains **pure Azure CLI** scripts for deploying lesson resources. These scripts use native `az` commands instead of Bicep templates or Azure Developer CLI (azd).

📜 **[← Back to Main Scripts Guide](../../SCRIPTS.md)** — Overview of all scripts and deployment options

## Why Use These Scripts?

1. **Learn the Commands** - See exactly what Azure CLI commands create each resource
2. **Cloud Shell Ready** - Works directly in Azure Cloud Shell (any browser, any OS)
3. **No Dependencies** - Only requires Azure CLI - no azd, Bicep, or other tools
4. **Educational** - Each script is heavily commented and shows best practices

## 📋 Copy-Paste Commands for Cloud Shell

**New!** The [`commands/`](commands/) folder contains copy-paste friendly markdown files for each lesson. Perfect for:

- **Azure Cloud Shell users** who want to run commands one at a time
- **Learners** who prefer to understand each command before executing
- **Quick reference** during hands-on labs

👉 **[Go to Copy-Paste Commands](commands/README.md)**

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- An active Azure subscription
- Appropriate permissions for the resources being created

### Using Azure Cloud Shell

If you don't have Azure CLI installed locally, use [Azure Cloud Shell](https://shell.azure.com):

1. Go to https://shell.azure.com
2. Select **Bash**
3. Open the [commands/](commands/) folder in GitHub to copy commands
4. Paste and run commands one at a time

## Available Scripts

| Script                           | Description                           | Resources Created                      | Copy-Paste                                    |
| -------------------------------- | ------------------------------------- | -------------------------------------- | --------------------------------------------- |
| `deploy.sh`                      | Interactive menu to deploy any lesson | All lessons                            | -                                             |
| `lesson-02-management-groups.sh` | Management group hierarchy            | Management Groups                      | [📋](commands/lesson-02-management-groups.md) |
| `lesson-03-storage.sh`           | Storage account with containers       | Storage Account, Blobs, Queues, Tables | [📋](commands/lesson-03-storage.md)           |
| `lesson-04-networking.sh`        | Virtual network with subnets          | VNet, Subnets, NSG                     | [📋](commands/lesson-04-networking.md)        |
| `lesson-05-compute-windows.sh`   | Windows VM and App Service            | Windows Server 2022, Web App           | [📋](commands/lesson-05-compute-windows.md)   |
| `lesson-06-compute-linux.sh`     | Linux VM with MicroK8s                | Ubuntu 24.04, Kubernetes               | [📋](commands/lesson-06-compute-linux.md)     |
| `lesson-07-containers.sh`        | Container registry                    | Azure Container Registry               | [📋](commands/lesson-07-containers.md)        |
| `lesson-08-serverless.sh`        | Function app                          | Azure Functions (Python)               | [📋](commands/lesson-08-serverless.md)        |
| `lesson-09-databases.sh`         | Cosmos DB                             | Cosmos DB (Serverless)                 | [📋](commands/lesson-09-databases.md)         |
| `lesson-11-ai-foundry.sh`        | AI services                           | Azure OpenAI / Cognitive Services      | [📋](commands/lesson-11-ai-foundry.md)        |

## Usage

### Option 1: Copy-Paste Commands (Cloud Shell)

For **Azure Cloud Shell** users who want to run commands one at a time:

1. Open [Azure Cloud Shell](https://shell.azure.com) and select **Bash**
2. Go to the [`commands/`](commands/) folder
3. Open the lesson you want (e.g., `lesson-03-storage.md`)
4. Copy each command block and paste into Cloud Shell

### Option 2: Interactive Menu

```bash
./deploy.sh
```

Select a lesson number from the menu to deploy.

### Option 3: Individual Lesson Scripts

```bash
# Deploy a specific lesson
./lesson-03-storage.sh

# Show available CLI commands for reference
./lesson-03-storage.sh --commands

# Clean up resources
./lesson-03-storage.sh --cleanup
```

### Customizing Deployment

Set environment variables to customize:

```bash
# Change location (default: centralus)
export LOCATION=eastus

# Change resource group name
export RESOURCE_GROUP=my-custom-rg

# Then run the script
./lesson-03-storage.sh
```

## Script Features

Each script includes:

- **Step-by-step deployment** with colored output
- **Error handling** with automatic rollback suggestions
- **Command reference** (`--commands` flag) showing key Azure CLI commands
- **Cleanup function** (`--cleanup` flag) to delete resources
- **Summary output** with connection details and next steps

## Lessons Without Resources

Some lessons are portal/CLI demos and don't require deployed resources:

- **Lesson 01**: Introduction to Azure (Portal overview)
- **Lesson 10**: Billing & Cost Management (Portal demo)
- **Lesson 12**: Architecture & Design (Best practices discussion)

## Cleanup

To avoid charges, clean up resources when done:

```bash
# Cleanup specific lesson
./lesson-03-storage.sh --cleanup

# Or use the main deploy script
./deploy.sh
# Then select 'c' for cleanup
```

## Comparison with Other Scripts

| Feature           | azure-cli/            | bash/ (azd)             | powershell/ (azd)        |
| ----------------- | --------------------- | ----------------------- | ------------------------ |
| Deployment Method | Native `az` commands  | Azure Developer CLI     | Azure Developer CLI      |
| Templates         | None (imperative)     | Bicep (declarative)     | Bicep (declarative)      |
| Best For          | Learning CLI commands | Production deployments  | Windows users            |
| Cloud Shell       | ✅ Yes                | ⚠️ Requires azd install | ❌ No                    |
| Dependencies      | Azure CLI only        | azd + Bicep             | azd + Bicep + PowerShell |

## Troubleshooting

### Permission Errors

```bash
# Make scripts executable
chmod +x *.sh
```

### Azure CLI Not Logged In

```bash
az login
az account set --subscription "Your Subscription Name"
```

### Region Not Available

Some resources (like Azure OpenAI) may not be available in all regions:

```bash
export LOCATION=eastus2
./lesson-11-ai-foundry.sh
```
