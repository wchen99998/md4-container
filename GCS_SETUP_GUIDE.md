# Google Cloud Storage Service Account Setup Guide

## Quick Setup

### Step 1: Create Service Account and Grant Permissions

```bash
# Set your configuration
export GCP_PROJECT_ID="your-project-id"
export BUCKET_NAME="your-bucket-name"
export SA_NAME="md4-training-sa"

# Run the setup script
./setup_gcs_service_account.sh
```

This will:
- Create a service account
- Grant it access to your specified bucket
- Download the service account key as `gcs-key.json`

### Step 2: Use in Docker Container

```bash
docker run -d \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  -e PAT_TOKEN=your_github_token \
  your-image-name
```

---

## Manual Setup (Step-by-Step)

### 1. Create a Service Account

```bash
PROJECT_ID="your-project-id"
SA_NAME="md4-training-sa"

gcloud iam service-accounts create "$SA_NAME" \
    --display-name="MD4 Training Service Account" \
    --project="$PROJECT_ID"
```

### 2. Grant Bucket Access

Choose the appropriate permission level:

#### Option A: Full Object Access (Read/Write/Delete)
```bash
BUCKET_NAME="your-bucket-name"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin"
```

#### Option B: Read-Only Access
```bash
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectViewer"
```

#### Option C: Write-Only Access
```bash
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectCreator"
```

### 3. Create and Download Key

```bash
gcloud iam service-accounts keys create gcs-key.json \
    --iam-account="${SA_EMAIL}" \
    --project="$PROJECT_ID"
```

**⚠️ Security Warning:** Keep this key file secure! It provides access to your GCS bucket.

### 4. Verify the Key

```bash
# Check the key file
cat gcs-key.json

# Test authentication
gcloud auth activate-service-account --key-file=gcs-key.json
gsutil ls gs://${BUCKET_NAME}
```

---

## Using in Container

### Method 1: Mount Key File (Recommended)

```bash
docker run -d \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  your-image-name
```

### Method 2: Copy Key into Container

```bash
# Build with key (less secure)
COPY gcs-key.json /workspace/gcs-key.json
ENV GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json
```

### Method 3: Use Key Content as Environment Variable

```bash
# Convert key to base64
KEY_CONTENT=$(cat gcs-key.json | base64)

docker run -d \
  -e GCS_KEY_BASE64="$KEY_CONTENT" \
  your-image-name
```

Then in your startup script:
```bash
echo "$GCS_KEY_BASE64" | base64 -d > /tmp/gcs-key.json
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcs-key.json
```

---

## Python Usage in Training Script

### Using Google Cloud Storage in Python

```python
from google.cloud import storage
import os

# Authentication happens automatically via GOOGLE_APPLICATION_CREDENTIALS
client = storage.Client()

# Access your bucket
bucket = client.bucket('your-bucket-name')

# Upload a file
blob = bucket.blob('path/to/file.txt')
blob.upload_from_filename('local-file.txt')

# Download a file
blob = bucket.blob('path/to/file.txt')
blob.download_to_filename('local-file.txt')
```

### Install Required Package

Add to your requirements or run:
```bash
pip install google-cloud-storage
```

Or with uv:
```bash
uv pip install google-cloud-storage
```

---

## Common IAM Roles for GCS

| Role | Permission | Use Case |
|------|------------|----------|
| `roles/storage.objectAdmin` | Full control over objects | Training (read data, write checkpoints) |
| `roles/storage.objectViewer` | Read-only access | Inference (only read model weights) |
| `roles/storage.objectCreator` | Write-only access | Logging (only write logs) |
| `roles/storage.admin` | Full bucket control | Bucket management |

---

## Troubleshooting

### Permission Denied Error

```bash
# Check current permissions
gcloud storage buckets get-iam-policy gs://${BUCKET_NAME}

# Re-grant permissions
gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin"
```

### List All Service Accounts

```bash
gcloud iam service-accounts list --project="$PROJECT_ID"
```

### Delete Service Account (Cleanup)

```bash
gcloud iam service-accounts delete "${SA_EMAIL}" \
    --project="$PROJECT_ID"
```

### Rotate Keys (Security Best Practice)

```bash
# List existing keys
gcloud iam service-accounts keys list \
    --iam-account="${SA_EMAIL}" \
    --project="$PROJECT_ID"

# Delete old key
gcloud iam service-accounts keys delete KEY_ID \
    --iam-account="${SA_EMAIL}" \
    --project="$PROJECT_ID"

# Create new key
gcloud iam service-accounts keys create gcs-key-new.json \
    --iam-account="${SA_EMAIL}" \
    --project="$PROJECT_ID"
```

---

## Security Best Practices

1. **Use Read-Only Keys When Possible**: If your container only needs to read data, use `roles/storage.objectViewer`
2. **Mount Keys as Read-Only**: Use `:ro` flag when mounting key files
3. **Rotate Keys Regularly**: Create new keys and delete old ones periodically
4. **Use Workload Identity on GKE**: If running on GKE, use Workload Identity instead of key files
5. **Never Commit Keys to Git**: Add `*.json` to `.gitignore`
6. **Limit Bucket Access**: Only grant access to specific buckets, not project-wide
7. **Monitor Usage**: Enable audit logs to track service account usage

---

## Integration with Training Script

Update `setup_and_train.sh` to use GCS:

```bash
# Set GCS credentials
export GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json

# Download data from GCS instead of Hugging Face
gsutil -m cp -r gs://your-bucket/gems_tfrecord ./data/

# Or use Python
python -c "
from google.cloud import storage
client = storage.Client()
bucket = client.bucket('your-bucket')
# Download files...
"
```
