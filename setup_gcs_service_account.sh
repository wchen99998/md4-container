#!/bin/bash
set -e

# Configuration
PROJECT_ID=${GCP_PROJECT_ID:-""}
SA_NAME=${SA_NAME:-"md4-training-sa"}
SA_DISPLAY_NAME=${SA_DISPLAY_NAME:-"MD4 Training Service Account"}
BUCKET_NAME=${BUCKET_NAME:-""}
KEY_FILE=${KEY_FILE:-"./gcs-key.json"}

# Validate required variables
if [ -z "$PROJECT_ID" ]; then
    echo "Error: GCP_PROJECT_ID environment variable is not set"
    exit 1
fi

if [ -z "$BUCKET_NAME" ]; then
    echo "Error: BUCKET_NAME environment variable is not set"
    exit 1
fi

SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "==> Creating service account: $SA_NAME"
gcloud iam service-accounts create "$SA_NAME" \
    --display-name="$SA_DISPLAY_NAME" \
    --project="$PROJECT_ID" \
    || echo "Service account may already exist, continuing..."

echo "==> Granting Storage Object Admin role to service account for bucket: $BUCKET_NAME"
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin" \
    --project="$PROJECT_ID"

echo "==> Creating and downloading service account key..."
gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SA_EMAIL" \
    --project="$PROJECT_ID"

echo "==> Service account setup complete!"
echo ""
echo "Service Account Email: $SA_EMAIL"
echo "Key File: $KEY_FILE"
echo ""
echo "To use in Docker:"
echo "  docker run -v \$(pwd)/$KEY_FILE:/workspace/gcs-key.json \\"
echo "             -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \\"
echo "             your-image-name"
