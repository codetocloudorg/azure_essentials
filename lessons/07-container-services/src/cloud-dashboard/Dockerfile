# Cloud Dashboard
# Code to Cloud - Azure Essentials Training
# Lesson 07: Container Services

FROM nginx:alpine

# Add labels for container metadata
LABEL maintainer="Code to Cloud"
LABEL description="Azure Essentials - Cloud Dashboard"
LABEL version="1.0"

# Copy application files
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
