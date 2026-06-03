#!/usr/bin/env bash

set -e

INPUT1="vid1-raw.mov"
INPUT2="vid2-raw.mov"

WIDTH=1280
HEIGHT=720
FPS=30

if [ ! -f "$INPUT1" ]; then
    echo "Error: $INPUT1 not found"
    exit 1
fi

if [ ! -f "$INPUT2" ]; then
    echo "Error: $INPUT2 not found"
    exit 1
fi

DUR1=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$INPUT1")
DUR2=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$INPUT2")

if [ -z "$DUR1" ] || [ -z "$DUR2" ]; then
    echo "Could not read durations."
    exit 1
fi

SHORTEST=$(awk -v a="$DUR1" -v b="$DUR2" 'BEGIN { if (a < b) print a; else print b }')

echo "Shorter video length: $SHORTEST seconds"
echo "Target: ${WIDTH}x${HEIGHT} @ ${FPS} fps"
echo "Converting..."

ffmpeg -y \
    -i "$INPUT1" \
    -vf "scale=${WIDTH}:${HEIGHT},fps=${FPS}" \
    -t "$SHORTEST" \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -an \
    vid1_ready.mov

ffmpeg -y \
    -i "$INPUT2" \
    -vf "scale=${WIDTH}:${HEIGHT},fps=${FPS}" \
    -t "$SHORTEST" \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -an \
    vid2_ready.mov

echo
echo "Done."
echo "Output files:"
echo "  vid1_ready.mov"
echo "  vid2_ready.mov"
echo "Both are $SHORTEST seconds long, ${WIDTH}x${HEIGHT}, ${FPS} fps."