# 📜 Scripts Guide

> **Azure Essentials** | How to run scripts, preflight checks, and deployments

---

## 🚀 Quick Start for Learners

Follow these steps **before** starting any lesson:

### Step 1: Run Preflight Checks

**Before deploying anything**, validate your environment is properly configured:

| Platform        | Command                                 | Description                                 |
| --------------- | --------------------------------------- | ------------------------------------------- |
| **macOS**       | `./scripts/bash/validate-env.sh`        | Validates all tools, auth, and Azure access |
| **Linux**       | `./scripts/bash/validate-env.sh`        | Same as macOS                               |
| **Windows**     | `.\scripts\powershell\validate-env.ps1` | PowerShell validation script                |
| **Cloud Shell** | `az login && az account show`           | Minimal check for Cloud Shell               |

```bash
# macOS / Linux
chmod +x scripts/bash/validate-env.sh
./scripts/bash/validate-env.sh
```

```powershell
# Windows (PowerShell)
.\scripts\powershell\validate-env.ps1
```

✅ **Expected Output**: All green checkmarks (✓) for required tools

---

## 📁 Script Locations

```
scripts/
├── bash/                      # macOS & Linux scripts
│   ├── deploy.sh              # 🚀 Interactive lesson deployment
│   ├── validate-env.sh        # ✅ Preflight environment check
│   ├── setup-local-tools.sh   # 🔧 Install all required tools
│   ├── test-all-lessons.sh    # 🧪 Test all lesson deployments
│   ├── test-lessons-e2e.sh    # 🧪 End-to-end lesson validation
│   └── test-deployment.sh     # 🧪 Test a specific deployment
│
├── powershell/                # Windows scripts
│   ├── deploy.ps1             # 🚀 Interactive lesson deployment
│   ├── validate-env.ps1       # ✅ Preflight environment check
│   ├── setup-local-tools.ps1  # 🔧 Install all required tools
│   └── test-deploy.ps1        # 🧪 Test deployment
│
└── azure-cli/                 # Pure Azure CLI scripts (any OS)
    ├── deploy.sh              # 🚀 Interactive menu for CLI scripts
    ├── lesson-*.sh            # Individual lesson scripts
    ├── README.md              # CLI scripts documentation
    └── commands/              # 📋 Copy-paste command reference
        ├── README.md
        └── lesson-*.md        # Per-lesson CLI commands
```

---

## 🔧 Setup & Installation

### Install All Required Tools (One Command)

Don't have the tools installed? Run our automated setup:

| Platform                  | Command                                      |
| ------------------------- | -------------------------------------------- |
| **macOS**                 | `./scripts/bash/setup-local-tools.sh`        |
| **Linux (Ubuntu/Debian)** | `./scripts/bash/setup-local-tools.sh`        |
| **Windows**               | `.\scripts\powershell\setup-local-tools.ps1` |

This installs:

- ✅ Azure CLI (`az`)
- ✅ Azure Developer CLI (`azd`)
- ✅ Git
- ✅ Python 3.11+
- ✅ kubectl
- ✅ Docker (guided)
- ✅ VS Code extensions

---

## 🧪 Testing & Validation (For Trainers)

### End-to-End Lesson Tests

Before teaching, validate that lessons work correctly with live Azure resources:

```bash
# Test all lessons (06 + 07)
./scripts/bash/test-lessons-e2e.sh

# Test only Lesson 06 (Linux/MicroK8s)
./scripts/bash/test-lessons-e2e.sh 06

# Test only Lesson 07 (Containers/ACR/Container Apps)
./scripts/bash/test-lessons-e2e.sh 07
```

| What It Tests | Duration | Cost Estimate |
|---------------|----------|---------------|
| **Lesson 06**: VM → SSH → MicroK8s → Deploy nginx → NodePort → Browser access | ~10 min | ~$2 |
| **Lesson 07**: ACR → Build image → Container Apps → Public HTTPS URL | ~8 min | ~$3 |

> ⚠️ **Cost Warning**: This creates real Azure resources. Cleanup is offered at the end of the test.

---

## 🚀 Deployment Options

You have **three ways** to deploy lesson resources:

### Option 1: Interactive Deployment Script (Recommended)

The easiest way for beginners:

```bash
# macOS / Linux
./scripts/bash/deploy.sh

# Windows (PowerShell)
.\scripts\powershell\deploy.ps1
```

This guided script will:

1. ✅ Check all prerequisites
2. ✅ Let you choose a region (Top 5 North America regions)
3. ✅ Select specific lessons to deploy
4. ✅ Create separate resource groups per lesson

### Option 2: Azure Developer CLI (azd)

For more control, use `azd` directly:

```bash
# Authenticate
azd auth login

# Initialize environment
azd init

# Set region and lesson
azd env set AZURE_LOCATION eastus
azd env set LESSON_NUMBER 03    # Deploy Lesson 03 only

# Deploy
azd up

# Clean up when done
azd down --force --purge
```

### Option 3: Pure Azure CLI Scripts

