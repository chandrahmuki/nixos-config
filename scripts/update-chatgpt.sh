#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
chatgpt_file="${CHATGPT_FILE:-$repo_root/aspects/chatgpt.nix}"
url="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb"

usage() {
  printf 'Usage: %s [--check]\n' "$(basename "$0")" >&2
}

check_only=0
if [[ "${1:-}" == "--check" ]]; then
  check_only=1
  shift
fi

if (($# > 0)); then
  usage
  exit 2
fi

# The package is 500 MB: when the server reports the same ETag as at the last successful
# check, the file has not changed and nothing is downloaded.
stamp="${XDG_CACHE_HOME:-$HOME/.cache}/nixos-config/chatgpt.etag"
etag="$(curl --fail --silent --location --head "$url" | tr -d '\r' | sed -n 's/^[Ee][Tt]ag: //p' | head -n 1)"
if [[ -n "$etag" && -f "$stamp" && "$(cat "$stamp")" == "$etag" ]]; then
  printf 'ChatGPT is unchanged (ETag %s).\n' "$etag"
  exit 0
fi

# The URL always serves the newest build, so the version is read from the package itself.
prefetch_json="$(nix store prefetch-file --json "$url")"
hash="$(jq -er '.hash' <<<"$prefetch_json")"
store_path="$(jq -er '.storePath' <<<"$prefetch_json")"
version="$(nix run nixpkgs#dpkg -- -f "$store_path" Version)"

[[ "$version" =~ ^[0-9]+(\.[0-9]+)+$ ]] || {
  printf 'Unexpected ChatGPT version: %s\n' "$version" >&2
  exit 1
}

current_version="$(sed -n 's/^[[:space:]]*version = "\([^"]*\)";.*/\1/p' "$chatgpt_file" | head -n 1)"
current_hash="$(sed -n 's/^[[:space:]]*hash = "\([^"]*\)";.*/\1/p' "$chatgpt_file" | head -n 1)"

remember_etag() {
  if [[ -n "$etag" ]]; then
    mkdir -p "$(dirname "$stamp")"
    printf '%s' "$etag" >"$stamp"
  fi
}

if [[ "$current_version" == "$version" && "$current_hash" == "$hash" ]]; then
  remember_etag
  printf 'ChatGPT %s is already configured with hash %s.\n' "$version" "$hash"
  exit 0
fi

if ((check_only)); then
  printf 'ChatGPT update available: %s/%s -> %s/%s\n' \
    "$current_version" "$current_hash" "$version" "$hash"
  exit 1
fi

CHATGPT_VERSION="$version" CHATGPT_HASH="$hash" perl -0pi -e \
  's/(pname = "chatgpt";\n\s+version = ")[^"]+(";\n\s+src = pkgs\.fetchurl \{\n\s+url = .*?\n\s+hash = ")[^"]+/$1$ENV{CHATGPT_VERSION}$2$ENV{CHATGPT_HASH}/s' \
  "$chatgpt_file"

if [[ "$(sed -n 's/^[[:space:]]*version = "\([^"]*\)";.*/\1/p' "$chatgpt_file" | head -n 1)" != "$version" ]] || \
   [[ "$(sed -n 's/^[[:space:]]*hash = "\([^"]*\)";.*/\1/p' "$chatgpt_file" | head -n 1)" != "$hash" ]]; then
  printf 'Failed to update %s\n' "$chatgpt_file" >&2
  exit 1
fi

remember_etag
printf 'Updated ChatGPT to %s with hash %s in %s.\n' "$version" "$hash" "$chatgpt_file"
