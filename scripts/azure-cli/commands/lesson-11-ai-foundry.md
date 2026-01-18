# Lesson 11: Azure AI Foundry - Copy-Paste Commands

> AI Hub, model catalog (OpenAI, Phi, embeddings), and prompt flow
>
> ⚠️ **Azure OpenAI requires approval** - You must request access at https://aka.ms/oai/access

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="eastus"  # Azure OpenAI has limited region availability
RESOURCE_GROUP="rg-essentials-ai"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
COGNITIVE_ACCOUNT="cog-essentials-${UNIQUE_SUFFIX}"

# Display the account name (save this!)
echo "Cognitive Services Account: $COGNITIVE_ACCOUNT"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=11-ai"
```

---

## Step 2: Create Azure OpenAI Resource

```bash
# Create Azure OpenAI account
az cognitiveservices account create \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --kind OpenAI \
    --sku S0 \
    --custom-domain "$COGNITIVE_ACCOUNT"
```

---

## Step 3: Get API Keys and Endpoint

```bash
# Get the endpoint
az cognitiveservices account show \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query properties.endpoint \
    -o tsv
```

```bash
# Get the API key
az cognitiveservices account keys list \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query key1 \
    -o tsv
```

```bash
# Store for later use
OPENAI_ENDPOINT=$(az cognitiveservices account show \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query properties.endpoint \
    -o tsv)

OPENAI_KEY=$(az cognitiveservices account keys list \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query key1 \
    -o tsv)

echo "Endpoint: $OPENAI_ENDPOINT"
```

---

## Step 4: Deploy a GPT Model

```bash
# Deploy GPT-4o-mini model
az cognitiveservices account deployment create \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --deployment-name "gpt-4o-mini" \
    --model-name "gpt-4o-mini" \
    --model-version "2024-07-18" \
    --model-format OpenAI \
    --sku-capacity 10 \
    --sku-name Standard
```

---

## Step 5: List Deployed Models

```bash
# List all deployments
az cognitiveservices account deployment list \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, Model:properties.model.name, Version:properties.model.version}" \
    -o table
```

---

## Step 6: Test the Model with Python

```bash
# Install the OpenAI SDK
pip install openai --quiet

# Test the model
python3 << 'EOF'
import os
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key=os.environ.get("OPENAI_KEY"),
    api_version="2024-02-15-preview",
    azure_endpoint=os.environ.get("OPENAI_ENDPOINT")
)

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "system", "content": "You are a helpful Azure expert."},
        {"role": "user", "content": "What are the main benefits of Azure?"}
    ],
    max_tokens=200
)

print("Response from Azure OpenAI:")
print("-" * 40)
print(response.choices[0].message.content)
EOF
```

---

## Step 7: Test with cURL

```bash
# Test using cURL
curl "${OPENAI_ENDPOINT}openai/deployments/gpt-4o-mini/chat/completions?api-version=2024-02-15-preview" \
    -H "Content-Type: application/json" \
    -H "api-key: ${OPENAI_KEY}" \
    -d '{
        "messages": [
            {"role": "user", "content": "What is Azure in one sentence?"}
        ],
        "max_tokens": 100
    }'
```

---

## Alternative: Use Cognitive Services (No OpenAI Access Required)

If you don't have Azure OpenAI access, you can use general Cognitive Services:

### Create a Text Analytics Resource

```bash
# Create Text Analytics resource
az cognitiveservices account create \
    --name "cog-text-${UNIQUE_SUFFIX}" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --kind TextAnalytics \
    --sku F0
```

### Get Text Analytics Credentials

```bash
TEXT_ENDPOINT=$(az cognitiveservices account show \
    --name "cog-text-${UNIQUE_SUFFIX}" \
    --resource-group "$RESOURCE_GROUP" \
    --query properties.endpoint \
    -o tsv)

TEXT_KEY=$(az cognitiveservices account keys list \
    --name "cog-text-${UNIQUE_SUFFIX}" \
    --resource-group "$RESOURCE_GROUP" \
    --query key1 \
    -o tsv)
```

### Test Sentiment Analysis

```bash
curl "${TEXT_ENDPOINT}text/analytics/v3.1/sentiment" \
    -H "Content-Type: application/json" \
    -H "Ocp-Apim-Subscription-Key: ${TEXT_KEY}" \
    -d '{
        "documents": [
            {"id": "1", "language": "en", "text": "Azure is amazing for cloud computing!"},
            {"id": "2", "language": "en", "text": "The deployment failed and caused issues."}
        ]
    }'
```

---

## 📊 View AI Resources

```bash
# Show account details
az cognitiveservices account show \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, Kind:kind, SKU:sku.name, Endpoint:properties.endpoint}" \
    -o table
```

```bash
# List all Cognitive Services accounts
az cognitiveservices account list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, Kind:kind, Location:location}" \
    -o table
```

---

## 📚 Additional Commands

### Regenerate API Keys

```bash
az cognitiveservices account keys regenerate \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --key-name key1
```

### Delete a Model Deployment

```bash
az cognitiveservices account deployment delete \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --deployment-name "gpt-4o-mini"
```

### List Available Models

```bash
az cognitiveservices account list-models \
    --name "$COGNITIVE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    -o table
```

---

## 🧹 Cleanup

```bash
# Delete the entire resource group
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo "Cleanup initiated - resources deleting in background"
```

---

## 🔗 Quick Reference

| Command | Description |
|---------|-------------|
| `az cognitiveservices account create` | Create AI resource |
| `az cognitiveservices account deployment create` | Deploy a model |
| `az cognitiveservices account deployment list` | List deployments |
| `az cognitiveservices account keys list` | Get API keys |
| `az cognitiveservices account list-models` | List available models |

---

## 🏗️ Azure OpenAI Models

| Model | Use Case | Input | Output |
|-------|----------|-------|--------|
| gpt-4o | General purpose | Text | Text |
| gpt-4o-mini | Cost-effective | Text | Text |
| text-embedding-3-large | Embeddings | Text | Vector |
| dall-e-3 | Image generation | Text | Image |
| whisper | Transcription | Audio | Text |

---

## 🔒 Responsible AI

Azure OpenAI includes built-in content filtering for:
- Hate speech
- Violence
- Sexual content
- Self-harm

Configure content filters in the Azure Portal or via API.
