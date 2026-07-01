# Lesson: Parsec multi-monitor issues on AMD/Mesa

## Context
When running Parsec (via XWayland) on an AMD GPU (RX 6800 XT), updating Mesa beyond version 26.1.2 completely breaks the dual-screen configuration. 
Furthermore, attempting to span Parsec across multiple monitors (even with scale 1x1 on both screens at 1080p) causes severe performance degradation ("hardware is not powerful enough" warning). This is caused by XWayland falling back to CPU software decoding because it cannot map the hardware-accelerated OpenGL/VA-API contexts across multiple physical monitors simultaneously.

## Actionable Guidelines
- **Mesa Pinning**: Keep Mesa system packages pinned to `nixpkgs-mesa` (commit `567a49d` / Mesa 26.1.2) in `modules/performance-tuning.nix`.
- **Future Checks**: During future system upgrades (`nix flake update`), check Mesa release notes and issues for XWayland multi-monitor hardware acceleration fixes before unpinning.
- **Usage Limitation**: Avoid stretching the Parsec client window across multiple monitors simultaneously under XWayland to prevent falling back to CPU software decoding.
