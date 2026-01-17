# Cosmos DB Test Application

This folder contains the Cosmos DB test application for Lesson 09.

## Overview

This application demonstrates CRUD operations with Azure Cosmos DB using the Python SDK.

## Prerequisites

- Python 3.9 or later
- Azure Cosmos DB account (created via `azd up`)
- Environment variables set:
  - `COSMOS_ENDPOINT`: Your Cosmos DB endpoint URL
  - `COSMOS_KEY`: Your Cosmos DB primary key

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
   export COSMOS_ENDPOINT="https://your-account.documents.azure.com:443/"
   export COSMOS_KEY="your-primary-key"
   ```

4. Run the application:
   ```bash
   python app.py
   ```

## Features

- Create items with automatic ID generation
- Read items with partition key queries
- Update existing items
- Delete items
- Query items with SQL syntax
