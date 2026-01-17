# Lesson 11: Azure AI Foundry

> **Duration**: 45 minutes | **Day**: 2

## Overview

Azure AI Foundry provides a unified platform for building intelligent applications. This lesson covers AI workspaces, the model catalog, and building a simple chatbot.

## Learning Objectives

By the end of this lesson, you will be able to:

- Navigate Azure AI Foundry and its components
- Explore the model catalog and deployment options
- Understand prompt engineering fundamentals
- Build and test a simple chatbot
- Configure AI model parameters for different use cases

---

## Key Concepts

### Azure AI Foundry Components

| Component | Description |
|-----------|-------------|
| **AI Hub** | Central resource for AI projects and shared resources |
| **AI Project** | Workspace for building AI applications |
| **Model Catalog** | Library of pre-trained models to deploy |
| **Prompt Flow** | Visual tool for orchestrating AI workflows |
| **Deployments** | Hosted model endpoints for inference |

### Model Categories

| Category | Models | Use Cases |
|----------|--------|-----------|
| **OpenAI** | GPT-4, GPT-4o, GPT-3.5 | Chat, text generation, reasoning |
| **Microsoft** | Phi-3, Phi-4 | Efficient small language models |
| **Embedding** | text-embedding-ada-002 | Semantic search, RAG |
| **Image** | DALL-E 3 | Image generation |
| **Speech** | Whisper | Speech-to-text |

### Key Parameters

| Parameter | Description | Range |
|-----------|-------------|-------|
| **Temperature** | Randomness in responses | 0.0 (focused) to 2.0 (creative) |
| **Max Tokens** | Maximum response length | 1 to model max |
| **Top P** | Nucleus sampling threshold | 0.0 to 1.0 |
| **Frequency Penalty** | Reduces repetition | 0.0 to 2.0 |
| **Presence Penalty** | Encourages new topics | 0.0 to 2.0 |

---

## Hands-on Exercises

### Exercise 11.1: Create an AI Hub and Project

**Objective**: Set up the Azure AI Foundry environment.

#### Using Azure Portal (Recommended)

1. Navigate to [Azure AI Foundry](https://ai.azure.com)
2. Select **Create a project**
3. Configure:
   - **Hub name**: `aihub-azure-essentials`
   - **Project name**: `ai-chatbot-project`
   - **Subscription**: Your subscription
   - **Resource group**: `rg-azure-essentials-dev`
   - **Region**: Select a region with AI model availability
4. Select **Create**

#### Using Azure CLI

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="uksouth"
HUB_NAME="aihub-essentials-$(openssl rand -hex 4)"

# Create the AI Hub (requires supporting resources)
# This creates Storage, Key Vault, and Application Insights automatically
az ml workspace create \
  --name $HUB_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --kind hub

# Create an AI Project within the hub
az ml workspace create \
  --name "${HUB_NAME}-project" \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --kind project \
  --hub-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.MachineLearningServices/workspaces/$HUB_NAME"
```

### Exercise 11.2: Explore the Model Catalog

**Objective**: Browse available models and understand deployment options.

1. Open your AI project in Azure AI Foundry
2. Navigate to **Model catalog**
3. Explore different model categories:
   - Filter by **Task** (Chat, Embeddings, Image)
   - Filter by **Provider** (OpenAI, Microsoft, Meta)
   - Filter by **Deployment type** (Serverless, Managed compute)
4. Select a model (e.g., `gpt-4o-mini`) to view:
   - Model card with capabilities
   - Pricing information
   - Deployment options
   - Sample code

### Exercise 11.3: Deploy a Model

**Objective**: Deploy a language model for chat.

1. In the Model catalog, select **gpt-4o-mini** (or available model)
2. Select **Deploy**
3. Configure deployment:
   - **Deployment name**: `gpt-4o-mini-deployment`
   - **Deployment type**: Serverless API
4. Note the **Endpoint** and **API Key** after deployment

### Exercise 11.4: Build a Simple Chatbot

**Objective**: Create a Python chatbot using the deployed model.

```bash
mkdir -p simple-chatbot && cd simple-chatbot

cat > chatbot.py << 'EOF'
"""
Simple Chatbot using Azure AI Foundry
Azure Essentials - Lesson 11
"""
import os
from openai import AzureOpenAI

# Configuration from environment variables
ENDPOINT = os.environ.get("AZURE_AI_ENDPOINT")
API_KEY = os.environ.get("AZURE_AI_KEY")
DEPLOYMENT = os.environ.get("AZURE_AI_DEPLOYMENT", "gpt-4o-mini-deployment")

# System prompt defines the chatbot's personality and behavior
SYSTEM_PROMPT = """You are a helpful Azure learning assistant. 
Your role is to:
- Answer questions about Microsoft Azure services
- Explain cloud computing concepts in simple terms
- Provide practical examples and best practices
- Be concise but thorough in your responses

If you don't know something, say so honestly."""

def create_client():
    """Create the Azure OpenAI client."""
    return AzureOpenAI(
        azure_endpoint=ENDPOINT,
        api_key=API_KEY,
        api_version="2024-02-15-preview"
    )

def chat(client, messages: list, user_input: str) -> str:
    """Send a message and get a response."""
    # Add user message to history
    messages.append({
        "role": "user",
        "content": user_input
    })
    
    # Get response from the model
    response = client.chat.completions.create(
        model=DEPLOYMENT,
        messages=messages,
        temperature=0.7,
        max_tokens=500,
        top_p=0.95
    )
    
    # Extract and store assistant response
    assistant_message = response.choices[0].message.content
    messages.append({
        "role": "assistant",
        "content": assistant_message
    })
    
    return assistant_message

def main():
    """Run the chatbot."""
    print("=" * 60)
    print("Azure Learning Assistant")
    print("Type 'quit' to exit, 'clear' to reset conversation")
    print("=" * 60)
    
    client = create_client()
    
    # Initialize conversation with system prompt
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT}
    ]
    
    while True:
        try:
            # Get user input
            user_input = input("\nYou: ").strip()
            
            if not user_input:
                continue
            
            if user_input.lower() == 'quit':
                print("Goodbye!")
                break
            
            if user_input.lower() == 'clear':
                messages = [{"role": "system", "content": SYSTEM_PROMPT}]
                print("Conversation cleared.")
                continue
            
            # Get and display response
            response = chat(client, messages, user_input)
            print(f"\nAssistant: {response}")
            
        except KeyboardInterrupt:
            print("\nGoodbye!")
            break
        except Exception as e:
            print(f"\nError: {e}")
            print("Please check your credentials and try again.")

