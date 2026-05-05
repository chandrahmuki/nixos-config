#!/usr/bin/env python3
import sqlite3
import os

DB_PATH = os.path.join(os.environ.get("PROJECT_ROOT", "/home/david/nixos-config"), ".omnigraph", "graph.db")

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()

c.executescript("""
DROP TABLE IF EXISTS annotations;
DROP TABLE IF EXISTS edges;
DROP TABLE IF EXISTS nodes;

CREATE TABLE nodes (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    label TEXT NOT NULL,
    file_path TEXT,
    line_number INTEGER,
    content_hash TEXT
);
CREATE INDEX idx_nodes_type ON nodes(type);
CREATE INDEX idx_nodes_file ON nodes(file_path);

CREATE TABLE edges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_id TEXT NOT NULL,
    to_id TEXT NOT NULL,
    type TEXT NOT NULL,
    confidence TEXT DEFAULT 'auto',
    UNIQUE(from_id, to_id, type)
);
CREATE INDEX idx_edges_from ON edges(from_id);
CREATE INDEX idx_edges_to ON edges(to_id);

CREATE TABLE annotations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    node_id TEXT NOT NULL,
    key TEXT NOT NULL,
    value TEXT NOT NULL
);
CREATE INDEX idx_annotations_node ON annotations(node_id);
""")

def add_node(id, type, label, file_path=None, line_number=None):
    c.execute("INSERT OR IGNORE INTO nodes (id, type, label, file_path, line_number) VALUES (?,?,?,?,?)",
              (id, type, label, file_path, line_number))

def add_edge(from_id, to_id, type, confidence="auto"):
    c.execute("INSERT OR IGNORE INTO edges (from_id, to_id, type, confidence) VALUES (?,?,?,?)",
              (from_id, to_id, type, confidence))

# ── FILES ──
nix_files = {
    "flake.nix": "flake.nix",
    "home.nix": "home.nix",
    "overlays.nix": "overlays.nix",
    "hosts/system/default.nix": "hosts/system/default.nix",
    "hosts/system/hardware-configuration.nix": "hosts/system/hardware-configuration.nix",
    "lib/colors.nix": "lib/colors.nix",
    "modules/default.nix": "modules/default.nix",
    "modules/ai.nix": "modules/ai.nix",
    "modules/backup.nix": "modules/backup.nix",
    "modules/bluetooth.nix": "modules/bluetooth.nix",
    "modules/btop.nix": "modules/btop.nix",
    "modules/direnv.nix": "modules/direnv.nix",
    "modules/discord.nix": "modules/discord.nix",
    "modules/font.nix": "modules/font.nix",
    "modules/gaming.nix": "modules/gaming.nix",
    "modules/git.nix": "modules/git.nix",
    "modules/irc.nix": "modules/irc.nix",
    "modules/media.nix": "modules/media.nix",
    "modules/microfetch.nix": "modules/microfetch.nix",
    "modules/nautilus.nix": "modules/nautilus.nix",
    "modules/neovim.nix": "modules/neovim.nix",
    "modules/nh.nix": "modules/nh.nix",
    "modules/niri.nix": "modules/niri.nix",
    "modules/noctalia.nix": "modules/noctalia.nix",
    "modules/notifications.nix": "modules/notifications.nix",
    "modules/obsidian.nix": "modules/obsidian.nix",
    "modules/parsec.nix": "modules/parsec.nix",
    "modules/pdf.nix": "modules/pdf.nix",
    "modules/performance-tuning.nix": "modules/performance-tuning.nix",
    "modules/secrets.nix": "modules/secrets.nix",
    "modules/tealdeer.nix": "modules/tealdeer.nix",
    "modules/terminal.nix": "modules/terminal.nix",
    "modules/theme.nix": "modules/theme.nix",
    "modules/utils.nix": "modules/utils.nix",
    "modules/vscode.nix": "modules/vscode.nix",
    "modules/walker.nix": "modules/walker.nix",
    "modules/xdg.nix": "modules/xdg.nix",
    "modules/yazi.nix": "modules/yazi.nix",
    "modules/zellij.nix": "modules/zellij.nix",
    "modules/zen-browser.nix": "modules/zen-browser.nix",
}
for fid, fp in nix_files.items():
    add_node(fid, "file", fid, fp)

