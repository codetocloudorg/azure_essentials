# Lesson 03: Storage Services

> **Time:** 25 minutes | **Difficulty:** Easy | **Cost:** ~$0.01

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created your first Storage Account
- Uploaded a file to Azure Blob Storage
- Accessed that file from anywhere in the world via URL

---

## 💾 What Is Azure Storage?

Think of Azure Storage as **a giant hard drive in the cloud** that:
- Never runs out of space (virtually unlimited)
- Is accessible from anywhere with internet
- Keeps multiple copies of your data (so it's never lost)
- Costs pennies per gigabyte

### Types of Azure Storage

| Type | What It Stores | Like... |
|------|---------------|---------|
| **Blob Storage** | Files (images, videos, backups) | Dropbox or Google Drive |
| **File Storage** | Files with folder structure | A network shared drive |
| **Queue Storage** | Messages between applications | A to-do list for apps |
| **Table Storage** | Simple data tables | A giant spreadsheet |

**This lesson focuses on Blob Storage** - the most common type.

---

## 🗂️ How Blob Storage Is Organized

```
📦 Storage Account (your-storage-name)
└── 📁 Container (like a folder)
    ├── 📄 Blob (file1.txt)
    ├── 📄 Blob (image.png)
    └── 📄 Blob (video.mp4)
```

| Concept | What It Is | Naming Rules |
|---------|-----------|--------------|
| **Storage Account** | The top-level "bucket" | Globally unique, 3-24 chars, lowercase + numbers only |
| **Container** | A folder inside the account | Lowercase, 3-63 chars |
| **Blob** | An individual file | Almost any name |

---

## 🛠️ Let's Create a Storage Account!

### Step 1: Create a Resource Group

First, we need a "folder" to put our storage account in:

```bash
# Set your variables
RESOURCE_GROUP="rg-storage-lesson"
LOCATION="centralus"

# Create the resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

**What happened?** You created an empty "project folder" in Azure.

### Step 2: Create the Storage Account

```bash
# Storage account name (must be globally unique!)
# Use your name/initials + random numbers
STORAGE_NAME="stlesson$(openssl rand -hex 4)"

# Create the storage account
az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

echo "Your storage account name is: $STORAGE_NAME"
```

**Wait about 30 seconds.** Storage accounts take a moment to create.

### Step 3: Create a Container

```bash
# Create a container named "myfiles"
az storage container create \
  --name myfiles \
  --account-name $STORAGE_NAME \
  --public-access blob
```

**What's `--public-access blob`?** It means anyone with the URL can view files. (We'll learn about security later.)

### Step 4: Upload a File

```bash
# Create a simple test file
echo "Hello from Azure Storage!" > hello.txt

# Upload it
az storage blob upload \
  --account-name $STORAGE_NAME \
  --container-name myfiles \
  --name hello.txt \
  --file hello.txt
```

### Step 5: Access Your File!

```bash
# Get the URL of your file
az storage blob url \
  --account-name $STORAGE_NAME \
  --container-name myfiles \
  --name hello.txt \
  --output tsv
```

**Copy that URL and paste it in your browser!** 🎉 You should see "Hello from Azure Storage!"

---

## 🔒 Storage Account Redundancy (Keeping Data Safe)

When you create a storage account, you choose how many copies Azure keeps:

| SKU | Copies | Protection Level | Cost |
|-----|--------|-----------------|------|
| **LRS** (Local) | 3 copies in one datacenter | Hardware failure | $ |
| **ZRS** (Zone) | 3 copies across 3 datacenters | Datacenter failure | $$ |
| **GRS** (Geo) | 6 copies across 2 regions | Regional disaster | $$$ |
| **GZRS** | Best of ZRS + GRS | Everything | $$$$ |

**For learning:** LRS is fine (cheapest).
**For production:** At least ZRS for important data.

---

## 📊 See It in the Portal

1. Go to [portal.azure.com](https://portal.azure.com)
2. Click **Resource Groups** in the left menu
3. Click **rg-storage-lesson**
4. Click your storage account
5. Click **Containers** → **myfiles** → **hello.txt**

You can also upload files by clicking the **Upload** button!

---

## 💰 What This Costs

| What | Price |
|------|-------|
| Storage (per GB/month) | ~$0.02 |
| Upload data | Free |
| Download data | ~$0.01 per GB |

**Your tiny test file:** Basically free!

---

## 🧹 Clean Up (Important!)

When you're done experimenting, delete the resource group to avoid any charges:

```bash
az group delete --name rg-storage-lesson --yes --no-wait
```

This deletes the storage account and everything in it.

---

## ❌ Common Problems & Fixes

### "The storage account name is already taken"

**Problem:** Storage account names must be globally unique across ALL of Azure.

**Fix:** Add more random characters:
```bash
STORAGE_NAME="st$(whoami)$(date +%s)"
```

---

### "AuthorizationFailure"

**Problem:** You don't have permission or aren't logged in.

**Fix:**
```bash
az login
az account set --subscription "Your Subscription Name"
```

---

### "ContainerNotFound"

**Problem:** The container doesn't exist or you misspelled it.

**Fix:** List your containers to check:
```bash
az storage container list --account-name $STORAGE_NAME --output table
```

---

## ✅ What You Learned

- 📦 What Azure Storage is and how it's organized
- 🛠️ How to create a storage account using CLI
- 📤 How to upload and access files
- 🔒 Different redundancy levels (LRS, ZRS, GRS)
- 🧹 How to clean up resources

---

## 📖 Key Terms

| Term | Meaning |
|------|---------|
| **Blob** | Binary Large Object - any file stored in Azure |
| **Container** | A folder inside a storage account |
| **SKU** | The tier/redundancy level (like LRS, GRS) |
| **Redundancy** | Having multiple copies of data for safety |

---

## ➡️ Next Steps

Now that you can store data, let's learn how to connect resources securely:

👉 **[Lesson 04: Networking](Lesson-04-Networking)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
