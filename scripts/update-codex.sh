#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ai_file="${CODEX_AI_FILE:-$repo_root/aspects/ai.nix}"

usage() {
  printf 'Usage: %s [--check] [VERSION]\n' "$(basename "$0")" >&2
}

check_only=0
if [[ "${1:-}" == "--check" ]]; then
  check_only=1
  shift
fi

if (($# > 1)); then
  usage
  exit 2
fi

if (($# == 1)); then
  version="$1"
else
  tag="$(curl --fail --silent --show-error --location \
    -H 'Accept: application/vnd.github+json' \
    https://api.github.com/repos/openai/codex/releases/latest | jq -r '.tag_name')"
  [[ "$tag" == rust-v* ]] || {
    printf 'Unexpected Codex release tag: %s\n' "$tag" >&2
    exit 1
  }
  version="${tag#rust-v}"
fi

[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  printf 'Invalid Codex version: %s\n' "$version" >&2
  exit 2
}

url="https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.gz"
prefetch_json="$(nix store prefetch-file --json "$url")"
hash="$(jq -er '.hash' <<<"$prefetch_json")"

current_version="$(sed -n 's/^[[:space:]]*codexVersion = "\([^"]*\)";.*/\1/p' "$ai_file")"
current_hash="$(sed -n '/codexVersion = /,/^    };/{s/^[[:space:]]*hash = "\([^"]*\)";.*/\1/p;}' "$ai_file" | head -n 1)"

if [[ "$current_version" == "$version" && "$current_hash" == "$hash" ]]; then
  printf 'Codex %s is already configured with hash %s.\n' "$version" "$hash"
  exit 0
fi

if ((check_only)); then
  printf 'Codex update available: %s/%s -> %s/%s\n' \
    "$current_version" "$current_hash" "$version" "$hash"
  exit 1
fi

CODEX_VERSION="$version" CODEX_HASH="$hash" perl -0pi -e \
  's/(codexVersion = ")[^"]+(";\n\s+codex = .*?\n\s+src = pkgs\.fetchurl \{\n\s+url = .*?\n\s+hash = ")[^"]+/$1$ENV{CODEX_VERSION}$2$ENV{CODEX_HASH}/s' \
  "$ai_file"

if [[ "$(sed -n 's/^[[:space:]]*codexVersion = "\([^"]*\)";.*/\1/p' "$ai_file")" != "$version" ]] || \
   [[ "$(sed -n '/codexVersion = /,/^    };/{s/^[[:space:]]*hash = "\([^"]*\)";.*/\1/p;}' "$ai_file" | head -n 1)" != "$hash" ]]; then
  printf 'Failed to update %s\n' "$ai_file" >&2
  exit 1
fi

printf 'Updated Codex to %s with hash %s in %s.\n' "$version" "$hash" "$ai_file"
