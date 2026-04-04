#!/usr/bin/env python3
"""
Create a COMPACT session snapshot from Claude Code session history.
Creates ONE single summary.md file (max ~2KB).
"""

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path
import re
import sys

MAX_SIZE_BYTES = 2048  # 2KB max


def get_memory_dir():
    """Get the memory directory path."""
    home = Path.home()
    return home / ".claude/projects/-home-david-nixos-config/memory"


def get_repo_root():
    """Get the NixOS config repository root."""
    home = Path.home()
    return home / "nixos-config"


def parse_git_log(num_commits=20):
    """
    Parse recent git log to extract commits with metadata.
    Returns list of dicts: {hash, message, author, date, files}
    """
    repo = get_repo_root()
    try:
        # Get recent commits with detailed format
        cmd = [
            "git",
            "-C",
            str(repo),
            "log",
            "--oneline",
            f"-{num_commits}",
            "--name-status",
            "--pretty=format:%H|%s|%an|%ai",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)

        commits = []
        lines = result.stdout.strip().split("\n")
        i = 0
        while i < len(lines):
            if "|" in lines[i]:
                parts = lines[i].split("|", 3)
                if len(parts) >= 2:
                    commit = {
                        "hash": parts[0][:7],
                        "message": parts[1],
                        "author": parts[2] if len(parts) > 2 else "unknown",
                        "date": parts[3] if len(parts) > 3 else "",
                        "files": [],
                    }
                    # Collect file changes for this commit
                    i += 1
                    while i < len(lines) and "|" not in lines[i] and lines[i].strip():
                        commit["files"].append(lines[i].strip())
                        i += 1
                    commits.append(commit)
                else:
                    i += 1
            else:
                i += 1
        return commits
    except Exception as e:
        print(f"Warning: couldn't parse git log: {e}")
        return []


def parse_session_history():
    """
    Parse git history to extract key information.
    Returns dict with decisions, fixes, modules, changes, todos, learnings.
    """

    findings = {
        "decisions": [],
        "fixes": [],
        "modules_added": [],
        "changes": [],
        "todos": [],
        "learnings": [],
        "summary": "",
    }

    commits = parse_git_log()
    if not commits:
        return findings

    # Pattern matching for commit types
    fix_pattern = re.compile(r"^fix(?:\([^)]+\))?:", re.IGNORECASE)
    feat_pattern = re.compile(r"^feat(?:\([^)]+\))?:", re.IGNORECASE)
    refactor_pattern = re.compile(r"^refactor(?:\([^)]+\))?:", re.IGNORECASE)
    module_pattern = re.compile(r"modules/|pkgs/", re.IGNORECASE)

    for commit in commits:
        msg = commit["message"]

        # Categorize by commit type
        if fix_pattern.match(msg):
            # Extract scope if available: fix(scope): message
            scope_match = re.match(r"fix\(([^)]+)\):\s*(.*)", msg)
            if scope_match:
                scope, detail = scope_match.groups()
                findings["fixes"].append(f"{detail} ({scope})")
            else:
                finding_msg = re.sub(r"^fix:\s*", "", msg)
                findings["fixes"].append(finding_msg)

        elif feat_pattern.match(msg):
            scope_match = re.match(r"feat\(([^)]+)\):\s*(.*)", msg)
            if scope_match:
                scope, detail = scope_match.groups()
                findings["decisions"].append(f"Added {detail} ({scope})")
            else:
                finding_msg = re.sub(r"^feat:\s*", "", msg)
                findings["decisions"].append(f"Added {finding_msg}")

        elif refactor_pattern.match(msg):
            finding_msg = re.sub(r"^refactor(?:\([^)]+\))?:\s*", "", msg)
            findings["changes"].append(finding_msg)

        # Check for module additions
        for file in commit["files"]:
            if "A\tmodules/" in file or file.startswith("modules/"):
                module_name = Path(file.split("\t")[-1]).stem
                if module_name not in findings["modules_added"]:
                    findings["modules_added"].append(module_name)

        # Check for decision keywords in commit message
        if any(
            kw in msg.lower()
            for kw in ["switched", "changed", "architecture", "approach"]
        ):
            if msg not in findings["decisions"]:
                findings["decisions"].append(msg)

    # Generate summary
    if commits:
        findings["summary"] = (
            f"Session involved {len(commits)} commits. Main focus: {commits[0]['message']}"
        )

    return findings


