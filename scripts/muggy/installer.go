package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// InstallTarget defines where to install the MCP
type InstallTarget string

const (
	TargetAntigravity InstallTarget = "antigravity"
	TargetGemini      InstallTarget = "gemini"
	TargetBoth        InstallTarget = "both"
)

// MCPConfig holds the structured JSON for an MCP server
type MCPConfig struct {
	Command string            `json:"command"`
	Args    []string          `json:"args"`
	Env     map[string]string `json:"env"`
}

// InstallMCP handles the full flow: fetching the command, parsing it, and updating files.
func InstallMCP(mcp MCPResult, targetStr string) (string, error) {
	target := InstallTarget(targetStr)
	
	// 1. Get Command if not already known
	cmdStr, err := ScrapeInstallationCommand(mcp.URL)
	if err != nil {
		return "", fmt.Errorf("failed to extract command from %s: %v", mcp.URL, err)
	}

	// 2. Parse Command
	command, args, name, err := ParseCommand(cmdStr)
	if err != nil {
		return "", fmt.Errorf("failed to parse command '%s': %v", cmdStr, err)
	}

	mcpConfig := MCPConfig{
		Command: command,
		Args:    args,
		Env:     make(map[string]string),
	}

	workspaceRoot := os.Getenv("WORKSPACE_ROOT")
	if workspaceRoot == "" {
		workspaceRoot = "/home/david/nixos-config"
	}

	var status []string

	// 3. Update Target(s)
	if target == TargetAntigravity || target == TargetBoth {
		// Antigravity has multiple potential config locations
		// Try the workspace one first
		wsConfig := filepath.Join(workspaceRoot, ".agent", "mcp_config.json")
		err = updateJSONConfig(wsConfig, name, mcpConfig)
		if err == nil {
			status = append(status, "Updated Antigravity config: "+wsConfig)
		}

		// Try the global one
		homeDir, _ := os.UserHomeDir()
		if homeDir != "" {
			globalConfig := filepath.Join(homeDir, ".gemini", "antigravity", "mcp_config.json")
			err = updateJSONConfig(globalConfig, name, mcpConfig)
			if err == nil {
				status = append(status, "Updated Global Antigravity config: "+globalConfig)
			}
		}
	}

	if target == TargetGemini || target == TargetBoth {
		nixPath := filepath.Join(workspaceRoot, "modules", "gemini.nix")
		err = updateNixConfig(nixPath, name, mcpConfig)
		if err != nil {
			return "", fmt.Errorf("failed to update Gemini Nix: %v", err)
		}
		status = append(status, "Updated Gemini config: "+nixPath)
	}

	return strings.Join(status, "\n"), nil
}

func updateJSONConfig(path string, name string, config MCPConfig) error {
	// Create directory if it doesn't exist
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0755); err != nil {
		// Just ignore if we can't create dir, we might not have permission, 
		// but usually we should.
	}

	var root map[string]interface{}
	
	bytes, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			root = map[string]interface{}{
				"mcpServers": make(map[string]interface{}),
			}
		} else {
			return err
		}
	} else {
		if err := json.Unmarshal(bytes, &root); err != nil {
			return err
		}
	}

	// Ensure mcpServers exists
	servers, ok := root["mcpServers"].(map[string]interface{})
	if !ok {
		servers = make(map[string]interface{})
		root["mcpServers"] = servers
	}

	servers[name] = config

	out, err := json.MarshalIndent(root, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(path, out, 0644)
}

func updateNixConfig(path string, name string, config MCPConfig) error {
	bytes, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	content := string(bytes)

	// Regex to find the MCP block between markers
	re := regexp.MustCompile(`(?s)(# MCP_CONFIG_START\s+mcpServers = \{)(.*?)(\};?\s+# MCP_CONFIG_END)`)
	match := re.FindStringSubmatchIndex(content)
	if match == nil {
		return fmt.Errorf("could not find # MCP_CONFIG_START and END markers in gemini.nix")
	}

	prefix := content[:match[4]] // Includes everything up to the start of the block (including group 1)
	block := content[match[4]:match[5]]
	suffix := content[match[5]:] // Includes everything from the end of the block (including group 3)

	// Format args for Nix
	argsStr := ""
	for _, a := range config.Args {
		argsStr += fmt.Sprintf(`"%s" `, a)
	}
	argsStr = strings.TrimSpace(argsStr)

	// Build the new entry
	newEntry := fmt.Sprintf(`
      %s = {
        command = "%s";
        args = [ %s ];
        env = { };
      };`, name, config.Command, argsStr)

	// Check if already exists (very basic check)
	if !strings.Contains(block, name+" = {") && !strings.Contains(block, fmt.Sprintf(`"%s" = {`, name)) {
		block = strings.TrimRight(block, " \n\r\t") + newEntry + "\n    "
	}

	newContent := prefix + block + suffix

	// Smart Mapping Dependency Injection
	if config.Command == "npx" && !strings.Contains(newContent, "pkgs.nodejs") {
		newContent = regexp.MustCompile(`(home\.packages = \[\s*pkgs\.gemini-cli)`).ReplaceAllString(newContent, "$1\n    pkgs.nodejs")
	} else if config.Command == "uvx" && !strings.Contains(newContent, "pkgs.uv") {
		newContent = regexp.MustCompile(`(home\.packages = \[\s*pkgs\.gemini-cli)`).ReplaceAllString(newContent, "$1\n    pkgs.uv")
	}

	return os.WriteFile(path, []byte(newContent), 0644)
}
