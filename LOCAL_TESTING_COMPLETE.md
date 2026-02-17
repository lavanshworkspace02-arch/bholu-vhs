# Local Testing Guide - Complete

This guide shows you how to test the entire deployment pipeline locally without needing a real Kubernetes cluster.

## Quick Start (5 minutes)

### Option 1: Docker Compose (Simplest)

```bash
# Build and run everything locally
bash scripts/build-and-run.sh
```

This:
- Builds API and Worker Docker images
- Starts all services (PostgreSQL, Redis, MinIO, etc.)
- Runs health checks
- Shows logs in real-time

**Then access:**
- API: http://localhost:8080
- MinIO Console: http://localhost:9001
- Grafana: http://localhost:3000
- Jaeger: http://localhost:16686

### Option 2: Run Tests Only

```bash
# Run linting, typecheck, unit & integration tests
bash scripts/run-tests-local.sh
```

This:
- Spins up PostgreSQL and Redis
- Runs npm lint, typecheck, unit tests, integration tests
- Cleans up after

### Option 3: Full Kubernetes Cluster (kind)

```bash
# Setup local Kubernetes cluster with kind
bash scripts/setup-kind-cluster.sh
```

This:
- Creates a 3-node Kubernetes cluster (requires kind, kubectl)
- Builds Docker images
- Deploys using kustomize
- Full Kubernetes experience locally

---

## Detailed Steps

### Prerequisites

All options require Docker Desktop or Docker Engine installed.

