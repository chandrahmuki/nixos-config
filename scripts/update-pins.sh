#!/usr/bin/env bash
# Update every package pinned by hand (version and hash in aspects/*.nix) to its latest
# release. Run by `nos` before the switch. A pin that cannot be checked (offline, API
# error) is reported and skipped, it never blocks the switch.
#
# Not covered: the Epic Games Launcher (aspects/gaming.nix), whose AppImage URL embeds a
# build id that Epic does not publish; update it by hand when its build fails.
set -u

scripts="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
failed=0

for updater in update-codex.sh update-antigravity-cli.sh update-chatgpt.sh; do
  if ! "$scripts/$updater"; then
    printf 'update-pins: %s failed, the pin keeps its current version\n' "$updater" >&2
    failed=1
  fi
done

exit "$failed"
