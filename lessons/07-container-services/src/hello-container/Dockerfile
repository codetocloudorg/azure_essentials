# Simple Python container - Alpine-based for small size
FROM python:3.13-alpine

# Set working directory
WORKDIR /app

# Create MOTD with ASCII art banner
RUN echo '   ██████╗ ██████╗ ██████╗ ███████╗    ████████╗ ██████╗ ' > /etc/motd && \
    echo '  ██╔════╝██╔═══██╗██╔══██╗██╔════╝    ╚══██╔══╝██╔═══██╗' >> /etc/motd && \
    echo '  ██║     ██║   ██║██║  ██║█████╗         ██║   ██║   ██║' >> /etc/motd && \
    echo '  ██║     ██║   ██║██║  ██║██╔══╝         ██║   ██║   ██║' >> /etc/motd && \
    echo '  ╚██████╗╚██████╔╝██████╔╝███████╗       ██║   ╚██████╔╝' >> /etc/motd && \
    echo '   ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝       ╚═╝    ╚═════╝ ' >> /etc/motd && \
    echo '' >> /etc/motd && \
    echo '   ██████╗██╗      ██████╗ ██╗   ██╗██████╗ ' >> /etc/motd && \
    echo '  ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗' >> /etc/motd && \
    echo '  ██║     ██║     ██║   ██║██║   ██║██║  ██║' >> /etc/motd && \
    echo '  ██║     ██║     ██║   ██║██║   ██║██║  ██║' >> /etc/motd && \
    echo '  ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝' >> /etc/motd && \
    echo '   ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ ' >> /etc/motd && \
    echo '' >> /etc/motd && \
    echo '  Azure Essentials - Code to Cloud' >> /etc/motd && \
    echo '  www.codetocloud.io' >> /etc/motd && \
    echo '' >> /etc/motd

# Install dependencies (just Flask)
RUN pip install --no-cache-dir flask gunicorn

# Copy application
COPY app.py .

# Expose port
EXPOSE 8080

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
