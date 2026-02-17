# Local Testing - Complete Index

## 🎯 START HERE

Choose your testing approach:

### ⚡ **Fastest (5 min) - Docker Compose Full Stack**
```bash
bash scripts/build-and-run.sh
```
- Builds images
- Starts all services
- Shows logs in real-time

📖 **Guide:** [QUICK_START.md](QUICK_START.md) - Path 1

---

### 🧪 **Tests Only (3 min) - No Services**
```bash
bash scripts/run-tests-local.sh
```
- Runs lint, typecheck, unit & integration tests
- Cleans up after

📖 **Guide:** [QUICK_START.md](QUICK_START.md) - Path 2

---

### ☸️ **Full Kubernetes (10 min) - kind Cluster**
```bash
bash scripts/setup-kind-cluster.sh
```
- Creates local 3-node K8s cluster
- Deploys using kustomize
- Full production-like environment

📖 **Guide:** [QUICK_START.md](QUICK_START.md) - Path 3

---

## 📚 Detailed Guides

| Document | Purpose | Audience |
|----------|---------|----------|
| **QUICK_START.md** | 3 quick paths to testing | Everyone - start here |
| **LOCAL_TESTING.md** | Docker Compose reference | Docker Compose users |
| **LOCAL_TESTING_COMPLETE.md** | All options detailed | Advanced users |
| **DEPLOYMENT_PIPELINE.md** | Full pipeline overview | DevOps/SRE |
| **DEPLOYMENT_QUICK_REF.sh** | kubectl commands | Kubernetes users |
| **infra/DEPLOYMENT.md** | kubectl recipes | Kubernetes users |

---

## 🔧 Scripts Available

### Quick Start Scripts
| Script | Purpose | Runtime |
|--------|---------|---------|
| `bash scripts/build-and-run.sh` | Full stack + logs | 2-5 min |
| `bash scripts/run-tests-local.sh` | Run all tests | 3-10 min |
| `bash scripts/setup-kind-cluster.sh` | K8s cluster setup | 10-15 min |
| `bash scripts/backup.sh` | Database backup | 1 min |

### Utility Scripts
| Script | Purpose |
|--------|---------|
| `bash QUICK_START.md` | Show this overview |
| `bash DEPLOYMENT_QUICK_REF.sh` | kubectl cheat sheet |
| `bash scripts/setup-pipeline.sh` | Production setup wizard |

---

## 📋 Quick Command Reference

### Start Stack
```bash
# Automated (recommended)
bash scripts/build-and-run.sh

# Manual
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

### Check Status
```bash
docker-compose -f docker-compose.prod.yml ps
docker stats
```

### View Logs
```bash
docker-compose -f docker-compose.prod.yml logs -f
docker-compose -f docker-compose.prod.yml logs -f api
```

### Test API
```bash
curl http://localhost:8080/health
```

### Stop Stack
```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml down -v  # with cleanup
```

---

## ✅ Verification

After starting the stack:

- [ ] Docker containers running: `docker ps`
- [ ] API healthy: `curl http://localhost:8080/health`
- [ ] Database up: `docker-compose -f docker-compose.prod.yml exec postgres psql -U app -d video`
- [ ] Logs clean: `docker-compose -f docker-compose.prod.yml logs` (no ERROR)

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Port in use | `lsof -i :8080` or `netstat -ano \| findstr :8080` |
| Container won't start | `docker-compose logs api` |
| Out of memory | `docker stats` to check usage |
| Out of disk | `docker system prune -a` |
| Network issue | `docker inspect video-api` |

---

## 🎯 Common Workflows

### I want to test my code changes
1. Make changes
2. `bash scripts/run-tests-local.sh`
3. If pass → `docker-compose -f docker-compose.prod.yml build --no-cache api`
4. `docker-compose -f docker-compose.prod.yml up api -d`
5. Test with `curl http://localhost:8080/health`

### I want to verify Dockerfile builds
```bash
docker build -t test-api -f infra/docker/api.Dockerfile .
docker run -it test-api /bin/sh
```

### I want to test the full pipeline
```bash
bash scripts/run-tests-local.sh  # Tests pass
bash scripts/build-and-run.sh     # Stack runs
# Verify services working
docker-compose -f docker-compose.prod.yml down
```

### I want to test Kubernetes deployment
```bash
bash scripts/setup-kind-cluster.sh
# Cluster created and deployed
kubectl get pods -n video-app
kind delete cluster --name video-ingest
```

---

## 📚 What's Included

### Docker Compose
- `docker-compose.yml` - Development (original)
- `docker-compose.prod.yml` - Production-optimized

### GitHub Actions
- `.github/workflows/deploy.yml` - Full CI/CD pipeline

### Kubernetes
- `infra/k8s/base/` - Base configurations
- `infra/k8s/overlays/development/` - Dev environment
- `infra/k8s/overlays/staging/` - Staging environment
- `infra/k8s/overlays/production/` - Production environment

### Documentation
- `QUICK_START.md` - Overview and quick paths
- `LOCAL_TESTING.md` - Docker Compose guide
- `LOCAL_TESTING_COMPLETE.md` - Comprehensive guide
- `DEPLOYMENT_PIPELINE.md` - Pipeline documentation
- `DEPLOYMENT_QUICK_REF.sh` - kubectl reference

### Scripts
- `scripts/build-and-run.sh` - Full stack
- `scripts/run-tests-local.sh` - Test suite
- `scripts/setup-kind-cluster.sh` - Kubernetes cluster
- `scripts/backup.sh` - Database backup
- `scripts/setup-pipeline.sh` - Production setup

---

## 🚀 Next Steps

1. **Test locally** → Choose a path above and run the script
2. **Make changes** → Edit code and test
3. **Commit & push** → GitHub Actions automatically tests
4. **Deploy** → Automatic deployments to dev/staging/prod based on branch/tag

---

## 💡 Tips

- **First time?** Start with `bash scripts/build-and-run.sh`
- **Quick tests?** Use `bash scripts/run-tests-local.sh`
- **Full experience?** Use `bash scripts/setup-kind-cluster.sh`
- **Stuck?** Check the troubleshooting section above
- **Docker Desktop?** GUI available at http://localhost (on some systems)

---

## 📞 Support

- Check logs: `docker-compose logs -f`
- See pods: `kubectl get pods -n video-app`
- Describe pod: `kubectl describe pod <name> -n video-app`
- Clean up: `docker system prune -a` or `kind delete cluster --name video-ingest`

---

**Ready to test? Pick a path above and run the script!** ⚡
