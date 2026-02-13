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

[![Website](https://img.shields.io/badge/codetocloud.io-00A4EF?logo=microsoft-edge&logoColor=white)](https://www.codetocloud.io)
[![Open in GitHub Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-black?logo=github)](https://codespaces.new/codetocloudorg/azure_essentials)
[![Azure Developer CLI](https://img.shields.io/badge/azd-compatible-blue)](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-Join%20Us-5865F2?logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)
[![Podcast](https://img.shields.io/badge/Podcast-Spotify-1DB954?logo=spotify&logoColor=white)](https://open.spotify.com/show/1iOZfFVamUk7CJPOvtU00v)

---

## Get Started in 60 Seconds

**The fastest way to start** — no installation required!

[![Open in GitHub Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-black?style=for-the-badge&logo=github)](https://codespaces.new/codetocloudorg/azure_essentials)

Click above to launch a fully-configured environment with all tools pre-installed.

---

> **🆕 New to Azure?** Start with the [Wiki for Learners](wiki/Home.md) — it walks you through everything step by step. Not sure what a term means? Check the [Glossary](wiki/Glossary.md).
>
> **Don't want to install anything?** Use [Azure Cloud Shell](https://shell.azure.com) — it runs in your browser with all tools pre-installed. Just sign in and paste commands from our [copy-paste reference](scripts/azure-cli/commands/).

## Quick Links

| Link                                                | Description                              |
| --------------------------------------------------- | ---------------------------------------- |
| [Wiki for Learners](wiki/Home.md)                   | Beginner-friendly step-by-step guides    |
| [Glossary](wiki/Glossary.md)                        | Plain-English definitions of Azure terms |
| [Course Agenda](lessons/00-prerequisites/agenda.md) | Full schedule with timings               |
| [Lesson Index](lessons/README.md)                   | All 12 lessons at a glance               |
| [Discord Community](https://discord.gg/vwfwq2EpXJ)  | Get help and connect                     |

---

<details>
<summary><strong>Local Setup (if not using Codespaces)</strong></summary>

### Prerequisites

| Tool                | Installation                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------------ |
| Azure Account       | [Create free account](https://azure.microsoft.com/free/)                                         |
| Azure CLI           | [Install](https://learn.microsoft.com/cli/azure/install-azure-cli) v2.50+                        |
| Azure Developer CLI | [Install azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) v1.5+ |
| VS Code             | [Download](https://code.visualstudio.com/) with Bicep extension                                  |
| Git                 | [Install](https://git-scm.com/downloads)                                                         |

### Setup Steps

> **💡 All commands below should be run from the project root folder** (`azure_essentials/`). If you're not sure how to open a terminal, see the [Scripts Guide](SCRIPTS.md#-where-do-i-run-these-commands) for help.

```bash
# 1. Clone the repo
git clone https://github.com/codetocloudorg/azure_essentials.git
cd azure_essentials

# 2. Run preflight checks
./scripts/bash/validate-env.sh        # macOS/Linux
.\scripts\powershell\validate-env.ps1 # Windows
```

See [Prerequisites Guide](lessons/00-prerequisites/README.md) for detailed platform instructions.

</details>

<details>
<summary><strong>Deploy with Azure Developer CLI</strong></summary>

### Interactive Deployment (Recommended)

```bash
# macOS / Linux
./scripts/bash/deploy.sh

# Windows
.\scripts\powershell\deploy.ps1
```

### Direct azd Commands

```bash
azd auth login
azd init
azd env set AZURE_LOCATION eastus
azd env set LESSON_NUMBER 03    # Deploy specific lesson
azd up
```

### Resource Groups Created

Each lesson deploys to its own resource group:

```
rg-{name}-lesson03-storage      <- Lesson 03: Storage
rg-{name}-lesson04-networking   <- Lesson 04: Networking
rg-{name}-lesson05-compute      <- Lesson 05: Windows VM
rg-{name}-lesson07-containers   <- Lesson 07: Containers
...
```

### Cleanup

```bash
azd down --force --purge    # Remove all resources
```

See [SCRIPTS.md](SCRIPTS.md) for all options.

</details>

<details>
<summary><strong>Course Structure (12 Lessons)</strong></summary>

### Day 1: Foundations

| #   | Lesson                                                         | Time   | Topic                             |
| --- | -------------------------------------------------------------- | ------ | --------------------------------- |
| 00  | [Prerequisites](lessons/00-prerequisites/README.md)            | 15 min | Setup                             |
| 01  | [Introduction](lessons/01-introduction/README.md)              | 55 min | Azure concepts                    |
| 02  | [Getting Started](lessons/02-getting-started/README.md)        | 20 min | Subscriptions and resource groups |
| 03  | [Storage](lessons/03-storage-services/README.md)               | 55 min | Blobs, files, queues              |
| 04  | [Networking](lessons/04-networking/README.md)                  | 35 min | VNets, NSGs, load balancers       |
| 05  | [Windows Compute](lessons/05-compute-windows/README.md)        | 30 min | VMs, App Service                  |
| 06  | [Linux and K8s](lessons/06-compute-linux-kubernetes/README.md) | 25 min | Linux VMs, MicroK8s               |
| 07  | [Containers](lessons/07-container-services/README.md)          | 25 min | ACR, AKS, Container Apps          |

### Day 2: Advanced Services

| #   | Lesson                                                   | Time   | Topic                  |
| --- | -------------------------------------------------------- | ------ | ---------------------- |
| 08  | [Serverless](lessons/08-serverless/README.md)            | 60 min | Functions, Logic Apps  |
| 09  | [Databases](lessons/09-database-services/README.md)      | 60 min | SQL, Cosmos DB, Fabric |
| 10  | [Billing](lessons/10-billing-cost/README.md)             | 20 min | Cost management        |
| 11  | [AI Foundry](lessons/11-ai-foundry/README.md)            | 45 min | AI models, chatbots    |
| 12  | [Architecture](lessons/12-architecture-design/README.md) | 45 min | Design patterns        |

</details>

<details>
<summary><strong>Cost and Region Information</strong></summary>

### Free Tier Compatible

| Lessons | Resources               | Cost |
| ------- | ----------------------- | ---- |
| 01-04   | Storage, VNet, NSGs     | FREE |
| 05      | App Service (F1)        | FREE |
| 06      | Local MicroK8s          | FREE |
| 08      | Functions (Consumption) | FREE |

### Low Cost (around $1-5/day)

| Lesson | Resources              | Est. Cost   |
| ------ | ---------------------- | ----------- |
| 07     | Container Registry     | ~$0.17/day  |
| 09     | Cosmos DB (Serverless) | Pay-per-use |
| 11     | AI Foundry             | ~$1-5/day   |

### Recommended Regions (North America)

| Region        | Location   | Notes              |
| ------------- | ---------- | ------------------ |
| eastus        | Virginia   | Best availability  |
| eastus2       | Virginia   | Good backup        |
| centralus     | Iowa       | Good for Cosmos DB |
| westus2       | Washington | West Coast         |
| canadacentral | Toronto    | Canadian learners  |

</details>

<details>
<summary><strong>Repository Structure</strong></summary>

```
azure_essentials/
├── README.md                 # This file
├── SCRIPTS.md                # Scripts guide
├── azure.yaml                # azd configuration
├── wiki/                     # Beginner-friendly guides
│
├── lessons/                  # Course content
│   ├── 00-prerequisites/
│   ├── 01-introduction/
│   └── ...                   # Through 12-architecture
│
├── infra/                    # Bicep templates
│   ├── main.bicep
│   └── modules/
│
├── scripts/
│   ├── bash/                 # macOS/Linux
│   │   ├── deploy.sh
│   │   └── validate-env.sh
│   ├── powershell/           # Windows
│   │   ├── deploy.ps1
│   │   └── validate-env.ps1
│   └── azure-cli/            # CLI reference
│
└── .devcontainer/            # Dev container config
```

</details>

<details>
<summary><strong>Troubleshooting</strong></summary>

### Authentication Issues

```bash
azd auth logout && az logout
azd auth login && az login
```

### Quota Exceeded

1. Run `azd down` to remove resources
2. Wait a few minutes
3. Try a different region or [request quota increase](https://aka.ms/azurequotarequest)

### Deployment Failures

```bash
azd show            # Check status
azd deploy --debug  # Detailed logs
```

### More Help

- [Troubleshooting Wiki](wiki/Troubleshooting.md) - Common problems and fixes
- [GitHub Issues](https://github.com/codetocloudorg/azure_essentials/issues) - Report bugs
- [Discord](https://discord.gg/vwfwq2EpXJ) - Ask the community

</details>

<details>
<summary><strong>Resources and Certifications</strong></summary>

### Continue Learning

- [AZ-900 Azure Fundamentals](https://learn.microsoft.com/certifications/azure-fundamentals/) - Entry certification
- [AZ-104 Azure Administrator](https://learn.microsoft.com/certifications/azure-administrator/) - Admin path
- [AZ-204 Azure Developer](https://learn.microsoft.com/certifications/azure-developer/) - Developer path
- [Microsoft Learn](https://learn.microsoft.com/azure/) - Free training

### Community

[![Website](https://img.shields.io/badge/Website-codetocloud.io-00A4EF?style=for-the-badge&logo=microsoft-edge&logoColor=white)](https://www.codetocloud.io)
[![Discord](https://img.shields.io/badge/Discord-Join%20Us-5865F2?logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/vwfwq2EpXJ)
[![Podcast](https://img.shields.io/badge/Podcast-Listen%20on%20Spotify-1DB954?logo=spotify&logoColor=white&style=for-the-badge)](https://open.spotify.com/show/1iOZfFVamUk7CJPOvtU00v)

</details>

---

## Contributing

This is Code to Cloud Inc. intellectual property. For contributions:

1. Fork this repository
2. Create a feature branch
3. Submit a pull request

---

## License

Copyright (c) 2024-2026 Code to Cloud Inc. | [MIT License](LICENSE)

Created by **Kevin Evans** and the Code to Cloud Inc. team. Built with love for the Azure community.
