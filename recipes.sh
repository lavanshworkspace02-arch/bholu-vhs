#!/usr/bin/env bash
set -euo pipefail

# Canonical, copy-paste-ready ffmpeg recipes used by the worker.
# These are referenced verbatim by wrappers (search for "recipes.sh").

probe() {
  # Fast probe: show format + streams for first 5 seconds
  ffprobe -v error -print_format json -show_format -show_streams -read_intervals "%+#5" "$1"
}

corruption_prepass() {
  # Attempt to read through corruption and discard corrupt packets
  ffmpeg -hide_banner -y \
    -err_detect ignore_err -fflags +discardcorrupt \
    -i "$1" \
    -map 0 -c copy -f null -
}

safe_remux() {
  # Remux to MP4 with faststart when codecs are already compatible
  ffmpeg -hide_banner -y \
    -i "$1" \
    -map 0 \
    -c copy \
    -movflags +faststart \
    "$2"
}

transcode_h264_crf() {
  # Deterministic (threads=1) H.264 + AAC MP4 transcode
  ffmpeg -hide_banner -y \
    -i "$1" \
    -map 0:v:0 -map 0:a? -map -0:d? -map -0:s? \
    -vf "scale=w=1280:h=720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
    -c:v libx264 -preset medium -crf 23 -pix_fmt yuv420p -threads 1 \
    -c:a aac -b:a 128k \
    -movflags +faststart \
    -map_metadata 0 -map_chapters 0 \
    "$2"
}

nvenc_fallback() {
  # GPU fallback: NVENC (requires NVIDIA runtime)
  ffmpeg -hide_banner -y \
    -hwaccel cuda -i "$1" \
    -map 0:v:0 -map 0:a? -map -0:d? -map -0:s? \
    -vf "scale=w=1280:h=720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
    -c:v h264_nvenc -preset p4 -cq 23 \
    -c:a aac -b:a 128k \
    -movflags +faststart \
    -map_metadata 0 -map_chapters 0 \
    "$2"
}

thumbnail_generation() {
  # One thumbnail at ~1s
  ffmpeg -hide_banner -y \
    -ss 00:00:01.000 -i "$1" \
    -frames:v 1 \
    -vf "scale=320:-2:flags=bicubic" \
    "$2"
}

ebur128_loudness_normalize() {
  # Example loudness pass (outputs stats to stderr)
  ffmpeg -hide_banner -y \
    -i "$1" \
    -filter_complex "ebur128=peak=true" \
    -f null -
}

