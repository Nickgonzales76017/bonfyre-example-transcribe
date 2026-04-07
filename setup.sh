#!/bin/sh
# setup.sh — Clone Bonfyre and build audio pipeline binaries
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BONFYRE_DIR="$SCRIPT_DIR/bonfyre"

if [ -d "$BONFYRE_DIR" ] && [ -f "$BONFYRE_DIR/Makefile" ]; then
    echo "Bonfyre already cloned at $BONFYRE_DIR"
else
    echo "Cloning Bonfyre..."
    git clone https://github.com/Nickgonzales76017/bonfyre.git "$BONFYRE_DIR"
fi

echo ""
echo "Building audio pipeline binaries..."

cd "$BONFYRE_DIR"
make lib

AUDIO_BINS="BonfyreIngest BonfyreHash BonfyreMediaPrep BonfyreTranscribe BonfyreTranscriptClean BonfyreParagraph BonfyreBrief BonfyreProof BonfyreTag BonfyreOffer BonfyrePack BonfyrePipeline"

for bin in $AUDIO_BINS; do
    printf "  Building %-30s" "$bin..."
    if make -C "cmd/$bin" CC="${CC:-cc}" CFLAGS="${CFLAGS:--O3 -march=native -flto=auto -Wall -Wextra -std=c11}" > /dev/null 2>&1; then
        echo "✓"
    else
        echo "✗ (optional — pipeline will still work)"
    fi
done

echo ""
echo "Setup complete. Run ./run.sh sample-data/meeting.wav"
