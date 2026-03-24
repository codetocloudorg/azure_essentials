# Lesson 11: Azure AI Foundry

> **Time:** 45 minutes | **Difficulty:** Medium | **Cost:** ~$0-5 (pay per API call)

## 🎯 What You'll Build

By the end of this lesson, you'll have:

- Created an Azure AI Services (Foundry) resource
- Made your first AI API call
- Built a simple chatbot using Azure OpenAI
- Understood Azure's AI service offerings

---

## 🤖 Azure AI Services Overview

Azure AI Foundry provides a unified platform for AI:

| Category     | Services                       | Use Cases                        |
| ------------ | ------------------------------ | -------------------------------- |
| **Language** | OpenAI GPT-4o, Translator      | Chatbots, translation, reasoning |
| **Vision**   | Computer Vision, GPT-4o Vision | Image analysis, OCR, detection   |
| **Speech**   | Whisper, Text-to-Speech        | Voice assistants, transcription  |
| **Decision** | Content Safety                 | Content moderation, safety       |
| **Search**   | Azure AI Search                | Enterprise search, RAG           |

---

## 🚀 Azure AI Foundry

The unified platform for building AI applications—access to GPT-4o, Phi-4, DALL-E, and more!

### What You Can Build

| Model                | Capability           | Example                     |
| -------------------- | -------------------- | --------------------------- |
| **GPT-4o**           | Multimodal reasoning | Chatbots, document analysis |
| **GPT-4.1-mini**      | Fast, efficient      | Quick responses, summaries  |
| **Phi-4**            | Small language model | Edge scenarios, low latency |
| **DALL-E 3**         | Image generation     | Create images from text     |
| **Whisper**          | Speech-to-text       | Transcription               |
| **text-embedding-3** | Vector embeddings    | Semantic search, RAG        |

---

## 🏗️ Set Up Azure AI Foundry

### Option 1: Azure CLI (Recommended)

```bash
# Variables
RG_NAME="rg-ai-lesson"
LOCATION="northcentralus"  # Recommended for hosted agents
AI_NAME="ai-foundry-demo-$(openssl rand -hex 4)"

# Register the provider (first time only)
az provider register --namespace Microsoft.CognitiveServices

# Create resource group
az group create --name $RG_NAME --location $LOCATION

# Create Azure AI Services (Foundry resource)
az cognitiveservices account create \
  --resource-group $RG_NAME \
  --name $AI_NAME \
  --kind AIServices \
  --sku S0 \
  --location $LOCATION \
  --custom-domain $AI_NAME \
  --yes
```

### Option 2: Azure Developer CLI (azd)

For a complete Foundry project with hosted agents:

```bash
mkdir my-foundry-project && cd my-foundry-project
azd init -t https://github.com/Azure-Samples/azd-ai-starter-basic -e my-foundry-project --no-prompt
azd env set ENABLE_HOSTED_AGENTS true  # Optional
azd provision --no-prompt
```

### Deploy a Model

```bash
# List available models
az cognitiveservices model list --location $LOCATION -o table

# Deploy GPT-4.1-mini
az cognitiveservices account deployment create \
  --resource-group $RG_NAME \
  --name $AI_NAME \
  --deployment-name gpt-4.1-mini \
  --model-name gpt-4.1-mini \
  --model-version "2025-04-14" \
  --model-format OpenAI \
  --sku-capacity 10 \
  --sku-name Standard
```

### Get Your Keys

```bash
# Get endpoint
ENDPOINT=$(az cognitiveservices account show \
  --resource-group $RG_NAME \
  --name $AI_NAME \
  --query properties.endpoint -o tsv)

# Get key
KEY=$(az cognitiveservices account keys list \
  --resource-group $RG_NAME \
  --name $AI_NAME \
  --query key1 -o tsv)

echo "Endpoint: $ENDPOINT"
echo "Key: $KEY"
```

---

## 💬 Make Your First API Call

### Using Python

```python
import os
from openai import AzureOpenAI

# Configuration
client = AzureOpenAI(
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_KEY"),
    api_version="2024-10-21"
)

# Make a completion request
response = client.chat.completions.create(
    model="gpt-4.1-mini",  # This is your deployment name
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What is Azure in one sentence?"}
    ],
    max_tokens=100
)

print(response.choices[0].message.content)
```

**Output:**

```
Azure is Microsoft's cloud computing platform that provides a wide range of
services for building, deploying, and managing applications and services.
```

Install SDK: `pip install openai`

### Using curl

```bash
curl "$ENDPOINT/openai/deployments/gpt-4.1-mini/chat/completions?api-version=2024-10-21" \
  -H "Content-Type: application/json" \
  -H "api-key: $KEY" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "What is Azure?"}
    ],
    "max_tokens": 100
  }'
```