# ── DATA FILES ──
data_files = {
    "secrets/secrets.yaml": "secrets/secrets.yaml",
    "generated/noctalia-settings.json": "generated/noctalia-settings.json",
    "generated/yazi.toml": "generated/yazi.toml",
    "nvim/": "nvim/",
    ".agent/gemini-settings.json": ".agent/gemini-settings.json",
}
for fid, fp in data_files.items():
    add_node(fid, "file", fid, fp)

# ── FLAKE INPUTS ──
flake_inputs = [
    ("inputs.nixpkgs", "nixpkgs"),
    ("inputs.nixpkgs-master", "nixpkgs-master"),
    ("inputs.home-manager", "home-manager"),
    ("inputs.niri", "niri"),
    ("inputs.noctalia", "noctalia"),
    ("inputs.nix-cachyos", "nix-cachyos"),
    ("inputs.elephant", "elephant"),
    ("inputs.walker", "walker"),
    ("inputs.sops-nix", "sops-nix"),
    ("inputs.opencode", "opencode"),
    ("inputs.zen-browser", "zen-browser"),
]
for iid, lbl in flake_inputs:
    add_node(iid, "input", lbl)

# ── OPTIONS (cross-module) ──
cross_options = [
    ("sops.secrets.github_token", "sops.secrets.github_token"),
    ("sops.secrets.gemini_api_key", "sops.secrets.gemini_api_key"),
    ("programs.fish.shellAliases", "programs.fish.shellAliases"),
    ("programs.fish.functions", "programs.fish.functions"),
    ("programs.fish.interactiveShellInit", "programs.fish.interactiveShellInit"),
    ("programs.niri.settings", "programs.niri.settings"),
    ("programs.noctalia-shell", "programs.noctalia-shell"),
    ("fonts.packages", "fonts.packages"),
    ("hardware.graphics", "hardware.graphics"),
    ("home.packages", "home.packages"),
    ("gtk.theme", "gtk.theme"),
    ("xdg.portal", "xdg.portal"),
    ("environment.sessionVariables", "environment.sessionVariables"),
    ("nixpkgs.overlays", "nixpkgs.overlays"),
]
for oid, lbl in cross_options:
    add_node(oid, "option", lbl)

# ── SESSIONS ──
sessions = [
    "2026-04-03_context-optimization-test",
    "2026-04-03_cost-optimization",
    "2026-04-03_flake-update-deno-fix",
    "2026-04-03_knowledge-migration",
    "2026-04-03_memory-context-fix",
    "2026-04-03_memory-optimization",
    "2026-04-03_memory-refactor",
    "2026-04-03_mpv-music-fix",
    "2026-04-03_nix-optimisations",
    "2026-04-03_opencode-install",
    "2026-04-03_persistence-tokens",
    "2026-04-03_project-map-skills",
    "2026-04-03_reactivate-skills-mcp",
    "2026-04-03_refactor-claude-docs",
    "2026-04-03_session-resume_fix",
    "2026-04-03_session-resume-fix-v2",
    "2026-04-03_session-resume-fix",
    "2026-04-03_skill-update",
    "2026-04-03_snapshot-implementation",
    "2026-04-03_snapshot-skill",
    "2026-04-03_zellij-layout",
    "2026-04-03_zellij-opencode",
    "2026-04-03_zjstatus-fix",
    "2026-04-04_gpu-screen-recorder",
    "2026-04-04_memory-consolidation",
    "2026-04-04_zellij_layout",
    "2026-04-04_zellij-fullscreen-fix",
    "2026-04-04_zellij-fullscreen",
    "2026-04-04_zellij-theme-customization",
    "2026-04-06_readme-sly-harvey-style",
    "2026-04-06_skills-superpowers",
    "2026-04-07_gsd-superpowers-integration",
    "2026-04-07_minifiles-explorer",
    "2026-04-07_minifiles-v2",
    "2026-04-08_codebase-rearchitecture",
    "2026-04-08_gemini-rules",
    "2026-04-08_minifiles-enter",
    "2026-04-08_opencode-flake",
    "2026-04-08_project-map-reference",
    "2026-04-08_rearchitecture-complete",
    "2026-04-10_lint-agents",
    "2026-04-11_aria2-lint-agents",
    "2026-04-14_thunar-replace",
    "2026-04-21_noctalia-opencode-fix",
    "2026-04-21_noctalia-shell-launch-fix",
    "2026-04-23_opencode-unpin",
    "2026-04-24_neovim-modernization",
    "2026-04-25_discord-screenshare",
    "2026-04-25_neovim-explorer-fix",
    "2026-04-26_thunar-nautilus-rtk",
    "2026-04-28_zen-browser-lutris-dbus",
    "2026-05-04_omnigraph-creation",
    "2026-05-04_omnigraph-fix-viz",
    "2026-05-04_zen-browser-deno-overlay",
]
for s in sessions:
    add_node(s, "session", s, f"memory/sessions/{s}/summary.md")

