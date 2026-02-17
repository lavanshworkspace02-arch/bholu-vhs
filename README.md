# Universal Video Ingest & Conversion Microservice

## What this is
Two services:
- `api` (NestJS): sessions, chunked uploads, job control/status, presets
- `worker` (BullMQ): analyze → fetch → scan → remux/transcode → package

Core tools: `ffmpeg`, `ffprobe`, `mediainfo`, `yt-dlp`, ClamAV.

## Local development (docker-compose)
Prereqs: Docker + Compose.

1. `cp .env.example .env` (optional)
2. `docker compose up --build`
3. API: `http://localhost:8080`
4. Metrics: `http://localhost:8080/metrics`
5. Jaeger UI: `http://localhost:16686`
6. Prometheus: `http://localhost:9090`

## Quick start workflow
1. `POST /api/v1/sessions` with `{ "source": { "type": "upload" }, "profile": "web_720p_h264" }`
2. Upload with `POST /api/v1/sessions/:id/upload_chunk` using `Content-Range`.
3. `POST /api/v1/sessions/:id/commit` → returns `job_id`
4. Poll `GET /api/v1/jobs/:id/status`

## Simulate 100 jobs (local)
After compose is up:
- `npm run build`
- `node --enable-source-maps dist/scripts/generate_sample_jobs.js`

## Remote ingestion examples
### YouTube / Drive / cloud links (via yt-dlp)
Create session with:
```json
{ "source": { "type": "yt_dlp", "uri": "https://www.youtube.com/watch?v=..." }, "profile": "web_720p_h264" }
```

### RTSP ingestion (best-effort sample capture)
```json
{ "source": { "type": "stream", "uri": "rtsp://user:pass@host/stream", "capture_seconds": 30 }, "profile": "web_720p_h264" }
```

## Tests
- Unit: `npm run test:unit`
- Integration (needs ffmpeg): `npm run test:integration`

Integration outputs land in `build/test-results/`.

