#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Essentials - Environment Validation Script
.DESCRIPTION
    This script validates that all required tools are installed and configured.
    Code to Cloud - www.codetocloud.io
.EXAMPLE
    .\validate-env.ps1
#>

$ErrorActionPreference = "Continue"

# Track validation status
$script:ValidationPassed = $true

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

# Banner
Write-Host ""
Write-ColorOutput "  ==========================================" Blue
Write-ColorOutput "    Azure Essentials - Environment Check   " Blue
Write-ColorOutput "    Code to Cloud                          " Blue
Write-ColorOutput "  ==========================================" Blue
Write-Host ""

#===============================================================================
# TOOL CHECKS
#===============================================================================

Write-ColorOutput "  Checking Required Tools..." Cyan
Write-Host ""

# Azure CLI
Write-Host "  " -NoNewline
if (Test-Command "az") {
    try {
        $azVersion = (az version --query '"azure-cli"' -o tsv 2>$null)
        Write-ColorOutput "✓ Azure CLI: $azVersion" Green
    } catch {
        Write-ColorOutput "✓ Azure CLI: installed" Green
    }
} else {
    Write-ColorOutput "✗ Azure CLI: Not installed" Red
    Write-Host "    Install: https://aka.ms/installazurecli"
    $script:ValidationPassed = $false
}

# Azure Developer CLI
Write-Host "  " -NoNewline
if (Test-Command "azd") {
    try {
        $azdVersion = (azd version 2>$null | Select-Object -First 1)
        Write-ColorOutput "✓ Azure Developer CLI: $azdVersion" Green
    } catch {
        Write-ColorOutput "✓ Azure Developer CLI: installed" Green
    }
} else {
    Write-ColorOutput "✗ Azure Developer CLI: Not installed" Red
    Write-Host "    Install: winget install Microsoft.Azd"
    $script:ValidationPassed = $false
}

# Git
Write-Host "  " -NoNewline
if (Test-Command "git") {
    try {
        $gitVersion = (git --version)
        Write-ColorOutput "✓ $gitVersion" Green
    } catch {
        Write-ColorOutput "✓ Git: installed" Green
    }
} else {
    Write-ColorOutput "✗ Git: Not installed" Red
    Write-Host "    Install: winget install Git.Git"
    $script:ValidationPassed = $false
}

# kubectl
Write-Host "  " -NoNewline
if (Test-Command "kubectl") {
    try {
        $kubectlVersion = (kubectl version --client -o json 2>$null | ConvertFrom-Json).clientVersion.gitVersion
        Write-ColorOutput "✓ kubectl: $kubectlVersion" Green
    } catch {
        Write-ColorOutput "✓ kubectl: installed" Green
    }
} else {
    Write-ColorOutput "○ kubectl: Not installed (optional)" Yellow
    Write-Host "    Install: winget install Kubernetes.kubectl"
}

# Docker
Write-Host "  " -NoNewline
if (Test-Command "docker") {
    try {
        $null = docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Docker: running" Green
        } else {
            Write-ColorOutput "○ Docker: installed but not running" Yellow
            Write-Host "    Start Docker Desktop"
        }
    } catch {
        Write-ColorOutput "○ Docker: installed but not running" Yellow
    }
} else {
    Write-ColorOutput "○ Docker: Not installed (optional)" Yellow
    Write-Host "    Install Docker Desktop: https://docker.com/products/docker-desktop"
}

# Python
Write-Host "  " -NoNewline
if (Test-Command "python") {
    try {
        $pythonVersion = (python --version 2>&1)
        Write-ColorOutput "✓ $pythonVersion" Green
    } catch {
        Write-ColorOutput "✓ Python: installed" Green
    }
} else {
    Write-ColorOutput "○ Python: Not installed (optional)" Yellow
    Write-Host "    Install: winget install Python.Python.3.11"
}

#===============================================================================
# AUTHENTICATION CHECKS
#===============================================================================

Write-Host ""
Write-ColorOutput "  Checking Azure Authentication..." Cyan
Write-Host ""

# Azure CLI login
Write-Host "  " -NoNewline
try {
    $account = az account show --query name -o tsv 2>$null
    if ($account) {
        Write-ColorOutput "✓ Azure CLI: Signed in to '$account'" Green
    } else {
        Write-ColorOutput "○ Azure CLI: Not authenticated" Yellow
        Write-Host "    Run: az login"
        $script:ValidationPassed = $false
    }
} catch {
    Write-ColorOutput "○ Azure CLI: Not authenticated" Yellow
    Write-Host "    Run: az login"
    $script:ValidationPassed = $false
}

# Azure Developer CLI login
Write-Host "  " -NoNewline
try {
    $null = azd auth login --check-status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Azure Developer CLI: Authenticated" Green
    } else {
        Write-ColorOutput "○ Azure Developer CLI: Not authenticated" Yellow
        Write-Host "    Run: azd auth login"
        $script:ValidationPassed = $false
    }
} catch {
    Write-ColorOutput "○ Azure Developer CLI: Not authenticated" Yellow
    Write-Host "    Run: azd auth login"
    $script:ValidationPassed = $false
}

#===============================================================================
# VS CODE EXTENSIONS CHECK
#===============================================================================

Write-Host ""
Write-ColorOutput "  Checking VS Code Extensions..." Cyan
Write-Host ""

if (Test-Command "code") {
    $requiredExtensions = @(
        "ms-azuretools.vscode-bicep",
        "ms-vscode.vscode-node-azure-pack",
        "hashicorp.terraform",
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "redhat.vscode-yaml"
    )

    try {
        $installedExtensions = code --list-extensions 2>$null

        foreach ($ext in $requiredExtensions) {
            Write-Host "  " -NoNewline
            if ($installedExtensions -contains $ext) {
                Write-ColorOutput "✓ $ext" Green
            } else {
                Write-ColorOutput "○ $ext (not installed)" Yellow
            }
        }
    } catch {
        Write-Host "  " -NoNewline
        Write-ColorOutput "○ Could not check VS Code extensions" Yellow
    }
} else {
    Write-Host "  " -NoNewline
    Write-ColorOutput "○ VS Code CLI not available" Yellow
    Write-Host "    Install VS Code: https://code.visualstudio.com/"
}

#===============================================================================
# SUMMARY
#===============================================================================

Write-Host ""
Write-ColorOutput "  ==========================================" Blue

if ($script:ValidationPassed) {
    Write-ColorOutput "    ✅ All required tools are ready!" Green
    Write-ColorOutput "  ==========================================" Blue
    Write-Host ""
    Write-Host "  You're ready to start the Azure Essentials course!"
    Write-Host ""
    Write-ColorOutput "  Quick Start:" Cyan
    Write-Host "    .\scripts\powershell\deploy.ps1"
    Write-Host ""
} else {
    Write-ColorOutput "    ⚠️  Some tools need attention" Yellow
    Write-ColorOutput "  ==========================================" Blue
    Write-Host ""
    Write-Host "  Please install or configure the missing items above."
    Write-Host ""
    Write-ColorOutput "  Quick Setup:" Cyan
    Write-Host "    .\scripts\powershell\setup-local-tools.ps1"
    Write-Host ""
}

Write-ColorOutput "  Code to Cloud | www.codetocloud.io" Blue
Write-Host ""
