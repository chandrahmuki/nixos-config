# Nix Flakes & Git Workflow

## The "Dirty" Rule
Nix Flakes only evaluate files that are **known to Git**. This is a security and reproducibility feature of the Flake evaluation sandbox.

### The Problem
If you create a new file (e.g., `modules/new-feature.nix`) and try to import it in `flake.nix` without adding it to Git, you will get an error:
`error: path '/nix/store/...-source/modules/new-feature.nix' does not exist`

Even though the file exists on your disk, Nix **only looks at the Git index**.

### The Solution: Surgical Staging
You must add the file to the Git index (staging area) even if you are not ready to commit it.

```bash
git add modules/new-feature.nix
```

> [!IMPORTANT]
> A simple `git add -N` (intent to add) is also sufficient for Nix to see the file without staging its entire content.

## Mandatory Agent Rule
When creating any new file or module in an active Nix Flake project:
1. **Immediately** run `git add <file>`.
2. Do not wait for the build command to fail.
3. This applies to `.nix` files, `secrets.yaml`, or any other asset referenced in the configuration.
