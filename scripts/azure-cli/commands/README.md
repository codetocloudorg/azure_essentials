# Copy-Paste Command Reference

This folder contains **copy-paste friendly** Azure CLI commands for each lesson.

## 📋 Purpose

These files are designed for learners who:

- Use **Azure Cloud Shell** and want to run commands one at a time
- Prefer copying individual commands rather than running scripts
- Want to understand each command before executing it

## 🚀 How to Use

1. Open [Azure Cloud Shell](https://shell.azure.com) (select **Bash**)
2. Open the lesson file you want to work through
3. Copy and paste commands one section at a time
4. Each section includes comments explaining what it does

## 📚 Available Lessons

| File | Lesson | Resources |
|------|--------|-----------|
| [lesson-02-management-groups.md](lesson-02-management-groups.md) | Management Groups | Management Group hierarchy |
| [lesson-03-storage.md](lesson-03-storage.md) | Storage Services | Storage Account, Containers, Queues |
| [lesson-04-networking.md](lesson-04-networking.md) | Networking | VNet, Subnets, NSG |
| [lesson-05-compute-windows.md](lesson-05-compute-windows.md) | Windows Compute | Windows VM, App Service |
| [lesson-06-compute-linux.md](lesson-06-compute-linux.md) | Linux Compute | Ubuntu VM, MicroK8s |
| [lesson-07-containers.md](lesson-07-containers.md) | Container Services | Container Registry |
| [lesson-08-serverless.md](lesson-08-serverless.md) | Serverless | Azure Functions |
| [lesson-09-databases.md](lesson-09-databases.md) | Database Services | Cosmos DB |
| [lesson-11-ai-foundry.md](lesson-11-ai-foundry.md) | AI Foundry | Azure OpenAI |

## 💡 Tips for Cloud Shell

```bash
# Check your current subscription
az account show --query name -o tsv

# List available locations
az account list-locations --query "[].name" -o tsv

# Set a different subscription
az account set --subscription "Your Subscription Name"
```

## ⚠️ Important Notes

- Commands use variables (like `$RESOURCE_GROUP`) - make sure to run the variable setup section first
- Each lesson has a **Cleanup** section at the end - always clean up to avoid charges
- Some resources take time to provision - wait for each command to complete
