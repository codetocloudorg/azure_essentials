#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Essentials - Interactive Deployment Menu
.DESCRIPTION
    This script provides a guided deployment experience for Windows learners
    Code to Cloud - www.codetocloud.io
.EXAMPLE
    .\deploy.ps1
#>

$ErrorActionPreference = "Stop"

# Colors for output
$script:Colors = @{
    Red     = "Red"
    Green   = "Green"
    Yellow  = "Yellow"
    Blue    = "Blue"
    Cyan    = "Cyan"
    Magenta = "Magenta"
    White   = "White"
}

# Script variables
$script:SelectedRegion = ""
$script:SelectedLesson = ""
$script:EnvName = ""
$script:SshPublicKey = ""
$script:WindowsPassword = ""
$script:SshRequired = $false
$script:WinPasswordRequired = $false
$script:NoResources = $false
$script:MgmtGroups = $false

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-ColorOutput "  ██████  ██████  ██████  ███████     ████████  ██████       ██████ ██       ██████  ██    ██ ██████" Cyan
    Write-ColorOutput "  ██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██" Cyan
    Write-ColorOutput "  ██      ██    ██ ██   ██ █████          ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██" Cyan
    Write-ColorOutput "  ██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██" Cyan
    Write-ColorOutput "   ██████  ██████  ██████  ███████        ██     ██████       ██████ ███████  ██████   ██████  ██████" Cyan
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-ColorOutput '     "There is no spoon. Only the code."' Magenta
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host ""
    Write-Host "     " -NoNewline
    Write-Host "Azure Essentials" -ForegroundColor White -NoNewline
    Write-Host " - Interactive Deployment"
    Write-ColorOutput "     www.codetocloud.io" Blue
    Write-Host ""
}

function Show-Section {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "  $Title" -ForegroundColor White
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host ""
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-Prerequisites {
    Show-Section "📋 Checking Prerequisites"

    $missing = $false
    $needsLogin = $false

    # Detect OS for setup script recommendation
    $osType = "Unknown"
    $setupCmd = ""
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -le 5)) {
        $osType = "Windows"
        $setupCmd = ".\scripts\powershell\setup-local-tools.ps1"
    } elseif ($IsMacOS) {
        $osType = "macOS"
        $setupCmd = "./scripts/bash/setup-local-tools.sh"
    } elseif ($IsLinux) {
        $osType = "Linux"
        $setupCmd = "./scripts/bash/setup-local-tools.sh"
    }

    Write-Host "    " -NoNewline
    Write-ColorOutput "○" Cyan -NoNewline
    Write-Host " Operating System: " -NoNewline
    Write-Host $osType -ForegroundColor White
    Write-Host ""

    # Check Azure CLI
    if (Test-Command "az") {
        try {
            $azVersion = (az version --query '"azure-cli"' -o tsv 2>$null)
            Write-ColorOutput "    ✓ Azure CLI: $azVersion" Green
        } catch {
            Write-ColorOutput "    ✓ Azure CLI: installed" Green
        }
    } else {
        Write-ColorOutput "    ✗ Azure CLI: Not installed" Red
        Write-ColorOutput "      Install: https://aka.ms/installazurecli" Cyan
        $missing = $true
    }

    # Check Azure Developer CLI
    if (Test-Command "azd") {
        try {
            $azdVersion = (azd version 2>$null | Select-Object -First 1)
            Write-ColorOutput "    ✓ Azure Developer CLI: $azdVersion" Green
        } catch {
            Write-ColorOutput "    ✓ Azure Developer CLI: installed" Green
        }
    } else {
        Write-ColorOutput "    ✗ Azure Developer CLI: Not installed" Red
        Write-ColorOutput "      Install: winget install Microsoft.Azd" Cyan
        $missing = $true
    }

    # Check authentication
    try {
        $account = az account show --query name -o tsv 2>$null
        if ($account) {
            Write-ColorOutput "    ✓ Azure Login: Signed in to '$account'" Green
        } else {
            Write-ColorOutput "    ○ Azure Login: Not authenticated" Yellow
            $needsLogin = $true
        }
    } catch {
        Write-ColorOutput "    ○ Azure Login: Not authenticated" Yellow
        $needsLogin = $true
    }

    if ($missing) {
        Write-Host ""
        Write-ColorOutput "  Please install missing prerequisites and try again." Red
        Write-Host ""
        Write-ColorOutput "  💡 Quick Setup:" Yellow -NoNewline
        Write-Host " Run the automated setup script for your OS:"
        Write-ColorOutput "     $setupCmd" Cyan
        Write-Host ""
        Write-Host "  Or follow the manual setup guide:"
        Write-ColorOutput "     lessons\00-prerequisites\README.md" Cyan
        exit 1
    }

    Write-Host ""
    Write-ColorOutput "  All prerequisites satisfied!" Green

    # Handle Azure login if needed
    if ($needsLogin) {
        Write-Host ""
        Show-Section "🔐 Azure Login Required"
        Write-Host "  You need to sign in to Azure to continue."
        Write-Host ""
        Read-Host "  Press Enter to open the Azure login page in your browser"
        Write-Host ""
        Write-ColorOutput "  Opening browser for Azure login..." Cyan
        Write-Host ""

        try {
            az login
            Write-Host ""
            Write-ColorOutput "  ✓ Azure CLI login successful!" Green
        } catch {
            Write-ColorOutput "  Azure CLI login failed. Please try again." Red
            exit 1
        }

        Write-Host ""
        Write-ColorOutput "  Now authenticating Azure Developer CLI..." Cyan
        try {
            azd auth login
            Write-ColorOutput "  ✓ Azure Developer CLI login successful!" Green
        } catch {
            Write-ColorOutput "  Azure Developer CLI login failed. Please try again." Red
            exit 1
        }

        $account = az account show --query name -o tsv 2>$null
        Write-Host ""
        Write-Host "  Signed in to: " -NoNewline
        Write-Host $account -ForegroundColor White
    }
}

