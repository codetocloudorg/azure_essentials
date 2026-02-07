# Lesson 11: Azure AI Foundry

> **Time:** 45 minutes | **Difficulty:** Medium | **Cost:** ~$0-5 (pay per API call)

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created an Azure AI resource
- Made your first AI API call
- Built a simple chatbot using Azure OpenAI
- Understood Azure's AI service offerings

---

## 🤖 Azure AI Services Overview

Azure offers many AI services:

| Category | Services | Use Cases |
|----------|----------|-----------|
| **Language** | OpenAI, Translator, Text Analytics | Chatbots, translation, sentiment |
| **Vision** | Computer Vision, Custom Vision, Face | Image analysis, OCR, detection |
| **Speech** | Speech-to-Text, Text-to-Speech | Voice assistants, transcription |
| **Decision** | Content Moderator, Personalizer | Content safety, recommendations |
| **Search** | Azure AI Search | Enterprise search, RAG |

---

## 🚀 Azure OpenAI Service

The most popular AI service—access to GPT-4, DALL-E, and more!

### What You Can Build

| Model | Capability | Example |
|-------|------------|---------|
| **GPT-4** | Text generation | Chatbots, writing assistants |
| **GPT-3.5** | Fast text generation | Quick responses, summaries |
| **DALL-E** | Image generation | Create images from text |
| **Whisper** | Speech-to-text | Transcription |
| **Embeddings** | Vector representations | Semantic search |

---

## 🏗️ Set Up Azure OpenAI

### Step 1: Request Access

Azure OpenAI requires approval:
1. Go to [aka.ms/oai/access](https://aka.ms/oai/access)
2. Fill out the form
3. Wait for email approval (usually 1-2 days)

### Step 2: Create Resource

```bash
# Variables
RG_NAME="rg-ai-lesson"
LOCATION="eastus"  # Note: Not all regions support OpenAI
AI_NAME="openai-demo-$RANDOM"

# Create resource group
az group create --name $RG_NAME --location $LOCATION

# Create OpenAI resource
az cognitiveservices account create \
  --resource-group $RG_NAME \
  --name $AI_NAME \
  --kind OpenAI \
  --sku S0 \
  --location $LOCATION
```

### Step 3: Deploy a Model

```bash
# Deploy GPT-3.5-turbo
az cognitiveservices account deployment create \
  --resource-group $RG_NAME \
  --name $AI_NAME \
  --deployment-name gpt-35-turbo \
  --model-name gpt-35-turbo \
  --model-version "0613" \
  --model-format OpenAI \
  --sku-capacity 10 \
  --sku-name Standard
```

### Step 4: Get Your Keys

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
    api_version="2024-02-01"
)

# Make a completion request
response = client.chat.completions.create(
    model="gpt-35-turbo",  # This is your deployment name
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
curl "$ENDPOINT/openai/deployments/gpt-35-turbo/chat/completions?api-version=2024-02-01" \
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
    api_version="2024-02-01"
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
        model="gpt-35-turbo",
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

| Service | Pricing (approx) |
|---------|------------------|
| **GPT-4** | $0.03/1K input tokens |
| **GPT-3.5-turbo** | $0.002/1K tokens |
| **DALL-E 3** | $0.04/image |
| **Whisper** | $0.006/minute |
| **Text Analytics** | $0.25/1K records |

### What's a Token?

- ~4 characters = 1 token
- "Hello world" ≈ 2 tokens
- Average sentence ≈ 20 tokens

---

## 🛡️ Responsible AI

Azure AI includes safety features:

| Feature | Purpose |
|---------|---------|
| **Content filters** | Block harmful content |
| **Abuse monitoring** | Detect misuse |
| **Rate limiting** | Prevent overload |
| **Audit logging** | Track usage |

### Enable Content Filtering

In the portal:
1. Go to your Azure OpenAI resource
2. Click **"Content filters"**
3. Configure severity thresholds for:
   - Hate speech
   - Sexual content
   - Violence
   - Self-harm

---

## 🧪 Try It: Azure AI Playground

No code needed!

1. Go to [oai.azure.com](https://oai.azure.com)
2. Select your resource and deployment
3. Use the **Chat** playground
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
```

---

## ⚠️ Common Issues

| Issue | Fix |
|-------|-----|
| Access denied | Apply at aka.ms/oai/access |
| Model not available | Try different region (eastus recommended) |
| Rate limited | Wait or increase quota |
| Content filtered | Adjust content filter settings |

---

## ✅ What You Learned

- 🤖 What Azure AI services are available
- 🚀 How to set up Azure OpenAI
- 💬 How to make API calls with Python
- 🤖 How to build a simple chatbot
- 🛡️ Responsible AI considerations

---

## ➡️ Next Steps

Let's put it all together with architecture design!

👉 **[Lesson 12: Architecture & Design](Lesson-12-Architecture-Design)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
