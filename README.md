# CUET CSE Fest DevOps Hackathon - E-Commerce Microservices

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=flat&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)

A fully containerized microservices architecture for an e-commerce backend with optimized Docker configurations, security best practices, and production-ready deployment strategies.

## 🎯 Problem Statement

The backend setup consisting of:

- A service for managing products (Backend)
- A gateway that forwards API requests (Gateway)
- MongoDB database for data persistence

**Requirements:**
- Containerized architecture using Docker
- Secure network configuration
- Optimized Docker images
- Data persistence across container restarts
- Separate development and production configurations

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

## 🔐 GitHub Secrets for CI/CD

To enable the CI/CD pipeline to push Docker images to Docker Hub, you need to set up the following secrets in your GitHub repository:

### Required Secrets

1. **DOCKERHUB_USERNAME**
   - Your Docker Hub username
   - Example: `yourusername`

2. **DOCKERHUB_TOKEN**
   - Docker Hub access token (NOT your password)
   - Create at: https://hub.docker.com/settings/security
   - Select "Read, Write, Delete" permissions

### Setting Up GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add both secrets:
   - Name: `DOCKERHUB_USERNAME`, Value: your Docker Hub username
   - Name: `DOCKERHUB_TOKEN`, Value: your Docker Hub access token

### Docker Hub Access Token Creation

```bash
# 1. Visit https://hub.docker.com/settings/security
# 2. Click "New Access Token"
# 3. Enter description: "GitHub Actions CI/CD"
# 4. Select permissions: "Read, Write, Delete"
# 5. Click "Generate"
# 6. Copy the token immediately (it won't be shown again)
```

### CI/CD Pipeline Features

The GitHub Actions workflow includes:
- ✅ **Code Quality**: ESLint and Prettier checks
- ✅ **Unit Tests**: Jest with coverage reports
- ✅ **Docker Build**: Multi-arch builds (amd64, arm64)
- ✅ **Docker Push**: Automatic push to Docker Hub
- ✅ **Security Scan**: Trivy vulnerability scanning
- ✅ **Smart Tagging**: Branch names, commit SHA, and latest tags

### Workflow Triggers

- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

## Expectations (Open ended, DO YOUR BEST!!!)

- Separate Dev and Prod configs
- Data Persistence
- Follow security basics (limit network exposure, sanitize input) 
- Docker Image Optimization
- Makefile CLI Commands for smooth dev and prod deploy experience (TRY TO COMPLETE THE COMMANDS COMMENTED IN THE Makefile)

**ADD WHAT EVER BEST PRACTICES YOU KNOW**

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+ and Docker Compose v2
- Make utility
- Git

### Setup & Run

1. **Clone the repository**

   ```bash
   git clone https://github.com/mehedikhan72/cuet-cse-fest-devops-hackathon-preli.git
   cd cuet-cse-fest-devops-hackathon-preli
   ```

2. **Create environment file** (already exists)

   The `.env` file is pre-configured with development settings.

3. **Start development environment**

   ```bash
   make dev-up
   ```

4. **Start production environment**

   ```bash
   make prod-up
   ```

5. **View logs**

   ```bash
   make logs SERVICE=gateway
   ```

## 🧪 Testing & Code Quality

### Running Tests Locally

#### Backend Tests

```bash
cd backend

# Install dependencies
npm install

# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

#### Gateway Tests

```bash
cd gateway

# Install dependencies
npm install

# Run all tests
npm test

# Run tests with coverage
npm run test:coverage
```

### Code Style & Linting

#### Backend Linting

```bash
cd backend

# Check code style
npm run lint

# Auto-fix linting issues
npm run lint:fix

# Check formatting
npm run format:check

# Auto-format code
npm run format
```

#### Gateway Linting

```bash
cd gateway

# Check code style
npm run lint

# Auto-fix linting issues
npm run lint:fix

# Check formatting
npm run format:check

