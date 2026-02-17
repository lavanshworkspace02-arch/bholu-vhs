# Test & Deployment Plan (1 page)

Date: 2026-02-17

## Scope
Production-ready microservice for video ingestion + conversion with:
- API (NestJS) for sessions/jobs/presets
- Worker (BullMQ) executing analyze → fetch → scan → remux/transcode → package
- PostgreSQL (Prisma) for jobs/artifacts
- Redis (BullMQ) for queue
- S3-compatible storage (MinIO in dev)
- ffmpeg/ffprobe/mediainfo/yt-dlp tooling
- ClamAV scanning
- Prometheus metrics, structured JSON logs, OpenTelemetry traces

## Environments
### Local dev (docker-compose)
Runs: `api`, `worker`, `postgres`, `redis`, `minio`, `clamav`, `jaeger`, `prometheus`, `grafana`.

### Prod (Kubernetes)
Deploy:
- `api` as Deployment + HPA (CPU)
- `worker` as Deployment in two pools: `cpu` and optional `gpu` (nodeSelector/taints)
- External managed Postgres/Redis/S3 recommended

## Test Strategy
### Unit tests (fast)
- Plan builder: probe parsing → remux vs transcode decisions
- Upload chunking: offset enforcement, resume behavior, commit preconditions
- Signed URL generation and TTL enforcement
- Error-code mapping (strict)

### Integration tests (ffmpeg-required)
Executed in docker with ffmpeg present:
1. MP4 (H.264/AAC) with rotation → REMUX profile, verify codec unchanged and metadata retained.
2. MOV (ProRes) → archival_prores (copy) and web_720p_h264 (transcode), verify stream codec.
3. MKV (HEVC) → remux if target supports, else transcode.
4. ZIP containing multiple videos → extracted and subjobs created.
5. Determinism: same input + preset + seed → identical SHA256 output.

### E2E smoke (compose)
- Create session → upload chunks → commit → poll job status → download artifact via signed URL.
- Remote ingestion: yt-dlp path (skipped by default; opt-in env var + network).

## CI/CD Pipeline (recommended)
1. `npm ci`
2. `npm run lint`
3. `npm run typecheck`
4. `npm test` (unit)
5. `npm run test:integration` (docker compose; produces `build/test-results/*`)
6. Build images; scan; push
7. Deploy to staging; run smoke

## Deployment Steps (Kubernetes)
1. Create secrets: DB URL, Redis URL, S3 credentials, JWT secret, OTLP endpoint.
2. Deploy `api`, `worker`, migrations job.
3. Configure ingress + rate limiting.
4. Validate `/metrics`, traces in Jaeger/Tempo, and a sample conversion job.

## “Needs Review” Policy Decisions
- Default bitrate/CRF caps per profile (cost vs quality)
- QA sampling retention: 1% outputs for 7 days (storage cost)
- GPU pool enablement and autoscaling strategy

