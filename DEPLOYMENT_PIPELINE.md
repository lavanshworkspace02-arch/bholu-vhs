# Deployment Pipeline Summary

## Overview

This deployment pipeline provides a complete CI/CD infrastructure for the Video Ingest Microservice with support for development, staging, and production environments.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Repository                            │
│  • Commits trigger automated workflows                            │
│  • Pull requests run tests                                        │
│  • Tags trigger production deployments                            │
└────────────────┬────────────────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────────────────┐
│              GitHub Actions (CI/CD Pipeline)                     │
├─────────────────────────────────────────────────────────────────┤
│  ✓ Test Job                                                      │
│    - Lint & typecheck                                            │
│    - Unit tests                                                  │
│    - Integration tests (with postgres, redis)                    │
│                                                                   │
│  ✓ Build Job (Matrix: api, worker)                              │
│    - Build multi-stage Docker images                             │
│    - Push to GitHub Container Registry                           │
│    - Cache layers via BuildKit                                   │
│                                                                   │
│  ✓ Deploy Dev (on: develop branch)                              │
│  ✓ Deploy Staging (on: main branch)                             │
│  ✓ Deploy Prod (on: git tags)                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
┌───▼──┐    ┌────▼───┐   ┌───▼─────┐
│  Dev │    │Staging │   │Production│
│ K8s  │    │  K8s   │   │   K8s    │
└──────┘    └────────┘   └──────────┘
```

## CI/CD Workflow (.github/workflows/deploy.yml)

### Test Stage
- Runs on all commits and PRs
- PostgreSQL + Redis services
- Linting, type checking, unit & integration tests
- **Artifact**: Test reports in Jest JUnit format

### Build Stage (requires: test)
- Builds separate images for api and worker
- Multi-stage Dockerfile with BuildKit caching
- Uses GitHub Container Registry (ghcr.io)
- Tags: branch, semantic version, commit SHA
- **Artifacts**: Container images pushed to registry

### Deploy Dev (requires: build, on: develop branch)
- Applies `infra/k8s/overlays/development` using kustomize
- Minimal resource constraints for dev environment
- 1 replica each for api and worker

### Deploy Staging (requires: build, on: main branch)
- Applies `infra/k8s/overlays/staging` using kustomize
- 2 replicas for high-availability testing
- Full resource limits configured

### Deploy Prod (requires: build, on: git tags)
- Applies `infra/k8s/overlays/production` using kustomize
- 3 replicas with pod disruption budgets
- Slack notification on success
- **Trigger**: Create a git tag: `git tag v1.0.0 && git push origin v1.0.0`

## Kubernetes Structure (infra/k8s/)

### Base Configuration (base/)
- **infrastructure.yaml**: PostgreSQL, Redis, MinIO, ClamAV (stateless services)
- **api.yaml**: API deployment with 3 replicas, HPA (CPU/memory-based), LoadBalancer service
- **worker.yaml**: Worker deployment with 2 replicas, HPA for video processing jobs
- **networking.yaml**: Network policies, Ingress, Pod Disruption Budgets
- **backup.yaml**: CronJob for daily database backups at 2 AM

### Environment Overlays
- **development/**: Low resource requests, 1 replica, lax scaling (1-2 pods)
- **staging/**: Medium resources, 2 replicas, moderate scaling (2-5 pods)
- **production/**: Full resources, 3 replicas, aggressive scaling (3-15 pods), required pod affinity

## Docker Image Optimization

### Multi-Stage Builds
```dockerfile
# Stage 1: Build dependencies (cached)
# Stage 2: Build application code
# Stage 3: Runtime (stripped, small)
```

### BuildKit Caching
- `--mount=type=cache` for npm install
- Separate dependencies layer from app code
- External cache via GitHub Actions (type=gha)
- Image size: ~400MB api, ~600MB worker (vs 1GB+ single-stage)

### Security
- Non-root user (uid: 1000)
- Read-only root filesystem
- Health checks included
- Network policies restrict traffic

## Environment Variables

### Development
```env
NODE_ENV=development
ALLOW_ANON=true
DEBUG=true
JWT_SECRET=dev-secret-key-change-in-prod
DATABASE_PASSWORD=dev-password
```

### Staging
```env
NODE_ENV=staging
ALLOW_ANON=false
QA_SAMPLING_RATE=0.1
```

### Production
```env
NODE_ENV=production
ALLOW_ANON=false
QA_SAMPLING_RATE=1.0
```

## Resource Limits

| Environment | API CPU/Mem | Worker CPU/Mem | Min Replicas | Max Replicas |
|---|---|---|---|---|
| Dev | 250m/256Mi | 500m/512Mi | 1 | 2 |
| Staging | 500m/512Mi | 1000m/1Gi | 2 | 5 |
| Prod | 500m/512Mi | 1000m/1Gi | 3 | 10-15 |

## Horizontal Pod Autoscaling (HPA)

### API
- Scales on: CPU 70% (dev 70%, staging 70%, prod 60%)
- Scales on: Memory 80% (dev 80%, staging 80%, prod 75%)

### Worker
- Scales on: CPU 75% (prod 65%)
- Scales on: Memory 85% (prod 80%)

## Database Persistence

- **PostgreSQL**: StatefulSet with PVC (10Gi default)
- **Redis**: In-memory with RDB snapshots
- **MinIO**: S3-compatible with PVC (50Gi default)
- **Daily Backups**: CronJob at 2 AM UTC, 30-day retention

## Deployment Commands

### Local/Dev
```bash
# Apply development environment
kubectl apply -k infra/k8s/overlays/development