# ── LESSONS ──
lessons = [
    "nix-modules",
    "nix-flakes",
    "nix-build",
    "nixos-store",
    "neovim",
    "git-workflow",
    "dev-tools",
]
for l in lessons:
    add_node(l, "lesson", l, f"memory/lessons/{l}.md")

# ── SKILLS ──
skills = [
    "project-map",
    "snapshot",
    "find-skills",
]
for s in skills:
    add_node(s, "skill", s, f"memory/skills/{s}/SKILL.md")

# ── INDEXES ──
add_node("memory/index_sessions.md", "file", "index_sessions", "memory/index_sessions.md")
add_node("memory/index_lessons.md", "file", "index_lessons", "memory/index_lessons.md")

# ══════════════════════════════════════════════════════════════
# EDGES
# ══════════════════════════════════════════════════════════════

# ── imports (code → code) ──
add_edge("flake.nix", "home.nix", "imports")
add_edge("flake.nix", "hosts/system/default.nix", "imports")
add_edge("flake.nix", "overlays.nix", "imports")
add_edge("hosts/system/default.nix", "hosts/system/hardware-configuration.nix", "imports")
add_edge("hosts/system/default.nix", "modules/default.nix", "imports")

# modules/default.nix dynamically imports all siblings
for m in nix_files:
    if m.startswith("modules/") and m != "modules/default.nix":
        add_edge("modules/default.nix", m, "imports")

# ── uses_input (module → flake input) ──
add_edge("modules/ai.nix", "inputs.nixpkgs-master", "uses_input")
add_edge("modules/niri.nix", "inputs.niri", "uses_input")
add_edge("modules/noctalia.nix", "inputs.noctalia", "uses_input")
add_edge("modules/walker.nix", "inputs.walker", "uses_input")
add_edge("modules/secrets.nix", "inputs.sops-nix", "uses_input")
add_edge("modules/zen-browser.nix", "inputs.zen-browser", "uses_input")
add_edge("overlays.nix", "inputs.niri", "uses_input")
add_edge("hosts/system/default.nix", "inputs.nix-cachyos", "uses_input")
add_edge("hosts/system/default.nix", "inputs.nixpkgs", "uses_input")
add_edge("flake.nix", "inputs.nixpkgs", "uses_input")
add_edge("flake.nix", "inputs.nixpkgs-master", "uses_input")
add_edge("flake.nix", "inputs.home-manager", "uses_input")
add_edge("flake.nix", "inputs.niri", "uses_input")
add_edge("flake.nix", "inputs.noctalia", "uses_input")
add_edge("flake.nix", "inputs.nix-cachyos", "uses_input")
add_edge("flake.nix", "inputs.elephant", "uses_input")
add_edge("flake.nix", "inputs.walker", "uses_input")
add_edge("flake.nix", "inputs.sops-nix", "uses_input")
add_edge("flake.nix", "inputs.opencode", "uses_input")
add_edge("flake.nix", "inputs.zen-browser", "uses_input")

# ── uses_colors (module → lib/colors.nix) ──
add_edge("modules/terminal.nix", "lib/colors.nix", "uses_colors")
add_edge("modules/zen-browser.nix", "lib/colors.nix", "uses_colors")

# ── references_secrets (module → secrets file) ──
add_edge("modules/secrets.nix", "secrets/secrets.yaml", "references_secrets")

# ── references_generated (module → generated file) ──
add_edge("modules/noctalia.nix", "generated/noctalia-settings.json", "references_generated")
add_edge("modules/yazi.nix", "generated/yazi.toml", "references_generated")

