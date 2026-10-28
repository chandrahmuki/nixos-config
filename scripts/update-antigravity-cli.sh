#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ai_file="${ANTIGRAVITY_AI_FILE:-$repo_root/aspects/ai.nix}"

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

version="$(curl --fail --silent --show-error --location \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest | jq -r '.tag_name')"

[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  printf 'Unexpected Antigravity CLI release tag: %s\n' "$version" >&2
  exit 1
}

current_version="$(sed -n '/pname = "antigravity-cli";/,/^    };/{s/^[[:space:]]*version = "\([^"]*\)";.*/\1/p;}' "$ai_file" | head -n 1)"

if [[ "$current_version" == "$version" ]]; then
  printf 'Antigravity CLI %s is already configured.\n' "$version"
  exit 0
fi

url="https://github.com/google-antigravity/antigravity-cli/releases/download/${version}/agy_cli_linux_x64.tar.gz"
hash="$(nix store prefetch-file --json "$url" | jq -er '.hash')"

if ((check_only)); then
  printf 'Antigravity CLI update available: %s -> %s\n' "$current_version" "$version"
  exit 1
fi

ANTIGRAVITY_VERSION="$version" ANTIGRAVITY_HASH="$hash" perl -0pi -e \
  's/(pname = "antigravity-cli";\n\s+version = ")[^"]+(";\n\s+src = pkgs\.fetchurl \{\n\s+url = "https:\/\/github\.com\/google-antigravity\/antigravity-cli\/releases\/download\/)[^\/]+(\/agy_cli_linux_x64\.tar\.gz";\n\s+)(?:sha256|hash) = "[^"]+/$1$ENV{ANTIGRAVITY_VERSION}$2$ENV{ANTIGRAVITY_VERSION}$3hash = "$ENV{ANTIGRAVITY_HASH}/s' \
  "$ai_file"

if [[ "$(sed -n '/pname = "antigravity-cli";/,/^    };/{s/^[[:space:]]*version = "\([^"]*\)";.*/\1/p;}' "$ai_file" | head -n 1)" != "$version" ]]; then
  printf 'Failed to update %s\n' "$ai_file" >&2
  exit 1
fi

printf 'Updated Antigravity CLI to %s with hash %s in %s.\n' "$version" "$hash" "$ai_file"
