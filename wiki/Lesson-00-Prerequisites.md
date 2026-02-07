# Lesson 00: Prerequisites

> **Time:** 15-30 minutes | **Difficulty:** Easy | **Cost:** $0

## 🎯 What You'll Accomplish

By the end of this lesson, your computer will be ready to work with Azure. Think of this as "installing the tools in your toolbox" before we start building.

---

## 🤔 What Are Prerequisites?

"Prerequisites" means "things you need before starting." Just like you need a hammer before building a birdhouse, you need certain tools before working with Azure.

### Tools We'll Install

| Tool | What It Does | Real-World Analogy |
|------|--------------|-------------------|
| **Azure CLI** | Talks to Azure from your command line | Like a phone to call Azure |
| **Azure Developer CLI (azd)** | Deploys complete applications | Like a "deploy everything" button |
| **VS Code** | Where you write and edit files | Like Microsoft Word, but for code |
| **Git** | Tracks changes to your files | Like "Track Changes" in Word |

---

## 📋 Step-by-Step Setup

### Method 1: GitHub Codespaces (Recommended for Beginners)

**Why?** Everything is pre-installed. Zero setup required!

1. Go to [github.com/codetocloudorg/azure_essentials](https://github.com/codetocloudorg/azure_essentials)
2. Click the green **"Code"** button
3. Select **"Codespaces"** tab
4. Click **"Create codespace on main"**
5. Wait 2-3 minutes for setup
6. **Done!** You now have a fully configured environment in your browser

![Codespaces is like having a computer in the cloud, pre-loaded with everything you need]

---

### Method 2: Local Setup (For Your Own Computer)

#### Step 1: Open Your Terminal

**What's a terminal?** It's where you type commands to control your computer.

| Your Computer | How to Open Terminal |
|---------------|---------------------|
| **Mac** | Press `Cmd + Space`, type "Terminal", press Enter |
| **Windows** | Press `Win + X`, select "Windows Terminal" or "PowerShell" |
| **Linux** | Press `Ctrl + Alt + T` |

#### Step 2: Install the Tools

**Mac/Linux:**
```bash
# Download setup script and run it
git clone https://github.com/codetocloudorg/azure_essentials.git
cd azure_essentials
chmod +x scripts/bash/setup-local-tools.sh
./scripts/bash/setup-local-tools.sh
```

**Windows (PowerShell):**
```powershell
# Download setup script and run it
git clone https://github.com/codetocloudorg/azure_essentials.git
cd azure_essentials
.\scripts\powershell\setup-local-tools.ps1
```

#### Step 3: Verify Everything Works

```bash
# Mac/Linux
./scripts/bash/validate-env.sh

# Windows
.\scripts\powershell\validate-env.ps1
```

**You should see green checkmarks (✓) for all required tools!**

---

## 🔐 Create Your Azure Account

If you don't have an Azure account yet:

1. Go to [azure.microsoft.com/free](https://azure.microsoft.com/free/)
2. Click **"Start free"**
3. Sign in with your Microsoft account (or create one)
4. Enter your information (credit card required for verification, but won't be charged)
5. Complete verification

### What You Get Free

| Service | Free Amount |
|---------|-------------|
| $200 credit | To spend in first 30 days |
| 12 months free | Popular services (VMs, Storage, etc.) |
| Always free | 55+ services forever |

---

## 🔑 Log In to Azure

Now connect your tools to your Azure account:

### Step 1: Log in to Azure CLI

```bash
az login
```

**What happens:**
1. Your browser opens
2. Sign in with your Azure account
3. Close the browser tab
4. Terminal shows "You have logged in"

### Step 2: Log in to Azure Developer CLI

```bash
azd auth login
```

Same process - browser opens, sign in, done!

### Step 3: Verify You're Connected

```bash
az account show --output table
```

You should see your subscription name. **You're connected!** 🎉

---

## ❌ Common Problems & Fixes

### "az: command not found"

**Problem:** Azure CLI isn't installed or isn't in your PATH.

**Fix:**
```bash
# Mac
brew install azure-cli

# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Windows
winget install Microsoft.AzureCLI
```

Then **restart your terminal** and try again.

---

### "No subscriptions found"

**Problem:** You're logged in but don't have an Azure subscription.

**Fix:** 
1. Go to [portal.azure.com](https://portal.azure.com)
2. Search for "Subscriptions"
3. Create a new subscription (Free Trial is fine)
4. Run `az login` again

---

### "Authentication failed"

**Problem:** Your login expired or credentials are invalid.

**Fix:**
```bash
# Clear old credentials and try again
az logout
az login
```

---

## ✅ Checklist Before Moving On

- [ ] I can open a terminal on my computer
- [ ] Running `az --version` shows a version number
- [ ] Running `az account show` shows my subscription
- [ ] Running `azd version` shows a version number

**All boxes checked? You're ready!**

---

## 📖 Key Terms You Learned

| Term | Meaning |
|------|---------|
| **Terminal** | Text-based way to control your computer |
| **CLI** | Command Line Interface - a tool you use by typing commands |
| **Azure CLI** | Microsoft's tool for managing Azure from the terminal |
| **Subscription** | Your Azure "account" that tracks what you create and costs |

---

## ➡️ Next Steps

You're all set up! Continue to:

👉 **[Lesson 01: Introduction to Azure](Lesson-01-Introduction)**

---

*Having trouble? Ask in our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
