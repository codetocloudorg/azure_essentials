# 🔧 Troubleshooting Guide

> Solutions to common problems when learning Azure

---

## 🚨 Quick Fixes (Try These First!)

Before anything else, try these:

### 1. Are You Logged In?

```bash
# Check Azure CLI login
az account show

# If you see an error, log in:
az login

# Check Azure Developer CLI
azd auth login --check-status

# If needed:
azd auth login
```

### 2. Is Your Subscription Set?

```bash
# See all subscriptions
az account list --output table

# Set the right one
az account set --subscription "Your Subscription Name"
```

### 3. Restart Your Terminal

Many issues are fixed by closing and reopening your terminal to refresh environment variables.

---

## 🔐 Authentication Issues

### "Please run 'az login' to setup account"

**Cause:** You're not logged in to Azure CLI.

**Fix:**
```bash
az login
```

A browser opens. Sign in and close the browser.

---

### "AADSTS700016: Application not found"

**Cause:** Azure AD configuration issue.

**Fix:**
```bash
az logout
az login --use-device-code
```

Follow the device code instructions instead of browser.

---

### "Token has expired"

**Cause:** Your login session expired (usually after 90 days).

**Fix:**
```bash
az logout
az account clear
az login
```

---

## 🚫 Permission Issues

### "AuthorizationFailed" or "Forbidden"

**Cause:** Your account doesn't have permission to do that action.

**Possible fixes:**

1. **Check your role:**
   ```bash
   az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --output table
   ```

2. **Contact your admin** to get Contributor role on the subscription.

3. **Try a different subscription** (maybe you have permissions there).

---

### "ResourceGroupNotFound"

**Cause:** The resource group doesn't exist or you don't have access.

**Fix:**
```bash
# List your resource groups
az group list --output table

# Make sure you're using an existing one, or create it:
az group create --name rg-my-app --location eastus
```

---

## 💻 VM Issues

### Can't Connect to VM (RDP or SSH)

**Checklist:**

1. **Is the VM running?**
   ```bash
   az vm show --resource-group <rg> --name <vm> --show-details --query powerState
   ```
   If "stopped" or "deallocated", start it:
   ```bash
   az vm start --resource-group <rg> --name <vm>
   ```

2. **Check NSG rules allow your traffic:**
   ```bash
   az network nsg rule list --resource-group <rg> --nsg-name <nsg> --output table
   ```
   - RDP: Port 3389 must be allowed
   - SSH: Port 22 must be allowed

3. **Get the correct IP:**
   ```bash
   az vm show --resource-group <rg> --name <vm> --show-details --query publicIps -o tsv
   ```

4. **Check your local firewall/VPN.** Corporate networks often block RDP/SSH.

---

### "OperationNotAllowed - VM size not available"

**Cause:** That VM size isn't available in that region, or you've hit a quota.

**Fixes:**

1. **Try a different size:**
   ```bash
   --size Standard_B1s   # Smallest, cheapest
   ```

2. **Try a different region:**
   ```bash
   --location eastus2    # or westus2, centralus
   ```

3. **Check your quota:**
   Portal → Subscriptions → Usage + quotas

---

## 📦 Container Issues

### "containerapp: command not found"

**Cause:** CLI extension not installed.

**Fix:**
```bash
az extension add --name containerapp --upgrade -y
```

---

### "Resource provider not registered"

**Cause:** The service (like Container Apps) needs to be enabled on your subscription.

**Fix:**
```bash
az provider register --namespace Microsoft.App --wait
az provider register --namespace Microsoft.ContainerRegistry --wait
```

---

### Container image build fails

**Cause:** Usually a Dockerfile or code issue.

**Debug:**
```bash
# Check build logs
az acr task logs --registry <acr-name>
```

**Common issues:**
- `COPY` command trying to copy a file that doesn't exist
- Missing `requirements.txt` or `package.json`
- Syntax errors in code

