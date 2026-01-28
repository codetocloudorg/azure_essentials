# Prerequisites & Environment Setup

> **Azure Essentials** | Get your machine ready for the course

---

## 📋 Overview

This guide will help you set up everything you need to complete the Azure Essentials course. Follow the instructions for your operating system (Windows, macOS, or Linux).

**Time Required**: 15-30 minutes

📜 **[Scripts Guide](../../SCRIPTS.md)** — Complete reference for all scripts and deployment options

---

## ✅ What You Need

| Tool                          | Purpose                                | Required?      |
| ----------------------------- | -------------------------------------- | -------------- |
| **Azure Account**             | Access to Azure cloud services         | ✅ Yes         |
| **Azure CLI**                 | Command-line tool for Azure            | ✅ Yes         |
| **Azure Developer CLI (azd)** | Simplified deployment tool             | ✅ Yes         |
| **Git**                       | Clone the course repository            | ✅ Yes         |
| **Visual Studio Code**        | Code editor with Azure extensions      | ✅ Yes         |
| **kubectl**                   | Kubernetes CLI for Lesson 06           | 📌 Recommended |
| **Docker Desktop**            | Container development (Lesson 07)      | 📌 Recommended |
| **Python 3.11+**              | For serverless and AI lessons          | 📌 Recommended |
| **jq**                        | JSON processor for CLI workflows       | 📌 Recommended |
| **Bicep CLI**                 | Infrastructure as Code (via Azure CLI) | 📌 Recommended |
| **Azure Storage Explorer**    | GUI for storage management             | 📌 Optional    |

---

## 🔐 Step 1: Create Your Azure Account

If you don't have an Azure account, create a free one:

