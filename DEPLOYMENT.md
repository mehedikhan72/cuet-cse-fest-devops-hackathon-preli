# Deployment Guide

## Overview

This is a fully containerized microservices e-commerce backend with Docker and DevOps best practices.

### Architecture

- **Gateway**: Public-facing API gateway (port 5921) - Only exposed service
- **Backend**: Internal product management service (port 3847) - Not exposed
- **MongoDB**: Database (port 27017) - Not exposed

All services communicate through a private Docker network.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Make (optional but recommended)
- PowerShell or Bash

## Quick Start

### 1. Clone and Setup

```bash
cd cuet-cse-fest-devops-hackathon-preli
```

### 2. Configure Environment

The `.env` file is already configured with default values. For production, update:

```env
MONGO_INITDB_ROOT_USERNAME=your_username
MONGO_INITDB_ROOT_PASSWORD=your_secure_password
MONGO_URI=mongodb://your_username:your_secure_password@mongo:27017/ecommerce?authSource=admin
```

### 3. Start Development Environment

```bash
make dev-up
```

Or without Make:
```bash
docker compose -f docker/compose.development.yaml --env-file .env up -d
```

### 4. Start Production Environment

```bash
make prod-up
```

Or without Make:
```bash
docker compose -f docker/compose.production.yaml --env-file .env up -d
```

## Makefile Commands

### Development

```bash
make dev-up          # Start development environment
make dev-down        # Stop development environment
make dev-build       # Build development containers
make dev-logs        # View development logs
make dev-restart     # Restart development services
make dev-ps          # Show running containers
```

### Production

```bash
make prod-up         # Start production environment
make prod-down       # Stop production environment
make prod-build      # Build production containers
make prod-logs       # View production logs
make prod-restart    # Restart production services
```

### Utilities

```bash
make health          # Check service health
make mongo-shell     # Open MongoDB shell
make backend-shell   # Open shell in backend container
make gateway-shell   # Open shell in gateway container
make db-backup       # Backup database
make db-reset        # Reset database (WARNING: deletes all data)
```

### Cleanup

```bash
make clean           # Remove containers and networks
make clean-volumes   # Remove volumes (deletes data)
make clean-all       # Remove everything
```

## Testing

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

Verify backend is not directly accessible (should fail):
```bash
curl http://localhost:3847/api/products
```

This should fail because the backend is not exposed to the host network.

## Security Features

### Network Isolation
- Only Gateway is exposed to public network (port 5921)
- Backend and MongoDB are isolated in private Docker network
- No direct access to internal services

### Container Security
- Non-root user execution in production
- Read-only filesystem where possible
- Dropped Linux capabilities
- No new privileges flag enabled
- Security options applied

### Image Optimization
- Multi-stage builds for smaller images
- Alpine-based images for minimal attack surface
- Cached layers for faster builds
- Production dependencies only

### Data Persistence
- Named volumes for MongoDB data
- Survives container restarts
- Backup capabilities via Makefile

## Best Practices Implemented

### DevOps
- ✅ Separate Dev and Prod configurations
- ✅ Environment-based configuration
- ✅ Health checks on all services
- ✅ Graceful shutdown handling
- ✅ Service dependencies managed
- ✅ Resource limits (can be added via compose)

### Docker
- ✅ Multi-stage builds
- ✅ Layer caching optimization
- ✅ .dockerignore files
- ✅ Non-root user execution
- ✅ Health checks in Dockerfile
- ✅ Minimal base images (Alpine)

### Security
- ✅ Network isolation
- ✅ No unnecessary exposed ports
- ✅ Read-only containers in production
- ✅ Dropped Linux capabilities
- ✅ Security options configured
- ✅ Environment variable management

### Data Management
- ✅ Named volumes for persistence
- ✅ Backup utilities
- ✅ Database reset tools
- ✅ Data survives restarts

## Troubleshooting

### Containers won't start

```bash
# Check logs
make dev-logs

# Check container status
make dev-ps

# Rebuild containers
make dev-build
make dev-up
```

### Cannot connect to services

```bash
# Check health
make health

# Verify network
docker network ls | grep ecommerce

# Check MongoDB connection
make mongo-shell
```

### Data persistence issues

```bash
# List volumes
docker volume ls | grep ecommerce

# Inspect volume
docker volume inspect ecommerce-mongo-data-dev
```

### Port already in use

```bash
# Check what's using port 5921
netstat -ano | findstr :5921  # Windows
lsof -i :5921                 # Linux/Mac

# Stop existing containers
make dev-down
```

## Performance Optimization

### Production Build
- Multi-stage builds reduce image size by ~70%
- Only production dependencies installed
- TypeScript compiled to optimized JavaScript
- Node modules cached between builds

### Resource Limits (Optional)
Add to compose files:
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

## Monitoring

### Log Management
```bash
# Follow all logs
make dev-logs

# Follow specific service
make logs SERVICE=backend

# Limit log lines
docker compose -f docker/compose.development.yaml logs --tail=100 backend
```

### Container Stats
```bash
docker stats
```

## Backup and Recovery

### Backup Database
```bash
make db-backup
```

Backups are stored in `backups/` directory with timestamp.

### Restore Database
```bash
docker compose -f docker/compose.development.yaml exec -T mongo \
  mongorestore --username admin --password securePass123!@# \
  --authenticationDatabase admin --archive < backups/mongo-backup-TIMESTAMP.archive
```

## Development Workflow

1. **Start development environment**: `make dev-up`
2. **Make code changes** - changes auto-reload with hot-reload
3. **View logs**: `make dev-logs`
4. **Test changes**: Use curl commands above
5. **Stop environment**: `make dev-down`

## Production Deployment

1. **Update .env** with production credentials
2. **Build production images**: `make prod-build`
3. **Start production**: `make prod-up`
4. **Verify health**: `make health`
5. **Monitor logs**: `make prod-logs`

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MongoDB Docker Image](https://hub.docker.com/_/mongo)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
