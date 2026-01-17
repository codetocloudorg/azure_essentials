"""
Simple Chatbot using Azure AI Foundry
Azure Essentials - Lesson 11: Azure AI Foundry
Code to Cloud
"""
import os
from openai import AzureOpenAI


# Configuration from environment variables
ENDPOINT = os.environ.get("AZURE_AI_ENDPOINT")
API_KEY = os.environ.get("AZURE_AI_KEY")
DEPLOYMENT = os.environ.get("AZURE_AI_DEPLOYMENT", "gpt-4o-mini-deployment")

# System prompt defines the chatbot's personality and behaviour
SYSTEM_PROMPT = """You are a helpful Azure learning assistant.
Your role is to:
- Answer questions about Microsoft Azure services
- Explain cloud computing concepts in simple terms
- Provide practical examples and best practices
- Be concise but thorough in your responses

If you don't know something, say so honestly.
Keep responses focused and relevant to Azure and cloud computing."""


def create_client() -> AzureOpenAI:
    """Create the Azure OpenAI client."""
    if not ENDPOINT or not API_KEY:
        raise ValueError(
            "Please set AZURE_AI_ENDPOINT and AZURE_AI_KEY environment variables"
        )

    return AzureOpenAI(
        azure_endpoint=ENDPOINT,
        api_key=API_KEY,
        api_version="2024-02-15-preview"
    )


def chat(client: AzureOpenAI, messages: list, user_input: str) -> str:
    """
    Send a message and get a response.

    Args:
        client: The Azure OpenAI client
        messages: Conversation history
        user_input: The user's message

    Returns:
        The assistant's response
    """
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
    print("  Azure Learning Assistant")
    print("  Azure Essentials - Lesson 11")
    print("=" * 60)
    print()
    print("Type 'quit' to exit, 'clear' to reset conversation")
    print()

    try:
        client = create_client()
    except ValueError as e:
        print(f"Configuration error: {e}")
        return

    # Initialise conversation with system prompt
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
                print("\nGoodbye! Happy learning!")
                break

            if user_input.lower() == 'clear':
                messages = [{"role": "system", "content": SYSTEM_PROMPT}]
                print("\nConversation cleared. Starting fresh!")
                continue

            # Get and display response
            print("\nAssistant: ", end="")
            response = chat(client, messages, user_input)
            print(response)

        except KeyboardInterrupt:
            print("\n\nGoodbye!")
            break
        except Exception as e:
            print(f"\nError: {e}")
            print("Please check your credentials and try again.")


if __name__ == "__main__":
    main()
