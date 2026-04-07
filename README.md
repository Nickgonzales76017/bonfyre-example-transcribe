# bonfyre-example-transcribe

**Audio → transcript → summary → tags → deliverable.** Entirely local. No cloud APIs. No per-minute billing.

## The pitch (for your CEO)

| | Deepgram | Rev.ai | **Bonfyre** |
|---|---|---|---|
| Per-minute cost | $0.0043–0.0145 | $0.02–0.07 | **$0** |
| 1,000 hours/month | $258–870 | $1,200–4,200 | **$0** |
| Annual cost | $3,096–10,440 | $14,400–50,400 | **$0** |
| Data privacy | Cloud processing | Cloud processing | **Never leaves your machine** |
| Setup | API keys, SDK, billing | API keys, SDK, billing | **`git clone && make`** |
| Internet required | Yes | Yes | **No** |
| Output | Transcript JSON | Transcript JSON | **Transcript + summary + tags + quality score + deliverable ZIP** |

**For a team transcribing 100+ hours/month, Bonfyre saves $3,000–50,000/year.**

## What this demo does

```
audio.wav → normalize → transcribe → clean → paragraph → brief → proof → tag → offer → pack
     ↓          ↓           ↓          ↓         ↓         ↓        ↓       ↓       ↓       ↓
  raw file   16kHz WAV   raw JSON   cleaned   paragraphs  summary  quality topics  price   ZIP
```

10 stages. One command. Output: a ZIP containing everything a client needs.

## Prerequisites

- C compiler (clang/gcc)
- SQLite3 headers
- ffmpeg (`brew install ffmpeg` / `apt install ffmpeg`) — for audio normalization
- Optional: Whisper model for real transcription (see below)

## Quick start

```bash
git clone https://github.com/Nickgonzales76017/bonfyre-example-transcribe.git
cd bonfyre-example-transcribe
./setup.sh                        # builds bonfyre (~2 min)
./run.sh sample-data/meeting.wav  # runs full pipeline on sample audio
```

## What you'll see

```
╔══════════════════════════════════════════════════════╗
║     Bonfyre Transcription Pipeline                   ║
╚══════════════════════════════════════════════════════╝

  Input: sample-data/meeting.wav (2:34)

  [1/10] Ingest          ✓  intake + type detection
  [2/10] Media Prep      ✓  normalize to 16kHz mono WAV
  [3/10] Hash            ✓  SHA-256 content address
  [4/10] Transcribe      ✓  speech → text (Whisper)
  [5/10] Clean           ✓  filler removal, normalization
  [6/10] Paragraph       ✓  speaker-aware paragraphs
  [7/10] Brief           ✓  executive summary + action items
  [8/10] Proof           ✓  quality score: 87/100
  [9/10] Tag             ✓  topics: [meeting, planning, Q2-review]
  [10/10] Pack           ✓  deliverable.zip

  Output: output/deliverable.zip
    ├── transcript.json         Full transcript
    ├── clean.json              Cleaned transcript
    ├── paragraphs.json         Speaker-aware paragraphs
    ├── brief.md                Executive summary + action items
    ├── proof.json              Quality score
    ├── tags.json               Topic classification
    └── offer.json              Pricing proposal

  Pipeline time: 5–8 ms (excluding transcription model)
  Total files: 7 artifacts + ZIP
```

## Three ways to run

### 1. Unified pipeline (fastest — one binary, one process)

```bash
./run.sh sample-data/meeting.wav
# Uses bonfyre-pipeline: all 10 stages in a single process
# 5–8 ms pipeline overhead (plus transcription model time)
```

### 2. Step-by-step (learn each binary)

```bash
./run-stepwise.sh sample-data/meeting.wav
# Runs each binary individually so you can see what each one does
```

### 3. Batch mode (process a directory of audio files)

```bash
./run-batch.sh audio-directory/
# Processes every .wav/.mp3/.m4a file in the directory
```

## Using real transcription (Whisper)

The sample data includes a pre-made transcript for zero-friction demo. For real audio:

```bash
# 1. Install Whisper (one-time)
pip3 install openai-whisper

# 2. Run with real transcription
./run.sh your-audio.mp3 --real
```

Or use any Whisper-compatible model — Bonfyre's transcription binary wraps whatever is available on your system.

## Sample data included

| File | Description |
|---|---|
| `meeting.wav` | 10-second synthesized tone (for pipeline testing) |
| `meeting-transcript.json` | Pre-made transcript (for zero-dependency demo) |

## Output breakdown

| Artifact | What it is | Who uses it |
|---|---|---|
| `transcript.json` | Raw timestamped text | Developers, search index |
| `clean.json` | Filler words removed, normalized | Editors, QA |
| `paragraphs.json` | Speaker-segmented paragraphs | Readers, summaries |
| `brief.md` | Executive summary + action items | **CEOs, managers** |
| `proof.json` | Quality score (0–100) | QA, pricing |
| `tags.json` | Topic/intent classification | Search, routing |
| `offer.json` | Pricing based on quality + length | Sales, invoicing |
| `deliverable.zip` | Everything packaged | Client delivery |

## Cost comparison (annual, 100 hours/month)

| Provider | Annual cost | Data privacy | Offline |
|---|---|---|---|
| Deepgram | $3,096–10,440 | No | No |
| Rev.ai | $14,400–50,400 | No | No |
| AssemblyAI | $4,320–14,400 | No | No |
| AWS Transcribe | $1,440 | AWS only | No |
| **Bonfyre** | **$0** | **Yes** | **Yes** |

## File structure

```
bonfyre-example-transcribe/
├── README.md
├── setup.sh                # Clones + builds Bonfyre
├── run.sh                  # Unified pipeline (one command)
├── run-stepwise.sh         # Step-by-step (each binary separate)
├── run-batch.sh            # Process a directory of audio files
├── sample-data/
│   ├── meeting.wav         # Sample audio (tone for testing)
│   └── meeting-transcript.json  # Pre-made transcript
└── output/                 # Created at runtime
```

## Next steps

| Want to... | Example repo |
|---|---|
| Search transcripts semantically | [bonfyre-example-semantic-search](https://github.com/Nickgonzales76017/bonfyre-example-semantic-search) |
| Compress transcript JSON | [bonfyre-example-compress](https://github.com/Nickgonzales76017/bonfyre-example-compress) |
| Run a full SaaS platform | [bonfyre-example-saas-stack](https://github.com/Nickgonzales76017/bonfyre-example-saas-stack) |

## License

MIT — same as [Bonfyre](https://github.com/Nickgonzales76017/bonfyre).
