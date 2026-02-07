#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Essentials - Local Tools Setup Script
.DESCRIPTION
    This script installs the required tools for the Azure Essentials course.
    Supports Windows with winget, Chocolatey, or manual installation.
    Code to Cloud - www.codetocloud.io
.EXAMPLE
    .\setup-local-tools.ps1
#>

$ErrorActionPreference = "Stop"

# Colors for output
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

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-AdminRights {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Banner
Clear-Host
Write-Host ""
Write-ColorOutput "  ==========================================" Blue
Write-ColorOutput "    Azure Essentials - Environment Setup   " Blue
Write-ColorOutput "    Code to Cloud                          " Blue
Write-ColorOutput "  ==========================================" Blue
Write-Host ""

# Detect package manager
$hasWinget = Test-Command "winget"
$hasChoco = Test-Command "choco"

if ($hasWinget) {
    Write-ColorOutput "  ✓ Package Manager: winget detected" Green
} elseif ($hasChoco) {
    Write-ColorOutput "  ✓ Package Manager: Chocolatey detected" Green
} else {
    Write-ColorOutput "  ⚠ No package manager found" Yellow
    Write-Host "  winget is recommended (included with Windows 11 and Windows 10 updates)"
    Write-Host "  Alternatively, install Chocolatey: https://chocolatey.org/install"
    Write-Host ""
}

Write-Host ""
Write-ColorOutput "  Installing/Checking Required Tools..." Cyan
Write-Host ""

# Track installation status
$tools = @{}

# Install Azure CLI
Write-Host "  Checking Azure CLI..." -NoNewline
if (Test-Command "az") {
    try {
        $azVersion = (az version --query '"azure-cli"' -o tsv 2>$null)
        Write-ColorOutput " ✓ Installed ($azVersion)" Green
        $tools["az"] = $true
    } catch {
        Write-ColorOutput " ✓ Installed" Green
        $tools["az"] = $true
    }
} else {
    Write-ColorOutput " Installing..." Yellow
    if ($hasWinget) {
        winget install Microsoft.AzureCLI --silent --accept-package-agreements --accept-source-agreements
    } elseif ($hasChoco) {
        choco install azure-cli -y
    } else {
        Write-ColorOutput "    Please install manually: https://aka.ms/installazurecli" Cyan
    }
    $tools["az"] = Test-Command "az"
}

# Install Azure Developer CLI (azd)
Write-Host "  Checking Azure Developer CLI..." -NoNewline
if (Test-Command "azd") {
    try {
        $azdVersion = (azd version 2>$null | Select-Object -First 1)
        Write-ColorOutput " ✓ Installed ($azdVersion)" Green
        $tools["azd"] = $true
    } catch {
        Write-ColorOutput " ✓ Installed" Green
        $tools["azd"] = $true
    }
} else {
    Write-ColorOutput " Installing..." Yellow
    if ($hasWinget) {
        winget install Microsoft.Azd --silent --accept-package-agreements --accept-source-agreements
    } elseif ($hasChoco) {
        choco install azd -y
    } else {
        Write-ColorOutput "    Please install manually: https://aka.ms/azure-dev/install" Cyan
    }
    $tools["azd"] = Test-Command "azd"
}

# Install kubectl
Write-Host "  Checking kubectl..." -NoNewline
if (Test-Command "kubectl") {
    try {
        $kubectlVersion = (kubectl version --client -o json 2>$null | ConvertFrom-Json).clientVersion.gitVersion
        Write-ColorOutput " ✓ Installed ($kubectlVersion)" Green
        $tools["kubectl"] = $true
    } catch {
        Write-ColorOutput " ✓ Installed" Green
        $tools["kubectl"] = $true
    }
} else {
    Write-ColorOutput " Installing..." Yellow
    if ($hasWinget) {
        winget install Kubernetes.kubectl --silent --accept-package-agreements --accept-source-agreements
    } elseif ($hasChoco) {
        choco install kubernetes-cli -y
    } else {
        Write-ColorOutput "    Please install manually: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/" Cyan
    }
    $tools["kubectl"] = Test-Command "kubectl"
}

# Install Git
Write-Host "  Checking Git..." -NoNewline
if (Test-Command "git") {
    try {
        $gitVersion = (git --version)
        Write-ColorOutput " ✓ $gitVersion" Green
        $tools["git"] = $true
    } catch {
        Write-ColorOutput " ✓ Installed" Green
        $tools["git"] = $true
    }
} else {
    Write-ColorOutput " Installing..." Yellow
    if ($hasWinget) {
        winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
    } elseif ($hasChoco) {
        choco install git -y
    } else {
        Write-ColorOutput "    Please install manually: https://git-scm.com/download/win" Cyan
    }
    $tools["git"] = Test-Command "git"
}

# Install Python
Write-Host "  Checking Python..." -NoNewline
if ((Test-Command "python") -or (Test-Command "python3")) {
    try {
        # Try python3 first (macOS/Linux), then python (Windows)
        if (Test-Command "python3") {
            $pythonVersion = (python3 --version 2>&1)
        } else {
            $pythonVersion = (python --version 2>&1)
        }
        Write-ColorOutput " ✓ $pythonVersion" Green
        $tools["python"] = $true
    } catch {
        Write-ColorOutput " ✓ Installed" Green
        $tools["python"] = $true
    }
} else {
    Write-ColorOutput " Installing..." Yellow
    if ($hasWinget) {
        winget install Python.Python.3.11 --silent --accept-package-agreements --accept-source-agreements
    } elseif ($hasChoco) {
        choco install python -y
    } else {
        Write-ColorOutput "    Please install manually: https://www.python.org/downloads/" Cyan
    }
    $tools["python"] = (Test-Command "python") -or (Test-Command "python3")
}

# Install jq
Write-Host "  Checking jq..." -NoNewline
if (Test-Command "jq") {
    try {
        $jqVersion = (jq --version 2>&1)
        Write-ColorOutput " ✓ $jqVersion" Green
        $tools["jq"] = $true
    } catch {
        Write-ColorOutput " ✓ Installed" Green
        $tools["jq"] = $true
    }
} else {
    Write-ColorOutput " Installing..." Yellow
    if ($hasWinget) {
        winget install jqlang.jq --silent --accept-package-agreements --accept-source-agreements
    } elseif ($hasChoco) {
        choco install jq -y
    } else {
        Write-ColorOutput "    Please install manually: https://stedolan.github.io/jq/download/" Cyan
    }
    $tools["jq"] = Test-Command "jq"
}

# Install Visual Studio Code
Write-Host "  Checking VS Code..." -NoNewline
# Check for 'code' command OR VS Code app on macOS
$vscodeInstalled = (Test-Command "code") -or (Test-Path "/Applications/Visual Studio Code.app")
if ($vscodeInstalled) {
    Write-ColorOutput " ✓ Installed" Green
    $tools["code"] = $true
    if (-not (Test-Command "code")) {
        Write-ColorOutput "    Tip: Add 'code' to PATH via: VS Code > Command Palette > 'Shell Command: Install'" Yellow
    }
} else {
    Write-ColorOutput " Installing..." Yellow
    if ($hasWinget) {
        winget install Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
    } elseif ($hasChoco) {
        choco install vscode -y
    } else {
        Write-ColorOutput "    Please install manually: https://code.visualstudio.com/" Cyan
    }
    $tools["code"] = Test-Command "code"
}

# Check for Docker Desktop
Write-Host "  Checking Docker..." -NoNewline
if (Test-Command "docker") {
    try {
        $dockerVersion = (docker version --format '{{.Client.Version}}' 2>$null)
        Write-ColorOutput " ✓ Installed ($dockerVersion)" Green
        $tools["docker"] = $true
    } catch {
        Write-ColorOutput " ✓ Installed" Green
        $tools["docker"] = $true
    }
} else {
    Write-ColorOutput " Not installed" Yellow
    Write-ColorOutput "    Please install Docker Desktop: https://www.docker.com/products/docker-desktop/" Cyan
    $tools["docker"] = $false
}

# Install Bicep CLI via Azure CLI
Write-Host ""
Write-ColorOutput "  Installing/updating Bicep CLI..." Yellow
if (Test-Command "az") {
    try {
        az bicep install 2>$null
        Write-ColorOutput "  ✓ Bicep CLI ready" Green
    } catch {
        try {
            az bicep upgrade 2>$null
            Write-ColorOutput "  ✓ Bicep CLI updated" Green
        } catch {
            Write-ColorOutput "  ✓ Bicep CLI ready" Green
        }
    }
}

# Install Azure CLI Extensions
Write-Host ""
Write-ColorOutput "  ==========================================" Blue
Write-ColorOutput "    Azure CLI Extensions                   " Blue
Write-ColorOutput "  ==========================================" Blue
Write-Host ""

Write-ColorOutput "  Installing containerapp extension (Lesson 07)..." Yellow
if (Test-Command "az") {
    try {
        az extension add --name containerapp --upgrade -y 2>$null
        Write-ColorOutput "  ✓ containerapp extension ready" Green
    } catch {
        Write-ColorOutput "  ○ containerapp extension (install manually)" Yellow
        Write-Host "    Run: az extension add --name containerapp -y"
    }
}

# Register Azure Resource Providers
Write-Host ""
Write-ColorOutput "  ==========================================" Blue
Write-ColorOutput "    Azure Resource Providers               " Blue
Write-ColorOutput "  ==========================================" Blue
Write-Host ""

Write-ColorOutput "  Registering required resource providers..." Yellow

if (Test-Command "az") {
    try {
        $account = az account show 2>$null | ConvertFrom-Json
        if ($account) {
            $providers = @(
                "Microsoft.Compute",
                "Microsoft.Storage",
                "Microsoft.Network",
                "Microsoft.Web",
                "Microsoft.App",
                "Microsoft.ContainerRegistry"
            )

            foreach ($provider in $providers) {
                $state = az provider show --namespace $provider --query registrationState -o tsv 2>$null
                if ($state -eq "Registered") {
                    Write-ColorOutput "  ✓ $provider - Already registered" Green
                } else {
                    Write-ColorOutput "  ○ Registering $provider..." Yellow
                    Start-Job -ScriptBlock { param($p) az provider register --namespace $p } -ArgumentList $provider | Out-Null
                }
            }
            Write-Host ""
            Write-ColorOutput "  Note: Provider registration may take a few minutes." Cyan
        } else {
            Write-ColorOutput "  ○ Not logged in - skipping provider registration" Yellow
            Write-Host "    After 'az login', run this script again"
        }
    } catch {
        Write-ColorOutput "  ○ Not logged in - skipping provider registration" Yellow
    }
}

# Summary
Write-Host ""
Write-ColorOutput "  ==========================================" Blue
Write-ColorOutput "    Installation Summary                   " Blue
Write-ColorOutput "  ==========================================" Blue
Write-Host ""

$allInstalled = $true
$toolList = @("az", "azd", "git", "code", "kubectl", "python", "jq", "docker")

foreach ($tool in $toolList) {
    # Special handling for tools that might be named differently on macOS
    $isInstalled = $tools[$tool]
    if (-not $isInstalled) {
        if ($tool -eq "python") {
            $isInstalled = (Test-Command "python3")
        } elseif ($tool -eq "code") {
            $isInstalled = (Test-Path "/Applications/Visual Studio Code.app")
        }
    }

    if ($isInstalled) {
        Write-ColorOutput "  ✓ $tool" Green
    } else {
        Write-ColorOutput "  ✗ $tool (not installed)" Red
        $allInstalled = $false
    }
}

Write-Host ""

if ($allInstalled) {
    Write-ColorOutput "  All tools installed successfully!" Green
    Write-Host ""
    Write-ColorOutput "  Next steps:" Blue
    Write-Host "    1. Open a NEW terminal (to refresh PATH)"
    Write-Host "    2. Run: az login"
    Write-Host "    3. Run: azd auth login"
    Write-Host "    4. Run: .\scripts\powershell\validate-env.ps1"
} else {
    Write-ColorOutput "  Some tools could not be installed automatically." Yellow
    Write-Host "  Please install them manually and run this script again."
    Write-Host ""
    Write-ColorOutput "  Note: You may need to open a NEW terminal after installation" Yellow
    Write-Host "  for the tools to be available in your PATH."
}

Write-Host ""
Write-ColorOutput "  ==========================================" Blue
Write-ColorOutput "    Code to Cloud - www.codetocloud.io     " Blue
Write-ColorOutput "  ==========================================" Blue
Write-Host ""
