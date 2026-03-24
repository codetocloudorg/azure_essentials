# Lesson 11: Azure AI Foundry

> **Duration**: 45 minutes | **Day**: 2

## Learning Objectives

In this lesson, you'll work with **Azure AI Foundry**, the platform for building AI applications. By the end, you'll be able to:

- Create an AI Foundry project in the Portal
- Deploy a language model (GPT-4.1-mini)
- Test the model in the Playground
- Build a simple chatbot with Python

## Why Azure AI Foundry?

| Challenge              | How Foundry Solves It                              |
| ---------------------- | -------------------------------------------------- |
| Need AI capabilities   | Access to GPT-4o, Phi-4, embeddings, vision models |
| Prompt experimentation | Built-in Playground to test without code           |
| Model management       | Deploy, monitor, and scale models from one place   |
| Enterprise ready       | Built-in security, compliance, and monitoring      |

**Real-world example**: Customer support chatbots, document analysis, content generation, code assistants.

---

## Quick Start

```
┌─────────────────────────────────────────────────────────────────┐
│                    Lesson 11 Workflow                           │
├─────────────────────────────────────────────────────────────────┤
│  1. PORTAL: Create AI Foundry project (5 min)                   │
│  2. PORTAL: Deploy GPT-4.1-mini model (3 min)                    │
│  3. PORTAL: Test in Playground (5 min)                          │
│  4. CLOUD SHELL: Run Python chatbot (10 min)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- Azure subscription with access to Azure OpenAI
- Azure Portal access

---

## Part 1: Create AI Foundry Project (Portal)

### Step 1: Open Azure AI Foundry

1. Go to [Azure AI Foundry](https://ai.azure.com)
2. Sign in with your Azure account
3. Click **+ Create project**

### Step 2: Create the Project

1. Fill in:
   | Setting | Value |
   |---------|-------|
   | Project name | `azure-essentials` |
   | Subscription | Your subscription |
   | Resource group | `rg-azure-essentials-dev` (create new if needed) |
   | Location | **North Central US** (recommended) or **East US 2** |

2. Click **Create**
3. Wait for deployment (~2 minutes)

> **Note**: The project automatically creates the underlying AI Services resource.

---

## Part 2: Deploy a Model

### Step 1: Open Model Catalog

1. In your **azure-essentials** project, click **Model catalog** in the left menu
2. Search for **gpt-4.1-mini**
3. Click on the model card

### Step 2: Deploy the Model

1. Click **Deploy**
2. Configure:
   | Setting | Value |
   |---------|-------|
   | Deployment name | `gpt-4.1-mini` |
   | Deployment type | **Serverless API** |

3. Click **Deploy**
4. Wait for deployment (~1 minute)

### Step 3: Note Your Credentials

After deployment, note these values (you'll need them later):

- **Endpoint URL**: `https://your-project.openai.azure.com/`
- **API Key**: Click "Show key" to reveal

---

## Part 3: Test in Playground

### Step 1: Open Chat Playground

1. In your project, click **Playgrounds** → **Chat**
2. Select your **gpt-4.1-mini** deployment

### Step 2: Set System Prompt

In the **System message** box, paste:

```
You are a helpful Azure learning assistant.
Your role is to:
- Answer questions about Microsoft Azure services
- Explain cloud computing concepts in simple terms
- Be concise but thorough

If you don't know something, say so honestly.
```

Click **Apply changes**.

### Step 3: Test the Model

Try these prompts:

| Prompt                                   | What You'll Learn     |
| ---------------------------------------- | --------------------- |
| "What is Azure Cosmos DB?"               | Factual response      |
| "Explain serverless in one sentence"     | Concise explanation   |
| "Compare Azure Functions vs App Service" | Comparison capability |

### Step 4: Experiment with Parameters

Click **Parameters** and try:

| Parameter       | Low Value | High Value | Effect                 |
| --------------- | --------- | ---------- | ---------------------- |
| **Temperature** | 0.2       | 1.2        | Focused → Creative     |
| **Max tokens**  | 100       | 1000       | Short → Long responses |

---

## Part 4: Build a Chatbot (Cloud Shell)

### Step 1: Open Cloud Shell

1. In Azure Portal, click the **Cloud Shell** icon (`>_` top right)
2. Select **Bash**

### Step 2: Get Your Credentials

