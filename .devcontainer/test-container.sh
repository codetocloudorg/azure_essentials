#!/bin/bash
# =============================================================================
# Dev Container Test Script
# Code to Cloud Inc. | www.codetocloud.io
# =============================================================================

set -e

echo "=============================================="
echo "DEV CONTAINER FULL TEST"
echo "=============================================="
echo ""

echo "=== 1. CORE TOOLS ==="
echo -n "Azure CLI:           "; az version --query '"azure-cli"' -o tsv 2>/dev/null || echo "MISSING"
echo -n "Bicep:               "; az bicep version 2>/dev/null | head -1 || echo "MISSING"
echo -n "Azure Dev CLI:       "; azd version 2>/dev/null | head -1 || echo "MISSING"
echo -n "Python:              "; python --version 2>&1
echo -n "Node.js:             "; node --version 2>&1
echo -n ".NET SDK:            "; dotnet --version 2>&1
echo -n "kubectl:             "; kubectl version --client -o json 2>/dev/null | jq -r .clientVersion.gitVersion || echo "MISSING"
echo -n "Docker CLI:          "; docker --version 2>&1 || echo "MISSING (expected in container)"
echo -n "Azure Functions:     "; func --version 2>&1 || echo "MISSING"
echo -n "Git:                 "; git --version 2>&1
echo -n "jq:                  "; jq --version 2>&1
echo ""

echo "=== 2. PYTHON PACKAGES (Lesson 08, 09, 11) ==="
python -c "import azure.functions; print('azure-functions:     OK')" 2>/dev/null || echo "azure-functions:     MISSING"
python -c "import azure.cosmos; print('azure-cosmos:        OK')" 2>/dev/null || echo "azure-cosmos:        MISSING"
python -c "import azure.storage.blob; print('azure-storage-blob:  OK')" 2>/dev/null || echo "azure-storage-blob:  MISSING"
python -c "import azure.identity; print('azure-identity:      OK')" 2>/dev/null || echo "azure-identity:      MISSING"
python -c "import openai; print('openai:              OK')" 2>/dev/null || echo "openai:              MISSING"
python -c "import flask; print('flask:               OK')" 2>/dev/null || echo "flask:               MISSING"
python -c "import requests; print('requests:            OK')" 2>/dev/null || echo "requests:            MISSING"
echo ""

echo "=== 3. DOTNET CHECK (Lesson 05) ==="
if [ -d "/workspaces/azure_essentials/lessons/05-compute-windows/src/cloud-quote-api" ]; then
    cd /workspaces/azure_essentials/lessons/05-compute-windows/src/cloud-quote-api
    dotnet restore --verbosity quiet 2>/dev/null && echo ".NET restore:        OK" || echo ".NET restore:        FAILED"
    cd /workspaces/azure_essentials
else
    echo ".NET project:        NOT MOUNTED"
fi
echo ""

echo "=== 4. NODE.JS CHECK (Lesson 07) ==="
node -e "console.log('Node.js exec:        OK')"
echo ""

echo "=== 5. SCRIPTS EXECUTABLE CHECK ==="
if [ -d "/workspaces/azure_essentials/scripts" ]; then
    test -x /workspaces/azure_essentials/scripts/bash/deploy.sh && echo "deploy.sh:           OK" || echo "deploy.sh:           NOT executable"
    test -x /workspaces/azure_essentials/scripts/bash/validate-env.sh && echo "validate-env.sh:     OK" || echo "validate-env.sh:     NOT executable"
else
    echo "Scripts:             NOT MOUNTED"
fi
echo ""

echo "=== 6. LESSON SAMPLE CODE CHECK ==="
if [ -d "/workspaces/azure_essentials/lessons" ]; then
    test -f /workspaces/azure_essentials/lessons/05-compute-windows/src/cloud-quote-api/Program.cs && echo "Lesson 05 .NET:      OK" || echo "Lesson 05 .NET:      MISSING"
    test -f /workspaces/azure_essentials/lessons/07-container-services/src/cloud-dashboard/Dockerfile && echo "Lesson 07 Docker:    OK" || echo "Lesson 07 Docker:    MISSING"
    test -f /workspaces/azure_essentials/lessons/08-serverless/src/sample-function/requirements.txt && echo "Lesson 08 Functions: OK" || echo "Lesson 08 Functions: MISSING"
    test -f /workspaces/azure_essentials/lessons/09-database-services/src/cosmos-test-app/app.py && echo "Lesson 09 Cosmos:    OK" || echo "Lesson 09 Cosmos:    MISSING"
    test -f /workspaces/azure_essentials/lessons/11-ai-foundry/src/simple-chatbot/chatbot.py && echo "Lesson 11 AI:        OK" || echo "Lesson 11 AI:        MISSING"
else
    echo "Lessons:             NOT MOUNTED"
fi
echo ""

echo "=== 7. INFRASTRUCTURE FILES ==="
if [ -d "/workspaces/azure_essentials/infra" ]; then
    test -f /workspaces/azure_essentials/infra/main.bicep && echo "main.bicep:          OK" || echo "main.bicep:          MISSING"
    test -f /workspaces/azure_essentials/azure.yaml && echo "azure.yaml:          OK" || echo "azure.yaml:          MISSING"
else
    echo "Infra:               NOT MOUNTED"
fi
echo ""

echo "=============================================="
echo "TEST COMPLETE"
echo "=============================================="
