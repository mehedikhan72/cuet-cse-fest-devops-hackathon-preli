# CI/CD Quick Setup Guide

## Prerequisites
- GitHub account
- Docker Hub account
- Git installed

## Step-by-Step Setup

### 1. Generate Package Lock Files

Run the setup script to generate `package-lock.json` files needed for CI:

**Windows (PowerShell):**
```powershell
./setup-ci.ps1
```

**Linux/Mac (Bash):**
```bash
chmod +x setup-ci.sh
./setup-ci.sh
```

### 2. Create Docker Hub Account

1. Go to https://hub.docker.com and sign up
2. Create two repositories:
   - `your-username/ecommerce-backend` (public)
   - `your-username/ecommerce-gateway` (public)

### 3. Generate Docker Hub Access Token

1. Login to Docker Hub
2. Go to **Account Settings** → **Security**
3. Click **New Access Token**
4. Name it "GitHub Actions CI/CD"
5. Select permissions: **Read, Write, Delete**
6. Click **Generate**
7. **Copy the token immediately** (shown only once!)

### 4. Configure GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

   **Secret 1:**
   - Name: `DOCKERHUB_USERNAME`
   - Value: Your Docker Hub username (e.g., `johndoe`)

   **Secret 2:**
   - Name: `DOCKERHUB_TOKEN`
   - Value: The access token you copied from Docker Hub

### 5. Update Docker Image Names (Optional)

If your Docker Hub username is different from `mehedikhan72`, update the image names in `.github/workflows/cd.yml`:

```yaml
env:
  DOCKER_REGISTRY: docker.io
  BACKEND_IMAGE: YOUR_USERNAME/ecommerce-backend  # Change this
  GATEWAY_IMAGE: YOUR_USERNAME/ecommerce-gateway  # Change this
```

### 6. Commit and Push

```bash
# Add files
git add .

# Commit
git commit -m "Add CI/CD pipeline with GitHub Actions"

# Push to trigger CI/CD
git push origin main
```

### 7. Monitor Pipeline

1. Go to your GitHub repository
2. Click the **Actions** tab
3. Watch the CI pipeline run:
   - Backend CI (linting, type checking, unit tests)
   - Gateway CI (linting, unit tests)
   - E2E Tests (integration tests)
   - Security Scan (vulnerability scanning)

4. If all tests pass, the CD pipeline will:
   - Build Docker images
   - Push to Docker Hub
   - Run smoke tests
   - Create release (for version tags)

### 8. Verify Deployment

Check Docker Hub to see your images:
```
https://hub.docker.com/r/YOUR_USERNAME/ecommerce-backend
https://hub.docker.com/r/YOUR_USERNAME/ecommerce-gateway
```

## Quick Commands

### Run Tests Locally
```bash
# Backend
cd backend
npm install
npm test
npm run lint

# Gateway
cd gateway
npm install
npm test
npm run lint
```

### Test Docker Build Locally
```bash
# Backend
docker build -f backend/Dockerfile backend/

# Gateway
docker build -f gateway/Dockerfile gateway/
```

### Manual Deployment
```bash
# Pull from Docker Hub
docker pull YOUR_USERNAME/ecommerce-backend:latest
docker pull YOUR_USERNAME/ecommerce-gateway:latest

# Run locally
docker compose -f docker/compose.production.yaml up -d
```

## Troubleshooting

### "package-lock.json not found" Error
```bash
# Run setup script again
./setup-ci.ps1  # Windows
./setup-ci.sh   # Linux/Mac
```

### "Authentication required" Error
- Check if `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are set correctly
- Verify Docker Hub token has not expired
- Ensure repositories exist on Docker Hub

### Tests Failing
```bash
# Run tests locally first
cd backend && npm test
cd gateway && npm test

# Check for errors
cd backend && npm run lint
cd gateway && npm run lint
```

### Docker Build Failing
```bash
# Test build locally
docker build -f backend/Dockerfile backend/
docker build -f gateway/Dockerfile gateway/

# Check logs
docker compose -f docker/compose.production.yaml logs
```

## Creating a Release

To create a versioned release with automatic GitHub release notes:

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This will:
1. Trigger the CD pipeline
2. Build images with version tags (v1.0.0, v1.0, latest)
3. Push to Docker Hub
4. Create a GitHub release with deployment instructions

## Next Steps

- [ ] Add code coverage reporting to README
- [ ] Set up branch protection rules
- [ ] Add status badges to README
- [ ] Configure notifications for pipeline failures
- [ ] Set up staging environment
- [ ] Add performance testing
- [ ] Implement blue-green deployment

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Complete CI/CD Guide](CI-CD.md)
- [Deployment Guide](DEPLOYMENT.md)