function Select-Region {
    Show-Section "🌍 Select Azure Region"

    Write-Host "  These regions have the " -NoNewline
    Write-ColorOutput "best capacity" Green -NoNewline
    Write-Host " for Azure free accounts:"
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "North America (Recommended):" -ForegroundColor White
    Write-ColorOutput "      1) East US          - Virginia (Largest Azure region)" Cyan
    Write-ColorOutput "      2) East US 2        - Virginia (High availability)" Cyan
    Write-ColorOutput "      3) West US 2        - Washington" Cyan
    Write-Host "      4) " -NoNewline
    Write-ColorOutput "Central US" Cyan -NoNewline
    Write-Host "       - Iowa " -NoNewline
    Write-ColorOutput "(Best for Cosmos DB)" Green
    Write-ColorOutput "      5) Canada Central   - Toronto" Cyan
    Write-Host ""

    while ($true) {
        $choice = Read-Host "  Select region [1-5]"
        switch ($choice) {
            "1" { $script:SelectedRegion = "eastus"; break }
            "2" { $script:SelectedRegion = "eastus2"; break }
            "3" { $script:SelectedRegion = "westus2"; break }
            "4" { $script:SelectedRegion = "centralus"; break }
            "5" { $script:SelectedRegion = "canadacentral"; break }
            default {
                Write-ColorOutput "  Invalid choice. Please enter 1-5." Red
                continue
            }
        }
        break
    }

    Write-Host ""
    Write-Host "  Selected region: " -NoNewline
    Write-Host $script:SelectedRegion -ForegroundColor White
}

