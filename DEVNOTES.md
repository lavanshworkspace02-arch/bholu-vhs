# DEVNOTES (Top 10 Pitfalls)

1. ffmpeg “determinism” depends on versions and threading; strict mode uses `-threads 1`.
2. MP4 container does not safely carry all codecs (e.g., Opus); remux only when compatible.
3. Rotation metadata is container-dependent; remux preserves it, transcode must bake rotation or copy metadata carefully.
4. RTSP/RTMP inputs can stall; always set timeouts and capture windows.
5. Partial corruption: `-err_detect ignore_err -fflags +discardcorrupt` helps read-through.
6. yt-dlp failures mix network, geo, auth, DRM; keep stderr + exit code and map explicitly.
7. ClamAV in containers can be slow on first run (DB warmup); handle scan timeouts gracefully.
8. S3 signed URLs must remain private-by-default and short-lived (<= 24h).
9. Large remote files without byte ranges require full download; enforce size thresholds.
10. Always persist last 200KB of ffmpeg stderr for debugging without storing huge logs in DB.

