# SRE Runbook (Top Failure Modes)

## 1) `1000_invalid_source_uri`
**Symptom:** scheme not supported or URL parse fails.  
**Triage:** inspect `source.uri`, ensure `http(s)://`, `s3+https://` (signed), `rtsp://`, `rtmp://`, `udp://`, or `yt_dlp` type.  
**Fix:** reissue session with supported URI.

## 2) `1001_no_range_support_for_large_remote`
**Symptom:** remote lacks `Accept-Ranges` and file > 100MB.  
**Triage:** worker log shows `range=false size=...`.  
**Fix:** stage the file to S3/MinIO first, then ingest via signed URL; or upload via chunks.

## 3) `2001_ffprobe_failed`
**Symptom:** probe step fails.  
**Example stderr:** `Invalid data found when processing input`  
**Triage:** check stored `ffprobe_stderr` (job error details) and re-run `recipes.sh probe <file>`.  
**Fix:** if truncated upload, resume from correct offset; if corrupted, use pre-pass and transcode.

## 4) `1003_short_probe`
**Symptom:** ffprobe has no duration; frame export test fails.  
**Triage:** worker tries a 1-frame decode; see ffmpeg stderr snippet.  
**Fix:** treat as stream or attempt full decode/transcode.

## 5) `3001_transcode_failed`
**Symptom:** ffmpeg exits non-zero.  
**Example stderr:** `Error while decoding stream #0:0: Invalid data found`  
**Triage:** download debug bundle (if created), run `recipes.sh corruption_prepass`.  
**Fix:** retry switches to safer settings; if still failing → manual inspection.

## 6) `4001_drm_or_restricted_source`
**Symptom:** yt-dlp indicates DRM/restricted/geo-block.  
**Triage:** check yt-dlp stderr and exit code.  
**Fix:** user must provide authorized source; service will not bypass DRM.

## 7) Malware rejection (`rejected_malware`)
**Symptom:** ClamAV reports infected.  
**Triage:** see scan output.  
**Fix:** reject, quarantine object, notify security.

## 8) Storage issues
**Symptom:** S3 upload fails (timeouts, auth).  
**Triage:** verify credentials, bucket existence, and MinIO health.  
**Fix:** rotate keys; check network.

## 9) Queue backlog
**Symptom:** jobs stuck in `queued`.  
**Triage:** Redis connectivity; worker crash loops; BullMQ stalled.  
**Fix:** scale workers; review logs; check resource limits.

## 10) Resource exhaustion
**Symptom:** OOMKilled, slow transcoding.  
**Triage:** check worker memory metrics; job size.  
**Fix:** route to larger pool; enforce file size caps; enable GPU pool.

