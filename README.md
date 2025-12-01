# Hackathon Challenge - DevOps Solution

![CI Pipeline](https://github.com/mehedikhan72/cuet-cse-fest-devops-hackathon-preli/actions/workflows/ci.yml/badge.svg)
![CD Pipeline](https://github.com/mehedikhan72/cuet-cse-fest-devops-hackathon-preli/actions/workflows/cd.yml/badge.svg)

A fully containerized microservices e-commerce backend with Docker, comprehensive CI/CD pipelines, and production-ready DevOps practices.

## 🚀 Quick Start

```bash
# Development
docker compose -f docker/compose.development.yaml --env-file .env up -d

# Production
docker compose -f docker/compose.production.yaml --env-file .env up -d

# Using Makefile (if available)
make dev-up    # Development
make prod-up   # Production
```

## 📋 Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Quick Start](#quick-start)
- [CI/CD Pipeline](#cicd-pipeline)
- [Documentation](#documentation)
- [Testing](#testing)

## Problem Statement

The backend setup consisting of:

- A service for managing products
- A gateway that forwards API requests

The system must be containerized, secure, optimized, and maintain data persistence across container restarts.

## Architecture

```
                    ┌─────────────────┐
                    │   Client/User   │
                    └────────┬────────┘
                             │
                             │ HTTP (port 5921)
                             │
                    ┌────────▼────────┐
                    │    Gateway      │
                    │  (port 5921)    │
                    │   [Exposed]     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼──────────┐      │
         │   Private Network   │      │
         │  (Docker Network)   │      │
         └──────────┬──────────┘      │
                    │                 │
         ┌──────────┴──────────┐      │
         │                     │      │
    ┌────▼────┐         ┌──────▼──────┐
    │ Backend │         │   MongoDB   │
    │(port    │◄────────┤  (port      │
    │ 3847)   │         │  27017)     │
    │[Not     │         │ [Not        │
    │Exposed] │         │ Exposed]    │
    └─────────┘         └─────────────┘
```

**Key Points:**
- Gateway is the only service exposed to external clients (port 5921)
- All external requests must go through the Gateway
- Backend and MongoDB should not be exposed to public network

## ✨ Features

### DevOps & Infrastructure
- ✅ **Docker Containerization**: Multi-stage builds, optimized images
- ✅ **Container Orchestration**: Docker Compose for dev and prod
- ✅ **Network Isolation**: Private networks, only gateway exposed
- ✅ **Data Persistence**: Named volumes for MongoDB
- ✅ **Health Checks**: Automated service health monitoring
- ✅ **Security Hardening**: Non-root users, read-only filesystems, capability dropping

### CI/CD Pipeline
- ✅ **Automated Testing**: Unit tests, E2E tests, integration tests
- ✅ **Code Quality**: ESLint, TypeScript type checking
- ✅ **Security Scanning**: Trivy vulnerability scanning
- ✅ **Docker Hub Integration**: Automated image builds and pushes
- ✅ **Multi-platform Builds**: AMD64 and ARM64 support
- ✅ **Matrix Testing**: Multiple Node.js versions

### Development Experience
- ✅ **Hot Reload**: Live code reloading in development
- ✅ **Makefile Commands**: Simple CLI for common tasks
- ✅ **Environment Management**: Separate dev/prod configs
- ✅ **Comprehensive Documentation**: Setup, deployment, optimization guides

## 🔄 CI/CD Pipeline

### Continuous Integration (CI)
Runs on every push and pull request:
- **Static Analysis**: ESLint, TypeScript type checking
- **Unit Tests**: Backend and gateway test suites with coverage
- **E2E Tests**: Full integration testing with Docker
- **Security Scan**: Trivy vulnerability scanning

### Continuous Deployment (CD)
Runs on main branch and version tags:
- **Build**: Multi-platform Docker images (AMD64/ARM64)
- **Push**: Automated push to Docker Hub
- **Verify**: Smoke tests with deployed images
- **Release**: GitHub releases for version tags

**See [CI-CD.md](CI-CD.md) for complete documentation**

## 📚 Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment guide, commands, troubleshooting
- **[CI-CD.md](CI-CD.md)** - CI/CD pipeline setup and configuration
- **[SECURITY.md](SECURITY.md)** - Security practices and policies
- **[OPTIMIZATION.md](OPTIMIZATION.md)** - Docker optimization strategies

## Project Structure

**DO NOT CHANGE THE PROJECT STRUCTURE.** The following structure must be maintained:

```
.
├── backend/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── src/
├── gateway/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── src/
├── docker/
│   ├── compose.development.yaml
│   └── compose.production.yaml
├── Makefile
└── README.md
```

## Environment Variables

Create a `.env` file in the root directory with the following variables (do not commit actual values):

```env
MONGO_INITDB_ROOT_USERNAME=
MONGO_INITDB_ROOT_PASSWORD=
MONGO_URI=
MONGO_DATABASE=
BACKEND_PORT=3847 # DO NOT CHANGE
GATEWAY_PORT=5921 # DO NOT CHANGE 
NODE_ENV=
```

## Expectations (Open ended, DO YOUR BEST!!!)

- Separate Dev and Prod configs
- Data Persistence
- Follow security basics (limit network exposure, sanitize input) 
- Docker Image Optimization
- Makefile CLI Commands for smooth dev and prod deploy experience (TRY TO COMPLETE THE COMMANDS COMMENTED IN THE Makefile)

**ADD WHAT EVER BEST PRACTICES YOU KNOW**

## Testing

### Manual Testing

Use the following curl commands to test your implementation.

### Health Checks

Check gateway health:
```bash
curl http://localhost:5921/health
```

Check backend health via gateway:
```bash
curl http://localhost:5921/api/health
```

### Product Management

Create a product:
```bash
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'
```

Get all products:
```bash
curl http://localhost:5921/api/products
```

### Security Test

Verify backend is not directly accessible (should fail or be blocked):
```bash
curl http://localhost:3847/api/products
```

### Automated Testing

```bash
# Run test script (PowerShell)
./test-api.ps1

# Run test script (Bash)
./test-api.sh

# Unit tests
cd backend && npm test
cd gateway && npm test

# Linting
cd backend && npm run lint
cd gateway && npm run lint
```

## 🛠️ Development Commands

```bash
# Start development environment
docker compose -f docker/compose.development.yaml --env-file .env up -d

# View logs
docker compose -f docker/compose.development.yaml logs -f

# Stop environment
docker compose -f docker/compose.development.yaml down

# Rebuild and restart
docker compose -f docker/compose.development.yaml up -d --build

# Clean everything (including volumes)
docker compose -f docker/compose.development.yaml down -v
```

## 🚀 Production Deployment

```bash
# Build production images
docker compose -f docker/compose.production.yaml --env-file .env build

# Start production environment
docker compose -f docker/compose.production.yaml --env-file .env up -d

# Check status
docker compose -f docker/compose.production.yaml ps

# View logs
docker compose -f docker/compose.production.yaml logs -f
```

## 🔐 Security Features

- **Network Isolation**: Backend and MongoDB not exposed to host
- **Non-root Execution**: Containers run as unprivileged users
- **Read-only Filesystems**: Enhanced security in production
- **Capability Dropping**: Minimal Linux capabilities
- **Input Validation**: Request validation and sanitization
- **Health Checks**: Automatic restart on failure

## 📊 Monitoring

```bash
# Container stats
docker stats

# Service health
docker compose -f docker/compose.production.yaml ps

# Logs
docker compose -f docker/compose.production.yaml logs --tail=100 -f
```

## 🎯 Key Achievements

✅ **Containerization**: Multi-stage Docker builds with Alpine Linux  
✅ **Security**: Network isolation, non-root users, security hardening  
✅ **Optimization**: Image sizes < 200MB, layer caching, multi-platform  
✅ **CI/CD**: Automated testing, linting, building, and deployment  
✅ **Data Persistence**: Named volumes, backup/restore capabilities  
✅ **DevOps Practices**: Environment configs, health checks, monitoring  
✅ **Documentation**: Comprehensive guides and troubleshooting  
✅ **Testing**: Unit tests, E2E tests, smoke tests, security tests  

## Submission Process

1. **Fork the Repository**
   - Fork this repository to your GitHub account
   - The repository must remain **private** during the contest

2. **Make Repository Public**
   - In the **last 5 minutes** of the contest, make your repository **public**
   - Repositories that remain private after the contest ends will not be evaluated

3. **Submit Repository URL**
   - Submit your repository URL at [arena.bongodev.com](https://arena.bongodev.com)
   - Ensure the URL is correct and accessible

4. **Code Evaluation**
   - All submissions will be both **automated and manually evaluated**
   - Plagiarism and code copying will result in disqualification

## Rules

- ⚠️ **NO COPYING**: All code must be your original work. Copying code from other participants or external sources will result in immediate disqualification.

- ⚠️ **NO POST-CONTEST COMMITS**: Pushing any commits to the git repository after the contest ends will result in **disqualification**. All work must be completed and committed before the contest deadline.

- ✅ **Repository Visibility**: Keep your repository private during the contest, then make it public in the last 5 minutes.

- ✅ **Submission Deadline**: Ensure your repository is public and submitted before the contest ends.

Good luck!

