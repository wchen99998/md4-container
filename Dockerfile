FROM ghcr.io/nvidia/jax:base

# Install system dependencies and Google Cloud SDK
RUN apt-get update && \
    apt-get install -y \
    tmux \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-sdk \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Copy training setup script
COPY setup_and_train.sh /workspace/setup_and_train.sh
RUN chmod +x /workspace/setup_and_train.sh

# Keep container running indefinitely
ENTRYPOINT ["tail", "-f", "/dev/null"]
