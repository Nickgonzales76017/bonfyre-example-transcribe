#!/bin/sh
# run-batch.sh — Process a directory of audio files
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BONFYRE="$SCRIPT_DIR/bonfyre/cmd"
PIPELINE="$BONFYRE/BonfyrePipeline/bonfyre-pipeline"
OUTPUT="$SCRIPT_DIR/output"

if [ -z "$1" ]; then
    echo "Usage: $0 <directory-of-audio-files>"
    echo ""
    echo "Processes every .wav, .mp3, and .m4a file in the directory."
    exit 1
fi

INPUT_DIR="$1"

if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: directory not found: $INPUT_DIR"
    exit 1
fi

if [ ! -x "$PIPELINE" ]; then
    echo "Error: bonfyre-pipeline not found. Run ./setup.sh first."
    exit 1
fi

echo "╔══════════════════════════════════════════════════════╗"
echo "║     Bonfyre Batch Transcription                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

COUNT=0
OK=0
FAIL=0

for f in "$INPUT_DIR"/*.wav "$INPUT_DIR"/*.mp3 "$INPUT_DIR"/*.m4a; do
    [ -f "$f" ] || continue
    COUNT=$((COUNT + 1))
    NAME=$(basename "$f" | sed 's/\.[^.]*$//')
    OUT_DIR="$OUTPUT/$NAME"
    mkdir -p "$OUT_DIR"

    printf "  [%3d] %-40s" "$COUNT" "$NAME"

    if "$PIPELINE" run --input "$f" --out "$OUT_DIR" --type audio > /dev/null 2>&1; then
        echo "✓"
        OK=$((OK + 1))
    else
        echo "✗"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "  Processed: $COUNT files ($OK succeeded, $FAIL failed)"
echo "  Output:    $OUTPUT/"