1. Go to [azure.microsoft.com/free](https://azure.microsoft.com/free/)
2. Click **Start free**
3. Sign in with your Microsoft account (or create one)
4. Complete the verification process
5. You'll receive **$200 credit** for 30 days plus 12 months of free services

> 💡 **Tip**: Use a personal Microsoft account for learning. Work accounts may have restrictions.

---

## 💻 Step 2: Install Required Tools

Choose your operating system and follow the instructions below.

---

### 🪟 Windows Setup

#### Option A: Automated Setup (Recommended)

1. **Install winget** (Windows Package Manager)
   - Comes pre-installed on Windows 11
   - For Windows 10, get it from the [Microsoft Store](https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1)

2. **Open PowerShell as Administrator** and run:

```powershell
# Install Git
winget install --id Git.Git -e --source winget

# Install Visual Studio Code
winget install --id Microsoft.VisualStudioCode -e --source winget

# Install Azure CLI
winget install --id Microsoft.AzureCLI -e --source winget

# Install Azure Developer CLI
winget install --id Microsoft.Azd -e --source winget

# Install kubectl (for Lesson 06: Kubernetes)
winget install --id Kubernetes.kubectl -e --source winget

# Install Python 3.11
winget install --id Python.Python.3.11 -e --source winget

# Install Docker Desktop
winget install --id Docker.DockerDesktop -e --source winget
```

3. **Restart your terminal** after installation

#### Option B: Use the Setup Script

We provide a PowerShell setup script that automates everything:

```powershell
# Clone the repository first
git clone https://github.com/yourorg/azure_essentials.git
cd azure_essentials

# Run the setup script
.\scripts\powershell\setup-local-tools.ps1
```

#### Option C: Manual Installation

| Tool                | Download Link                                                                                                                                      |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Git                 | [git-scm.com/download/win](https://git-scm.com/download/win)                                                                                       |
| VS Code             | [code.visualstudio.com](https://code.visualstudio.com/)                                                                                            |
| Azure CLI           | [aka.ms/installazurecliwindows](https://aka.ms/installazurecliwindows)                                                                             |
| Azure Developer CLI | [learn.microsoft.com/azure/developer/azure-developer-cli/install-azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) |
| kubectl             | [kubernetes.io/docs/tasks/tools/install-kubectl-windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)                          |
| Python              | [python.org/downloads](https://www.python.org/downloads/)                                                                                          |
| Docker Desktop      | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)                                                              |

---

### 🍎 macOS Setup

#### Option A: Automated Setup (Recommended)

1. **Install Homebrew** (if not already installed):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **Install all required tools**:

```bash
# Install Git
brew install git

# Install Visual Studio Code
brew install --cask visual-studio-code

# Install Azure CLI
brew install azure-cli

# Install Azure Developer CLI
brew tap azure/azd && brew install azd

# Install kubectl (for Lesson 06: Kubernetes)
brew install kubectl

# Install Python 3.11
brew install python@3.11

# Install Docker Desktop
brew install --cask docker
```

3. **Install Bicep CLI**:

```bash
az bicep install
```

#### Option B: Use the Setup Script

We provide a setup script that automates everything:

```bash
# Clone the repository first
git clone https://github.com/yourorg/azure_essentials.git
cd azure_essentials

# Run the setup script
chmod +x scripts/bash/setup-local-tools.sh
./scripts/bash/setup-local-tools.sh
```

---

### 🐧 Linux Setup (Ubuntu/Debian)

#### Step-by-Step Installation

1. **Update your system**:

```bash
sudo apt update && sudo apt upgrade -y
```

2. **Install Git**:

```bash
sudo apt install -y git
```

3. **Install Azure CLI**:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

4. **Install Azure Developer CLI**:

```bash
curl -fsSL https://aka.ms/install-azd.sh | bash
```

5. **Install Visual Studio Code**:

```bash
# Download and install
sudo apt install -y software-properties-common apt-transport-https wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code
```

6. **Install kubectl** (for Lesson 06: Kubernetes):

```bash
# Add Kubernetes apt repository
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubectl
```

7. **Install Python 3.11+**:

```bash
sudo apt install -y python3 python3-pip python3-venv
```

8. **Install Docker** (for container lessons):

```bash
# Install Docker
curl -fsSL https://get.docker.com | sudo sh

# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

9. **Install Bicep CLI**:

```bash
az bicep install
```

#### Use the Setup Script

Alternatively, use our setup script:

```bash
git clone https://github.com/yourorg/azure_essentials.git
cd azure_essentials
chmod +x scripts/bash/setup-local-tools.sh
./scripts/bash/setup-local-tools.sh
```

---

## 🔧 Step 3: Install VS Code Extensions

Open VS Code and install these extensions for the best experience:

### Required Extensions

| Extension       | What It Does                 | Install Command                                             |
| --------------- | ---------------------------- | ----------------------------------------------------------- |
| **Bicep**       | Azure infrastructure as code | `code --install-extension ms-azuretools.vscode-bicep`       |
| **Azure Tools** | Azure resource management    | `code --install-extension ms-vscode.vscode-node-azure-pack` |

### Recommended Extensions

| Extension      | What It Does            | Install Command                                                        |
| -------------- | ----------------------- | ---------------------------------------------------------------------- |
| **Python**     | Python language support | `code --install-extension ms-python.python`                            |
| **Docker**     | Container development   | `code --install-extension ms-azuretools.vscode-docker`                 |
| **YAML**       | YAML file support       | `code --install-extension redhat.vscode-yaml`                          |
| **Kubernetes** | K8s support             | `code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools` |

#### Install All Extensions at Once

**Windows (PowerShell):**

```powershell
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-python.python
code --install-extension ms-azuretools.vscode-docker
code --install-extension redhat.vscode-yaml
```

**macOS/Linux (Terminal):**

```bash
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-python.python
code --install-extension ms-azuretools.vscode-docker
code --install-extension redhat.vscode-yaml
```

---

## 🔑 Step 4: Sign In to Azure

Now let's connect your tools to Azure.

### Sign In with Azure CLI

```bash
az login
```

This opens a browser window. Sign in with your Azure account.

### Sign In with Azure Developer CLI

```bash
azd auth login
```

This also opens a browser for authentication.

### Verify Your Connection

```bash
# Check Azure CLI
az account show --query "{Name:name, SubscriptionId:id}" -o table

# Check azd
azd auth login --check-status
```

You should see your subscription name and ID.

---

## 📁 Step 5: Clone the Course Repository

```bash
# Navigate to where you want the project
cd ~/Dev  # or any folder you prefer

# Clone the repository
git clone https://github.com/yourorg/azure_essentials.git

# Enter the directory
cd azure_essentials

# Open in VS Code
code .
```

---

## ✔️ Step 6: Validate Your Setup

Run our validation script to confirm everything is working:

**macOS/Linux:**

```bash
./scripts/bash/validate-env.sh
```

**Windows (Git Bash or WSL):**

```bash
bash ./scripts/bash/validate-env.sh
```

You should see green checkmarks (✓) for all required tools:

```
✓ Git installed
✓ Azure CLI installed
✓ Azure Developer CLI installed
✓ VS Code installed
✓ Python installed
✓ Docker installed
✓ Logged in to Azure CLI
✓ Logged in to Azure Developer CLI
```

---

## 🚀 Step 7: Test Deployment (Optional)

To verify everything works, use our interactive deployment script:

**macOS/Linux:**

```bash
./scripts/bash/deploy.sh
```

**Windows (PowerShell):**

```powershell
.\scripts\powershell\deploy.ps1
```

The script will guide you through:

- Checking prerequisites
- Selecting a region
- Choosing a lesson to deploy

Alternatively, deploy manually with azd:

```bash
# Set your environment
azd init

# Choose a region (eastus recommended)
azd env set AZURE_LOCATION eastus

# Deploy only Lesson 03 (Storage) as a test
azd env set LESSON_NUMBER 03
azd up
```

If successful, clean up the test resources:

```bash
azd down --force --purge
```

---

## ❓ Troubleshooting

### "Command not found" errors

**Windows:** Restart your terminal/PowerShell after installing new tools.

**macOS/Linux:** Run `source ~/.bashrc` or `source ~/.zshrc`, or restart your terminal.

### Azure CLI login issues

```bash
# Clear cached credentials
az logout
az account clear

# Try logging in again
az login
```

### Docker not starting

- **Windows/macOS:** Ensure Docker Desktop is running (check system tray)
- **Linux:** Start Docker service: `sudo systemctl start docker`

### Permission denied (Linux/macOS)

```bash
# Make scripts executable
chmod +x scripts/*.sh
```

### Python version issues

Ensure you have Python 3.11 or later:

```bash
python3 --version
```

If you have an older version, install Python 3.11 using the instructions above.

---

## 🆘 Getting Help

| Issue                    | Where to Get Help                                                       |
| ------------------------ | ----------------------------------------------------------------------- |
| Course content questions | Ask your instructor                                                     |
| Repository issues        | Open a GitHub issue                                                     |
| Azure documentation      | [learn.microsoft.com/azure](https://learn.microsoft.com/azure/)         |
| Azure CLI help           | [learn.microsoft.com/cli/azure](https://learn.microsoft.com/cli/azure/) |

---

## ✅ Checklist Before Class

Before the training session, confirm you have:

- [ ] Azure account created and verified
- [ ] Azure CLI installed and logged in (`az login`)
- [ ] Azure Developer CLI installed and logged in (`azd auth login`)
- [ ] Git installed
- [ ] VS Code installed with Bicep extension
- [ ] Course repository cloned
- [ ] (Optional) Docker Desktop installed and running
- [ ] (Optional) Python 3.11+ installed

---

**You're all set! See you in class! 🎉**
