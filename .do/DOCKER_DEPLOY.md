# DigitalOcean Docker Container Deployment Guide

## Quick Start

### Prerequisites

- Docker installed locally
- DigitalOcean account
- GitHub repository pushed

### Step 1: Build Docker Image Locally

```bash
cd /Users/mathavanr1968/iSuite_IDE/Openhands/OpenHands

# Build the image
docker build -t openhands-app:latest .
```

### Step 2: Test Locally (Optional)

```bash
# Run the container
docker run -p 3000:3000 \
  -e LLM_API_KEY=your_api_key \
  -e LLM_MODEL=anthropic/claude-3-5-sonnet-20241022 \
  -e OH_SECRET_KEY=$(openssl rand -hex 32) \
  openhands-app:latest

# Test at http://localhost:3000
```

### Step 3: Push to DigitalOcean Container Registry

```bash
# Install doctl (DigitalOcean CLI)
brew install doctl

# Authenticate
doctl auth init

# Create container registry (if not exists)
doctl registry create openhands-registry

# Log in to registry
doctl registry login

# Tag the image
docker tag openhands-app:latest registry.digitalocean.com/openhands-registry/openhands-app:latest

# Push to registry
docker push registry.digitalocean.com/openhands-registry/openhands-app:latest
```

### Step 4: Deploy on DigitalOcean

#### Option A: Using App Platform

1. Go to https://cloud.digitalocean.com/apps
2. Click "Create App"
3. Choose "DigitalOcean Container Registry"
4. Select your image: `openhands-registry/openhands-app:latest`
5. Configure:
   - Port: 3000
   - Health check: `/api/options/models`
6. Add environment variables:
   - `LLM_API_KEY`
   - `LLM_MODEL`
   - `OH_SECRET_KEY`
7. Deploy!

#### Option B: Using Droplet (Manual)

```bash
# Create droplet
doctl compute droplet create openhands-app \
  --image docker-20-04 \
  --size s-2vcpu-4gb \
  --region nyc1

# SSH into droplet
doctl compute ssh openhands-app

# Pull and run container
docker login registry.digitalocean.com
docker pull registry.digitalocean.com/openhands-registry/openhands-app:latest
docker run -d -p 80:3000 \
  -e LLM_API_KEY=your_key \
  -e LLM_MODEL=anthropic/claude-3-5-sonnet-20241022 \
  -e OH_SECRET_KEY=your_secret \
  --restart unless-stopped \
  registry.digitalocean.com/openhands-registry/openhands-app:latest
```

### Step 5: Set Up GitHub Actions (Optional - Auto Deploy)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to DigitalOcean

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build and push to DigitalOcean
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}

      - name: Build image
        run: docker build -t openhands-app .

      - name: Push to registry
        run: |
          doctl registry login
          docker tag openhands-app registry.digitalocean.com/openhands-registry/openhands-app:latest
          docker push registry.digitalocean.com/openhands-registry/openhands-app:latest
```

## Environment Variables

Required:

- `LLM_API_KEY` - Your AI provider API key
- `LLM_MODEL` - Model name (e.g., `anthropic/claude-3-5-sonnet-20241022`)
- `OH_SECRET_KEY` - Session secret (generate with `openssl rand -hex 32`)

Optional:

- `WORKSPACE_BASE` - Default: `/workspace`
- `SANDBOX_RUNTIME_CONTAINER_IMAGE` - Default: `ghcr.io/all-hands-ai/runtime:0.20-nikolaik`
- `LOG_ALL_EVENTS` - Default: `false`

## Troubleshooting

### Build fails

- Check Docker is running
- Ensure enough disk space
- Try `docker system prune` to clean up

### Push fails

- Verify `doctl auth init` was successful
- Check registry name matches
- Ensure you're logged in: `doctl registry login`

### Container won't start

- Check logs: `docker logs <container_id>`
- Verify environment variables are set
- Check port 3000 is not in use

## Cost Estimate

**Container Registry:** $5/month (100GB storage)
**App Platform (basic):** $5/month
**Total:** ~$10/month

Or use Droplet:
**Droplet (2GB RAM):** $12/month
**Total:** ~$17/month (includes registry)

## Next Steps

1. Build Docker image locally
2. Test it works
3. Push to DigitalOcean registry
4. Deploy using App Platform or Droplet
5. Configure domain (optional)
6. Set up SSL (automatic with App Platform)
