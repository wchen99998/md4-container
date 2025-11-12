# MD4 Training Container - Quick Start Guide

## Prerequisites

- Docker installed
- gcloud CLI installed (for GCS setup)
- GitHub Personal Access Token (PAT)
- GCP project with billing enabled (if using GCS)

## Option 1: Quick Start with Hugging Face (No GCS)

### 1. Build the Docker image

```bash
docker build -t md4-training .
```

### 2. Run training

```bash
docker run -d \
  --name md4-training \
  --gpus all \
  -e PAT_TOKEN=your_github_token \
  -e BRANCH_NAME=main \
  -v $(pwd)/output:/workspace/output \
  md4-training \
  /workspace/setup_and_train.sh
```

### 3. Monitor progress

```bash
docker logs -f md4-training
```

---

## Option 2: With Google Cloud Storage

### Step 1: Setup GCS Service Account

```bash
# Configure your settings
export GCP_PROJECT_ID="your-project-id"
export BUCKET_NAME="your-bucket-name"

# Run the setup script
./setup_gcs_service_account.sh
```

This creates `gcs-key.json` with credentials.

### Step 2: Build Docker Image

```bash
docker build -t md4-training .
```

### Step 3: Run Training with GCS

```bash
docker run -d \
  --name md4-training \
  --gpus all \
  -e PAT_TOKEN=your_github_token \
  -e DATA_SOURCE=gcs \
  -e GCS_BUCKET=your-bucket-name \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -v $(pwd)/output:/workspace/output \
  md4-training \
  /workspace/setup_and_train.sh
```

### Step 4: Monitor

```bash
# View logs
docker logs -f md4-training

# Check status
docker ps

# Access container
docker exec -it md4-training /bin/bash
```

---

## Using Environment File (Recommended)

### 1. Create your environment file

```bash
cp .env.example training.env
# Edit training.env with your values
```

### 2. Run with env file

```bash
docker run -d \
  --name md4-training \
  --gpus all \
  --env-file training.env \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  -v $(pwd)/output:/workspace/output \
  md4-training \
  /workspace/setup_and_train.sh
```

---

## Environment Variables Reference

### Required
- `PAT_TOKEN` - GitHub Personal Access Token

### Optional
- `BRANCH_NAME` - Git branch to checkout (default: "main")
- `CONFIG_PATH` - Training config file (default: "md4/configs/md4/gems_vae_test.py")
- `TRAINING_WORKDIR` - Output directory (default: "/home/wuhao/md4/GEMS_TEST_MAE")
- `DATA_SOURCE` - Data source: "huggingface" or "gcs" (default: "huggingface")

### GCS-Specific (when DATA_SOURCE=gcs)
- `GCS_BUCKET` - GCS bucket name
- `GCS_DATA_PATH` - Path within bucket (default: "gems_tfrecord")
- `GOOGLE_APPLICATION_CREDENTIALS` - Path to key file (default: "/workspace/gcs-key.json")

---

## Common Commands

```bash
# Build image
docker build -t md4-training .

# Run training
docker run -d --name md4-training --gpus all --env-file training.env md4-training

# View logs
docker logs -f md4-training

# Stop container
docker stop md4-training

# Remove container
docker rm md4-training

# Access container shell
docker exec -it md4-training /bin/bash

# Copy output files
docker cp md4-training:/workspace/output ./local-output
```

---

## Troubleshooting

### Permission Denied (GCS)

```bash
# Check GCS permissions
gcloud storage buckets get-iam-policy gs://your-bucket

# Test authentication
docker run -it --rm \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/gcs-key.json \
  -v $(pwd)/gcs-key.json:/workspace/gcs-key.json:ro \
  md4-training \
  gsutil ls gs://your-bucket
```

### Git Clone Failed

- Verify PAT_TOKEN has repo access
- Check token hasn't expired
- Ensure token is correctly set in environment

### GPU Not Available

```bash
# Check GPU availability
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# Install nvidia-docker if needed
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
```

### Container Exits Immediately

```bash
# Check logs
docker logs md4-training

# Run interactively for debugging
docker run -it --rm --env-file training.env md4-training /bin/bash
```

---

## File Structure

```
md4-container/
├── Dockerfile                      # Container definition
├── setup_and_train.sh             # Main training script
├── setup_gcs_service_account.sh   # GCS setup helper
├── docker-run-examples.sh         # Usage examples
├── .env.example                   # Environment template
├── GCS_SETUP_GUIDE.md            # Detailed GCS guide
├── QUICKSTART.md                 # This file
└── gcs-key.json                  # GCS credentials (gitignored)
```

---

## Next Steps

- See `GCS_SETUP_GUIDE.md` for detailed GCS configuration
- See `docker-run-examples.sh` for more usage patterns
- Check Docker logs regularly to monitor training progress
- Save checkpoints to mounted volumes for persistence

---

## Security Notes

- **Never commit `gcs-key.json` to git**
- Add `*.json` to `.gitignore`
- Mount key files as read-only (`:ro`)
- Rotate service account keys regularly
- Use minimal IAM permissions (objectViewer for read-only)