function Select-Lesson {
    Show-Section "📚 Select Lesson to Deploy"

    Write-Host "  Each lesson deploys to its " -NoNewline
    Write-ColorOutput "own resource group" Cyan -NoNewline
    Write-Host " for clarity."
    Write-Host "  Lessons 1, 10, 12 are " -NoNewline
    Write-ColorOutput "portal/CLI demos" Green -NoNewline
    Write-Host " - no Azure resources needed."
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "  DAY 1 - FOUNDATIONS" -ForegroundColor White
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "     " -NoNewline; Write-ColorOutput "1)" Cyan -NoNewline; Write-Host " Introduction to Azure      " -NoNewline; Write-ColorOutput "[NO RESOURCES]" Green -NoNewline; Write-Host " Portal & CLI basics"
    Write-Host "     " -NoNewline; Write-ColorOutput "2)" Cyan -NoNewline; Write-Host " Getting Started            " -NoNewline; Write-ColorOutput "[TENANT]" Yellow -NoNewline; Write-Host "       Management Groups & Policy"
    Write-Host "     " -NoNewline; Write-ColorOutput "3)" Cyan -NoNewline; Write-Host " Storage Services           " -NoNewline; Write-ColorOutput "[FREE]" Green -NoNewline; Write-Host "         Blobs, queues, tables"
    Write-Host "     " -NoNewline; Write-ColorOutput "4)" Cyan -NoNewline; Write-Host " Networking Services        " -NoNewline; Write-ColorOutput "[FREE]" Green -NoNewline; Write-Host "         VNets, subnets, NSGs"
    Write-Host "     " -NoNewline; Write-ColorOutput "5)" Cyan -NoNewline; Write-Host " Compute: Windows           " -NoNewline; Write-ColorOutput "[QUOTA: B1s]" Yellow -NoNewline; Write-Host "  Windows VM + App Service"
    Write-Host "     " -NoNewline; Write-ColorOutput "6)" Cyan -NoNewline; Write-Host " Compute: Linux & K8s       " -NoNewline; Write-ColorOutput "[QUOTA: B1s]" Yellow -NoNewline; Write-Host "  Ubuntu VM + MicroK8s"
    Write-Host "     " -NoNewline; Write-ColorOutput "7)" Cyan -NoNewline; Write-Host " Container Services         " -NoNewline; Write-ColorOutput "[~`$5/mo]" Yellow -NoNewline; Write-Host "       Azure Container Registry"
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "  DAY 2 - ADVANCED SERVICES" -ForegroundColor White
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "     " -NoNewline; Write-ColorOutput "8)" Cyan -NoNewline; Write-Host " Serverless Services        " -NoNewline; Write-ColorOutput "[QUOTA: Dynamic]" Yellow -NoNewline; Write-Host " Azure Functions"
    Write-Host "     " -NoNewline; Write-ColorOutput "9)" Cyan -NoNewline; Write-Host " Database & Data Services   " -NoNewline; Write-ColorOutput "[Pay-per-use]" Yellow -NoNewline; Write-Host "  Cosmos DB Serverless"
    Write-Host "    " -NoNewline; Write-ColorOutput "10)" Cyan -NoNewline; Write-Host " Billing & Cost Mgmt        " -NoNewline; Write-ColorOutput "[NO RESOURCES]" Green -NoNewline; Write-Host " Cost management demo"
    Write-Host "    " -NoNewline; Write-ColorOutput "11)" Cyan -NoNewline; Write-Host " Azure AI Foundry           " -NoNewline; Write-ColorOutput "[`$1-5/day]" Red -NoNewline; Write-Host "     AI Hub, model catalog"
    Write-Host "    " -NoNewline; Write-ColorOutput "12)" Cyan -NoNewline; Write-Host " Architecture Design        " -NoNewline; Write-ColorOutput "[NO RESOURCES]" Green -NoNewline; Write-Host " Whiteboard session"
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "     " -NoNewline; Write-ColorOutput "0)" Cyan -NoNewline; Write-Host " Deploy ALL Resources       " -NoNewline; Write-ColorOutput "[ALL QUOTAS]" Red -NoNewline; Write-Host "   Lessons 3-9,11 (RGs)"
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host ""
    Write-ColorOutput "  ┌─────────────────────────────────────────────────────────────────────────────┐" Magenta
    Write-ColorOutput "  │" Magenta -NoNewline; Write-Host " 💡 RESOURCE AVAILABILITY INFO:" -ForegroundColor White -NoNewline; Write-ColorOutput "                                            │" Magenta
    Write-ColorOutput "  │                                                                             │" Magenta
    Write-ColorOutput "  │" Magenta -NoNewline; Write-Host "  " -NoNewline; Write-ColorOutput "FREE" Green -NoNewline; Write-Host " = Works with Azure Free Account, no quota needed" -NoNewline; Write-ColorOutput "                    │" Magenta
    Write-ColorOutput "  │" Magenta -NoNewline; Write-Host "  " -NoNewline; Write-ColorOutput "QUOTA" Yellow -NoNewline; Write-Host " = Requires compute quota (some subscriptions have 0)" -NoNewline; Write-ColorOutput "           │" Magenta
    Write-ColorOutput "  │" Magenta -NoNewline; Write-Host "  " -NoNewline; Write-ColorOutput "`$`$`$" Red -NoNewline; Write-Host " = Incurs costs, not covered by free tier" -NoNewline; Write-ColorOutput "                             │" Magenta
    Write-ColorOutput "  │                                                                             │" Magenta
    Write-ColorOutput "  │" Magenta -NoNewline; Write-Host "  If deployment fails with 'quota' error, try: " -NoNewline; Write-ColorOutput "3, 4, 7, or 9" Cyan -NoNewline; Write-ColorOutput "              │" Magenta
    Write-ColorOutput "  └─────────────────────────────────────────────────────────────────────────────┘" Magenta
    Write-Host ""

    while ($true) {
        $choice = Read-Host "  Select lesson [0-12]"
        switch ($choice) {
            "0" { $script:SelectedLesson = ""; $script:SshRequired = $true; $script:WinPasswordRequired = $true; break }
            "1" { $script:SelectedLesson = "01"; $script:NoResources = $true; break }
            "2" { $script:SelectedLesson = "02"; $script:MgmtGroups = $true; break }
            "3" { $script:SelectedLesson = "03"; break }
            "4" { $script:SelectedLesson = "04"; break }
            "5" { $script:SelectedLesson = "05"; $script:WinPasswordRequired = $true; break }
            "6" { $script:SelectedLesson = "06"; $script:SshRequired = $true; break }
            "7" { $script:SelectedLesson = "07"; break }
            "8" { $script:SelectedLesson = "08"; break }
            "9" { $script:SelectedLesson = "09"; break }
            "10" { $script:SelectedLesson = "10"; $script:NoResources = $true; break }
            "11" { $script:SelectedLesson = "11"; break }
            "12" { $script:SelectedLesson = "12"; $script:NoResources = $true; break }
            default {
                Write-ColorOutput "  Invalid choice. Please enter 0-12." Red
                continue
            }
        }
        break
    }

    # Handle lessons that don't need Azure resources
    if ($script:NoResources) {
        Write-Host ""
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
        Write-ColorOutput "    ✅ Lesson $($script:SelectedLesson) is a demo/discussion - no deployment needed!" Green
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
        Write-Host ""
        Write-Host "  Navigate to the lesson folder to follow along:"
        Write-ColorOutput "    cd lessons\$($script:SelectedLesson)-*" Cyan
        Write-Host ""
        Read-Host "  Press Enter to exit"
        exit 0
    }

    # Handle Lesson 2 - Management Groups (requires tenant-level permissions)
    if ($script:MgmtGroups) {
        return  # Will call Deploy-ManagementGroups in main flow
    }

    if ([string]::IsNullOrEmpty($script:SelectedLesson)) {
        Write-ColorOutput "  ⚠️  Deploying ALL lessons will create multiple resource groups and may incur costs." Yellow
        $confirm = Read-Host "  Are you sure? (y/n)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Select-Lesson
            return
        }
    }

    Write-Host ""
    if ([string]::IsNullOrEmpty($script:SelectedLesson)) {
        Write-Host "  Selected: " -NoNewline
        Write-Host "All Lessons" -ForegroundColor White
    } else {
        Write-Host "  Selected: " -NoNewline
        Write-Host "Lesson $($script:SelectedLesson)" -ForegroundColor White
    }
}

