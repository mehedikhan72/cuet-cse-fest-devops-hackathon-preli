# CI/CD Pipeline Documentation

## Overview

This project uses GitHub Actions for continuous integration and continuous deployment (CI/CD). The pipeline consists of two main workflows:

1. **CI Pipeline** (`ci.yml`) - Runs on every push and pull request
2. **CD Pipeline** (`cd.yml`) - Runs on pushes to main branch and version tags

## CI Pipeline (Continuous Integration)

### Triggers
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

### Jobs

#### 1. Backend CI
- **Matrix Testing**: Tests on Node.js 18.x and 20.x
- **Steps**:
  - Checkout code
  - Setup Node.js
  - Install dependencies
  - Run ESLint (code quality)
  - Run TypeScript type checking
  - Run unit tests with coverage
  - Upload coverage to Codecov
  - Build TypeScript to JavaScript

#### 2. Gateway CI
- **Matrix Testing**: Tests on Node.js 18.x and 20.x
- **Steps**:
  - Checkout code
  - Setup Node.js
  - Install dependencies
  - Run ESLint (code quality)
  - Run unit tests with coverage
  - Upload coverage to Codecov

#### 3. E2E Tests
- **Runs After**: Backend CI and Gateway CI pass
- **Steps**:
  - Build Docker images (production)
  - Start all services (gateway, backend, MongoDB)
  - Wait for services to be healthy
  - Run end-to-end tests:
    - Health checks
    - Create product
    - Get products
    - Input validation
    - Security isolation tests
  - Show logs on failure
  - Cleanup containers and volumes

#### 4. Security Scan
- **Tool**: Trivy vulnerability scanner
- **Scans**: Filesystem and dependencies
- **Output**: Uploads results to GitHub Security

## CD Pipeline (Continuous Deployment)

### Triggers
- Push to `main` branch
- Version tags (e.g., `v1.0.0`)
- Manual workflow dispatch

### Jobs

#### 1. Build & Push Backend
- **Steps**:
  - Checkout code
  - Setup Docker Buildx (multi-platform builds)
  - Login to Docker Hub
  - Extract metadata (tags, labels)
  - Build and push backend image:
    - Platforms: `linux/amd64`, `linux/arm64`
    - Tags: latest, version, branch, SHA
    - Layer caching for faster builds

#### 2. Build & Push Gateway
- **Steps**: Same as backend but for gateway service

#### 3. Verify Deployment
- **Runs After**: Both images are built and pushed
- **Steps**:
  - Pull images from Docker Hub
  - Inspect images
  - Run smoke tests:
    - Start services with pulled images
    - Test health endpoints
    - Verify functionality
    - Cleanup

#### 4. Create GitHub Release
- **Runs After**: Images verified
- **Trigger**: Only on version tags (e.g., `v1.0.0`)
- **Creates**: GitHub release with Docker image details

## Setup Instructions

### 1. GitHub Repository Secrets

Add these secrets to your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Description | Example |
|------------|-------------|---------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | `yourusername` |
| `DOCKERHUB_TOKEN` | Docker Hub access token | Generate at hub.docker.com → Account Settings → Security |

### 2. Docker Hub Setup

1. Create a Docker Hub account at https://hub.docker.com
2. Create two repositories:
   - `your-username/ecommerce-backend`
   - `your-username/ecommerce-gateway`
3. Generate an access token:
   - Account Settings → Security → New Access Token
   - Give it read, write, delete permissions
   - Copy the token (shown only once)

### 3. Enable GitHub Actions

1. Go to repository Settings → Actions → General
2. Enable "Allow all actions and reusable workflows"
3. Enable "Read and write permissions" for GITHUB_TOKEN

## Running Locally

### Run Tests
```bash
# Backend tests
cd backend
npm install
npm run test

# Gateway tests
cd gateway
npm install
npm run test
```

### Run Linting
```bash
# Backend linting
cd backend
npm run lint

# Gateway linting
cd gateway
npm run lint
```

### Run Type Checking
```bash
# Backend type check
cd backend
npm run type-check
```

## Pipeline Status Badges

Add these badges to your README:

```markdown
![CI Pipeline](https://github.com/yourusername/repo/actions/workflows/ci.yml/badge.svg)
![CD Pipeline](https://github.com/yourusername/repo/actions/workflows/cd.yml/badge.svg)
```

## Deployment Process

### Automatic Deployment (Main Branch)
1. Push to `main` branch
2. CI pipeline runs (tests, linting, E2E)
3. If CI passes, CD pipeline triggers
4. Images built and pushed to Docker Hub with `latest` tag
5. Smoke tests verify deployment

### Version Release
1. Create and push a version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. CD pipeline triggers
3. Images built with version tags
4. GitHub release created automatically
5. Deployment instructions in release notes

## Docker Image Tags

Images are tagged with multiple formats:

- `latest` - Latest main branch build
- `main` - Main branch builds
- `v1.0.0` - Semantic version tags
- `v1.0` - Major.minor version
- `main-abc123` - Branch name + commit SHA

## Monitoring

### GitHub Actions
- View pipeline runs: Actions tab in GitHub
- Check logs for each job
- Download artifacts (if any)

### Docker Hub
- View image layers and sizes
- Check pull statistics
- Manage tags and versions

## Troubleshooting

### CI Fails on Tests
```bash
# Run tests locally first
npm run test

# Check test coverage
npm run test:ci
```

### CD Fails on Docker Build
```bash
# Test build locally
docker build -f backend/Dockerfile backend/
docker build -f gateway/Dockerfile gateway/
```

### Authentication Errors
- Verify DOCKERHUB_USERNAME and DOCKERHUB_TOKEN secrets
- Check Docker Hub access token permissions
- Ensure repositories exist on Docker Hub

### E2E Tests Fail
```bash
# Run E2E tests locally
docker compose -f docker/compose.production.yaml up -d
# Wait for services
sleep 30
# Test manually
curl http://localhost:5921/health
curl http://localhost:5921/api/health
```

## Security Best Practices

1. **Never commit secrets** - Use GitHub Secrets
2. **Scan for vulnerabilities** - Trivy runs automatically
3. **Use minimal base images** - Alpine Linux
4. **Multi-stage builds** - Reduce attack surface
5. **Non-root users** - Containers run as non-root
6. **Read-only filesystems** - Production containers

## Performance Optimization

1. **Layer caching** - Docker build cache enabled
2. **Multi-platform builds** - Parallel build for amd64/arm64
3. **Matrix testing** - Parallel test execution
4. **Dependency caching** - npm cache in CI

## Next Steps

1. **Code Coverage**: Review coverage reports in Codecov
2. **Security**: Check Trivy scan results in GitHub Security
3. **Performance**: Monitor Docker Hub pull metrics
4. **Documentation**: Update README with pipeline badges

## Support

For issues with the CI/CD pipeline:
1. Check GitHub Actions logs
2. Review this documentation
3. Test locally before pushing
4. Verify all secrets are configured correctly