# ── provides_option (module → option) ──
add_edge("modules/secrets.nix", "sops.secrets.github_token", "provides_option")
add_edge("modules/secrets.nix", "sops.secrets.gemini_api_key", "provides_option")
add_edge("modules/niri.nix", "programs.niri.settings", "provides_option")
add_edge("modules/noctalia.nix", "programs.noctalia-shell", "provides_option")
add_edge("modules/terminal.nix", "programs.fish.shellAliases", "provides_option")
add_edge("modules/terminal.nix", "programs.fish.functions", "provides_option")
add_edge("modules/terminal.nix", "programs.fish.interactiveShellInit", "provides_option")
add_edge("modules/terminal.nix", "gtk.theme", "provides_option")
add_edge("modules/theme.nix", "gtk.theme", "provides_option")
add_edge("modules/font.nix", "fonts.packages", "provides_option")
add_edge("hosts/system/default.nix", "hardware.graphics", "provides_option")
add_edge("hosts/system/default.nix", "xdg.portal", "provides_option")
add_edge("hosts/system/default.nix", "environment.sessionVariables", "provides_option")
add_edge("overlays.nix", "nixpkgs.overlays", "provides_option")
add_edge("modules/nh.nix", "programs.fish.functions", "provides_option")
add_edge("modules/media.nix", "programs.fish.functions", "provides_option")
add_edge("modules/utils.nix", "programs.fish.functions", "provides_option")
add_edge("modules/zellij.nix", "programs.fish.shellAliases", "provides_option")
add_edge("modules/zellij.nix", "programs.fish.functions", "provides_option")

# ── consumes_option (module → option) ──
add_edge("modules/niri.nix", "programs.fish.shellAliases", "consumes_option")
add_edge("modules/niri.nix", "programs.noctalia-shell", "consumes_option")
add_edge("modules/niri.nix", "hardware.graphics", "consumes_option")
add_edge("modules/gaming.nix", "hardware.graphics", "consumes_option")
add_edge("modules/gaming.nix", "environment.sessionVariables", "consumes_option")
add_edge("modules/performance-tuning.nix", "hardware.graphics", "consumes_option")
add_edge("modules/performance-tuning.nix", "environment.sessionVariables", "consumes_option")
add_edge("modules/terminal.nix", "fonts.packages", "consumes_option")
add_edge("modules/ai.nix", "sops.secrets.github_token", "consumes_option")
add_edge("modules/terminal.nix", "sops.secrets.github_token", "consumes_option")
add_edge("modules/terminal.nix", "sops.secrets.gemini_api_key", "consumes_option")
add_edge("modules/theme.nix", "environment.sessionVariables", "consumes_option")
add_edge("modules/noctalia.nix", "programs.niri.settings", "consumes_option")

# ── session_modified (session → module) ──
session_mods = {
    "2026-04-03_flake-update-deno-fix": ["modules/ai.nix", "overlays.nix"],
    "2026-04-03_mpv-music-fix": ["modules/media.nix"],
    "2026-04-03_nix-optimisations": ["modules/performance-tuning.nix"],
    "2026-04-03_opencode-install": ["modules/ai.nix"],
    "2026-04-03_skill-update": ["modules/zellij.nix", "flake.nix"],
    "2026-04-03_zellij-layout": ["modules/zellij.nix"],
    "2026-04-03_zellij-opencode": ["modules/zellij.nix"],
    "2026-04-03_zjstatus-fix": ["modules/zellij.nix"],
    "2026-04-04_gpu-screen-recorder": ["modules/gaming.nix"],
    "2026-04-04_zellij-fullscreen-fix": ["modules/zellij.nix"],
    "2026-04-04_zellij-fullscreen": ["modules/zellij.nix"],
    "2026-04-04_zellij_layout": ["modules/zellij.nix"],
    "2026-04-04_zellij-theme-customization": ["modules/zellij.nix"],
    "2026-04-08_gemini-rules": ["modules/ai.nix"],
    "2026-04-08_opencode-flake": ["flake.nix", "overlays.nix"],
    "2026-04-08_rearchitecture-complete": ["modules/ai.nix", "modules/gaming.nix", "modules/media.nix", "lib/colors.nix", "modules/terminal.nix", "modules/utils.nix", "modules/git.nix", "modules/neovim.nix"],
    "2026-04-10_lint-agents": ["modules/neovim.nix"],
    "2026-04-11_aria2-lint-agents": ["modules/utils.nix", "modules/neovim.nix"],
    "2026-04-14_thunar-replace": ["modules/nautilus.nix", "modules/theme.nix"],
    "2026-04-21_noctalia-opencode-fix": ["modules/noctalia.nix", "overlays.nix"],
    "2026-04-21_noctalia-shell-launch-fix": ["modules/niri.nix", "modules/walker.nix"],
    "2026-04-23_opencode-unpin": ["overlays.nix"],
    "2026-04-24_neovim-modernization": ["modules/neovim.nix"],
    "2026-04-25_discord-screenshare": ["modules/niri.nix", "modules/discord.nix"],
    "2026-04-25_neovim-explorer-fix": ["modules/neovim.nix"],
    "2026-04-26_thunar-nautilus-rtk": ["modules/nautilus.nix", "modules/utils.nix"],
    "2026-04-28_zen-browser-lutris-dbus": ["modules/zen-browser.nix", "modules/gaming.nix", "overlays.nix", "modules/utils.nix"],
    "2026-05-04_omnigraph-creation": ["modules/utils.nix"],
    "2026-05-04_zen-browser-deno-overlay": ["flake.nix", "modules/xdg.nix", "modules/niri.nix", "overlays.nix"],
}
for s, mods in session_mods.items():
    for m in mods:
        add_edge(s, m, "session_modified")

