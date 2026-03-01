package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)



// MCPConfig holds the structured JSON for an MCP server
type MCPConfig struct {
	Command string            `json:"command"`
	Args    []string          `json:"args"`
	Env     map[string]string `json:"env"`
}

// InstallMCP handles the full flow: fetching the command, parsing it, and updating files.
func InstallMCP(mcp MCPResult, targetStr string, entityType string) (string, error) {
	
	if entityType == "skill" {
		// --- SKILL INSTALLATION ---
		// 1. Validate Target Directory
		if targetStr == "" {
			return "", fmt.Errorf("skill installation requires an absolute directory path")
		}

		// Ensure target directory exists
		if err := os.MkdirAll(targetStr, 0755); err != nil {
			return "", fmt.Errorf("failed to create target directory %s: %v", targetStr, err)
		}

		// 2. Format Git Clone Command
		// e.g. https://github.com/owner/repo -> https://github.com/owner/repo.git
		cloneURL := mcp.URL
		if !strings.HasSuffix(cloneURL, ".git") {
			cloneURL += ".git"
		}

		// Calculate target directory name
		repoName := filepath.Base(mcp.URL)
		if strings.HasSuffix(repoName, ".git") {
			repoName = strings.TrimSuffix(repoName, ".git")
		}
		
		destPath := filepath.Join(targetStr, repoName)
		
		// Optional Check if it already exists
		if _, err := os.Stat(destPath); err == nil {
			return "", fmt.Errorf("destination '%s' already exists", destPath)
		}

		// Execute Git Clone natively
		cmd := exec.Command("git", "clone", cloneURL, destPath)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		
		err := cmd.Run()
		if err != nil {
			return "", fmt.Errorf("git clone failed for %s: %v", cloneURL, err)
		}

		return fmt.Sprintf("Successfully cloned Skill to:\n%s", destPath), nil
	}

	// --- MCP SERVER INSTALLATION ---
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

	// 2.5 Pre-flight Test
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	testCmd := exec.CommandContext(ctx, command, args...)
	var stderrBuf strings.Builder
	testCmd.Stderr = &stderrBuf

	if err := testCmd.Start(); err != nil {
		return "", fmt.Errorf("pre-flight error: failed to start command '%s': %v", command, err)
	}

	err = testCmd.Wait()
	if ctx.Err() == context.DeadlineExceeded {
		// Success: Server stayed alive for 3 seconds, likely waiting for MCP RPC connections.
	} else if err != nil {
		errMsg := strings.TrimSpace(stderrBuf.String())
		if errMsg == "" {
			errMsg = err.Error()
		}
		// Return friendly, structured error block so Bubble Tea displays it nicely
		return "", fmt.Errorf("Pre-flight safety check failed!\nThe server crashed when tested.\n\nCommand: %s %s\nError Output:\n%s", command, strings.Join(args, " "), errMsg)
	}

	mcpConfig := MCPConfig{
		Command: command,
		Args:    args,
		Env:     make(map[string]string),
	}

	// 3. Update Target(s) based on absolute file paths
	var status []string
	
	if strings.HasSuffix(targetStr, ".nix") {
		err = updateNixConfig(targetStr, name, mcpConfig)
		if err != nil {
			return "", fmt.Errorf("failed to update Nix config: %v", err)
		}
		status = append(status, "✅ Updated Nix config: "+targetStr)
	} else if strings.HasSuffix(targetStr, ".json") {
		err = updateJSONConfig(targetStr, name, mcpConfig)
		if err != nil {
			return "", fmt.Errorf("failed to update JSON config: %v", err)
		}
		status = append(status, "✅ Updated JSON config: "+targetStr)
	} else {
		return "", fmt.Errorf("Target path must end with .nix or .json for MCPs")
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