**Option 1 & 2:** Docker only (no additional tools)
**Option 3:** Also requires [kind](https://kind.sigs.k8s.io/) and [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Option 1: Docker Compose (Full Stack)

```bash
# Method A: Run everything in one go
bash scripts/build-and-run.sh

# Method B: Step by step control
cd .

# 1. Build images
docker-compose -f docker-compose.prod.yml build

# 2. Start services
docker-compose -f docker-compose.prod.yml up -d

# 3. Check status
docker-compose -f docker-compose.prod.yml ps

# 4. View logs
docker-compose -f docker-compose.prod.yml logs -f

# 5. Stop everything
docker-compose -f docker-compose.prod.yml down
```

#### Test the running services

```bash
# Health check
curl http://localhost:8080/health

# View environment
docker-compose -f docker-compose.prod.yml exec api printenv | grep NODE

# Connect to database
docker-compose -f docker-compose.prod.yml exec postgres psql -U app -d video

# Connect to Redis
docker-compose -f docker-compose.prod.yml exec redis redis-cli

# Run migrations
docker-compose -f docker-compose.prod.yml exec api npm run prisma:migrate

# Run tests inside container
docker-compose -f docker-compose.prod.yml exec api npm test

# View logs for specific service
docker-compose -f docker-compose.prod.yml logs -f api
docker-compose -f docker-compose.prod.yml logs -f worker
```

#### Accessing Services

| Service | URL | Credentials |
|---------|-----|-------------|
| API | http://localhost:8080 | - |
| Swagger/OpenAPI | http://localhost:8080/api/docs | - |
| MinIO Console | http://localhost:9001 | minio / minio123 |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3000 | admin / admin |
| Jaeger | http://localhost:16686 | - |
| PostgreSQL | localhost:5432 | app / app |
| Redis | localhost:6379 | - |

#### Troubleshooting Docker Compose

```bash
# View all container logs with timestamps
docker-compose -f docker-compose.prod.yml logs --timestamps

# Check specific container
docker-compose -f docker-compose.prod.yml logs api --tail=50

# Inspect running container
docker inspect video-api

# Resource usage
docker stats

# Restart a specific service
docker-compose -f docker-compose.prod.yml restart api

# Force rebuild (ignore cache)
docker-compose -f docker-compose.prod.yml build --no-cache

# Clean up everything (including volumes)
docker-compose -f docker-compose.prod.yml down -v
docker system prune -a
```

---

### Option 2: Run Tests Locally

```bash
# Automated test execution
bash scripts/run-tests-local.sh
```

This script:
1. Starts PostgreSQL and Redis in containers
2. Installs dependencies (`npm install`)
3. Runs linting (`npm run lint`)
4. Runs TypeScript check (`npm run typecheck`)
5. Runs unit tests (`npm run test:unit`)
6. Runs integration tests (`npm run test:integration`)
7. Cleans up containers

#### Or run tests manually

```bash
# 1. Start test services
docker-compose up -d postgres redis

# 2. Wait for services
sleep 5

# 3. Install deps
npm install

# 4. Run tests
npm run lint
npm run typecheck
npm run test:unit

# 5. Integration tests (needs database)
export DATABASE_URL=postgresql://app:app@localhost:5432/video
export REDIS_URL=redis://localhost:6379
npm run test:integration

# 6. Stop services
docker-compose down
```

---

### Option 3: Local Kubernetes with kind

#### Prerequisites

```bash
# macOS
brew install kind kubectl

# Linux (from github releases)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Windows (with chocolatey)
choco install kind kubectl
```

#### Setup Cluster

```bash
# Automated setup
bash scripts/setup-kind-cluster.sh
```

This creates a 3-node cluster and deploys the app.

#### Or setup manually

```bash
# 1. Create cluster
kind create cluster --name video-ingest

# 2. Build images
docker build -t video-ingest-api:latest -f infra/docker/api.Dockerfile .
docker build -t video-ingest-worker:latest -f infra/docker/worker.Dockerfile .

# 3. Load into cluster
kind load docker-image video-ingest-api:latest --name video-ingest
kind load docker-image video-ingest-worker:latest --name video-ingest

# 4. Deploy
kubectl apply -k infra/k8s/overlays/development

# 5. Watch deployment
kubectl get pods -n video-app --watch

# 6. Port forward
kubectl port-forward -n video-app svc/api-service 8080:80 &

# 7. Test
curl http://localhost:8080/health

# 8. View logs
kubectl logs -n video-app deployment/dev-api-deployment -f

# 9. Cleanup
kind delete cluster --name video-ingest
```

---

## Testing the Pipeline Locally

### Simulate GitHub Actions Workflow

```bash
# 1. Run the full test suite
bash scripts/run-tests-local.sh

# 2. Build images (simulates build job)
docker build -t video-ingest-api:local -f infra/docker/api.Dockerfile .
docker build -t video-ingest-worker:local -f infra/docker/worker.Dockerfile .

# 3. Deploy to local Kubernetes (simulates deploy job)
bash scripts/setup-kind-cluster.sh

# 4. Run integration tests against deployed services
kubectl port-forward -n video-app svc/api-service 8080:80 &
curl http://localhost:8080/health
```

---

## Common Scenarios

### Scenario 1: I want to test a code change

```bash
# 1. Make code change
# 2. Run tests
bash scripts/run-tests-local.sh

# 3. If tests pass, rebuild and run
docker-compose -f docker-compose.prod.yml build --no-cache api
docker-compose -f docker-compose.prod.yml up -d api

# 4. Test the change
curl http://localhost:8080/health
docker-compose -f docker-compose.prod.yml logs api
```

### Scenario 2: I want to verify the Dockerfile builds correctly

```bash
# Build API image
docker build -t video-ingest-api:test -f infra/docker/api.Dockerfile .

# Test the image
docker run -it video-ingest-api:test /bin/sh

# Build Worker image
docker build -t video-ingest-worker:test -f infra/docker/worker.Dockerfile .
```

### Scenario 3: I want to test the full deployment

```bash
# Option A: Docker Compose (fast)
bash scripts/build-and-run.sh

# Option B: Kubernetes (full experience)
bash scripts/setup-kind-cluster.sh

# Monitor
docker stats  # For Docker Compose
kubectl top pods -n video-app  # For Kubernetes
```

### Scenario 4: I want to test a database migration

```bash
# Start stack
docker-compose -f docker-compose.prod.yml up -d

# Run migrations
docker-compose -f docker-compose.prod.yml exec api npm run prisma:migrate

# Verify
docker-compose -f docker-compose.prod.yml exec postgres psql -U app -d video -c "\dt"
```

### Scenario 5: I want to test without rebuilding images

```bash
# Use pre-built images from docker-compose.prod.yml
docker-compose -f docker-compose.prod.yml pull

# Or use development compose file (if available)
docker-compose up -d

# Start fresh
docker-compose down -v
docker-compose up -d
```

---

## Monitoring & Debugging

### Logs

```bash
# Docker Compose
docker-compose -f docker-compose.prod.yml logs -f
docker-compose -f docker-compose.prod.yml logs -f api

# Kubernetes
kubectl logs -n video-app -l app=api -f
kubectl logs -n video-app -l app=worker -f
kubectl logs -n video-app deployment/dev-api-deployment
```

### Resource Usage

```bash
# Docker
docker stats

# Kubernetes
kubectl top nodes
kubectl top pods -n video-app
kubectl describe pod <pod-name> -n video-app
```

### Network Connectivity

```bash
# Docker Compose - test service to service
docker-compose -f docker-compose.prod.yml exec api curl http://postgres:5432/
docker-compose -f docker-compose.prod.yml exec api curl http://redis:6379/

# Kubernetes - test service to service
kubectl exec -it -n video-app deployment/dev-api-deployment -- curl http://postgres:5432/
```

### Container/Pod Status

```bash
# Docker
docker ps -a
docker inspect <container-id>

# Kubernetes
kubectl get pods -n video-app -o wide
kubectl describe pod <pod-name> -n video-app
kubectl get events -n video-app
```

---

## Performance Testing

### Load Testing with curl

```bash
# Simple load test
for i in {1..100}; do
  curl -s http://localhost:8080/health &
done
wait

# With Apache Bench (if installed)
ab -n 1000 -c 10 http://localhost:8080/health
```

### Resource Limits in Docker Compose

```bash
# Check current usage
docker stats

# Set limits (in docker-compose.prod.yml)
# services:
#   api:
#     deploy:
#       resources:
#         limits:
#           cpus: '1'
#           memory: 512M
#         reservations:
#           cpus: '0.5'
#           memory: 256M
```

---

## Cleanup

```bash
# Stop Docker Compose stack
docker-compose -f docker-compose.prod.yml down

# Remove volumes
docker-compose -f docker-compose.prod.yml down -v

# Remove local images
docker rmi video-ingest-api video-ingest-worker

# Remove kind cluster
kind delete cluster --name video-ingest

# Clean up Docker system (unused images, containers, volumes)
docker system prune -a
```

---

## Next Steps

1. **For local development:** Use the original `docker-compose.yml` with volume mounts for hot reload
2. **For CI testing:** Use `scripts/run-tests-local.sh` in your own CI
3. **For full pipeline:** Use `scripts/setup-kind-cluster.sh` to test Kubernetes deployments
4. **For production deployment:** See `DEPLOYMENT_PIPELINE.md`

Let me know if you have any questions!
