FROM ghcr.io/nvidia/jax:base

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    tmux \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Keep container running indefinitely
ENTRYPOINT ["tail", "-f", "/dev/null"]
