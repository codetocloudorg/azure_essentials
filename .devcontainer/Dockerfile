# =============================================================================
# Azure Essentials Dev Container
# Code to Cloud Inc. | www.codetocloud.io
# =============================================================================
# Ubuntu minimal base with all tools needed for Azure Essentials training
# =============================================================================

FROM ubuntu:24.04

LABEL maintainer="Code to Cloud Inc. <hello@codetocloud.io>"
LABEL description="Azure Essentials Training - Development Container"
LABEL org.opencontainers.image.source="https://github.com/codetocloudorg/azure_essentials"

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# =============================================================================
# Base System Setup
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential tools
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    # Development essentials
    git \
    vim \
    nano \
    less \
    jq \
    unzip \
    zip \
    tree \
    htop \
    # Networking tools
    dnsutils \
    iputils-ping \
    netcat-openbsd \
    openssh-client \
    # Build tools (for Python packages)
    build-essential \
    libssl-dev \
    libffi-dev \
    # Shell
    bash-completion \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# =============================================================================
# Azure CLI
# =============================================================================
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && az bicep install

# =============================================================================
# Azure Developer CLI (azd)
# =============================================================================
RUN curl -fsSL https://aka.ms/install-azd.sh | bash

# =============================================================================
# Python 3.11
# =============================================================================
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-venv \
        python3.11-dev \
        python3-pip \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for Azure
RUN pip3 install --no-cache-dir --break-system-packages --ignore-installed \
    azure-functions \
    azure-cosmos \
    azure-storage-blob \
    azure-identity \
    openai \
    requests \
    flask

# =============================================================================
# Node.js LTS
# =============================================================================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# .NET 8 SDK
# =============================================================================
RUN wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-8.0 \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# kubectl
# =============================================================================
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Docker CLI (for Docker-in-Docker scenarios)
# =============================================================================
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Azure Functions Core Tools
# =============================================================================
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-functions.list \
    && apt-get update \
    && apt-get install -y azure-functions-core-tools-4 \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Create non-root user
# =============================================================================
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN if getent group $USER_GID > /dev/null 2>&1; then \
        groupmod -n $USERNAME $(getent group $USER_GID | cut -d: -f1); \
    else \
        groupadd --gid $USER_GID $USERNAME; \
    fi \
    && if id -u $USER_UID > /dev/null 2>&1; then \
        usermod -l $USERNAME -d /home/$USERNAME -m $(id -nu $USER_UID); \
    else \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
    fi \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# =============================================================================
# MOTD (Message of the Day)
# =============================================================================
COPY motd.txt /etc/motd

# Configure bash to show MOTD on login
RUN echo 'cat /etc/motd' >> /home/$USERNAME/.bashrc \
    && echo 'cat /etc/motd' >> /etc/bash.bashrc

# =============================================================================
# Final Setup
# =============================================================================
# Set ownership
RUN mkdir -p /home/$USERNAME/.azure /home/$USERNAME/.azd \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set working directory
WORKDIR /workspaces/azure_essentials

# Switch to non-root user
USER $USERNAME

# Default command
CMD ["bash"]
