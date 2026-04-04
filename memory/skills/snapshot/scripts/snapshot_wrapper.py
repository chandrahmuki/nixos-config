#!/usr/bin/env python3
"""
Wrapper for /snapshot skill that Claude Code calls.
Receives session context and generates a snapshot.
"""

import json
import sys
import subprocess
from pathlib import Path
from datetime import datetime, timezone

def extract_session_context():
    """
    Extract key information from THIS session.
    Called by Claude with session summary data.
    """
    # Session data will be passed via stdin or environment
    session_data = {
        "decisions": [],
        "discoveries": [],
        "fixes": [],
        "modules_modified": [],
        "changes": [],
        "todos": [],
        "insights": []
    }

    # Read from stdin if available
    try:
        input_data = sys.stdin.read()
        if input_data.strip():
            # Try to parse as JSON first
            try:
                session_data = json.loads(input_data)
            except json.JSONDecodeError:
                # Otherwise treat as plain text analysis
                lines = input_data.split('\n')
                for line in lines:
                    if line.strip():
                        session_data["insights"].append(line.strip())
    except:
        pass

    return session_data

def create_snapshot(topic="session", session_context=None):
    """
    Create a snapshot by calling create_snapshot.py with session data.
    """
    script_path = Path(__file__).parent / "create_snapshot.py"

    # Write session data to temp file
    session_file = Path("/tmp") / f"session_{datetime.now(timezone.utc).timestamp()}.txt"

    if session_context:
        with open(session_file, 'w') as f:
            if isinstance(session_context, dict):
                json.dump(session_context, f)
            else:
                f.write(str(session_context))

    # Call create_snapshot.py
    cmd = [
        sys.executable,
        str(script_path),
        f"--topic={topic}",
        f"--session={session_file}"
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        return result.returncode == 0
    finally:
        # Cleanup
        if session_file.exists():
            session_file.unlink()

if __name__ == "__main__":
    topic = sys.argv[1] if len(sys.argv) > 1 else "session"
    context = extract_session_context()
    success = create_snapshot(topic, context)
    sys.exit(0 if success else 1)
