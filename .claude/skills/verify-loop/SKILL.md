---
name: verify-loop
description: Run a task as a self-verifying loop (criterion first, reproduce, one change, prove it on the real new version, repeat) so the user no longer has to be the tester. Use for any change whose result can be observed or measured - UI, service, package, shortcut, config.
user-invocable: true
argument-hint: <task>
---

# verify-loop

The agent hands the task back only when its own test passes, or when it is blocked and can show why. The user keeps the final acceptance on the real session, not the debugging.

Follows `AGENTS.md` (proof levels, final report). Never test in the user's live session while they work: use `scripts/vm-test.sh` and always `stop` it.

## The loop

1. **Criterion first.** Write what must be observable or measurable, before touching code: elements and their order, states (open/closed/hover), a command and its expected output, a unit and its journal. If it cannot be stated, ask the user one precise question.
2. **Reproduce.** Run the exact scenario on the current state and capture the symptom (screenshot, output, log). No reproduction, no fix: an unreproduced symptom means the test is wrong.
3. **Hypothesis, then one variable.** State it as a hypothesis. Change one thing. A cause is "proven" only when that single change moves the symptom as predicted.
4. **Prove the test sees the new version.** Before reading any result, show what is actually running: process start time vs. file edit time, store path, loaded config, PID. A run on the old code proves nothing; do not conclude "hypothesis wrong" from it.
5. **Replay the same scenario**, then on a fresh instance (and, if the thing hot-reloads, on an already-open instance). Read the evidence yourself (open the screenshot, read the log); a file existing is not a result.
6. **Cap and stop.** Max 5 iterations. After two comparable failures, stop adjusting locally and widen the diagnosis. If blocked, report the exact blocker and the evidence, not a partial success.
7. **Clean up** (stop the VM, no stray processes or files), run `git diff --check` and `nix flake check`, then give the `AGENTS.md` final report. State plainly what is inspected, built, activated, tested, or not verified.

## What the agent does not do

- Declare done after an edit, an eval or a build.
- Restart the user's live Quickshell/Hyprland, or commit, without the user's go-ahead.
- Delegate the final acceptance to a sub-agent.
- Decide a physical step (voice, plugging a device, taste) is passed: automate everything else, ask for one precise action, then inspect immediately.

## Domain notes (load only the one you need)

- Visual interface (Quickshell, Hyprland, widgets, panels): `references/ui.md`
