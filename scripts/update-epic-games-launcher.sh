#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
gaming_file="${EPIC_GAMING_FILE:-$repo_root/aspects/gaming.nix}"
url="https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher-x86_64.deb"
stamp="${XDG_CACHE_HOME:-$HOME/.cache}/nixos-config/epic-games-launcher.etag"

headers_and_url="$(curl --fail --silent --show-error --location --head \
  --write-out $'\n%{url_effective}' "$url")"
etag="$(sed -n 's/^[Ee][Tt]ag: //p' <<<"$headers_and_url" | tr -d '\r' | tail -n 1)"
resolved_url="${headers_and_url##*$'\n'}"

if [[ -n "$etag" && -f "$stamp" && "$(cat "$stamp")" == "$etag" ]]; then
  printf 'Epic Games Launcher is unchanged (ETag %s).\n' "$etag"
  exit 0
fi

version="$(sed -nE 's#.*EGLv2/([0-9]+\.[0-9]+\.[0-9]+)(%2B|\+).*#\1#p' <<<"$resolved_url")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  printf 'Could not determine Epic Games Launcher version from URL: %s\n' "$resolved_url" >&2
  exit 1
}

current_version="$(sed -n '/pname = "epic-games-launcher";/,/};/{s/^[[:space:]]*version = "\([^"]*\)";.*/\1/p;}' "$gaming_file" | head -n 1)"
current_hash="$(sed -n '/pname = "epic-games-launcher";/,$p' "$gaming_file" | sed -n 's/^[[:space:]]*hash = "\([^"]*\)";.*/\1/p' | head -n 1)"

if [[ "$current_version" == "$version" ]]; then
  if [[ -n "$etag" ]]; then
    mkdir -p "$(dirname "$stamp")"
    printf '%s' "$etag" >"$stamp"
  fi
  printf 'Epic Games Launcher %s is already configured.\n' "$version"
  exit 0
fi

hash="$(nix store prefetch-file --json "$url" | jq -er '.hash')"
EPIC_VERSION="$version" EPIC_HASH="$hash" perl -0pi -e \
  's/(pname = "epic-games-launcher";\n\s+version = ")[^"]+(";\n\s+\};\n\s+pkgs\.stdenvNoCC\.mkDerivation \{.*?hash = ")[^"]+/$1$ENV{EPIC_VERSION}$2$ENV{EPIC_HASH}/s' \
  "$gaming_file"

if [[ "$(sed -n '/pname = "epic-games-launcher";/,/};/{s/^[[:space:]]*version = "\([^"]*\)";.*/\1/p;}' "$gaming_file" | head -n 1)" != "$version" ]] || \
  [[ "$(sed -n '/pname = "epic-games-launcher";/,$p' "$gaming_file" | sed -n 's/^[[:space:]]*hash = "\([^"]*\)";.*/\1/p' | head -n 1)" != "$hash" ]]; then
  printf 'Failed to update %s\n' "$gaming_file" >&2
  exit 1
fi

if [[ -n "$etag" ]]; then
  mkdir -p "$(dirname "$stamp")"
  printf '%s' "$etag" >"$stamp"
fi
printf 'Updated Epic Games Launcher to %s with hash %s in %s.\n' "$version" "$hash" "$gaming_file"
