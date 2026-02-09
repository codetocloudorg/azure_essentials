#!/usr/bin/env pwsh
#===============================================================================
# Azure Essentials - Deployment Validation Script (PowerShell)
#===============================================================================
# Code to Cloud | www.codetocloud.io
#
# PURPOSE:
#   Validates that lesson deployments completed successfully by checking
#   for expected Azure resources. Use this during live training to verify
#   deployments are working correctly before moving to the next lesson.
#
# USAGE:
#   ./test-deployment.ps1                    # Test all lessons
#   ./test-deployment.ps1 -Lesson 03         # Test specific lesson
#   ./test-deployment.ps1 -EnvName myenv     # Test with custom env name
#
#===============================================================================

param(
    [string]$EnvName = $env:AZURE_ENV_NAME,
    [string]$Lesson = ""
)

# Default environment name
if ([string]::IsNullOrEmpty($EnvName)) {
    $EnvName = "azlearn"
}

#===============================================================================
# HELPER FUNCTIONS
#===============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║  $Message" -ForegroundColor White
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
}

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "  $Message" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "  ⚠ $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ● $Message" -ForegroundColor Cyan
}

function Write-Detail {
    param([string]$Message)
    Write-Host "    └─ $Message" -ForegroundColor DarkGray
}

#===============================================================================
# AZURE CLI HELPER FUNCTIONS
#===============================================================================

function Find-ResourceGroups {
    param([string]$Pattern)
    $result = az group list --query "[?contains(name, '$Pattern')].name" -o tsv 2>$null
    return $result -split "`n" | Where-Object { $_ -ne "" }
}

function Test-Resource {
    param(
        [string]$ResourceGroup,
        [string]$ResourceType,
        [string]$NamePattern = ""
    )
    
    $query = if ($NamePattern) {
        "[?contains(name, '$NamePattern')]"
    } else {
        "@"
    }
    
    $count = az resource list `
        --resource-group $ResourceGroup `
        --resource-type $ResourceType `
        --query "length($query)" `
        -o tsv 2>$null
    
    return [int]$count -gt 0
}

#===============================================================================
# LESSON VALIDATION FUNCTIONS
#===============================================================================

function Test-Lesson02 {
    Write-Section "🏢 Lesson 02: Management Groups"
    Write-Host "  Checking for management group hierarchy..." -ForegroundColor Cyan
    Write-Host ""
    
    $expectedGroups = @("mg-essentials-root", "mg-essentials-production", "mg-essentials-development", "mg-essentials-sandbox")
    $foundCount = 0
    $foundGroups = @()
    
    foreach ($mg in $expectedGroups) {
        $result = az account management-group show -n $mg --query name -o tsv 2>$null
        if ($result) {
            $foundCount++
            $foundGroups += $mg
        }
    }
    
    if ($foundCount -eq 0) {
        Write-Error2 "No Management Groups found"
        Write-Detail "Expected pattern: mg-essentials-*"
        return $false
    }
    
    Write-Info "Found $foundCount Management Group(s)"
    Write-Success "Management Groups:"
    foreach ($mg in $foundGroups) {
        $display = az account management-group show -n $mg --query displayName -o tsv 2>$null
        if ($display) {
            Write-Detail "$mg ($display)"
        }
    }
    
    Write-Host ""
    Write-Success "Lesson 02 validation PASSED"
    return $true
}

function Test-Lesson03 {
    Write-Section "📦 Lesson 03: Storage Services"
    Write-Host "  Verifying Azure Storage resources..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'storage') || contains(name, 'lesson03') || contains(name, 'lesson-03')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 03"
        Write-Detail "Expected pattern: *lesson03* or *storage*"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    
    if (Test-Resource -ResourceGroup $rg -ResourceType "Microsoft.Storage/storageAccounts") {
        $storageName = az storage account list -g $rg --query "[0].name" -o tsv 2>$null
        Write-Success "Storage Account: $storageName"
        
        $key = az storage account keys list --account-name $storageName -g $rg --query "[0].value" -o tsv 2>$null
        $containers = az storage container list --account-name $storageName --account-key $key --query "length(@)" -o tsv 2>$null
        
        if ([int]$containers -gt 0) {
            Write-Success "Blob Containers: $containers container(s)"
        } else {
            Write-Warning2 "No blob containers found"
        }
        
        Write-Host ""
        Write-Success "Lesson 03 validation PASSED"
        return $true
    } else {
        Write-Error2 "Storage Account not found"
        return $false
    }
}