function Get-EnvironmentName {
    Show-Section "🏷️  Environment Name"

    Write-Host "  Enter a unique name for your environment."
    Write-Host "  This will be used in resource group names (e.g., rg-{name}-lesson03-storage)"
    Write-Host ""

    # Cross-platform username detection (Windows: USERNAME, macOS/Linux: USER)
    $username = if ($env:USERNAME) { $env:USERNAME } elseif ($env:USER) { $env:USER } else { "user" }
    $cleanUsername = ($username.ToLower() -replace '[^a-z0-9]','')
    if ($cleanUsername.Length -gt 8) { $cleanUsername = $cleanUsername.Substring(0, 8) }
    $defaultName = "azlearn-$cleanUsername"

    $envName = Read-Host "  Environment name [$defaultName]"

    if ([string]::IsNullOrWhiteSpace($envName)) {
        $script:EnvName = $defaultName
    } else {
        $script:EnvName = ($envName.ToLower() -replace '[^a-z0-9-]','')
    }

    Write-Host ""
    Write-Host "  Environment name: " -NoNewline
    Write-Host $script:EnvName -ForegroundColor White
}

function Setup-WindowsPassword {
    if (-not $script:WinPasswordRequired) {
        return
    }

    Show-Section "🔐 Windows VM Password Setup"

    Write-Host "  Lesson 5 deploys a Windows Server VM that requires RDP password authentication."
    Write-Host ""
    Write-ColorOutput "  Password requirements:" Yellow
    Write-Host "    • At least 12 characters"
    Write-Host "    • Contains uppercase, lowercase, number, and special character"
    Write-Host ""

    while ($true) {
        $securePassword = Read-Host "  Enter password for Windows VM" -AsSecureString
        $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

        if ($password.Length -lt 12) {
            Write-ColorOutput "  Password must be at least 12 characters." Red
            continue
        }

        if ($password -cnotmatch '[A-Z]') {
            Write-ColorOutput "  Password must contain at least one uppercase letter." Red
            continue
        }
        if ($password -cnotmatch '[a-z]') {
            Write-ColorOutput "  Password must contain at least one lowercase letter." Red
            continue
        }
        if ($password -notmatch '[0-9]') {
            Write-ColorOutput "  Password must contain at least one number." Red
            continue
        }

        $secureConfirm = Read-Host "  Confirm password" -AsSecureString
        $confirm = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureConfirm))

        if ($password -ne $confirm) {
            Write-ColorOutput "  Passwords do not match. Try again." Red
            continue
        }

        $script:WindowsPassword = $password
        break
    }

    Write-Host ""
    Write-ColorOutput "  ✓ Windows password set." Green
    Write-Host ""
    Write-ColorOutput "  💡 Remember your credentials:" Yellow
    Write-Host "     Username: azureuser"
    Write-Host "     Password: (the password you just entered)"
}