Learn the actual Azure CLI commands (great for understanding what's happening):

```bash
# Interactive menu
./scripts/azure-cli/deploy.sh

# Or run individual lesson scripts
./scripts/azure-cli/lesson-03-storage.sh

# See the CLI commands without running
./scripts/azure-cli/lesson-03-storage.sh --commands

# Clean up resources
./scripts/azure-cli/lesson-03-storage.sh --cleanup
```

### Option 4: Copy-Paste Commands (Cloud Shell)

For Azure Cloud Shell or step-by-step learning, use the copy-paste reference:

1. Open [Azure Cloud Shell](https://shell.azure.com) → Select **Bash**
2. Browse to [`scripts/azure-cli/commands/`](scripts/azure-cli/commands/)
3. Open the lesson file (e.g., `lesson-03-storage.md`)
4. Copy and paste commands one at a time

---

## ✅ Preflight Checks Explained

### What the Validation Script Checks

| Check                   | Required?      | What It Verifies                    |
| ----------------------- | -------------- | ----------------------------------- |
| **Azure CLI**           | ✅ Yes         | `az` command available and version  |
| **Azure Developer CLI** | ✅ Yes         | `azd` command available             |
| **Git**                 | ✅ Yes         | `git` available for version control |
| **Azure CLI Login**     | ✅ Yes         | Authenticated to Azure subscription |
| **azd Login**           | ✅ Yes         | Authenticated for azd deployments   |
| **Python 3**            | 📌 Recommended | For Azure Functions & AI lessons    |
| **kubectl**             | 📌 Recommended | For Kubernetes lessons              |
| **Docker**              | 📌 Recommended | For container lessons               |
| **VS Code Extensions**  | 📌 Optional    | Bicep, Azure Tools installed        |

### Interpreting Results

```
✓ = Passed (green)    → All good, no action needed
✗ = Failed (red)      → Required - action needed before continuing
○ = Optional (yellow) → Recommended but not blocking
```

### Fixing Common Issues

```bash
# Azure CLI not authenticated
az login

# Azure Developer CLI not authenticated
azd auth login

# Scripts not executable (macOS/Linux)
chmod +x scripts/bash/*.sh
chmod +x scripts/azure-cli/*.sh

# Docker not running
# macOS/Windows: Start Docker Desktop
# Linux: sudo systemctl start docker
```

---

## 🔄 Script Comparison

| Feature          | `bash/` scripts     | `powershell/` scripts  | `azure-cli/` scripts  |
| ---------------- | ------------------- | ---------------------- | --------------------- |
| **Platform**     | macOS, Linux, WSL   | Windows                | Any (with bash)       |
| **Method**       | Azure Developer CLI | Azure Developer CLI    | Native `az` commands  |
| **Templates**    | Bicep (declarative) | Bicep (declarative)    | None (imperative)     |
| **Best For**     | Production-style    | Windows users          | Learning CLI commands |
| **Cloud Shell**  | ⚠️ Needs azd        | ❌ No                  | ✅ Yes                |
| **Dependencies** | azd, Bicep          | azd, Bicep, PowerShell | Azure CLI only        |

---

## 🧹 Cleanup

**Always clean up resources when done** to avoid charges:

### Option 1: Interactive Cleanup (Recommended)

The deploy scripts have a built-in cleanup option:

```bash
# macOS / Linux - Interactive menu (choose 'c' for cleanup)
./scripts/bash/deploy.sh

# macOS / Linux - Direct cleanup command
./scripts/bash/deploy.sh --cleanup

# Non-interactive (for scripting)
./scripts/bash/deploy.sh --cleanup --env azlearn-yourname --yes
```

```powershell
# Windows - Interactive menu (choose 'c' for cleanup)
.\scripts\powershell\deploy.ps1

# Windows - Direct cleanup command
.\scripts\powershell\deploy.ps1 -Cleanup

# Non-interactive (for scripting)
.\scripts\powershell\deploy.ps1 -Cleanup -Environment azlearn-yourname -Yes
```

### Option 2: Using azd

```bash
# Removes all resources deployed via azd
azd down --force --purge
```

### Option 3: Using Azure CLI scripts

```bash
./scripts/azure-cli/lesson-03-storage.sh --cleanup
```

### Option 4: Manual cleanup

```bash
# Delete a specific resource group
az group delete --name rg-yourname-lesson03-storage --yes --no-wait

# List all your resource groups
az group list --query "[?contains(name, 'yourname')].name" -o tsv
```

### What Gets Cleaned Up

The cleanup process removes:

- ✅ All lesson resource groups (rg-_-lesson_)
- ✅ Management groups (if Lesson 02 was deployed)
- ✅ Soft-deleted Key Vaults (purges them)
- ✅ Soft-deleted Cognitive Services (AI Foundry resources)

---

## 🆘 Troubleshooting

### "Permission denied" when running scripts

```bash
# macOS / Linux
chmod +x scripts/bash/*.sh
chmod +x scripts/azure-cli/*.sh
```

### "Command not found" after installation

```bash
# macOS / Linux - restart shell or source profile
source ~/.bashrc   # or ~/.zshrc

# Windows - restart PowerShell terminal
```

### Azure CLI login issues

```bash
# Clear cached credentials
az logout
az account clear

# Login again
az login
```

### azd deployment failures

```bash
# Check current status
azd show

# Debug mode for more info
azd up --debug

# If stuck, force cleanup and retry
azd down --force --purge
azd up
```

---

## 📖 More Resources

- [Prerequisites & Setup Guide](lessons/00-prerequisites/README.md) — Detailed installation instructions
- [Lesson Index](lessons/README.md) — Navigate all course lessons
- [Azure CLI Commands Reference](scripts/azure-cli/commands/README.md) — Copy-paste commands
- [Main README](README.md) — Course overview

---

**Happy Learning! 🎉**
