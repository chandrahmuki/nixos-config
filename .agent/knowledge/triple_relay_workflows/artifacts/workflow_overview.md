# Triple Relay Workflows

The Triple Relay system ensures code quality, architectural consistency, and knowledge retention by dividing responsibilities between three agentic roles.

## Roles
1. **Coder**: Focuses 100% on implementation and functional verification.
2. **Auditor (via `/audit`)**: Focuses 100% on code quality, cleanliness, and compliance with `GEMINI.md`.
3. **Archivist (via `/archive`)**: Focuses 100% on documentation and Knowledge Items (KI).

## Workflow Commands
- `/auto-doc`: Automates documentation synchronization after a major change.
- `/audit`: Triggers a code review by the Auditor.
- `/archive`: Triggers the Archiving process by the Archivist.

## Principles
- **Surgical Focus**: Tasks should be completed in 5-10 turns.
- **Surgical Metadata Only**: Avoid full file scans; prioritize `git show --stat` and direct `view_file`.
- **Zéro historique profond**: Limit `git log` to strict minimum (usually `-n 1`).
- **Knowledge Priority**: Updating Knowledge Items (KI) is prioritized over standard Markdown documentation.
- **Relay Handover**: The Coder passes the baton to the Auditor or Archivist once their part is done.
