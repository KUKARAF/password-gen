#!/usr/bin/env bash
# Downloads source wordlists and produces clean, filtered word lists
# Output: wordlists/en.txt, de.txt, es.txt, pl.txt (one word per line)

set -euo pipefail

RAW="wordlists/raw"
OUT="wordlists"

mkdir -p "$RAW" "$OUT"

echo "Downloading sources..."

curl -fsSL "https://lightsecond.com/password_building_block_dict.txt" -o "$RAW/en_raw.txt"
curl -fsSL "https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/spanish.txt" -o "$RAW/es_raw.txt"
curl -fsSL "https://raw.githubusercontent.com/dys2p/wordlists-de/main/de-7776-v1.txt" -o "$RAW/de_raw.txt"
curl -fsSL "https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/pl/pl_50k.txt" -o "$RAW/pl_raw.txt"

echo "Processing English..."
# Already clean (one word per line, no numbers)
cp "$RAW/en_raw.txt" "$OUT/en.txt"

echo "Processing Spanish..."
# BIP39 list is already clean (one word per line)
cp "$RAW/es_raw.txt" "$OUT/es.txt"

echo "Processing German..."
# dys2p: one word per line, filter to 5-9 chars only
awk 'length($0)>=5 && length($0)<=9' "$RAW/de_raw.txt" > "$OUT/de.txt"

echo "Processing Polish..."
# hermitdave: "word frequency" format, strip freq column,
# skip first 50 entries (stopwords/function words),
# keep only 5-9 char words with Polish alphabet chars,
# cap at 3000 words
awk '{print $1}' "$RAW/pl_raw.txt" \
  | tail -n +51 \
  | awk 'length($0)>=5 && length($0)<=9 && /^[a-ząćęłńóśźż]+$/' \
  | head -3000 \
  > "$OUT/pl.txt"

echo ""
echo "Done. Word counts:"
wc -l "$OUT/en.txt" "$OUT/es.txt" "$OUT/de.txt" "$OUT/pl.txt"
