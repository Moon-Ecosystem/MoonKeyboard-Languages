#!/usr/bin/env bash
# Downloads the Spanish pack's source data into es/data/ (git-ignored), then builds the pack.
# Needs a checkout of the app repo (Moon-Ecosystem/MoonKeyboard) for its tools: set MOONKEYBOARD
# to it, and PACK_KEY to the pack-signing private key.
#
#   MOONKEYBOARD=../MoonKeyboard PACK_KEY=~/.android-keys/moonkeyboard-packs.pk8 es/fetch-data.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
app="$(cd "${MOONKEYBOARD:?set MOONKEYBOARD to the MoonKeyboard checkout}" && pwd)"
mkdir -p "$here/data" "$here/build" "$here/eval"
cd "$here/data"

# AOSP LatinIME Spanish word list, Apache 2.0 (googlesource serves files base64-encoded)
curl -sSf "https://android.googlesource.com/platform/packages/inputmethods/LatinIME/+/refs/heads/main/dictionaries/es_wordlist.combined.gz?format=TEXT" \
  | base64 -d > es_wordlist.combined.gz

# Tatoeba Spanish sentences, CC BY 2.0 FR
curl -sSf -o spa_sentences.tsv.bz2 https://downloads.tatoeba.org/exports/per_language/spa/spa_sentences.tsv.bz2
bunzip2 -f spa_sentences.tsv.bz2

# Common Voice's everyday Spanish sentences, submitted by volunteers, CC0. Its Wikipedia set is
# left out: predictions would read like an encyclopedia.
curl -sSf -o commonvoice.txt https://raw.githubusercontent.com/common-voice/common-voice/main/server/data/es/sentence-collector.txt

cd "$app"
./gradlew -q :tools:run --args="--words $here/data/es_wordlist.combined.gz --sentences $here/data/spa_sentences.tsv \
  --extra commonvoice=$here/data/commonvoice.txt --extra-eval-dir $here/eval \
  --out $here/build/es.dict --eval-out $here/eval/tatoeba.txt"
version=$(sed -n 's/.*"version": *\([0-9]*\).*/\1/p' "$here/pack/pack.json")
./gradlew -q :tools:run -PmainClass=com.moonkeyboard.tools.BuildPackKt \
  --args="pack $here/pack $here/build ${PACK_KEY:?set PACK_KEY to the signing key} $here/build/es-$version.mkpack"
