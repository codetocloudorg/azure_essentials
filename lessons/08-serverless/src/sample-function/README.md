# Sample Function App

This folder contains the Azure Functions sample code for Lesson 08.

## Structure

```
sample-function/
├── HttpTrigger/
│   ├── __init__.py
│   └── function.json
├── TimerTrigger/
│   ├── __init__.py
│   └── function.json
├── host.json
├── local.settings.json
└── requirements.txt
```

## Local Development

1. Create a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # macOS/Linux
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run locally:
   ```bash
   func start
   ```

## Deployment

This function is deployed automatically via `azd up` from the repository root.
