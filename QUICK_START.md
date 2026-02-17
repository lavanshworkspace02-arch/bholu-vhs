# Quick Start - Choose Your Path

## 🚀 Fastest Way (5 minutes)

### Path 1: Just Run the Stack

```bash
bash scripts/build-and-run.sh
```

**What it does:**
- Builds Docker images
- Starts all services (API, database, cache, etc.)
- Runs health checks
- Shows real-time logs

**Then access:**
- API: http://localhost:8080
- MinIO: http://localhost:9001
- Grafana: http://localhost:3000

**To stop:**
```bash
docker-compose -f docker-compose.prod.yml down
```

---

## 🧪 Test Everything

### Path 2: Run Tests

```bash
bash scripts/run-tests-local.sh
```

**What it does:**
- Lints code
- Type checks TypeScript
- Runs unit tests
- Runs integration tests
- Cleans up

**Result:** ✓ All tests passed

---

## ☸️ Full Kubernetes (Advanced)

### Path 3: Test in Kubernetes

```bash
bash scripts/setup-kind-cluster.sh
```

**What it does:**
- Creates local 3-node Kubernetes cluster
- Builds and loads images
- Deploys all services
- Shows access URLs

**Then test:**
```bash
kubectl get pods -n video-app
kubectl logs -n video-app deployment/dev-api-deployment -f
```

**To stop:**
```bash
kind delete cluster --name video-ingest
```

---

## 📋 Manual Step-by-Step

### Step 1: Build Images

```bash
docker build -t video-ingest-api:latest -f infra/docker/api.Dockerfile .
docker build -t video-ingest-worker:latest -f infra/docker/worker.Dockerfile .
```

### Step 2: Start Services

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Step 3: Check Status

```bash
docker-compose -f docker-compose.prod.yml ps
```

### Step 4: View Logs

```bash
docker-compose -f docker-compose.prod.yml logs -f api
```

### Step 5: Test API

```bash
curl http://localhost:8080/health
```

### Step 6: Stop Stack

```bash
docker-compose -f docker-compose.prod.yml down
```

---

## 🔧 Common Commands

### View logs
```bash
docker-compose -f docker-compose.prod.yml logs -f
docker-compose -f docker-compose.prod.yml logs -f api
```

### Connect to database
```bash
docker-compose -f docker-compose.prod.yml exec postgres psql -U app -d video
```

### Run migrations
```bash
docker-compose -f docker-compose.prod.yml exec api npm run prisma:migrate
```

### Run tests
```bash
docker-compose -f docker-compose.prod.yml exec api npm test
```

### View container status
```bash
docker ps
docker stats
```

### Cleanup everything
```bash
docker-compose -f docker-compose.prod.yml down -v
docker system prune -a
```

---

## ✅ Verification Checklist

- [ ] Docker running (`docker ps` shows no errors)
- [ ] Stack started (`docker-compose ps` shows running services)
- [ ] API responding (`curl http://localhost:8080/health`)
- [ ] Database connected (`docker-compose exec postgres psql -U app -d video`)
- [ ] Tests passing (`npm test` or `bash scripts/run-tests-local.sh`)

---

## 📚 Documentation

- **LOCAL_TESTING_COMPLETE.md** - Detailed guide for all options
- **LOCAL_TESTING.md** - Docker Compose guide
- **DEPLOYMENT_PIPELINE.md** - Full pipeline overview
- **DEPLOYMENT_QUICK_REF.sh** - kubectl quick reference

---

## Need Help?

**Docker won't start?**
```bash
docker ps  # Check if Docker is running
```

**Port already in use?**
```bash
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows
```

**Container crashed?**
```bash
docker-compose -f docker-compose.prod.yml logs api
```

**Out of disk space?**
```bash
docker system prune -a
```

---

## 🎯 Next Steps

After local testing:

1. **Make code changes** → Run tests → Commit → Push
2. **Deployment** → GitHub Actions tests → Builds → Deploys to dev/staging/prod
3. **Production** → Tag a release → Automatic production deployment

That's it! Your full CI/CD pipeline is ready.