function Test-Lesson04 {
    Write-Section "🌐 Lesson 04: Networking Services"
    Write-Host "  Verifying Virtual Network infrastructure..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'networking') || contains(name, 'lesson04') || contains(name, 'lesson-04')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 04"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    $passed = 0
    $failed = 0
    
    if (Test-Resource -ResourceGroup $rg -ResourceType "Microsoft.Network/virtualNetworks") {
        $vnetName = az network vnet list -g $rg --query "[0].name" -o tsv 2>$null
        $addressSpace = az network vnet show -g $rg -n $vnetName --query "addressSpace.addressPrefixes[0]" -o tsv 2>$null
        Write-Success "Virtual Network: $vnetName ($addressSpace)"
        
        $subnets = az network vnet subnet list -g $rg --vnet-name $vnetName --query "length(@)" -o tsv 2>$null
        Write-Success "Subnets: $subnets subnet(s)"
        $passed++
    } else {
        Write-Error2 "Virtual Network not found"
        $failed++
    }
    
    if (Test-Resource -ResourceGroup $rg -ResourceType "Microsoft.Network/networkSecurityGroups") {
        $nsgCount = az network nsg list -g $rg --query "length(@)" -o tsv 2>$null
        Write-Success "Network Security Groups: $nsgCount"
        $passed++
    } else {
        Write-Warning2 "No NSG found (may be expected)"
    }
    
    Write-Host ""
    if ($failed -eq 0) {
        Write-Success "Lesson 04 validation PASSED"
        return $true
    } else {
        Write-Error2 "Lesson 04 validation FAILED"
        return $false
    }
}

function Test-Lesson05 {
    Write-Section "🖥️ Lesson 05: Windows Compute"
    Write-Host "  Verifying Windows VM and web server resources..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'compute') || contains(name, 'windows') || contains(name, 'lesson05') || contains(name, 'lesson-05')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 05"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    $passed = 0
    
    $vmName = az vm list -g $rg --query "[?storageProfile.osDisk.osType=='Windows'].name | [0]" -o tsv 2>$null
    if ($vmName) {
        $vmSize = az vm show -g $rg -n $vmName --query "hardwareProfile.vmSize" -o tsv 2>$null
        $powerState = az vm get-instance-view -g $rg -n $vmName --query "instanceView.statuses[1].displayStatus" -o tsv 2>$null
        Write-Success "Windows VM: $vmName ($vmSize)"
        Write-Detail "Power State: $powerState"
        
        $pip = az vm list-ip-addresses -g $rg -n $vmName --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv 2>$null
        if ($pip) {
            Write-Detail "Public IP: $pip"
        }
        $passed++
    } else {
        Write-Warning2 "Windows VM not found (may use App Service only)"
    }
    
    $appName = az webapp list -g $rg --query "[0].name" -o tsv 2>$null
    if ($appName) {
        $appUrl = az webapp show -g $rg -n $appName --query "defaultHostName" -o tsv 2>$null
        Write-Success "App Service: $appName"
        Write-Detail "URL: https://$appUrl"
        $passed++
    } else {
        Write-Warning2 "App Service not found"
    }
    
    Write-Host ""
    if ($passed -gt 0) {
        Write-Success "Lesson 05 validation PASSED"
        return $true
    } else {
        Write-Error2 "Lesson 05 validation FAILED"
        return $false
    }
}

function Test-Lesson06 {
    Write-Section "🐧 Lesson 06: Linux & Kubernetes"
    Write-Host "  Verifying Linux VM with MicroK8s..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'linux') || contains(name, 'k8s') || contains(name, 'lesson06') || contains(name, 'lesson-06')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 06"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    
    $vmName = az vm list -g $rg --query "[?storageProfile.osDisk.osType=='Linux'].name | [0]" -o tsv 2>$null
    if ($vmName) {
        $vmSize = az vm show -g $rg -n $vmName --query "hardwareProfile.vmSize" -o tsv 2>$null
        $image = az vm show -g $rg -n $vmName --query "storageProfile.imageReference.offer" -o tsv 2>$null
        Write-Success "Linux VM: $vmName ($vmSize)"
        Write-Detail "Image: $image"
        
        $pip = az vm list-ip-addresses -g $rg -n $vmName --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv 2>$null
        if ($pip) {
            Write-Detail "SSH: ssh azureuser@$pip"
        }
        
        Write-Host ""
        Write-Success "Lesson 06 validation PASSED"
        return $true
    } else {
        Write-Error2 "Linux VM not found"
        return $false
    }
}