if __name__ == "__main__":
    main()
EOF

cat > requirements.txt << 'EOF'
openai>=1.0.0
EOF

cd ..
```

Run the chatbot:

```bash
# Set environment variables (get these from your deployment)
export AZURE_AI_ENDPOINT="https://your-endpoint.openai.azure.com/"
export AZURE_AI_KEY="your-api-key"
export AZURE_AI_DEPLOYMENT="gpt-4o-mini-deployment"

# Install and run
cd simple-chatbot
pip install -r requirements.txt
python chatbot.py
```

### Exercise 11.5: Experiment with Parameters

**Objective**: Understand how parameters affect model responses.

Try these variations in the chatbot code:

```python
# Creative responses (storytelling, brainstorming)
response = client.chat.completions.create(
    model=DEPLOYMENT,
    messages=messages,
    temperature=1.2,      # Higher = more creative
    max_tokens=1000,
    top_p=0.95
)

# Focused responses (factual, consistent)
response = client.chat.completions.create(
    model=DEPLOYMENT,
    messages=messages,
    temperature=0.2,      # Lower = more focused
    max_tokens=500,
    top_p=0.8
)

# Reduce repetition
response = client.chat.completions.create(
    model=DEPLOYMENT,
    messages=messages,
    temperature=0.7,
    frequency_penalty=0.5,  # Reduce word repetition
    presence_penalty=0.5    # Encourage topic variety
)
```

---

## Prompt Engineering Tips

| Technique | Description | Example |
|-----------|-------------|---------|
| **Be specific** | Clear instructions | "Explain in 3 bullet points" |
| **Provide context** | Background information | "For a beginner developer..." |
| **Use examples** | Few-shot learning | "Format like this example: ..." |
| **Set constraints** | Limit scope | "In 100 words or less" |
| **Define persona** | Role-based prompts | "You are an Azure architect..." |

---

## Key Commands Reference

```bash
# Azure ML CLI (AI Foundry)
az ml workspace create --kind hub
az ml workspace create --kind project --hub-id <hub>
az ml online-endpoint list
az ml online-deployment list

# Model deployment (via Portal or SDK)
# Use Azure AI Foundry portal for model deployments
```

---

## Summary

In this lesson, you learned:

- ✅ Azure AI Foundry components and navigation
- ✅ Model catalog exploration and deployment
- ✅ Building a chatbot with Python SDK
- ✅ Parameter tuning for different use cases
- ✅ Prompt engineering fundamentals

---

## Next Steps

Continue to [Lesson 12: Architecture Design](../12-architecture-design/README.md) for the collaborative design session.

---

## Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-studio/)
- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [Prompt Engineering Guide](https://learn.microsoft.com/azure/ai-services/openai/concepts/prompt-engineering)