def create_snapshot_directory(topic=None):
    """Create the session snapshot directory with appropriate timestamp."""
    memory_dir = get_memory_dir()

    # Generate topic from timestamp if not provided
    if not topic:
        topic = "session"

    # Create dated folder: YYYY-MM-DD_topic
    now = datetime.now(timezone.utc)
    date_str = now.strftime("%Y-%m-%d")
    folder_name = f"{date_str}_{topic}"
    snapshot_dir = memory_dir / "sessions" / folder_name

    # Ensure it doesn't exist already
    counter = 1
    original_folder = snapshot_dir
    while snapshot_dir.exists():
        folder_name = f"{date_str}_{topic}-{counter}"
        snapshot_dir = memory_dir / "sessions" / folder_name
        counter += 1

    snapshot_dir.mkdir(parents=True, exist_ok=True)
    return snapshot_dir, folder_name


def write_summary_file(filepath, findings, topic):
    """Write a SINGLE compact summary.md file."""
    now = datetime.now(timezone.utc)

    content = f"""---
Generated: {now.strftime("%Y-%m-%d %H:%M UTC")}
Topic: {topic}
---

## What Was Accomplished
"""
    # Max 5 bullets per section
    if findings.get("summary"):
        content += f"- {findings['summary']}\n"

    if findings.get("decisions"):
        content += "\n## Decisions Made\n"
        for item in findings["decisions"][:5]:
            content += f"- {item}\n"

    if findings.get("fixes"):
        content += "\n## Fixes\n"
        for item in findings["fixes"][:5]:
            content += f"- {item}\n"

    if findings.get("modules_added"):
        content += "\n## Modules Added\n"
        for item in findings["modules_added"][:5]:
            content += f"- {item}\n"

    if findings.get("changes"):
        content += "\n## Changes\n"
        for item in findings["changes"][:5]:
            content += f"- {item}\n"

    content += f"\n(End of file)\n"

    # Size check
    size = len(content.encode("utf-8"))
    if size > MAX_SIZE_BYTES:
        raise ValueError(f"Snapshot trop gros: {size} bytes (max: {MAX_SIZE_BYTES})")

    filepath.write_text(content)
    return size


def update_index_sessions(snapshot_folder, summary=""):
    """Update index_sessions.md with new snapshot entry."""
    memory_dir = get_memory_dir()
    index_file = memory_dir / "index_sessions.md"

    # Create or read existing index
    if index_file.exists():
        content = index_file.read_text()
    else:
        content = "# Session Snapshots\n\n"

    # Parse date from folder name (YYYY-MM-DD_topic)
    date_part = snapshot_folder.split("_")[0]
    topic_part = "_".join(snapshot_folder.split("_")[1:])

    # Add new entry (group by date)
    if f"## {date_part}" not in content:
        content += f"\n## {date_part}\n\n"

    summary_text = f" — {summary}" if summary else ""
    entry = f"- [{topic_part}](sessions/{snapshot_folder}/){summary_text}\n"

    # Insert after the date header
    lines = content.split("\n")
    for i, line in enumerate(lines):
        if line == f"## {date_part}":
            # Insert after this header (skip blank line if exists)
            if i + 1 < len(lines) and lines[i + 1] == "":
                lines.insert(i + 2, entry)
            else:
                lines.insert(i + 1, entry)
            break

    index_file.write_text("\n".join(lines))


def ensure_memory_structure():
    """Ensure the base memory directory structure exists."""
    memory_dir = get_memory_dir()

    # Create base directories
    (memory_dir / "sessions").mkdir(parents=True, exist_ok=True)

    # Create MEMORY.md if it doesn't exist
    memory_file = memory_dir / "MEMORY.md"
    if not memory_file.exists():
        memory_file.write_text("""# Project Memory Index

- [Sessions](index_sessions.md) — List of all session snapshots
- [User Profile](user_profile.md) — Your role and preferences
- [Feedback & Patterns](feedback.md) — How to work with you
""")


def extract_session_data_from_input():
    """
    Extract session data from stdin (JSON format).
    Claude Code will pass conversation data here.
    """
    try:
        input_data = json.loads(sys.stdin.read())
        return input_data
    except (json.JSONDecodeError, EOFError):
        return None