# Check rollout status
kubectl rollout status deployment/dev-api-deployment -n video-app

# View logs
kubectl logs -n video-app -l app=api -f
```

### Production
```bash
# Requires: valid kubeconfig and prod secrets configured
# Trigger: Push a git tag
git tag v1.0.0
git push origin v1.0.0

# Monitor deployment
kubectl get pods -n video-app
kubectl describe hpa -n video-app
```

## Monitoring & Observability

- **Prometheus**: Scrapes /metrics endpoints (enabled via annotations)
- **Grafana**: Visualization dashboard (admin password required)
- **Jaeger**: Distributed tracing via OpenTelemetry (4317 OTLP endpoint)
- **Pod Events**: `kubectl get events -n video-app`

## Disaster Recovery

### Backup Strategy
- Daily automatic backups (CronJob at 2 AM)
- PostgreSQL: Full dump compressed
- Redis: RDB snapshots
- MinIO: Tar archive of all buckets
- Retention: 30 days

### Restore PostgreSQL
```bash
kubectl cp ./postgres_YYYYMMDD_HHMMSS.sql.gz \
  video-app/postgres-0:/tmp/

kubectl exec -it video-app/postgres-0 -- \
  bash -c "gunzip < /tmp/postgres_YYYYMMDD_HHMMSS.sql.gz | psql -U app -d video"
```

### Rollback
```bash
# Rollback to previous deployment revision
kubectl rollout undo deployment/api-deployment -n video-app
kubectl rollout undo deployment/worker-deployment -n video-app

# View rollout history
kubectl rollout history deployment/api-deployment -n video-app
```

## GitHub Secrets (Required)

| Secret | Purpose |
|---|---|
| `DEV_KUBECONFIG` | Base64-encoded dev cluster kubeconfig |
| `STAGING_KUBECONFIG` | Base64-encoded staging kubeconfig |
| `PROD_KUBECONFIG` | Base64-encoded production kubeconfig |
| `SLACK_WEBHOOK_URL` | Optional: Slack deployment notifications |

### Encode kubeconfig
```bash
base64 -w 0 ~/.kube/config > kubeconfig.b64
# Copy contents into GitHub Secrets
```

## Production Checklist

- [ ] All secrets configured (JWT, DB password, S3 credentials)
- [ ] Ingress hostname configured (update `api.example.com`)
- [ ] TLS certificate provisioned (cert-manager + Let's Encrypt)
- [ ] Network policies enforced
- [ ] Monitoring & alerting rules configured
- [ ] Backup CronJob tested and validated
- [ ] Pod Disruption Budgets in place
- [ ] Node affinity labels applied
- [ ] Resource quotas enforced at namespace level
- [ ] RBAC policies restricted
- [ ] Runbook documentation completed
- [ ] Disaster recovery procedures tested

## Troubleshooting

### Deployment stuck on CrashLoopBackOff
```bash
kubectl describe pod <pod-name> -n video-app
kubectl logs <pod-name> -n video-app --previous
```

### High memory usage
```bash
kubectl top pod -n video-app
kubectl describe pod <pod-name> -n video-app  # Check limits
```

### Network connectivity issues
```bash
kubectl get networkpolicies -n video-app
kubectl describe networkpolicy <policy-name> -n video-app
```

### Database migration failures
```bash
# Run migrations manually
kubectl exec -it deployment/api-deployment -n video-app -- \
  npm run prisma:migrate

# Check migration status
kubectl exec -it deployment/api-deployment -n video-app -- \
  npx prisma migrate status
```

## References

- [kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Docker buildx](https://docs.docker.com/build/overview/)
- [GitHub Actions](https://docs.github.com/en/actions)