```bash
# Auto-discover your AI Services account
AI_ACCOUNT=$(az cognitiveservices account list --query "[?kind=='AIServices'].name | [0]" -o tsv)
RG=$(az cognitiveservices account list --query "[?kind=='AIServices'].resourceGroup | [0]" -o tsv)

echo "Found: $AI_ACCOUNT in $RG"

# Get endpoint and key
export AZURE_AI_ENDPOINT=$(az cognitiveservices account show --name $AI_ACCOUNT --resource-group $RG --query properties.endpoint -o tsv)
export AZURE_AI_KEY=$(az cognitiveservices account keys list --name $AI_ACCOUNT --resource-group $RG --query key1 -o tsv)
export AZURE_AI_DEPLOYMENT="gpt-4.1-mini"

echo "Endpoint: $AZURE_AI_ENDPOINT"
```

### Step 3: Run the Chatbot

```bash
# Clone repo
git clone https://github.com/codetocloudorg/azure_essentials.git 2>/dev/null || true
cd azure_essentials/lessons/11-ai-foundry/src/simple-chatbot

# Install and run
pip install --user -r requirements.txt
python chatbot.py
```

**Expected Output:**

```
============================================================
Azure Learning Assistant
Type 'quit' to exit, 'clear' to reset conversation
============================================================

You: What is Azure?
Assistant: Azure is Microsoft's cloud computing platform...
```

---

## Understanding the Code

The Python chatbot demonstrates:

| Component                   | What It Does                      |
| --------------------------- | --------------------------------- |
| `AzureOpenAI` client        | Connects to your Foundry endpoint |
| System prompt               | Defines the assistant's behavior  |
| Message history             | Maintains conversation context    |
| `chat.completions.create()` | Sends messages and gets responses |

### Key Code Pattern

```python
from openai import AzureOpenAI

# Connect to Azure AI Foundry
client = AzureOpenAI(
    azure_endpoint=ENDPOINT,
    api_key=API_KEY,
    api_version="2024-10-21"
)

# Send a message
response = client.chat.completions.create(
    model="gpt-4.1-mini",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"}
    ],
    temperature=0.7
)

print(response.choices[0].message.content)
```

---

## Key Concepts

### Model Parameters

| Parameter       | What It Does               | When to Use                                     |
| --------------- | -------------------------- | ----------------------------------------------- |
| **Temperature** | Controls randomness        | Low (0.2) for facts, High (1.0+) for creativity |
| **Max tokens**  | Limits response length     | Set based on use case                           |
| **Top P**       | Alternative to temperature | Usually leave at 0.95                           |

### Prompt Engineering Tips

| Technique           | Example                              |
| ------------------- | ------------------------------------ |
| **Be specific**     | "List 3 benefits of Azure Functions" |
| **Provide context** | "For a beginner developer..."        |
| **Set format**      | "Respond in bullet points"           |
| **Define persona**  | "You are an Azure architect"         |

---

## Troubleshooting

### "Resource not found"

Verify your AI Services account exists:

```bash
az cognitiveservices account list -o table
```

### "Model deployment not found"

Check your deployments in the Portal:

1. Go to [ai.azure.com](https://ai.azure.com)
2. Open your **azure-essentials** project
3. Click **Deployments** - verify `gpt-4.1-mini` exists

### "Invalid API key"

Regenerate the key in the Portal or via CLI:

```bash
az cognitiveservices account keys regenerate --name $AI_ACCOUNT --resource-group $RG --key-name key1
```

---

## Cleanup

Delete the AI Foundry resources when done:

```bash
# Delete the resource group
az group delete --name rg-azure-essentials-dev --yes --no-wait

# Note: AI Services are soft-deleted for 48 hours
# To purge immediately:
az cognitiveservices account purge --name $AI_ACCOUNT --location northcentralus
```

---

## Summary

| Task                                          | Completed |
| --------------------------------------------- | --------- |
| Created AI Foundry project (azure-essentials) | ✅        |
| Deployed GPT-4.1-mini model                    | ✅        |
| Tested in Playground                          | ✅        |
| Built Python chatbot                          | ✅        |

---

## Next Steps

Continue to [Lesson 12: Architecture Design](../12-architecture-design/README.md)

---

## Additional Resources

- [Azure AI Foundry](https://ai.azure.com)
- [Azure OpenAI Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [Prompt Engineering Guide](https://learn.microsoft.com/azure/ai-services/openai/concepts/prompt-engineering)
