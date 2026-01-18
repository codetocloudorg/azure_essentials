# Simple Python container - Alpine-based for small size
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Install dependencies (just Flask)
RUN pip install --no-cache-dir flask gunicorn

# Copy application
COPY app.py .

# Expose port
EXPOSE 8080

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