def analyze_session_text(session_text):
    """
    Analyze raw session text to extract decisions, fixes, modules, changes, todos, learnings.
    """
    findings = {
        "decisions": [],
        "fixes": [],
        "modules_added": [],
        "changes": [],
        "todos": [],
        "learnings": [],
        "tasks": [],
    }

    if not session_text:
        return findings

    lines = session_text.split("\n")

    # Pattern matching for various extraction types
    for i, line in enumerate(lines):
        lower_line = line.lower()

        # Decisions
        if any(
            kw in lower_line
            for kw in [
                "decided",
                "decision:",
                "chose",
                "switching to",
                "changed to",
                "approach:",
                "architecture:",
            ]
        ):
            if line.strip() and len(line.strip()) > 10:
                findings["decisions"].append(line.strip())

        # Fixes
        if any(
            kw in lower_line
            for kw in ["fix(", "fixed", "bug fix", "resolved", "issue fixed"]
        ):
            if line.strip() and len(line.strip()) > 10:
                findings["fixes"].append(line.strip())

        # New modules/files
        if any(
            kw in lower_line
            for kw in [
                "created",
                "added module",
                "new file",
                "modules/",
                "wrote",
                "created .nix",
            ]
        ):
            if "module" in lower_line or ".nix" in line:
                findings["modules_added"].append(line.strip())

        # Configuration changes
        if any(
            kw in lower_line
            for kw in [
                "modified",
                "updated config",
                "changed config",
                "refactored",
                "configuration change",
            ]
        ):
            if line.strip() and len(line.strip()) > 10:
                findings["changes"].append(line.strip())

        # TODOs
        if any(
            kw in lower_line
            for kw in ["todo:", "need to", "should", "remaining work", "next:"]
        ):
            if line.strip() and len(line.strip()) > 5:
                findings["todos"].append(line.strip())

        # Learnings/discoveries
        if any(
            kw in lower_line
            for kw in [
                "discovered",
                "learned",
                "found that",
                "turns out",
                "pain point",
                "insight",
            ]
        ):
            if line.strip() and len(line.strip()) > 10:
                findings["learnings"].append(line.strip())

    # Deduplicate
    for key in findings:
        findings[key] = list(dict.fromkeys(findings[key]))[:10]  # Keep top 10 of each

    return findings


def format_findings(findings):
    """Convert findings dict to formatted sections for markdown."""
    sections = {}

    if findings["decisions"]:
        sections["Decisions"] = findings["decisions"]

    if findings["fixes"]:
        sections["Fixes"] = findings["fixes"]

    if findings["modules_added"]:
        sections["Modules Added"] = findings["modules_added"]

    if findings["changes"]:
        sections["Configuration Changes"] = findings["changes"]

    if findings["todos"]:
        sections["Remaining Tasks"] = findings["todos"]

    if findings["learnings"]:
        sections["Key Learnings"] = findings["learnings"]

    return sections


def main():
    """Main entry point for snapshot creation."""

    # Parse arguments
    topic = None
    session_data_file = None

    for arg in sys.argv[1:]:
        if arg.startswith("--topic="):
            topic = arg.split("=", 1)[1]
        elif arg.startswith("--session="):
            session_data_file = arg.split("=", 1)[1]

    if not topic:
        topic = "session"

    # Ensure structure exists
    ensure_memory_structure()

    # Create snapshot directory
    snapshot_dir, folder_name = create_snapshot_directory(topic)

    # Get session data if provided (highest priority)
    all_findings = {
        "decisions": [],
        "fixes": [],
        "modules_added": [],
        "changes": [],
        "todos": [],
        "learnings": [],
        "summary": "",
    }

    if session_data_file and Path(session_data_file).exists():
        try:
            with open(session_data_file) as f:
                content = f.read()
                # Try JSON first
                try:
                    session_data = json.loads(content)
                    # Direct mapping of keys
                    if isinstance(session_data, dict):
                        all_findings["decisions"] = session_data.get("decisions", [])
                        all_findings["fixes"] = session_data.get("fixes", [])
                        all_findings["modules_added"] = session_data.get(
                            "modules_modified", []
                        ) or session_data.get("modules_added", [])
                        all_findings["changes"] = session_data.get("changes", [])
                        all_findings["todos"] = session_data.get("todos", [])
                        all_findings["learnings"] = session_data.get(
                            "insights", []
                        ) or session_data.get("learnings", [])
                        all_findings["summary"] = session_data.get(
                            "summary", "Session snapshot"
                        )
                except json.JSONDecodeError:
                    # Fallback to text analysis
                    session_findings = analyze_session_text(content)
                    all_findings = session_findings
        except Exception as e:
            print(f"Warning: couldn't read session data: {e}")

    # Fallback to git history if no session data provided
    if not any(
        all_findings[k] for k in ["decisions", "fixes", "modules_added", "changes"]
    ):
        git_findings = parse_session_history()
        all_findings = git_findings

    # Create ONE summary.md file
    summary_file = snapshot_dir / "summary.md"
    try:
        size = write_summary_file(summary_file, all_findings, topic)
    except ValueError as e:
        print(f"ERROR: {e}")
        print("Réduis le contenu et réessaye.")
        # Clean up the directory
        if snapshot_dir.exists():
            snapshot_dir.rmdir()
        return None

    # Update index
    update_index_sessions(folder_name, summary=f"Snapshot: {topic}")

    print(f"✓ Snapshot created: {snapshot_dir}")
    print(f"✓ Size: {size} bytes")
    print(f"✓ Updated index_sessions.md")
    return str(snapshot_dir)


if __name__ == "__main__":
    main()
