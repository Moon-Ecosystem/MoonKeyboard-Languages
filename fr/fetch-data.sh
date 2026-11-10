#!/usr/bin/env bash
# Downloads the French pack's source data into fr/data/ (git-ignored), then builds the pack.
# Needs a checkout of the app repo (Moon-Ecosystem/MoonKeyboard) for its tools: set MOONKEYBOARD
# to it, and PACK_KEY to the pack-signing private key.
#
#   MOONKEYBOARD=../MoonKeyboard PACK_KEY=~/.android-keys/moonkeyboard-packs.pk8 fr/fetch-data.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
app="$(cd "${MOONKEYBOARD:?set MOONKEYBOARD to the MoonKeyboard checkout}" && pwd)"
mkdir -p "$here/data" "$here/build" "$here/eval"
cd "$here/data"

# AOSP LatinIME French word list, Apache 2.0 (googlesource serves files base64-encoded). It has the
# elided forms as words of their own ("c'est", "l'homme"), so they type and correct like any word.
curl -sSf "https://android.googlesource.com/platform/packages/inputmethods/LatinIME/+/refs/heads/main/dictionaries/fr_wordlist.combined.gz?format=TEXT" \
  | base64 -d > fr_wordlist.combined.gz

# Tatoeba French sentences, CC BY 2.0 FR
curl -sSf -o fra_sentences.tsv.bz2 https://downloads.tatoeba.org/exports/per_language/fra/fra_sentences.tsv.bz2
bunzip2 -f fra_sentences.tsv.bz2

# Common Voice's everyday French sentences, submitted by volunteers, CC0. Its Wikipedia sets are
# left out: predictions would read like an encyclopedia.
curl -sSf -o commonvoice.txt https://raw.githubusercontent.com/common-voice/common-voice/main/server/data/fr/sentence-collector.txt

cd "$app"
./gradlew -q :tools:run --args="--words $here/data/fr_wordlist.combined.gz --sentences $here/data/fra_sentences.tsv \
  --extra commonvoice=$here/data/commonvoice.txt --extra-eval-dir $here/eval \
  --out $here/build/fr.dict --eval-out $here/eval/tatoeba.txt"
version=$(sed -n 's/.*"version": *\([0-9]*\).*/\1/p' "$here/pack/pack.json")
./gradlew -q :tools:run -PmainClass=com.moonkeyboard.tools.BuildPackKt \
  --args="pack $here/pack $here/build ${PACK_KEY:?set PACK_KEY to the signing key} $here/build/fr-$version.mkpack"
