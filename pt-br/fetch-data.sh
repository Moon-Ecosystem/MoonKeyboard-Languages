#!/usr/bin/env bash
# Downloads the Brazilian Portuguese pack's source data into pt-br/data/ (git-ignored), then builds
# the pack. Needs a checkout of the app repo (Moon-Ecosystem/MoonKeyboard) for its tools: set
# MOONKEYBOARD to it, and PACK_KEY to the pack-signing private key.
#
#   MOONKEYBOARD=../MoonKeyboard PACK_KEY=~/.android-keys/moonkeyboard-packs.pk8 pt-br/fetch-data.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
app="$(cd "${MOONKEYBOARD:?set MOONKEYBOARD to the MoonKeyboard checkout}" && pwd)"
mkdir -p "$here/data" "$here/build" "$here/eval"
cd "$here/data"

# AOSP LatinIME Brazilian Portuguese word list, Apache 2.0 (googlesource serves files base64-encoded)
curl -sSf "https://android.googlesource.com/platform/packages/inputmethods/LatinIME/+/refs/heads/main/dictionaries/pt_BR_wordlist.combined.gz?format=TEXT" \
  | base64 -d > pt_BR_wordlist.combined.gz

# Tatoeba Portuguese sentences, CC BY 2.0 FR (Brazilian and European together; the word list decides the spelling)
curl -sSf -o por_sentences.tsv.bz2 https://downloads.tatoeba.org/exports/per_language/por/por_sentences.tsv.bz2
bunzip2 -f por_sentences.tsv.bz2

# Common Voice's everyday Portuguese sentences, submitted by volunteers, CC0
curl -sSf -o commonvoice.txt https://raw.githubusercontent.com/common-voice/common-voice/main/server/data/pt/sentence-collector.txt

cd "$app"
./gradlew -q :tools:run --args="--words $here/data/pt_BR_wordlist.combined.gz --sentences $here/data/por_sentences.tsv \
  --extra commonvoice=$here/data/commonvoice.txt --extra-eval-dir $here/eval \
  --out $here/build/pt-br.dict --eval-out $here/eval/tatoeba.txt"
version=$(sed -n 's/.*"version": *\([0-9]*\).*/\1/p' "$here/pack/pack.json")
./gradlew -q :tools:run -PmainClass=com.moonkeyboard.tools.BuildPackKt \
  --args="pack $here/pack $here/build ${PACK_KEY:?set PACK_KEY to the signing key} $here/build/pt-br-$version.mkpack"
