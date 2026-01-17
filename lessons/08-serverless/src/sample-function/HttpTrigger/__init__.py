"""
HTTP Trigger Function
Azure Essentials - Lesson 08: Serverless Services
Code to Cloud
"""
import azure.functions as func
import json
from datetime import datetime


def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP trigger function that returns a greeting.

    Query Parameters:
        name (str): The name to greet (optional)

    Returns:
        JSON response with greeting message
    """
    # Get name from query string or request body
    name = req.params.get('name')

    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get('name')
        except ValueError:
            pass

    if name:
        message = f"Hello, {name}! Welcome to Azure Functions."
    else:
        message = "Hello! Pass a name in the query string or request body."

    response_data = {
        "message": message,
        "timestamp": datetime.utcnow().isoformat(),
        "function": "HttpTrigger",
        "course": "Azure Essentials"
    }

    return func.HttpResponse(
        json.dumps(response_data, indent=2),
        mimetype="application/json",
        status_code=200
    )
