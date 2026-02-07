# Lesson 01: Introduction to Azure

> **Time:** 20 minutes | **Difficulty:** Easy | **Cost:** $0 (reading only)

## 🎯 What You'll Learn

By the end of this lesson, you'll understand:
- What "the cloud" actually means
- How Azure organizes resources
- The Azure Portal interface
- Key vocabulary every Azure user needs

---

## ☁️ What Is "The Cloud"?

You've heard "the cloud" everywhere. But what is it really?

### The Simple Explanation

**The cloud = Someone else's computer that you rent over the internet.**

That's it! When you use Azure:
- Microsoft owns the computers (servers)
- You rent them by the hour/minute
- You access them over the internet
- You pay only for what you use

### Why Is It Called "The Cloud"?

In old network diagrams, engineers drew the internet as a cloud shape because they didn't care what was inside - just that it connected things. The name stuck!

```
   Your Computer ←→ ☁️ "The Cloud" ☁️ ←→ Azure Servers
                    (The Internet)
```

---

## 🏢 Azure's "Organizational Structure"

Azure organizes everything in a hierarchy. Think of it like a company:

```
🏛️ Azure Account (Your Microsoft Account)
└── 📁 Subscription (Your "department budget")
    └── 📁 Resource Group (Your "project folder")
        ├── 💻 Virtual Machine
        ├── 💾 Storage Account
        └── 🌐 Virtual Network
```

### Breaking It Down

| Level | What It Is | Real-World Analogy |
|-------|----------|-------------------|
| **Account** | Your Microsoft identity | Your employee badge |
| **Subscription** | Billing container | A department credit card |
| **Resource Group** | Logical container for related resources | A project folder |
| **Resource** | An actual Azure service | A tool or machine |

### Why This Matters

When you create anything in Azure, you MUST specify:
1. Which **subscription** pays for it
2. Which **resource group** contains it
3. Which **region** (location) hosts it

---

## 🌍 Azure Regions

Azure has data centers all around the world. Each location is called a **region**.

### Popular Regions (North America)

| Region Name | Location | Use When... |
|-------------|----------|-------------|
| `eastus` | Virginia, USA | Default choice, lots of services |
| `westus2` | Washington, USA | West coast users |
| `centralus` | Iowa, USA | Central location |
| `canadacentral` | Toronto, Canada | Canadian data residency |

### Why Regions Matter

1. **Speed** - Closer regions = faster for your users
2. **Compliance** - Some data must stay in certain countries
3. **Cost** - Prices vary slightly by region
4. **Availability** - Some services aren't available everywhere

---

## 🖥️ Ways to Use Azure

You can manage Azure three ways:

### 1. Azure Portal (Web Interface)

**URL:** [portal.azure.com](https://portal.azure.com)

**Best for:** 
- Exploring and learning
- Visual overview of resources
- One-time tasks

**Looks like:** A web dashboard with menus and buttons

### 2. Azure CLI (Command Line)

**Best for:**
- Automation and scripts
- Faster once you know it
- Reproducible operations

**Looks like:**
```bash
az vm create --name myVM --resource-group myRG --image Ubuntu2204
```

### 3. Infrastructure as Code (Bicep/ARM)

**Best for:**
- Defining infrastructure in files
- Version control
- Team collaboration

**Looks like:**
```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'
  location: 'eastus'
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}
```

---

## 🔤 Key Vocabulary

Here are terms you'll hear constantly in Azure:

| Term | Simple Definition | Example |
|------|-------------------|---------|
| **Resource** | Anything you create in Azure | A VM, storage account, database |
| **Resource Group** | A folder for related resources | "my-web-app-rg" |
| **Subscription** | Your Azure billing account | "Visual Studio Enterprise" |
| **Region** | Where your resources physically live | "East US", "West Europe" |
| **SKU** | "Stock Keeping Unit" - the size/tier | "Standard_B2s" (VM size) |
| **ARM** | Azure Resource Manager - how Azure organizes everything | The "brain" of Azure |

---

## 🎮 Let's Explore the Portal!

### Quick Tour (5 minutes)

1. Go to [portal.azure.com](https://portal.azure.com)
2. Sign in with your Azure account
3. Look for these elements:

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍 Search bar        [Home] [Dashboard] [All services]    ⚙️  │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐                                               │
│  │ ≡ Menu       │   Welcome to Azure!                          │
│  │              │                                               │
│  │ + Create     │   [Create a resource]                        │
│  │              │                                               │
│  │ 📁 Resources │   Recent resources:                          │
│  │ 📊 Cost      │   (Your resources will appear here)          │
│  │ ⚙️ Settings │                                               │
│  └──────────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

### Try These

1. **Search for "Subscriptions"** → See your billing accounts
2. **Click "Resource groups"** → See your project folders (probably empty)
3. **Click "Create a resource"** → Browse the Azure marketplace

---

## 🧠 Understanding Azure Pricing

Azure uses **pay-as-you-go** pricing. You're charged for:

| What | How Charged | Example |
|------|-------------|---------|
| Compute time | Per hour/minute | VM running = costs money, VM stopped = free |
| Storage | Per GB/month | 100 GB stored = ~$2/month |
| Network egress | Per GB transferred OUT | Data leaving Azure costs (inbound is free) |
| Operations | Per 10,000 operations | Storage reads/writes |

### 💡 Cost-Saving Tips

1. **Stop resources when not using them** - A stopped VM costs almost nothing
2. **Use Free Tier** - Many services have a free tier
3. **Delete what you don't need** - Especially after learning exercises
4. **Set budget alerts** - Azure can email you at spending thresholds

---

## ❓ Quiz Yourself

Before moving on, can you answer:

1. What is a **resource group**?
   <details><summary>Answer</summary>A logical container (folder) for related Azure resources</details>

2. What is a **subscription**?
   <details><summary>Answer</summary>A billing container - like a department credit card</details>

3. Why do you choose a **region**?
   <details><summary>Answer</summary>For speed (closer to users), compliance, cost, and service availability</details>

4. Name the 3 ways to manage Azure.
   <details><summary>Answer</summary>1) Azure Portal (web), 2) Azure CLI (commands), 3) Infrastructure as Code (Bicep/ARM)</details>

---

## ✅ Lesson Complete!

You now understand:
- ☁️ What "the cloud" actually is
- 🏗️ How Azure organizes resources (Account → Subscription → Resource Group → Resource)
- 🌍 What regions are and why they matter
- 🖥️ Three ways to manage Azure

---

## ➡️ Next Steps

Time to create your first resource!

👉 **[Lesson 02: Getting Started](Lesson-02-Getting-Started)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
