#!/bin/sh
# run.sh — Run the full transcription pipeline on an audio file
#
# Usage:
#   ./run.sh <audio-file>           # unified pipeline (fast)
#   ./run.sh <audio-file> --real    # use real Whisper transcription
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BONFYRE="$SCRIPT_DIR/bonfyre/cmd"
PIPELINE="$BONFYRE/BonfyrePipeline/bonfyre-pipeline"
OUTPUT="$SCRIPT_DIR/output"
SAMPLE="$SCRIPT_DIR/sample-data"

USE_REAL=0

if [ -z "$1" ]; then
    echo "Usage: $0 <audio-file> [--real]"
    echo ""
    echo "Examples:"
    echo "  $0 sample-data/meeting.wav           # demo with pre-made transcript"
    echo "  $0 your-interview.mp3 --real          # real Whisper transcription"
    echo ""
    echo "The pipeline produces:"
    echo "  transcript → cleaned → paragraphs → summary → quality → tags → price → ZIP"
    exit 1
fi

INPUT="$1"
shift
while [ $# -gt 0 ]; do
    case "$1" in
        --real) USE_REAL=1; shift ;;
        *)      shift ;;
    esac
done

if [ ! -f "$INPUT" ]; then
    echo "Error: file not found: $INPUT"
    exit 1
fi

if [ ! -x "$PIPELINE" ]; then
    echo "Error: bonfyre-pipeline not found. Run ./setup.sh first."
    exit 1
fi

mkdir -p "$OUTPUT"

echo "╔══════════════════════════════════════════════════════╗"
echo "║     Bonfyre Transcription Pipeline                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Input: $INPUT"
echo ""

# If using sample data without real Whisper, copy pre-made transcript
INPUT_BASE=$(basename "$INPUT" | sed 's/\.[^.]*$//')
if [ "$USE_REAL" = "0" ] && [ -f "$SAMPLE/${INPUT_BASE}-transcript.json" ]; then
    echo "  Mode: demo (using pre-made transcript)"
    echo "  Tip:  use --real flag for actual Whisper transcription"
    echo ""
    cp "$SAMPLE/${INPUT_BASE}-transcript.json" "$OUTPUT/transcript.json"
fi

# Run the unified pipeline
echo "━━━ Running pipeline ━━━"
echo ""

START_TS=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo 0)

"$PIPELINE" run --input "$INPUT" --out "$OUTPUT" --type audio 2>&1 | while IFS= read -r line; do
    echo "  $line"
done || true

END_TS=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo 0)

echo ""

if [ "$START_TS" != "0" ] && [ "$END_TS" != "0" ]; then
    ELAPSED=$((END_TS - START_TS))
    echo "  Pipeline time: ${ELAPSED} ms"
fi

# Show output
echo ""
echo "━━━ Output ━━━"
echo ""
if [ -d "$OUTPUT" ]; then
    for f in "$OUTPUT"/*; do
        [ -f "$f" ] || continue
        SIZE=$(ls -lh "$f" | awk '{print $5}')
        printf "  %-35s %s\n" "$(basename "$f")" "$SIZE"
    done
fi

echo ""
echo "All artifacts in: $OUTPUT/"
echo ""
echo "Key files for your CEO:"
echo "  $OUTPUT/brief.md        ← Executive summary + action items"
echo "  $OUTPUT/proof.json      ← Quality score"
echo "  $OUTPUT/offer.json      ← Pricing proposal"