function Setup-SshKey {
    if (-not $script:SshRequired) {
        return
    }

    Show-Section "🔑 SSH Key Setup"

    Write-Host "  Lesson 6 deploys an Ubuntu VM that requires SSH key authentication."
    Write-Host ""

    # Cross-platform home directory (Windows: USERPROFILE, macOS/Linux: HOME)
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { "~" }

    # Check for existing SSH key
    $rsaKeyPath = Join-Path $homeDir ".ssh" "id_rsa.pub"
    $ed25519KeyPath = Join-Path $homeDir ".ssh" "id_ed25519.pub"

    if (Test-Path $rsaKeyPath) {
        Write-ColorOutput "  ✓ Found existing SSH key: $rsaKeyPath" Green
        Write-Host ""
        $useExisting = Read-Host "  Use this key? (y/n) [y]"
        if ($useExisting -ne "n" -and $useExisting -ne "N") {
            $script:SshPublicKey = (Get-Content $rsaKeyPath -Raw).Trim()
            Write-ColorOutput "  Using existing SSH key." Green
            return
        }
    } elseif (Test-Path $ed25519KeyPath) {
        Write-ColorOutput "  ✓ Found existing SSH key: $ed25519KeyPath" Green
        Write-Host ""
        $useExisting = Read-Host "  Use this key? (y/n) [y]"
        if ($useExisting -ne "n" -and $useExisting -ne "N") {
            $script:SshPublicKey = (Get-Content $ed25519KeyPath -Raw).Trim()
            Write-ColorOutput "  Using existing SSH key." Green
            return
        }
    }

    # No existing key or user declined
    Write-Host "  No SSH key found or you chose not to use existing key."
    Write-Host ""
    $generateKey = Read-Host "  Generate a new SSH key pair? (y/n) [y]"

    if ($generateKey -eq "n" -or $generateKey -eq "N") {
        Write-Host ""
        Write-ColorOutput "  You'll need to provide an SSH public key for VM access." Yellow
        Write-Host "  Enter your SSH public key (starts with ssh-rsa or ssh-ed25519):"
        $script:SshPublicKey = Read-Host "  "

        if ([string]::IsNullOrWhiteSpace($script:SshPublicKey)) {
            Write-ColorOutput "  No SSH key provided. Cannot deploy Lesson 06." Red
            exit 1
        }
    } else {
        Write-Host ""
        Write-ColorOutput "  Generating new SSH key pair..." Cyan

        $sshDir = Join-Path $homeDir ".ssh"
        if (-not (Test-Path $sshDir)) {
            New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        }

        $keyPath = Join-Path $sshDir "id_ed25519_azure"

        # Remove existing key to avoid interactive prompts
        if (Test-Path $keyPath) {
            Remove-Item $keyPath -Force
            Remove-Item "$keyPath.pub" -Force -ErrorAction SilentlyContinue
        }

        ssh-keygen -t ed25519 -f $keyPath -N '""' -C "azure-essentials-vm"

        $script:SshPublicKey = (Get-Content "$keyPath.pub" -Raw).Trim()
        Write-Host ""
        Write-ColorOutput "  ✓ SSH key generated: $keyPath" Green
        Write-ColorOutput "  ✓ Private key: $keyPath" Green
        Write-Host ""
        Write-ColorOutput "  💡 To SSH to your VM after deployment:" Yellow
        Write-ColorOutput "     ssh -i $keyPath azureuser@<vm-public-ip>" Cyan
    }
    Write-Host ""
}