function Test-Lesson07 {
    Write-Section "🐳 Lesson 07: Container Services"
    Write-Host "  Verifying container infrastructure..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'container') || contains(name, 'lesson07') || contains(name, 'lesson-07')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 07"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    
    $acrName = az acr list -g $rg --query "[0].name" -o tsv 2>$null
    if ($acrName) {
        $loginServer = az acr show -g $rg -n $acrName --query "loginServer" -o tsv 2>$null
        $sku = az acr show -g $rg -n $acrName --query "sku.name" -o tsv 2>$null
        Write-Success "Container Registry: $acrName"
        Write-Detail "Login Server: $loginServer"
        Write-Detail "SKU: $sku"
        
        $repoCount = az acr repository list -n $acrName --query "length(@)" -o tsv 2>$null
        if (-not $repoCount) { $repoCount = "0" }
        Write-Detail "Repositories: $repoCount"
        
        Write-Host ""
        Write-Success "Lesson 07 validation PASSED"
        return $true
    } else {
        Write-Error2 "Container Registry not found"
        return $false
    }
}

function Test-Lesson08 {
    Write-Section "⚡ Lesson 08: Serverless Services"
    Write-Host "  Verifying Azure Functions deployment..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'serverless') || contains(name, 'function') || contains(name, 'lesson08') || contains(name, 'lesson-08')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 08"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    
    $funcName = az functionapp list -g $rg --query "[0].name" -o tsv 2>$null
    if ($funcName) {
        $funcUrl = az functionapp show -g $rg -n $funcName --query "defaultHostName" -o tsv 2>$null
        $runtime = az functionapp show -g $rg -n $funcName --query "siteConfig.linuxFxVersion" -o tsv 2>$null
        Write-Success "Function App: $funcName"
        Write-Detail "URL: https://$funcUrl"
        Write-Detail "Runtime: $runtime"
        
        Write-Host ""
        Write-Success "Lesson 08 validation PASSED"
        return $true
    } else {
        Write-Error2 "Function App not found"
        return $false
    }
}

function Test-Lesson09 {
    Write-Section "🗄️ Lesson 09: Database Services"
    Write-Host "  Verifying Cosmos DB deployment..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'database') || contains(name, 'cosmos') || contains(name, 'lesson09') || contains(name, 'lesson-09')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 09"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    
    $cosmosName = az cosmosdb list -g $rg --query "[0].name" -o tsv 2>$null
    if ($cosmosName) {
        $endpoint = az cosmosdb show -g $rg -n $cosmosName --query "documentEndpoint" -o tsv 2>$null
        $consistency = az cosmosdb show -g $rg -n $cosmosName --query "consistencyPolicy.defaultConsistencyLevel" -o tsv 2>$null
        Write-Success "Cosmos DB Account: $cosmosName"
        Write-Detail "Endpoint: $endpoint"
        Write-Detail "Consistency: $consistency"
        
        Write-Host ""
        Write-Success "Lesson 09 validation PASSED"
        return $true
    } else {
        Write-Error2 "Cosmos DB not found"
        return $false
    }
}

function Test-Lesson11 {
    Write-Section "🤖 Lesson 11: AI Foundry"
    Write-Host "  Verifying Azure AI resources..." -ForegroundColor Cyan
    Write-Host ""
    
    $rg = az group list --query "[?contains(name, 'ai-foundry') || contains(name, 'ai') || contains(name, 'lesson11') || contains(name, 'lesson-11')].name" -o tsv 2>$null | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($rg)) {
        Write-Error2 "Resource group not found for Lesson 11"
        return $false
    }
    
    Write-Info "Resource Group: $rg"
    
    $aiCount = az resource list -g $rg --query "length([?contains(type, 'CognitiveServices') || contains(type, 'MachineLearning')])" -o tsv 2>$null
    
    if ([int]$aiCount -gt 0) {
        # List AI resources
        $resources = az resource list -g $rg --query "[?contains(type, 'CognitiveServices') || contains(type, 'MachineLearning')].{name:name, type:type}" -o json 2>$null | ConvertFrom-Json
        
        Write-Success "AI Resources found: $aiCount"
        foreach ($resource in $resources) {
            $shortType = $resource.type -replace "Microsoft\.", ""
            Write-Detail "$($resource.name) ($shortType)"
        }
        
        Write-Host ""
        Write-Success "Lesson 11 validation PASSED"
        return $true
    } else {
        Write-Error2 "AI resources not found"
        return $false
    }
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

Write-Header "Azure Essentials - Deployment Validation"
Write-Host ""
Write-Host "  Environment: $EnvName" -ForegroundColor Cyan
Write-Host ""

