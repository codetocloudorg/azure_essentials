"""
Azure Essentials - Hello Container App
A minimal Flask app for demonstrating container deployment.
"""
from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    """Simple hello endpoint with container info."""
    hostname = socket.gethostname()
    return f"""
    <html>
    <head>
        <title>Hello from Azure Container!</title>
        <style>
            body {{ 
                font-family: Arial, sans-serif; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
            }}
            .container {{
                text-align: center;
                padding: 40px;
                background: rgba(255,255,255,0.1);
                border-radius: 20px;
                backdrop-filter: blur(10px);
            }}
            h1 {{ font-size: 3em; margin-bottom: 10px; }}
            .emoji {{ font-size: 4em; }}
            .info {{ opacity: 0.8; margin-top: 20px; }}
            code {{ background: rgba(0,0,0,0.3); padding: 5px 10px; border-radius: 5px; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="emoji">🐳</div>
            <h1>Hello from Azure!</h1>
            <p>Your container is running successfully.</p>
            <div class="info">
                <p>Container hostname: <code>{hostname}</code></p>
                <p>Running on: <code>Azure Container Registry + AKS</code></p>
            </div>
        </div>
    </body>
    </html>
    """

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes."""
    return {"status": "healthy", "hostname": socket.gethostname()}

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