function Deploy-ManagementGroups {
    Show-Section "🏢 Deploying Management Groups"

    Write-ColorOutput "  ⚠️  Management Groups require tenant-level permissions." Yellow
    Write-Host ""
    Write-Host "  This will create an Azure Landing Zone style hierarchy:"
    Write-Host ""
    Write-Host "    📁 mg-$($script:EnvName)-root (Organization Root)"
    Write-Host "    ├── 📁 mg-$($script:EnvName)-platform"
    Write-Host "    │   ├── 📁 mg-$($script:EnvName)-identity"
    Write-Host "    │   ├── 📁 mg-$($script:EnvName)-connectivity"
    Write-Host "    │   └── 📁 mg-$($script:EnvName)-management"
    Write-Host "    ├── 📁 mg-$($script:EnvName)-workloads"
    Write-Host "    │   ├── 📁 mg-$($script:EnvName)-prod"
    Write-Host "    │   └── 📁 mg-$($script:EnvName)-nonprod"
    Write-Host "    └── 📁 mg-$($script:EnvName)-sandbox"
    Write-Host ""

    $confirm = Read-Host "  Deploy Management Groups? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-ColorOutput "  Deployment cancelled." Yellow
        exit 0
    }

    Write-Host ""
    Write-ColorOutput "  Deploying Management Groups via Azure CLI..." Cyan
    Write-Host ""

    # Get current timestamp for deployment name
    $timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
    $deploymentName = "mg-$($script:EnvName)-$timestamp"

    # Deploy using Azure CLI with tenant scope
    try {
        az deployment tenant create `
            --name $deploymentName `
            --location $script:SelectedRegion `
            --template-file "infra/modules/management-groups.bicep" `
            --parameters environmentName="$($script:EnvName)"

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
            Write-ColorOutput "    ✅ Management Groups Created Successfully!" Green
            Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
            Write-Host ""
            Write-Host "  View in Azure Portal:"
            Write-Host "    https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade"
            Write-Host ""
            Write-ColorOutput "  To clean up Management Groups:" Yellow
            Write-ColorOutput "    az account management-group delete --name mg-$($script:EnvName)-root --recurse" Cyan
        } else {
            throw "Deployment failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Host ""
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Red
        Write-ColorOutput "    ❌ Deployment Failed" Red
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Red
        Write-Host ""
        Write-Host "  Common issues:"
        Write-Host "    • You need tenant-level permissions (Global Admin or similar)"
        Write-Host "    • Your account may not have Management Group Contributor role"
        Write-Host ""
        Write-Host "  Request permissions from your Azure AD administrator."
    }
}

