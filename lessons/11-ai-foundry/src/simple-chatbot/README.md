# Simple Chatbot

This folder contains the AI chatbot application for Lesson 11.

## Overview

A simple chatbot built with Azure AI Foundry that demonstrates:

- Azure OpenAI integration
- Conversation history management
- Parameter tuning (temperature, max tokens)
- System prompts for persona definition

## Prerequisites

- Python 3.9 or later
- Azure AI Foundry project with deployed model
- Environment variables set:
  - `AZURE_AI_ENDPOINT`: Your AI endpoint URL
  - `AZURE_AI_KEY`: Your API key
  - `AZURE_AI_DEPLOYMENT`: Your deployment name

## Setup

1. Create a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # macOS/Linux
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set environment variables:
   ```bash
   export AZURE_AI_ENDPOINT="https://your-endpoint.openai.azure.com/"
   export AZURE_AI_KEY="your-api-key"
   export AZURE_AI_DEPLOYMENT="gpt-4o-mini-deployment"
   ```

4. Run the chatbot:
   ```bash
   python chatbot.py
   ```

## Usage

- Type your questions and press Enter
- Type `quit` to exit
- Type `clear` to reset the conversation
