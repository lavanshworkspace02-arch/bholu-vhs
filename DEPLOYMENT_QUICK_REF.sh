#!/usr/bin/env bash

# DEPLOYMENT PIPELINE QUICK REFERENCE
# Video Ingest Microservice

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         DEPLOYMENT PIPELINE QUICK REFERENCE                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "QUICK START"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# 1. Initial setup"
echo "bash scripts/setup-pipeline.sh"
echo ""

echo "# 2. View deployment status"
echo "kubectl get pods -n video-app"
echo "kubectl get hpa -n video-app"
echo ""

echo "# 3. View logs"
echo "kubectl logs -n video-app -l app=api -f"
echo "kubectl logs -n video-app -l app=worker -f"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DEPLOYMENT COMMANDS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# Deploy development environment"
echo "kubectl apply -k infra/k8s/overlays/development"
echo ""

echo "# Deploy staging environment"
echo "kubectl apply -k infra/k8s/overlays/staging"
echo ""

echo "# Deploy production environment"
echo "kubectl apply -k infra/k8s/overlays/production"
echo ""

echo "# Trigger production via git tag (CI/CD)"
echo "git tag v1.0.0 && git push origin v1.0.0"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "MONITORING & DEBUGGING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# Check pod status"
echo "kubectl get pods -n video-app"
echo ""

echo "# Describe pod (troubleshooting)"
echo "kubectl describe pod <pod-name> -n video-app"
echo ""

echo "# Tail logs"
echo "kubectl logs -f deployment/api-deployment -n video-app"
echo ""

echo "# Resource usage"
echo "kubectl top pods -n video-app"
echo "kubectl top nodes"
echo ""

echo "# HPA status"
echo "kubectl get hpa -n video-app"
echo "kubectl describe hpa api-hpa -n video-app"
echo ""

echo "# Events"
echo "kubectl get events -n video-app --sort-by='.lastTimestamp'"
echo ""

echo "# Port forward (local testing)"
echo "kubectl port-forward svc/api-service 8080:80 -n video-app"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DATABASE OPERATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# Run migrations"
echo "kubectl exec deployment/api-deployment -n video-app -- npm run prisma:migrate"
echo ""

echo "# Backup databases"
echo "bash scripts/backup.sh"
echo ""

echo "# Exec into postgres"
echo "kubectl exec -it svc/postgres -n video-app -- psql -U app -d video"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ROLLOUT MANAGEMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# Watch rollout"
echo "kubectl rollout status deployment/api-deployment -n video-app"
echo ""

echo "# Rollout history"
echo "kubectl rollout history deployment/api-deployment -n video-app"
echo ""

echo "# Rollback to previous"
echo "kubectl rollout undo deployment/api-deployment -n video-app"
echo ""

echo "# Restart deployment (pick up new secrets)"
echo "kubectl rollout restart deployment/api-deployment -n video-app"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SECRETS & CONFIG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# Edit secrets"
echo "kubectl edit secret app-secrets -n video-app"
echo ""

echo "# Edit configmap"
echo "kubectl edit configmap app-config -n video-app"
echo ""

echo "# Create/update secrets"
echo "kubectl create secret generic app-secrets \\"
echo "  --from-literal=JWT_SECRET=your-secret \\"
echo "  --from-literal=DATABASE_PASSWORD=your-password \\"
echo "  -n video-app --dry-run=client -o yaml | kubectl apply -f -"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SCALING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# Manual scale"
echo "kubectl scale deployment/api-deployment --replicas=5 -n video-app"
echo ""

echo "# Update HPA min/max"
echo "kubectl patch hpa api-hpa -n video-app -p '{\"spec\": {\"minReplicas\": 5, \"maxReplicas\": 20}}'"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CLEANUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "# Delete environment"
echo "kubectl delete -k infra/k8s/overlays/development"
echo ""

echo "# Delete namespace (all resources)"
echo "kubectl delete namespace video-app"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DOCUMENTATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📄 DEPLOYMENT_PIPELINE.md      - Complete pipeline overview"
echo "📄 infra/DEPLOYMENT.md         - kubectl command reference"
echo "📄 .github/workflows/deploy.yml - CI/CD workflow configuration"
echo ""