function Confirm-AndDeploy {
    Show-Section "🚀 Ready to Deploy"

    Write-Host "    Environment:  " -NoNewline
    Write-Host $script:EnvName -ForegroundColor White
    Write-Host "    Region:       " -NoNewline
    Write-Host $script:SelectedRegion -ForegroundColor White

    if ([string]::IsNullOrEmpty($script:SelectedLesson)) {
        Write-Host "    Lesson:       " -NoNewline
        Write-Host "All Lessons" -ForegroundColor White
        Write-Host ""
        Write-ColorOutput "    Resource groups to be created:" Cyan
        Write-Host "      • rg-$($script:EnvName)-lesson03-storage"
        Write-Host "      • rg-$($script:EnvName)-lesson04-networking"
        Write-Host "      • rg-$($script:EnvName)-lesson05-compute"
        Write-Host "      • rg-$($script:EnvName)-lesson06-linux-k8s"
        Write-Host "      • rg-$($script:EnvName)-lesson07-containers"
        Write-Host "      • rg-$($script:EnvName)-lesson08-serverless"
        Write-Host "      • rg-$($script:EnvName)-lesson09-database"
        Write-Host "      • rg-$($script:EnvName)-lesson11-ai-foundry"
    } else {
        Write-Host "    Lesson:       " -NoNewline
        Write-Host "Lesson $($script:SelectedLesson)" -ForegroundColor White
        Write-Host ""
        Write-ColorOutput "    Resource group to be created:" Cyan
        Write-Host "      • rg-$($script:EnvName)-lesson$($script:SelectedLesson)-*"
    }
    Write-Host ""

    $confirm = Read-Host "  Proceed with deployment? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-ColorOutput "  Deployment cancelled." Yellow
        exit 0
    }

    # Initialize azd environment
    Show-Section "⚙️  Initializing Environment"

    # Get current subscription ID
    $subscriptionId = az account show --query id -o tsv 2>$null
    if ([string]::IsNullOrEmpty($subscriptionId)) {
        Write-ColorOutput "  Error: Could not get Azure subscription ID" Red
        exit 1
    }

    $subscriptionName = az account show --query name -o tsv
    Write-Host "  Using subscription: $subscriptionName"

    # Create or select environment
    $envList = azd env list 2>$null
    if ($envList -match "^$($script:EnvName) ") {
        Write-Host "  Environment '$($script:EnvName)' already exists, selecting it..."
        azd env select $script:EnvName
    } else {
        Write-Host "  Creating new environment '$($script:EnvName)'..."
        azd env new $script:EnvName --no-prompt 2>$null
        if (-not $?) {
            azd env select $script:EnvName 2>$null
        }
    }

    # Set subscription and location
    azd env set AZURE_SUBSCRIPTION_ID $subscriptionId
    azd env set AZURE_LOCATION $script:SelectedRegion

    if (-not [string]::IsNullOrEmpty($script:SelectedLesson)) {
        azd env set LESSON_NUMBER $script:SelectedLesson
    }

    if (-not [string]::IsNullOrWhiteSpace($script:WindowsPassword)) {
        azd env set WINDOWS_ADMIN_PASSWORD $script:WindowsPassword
    }

    if (-not [string]::IsNullOrWhiteSpace($script:SshPublicKey)) {
        azd env set SSH_PUBLIC_KEY $script:SshPublicKey
    }

    Write-Host ""
    Write-ColorOutput "  Environment configured successfully!" Green

    # Run deployment
    Show-Section "☁️  Deploying to Azure"

    Write-Host "  This may take 5-15 minutes depending on the resources..."
    Write-Host ""

    azd up

    # Post-deployment: Build container for Lesson 07
    if ($script:SelectedLesson -eq "07" -or [string]::IsNullOrEmpty($script:SelectedLesson)) {
        Build-HelloContainer
    }
}

