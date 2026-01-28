#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Essentials - Interactive Deployment Menu
.DESCRIPTION
    Provides a guided, interactive deployment experience for the Azure
    Essentials 2-Day training course. This script walks learners through:
    - Prerequisites checking (Azure CLI, azd)
    - Azure authentication
    - Subscription selection
    - Region selection (optimized for free tier availability)
    - Preflight checks (quota, permissions, providers)
    - Lesson selection and deployment

    Code to Cloud - www.codetocloud.io

.EXAMPLE
    .\deploy.ps1

.NOTES
    HOW DEPLOYMENT WORKS (THE TECHNOLOGY STACK):

      1. YOU RUN THIS SCRIPT (deploy.ps1)
         └─> Collects: environment name, region, lesson choice

      2. AZURE DEVELOPER CLI (azd)
         └─> Reads: azure.yaml (project definition)
         └─> Initializes: environment variables and parameters
         └─> Orchestrates: the entire deployment process

      3. BICEP COMPILER
         └─> Input: /infra/main.bicep (Infrastructure as Code)
         └─> Output: ARM JSON template (Azure Resource Manager format)
         └─> Modules: /infra/modules/*.bicep (reusable components)

      4. AZURE RESOURCE MANAGER (ARM)
         └─> Receives: Compiled JSON template + parameters
         └─> Validates: Template syntax and resource availability
         └─> Creates: Azure resources in your subscription

      5. AZURE RESOURCES
         └─> Resource groups, VMs, storage, networking, etc.
         └─> All tagged and organized by lesson
#>

$ErrorActionPreference = "Stop"

#===============================================================================
# SCRIPT VARIABLES
#===============================================================================
$script:SelectedRegion = ""
$script:SelectedLesson = ""
$script:EnvName = ""
$script:SshPublicKey = ""
$script:WindowsPassword = ""
$script:SshRequired = $false
$script:WinPasswordRequired = $false
$script:NoResources = $false
$script:MgmtGroups = $false
$script:DeployAll = $false
$script:SelectedSubscriptionId = ""
$script:SelectedSubscriptionName = ""

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================
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

#===============================================================================
# PREREQUISITES CHECK
#===============================================================================
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
    }
}

#===============================================================================
# SUBSCRIPTION SELECTION
#===============================================================================
function Select-Subscription {
    Show-Section "💳 Select Azure Subscription"

    Write-ColorOutput "  WHAT IS A SUBSCRIPTION?" Cyan
    Write-Host "    A subscription is your billing account in Azure."
    Write-Host "    All resources you create will be billed to this subscription."
    Write-Host ""

    Write-ColorOutput "  Fetching your Azure subscriptions..." Cyan
    Write-Host ""

    # Get list of subscriptions
    try {
        $subs = az account list --query "[].{name:name, id:id, state:state, isDefault:isDefault}" -o json 2>$null | ConvertFrom-Json
    } catch {
        Write-ColorOutput "  Error fetching subscriptions." Red
        exit 1
    }

    if (-not $subs -or $subs.Count -eq 0) {
        Write-ColorOutput "  No subscriptions found." Red
        Write-Host "  Please ensure you have access to at least one Azure subscription."
        Write-Host ""
        Write-Host "  If you need a subscription:"
        Write-Host "    • Free Trial: https://azure.microsoft.com/free/"
        Write-Host "    • Azure for Students: https://azure.microsoft.com/free/students/"
        exit 1
    }

    if ($subs.Count -eq 1) {
        # Only one subscription, use it automatically
        $script:SelectedSubscriptionId = $subs[0].id
        $script:SelectedSubscriptionName = $subs[0].name
        Write-ColorOutput "    ✓ Found 1 subscription: $($subs[0].name)" Green
    } else {
        # Multiple subscriptions, let user choose
        Write-Host "    Found $($subs.Count) subscriptions:"
        Write-Host ""
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
        Write-Host "    " -NoNewline
        Write-Host ("#".PadRight(4) + "SUBSCRIPTION NAME".PadRight(45) + "STATE") -ForegroundColor White
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow

        $defaultNum = 1
        for ($i = 0; $i -lt $subs.Count; $i++) {
            $sub = $subs[$i]
            $num = $i + 1
            $defaultMarker = ""
            if ($sub.isDefault) {
                $defaultMarker = " (current)"
                $defaultNum = $num
            }

            Write-Host "    " -NoNewline
            Write-ColorOutput "$num)".PadRight(4) Cyan -NoNewline
            Write-Host $sub.name.PadRight(45) -NoNewline
            if ($sub.state -eq "Enabled") {
                Write-ColorOutput $sub.state Green -NoNewline
            } else {
                Write-ColorOutput $sub.state Yellow -NoNewline
            }
            Write-ColorOutput $defaultMarker Green
        }

        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
        Write-Host ""

        while ($true) {
            $choice = Read-Host "  Select subscription [1-$($subs.Count)] (default: $defaultNum)"

            if ([string]::IsNullOrWhiteSpace($choice)) {
                $choice = $defaultNum
            }

            if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $subs.Count) {
                $idx = [int]$choice - 1
                $script:SelectedSubscriptionId = $subs[$idx].id
                $script:SelectedSubscriptionName = $subs[$idx].name
                break
            } else {
                Write-ColorOutput "  Invalid choice. Please enter a number between 1 and $($subs.Count)." Red
            }
        }
    }

    # Set the subscription as active
    Write-Host ""
    Write-ColorOutput "  Setting active subscription..." Cyan
    az account set --subscription $script:SelectedSubscriptionId

    Write-Host ""
    Write-ColorOutput "  ✓ Using subscription: " Green -NoNewline
    Write-Host $script:SelectedSubscriptionName -ForegroundColor White
    Write-Host "    ID: $($script:SelectedSubscriptionId.Substring(0, 8))..."
}

#===============================================================================
# PREFLIGHT CHECKS
#===============================================================================
function Test-PreflightChecks {
    Show-Section "🔍 Running Preflight Checks"

    Write-ColorOutput "  WHAT ARE PREFLIGHT CHECKS?" Cyan
    Write-Host "    Validation steps that catch issues BEFORE deployment starts."
    Write-Host "    This saves time by detecting problems early."
    Write-Host ""

    $checksPassed = $true
    $warnings = 0

    # Check 1: Subscription State
    Write-Host "  1. Subscription Status" -ForegroundColor White
    try {
        $subState = az account show --query state -o tsv 2>$null
        if ($subState -eq "Enabled") {
            Write-ColorOutput "     ✓ Subscription is active and enabled" Green
        } else {
            Write-ColorOutput "     ✗ Subscription state: $subState" Red
            $checksPassed = $false
        }
    } catch {
        Write-ColorOutput "     ○ Could not check subscription state" Yellow
        $warnings++
    }

    # Check 2: Resource Providers
    Write-Host ""
    Write-Host "  2. Resource Provider Registration" -ForegroundColor White
    Write-ColorOutput "     (Azure services must be registered before use)" Cyan

    $providers = @("Microsoft.Compute", "Microsoft.Storage", "Microsoft.Network", "Microsoft.Web", "Microsoft.ContainerRegistry")

    foreach ($provider in $providers) {
        try {
            $state = az provider show --namespace $provider --query registrationState -o tsv 2>$null
            if ($state -eq "Registered") {
                Write-ColorOutput "     ✓ $provider" Green
            } elseif ($state -eq "Registering") {
                Write-ColorOutput "     ○ $provider (registering)" Yellow
                $warnings++
            } else {
                Write-ColorOutput "     ○ $provider - $state" Yellow
                $warnings++
            }
        } catch {
            Write-ColorOutput "     ○ $provider - Could not check" Yellow
            $warnings++
        }
    }

    # Check 3: Quota Check
    Write-Host ""
    Write-Host "  3. Compute Quota Check" -ForegroundColor White
    Write-ColorOutput "     (Checking if you have vCPU quota for VMs)" Cyan

    try {
        $quotaJson = az vm list-usage --location $script:SelectedRegion --query "[?contains(name.value, 'standardBSFamily')].{current:currentValue, limit:limit}" -o json 2>$null
        $quota = $quotaJson | ConvertFrom-Json

        if ($quota -and $quota.Count -gt 0) {
            $current = $quota[0].current
            $limit = $quota[0].limit
            $available = $limit - $current

            if ($limit -eq 0) {
                Write-ColorOutput "     ⚠ B-series vCPU quota: $current/$limit used (no quota)" Yellow
                $warnings++
            } elseif ($available -lt 2) {
                Write-ColorOutput "     ⚠ B-series vCPU quota: $current/$limit used ($available available)" Yellow
                $warnings++
            } else {
                Write-ColorOutput "     ✓ B-series vCPU quota: $current/$limit used ($available available)" Green
            }
        } else {
            Write-ColorOutput "     ○ Could not check quota" Yellow
            $warnings++
        }
    } catch {
        Write-ColorOutput "     ○ Could not check quota" Yellow
        $warnings++
    }

    # Check 4: Permissions
    Write-Host ""
    Write-Host "  4. Permissions Check" -ForegroundColor White
    Write-ColorOutput "     (Checking if you can create resources)" Cyan

    try {
        $userId = az ad signed-in-user show --query id -o tsv 2>$null
        if ($userId) {
            $roles = az role assignment list --assignee $userId --query "[].roleDefinitionName" -o tsv 2>$null | Select-Object -First 5
            if ($roles) {
                $rolesString = $roles -join ", "
                if ($rolesString -match "Owner|Contributor") {
                    Write-ColorOutput "     ✓ You have Owner/Contributor access" Green
                } else {
                    Write-ColorOutput "     ⚠ Found roles: $rolesString" Yellow
                    $warnings++
                }
            } else {
                Write-ColorOutput "     ○ Could not determine role assignments" Yellow
                $warnings++
            }
        } else {
            Write-ColorOutput "     ○ Could not check permissions" Yellow
            $warnings++
        }
    } catch {
        Write-ColorOutput "     ○ Could not check permissions" Yellow
        $warnings++
    }

    # Check 5: Region
    Write-Host ""
    Write-Host "  5. Region Availability" -ForegroundColor White
    Write-ColorOutput "     (Checking if selected region is accessible)" Cyan

    try {
        $regionAvailable = az account list-locations --query "[?name=='$($script:SelectedRegion)'].name" -o tsv 2>$null
        if ($regionAvailable) {
            Write-ColorOutput "     ✓ Region '$($script:SelectedRegion)' is available" Green
        } else {
            Write-ColorOutput "     ✗ Region '$($script:SelectedRegion)' is not available" Red
            $checksPassed = $false
        }
    } catch {
        Write-ColorOutput "     ○ Could not check region availability" Yellow
        $warnings++
    }

    # Summary
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow

    if (-not $checksPassed) {
        Write-ColorOutput "    ✗ Preflight checks failed" Red
        $continueAnyway = Read-Host "    Continue anyway? (y/n)"
        if ($continueAnyway -ne "y" -and $continueAnyway -ne "Y") {
            Write-ColorOutput "  Deployment cancelled." Yellow
            exit 1
        }
    } elseif ($warnings -gt 0) {
        Write-ColorOutput "    ⚠ Preflight checks passed with $warnings warning(s)" Yellow
        $continueDeploy = Read-Host "    Continue with deployment? (y/n) [y]"
        if ($continueDeploy -eq "n" -or $continueDeploy -eq "N") {
            Write-ColorOutput "  Deployment cancelled." Yellow
            exit 0
        }
    } else {
        Write-ColorOutput "    ✓ All preflight checks passed!" Green
    }

    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
}

#===============================================================================
# REGION SELECTION
#===============================================================================
function Select-Region {
    Show-Section "🌍 Select Azure Region"

    Write-ColorOutput "  WHAT IS A REGION?" Cyan
    Write-Host "    An Azure region is a set of datacenters in a geographic area."
    Write-Host "    Your resources will be physically located in these datacenters."
    Write-Host ""
    Write-ColorOutput "  WHY THESE REGIONS?" Cyan
    Write-Host "    These regions have the best capacity for Azure free/trial accounts."
    Write-Host "    They're less likely to have quota issues for VMs and other resources."
    Write-Host ""
    Write-Host "    " -NoNewline
    Write-Host "North America (Recommended for training):" -ForegroundColor White
    Write-ColorOutput "      1) East US          - Virginia (Largest Azure region)" Cyan
    Write-ColorOutput "      2) East US 2        - Virginia (High availability)" Cyan
    Write-ColorOutput "      3) West US 2        - Washington" Cyan
    Write-Host "      4) " -NoNewline
    Write-ColorOutput "Central US" Cyan -NoNewline
    Write-Host "       - Iowa " -NoNewline
    Write-ColorOutput "(Best for Cosmos DB free tier)" Green
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
    Write-ColorOutput "  Selected region: " Green -NoNewline
    Write-Host $script:SelectedRegion -ForegroundColor White
}

#===============================================================================
# ENVIRONMENT NAME
#===============================================================================
function Get-EnvironmentName {
    Show-Section "🏷️  Environment Name"

    Write-ColorOutput "  WHAT IS AN ENVIRONMENT NAME?" Cyan
    Write-Host "    A unique prefix used to name all your Azure resources."
    Write-Host "    This prevents naming conflicts if multiple learners deploy."
    Write-Host ""
    Write-ColorOutput "  HOW IT'S USED:" Cyan
    Write-Host "    Resource Group: rg-{name}-lesson03-storage"
    Write-Host "    Storage Account: st{name}lesson03"
    Write-Host "    Virtual Machine: vm-{name}-win-01"
    Write-Host ""

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
    Write-ColorOutput "  Environment name: " Green -NoNewline
    Write-Host $script:EnvName -ForegroundColor White
    Write-ColorOutput "  Your resources will be named like: rg-$($script:EnvName)-lesson03-storage" Cyan
}

#===============================================================================
# LESSON SELECTION
#===============================================================================
function Select-Lesson {
    Show-Section "📚 Select Lesson to Deploy"

    Write-ColorOutput "  HOW DEPLOYMENT WORKS:" Cyan
    Write-Host "    1. You select a lesson below"
    Write-Host "    2. Bicep files in /infra/modules/ define the Azure resources"
    Write-Host "    3. azd compiles Bicep → ARM template → deploys to Azure"
    Write-Host "    4. Resources appear in a dedicated resource group"
    Write-Host ""
    Write-Host "  Each lesson deploys to its " -NoNewline
    Write-ColorOutput "own resource group" Cyan -NoNewline
    Write-Host " for easy cleanup."
    Write-Host "  Lessons 1, 10, 12 are " -NoNewline
    Write-ColorOutput "portal/CLI demos" Green -NoNewline
    Write-Host " - no Azure resources needed."
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "    DAY 1 - FOUNDATIONS" -ForegroundColor White
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "     " -NoNewline; Write-ColorOutput "1)" Cyan -NoNewline; Write-Host " Introduction to Azure      " -NoNewline; Write-ColorOutput "[NO RESOURCES]" Green -NoNewline; Write-Host " Portal & CLI basics"
    Write-Host "     " -NoNewline; Write-ColorOutput "2)" Cyan -NoNewline; Write-Host " Getting Started            " -NoNewline; Write-ColorOutput "[TENANT]" Yellow -NoNewline; Write-Host "       Management Groups"
    Write-Host "     " -NoNewline; Write-ColorOutput "3)" Cyan -NoNewline; Write-Host " Storage Services           " -NoNewline; Write-ColorOutput "[FREE]" Green -NoNewline; Write-Host "         Blobs, queues, tables"
    Write-Host "     " -NoNewline; Write-ColorOutput "4)" Cyan -NoNewline; Write-Host " Networking Services        " -NoNewline; Write-ColorOutput "[FREE]" Green -NoNewline; Write-Host "         VNets, subnets, NSGs"
    Write-Host "     " -NoNewline; Write-ColorOutput "5)" Cyan -NoNewline; Write-Host " Compute: Windows           " -NoNewline; Write-ColorOutput "[QUOTA: B1s]" Yellow -NoNewline; Write-Host "  Windows VM + App Service"
    Write-Host "     " -NoNewline; Write-ColorOutput "6)" Cyan -NoNewline; Write-Host " Compute: Linux & K8s       " -NoNewline; Write-ColorOutput "[QUOTA: B1s]" Yellow -NoNewline; Write-Host "  Ubuntu VM + MicroK8s"
    Write-Host "     " -NoNewline; Write-ColorOutput "7)" Cyan -NoNewline; Write-Host " Container Services         " -NoNewline; Write-ColorOutput "[~`$35/mo]" Yellow -NoNewline; Write-Host "      ACR + AKS"
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "    DAY 2 - ADVANCED SERVICES" -ForegroundColor White
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "     " -NoNewline; Write-ColorOutput "8)" Cyan -NoNewline; Write-Host " Serverless Services        " -NoNewline; Write-ColorOutput "[QUOTA: Dynamic]" Yellow -NoNewline; Write-Host " Azure Functions"
    Write-Host "     " -NoNewline; Write-ColorOutput "9)" Cyan -NoNewline; Write-Host " Database & Data Services   " -NoNewline; Write-ColorOutput "[Pay-per-use]" Yellow -NoNewline; Write-Host "  Cosmos DB Serverless"
    Write-Host "    " -NoNewline; Write-ColorOutput "10)" Cyan -NoNewline; Write-Host " Billing & Cost Mgmt        " -NoNewline; Write-ColorOutput "[NO RESOURCES]" Green -NoNewline; Write-Host " Cost management demo"
    Write-Host "    " -NoNewline; Write-ColorOutput "11)" Cyan -NoNewline; Write-Host " Azure AI Foundry           " -NoNewline; Write-ColorOutput "[`$1-5/day]" Red -NoNewline; Write-Host "     AI Hub, model catalog"
    Write-Host "    " -NoNewline; Write-ColorOutput "12)" Cyan -NoNewline; Write-Host " Architecture Design        " -NoNewline; Write-ColorOutput "[NO RESOURCES]" Green -NoNewline; Write-Host " Whiteboard session"
    Write-Host ""
    Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Yellow
    Write-Host "     " -NoNewline; Write-ColorOutput "0)" Cyan -NoNewline; Write-Host " Deploy ALL Resources       " -NoNewline; Write-ColorOutput "[ALL QUOTAS]" Red -NoNewline; Write-Host "   Lessons 2-9,11"
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
    Write-ColorOutput "  │" Magenta -NoNewline; Write-Host "  Request quota increase: " -NoNewline; Write-ColorOutput "https://aka.ms/azurequotarequest" Cyan -NoNewline; Write-ColorOutput "                │" Magenta
    Write-ColorOutput "  └─────────────────────────────────────────────────────────────────────────────┘" Magenta
    Write-Host ""

    while ($true) {
        $choice = Read-Host "  Select lesson [0-12]"
        switch ($choice) {
            "0" { $script:SelectedLesson = ""; $script:SshRequired = $true; $script:WinPasswordRequired = $true; $script:DeployAll = $true; break }
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

    if ($script:NoResources) {
        Write-Host ""
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
        Write-ColorOutput "    ✅ Lesson $($script:SelectedLesson) is a demo - no deployment needed!" Green
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
        Write-Host ""
        Write-Host "  Navigate to the lesson folder to follow along:"
        Write-ColorOutput "    cd lessons\$($script:SelectedLesson)-*" Cyan
        Write-Host ""
        Read-Host "  Press Enter to exit"
        exit 0
    }

    if ($script:MgmtGroups) {
        return
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

#===============================================================================
# PASSWORD GENERATION
#===============================================================================
function New-RandomPassword {
    $upper = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    $lower = "abcdefghjkmnpqrstuvwxyz"
    $nums = "23456789"
    $special = "!@#$%&*"

    $password = ""
    $password += $upper[(Get-Random -Maximum $upper.Length)]
    $password += $lower[(Get-Random -Maximum $lower.Length)]
    $password += $nums[(Get-Random -Maximum $nums.Length)]
    $password += $special[(Get-Random -Maximum $special.Length)]

    $all = $upper + $lower + $nums
    for ($i = 0; $i -lt 8; $i++) {
        $password += $all[(Get-Random -Maximum $all.Length)]
    }

    $password += $special[(Get-Random -Maximum $special.Length)]
    $password += $upper[(Get-Random -Maximum $upper.Length)]
    $password += $lower[(Get-Random -Maximum $lower.Length)]
    $password += $nums[(Get-Random -Maximum $nums.Length)]

    $chars = $password.ToCharArray()
    $shuffled = $chars | Get-Random -Count $chars.Count
    return -join $shuffled
}

#===============================================================================
# WINDOWS PASSWORD SETUP
#===============================================================================
function Setup-WindowsPassword {
    if (-not $script:WinPasswordRequired) {
        return
    }

    Show-Section "🔐 Windows VM Password Setup"

    Write-ColorOutput "  WHAT YOU'RE CONFIGURING:" Cyan
    Write-Host "    Lesson 5 deploys a Windows Server VM with IIS web server."
    Write-Host "    You'll use Remote Desktop (RDP) to connect to this VM."
    Write-Host ""
    Write-ColorOutput "  Password requirements (Azure enforced):" Yellow
    Write-Host "    • At least 12 characters"
    Write-Host "    • Contains uppercase (A-Z), lowercase (a-z), number (0-9)"
    Write-Host "    • Special character recommended (!@#$%^&*)"
    Write-Host ""
    Write-ColorOutput "  Password options:" Cyan
    Write-Host "    1) Generate a secure random password (recommended)"
    Write-Host "    2) Enter your own password"
    Write-Host ""

    $passwordOption = Read-Host "  Select option [1-2, default=1]"
    if ([string]::IsNullOrWhiteSpace($passwordOption)) { $passwordOption = "1" }

    if ($passwordOption -eq "1") {
        $script:WindowsPassword = New-RandomPassword
        Write-ColorOutput "  ✓ Generated secure password." Green
        Write-Host ""
        Write-ColorOutput "  ╔══════════════════════════════════════════════════════════════╗" Yellow
        Write-ColorOutput "  ║  " Yellow -NoNewline; Write-Host "IMPORTANT: SAVE THIS PASSWORD NOW!" -ForegroundColor Red -NoNewline; Write-ColorOutput "                          ║" Yellow
        Write-ColorOutput "  ╠══════════════════════════════════════════════════════════════╣" Yellow
        Write-ColorOutput "  ║  Username: " Yellow -NoNewline; Write-Host "azureuser" -ForegroundColor White -NoNewline; Write-ColorOutput "                                        ║" Yellow
        Write-ColorOutput "  ║  Password: " Yellow -NoNewline; Write-Host $script:WindowsPassword -ForegroundColor White -NoNewline; Write-ColorOutput "                      ║" Yellow
        Write-ColorOutput "  ╚══════════════════════════════════════════════════════════════╝" Yellow
        Write-Host ""
        Write-ColorOutput "  You'll need these credentials to RDP into your Windows VM." Cyan
    } else {
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
}

#===============================================================================
# SSH KEY SETUP
#===============================================================================
function Setup-SshKey {
    if (-not $script:SshRequired) {
        return
    }

    Show-Section "🔑 SSH Key Setup"

    Write-ColorOutput "  WHAT YOU'RE CONFIGURING:" Cyan
    Write-Host "    Lesson 6 deploys an Ubuntu Linux VM with MicroK8s."
    Write-Host "    You'll use SSH (Secure Shell) to connect to this VM."
    Write-Host ""
    Write-ColorOutput "  WHY SSH KEYS?" Cyan
    Write-Host "    SSH keys are more secure than passwords:"
    Write-Host "    • Can't be guessed or brute-forced"
    Write-Host "    • Private key never leaves your machine"
    Write-Host ""

    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { "~" }

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

        if (Test-Path $keyPath) {
            Remove-Item $keyPath -Force
            Remove-Item "$keyPath.pub" -Force -ErrorAction SilentlyContinue
        }

        ssh-keygen -t ed25519 -f $keyPath -N '""' -C "azure-essentials-vm"

        $script:SshPublicKey = (Get-Content "$keyPath.pub" -Raw).Trim()
        Write-Host ""
        Write-ColorOutput "  ✓ SSH key generated: $keyPath" Green
        Write-Host ""
        Write-ColorOutput "  💡 To SSH to your VM after deployment:" Yellow
        Write-ColorOutput "     ssh -i $keyPath azureuser@<vm-public-ip>" Cyan
    }
    Write-Host ""
}

#===============================================================================
# MANAGEMENT GROUPS DEPLOYMENT
#===============================================================================
function Deploy-ManagementGroups {
    Show-Section "🏢 Deploying Management Groups"

    Write-ColorOutput "  WHAT YOU'RE DEPLOYING:" Cyan
    Write-Host "    Management Groups create an organizational hierarchy above subscriptions."
    Write-Host "    This follows the Azure Landing Zone pattern used by enterprises."
    Write-Host ""
    Write-ColorOutput "  ⚠️  REQUIREMENT: Tenant-level permissions (Global Admin or similar)" Yellow
    Write-Host ""
    Write-ColorOutput "  HIERARCHY BEING CREATED:" Cyan
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

    $mgPrefix = "mg-$($script:EnvName)"

    try {
        Write-Host "  Creating root: $mgPrefix-root"
        az account management-group create --name "$mgPrefix-root" --display-name "Organization Root" --output none 2>$null

        Write-Host "  Creating second-level groups..."
        foreach ($child in @("platform", "workloads", "sandbox")) {
            $displayName = (Get-Culture).TextInfo.ToTitleCase($child)
            az account management-group create --name "$mgPrefix-$child" --display-name $displayName --parent "$mgPrefix-root" --output none 2>$null
            Write-Host "    ✓ $mgPrefix-$child"
        }

        Write-Host "  Creating Platform children..."
        foreach ($child in @("identity", "connectivity", "management")) {
            $displayName = (Get-Culture).TextInfo.ToTitleCase($child)
            az account management-group create --name "$mgPrefix-$child" --display-name $displayName --parent "$mgPrefix-platform" --output none 2>$null
            Write-Host "    ✓ $mgPrefix-$child"
        }

        Write-Host "  Creating Workloads children..."
        az account management-group create --name "$mgPrefix-prod" --display-name "Production" --parent "$mgPrefix-workloads" --output none 2>$null
        Write-Host "    ✓ $mgPrefix-prod"
        az account management-group create --name "$mgPrefix-nonprod" --display-name "Non-Production" --parent "$mgPrefix-workloads" --output none 2>$null
        Write-Host "    ✓ $mgPrefix-nonprod"

        Write-Host ""
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
        Write-ColorOutput "    ✅ Management Groups Created Successfully!" Green
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Green
        Write-Host ""
        Write-Host "  View in Azure Portal:"
        Write-Host "    https://portal.azure.com/#view/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade"
    } catch {
        Write-Host ""
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Red
        Write-ColorOutput "    ❌ Deployment Failed" Red
        Write-ColorOutput "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" Red
        Write-Host ""
        Write-Host "  Common issues:"
        Write-Host "    • You need tenant-level permissions (Global Admin or similar)"
    }
}

function Deploy-ManagementGroupsSilent {
    Write-Host ""
    Write-ColorOutput "  Deploying Management Groups via Azure CLI..." Cyan
    Write-Host ""

    $mgPrefix = "mg-$($script:EnvName)"

    Write-Host "    Creating root: $mgPrefix-root"
    az account management-group create --name "$mgPrefix-root" --display-name "Organization Root" --output none 2>$null

    Write-Host "    Creating second-level groups..."
    foreach ($child in @("platform", "workloads", "sandbox")) {
        $displayName = (Get-Culture).TextInfo.ToTitleCase($child)
        az account management-group create --name "$mgPrefix-$child" --display-name $displayName --parent "$mgPrefix-root" --output none 2>$null
        Write-Host "      ✓ $mgPrefix-$child"
    }

    Write-Host "    Creating Platform children..."
    foreach ($child in @("identity", "connectivity", "management")) {
        $displayName = (Get-Culture).TextInfo.ToTitleCase($child)
        az account management-group create --name "$mgPrefix-$child" --display-name $displayName --parent "$mgPrefix-platform" --output none 2>$null
        Write-Host "      ✓ $mgPrefix-$child"
    }

    Write-Host "    Creating Workloads children..."
    az account management-group create --name "$mgPrefix-prod" --display-name "Production" --parent "$mgPrefix-workloads" --output none 2>$null
    Write-Host "      ✓ $mgPrefix-prod"
    az account management-group create --name "$mgPrefix-nonprod" --display-name "Non-Production" --parent "$mgPrefix-workloads" --output none 2>$null
    Write-Host "      ✓ $mgPrefix-nonprod"

    Write-Host ""
    Write-ColorOutput "    ✅ Management Groups created (9 total)" Green
}

#===============================================================================
# DEPLOYMENT CONFIRMATION & EXECUTION
#===============================================================================
function Confirm-AndDeploy {
    Show-Section "🚀 Ready to Deploy"

    Write-ColorOutput "  DEPLOYMENT SUMMARY:" Cyan
    Write-Host ""
    Write-Host "    Environment:  " -NoNewline
    Write-Host $script:EnvName -ForegroundColor White
    Write-Host "    Region:       " -NoNewline
    Write-Host $script:SelectedRegion -ForegroundColor White

    if ([string]::IsNullOrEmpty($script:SelectedLesson)) {
        Write-Host "    Lesson:       " -NoNewline
        Write-Host "All Lessons (02-09, 11)" -ForegroundColor White
    } else {
        Write-Host "    Lesson:       " -NoNewline
        Write-Host "Lesson $($script:SelectedLesson)" -ForegroundColor White
    }
    Write-Host ""

    $confirm = Read-Host "  Proceed with deployment? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-ColorOutput "  Deployment cancelled." Yellow
        exit 0
    }

    Show-Section "⚙️  Initializing Environment"

    $subscriptionId = az account show --query id -o tsv 2>$null
    if ([string]::IsNullOrEmpty($subscriptionId)) {
        Write-ColorOutput "  Error: Could not get Azure subscription ID" Red
        exit 1
    }

    $subscriptionName = az account show --query name -o tsv
    Write-Host "  Using subscription: " -NoNewline
    Write-Host $subscriptionName -ForegroundColor White

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

    Show-Section "☁️  Deploying to Azure"

    Write-ColorOutput "  Estimated time: 5-15 minutes depending on resources..." Yellow
    Write-Host ""

    if ($script:DeployAll) {
        Write-ColorOutput "  Step 1/2: Deploying Management Groups via Azure CLI..." Cyan
        Deploy-ManagementGroupsSilent
        Write-Host ""
        Write-ColorOutput "  Step 2/2: Deploying Lessons 3-9,11 via Bicep..." Cyan
    }

    azd up

    if ($script:SelectedLesson -eq "07" -or [string]::IsNullOrEmpty($script:SelectedLesson)) {
        Build-HelloContainer
    }
}

function Build-HelloContainer {
    $scriptPath = $PSScriptRoot
    $repoRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)
    $helloAppDir = Join-Path $repoRoot "lessons/07-container-services/src/hello-container"

    try {
        $acrName = az acr list --query "[?contains(name, '$($script:EnvName)')].name" -o tsv 2>$null | Select-Object -First 1
    } catch {
        return
    }

    if ($acrName -and (Test-Path $helloAppDir)) {
        Write-Host ""
        Write-ColorOutput "  Building hello-container in ACR..." Cyan
        az acr build --registry $acrName --image "hello-container:v1" --file "$helloAppDir/Dockerfile" $helloAppDir --no-logs
        $loginServer = az acr show --name $acrName --query loginServer -o tsv
        Write-ColorOutput "  ✓ Image built: ${loginServer}/hello-container:v1" Green
    }
}

#===============================================================================
# COMPLETION MESSAGE
#===============================================================================
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

#===============================================================================
# MAIN FUNCTION
#===============================================================================
function Main {
    Show-Banner
    Test-Prerequisites
    Select-Subscription
    Get-EnvironmentName
    Select-Region
    Test-PreflightChecks
    Select-Lesson

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

#===============================================================================
# SCRIPT ENTRY POINT
#===============================================================================
Main
