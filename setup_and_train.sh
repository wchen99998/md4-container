#!/bin/bash
set -e  # Exit on error

# Environment variables with defaults
PAT_TOKEN=${PAT_TOKEN:-""}
BRANCH_NAME=${BRANCH_NAME:-"gems_latest"}
CONFIG_PATH=${CONFIG_PATH:-"md4/configs/md4/gems_vae_test.py"}
TRAINING_WORKDIR=${TRAINING_WORKDIR:-"/home/wuhao/md4/GEMS_TEST_MAE"}
DATA_SOURCE=${DATA_SOURCE:-"huggingface"}  # Options: huggingface, gcs
GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS:-"/workspace/gcs-key.json"}
GCS_BUCKET=${GCS_BUCKET:-""}
GCS_DATA_PATH=${GCS_DATA_PATH:-"gems_tfrecord"}

# Validate required environment variables
if [ -z "$PAT_TOKEN" ]; then
    echo "Error: PAT_TOKEN environment variable is not set"
    exit 1
fi

echo "==> Cloning repository..."
git clone https://username:${PAT_TOKEN}@github.com/wchen99998/md4.git
cd md4

echo "==> Switching to branch: $BRANCH_NAME"
git checkout "$BRANCH_NAME"

echo "==> Downloading dataset..."
if [ "$DATA_SOURCE" = "huggingface" ]; then
    echo "Downloading from Hugging Face..."
    uvx hf download cjim8889/GeMS-TF --repo-type dataset --local-dir ./data/gems_tfrecord

else
    echo "Error: Invalid DATA_SOURCE. Must be 'huggingface' or 'gcs'"
    exit 1
fi

echo "==> Starting training..."
python md4/main.py \
    --config "$CONFIG_PATH" \
    --workdir "$TRAINING_WORKDIR" \
    --mode vae

echo "==> Training completed successfully!"
