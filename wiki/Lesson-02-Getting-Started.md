# Lesson 02: Getting Started

> **Time:** 15 minutes | **Difficulty:** Easy | **Cost:** $0

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created your first resource group
- Explored the Azure Portal
- Run your first Azure CLI commands

---

## 📁 What Is a Resource Group?

A **Resource Group** is like a folder on your computer, but for Azure resources.

### Why Use Resource Groups?

| Benefit | Explanation |
|---------|-------------|
| **Organization** | Keep related resources together |
| **Easy deletion** | Delete the folder = delete everything inside |
| **Access control** | Set permissions at the group level |
| **Cost tracking** | See costs per project/group |

### Real-World Examples

| Resource Group | What's Inside |
|----------------|---------------|
| `rg-website-production` | Web app, database, storage |
| `rg-dev-testing` | Development VMs, test databases |
| `rg-training-lesson03` | Resources for Lesson 03 |

---

## 🛠️ Create Your First Resource Group

### Using Azure CLI (Recommended)

```bash
# Set variables
RG_NAME="rg-my-first-resource-group"
LOCATION="centralus"

# Create the resource group
az group create \
  --name $RG_NAME \
  --location $LOCATION
```

**Output:**
```json
{
  "id": "/subscriptions/.../resourceGroups/rg-my-first-resource-group",
  "location": "centralus",
  "name": "rg-my-first-resource-group",
  "properties": {
    "provisioningState": "Succeeded"
  }
}
```

🎉 **Congratulations!** You just created your first Azure resource!

### Using Azure Portal

1. Go to [portal.azure.com](https://portal.azure.com)
2. Search for **"Resource groups"** in the top search bar
3. Click **"+ Create"**
4. Fill in:
   - **Subscription:** Your subscription
   - **Resource group:** `rg-my-first-resource-group`
   - **Region:** Central US
5. Click **"Review + create"**
6. Click **"Create"**

---

## 🔍 Verify It Exists

### CLI

```bash
# List all resource groups
az group list --output table

# Show details of your resource group
az group show --name rg-my-first-resource-group
```

### Portal

1. Click **"Resource groups"** in the left menu (or search for it)
2. You should see `rg-my-first-resource-group` in the list
3. Click it to see inside (it's empty for now!)

---

## 🏷️ Add Tags (Optional but Recommended)

Tags help you organize and track costs:

```bash
az group update \
  --name rg-my-first-resource-group \
  --tags environment=learning owner=me project=azure-essentials
```

Tags are like labels:
- `environment: learning` → This is for training, not production
- `owner: me` → I created this
- `project: azure-essentials` → Part of this course

---

## 🧹 Clean Up

When you're done with a resource group, delete it:

```bash
az group delete --name rg-my-first-resource-group --yes
```

**This deletes everything inside!** That's why resource groups are powerful - one command cleans up all related resources.

---

## ✅ What You Learned

- 📁 What a resource group is (a folder for Azure resources)
- 🛠️ How to create a resource group via CLI and Portal
- 🏷️ How to add tags for organization
- 🧹 How to delete a resource group

---

## ➡️ Next Steps

Now let's put something in that folder!

👉 **[Lesson 03: Storage Services](Lesson-03-Storage)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
