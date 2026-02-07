# Lesson 05: Windows Compute (Virtual Machines)

> **Time:** 30 minutes | **Difficulty:** Medium | **Cost:** ~$0.05 (if stopped promptly)

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created a Windows Server virtual machine in Azure
- Connected to it using Remote Desktop (RDP)
- Understood how VMs work and cost

---

## 💻 What Is a Virtual Machine?

A **Virtual Machine (VM)** is a computer that runs inside a data center, but you use it like it's sitting on your desk.

### Physical vs Virtual

| Physical Computer | Virtual Machine |
|------------------|-----------------|
| You buy it ($1000+) | You rent it (pennies/hour) |
| Sits under your desk | Lives in Azure's datacenter |
| Takes days to get | Creates in 5 minutes |
| You fix it when it breaks | Azure fixes it |

### Why Use VMs?

- **Test software** without risking your real computer
- **Run Windows applications** from a Mac
- **Host websites and apps** that need a "real" server
- **Scale up/down** - need more power? Just resize!

---

## 🏗️ VM Components Explained

When you create a VM, Azure actually creates several resources:

```
📦 Resource Group
├── 💻 Virtual Machine (the "computer")
├── 💾 OS Disk (the "hard drive")
├── 🌐 Virtual Network (the "network cable")
├── 🔌 Network Interface (the "network port")
├── 📍 Public IP Address (the "internet address")
└── 🔒 Network Security Group (the "firewall")
```

Don't worry - Azure creates all of these automatically!

---

## 💵 Understanding VM Costs

VMs are charged **per minute** while running:

| Size | vCPUs | RAM | Approx Cost/Hour |
|------|-------|-----|------------------|
| Standard_B1s | 1 | 1 GB | $0.01 |
| Standard_B2s | 2 | 4 GB | $0.04 |
| Standard_D2s_v5 | 2 | 8 GB | $0.10 |
| Standard_D4s_v5 | 4 | 16 GB | $0.19 |

### Cost-Saving Tips

| Action | Savings |
|--------|---------|
| **Stop VM when not using** | ~95% (only disk costs remain) |
| **Use B-series for learning** | Cheapest general-purpose VMs |
| **Delete when done** | 100% (no more charges) |
| **Auto-shutdown** | We'll configure this! |

---

## 🛠️ Let's Create a Windows VM!

### Step 1: Set Up Variables

```bash
# Set your variables
RESOURCE_GROUP="rg-compute-windows"
LOCATION="centralus"
VM_NAME="vm-win-learn"
ADMIN_USER="azureuser"
```

### Step 2: Create Resource Group

```bash
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

### Step 3: Create the Virtual Machine

```bash
# This command will prompt you for a password
# Password requirements: 12+ chars, uppercase, lowercase, number, special char

az vm create \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --image Win2022Datacenter \
  --size Standard_B2s \
  --admin-username $ADMIN_USER \
  --public-ip-sku Standard
```

⏳ **This takes 3-5 minutes.** Azure is:
1. Creating a virtual hard drive
2. Installing Windows Server 2022
3. Setting up networking
4. Assigning a public IP address

### Step 4: Get Your VM's IP Address

```bash
az vm show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --show-details \
  --query publicIps \
  --output tsv
```

**Save this IP address!** You'll need it to connect.

---

## 🖥️ Connect to Your VM with Remote Desktop

### On Windows

1. Press `Win + R`
2. Type `mstsc` and press Enter
3. Enter your VM's IP address
4. Click **Connect**
5. Enter username: `azureuser`
6. Enter the password you created
7. Click **Yes** on the certificate warning

### On Mac

1. Download [Microsoft Remote Desktop](https://apps.apple.com/app/microsoft-remote-desktop/id1295203466) from App Store
2. Click **Add PC**
3. Enter your VM's IP address
4. Double-click to connect
5. Enter credentials when prompted

### On Linux

```bash
# Install xfreerdp
sudo apt install freerdp2-x11

# Connect
xfreerdp /u:azureuser /v:<your-vm-ip>
```

---

## 🎉 You're In!

You're now using a Windows Server running in Azure! Try:

1. **Open Server Manager** - see the VM's configuration
2. **Open PowerShell** - run some commands
3. **Open a browser** - yes, your VM has internet!

---

## ⏰ Configure Auto-Shutdown (Save Money!)

Don't forget to turn off the VM when you're done! Even better, set up auto-shutdown:

### Using CLI

```bash
# Set auto-shutdown at 7 PM UTC
az vm auto-shutdown \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --time 1900
```

### Using Portal

1. Go to [portal.azure.com](https://portal.azure.com)
2. Find your VM
3. Click **Auto-shutdown** in the left menu
4. Enable it and set a time
5. Click **Save**

---

## 🛑 Stop Your VM (Stop Charges!)

When you're done:

```bash
# Stop the VM (stops compute charges)
az vm deallocate \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP
```

**Note:** "Deallocate" stops charges. Just "Stop" from inside Windows does NOT stop Azure charges!

### VM States Explained

| Status | Compute Charged? | Disk Charged? |
|--------|-----------------|---------------|
| Running | ✅ Yes | ✅ Yes |
| Stopped (from Windows) | ✅ Yes! | ✅ Yes |
| Deallocated | ❌ No | ✅ Yes ($0.01/hr) |
| Deleted | ❌ No | ❌ No |

---

## 🧹 Clean Up

Delete everything when you're done learning:

```bash
az group delete --name rg-compute-windows --yes --no-wait
```

---

## ❌ Common Problems & Fixes

### "Can't connect via RDP"

**Problem:** RDP connection times out or is refused.

**Possible fixes:**

1. **Check the VM is running:**
   ```bash
   az vm show -g $RESOURCE_GROUP -n $VM_NAME --show-details --query powerState
   ```

2. **Check NSG allows RDP (port 3389):**
   ```bash
   az network nsg rule list -g $RESOURCE_GROUP --nsg-name ${VM_NAME}NSG -o table
   ```

3. **Check your IP isn't blocked.** Some corporate networks block RDP.

---

### "Password doesn't meet requirements"

**Problem:** Azure rejects your password.

**Requirements:**
- 12-123 characters
- Has uppercase letters
- Has lowercase letters  
- Has numbers
- Has special characters

**Example good password:** `Azure2024!Learn`

---

### "Not enough quota"

**Problem:** Your subscription doesn't allow that VM size.

**Fix:** Try a smaller size:
```bash
--size Standard_B1s
```

Or check your quota in the Portal: Subscriptions → Usage + quotas

---

## ✅ What You Learned

- 💻 What a Virtual Machine is and why to use one
- 🏗️ Components that make up a VM (disk, network, IP, etc.)
- 🛠️ How to create a Windows VM with Azure CLI
- 🖥️ How to connect using Remote Desktop (RDP)
- ⏰ How to configure auto-shutdown to save money
- 🛑 The difference between Stopped and Deallocated

---

## 📖 Key Terms

| Term | Meaning |
|------|---------|
| **VM** | Virtual Machine - a computer in the cloud |
| **RDP** | Remote Desktop Protocol - how you connect to Windows VMs |
| **NSG** | Network Security Group - firewall rules for your VM |
| **Deallocate** | Stop and release compute resources (stops charges) |
| **SKU/Size** | The VM's "specs" (CPUs, RAM) |

---

## ➡️ Next Steps

Let's try Linux next:

👉 **[Lesson 06: Linux & Kubernetes](Lesson-06-Compute-Linux)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