---

## 🤖 Build a Simple Chatbot

Create `chatbot.py`:

```python
import os
from openai import AzureOpenAI

client = AzureOpenAI(
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_KEY"),
    api_version="2024-10-21"
)

# Conversation history
messages = [
    {"role": "system", "content": "You are a helpful Azure expert assistant."}
]

print("Azure Chatbot (type 'quit' to exit)")
print("-" * 40)

while True:
    user_input = input("\nYou: ").strip()

    if user_input.lower() == 'quit':
        break

    # Add user message to history
    messages.append({"role": "user", "content": user_input})

    # Get response
    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=messages,
        max_tokens=500
    )

    assistant_message = response.choices[0].message.content

    # Add assistant response to history
    messages.append({"role": "assistant", "content": assistant_message})

    print(f"\nBot: {assistant_message}")
```

Run it:

```bash
export AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com/"
export AZURE_OPENAI_KEY="your-key-here"
python chatbot.py
```

---

## 🔍 Other AI Services

### Azure AI Language

For text analysis without OpenAI:

```python
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential

client = TextAnalyticsClient(
    endpoint=endpoint,
    credential=AzureKeyCredential(key)
)

# Sentiment analysis
documents = ["I love Azure! It's amazing.", "This is frustrating."]
response = client.analyze_sentiment(documents)

for doc in response:
    print(f"Sentiment: {doc.sentiment}")
```

### Azure Computer Vision

For image analysis:

```python
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials

client = ComputerVisionClient(
    endpoint,
    CognitiveServicesCredentials(key)
)

# Analyze image
image_url = "https://example.com/image.jpg"
analysis = client.analyze_image(image_url, visual_features=["Categories", "Description", "Tags"])

print(f"Description: {analysis.description.captions[0].text}")
```

---

## 💰 Pricing Overview

Azure AI services charge per API call:

| Service                    | Pricing (approx)         |
| -------------------------- | ------------------------ |
| **GPT-4o**                 | $0.005/1K input tokens   |
| **GPT-4.1-mini**            | $0.00015/1K input tokens |
| **Phi-4**                  | $0.00007/1K input tokens |
| **DALL-E 3**               | $0.04/image              |
| **Whisper**                | $0.006/minute            |
| **text-embedding-3-large** | $0.00013/1K tokens       |

### What's a Token?

- ~4 characters = 1 token
- "Hello world" ≈ 2 tokens
- Average sentence ≈ 20 tokens

---

## 🛡️ Responsible AI

Azure AI includes safety features:

| Feature              | Purpose               |
| -------------------- | --------------------- |
| **Content filters**  | Block harmful content |
| **Abuse monitoring** | Detect misuse         |
| **Rate limiting**    | Prevent overload      |
| **Audit logging**    | Track usage           |

### Enable Content Filtering

In the portal:

1. Go to your Azure AI Services resource
2. Click **"Content filters"**
3. Configure severity thresholds for:
   - Hate speech
   - Sexual content
   - Violence
   - Self-harm

---

## 🧪 Try It: Azure AI Foundry Portal

No code needed!

1. Go to [ai.azure.com](https://ai.azure.com)
2. Select your resource and deployment
3. Use the **Playground**
4. Experiment with different prompts

### System Prompt Tips

```
You are a helpful assistant that specializes in Azure cloud services.
- Keep answers concise and technical
- Provide code examples when relevant
- If unsure, say "I don't know"
```

---

## 🧹 Clean Up

```bash
az group delete --name $RG_NAME --yes

# Purge soft-deleted AI Services (optional)
az cognitiveservices account purge --name $AI_NAME --location $LOCATION
```

---

## ⚠️ Common Issues

| Issue                   | Fix                                                                |
| ----------------------- | ------------------------------------------------------------------ |
| Provider not registered | Run `az provider register --namespace Microsoft.CognitiveServices` |
| Model not available     | Try different region (northcentralus recommended)                  |
| Rate limited            | Wait or request quota increase                                     |
| Content filtered        | Adjust content filter settings                                     |
| Soft-deleted resource   | Purge with `az cognitiveservices account purge`                    |

---

## ✅ What You Learned

- 🤖 What Azure AI Foundry services are available
- 🚀 How to create Azure AI Services (Foundry resource)
- 💬 How to make API calls with Python
- 🤖 How to build a simple chatbot
- 🛡️ Responsible AI considerations

---

## ➡️ Next Steps

Let's put it all together with architecture design!

👉 **[Lesson 12: Architecture & Design](Lesson-12-Architecture-Design)**

---

_Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!_