function Build-HelloContainer {
    $scriptPath = $PSScriptRoot
    $repoRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)
    $helloAppDir = Join-Path $repoRoot "lessons/07-container-services/src/hello-container"

    # Find the ACR name from deployed resources
    try {
        $acrName = az acr list --query "[?contains(name, '$($script:EnvName)')].name" -o tsv 2>$null | Select-Object -First 1
    } catch {
        return
    }

    if ($acrName -and (Test-Path $helloAppDir)) {
        Write-Host ""
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
        Write-ColorOutput "    Building hello-container in ACR..." Cyan
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Cyan
        Write-Host ""

        az acr build `
            --registry $acrName `
            --image "hello-container:v1" `
            --file "$helloAppDir/Dockerfile" `
            $helloAppDir `
            --no-logs

        $loginServer = az acr show --name $acrName --query loginServer -o tsv
        Write-ColorOutput "  ✓ Image built: ${loginServer}/hello-container:v1" Green
    }
}

function Show-Completion {
    Write-Host ""
    Write-Host ""
    Write-ColorOutput "  ██████  ██████  ██████  ███████     ████████  ██████       ██████ ██       ██████  ██    ██ ██████" Green
    Write-ColorOutput "  ██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██" Green
    Write-ColorOutput "  ██      ██    ██ ██   ██ █████          ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██" Green
    Write-ColorOutput "  ██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██" Green
    Write-ColorOutput "   ██████  ██████  ██████  ███████        ██     ██████       ██████ ███████  ██████   ██████  ██████" Green
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
    Write-Host "     ✅ Deployment Complete!" -ForegroundColor White
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
    Write-Host ""
    Write-Host "  Resource Groups Created:" -ForegroundColor White
    try {
        az group list --query "[?contains(name, '$($script:EnvName)')].{Name:name, Location:location}" -o table
    } catch {
        Write-Host "    Run 'az group list' to see your resource groups"
    }
    Write-Host ""
    Write-Host "  Next Steps:" -ForegroundColor White
    Write-Host "    1. Navigate to the lessons\ folder"
    Write-Host "    2. Follow the README for your selected lesson"
    Write-Host "    3. Explore resources in the Azure Portal"
    Write-Host ""
    Write-Host "  Useful Commands:" -ForegroundColor White
    Write-ColorOutput "    azd show" Cyan -NoNewline; Write-Host "          - View deployed resources"
    Write-ColorOutput "    azd down" Cyan -NoNewline; Write-Host "          - Delete all resources when done"
    Write-ColorOutput "    az group list" Cyan -NoNewline; Write-Host "     - List your resource groups"
    Write-Host ""
    Write-ColorOutput "  Azure Portal:" Blue -NoNewline; Write-Host " https://portal.azure.com"
    Write-ColorOutput "  Code to Cloud:" Blue -NoNewline; Write-Host " www.codetocloud.io"
    Write-Host ""
    Write-ColorOutput "  ⚠️  Remember to run 'azd down' when you're finished to avoid charges!" Yellow
    Write-Host ""
}

# Main function
function Main {
    Show-Banner
    Test-Prerequisites
    Get-EnvironmentName
    Select-Region
    Select-Lesson

    # Handle Management Groups deployment separately (requires tenant scope)
    if ($script:MgmtGroups) {
        Deploy-ManagementGroups
        Write-Host ""
        Read-Host "  Press Enter to exit"
        exit 0
    }

    Setup-WindowsPassword
    Setup-SshKey
    Confirm-AndDeploy
    Show-Completion
}

# Run main
Main