# Check Azure CLI login
$account = az account show --query name -o tsv 2>$null
if (-not $account) {
    Write-Error2 "Not logged in to Azure CLI"
    Write-Host "  Run: az login" -ForegroundColor Yellow
    exit 1
}
Write-Info "Azure Account: $account"

# Discover resources
Write-Section "📂 Discovering Resources"

# Check for Management Groups (Lesson 02)
$mgList = @()
foreach ($mg in @("mg-essentials-root", "mg-essentials-production", "mg-essentials-development", "mg-essentials-sandbox")) {
    $result = az account management-group show -n $mg --query name -o tsv 2>$null
    if ($result) {
        $mgList += $mg
    }
}

# Find resource groups
$rgList = @()
$rgList += Find-ResourceGroups -Pattern $EnvName
$rgList += Find-ResourceGroups -Pattern "essentials"
$rgList += Find-ResourceGroups -Pattern "lesson"
$rgList = $rgList | Sort-Object -Unique | Where-Object { $_ -ne "" }

if ($rgList.Count -eq 0 -and $mgList.Count -eq 0) {
    Write-Warning2 "No resources found matching patterns"
    Write-Info "Resource groups: *$EnvName* or *essentials*"
    Write-Info "Management groups: mg-essentials-*"
    Write-Info "Tip: Set environment name with -EnvName parameter or AZURE_ENV_NAME variable"
    exit 1
}

# Show what we found
if ($mgList.Count -gt 0) {
    Write-Host "  Found Management Groups (Lesson 02):" -ForegroundColor White
    foreach ($mg in $mgList) {
        Write-Info $mg
    }
}

if ($rgList.Count -gt 0) {
    Write-Host "  Found Resource Groups:" -ForegroundColor White
    foreach ($rg in $rgList) {
        Write-Info $rg
    }
}

# Run validations
$TotalPassed = 0
$TotalFailed = 0

function Invoke-Validation {
    param([string]$LessonNum)
    
    $result = switch ($LessonNum) {
        "02" { Test-Lesson02 }
        "03" { Test-Lesson03 }
        "04" { Test-Lesson04 }
        "05" { Test-Lesson05 }
        "06" { Test-Lesson06 }
        "07" { Test-Lesson07 }
        "08" { Test-Lesson08 }
        "09" { Test-Lesson09 }
        "11" { Test-Lesson11 }
        default { Write-Warning2 "Unknown lesson: $LessonNum"; $false }
    }
    
    if ($result) {
        $script:TotalPassed++
    } else {
        $script:TotalFailed++
    }
}

if ($Lesson) {
    # Validate specific lesson
    Invoke-Validation -LessonNum $Lesson
} else {
    # Validate based on discovered resources
    if ($mgList.Count -gt 0) {
        Invoke-Validation -LessonNum "02"
    }
    
    $rgString = $rgList -join " "
    
    if ($rgString -match "lesson.?03|storage") {
        Invoke-Validation -LessonNum "03"
    }
    if ($rgString -match "lesson.?04|networking") {
        Invoke-Validation -LessonNum "04"
    }
    if ($rgString -match "lesson.?05|compute|windows") {
        Invoke-Validation -LessonNum "05"
    }
    if ($rgString -match "lesson.?06|linux|k8s|microk8s") {
        Invoke-Validation -LessonNum "06"
    }
    if ($rgString -match "lesson.?07|container") {
        Invoke-Validation -LessonNum "07"
    }
    if ($rgString -match "lesson.?08|serverless|function") {
        Invoke-Validation -LessonNum "08"
    }
    if ($rgString -match "lesson.?09|database|cosmos") {
        Invoke-Validation -LessonNum "09"
    }
    if ($rgString -match "lesson.?11|ai-foundry|ai.foundry") {
        Invoke-Validation -LessonNum "11"
    }
}

# Summary
Write-Header "📊 Validation Summary"
Write-Host ""

if ($TotalFailed -eq 0 -and $TotalPassed -gt 0) {
    Write-Host "  All validations PASSED! ($TotalPassed lessons)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Your Azure Essentials environment is ready for training." -ForegroundColor Cyan
} elseif ($TotalPassed -gt 0) {
    Write-Host "  Partial success: $TotalPassed passed, $TotalFailed failed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Some lessons may need redeployment." -ForegroundColor Yellow
} else {
    Write-Host "  No validations passed." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Check that resources are deployed and accessible." -ForegroundColor Red
}

Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "  Code to Cloud | www.codetocloud.io" -ForegroundColor DarkGray
Write-Host ""