# ── session_produced (session → lesson/skill) ──
add_edge("2026-04-24_neovim-modernization", "neovim", "session_produced")
add_edge("2026-04-24_neovim-modernization", "nix-modules", "session_produced")
add_edge("2026-04-25_neovim-explorer-fix", "neovim", "session_produced")
add_edge("2026-05-04_omnigraph-creation", "dev-tools", "session_produced")
add_edge("2026-05-04_omnigraph-fix-viz", "dev-tools", "session_produced")
add_edge("2026-04-03_project-map-skills", "project-map", "session_produced")
add_edge("2026-04-03_snapshot-skill", "snapshot", "session_produced")
add_edge("2026-04-08_project-map-reference", "project-map", "session_produced")

# ── lesson_applies_to (lesson → module/concept) ──
add_edge("nix-modules", "modules/default.nix", "lesson_applies_to")
add_edge("nix-modules", "modules/zen-browser.nix", "lesson_applies_to")
add_edge("nix-flakes", "flake.nix", "lesson_applies_to")
add_edge("nix-build", "overlays.nix", "lesson_applies_to")
add_edge("neovim", "modules/neovim.nix", "lesson_applies_to")
add_edge("git-workflow", "modules/git.nix", "lesson_applies_to")
add_edge("dev-tools", "modules/utils.nix", "lesson_applies_to")

# ── indexes (index → item) ──
for s in sessions:
    add_edge("memory/index_sessions.md", s, "indexes")
add_edge("memory/index_lessons.md", "nix-modules", "indexes")
add_edge("memory/index_lessons.md", "nix-flakes", "indexes")
add_edge("memory/index_lessons.md", "nix-build", "indexes")
add_edge("memory/index_lessons.md", "nixos-store", "indexes")
add_edge("memory/index_lessons.md", "neovim", "indexes")
add_edge("memory/index_lessons.md", "git-workflow", "indexes")
add_edge("memory/index_lessons.md", "dev-tools", "indexes")

# ── uses_module (module → external flake module) ──
add_edge("modules/niri.nix", "inputs.niri", "uses_module")
add_edge("modules/noctalia.nix", "inputs.noctalia", "uses_module")
add_edge("modules/walker.nix", "inputs.walker", "uses_module")
add_edge("modules/secrets.nix", "inputs.sops-nix", "uses_module")
add_edge("modules/zen-browser.nix", "inputs.zen-browser", "uses_module")

conn.commit()

# ── STATS ──
print("=== Node counts by type ===")
for row in c.execute("SELECT type, COUNT(*) FROM nodes GROUP BY type ORDER BY COUNT(*) DESC"):
    print(f"  {row[0]}: {row[1]}")

print("\n=== Edge counts by type ===")
for row in c.execute("SELECT type, COUNT(*) FROM edges GROUP BY type ORDER BY COUNT(*) DESC"):
    print(f"  {row[0]}: {row[1]}")

print(f"\nTotal nodes: {c.execute('SELECT COUNT(*) FROM nodes').fetchone()[0]}")
print(f"Total edges: {c.execute('SELECT COUNT(*) FROM edges').fetchone()[0]}")

conn.close()
