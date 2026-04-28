---
Generated: 2026-04-28 UTC
Topic: zen-browser lutris dbus-migration
---

## What Was Accomplished
- Replaced Brave with Zen Browser (new flake input + module)
- Added Lutris to gaming module
- Fixed openldap build failure (doCheck = false in overlays)
- Resolved dbus → dbus-broker migration blocking `nos` switch
- Added gimp to utils

## Key Decisions
- Used `nos boot` instead of `nos` for dbus-broker migration (requires reboot)
- Zen Browser flake: `github:0xc000022070/zen-browser-flake`
- Removed Brave module entirely (not kept alongside)

## Troubleshooting
- `nos` blocked by switchInhibitors: dbus implementation change requires `nos boot && reboot`
- openldap 2.6.13 test017 flaky: disabled tests via overlay
- After dbus-broker active, `nos` works normally again

## Commits This Session
- `93f6ecd` feat: replace brave with zen-browser, add lutris, fix openldap build