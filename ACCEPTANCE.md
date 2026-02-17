# Acceptance Criteria (Programmable)

## Core
- Determinism: identical input + profile + `random_seed` ⇒ identical artifact SHA256.
- Error mapping: known failures return documented `error_code` with remediation text.
- Observability: every job emits Prometheus metrics and OpenTelemetry spans.
- Security: every file is scanned by ClamAV before packaging; infected ⇒ `rejected_malware`.

## Test Commands
### Unit tests
`npm run test:unit`

### Integration tests (docker)
`docker compose up --build -d postgres redis minio clamav jaeger`
`docker compose run --rm worker npm run test:integration`

Artifacts:
- JUnit: `build/test-results/junit-*.xml`

## Canonical matrix (Jest)
- MP4(H.264/AAC) with rotation → REMUX
- MOV(ProRes) → TRANSCODE for web, preserve for archival
- MKV(HEVC) → remux if allowed
- RTSP intermittent → best-effort segment capture with partial_success
- ZIP multi-file → extract + create subjobs

