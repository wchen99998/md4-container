#!/bin/bash
# Docker Run Examples for MD4 Training Container

# ============================================
# Example 1: Basic run with Hugging Face data
# ============================================
docker run -d \
  --name md4-training \
  -e PAT_TOKEN=ghp_your_token_here \
  -e BRANCH_NAME=main \
  -e CONFIG_PATH=md4/configs/md4/gems_vae_test.py \
  -e TRAINING_WORKDIR=/workspace/training_output \
  -v $(pwd)/training_output:/workspace/training_output \
  your-image-name \
  /workspace/setup_and_train.sh


# ============================================
# Example 2: Run with GCS data source
# ============================================
docker run -d \
  --name md4-training-gcs \
  -e PAT_TOKEN=ghp_your_token_here \
  -e BRANCH_NAME=main \
  -e DATA_SOURCE=gcs \
  -e GCS_BUCKET=your-bucket-name \
  -e GCS_DATA_PATH=gems_tfrecord \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -v $(pwd)/training_output:/workspace/training_output \
  your-image-name \
  /workspace/setup_and_train.sh


# ============================================
# Example 3: Run with GPU support
# ============================================
docker run -d \
  --name md4-training-gpu \
  --gpus all \
  -e PAT_TOKEN=ghp_your_token_here \
  -e BRANCH_NAME=main \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  -e DATA_SOURCE=gcs \
  -e GCS_BUCKET=your-bucket-name \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -v $(pwd)/training_output:/workspace/training_output \
  your-image-name \
  /workspace/setup_and_train.sh


# ============================================
# Example 4: Interactive mode (for debugging)
# ============================================
docker run -it \
  --name md4-debug \
  -e PAT_TOKEN=ghp_your_token_here \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -v $(pwd)/training_output:/workspace/training_output \
  your-image-name \
  /bin/bash

# Then inside container:
# ./workspace/setup_and_train.sh


# ============================================
# Example 5: With environment file
# ============================================
# Create a file named 'training.env' with:
# PAT_TOKEN=ghp_your_token_here
# BRANCH_NAME=main
# DATA_SOURCE=gcs
# GCS_BUCKET=your-bucket-name
# GCS_DATA_PATH=gems_tfrecord
# CONFIG_PATH=md4/configs/md4/gems_vae_test.py
# TRAINING_WORKDIR=/workspace/training_output

docker run -d \
  --name md4-training-env \
  --env-file training.env \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -v $(pwd)/training_output:/workspace/training_output \
  your-image-name \
  /workspace/setup_and_train.sh


# ============================================
# Example 6: Run on existing container
# ============================================
# If container is already running with tail -f /dev/null
docker exec -it \
  -e PAT_TOKEN=ghp_your_token_here \
  -e DATA_SOURCE=gcs \
  -e GCS_BUCKET=your-bucket-name \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  existing-container-name \
  /workspace/setup_and_train.sh


# ============================================
# Useful Commands
# ============================================

# View logs
docker logs -f md4-training

# Copy files from container
docker cp md4-training:/workspace/training_output ./local_output

# Stop container
docker stop md4-training

# Remove container
docker rm md4-training

# Access running container
docker exec -it md4-training /bin/bash

# Check container resource usage
docker stats md4-training
