#!/usr/bin/env python3
import sys
import re
import json
import os
import requests
from bs4 import BeautifulSoup

def scrape_mcp(url):
    print(f"Fetching {url}...")
    response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
    response.raise_for_status()
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Heuristic for Skill.fish
    if "skill.fish" in url:
        # Look for code blocks or specific command patterns
        code_blocks = soup.find_all('pre')
        for block in code_blocks:
            text = block.get_text().strip()
            if "npx" in text or "uvx" in text:
                return parse_command(text)
    
    # Generic extraction
    code_elements = soup.find_all(['code', 'pre'])
    for elem in code_elements:
        text = elem.get_text().strip()
        if "npx" in text or "uvx" in text:
            # Clean up (sometimes it's multiline or has comments)
            lines = [l for l in text.split('\n') if 'npx' in l or 'uvx' in l]
            if lines:
                return parse_command(lines[0])
                
    return None

def parse_command(cmd_str):
    # Remove bash characters and extra quotes
    cmd_str = cmd_str.replace('\\', '').replace('\n', ' ').strip()
    # Basic space split (could be more robust with shlex)
    parts = cmd_str.split()
    
    if not parts:
        return None

    # Basic extraction
    if parts[0] in ["npx", "uvx"]:
        command = parts[0]
        args = [p.strip('"').strip("'") for p in parts[1:]]
        # Extract server name as label
        name = args[-1].split('/')[-1].replace('server', '').replace('@modelcontextprotocol/', '').strip('-')
        if name.startswith('-') or name == '': 
             name = "mcp-server"
        
        # Avoid reserved names or weird chars
        name = re.sub(r'[^a-zA-Z0-1_-]', '', name)
        
        return {
            "name": name,
            "command": command,
            "args": args,
            "env": {}
        }
    return None

def update_antigravity(config_path, mcp_data):
    if not os.path.exists(config_path):
        config = {"mcpServers": {}}
    else:
        with open(config_path, 'r') as f:
            config = json.load(f)
    
    config["mcpServers"][mcp_data["name"]] = {
        "command": mcp_data["command"],
        "args": mcp_data["args"],
        "env": mcp_data["env"]
    }
    
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    print(f"Updated Antigravity config: {config_path}")

def update_gemini(nix_path, mcp_data):
    with open(nix_path, 'r') as f:
        content = f.read()
    
    # Find mcpServers = { ... };
    # We use the markers MCP_CONFIG_START and MCP_CONFIG_END
    pattern = re.compile(r'(# MCP_CONFIG_START\s+mcpServers = \{)(.*?)(\};?\s+# MCP_CONFIG_END)', re.DOTALL)
    match = pattern.search(content)
    
    if not match:
        print("Error: Could not find MCP markers in gemini.nix")
        return

    mcp_block = match.group(2)
    
    # Simple check if already exists
    if f'"{mcp_data["name"]}"' in mcp_block or f'{mcp_data["name"]} =' in mcp_block:
        print(f"MCP {mcp_data['name']} already exists in gemini.nix, updating/skipping...")
        # For now, we append if not found, or user could manually clean
    
    # Generate Nix string
    args_str = " ".join([f'"{a}"' for a in mcp_data["args"]])
    new_entry = f'\n      {mcp_data["name"]} = {{\n        command = "{mcp_data["command"]}";\n        args = [ {args_str} ];\n        env = {{ }};\n      }};'
    
    # Replace the block content
    new_block = mcp_block.rstrip() + new_entry + "\n    "
    new_content = content[:match.start(2)] + new_block + content[match.end(2):]
    
    # Also add dependencies to home.packages if missing
    if mcp_data["command"] == "npx" and "pkgs.nodejs" not in content and "pkgs.node" not in content:
        # Simple injection before the list end
        new_content = re.sub(r'(home\.packages = \[\s*pkgs\.gemini-cli)', r'\1\n    pkgs.nodejs', new_content)
    elif mcp_data["command"] == "uvx" and "pkgs.uv" not in content:
        new_content = re.sub(r'(home\.packages = \[\s*pkgs\.gemini-cli)', r'\1\n    pkgs.uv', new_content)

    with open(nix_path, 'w') as f:
        f.write(new_content)
    print(f"Updated Gemini Nix config: {nix_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: mcp-nix-manager.py <URL> <target:antigravity|gemini|both>")
        sys.exit(1)
    
    url = sys.argv[1]
    target = sys.argv[2]
    
    mcp_data = scrape_mcp(url)
    if not mcp_data:
        print("Could not extract MCP config from URL.")
        sys.exit(1)
    
    print(f"Found MCP: {mcp_data['name']} -> {mcp_data['command']} {' '.join(mcp_data['args'])}")
    
    workspace_root = os.environ.get("WORKSPACE_ROOT", "/home/david/nixos-config")
    
    if target in ["antigravity", "both"]:
        config_path = os.path.expanduser("~/.gemini/antigravity/mcp_config.json")
        # In this specific setup, it might be in Workspace root too
        ws_config = os.path.join(workspace_root, ".agent/mcp_config.json")
        if os.path.exists(ws_config):
            update_antigravity(ws_config, mcp_data)
        update_antigravity(config_path, mcp_data)
        
    if target in ["gemini", "both"]:
        nix_path = os.path.join(workspace_root, "modules/gemini.nix")
        update_gemini(nix_path, mcp_data)
