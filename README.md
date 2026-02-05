```
   ██████╗ ██████╗ ██████╗ ███████╗    ████████╗ ██████╗
  ██╔════╝██╔═══██╗██╔══██╗██╔════╝    ╚══██╔══╝██╔═══██╗
  ██║     ██║   ██║██║  ██║█████╗         ██║   ██║   ██║
  ██║     ██║   ██║██║  ██║██╔══╝         ██║   ██║   ██║
  ╚██████╗╚██████╔╝██████╔╝███████╗       ██║   ╚██████╔╝
   ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝       ╚═╝    ╚═════╝

   ██████╗██╗      ██████╗ ██╗   ██╗██████╗
  ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗
  ██║     ██║     ██║   ██║██║   ██║██║  ██║
  ██║     ██║     ██║   ██║██║   ██║██║  ██║
  ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝
   ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝
```

# Azure Essentials Live Training

> **Code to Cloud** | A hands-on journey from local development to Azure mastery

[![Azure Developer CLI](https://img.shields.io/badge/azd-compatible-blue)](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Overview

Welcome to Azure Essentials, a comprehensive two-day training course that takes you from cloud fundamentals to deploying real-world solutions on Microsoft Azure. This repository contains all the materials, infrastructure code, and hands-on exercises you need to succeed.

📅 **[View Full Course Agenda](lessons/00-prerequisites/agenda.md)** — Detailed schedule with timings for each module

### What You Will Learn

- **Core Azure Concepts**: Understand IaaS, PaaS, SaaS, and serverless service models
- **Infrastructure Management**: Work with compute, storage, networking, and containers
- **Data Services**: Explore Cosmos DB and Microsoft Fabric for modern data workloads
- **Serverless and Automation**: Build with Azure Functions and Logic Apps
- **AI Integration**: Create intelligent applications with Azure AI Foundry
- **Cost Optimisation**: Manage billing, budgets, and resource governance

---

## 🎯 Before You Start (Learners Start Here!)

Before diving into any lesson, complete these steps:

### Step 1: Check Prerequisites

👉 **[Prerequisites & Setup Guide](lessons/00-prerequisites/README.md)** — Install all required tools for your OS (Windows, macOS, Linux)

### Step 2: Run Preflight Checks ⚡

**Run this BEFORE deploying anything** to catch issues early:

| Platform                 | Command                                 |
| ------------------------ | --------------------------------------- |
| **macOS / Linux**        | `./scripts/bash/validate-env.sh`        |
| **Windows (PowerShell)** | `.\scripts\powershell\validate-env.ps1` |

```bash
# macOS / Linux
./scripts/bash/validate-env.sh
```

```powershell
# Windows (PowerShell)
.\scripts\powershell\validate-env.ps1
```

✅ You should see **green checkmarks (✓)** for all required tools. Fix any red ✗ items before continuing.

### Step 3: Review the Scripts Guide

📜 **[SCRIPTS.md](SCRIPTS.md)** — Complete guide to running scripts, deployment options, and troubleshooting

---

## Quick Start

This course uses the [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) for a streamlined learning experience. With two commands, you can provision all resources and tear them down when finished.

### Prerequisites Checklist

| Requirement             | Description                                                                                                     |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Azure Account**       | [Free Azure account](https://azure.microsoft.com/free/) with active subscription                                |
| **Azure CLI**           | [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) version 2.50 or later              |
| **Azure Developer CLI** | [Install azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) version 1.5 or later |
| **Visual Studio Code**  | [Download VS Code](https://code.visualstudio.com/) with Bicep and Azure extensions                              |
| **Git**                 | [Install Git](https://git-scm.com/downloads) for version control                                                |

📅 **[Course Agenda](lessons/00-prerequisites/agenda.md)** — Full schedule with module timings and topics

> 💡 **New to Azure?** Follow our [detailed setup guide](lessons/00-prerequisites/README.md) with platform-specific instructions.

### Environment Setup

1. **Clone this repository**

   ```bash
   git clone https://github.com/yourorg/azure_essentials.git
   cd azure_essentials
   ```

2. **Run the Interactive Deployment Script** (Recommended)

   **macOS / Linux:**

   ```bash
   ./scripts/bash/deploy.sh
   ```

   **Windows (PowerShell):**

   ```powershell
   .\scripts\powershell\deploy.ps1
   ```

   This guided script will:
   - ✅ Check all prerequisites
   - ✅ Let you choose from **Top 5 North America regions** (best free tier capacity)
   - ✅ Select specific lessons to deploy
   - ✅ Create **separate resource groups per lesson** for clarity

3. **Or use azd directly** (Advanced)

   ```bash
   azd auth login
   azd init
   azd env set AZURE_LOCATION eastus      # Choose: eastus, eastus2, westus2, centralus, canadacentral
   azd env set LESSON_NUMBER 03           # Deploy specific lesson (03, 04, 05, 07, 08, 09, 11)
   azd up
   ```

### Resource Group Structure

Each lesson deploys to its **own resource group** for clarity:

```
rg-{your-name}-lz-platform-*         ← Lesson 02: Landing Zone Demo (6 RGs)
rg-{your-name}-lesson03-storage      ← Lesson 03: Storage Services
rg-{your-name}-lesson04-networking   ← Lesson 04: Networking
rg-{your-name}-lesson05-compute      ← Lesson 05: Windows Compute
rg-{your-name}-lesson06-linux-k8s    ← Lesson 06: Linux & MicroK8s
rg-{your-name}-lesson07-containers   ← Lesson 07: Container Services
rg-{your-name}-lesson08-serverless   ← Lesson 08: Azure Functions
rg-{your-name}-lesson09-database     ← Lesson 09: Cosmos DB
rg-{your-name}-lesson11-ai-foundry   ← Lesson 11: AI Foundry
```

### ⚠️ Quota Considerations

Some lessons require compute quota that may not be available on free accounts:

| Lesson              | Quota Required | If Deployment Fails                                        |
| ------------------- | -------------- | ---------------------------------------------------------- |
| 5 - Windows Compute | Basic VMs      | [Request quota increase](https://aka.ms/azurequotarequest) |
| 6 - Linux & K8s     | Standard_B2s   | Try a different region                                     |
| 8 - Serverless      | Dynamic VMs    | [Request quota increase](https://aka.ms/azurequotarequest) |
| 9 - Database        | Cosmos DB      | Use **Central US** region (best availability)              |

> 💡 **Tip**: Lessons 2, 3, 4, and 7 work reliably on free accounts without quota issues.

### Tear Down Resources

When you finish a session or the course, remove all resources to avoid charges:

**Option 1: Interactive Cleanup (Recommended)**

```bash
# macOS / Linux - Run deploy script and choose 'c' for cleanup
./scripts/bash/deploy.sh

# Or use direct cleanup command
./scripts/bash/deploy.sh --cleanup --env azlearn-yourname --yes
```

```powershell
# Windows - Run deploy script and choose 'c' for cleanup
.\scripts\powershell\deploy.ps1

# Or use direct cleanup command
.\scripts\powershell\deploy.ps1 -Cleanup -Environment azlearn-yourname -Yes
```

**Option 2: Using azd**

```bash
azd down --force --purge
```

> **Important**: Always run cleanup when you finish working to prevent unexpected Azure charges.

---

## 🌍 Recommended Regions (North America)

These regions have the **best capacity** for Azure free accounts:

| Region            | Location   | Recommendation                             |
| ----------------- | ---------- | ------------------------------------------ |
| **eastus**        | Virginia   | ⭐ Largest Azure region, best availability |
| **eastus2**       | Virginia   | ⭐ High capacity, good backup option       |
| **westus2**       | Washington | Good for West Coast learners               |
| **centralus**     | Iowa       | Central location                           |
| **canadacentral** | Toronto    | For Canadian learners                      |

---

## 💰 Cost Information for Azure Free Account Users

This course is designed to be **as cost-effective as possible** for learners using Azure free accounts. However, not all lessons are free.

### Free Tier Compatible Lessons

| Lesson    | Resources Used                | Free Tier Status                            |
| --------- | ----------------------------- | ------------------------------------------- |
| **01-03** | Storage Account (LRS)         | ✅ **FREE** - 5 GB included in free tier    |
| **04**    | Virtual Network, NSGs         | ✅ **FREE** - Networking resources are free |
| **05**    | App Service (F1 SKU)          | ✅ **FREE** - F1 tier is always free        |
| **06**    | Local MicroK8s only           | ✅ **FREE** - No Azure resources            |
| **08**    | Azure Functions (Consumption) | ✅ **FREE** - 1M executions/month free      |

### Paid Resources (Low Cost)

| Lesson | Resources Used             | Estimated Cost                                   |
| ------ | -------------------------- | ------------------------------------------------ |
| **07** | Container Registry (Basic) | 💵 ~$5/month (~$0.17/day)                        |
| **09** | Cosmos DB (Serverless)     | 💵 Pay-per-use (~$0.25 per 1M RUs)               |
| **11** | AI Foundry (Hub + Project) | 💵 ~$1-5/day (includes Key Vault, Log Analytics) |

### Recommendations for Free Account Users

1. **Deploy lessons progressively**: Use the `lessonNumber` parameter to deploy only what you need

   ```bash
   azd env set LESSON_NUMBER 5  # Deploy only lessons 1-5
   azd up
   ```

2. **Skip AI Foundry (Lesson 11)** if you want to stay completely free - you can follow along with the instructor's demo

3. **Always run `azd down`** at the end of each day to stop charges

4. **Monitor your spending** in the Azure Portal: Cost Management + Billing > Cost analysis

---

## Course Structure

This course is organised into 12 progressive lessons across two days. Each lesson builds upon previous concepts.

📅 **[View Detailed Agenda](lessons/00-prerequisites/agenda.md)** — Complete schedule with presentation times, demos, and breaks

### Day 1: Foundations

| Lesson                                              | Title                         | Duration  | Description                                                 |
| --------------------------------------------------- | ----------------------------- | --------- | ----------------------------------------------------------- |
| [00](lessons/00-prerequisites/README.md)            | Prerequisites & Setup         | 15-30 min | Set up your machine (Windows, macOS, or Linux)              |
| [01](lessons/01-introduction/README.md)             | Introduction to Azure         | 55 min    | Azure cloud concepts, service models, portal and CLI basics |
| [02](lessons/02-getting-started/README.md)          | Getting Started with Azure    | 20 min    | Accounts, subscriptions, tenants, and resource groups       |
| [03](lessons/03-storage-services/README.md)         | Storage Services              | 55 min    | Blobs, files, queues, tables, and storage redundancy        |
| [04](lessons/04-networking/README.md)               | Networking Services           | 35 min    | Virtual networks, subnets, NSGs, and load balancers         |
| [05](lessons/05-compute-windows/README.md)          | Compute: Windows              | 30 min    | Windows VMs, availability, and App Service deployment       |
| [06](lessons/06-compute-linux-kubernetes/README.md) | Compute: Linux and Kubernetes | 25 min    | Linux workloads and Kubernetes fundamentals with MicroK8s   |
| [07](lessons/07-container-services/README.md)       | Container Services            | 25 min    | Azure Container Registry and Azure Kubernetes Service       |

### Day 2: Advanced Services

| Lesson                                         | Title                         | Duration | Description                                             |
| ---------------------------------------------- | ----------------------------- | -------- | ------------------------------------------------------- |
| [08](lessons/08-serverless/README.md)          | Serverless Services           | 60 min   | Azure Functions, triggers, bindings, and Logic Apps     |
| [09](lessons/09-database-services/README.md)   | Database and Data Services    | 60 min   | Azure SQL, Cosmos DB, and Microsoft Fabric introduction |
| [10](lessons/10-billing-cost/README.md)        | Billing and Cost Optimisation | 20 min   | Cost management, budgets, and resource tagging          |
| [11](lessons/11-ai-foundry/README.md)          | Azure AI Foundry              | 45 min   | AI workspaces, model catalog, and chatbot development   |
| [12](lessons/12-architecture-design/README.md) | Architecture Design           | 45 min   | Collaborative design session for real-world scenarios   |

👉 **[View Full Lesson Index](lessons/README.md)** — Quick navigation to all lessons

---

## Repository Structure

```
azure_essentials/
├── README.md                 # This file - course overview and setup
├── SCRIPTS.md                # 📜 Scripts guide - how to run everything
├── azure.yaml                # Azure Developer CLI configuration
├── LICENSE                   # MIT License
│
├── .devcontainer/            # Development container configuration
│   └── devcontainer.json     # VS Code dev container settings
│
├── infra/                    # Infrastructure as Code (Bicep)
│   ├── main.bicep            # Main infrastructure orchestrator
│   ├── main.parameters.json  # Parameter values
│   ├── abbreviations.json    # Azure naming abbreviations
│   └── modules/              # Modular Bicep templates
│       ├── storage.bicep
│       ├── networking.bicep
│       ├── compute-windows.bicep
│       ├── linux-microk8s.bicep
│       ├── container-registry.bicep
│       ├── functions.bicep
│       ├── cosmosdb.bicep
│       ├── ai-foundry.bicep
│       └── management-groups.bicep
│
├── lessons/                  # Course lessons and exercises
│   ├── README.md             # Lesson index with quick navigation
│   ├── 00-prerequisites/     # Setup guide (start here!)
│   ├── 01-introduction/
│   ├── 02-getting-started/
│   └── ...                   # Lessons 03-12
│
├── scripts/                  # Deployment and setup scripts
│   ├── bash/                 # macOS/Linux scripts
│   │   ├── deploy.sh         # 🚀 Interactive deployment
│   │   ├── validate-env.sh   # ✅ Preflight checks
│   │   └── setup-local-tools.sh
│   ├── powershell/           # Windows scripts
│   │   ├── deploy.ps1        # 🚀 Interactive deployment
│   │   ├── validate-env.ps1  # ✅ Preflight checks
│   │   └── setup-local-tools.ps1
│   └── azure-cli/            # Pure Azure CLI scripts (any OS)
│       ├── commands/         # 📋 Copy-paste command reference
│       └── lesson-*.sh       # Per-lesson CLI scripts
│
├── CHANGELOG.md              # Version history
│
└── .devcontainer/            # VS Code Dev Container config
    └── devcontainer.json
```

---

## Working with This Repository

### Using the Dev Container (Recommended)

This repository includes a development container with all required tools pre-installed. To use it:

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VS Code extension
3. Open this repository in VS Code
4. When prompted, select **Reopen in Container**

The dev container includes:

- Azure CLI
- Azure Developer CLI (azd)
- Bicep CLI
- kubectl
- Docker CLI
- All recommended VS Code extensions

### Manual Setup

If you prefer not to use the dev container, run the setup script:

```bash
# macOS and Linux
./scripts/bash/setup-local-tools.sh
```

```powershell
# Windows (PowerShell)
.\scripts\powershell\setup-local-tools.ps1
```

Then **always run preflight checks** before deploying:

```bash
# macOS and Linux
./scripts/bash/validate-env.sh
```

```powershell
# Windows (PowerShell)
.\scripts\powershell\validate-env.ps1
```

📜 **[See the full Scripts Guide](SCRIPTS.md)** for all deployment options and troubleshooting.

---

## Troubleshooting

### Common Issues

#### Authentication Errors

If you encounter authentication issues:

```bash
# Clear cached credentials
azd auth logout
az logout

# Re-authenticate
azd auth login
az login
```

#### Resource Quota Exceeded

Free tier accounts have resource limits. If you hit quota limits:

1. Run `azd down` to remove existing resources
2. Wait a few minutes for cleanup to complete
3. Try `azd up` again

#### Deployment Failures

If a deployment fails:

```bash
# Check deployment status
azd show

# View detailed logs
azd deploy --debug
```

### Getting Help

- **Course Issues**: Raise an issue in this repository
- **Azure Documentation**: [Microsoft Learn](https://learn.microsoft.com/azure/)
- **Azure Developer CLI**: [azd Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)

---

## Additional Resources

### Recommended Follow-up

After completing this course, continue your Azure journey:

- 📖 [Learning Microsoft Azure](https://learning.oreilly.com/) (O'Reilly)
- 🎓 [AZ-900 Azure Fundamentals](https://learn.microsoft.com/certifications/azure-fundamentals/)
- 🧪 [Cloud Labs: AZ-900](https://learning.oreilly.com/) (Interactive Labs)
- 📺 [Azure Resource Center](https://azure.microsoft.com/resources/)

### Certification Paths

This course prepares you for:

| Certification                                                             | Level        | Focus               |
| ------------------------------------------------------------------------- | ------------ | ------------------- |
| [AZ-900](https://learn.microsoft.com/certifications/azure-fundamentals/)  | Foundational | Azure Fundamentals  |
| [AZ-104](https://learn.microsoft.com/certifications/azure-administrator/) | Associate    | Azure Administrator |
| [AZ-204](https://learn.microsoft.com/certifications/azure-developer/)     | Associate    | Azure Developer     |

---

## Contributing

This is Code to Cloud intellectual property. For contributions or corrections:

1. Fork this repository
2. Create a feature branch
3. Submit a pull request with a clear description

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgements

Created by **Kevin Evans** and the Code to Cloud team.

Built with ❤️ for the Azure community.
