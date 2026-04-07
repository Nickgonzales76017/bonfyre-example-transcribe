#!/bin/sh
# run-stepwise.sh — Run each pipeline stage individually (educational)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BONFYRE="$SCRIPT_DIR/bonfyre/cmd"
OUTPUT="$SCRIPT_DIR/output"
SAMPLE="$SCRIPT_DIR/sample-data"

if [ -z "$1" ]; then
    echo "Usage: $0 <audio-file>"
    exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
    echo "Error: file not found: $INPUT"
    exit 1
fi

mkdir -p "$OUTPUT"

echo "╔══════════════════════════════════════════════════════╗"
echo "║     Bonfyre Pipeline — Step by Step                  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

step() {
    STEP_NUM="$1"
    STEP_NAME="$2"
    BINARY="$3"
    shift 3
    printf "  [%2d/10] %-20s" "$STEP_NUM" "$STEP_NAME"
    if [ -x "$BINARY" ]; then
        if "$BINARY" "$@" > /dev/null 2>&1; then
            echo "✓"
        else
            echo "✗ (non-zero exit — check args)"
        fi
    else
        echo "– (binary not built)"
    fi
}

INPUT_BASE=$(basename "$INPUT" | sed 's/\.[^.]*$//')

# Copy input to work directory
cp "$INPUT" "$OUTPUT/"

# Use pre-made transcript if available
if [ -f "$SAMPLE/${INPUT_BASE}-transcript.json" ]; then
    cp "$SAMPLE/${INPUT_BASE}-transcript.json" "$OUTPUT/transcript.json"
fi

step 1  "Ingest"       "$BONFYRE/BonfyreIngest/bonfyre-ingest" \
    intake "$INPUT" --out "$OUTPUT/"

step 2  "Media Prep"   "$BONFYRE/BonfyreMediaPrep/bonfyre-media-prep" \
    normalize "$OUTPUT/${INPUT_BASE}.wav" 2>/dev/null || \
    printf "  [ 2/10] %-20s– (ffmpeg needed)\n" "Media Prep"

step 3  "Hash"         "$BONFYRE/BonfyreHash/bonfyre-hash" \
    file "$OUTPUT/${INPUT_BASE}.wav"

step 4  "Transcribe"   "$BONFYRE/BonfyreTranscribe/bonfyre-transcribe" \
    run "$OUTPUT/${INPUT_BASE}.wav" --out "$OUTPUT/transcript.json"

step 5  "Clean"        "$BONFYRE/BonfyreTranscriptClean/bonfyre-transcript-clean" \
    run "$OUTPUT/transcript.json" --out "$OUTPUT/clean.json"

step 6  "Paragraph"    "$BONFYRE/BonfyreParagraph/bonfyre-paragraph" \
    run "$OUTPUT/clean.json" --out "$OUTPUT/paragraphs.json"

step 7  "Brief"        "$BONFYRE/BonfyreBrief/bonfyre-brief" \
    generate "$OUTPUT/paragraphs.json" --out "$OUTPUT/brief.md"

step 8  "Proof"        "$BONFYRE/BonfyreProof/bonfyre-proof" \
    score "$OUTPUT/" --out "$OUTPUT/proof.json"

step 9  "Tag"          "$BONFYRE/BonfyreTag/bonfyre-tag" \
    predict "$OUTPUT/paragraphs.json" --out "$OUTPUT/tags.json"

step 10 "Pack"         "$BONFYRE/BonfyrePack/bonfyre-pack" \
    bundle "$OUTPUT/" --out "$OUTPUT/deliverable.zip"

echo ""
echo "Done. Artifacts in: $OUTPUT/"
