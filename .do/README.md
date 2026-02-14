# DigitalOcean Deployment Guide

## Quick Deploy to DigitalOcean App Platform

### Prerequisites

1. **GitHub Repository**: Ensure all code is committed and pushed to GitHub
2. **DigitalOcean Account**: Sign up at https://www.digitalocean.com/
3. **Required Secrets**: Have these ready:
   - LLM API Key (OpenAI, Anthropic, etc.)
   - OH_SECRET_KEY (generate with: `openssl rand -hex 32`)

### Deployment Steps

#### 1. Prepare Your Repository

```bash
# Make sure all changes are committed
git add .
git commit -m "Add DigitalOcean deployment configuration"
git push origin main
```

#### 2. Create App on DigitalOcean

1. Go to [DigitalOcean App Platform](https://cloud.digitalocean.com/apps)
2. Click **"Create App"**
3. Select **"GitHub"** as source
4. Authorize DigitalOcean to access your repository
5. Select your repository: `mathavanr1968/OpenHands`
6. Select branch: `main`

#### 3. Configure App Spec

1. In the configuration screen, click **"Edit App Spec"**
2. Replace the auto-generated spec with the contents of `.do/app.yaml`
3. Or upload the `.do/app.yaml` file directly

#### 4. Set Environment Variables

In the DigitalOcean dashboard, add these environment variables:

**Backend Service:**

| Variable        | Value                                  | Type   |
| --------------- | -------------------------------------- | ------ |
| `LLM_API_KEY`   | Your API key (OpenAI/Anthropic)        | Secret |
| `LLM_MODEL`     | `anthropic/claude-3-5-sonnet-20241022` | Secret |
| `OH_SECRET_KEY` | Generate with `openssl rand -hex 32`   | Secret |

**Optional Variables:**

| Variable                          | Value                | Description             |
| --------------------------------- | -------------------- | ----------------------- |
| `DATABASE_URL`                    | Your database URL    | If using external DB    |
| `SANDBOX_RUNTIME_CONTAINER_IMAGE` | Custom runtime image | If using custom sandbox |

#### 5. Deploy

1. Click **"Create Resources"**
2. Wait for the build to complete (10-15 minutes)
3. Monitor the build logs for any errors

#### 6. Verify Deployment

Once deployed, you'll get a URL like: `https://your-app-name.ondigitalocean.app`

Test the following:

- [ ] Frontend loads correctly
- [ ] Can create a new conversation
- [ ] Agent can execute basic commands
- [ ] API endpoints are accessible

### Troubleshooting

#### Build Fails

**Issue**: Poetry installation fails

```bash
# Solution: Check Python version in app.yaml
environment_slug: python  # Should use Python 3.13
```

**Issue**: Frontend build fails

```bash
# Solution: Check Node.js version
# Add to app.yaml:
engines:
  node: "20.x"
```

#### Runtime Errors

**Issue**: Backend service won't start

- Check environment variables are set correctly
- Verify `OH_SECRET_KEY` is set
- Check application logs in DigitalOcean dashboard

**Issue**: Frontend can't connect to backend

- Verify `VITE_BACKEND_URL` is set to backend service URL
- Check CORS configuration

### Updating the Deployment

To update your deployment:

```bash
# Make changes locally
git add .
git commit -m "Your update message"
git push origin main

# DigitalOcean will automatically rebuild and deploy
```

### Cost Estimate

**Basic Setup:**

- Backend (basic-xs): $5/month
- Frontend (static site): $0 (included)
- **Total**: ~$5/month

**With Database:**

- Backend: $5/month
- Frontend: $0
- PostgreSQL (basic): $15/month
- **Total**: ~$20/month

### Support

For issues:

1. Check DigitalOcean application logs
2. Review build logs for errors
3. Verify all environment variables are set
4. Check GitHub repository is accessible

### Environment Variables Reference

Generate secrets:

```bash
# Generate OH_SECRET_KEY
openssl rand -hex 32

# Generate database password (if needed)
openssl rand -base64 32
```

### Next Steps

After successful deployment:

1. Set up custom domain (optional)
2. Configure SSL certificate (automatic with DigitalOcean)
3. Set up monitoring and alerts
4. Configure backup strategy (if using database)
