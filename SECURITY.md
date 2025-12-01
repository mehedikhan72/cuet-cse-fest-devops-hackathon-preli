# Security Policy

## Container Security

### Production Containers
- Run as non-root user (UID 1001)
- Read-only filesystem enabled
- All Linux capabilities dropped except NET_BIND_SERVICE
- No new privileges flag enabled
- tmpfs for temporary files

### Network Security
- Backend and MongoDB are NOT exposed to host network
- Only Gateway is accessible (port 5921)
- Private Docker network for internal communication
- Network isolation enforced

## Environment Variables

Never commit the following to version control:
- `.env`
- `MONGO_INITDB_ROOT_USERNAME`
- `MONGO_INITDB_ROOT_PASSWORD`
- `MONGO_URI`

Always use strong passwords:
- Minimum 16 characters
- Mix of uppercase, lowercase, numbers, and symbols
- Unique for each environment

## MongoDB Security

- Authentication enabled (authSource=admin)
- Root credentials required for access
- Database access restricted to backend service only
- No direct external access

## Docker Security

### Image Security
- Using official images from Docker Hub
- Alpine-based images for minimal attack surface
- Regular security updates recommended
- Multi-stage builds to minimize image size

### Runtime Security
```yaml
security_opt:
  - no-new-privileges:true
read_only: true
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

## Best Practices

1. **Update Dependencies**: Regularly update npm packages
2. **Scan Images**: Use `docker scan` to check for vulnerabilities
3. **Rotate Credentials**: Change database passwords periodically
4. **Monitor Logs**: Review logs for suspicious activity
5. **Backup Data**: Regular database backups
6. **Limit Resources**: Set CPU and memory limits in production
7. **Use Secrets**: Consider Docker Swarm secrets or Kubernetes secrets for production

## Reporting Security Issues

If you discover a security vulnerability, please report it privately.
