# Docker Optimization Guide

## Image Size Optimization

### Backend Production Image
- **Base Image**: node:20-alpine (smallest official Node.js image)
- **Multi-stage Build**: Builder stage separate from runtime
- **Production Dependencies Only**: Using `npm ci --only=production`
- **Layer Caching**: Package files copied before source code

### Gateway Production Image
- **Base Image**: node:20-alpine
- **Minimal Layers**: Optimized layer ordering
- **Cache Cleaning**: `npm cache clean --force`
- **Non-root User**: Security and best practices

## Build Performance

### Caching Strategy
1. Copy package.json first
2. Install dependencies (cached if package.json unchanged)
3. Copy source code last (changes frequently)

### Build Commands
```bash
# Build with cache
make prod-build

# Build without cache (fresh build)
make prod-build ARGS="--no-cache"

# Build specific service
make prod-build backend
```

## Runtime Optimization

### Development
- **Hot Reload**: Code changes auto-reload
- **Volume Mounts**: Source code mounted as read-only
- **Named Volumes**: node_modules persisted for faster startup
- **Development Tools**: Included for debugging

### Production
- **Read-only Filesystem**: Enhanced security
- **tmpfs**: Temporary files in memory
- **No Development Dependencies**: Smaller image
- **Health Checks**: Automatic restart on failure

## Network Optimization

### Docker Network
- **Bridge Network**: Efficient internal communication
- **DNS Resolution**: Services discoverable by name
- **Network Isolation**: Private network for security

### Service Communication
- **Internal Network**: No external exposure
- **Gateway Pattern**: Single entry point
- **Service Discovery**: Automatic DNS resolution

## Volume Performance

### MongoDB Volumes
- **Named Volumes**: Better performance than bind mounts
- **Persistence**: Data survives container restarts
- **Backup Strategy**: Regular backups recommended

### Node Modules Volumes (Dev)
- **Separate Volumes**: Prevents mounting from host
- **Platform Consistency**: Native compiled modules work correctly
- **Faster Startup**: Cached dependencies

## Memory and CPU

### Resource Limits (Optional)
Add to compose files for production:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
  
  gateway:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M
  
  mongo:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
        reservations:
          cpus: '1.0'
          memory: 512M
```

## Monitoring Performance

### Container Stats
```bash
docker stats
```

### Logs Performance
```bash
# Limit log size
docker compose -f docker/compose.production.yaml up -d \
  --log-opt max-size=10m \
  --log-opt max-file=3
```

## Production Checklist

- [ ] Multi-stage builds enabled
- [ ] Production dependencies only
- [ ] Image size < 200MB (backend), < 150MB (gateway)
- [ ] Health checks configured
- [ ] Resource limits set
- [ ] Logging configured
- [ ] Volumes for persistence
- [ ] Network isolation enabled
- [ ] Security options applied
- [ ] Non-root user execution

## Size Comparison

### Before Optimization
- Backend: ~1.2GB (full Node.js image + dev dependencies)
- Gateway: ~1.1GB (full Node.js image)

### After Optimization
- Backend: ~180MB (Alpine + production only)
- Gateway: ~150MB (Alpine + minimal dependencies)

**Total Savings: ~2GB per deployment**

## Further Optimizations

### 1. Distroless Images
Consider using distroless images for even smaller size:
```dockerfile
FROM gcr.io/distroless/nodejs20-debian11
```

### 2. Dependency Pruning
Use tools like `npm prune` and `depcheck` to remove unused dependencies.

### 3. Build Cache
Enable BuildKit for better caching:
```bash
DOCKER_BUILDKIT=1 docker build .
```

### 4. Layer Optimization
Combine RUN commands to reduce layers:
```dockerfile
RUN apk add --no-cache git curl && \
    npm ci --only=production && \
    npm cache clean --force
```

## Performance Metrics

### Startup Time
- **Development**: ~10-15 seconds
- **Production**: ~5-8 seconds

### Build Time (with cache)
- **Backend**: ~30 seconds
- **Gateway**: ~20 seconds

### Build Time (without cache)
- **Backend**: ~2-3 minutes
- **Gateway**: ~1-2 minutes

## Best Practices

1. **Use .dockerignore**: Exclude unnecessary files
2. **Order Layers**: Least changing to most changing
3. **Combine Commands**: Reduce layer count
4. **Clean Cache**: Remove temporary files
5. **Alpine Base**: Smallest official images
6. **Multi-stage**: Separate build and runtime
7. **Production Only**: No dev dependencies in production
8. **Health Checks**: Enable auto-restart
9. **Named Volumes**: Better performance
10. **Network Optimization**: Private networks for security