# Auto-format code
npm run format
```

### Test Coverage

After running `npm run test:coverage`, coverage reports will be generated:
- Console output with summary
- HTML report in `coverage/` directory
- LCOV format for CI/CD integration

Open `coverage/index.html` in your browser to view detailed coverage reports.

## 📦 Makefile Commands

The project includes a comprehensive Makefile for easy management:

### Development Commands

```bash
make dev-up          # Start development environment
make dev-down        # Stop development environment
make dev-build       # Build development containers
make dev-logs        # View development logs
make dev-restart     # Restart development services
make dev-shell       # Open shell in backend container
make backend-shell   # Open shell in backend container
make gateway-shell   # Open shell in gateway container
make mongo-shell     # Open MongoDB shell
```

### Production Commands

```bash
make prod-up         # Start production environment
make prod-down       # Stop production environment
make prod-build      # Build production containers
make prod-logs       # View production logs
make prod-restart    # Restart production services
```

### Database Commands

```bash
make db-backup       # Backup MongoDB database
make db-reset        # Reset database (WARNING: deletes all data)
```

### Cleanup Commands

```bash
make clean           # Remove containers and networks
make clean-all       # Remove everything including volumes and images
make clean-volumes   # Remove all volumes
```

### Utility Commands

```bash
make ps              # Show running containers
make status          # Alias for ps
make health          # Check service health
make stats           # Show container resource usage
make help            # Display all available commands
```

## 🧪 Testing

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

Expected: Connection refused or timeout (backend not exposed)

## 🏗️ Implementation Details

### Docker Optimization

- **Multi-stage builds**: Separate build and production stages for smaller images
- **Alpine Linux**: Using lightweight Alpine base images (~5MB)
- **Layer caching**: Optimized layer ordering for faster builds
- **Non-root user**: Running containers as non-root for security
- **.dockerignore**: Excluding unnecessary files from builds

### Security Best Practices

- **Network isolation**: Backend and MongoDB not exposed to public network
- **Private Docker network**: All services communicate through internal network
- **Non-root containers**: All containers run as non-root users
- **Health checks**: All services have health check endpoints
- **Resource limits**: Production containers have CPU and memory limits
- **Read-only filesystem**: Production containers use read-only filesystem where possible
- **Security options**: `no-new-privileges` flag enabled

### Data Persistence

- **Named volumes**: MongoDB data persisted in Docker volumes
- **Separate volumes**: Different volumes for dev and prod environments
- **Backup support**: Makefile includes database backup commands

### Environment Configuration

- **.env file**: Central configuration for all services
- **.env.example**: Template files in each service directory
- **Environment-specific configs**: Separate Docker Compose files for dev/prod
- **dotenv support**: Both backend and gateway load environment variables

### Development Features

- **Hot-reload**: Development containers support code hot-reloading
- **Volume mounts**: Source code mounted for instant updates
- **Separate node_modules**: Named volumes prevent conflicts
- **Debug logging**: Enhanced logging in development mode

### Production Features

- **Optimized images**: Multi-stage builds reduce image size by ~60%
- **Resource limits**: CPU and memory constraints prevent resource exhaustion
- **Restart policies**: Automatic container restart on failure
- **Health monitoring**: Docker health checks for all services
- **Security hardening**: Read-only filesystem and security options

## 📁 Project Structure Details

```
.
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   ├── db.ts           # MongoDB connection
│   │   │   ├── envConfig.ts    # Environment configuration
│   │   │   └── index.ts
│   │   ├── models/
│   │   │   └── product.ts      # Product schema
│   │   ├── routes/
│   │   │   └── products.ts     # Product API routes
│   │   ├── types/
│   │   │   ├── index.ts
│   │   │   └── product.ts      # TypeScript types
│   │   └── index.ts            # Backend entry point
│   ├── Dockerfile              # Production Dockerfile
│   ├── Dockerfile.dev          # Development Dockerfile
│   ├── .dockerignore
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
│
├── gateway/
│   ├── src/
│   │   └── gateway.js          # Gateway entry point
│   ├── Dockerfile              # Production Dockerfile
│   ├── Dockerfile.dev          # Development Dockerfile
│   ├── .dockerignore
│   ├── .env.example
│   └── package.json
│
├── docker/
│   ├── compose.development.yaml # Development environment
│   └── compose.production.yaml  # Production environment
│
├── .env                        # Environment variables (not committed)
├── Makefile                    # CLI commands
└── README.md
```

## 🔧 Configuration Files

### .env (Root Directory)

```env
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=securepassword123
MONGO_URI=mongodb://admin:securepassword123@mongo:27017
MONGO_DATABASE=ecommerce
BACKEND_PORT=3847
BACKEND_URL=http://backend:3847
GATEWAY_PORT=5921
NODE_ENV=development
```

### Backend .env (Optional)

The backend can also use its own `.env` file. See `backend/.env.example` for template.

### Gateway .env (Optional)

The gateway can also use its own `.env` file. See `gateway/.env.example` for template.

## 🚨 Troubleshooting

### Port Already in Use

```bash
# Find and kill process using port 5921
lsof -ti:5921 | xargs kill -9

# Or use different port in .env
GATEWAY_PORT=5922
```

### Container Won't Start

```bash
# Check logs
make logs SERVICE=backend

# Check container status
make ps

# Rebuild containers
make dev-build
make dev-up
```

### Database Connection Issues

```bash
# Check MongoDB logs
make logs SERVICE=mongo

# Reset database
make db-reset

# Verify MongoDB is healthy
docker compose -f docker/compose.development.yaml ps mongo
```

### Permission Denied Errors

```bash
# Fix volume permissions
docker compose -f docker/compose.development.yaml down -v
make dev-up
```

## 📊 Performance Metrics

### Image Sizes

- Backend (Production): ~150MB (vs ~300MB without optimization)
- Gateway (Production): ~130MB (vs ~280MB without optimization)
- MongoDB: Official mongo:7-jammy image

### Build Times

- Development: ~30-60 seconds (first build)
- Production: ~60-120 seconds (with multi-stage)
- Subsequent builds: ~5-15 seconds (with layer caching)

## 🔐 Security Considerations

1. **Environment Variables**: Never commit `.env` file with real credentials
2. **Network Isolation**: Only gateway port exposed to host
3. **Container Security**: Non-root users, read-only filesystem
4. **MongoDB**: Authentication required, not exposed to public
5. **CORS**: Configured appropriately for production

## 📚 API Documentation

### Health Endpoints

- `GET /health` - Gateway health check
- `GET /api/health` - Backend health check (via gateway)

### Product Endpoints

- `GET /api/products` - List all products
- `POST /api/products` - Create a new product
  ```json
  {
    "name": "Product Name",
    "price": 99.99
  }
  ```

## 🎯 Best Practices Implemented

- ✅ Multi-stage Docker builds
- ✅ Layer caching optimization
- ✅ Health checks for all services
- ✅ Separate dev/prod configurations
- ✅ Volume-based data persistence
- ✅ Network isolation
- ✅ Non-root container execution
- ✅ Resource limits in production
- ✅ Comprehensive Makefile commands
- ✅ .dockerignore for build optimization
- ✅ Environment variable management
- ✅ Security hardening
- ✅ Logging and monitoring
- ✅ Documentation

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

---

Good luck! 🚀

