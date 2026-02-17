#!/bin/bash

# Local Testing Guide - Quick Start with Docker Compose

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_header() {
  echo -e "\n${BLUE}===================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}===================================${NC}\n"
}

log_info() {
  echo -e "${GREEN}✓${NC} $1"
}

log_step() {
  echo -e "${YELLOW}→${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

main() {
  clear
  cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║    LOCAL TESTING - Video Ingest Microservice              ║
║    (Docker Compose - No Kubernetes required)              ║
╚════════════════════════════════════════════════════════════╝
EOF
  
  log_header "Quick Start Guide"
  
  echo "This guide runs the entire stack locally using Docker Compose."
  echo "No Kubernetes cluster needed!"
  echo ""
  
  echo "Prerequisites:"
  echo "  ✓ Docker Desktop or Docker Engine"
  echo "  ✓ docker-compose (included with Docker Desktop)"
  echo "  ✓ 4GB+ RAM available"
  echo ""
  
  log_header "STEP 1: Build Images (Optional - speeds up first run)"
  echo "Build container images locally instead of pulling:"
  echo ""
  log_step "docker-compose -f docker-compose.prod.yml build"
  echo ""
  echo "⏱  This takes 5-10 minutes on first run (caches subsequent builds)"
  echo ""
  
  log_header "STEP 2: Start the Stack"
  echo "Launch all services:"
  echo ""
  log_step "docker-compose -f docker-compose.prod.yml up"
  echo ""
  echo "Or run in background:"
  log_step "docker-compose -f docker-compose.prod.yml up -d"
  echo ""
  
  log_header "STEP 3: Wait for Services"
  echo "Check health status (in another terminal):"
  echo ""
  log_step "docker-compose -f docker-compose.prod.yml ps"
  echo ""
  echo "Expected output:"
  cat << 'DOCKER_PS'
NAME                COMMAND                  SERVICE      STATUS
video-postgres      "postgres"               postgres     healthy
video-redis         "redis-server"           redis        healthy
video-minio         "server /data"           minio        healthy
video-api           "node --enable-source"   api          healthy
video-worker        "node --enable-source"   worker       healthy
DOCKER_PS
  echo ""
  
  log_header "STEP 4: Test the API"
  echo "Health check:"
  log_step "curl http://localhost:8080/health"
  echo ""
  
  echo "OpenAPI docs (if available):"
  log_step "open http://localhost:8080/api/docs"
  echo ""
  
  log_header "STEP 5: View Logs"
  echo "All logs:"
  log_step "docker-compose -f docker-compose.prod.yml logs -f"
  echo ""
  
  echo "API logs only:"
  log_step "docker-compose -f docker-compose.prod.yml logs -f api"
  echo ""
  
  echo "Worker logs only:"
  log_step "docker-compose -f docker-compose.prod.yml logs -f worker"
  echo ""
  
  log_header "STEP 6: Access Services"
  cat << 'SERVICES'
Service           URL/Port            Credentials
────────────────────────────────────────────────────────────
API               http://localhost:8080
Swagger UI        http://localhost:8080/api/docs
MinIO Console     http://localhost:9001     minio / minio123
Prometheus        http://localhost:9090
Grafana           http://localhost:3000     admin / admin
Jaeger UI         http://localhost:16686
PostgreSQL        localhost:5432            app / app
Redis             localhost:6379
SERVICES
  echo ""
  
  log_header "STEP 7: Stop the Stack"
  echo "Stop all containers (keeps data):"
  log_step "docker-compose -f docker-compose.prod.yml down"
  echo ""
  
  echo "Stop and remove volumes (clean slate):"
  log_step "docker-compose -f docker-compose.prod.yml down -v"
  echo ""
  
  log_header "COMMON TASKS"
  
  echo "Run database migrations:"
  log_step "docker-compose -f docker-compose.prod.yml exec api npm run prisma:migrate"
  echo ""
  
  echo "Connect to PostgreSQL:"
  log_step "docker-compose -f docker-compose.prod.yml exec postgres psql -U app -d video"
  echo ""
  
  echo "Connect to Redis CLI:"
  log_step "docker-compose -f docker-compose.prod.yml exec redis redis-cli"
  echo ""
  
  echo "View environment variables:"
  log_step "docker-compose -f docker-compose.prod.yml exec api printenv | grep -E '(NODE_|DATABASE|REDIS|S3)'"
  echo ""
  
  echo "Rebuild a single service:"
  log_step "docker-compose -f docker-compose.prod.yml build --no-cache api"
  echo ""
  
  log_header "TROUBLESHOOTING"
  
  echo "Container exiting with error?"
  log_step "docker-compose -f docker-compose.prod.yml logs api"
  echo ""
  
  echo "Port already in use?"
  log_step "lsof -i :8080  # (macOS/Linux)"
  echo "netstat -ano | findstr :8080  # (Windows)"
  echo ""
  
  echo "Out of disk space?"
  log_step "docker system prune -a  # Clean up unused images/containers"
  echo ""
  
  echo "Database won't start?"
  log_step "docker-compose -f docker-compose.prod.yml down -v"
  log_step "docker-compose -f docker-compose.prod.yml up postgres -d"
  echo ""
  
  log_header "NEXT STEPS"
  
  echo "1. For local development with hot reload:"
  echo "   Use docker-compose.yml (original) instead of docker-compose.prod.yml"
  echo ""
  
  echo "2. For full Kubernetes testing:"
  echo "   Run: bash scripts/setup-kind-cluster.sh"
  echo ""
  
  echo "3. To simulate GitHub Actions workflow locally:"
  echo "   Run: bash scripts/test-ci-locally.sh"
  echo ""
  
  echo "4. To run just the tests:"
  echo "   Run: bash scripts/run-tests-local.sh"
  echo ""
  
  log_header "Full Command Cheat Sheet"
  
  cat << 'CHEATSHEET'
# Start stack in background
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs (all services)
docker-compose -f docker-compose.prod.yml logs -f

# View logs (specific service)
docker-compose -f docker-compose.prod.yml logs -f api

# Run command in container
docker-compose -f docker-compose.prod.yml exec api bash

# Execute migrations
docker-compose -f docker-compose.prod.yml exec api npm run prisma:migrate

# Connect to database
docker-compose -f docker-compose.prod.yml exec postgres psql -U app -d video

# Stop stack (keep data)
docker-compose -f docker-compose.prod.yml down

# Stop stack (delete data)
docker-compose -f docker-compose.prod.yml down -v

# Rebuild all images
docker-compose -f docker-compose.prod.yml build

# Rebuild one image
docker-compose -f docker-compose.prod.yml build --no-cache api

# View resource usage
docker stats
CHEATSHEET
  echo ""
}

main "$@"