---

### Container App shows "Service Unavailable" (503)

**Cause:** Container failed to start or crashed.

**Debug:**
```bash
# Check logs
az containerapp logs show --name <app> --resource-group <rg>
```

**Common issues:**
- Wrong port: Check `--target-port` matches what app listens on
- Missing environment variables
- App crashes on startup (syntax error, missing dependency)

---

## 💾 Storage Issues

### "StorageAccountAlreadyTaken"

**Cause:** Storage account names must be globally unique across ALL of Azure.

**Fix:** Use a more unique name:
```bash
STORAGE_NAME="st$(whoami | tr -d '[:space:]')$(date +%s)"
```

---

### "AuthorizationPermissionMismatch"

**Cause:** Access permissions issue with storage.

**Fixes:**

1. **Use account key explicitly:**
   ```bash
   STORAGE_KEY=$(az storage account keys list --account-name <name> --query '[0].value' -o tsv)
   az storage blob upload --account-key $STORAGE_KEY ...
   ```

2. **Enable blob public access** (for learning only):
   ```bash
   az storage account update --name <name> --allow-blob-public-access true
   ```

---

## 🌐 Networking Issues

### "NetworkSecurityGroup...not found"

**Cause:** NSG doesn't exist or wrong name.

**Fix:**
```bash
# List NSGs in your resource group
az network nsg list --resource-group <rg> --output table
```

---

### "SubnetNotFound"

**Cause:** VNet or subnet doesn't exist.

**Fix:**
```bash
# List VNets
az network vnet list --resource-group <rg> --output table

# List subnets in a VNet
az network vnet subnet list --resource-group <rg> --vnet-name <vnet> --output table
```

---

## 💰 Cost Issues

### Unexpected charges appearing

**Immediate actions:**

1. **Stop running resources:**
   ```bash
   # Stop VMs (stops compute charges)
   az vm deallocate --resource-group <rg> --name <vm>
   ```

2. **Delete unused resource groups:**
   ```bash
   az group delete --name <rg-name> --yes --no-wait
   ```

3. **Check what's running:**
   Portal → Cost Management + Billing → Cost analysis

**Set up a budget alert:**
Portal → Cost Management → Budgets → Add

---

## 🔧 CLI Issues

### "az: command not found"

**Cause:** Azure CLI not installed or not in PATH.

**Fixes by OS:**

**Mac:**
```bash
brew install azure-cli
```

**Ubuntu/Debian:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Windows:**
```powershell
winget install Microsoft.AzureCLI
```

Then restart your terminal.

---

### "The term 'az' is not recognized" (PowerShell)

**Cause:** Need to restart PowerShell after installation.

**Fix:** Close PowerShell and open a new window.

---

### Azure CLI is slow

**Cause:** Usually telemetry or extension loading.

**Speed up:**
```bash
# Disable telemetry
az config set core.collect_telemetry=false

# Update extensions
az extension update --all
```

---

## 🆘 Still Stuck?

### 1. Read the Error Message Carefully

Azure errors often tell you exactly what's wrong:
```
"The storage account 'xyz' already exists in another resource group"
```
→ Just use a different name!

### 2. Check Azure Status

Is Azure having issues? Check: [status.azure.com](https://status.azure.com)

### 3. Search the Docs

Microsoft docs are excellent: [learn.microsoft.com/azure](https://learn.microsoft.com/azure)

### 4. Ask for Help

- **Discord:** [discord.gg/vwfwq2EpXJ](https://discord.gg/vwfwq2EpXJ)
- **Stack Overflow:** Tag questions with `azure`
- **GitHub Issues:** Check this repo's issues

---

### When Asking for Help, Include:

1. **The exact error message** (copy/paste)
2. **The command you ran**
3. **What OS you're using** (Mac, Windows, Linux)
4. **What you've already tried**

---

*Happy debugging! Remember: every error is a learning opportunity.* 🚀
