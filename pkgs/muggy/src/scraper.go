package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

func extractCmdIfValid(line string) string {
	cmd := strings.TrimSpace(line)
	cmd = strings.ReplaceAll(cmd, "`", "")
	cmd = strings.TrimPrefix(cmd, "$ ")
	cmd = strings.TrimPrefix(cmd, "> ")
	cmd = strings.TrimPrefix(cmd, "- ")
	cmd = strings.TrimPrefix(cmd, "* ")
	cmd = strings.TrimSpace(cmd)
	
	if strings.HasPrefix(cmd, "npx ") || strings.HasPrefix(cmd, "uvx ") || cmd == "npx" || cmd == "uvx" {
		return cmd
	}
	return ""
}

// searchRepos is a helper that queries the GitHub Repository Search API and returns MCPResult entries.
// It deduplicates by URL using the provided seenKeys map.
func searchRepos(client *http.Client, queries []string, seenKeys map[string]bool, perPage int) []MCPResult {
	var results []MCPResult
	for _, sq := range queries {
		searchURL := fmt.Sprintf("https://api.github.com/search/repositories?q=%s&sort=stars&order=desc&per_page=%d", url.QueryEscape(sq), perPage)
		req, err := http.NewRequest("GET", searchURL, nil)
		if err != nil {
			continue
		}
		req.Header.Set("User-Agent", "Muggy-CLI")
		req.Header.Set("Accept", "application/vnd.github.v3+json")

		resp, err := client.Do(req)
		if err != nil {
			continue
		}
		if resp.StatusCode != 200 {
			resp.Body.Close()
			continue
		}

		var data struct {
			Items []struct {
				Name        string `json:"name"`
				FullName    string `json:"full_name"`
				Description string `json:"description"`
				HtmlURL     string `json:"html_url"`
			} `json:"items"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&data); err == nil {
			for _, item := range data.Items {
				if seenKeys[item.HtmlURL] {
					continue
				}
				seenKeys[item.HtmlURL] = true
				desc := item.Description
				if desc == "" {
					desc = "GitHub Repository: " + item.FullName
				}
				results = append(results, MCPResult{
					Name:   item.Name,
					Desc:   desc,
					Source: "GitHub",
					URL:    item.HtmlURL,
				})
			}
		}
		resp.Body.Close()
	}
	return results
}

// SearchGitHub provides a reliable discovery mechanism by searching GitHub repositories
func SearchGitHub(query string, entityType string) ([]MCPResult, error) {
	var allResults []MCPResult
	seenKeys := make(map[string]bool)
	client := &http.Client{}

	if entityType == "skill" {
		// --- SKILL SEARCH ---
		// Try GitHub Code Search API first (requires auth token for precise results)
		ghToken := os.Getenv("GITHUB_TOKEN")
		if ghToken == "" {
			ghToken = os.Getenv("GITHUB_PERSONAL_ACCESS_TOKEN")
		}

		if ghToken != "" {
			// Precise search: find actual SKILL.md files inside .agent/skills and .gemini/skills
			codeQueries := []string{
				fmt.Sprintf("filename:SKILL.md path:.agent/skills %s", query),
				fmt.Sprintf("filename:SKILL.md path:.gemini/skills %s", query),
			}

			for _, sq := range codeQueries {
				searchURL := fmt.Sprintf("https://api.github.com/search/code?q=%s&per_page=30", url.QueryEscape(sq))

				req, err := http.NewRequest("GET", searchURL, nil)
				if err != nil {
					continue
				}

				req.Header.Set("User-Agent", "Muggy-CLI")
				req.Header.Set("Accept", "application/vnd.github.v3+json")
				req.Header.Set("Authorization", "Bearer "+ghToken)

				resp, err := client.Do(req)
				if err != nil {
					continue
				}

				if resp.StatusCode != 200 {
					resp.Body.Close()
					continue
				}

				var data struct {
					Items []struct {
						Name string `json:"name"`
						Path string `json:"path"`
						Repo struct {
							FullName    string `json:"full_name"`
							Description string `json:"description"`
							HtmlURL     string `json:"html_url"`
						} `json:"repository"`
					} `json:"items"`
				}

				if err := json.NewDecoder(resp.Body).Decode(&data); err == nil {
					for _, item := range data.Items {
						// Extract skill name from path: .agent/skills/code-quality/SKILL.md -> code-quality
						parts := strings.Split(item.Path, "/")
						skillName := "unknown-skill"
						for i, p := range parts {
							if strings.EqualFold(p, "SKILL.md") || strings.EqualFold(p, "skill.md") {
								if i > 0 {
									skillName = parts[i-1]
								}
								break
							}
						}
						// If skill name is just "skills" (flat file), use repo name
						if skillName == "skills" {
							skillName = strings.Split(item.Repo.FullName, "/")[1]
						}

						// Deduplicate by repo+skill combination
						dedupeKey := item.Repo.FullName + "/" + skillName
						if seenKeys[dedupeKey] {
							continue
						}
						seenKeys[dedupeKey] = true

						desc := item.Repo.Description
						if desc == "" {
							desc = "Skill from " + item.Repo.FullName
						}
						displayName := fmt.Sprintf("%s (%s)", skillName, item.Repo.FullName)

						allResults = append(allResults, MCPResult{
							Name:   displayName,
							Desc:   desc,
							Source: "GitHub Code",
							URL:    item.Repo.HtmlURL,
						})
					}
				}
				resp.Body.Close()
			}
		}

		// Fallback: if no token or Code Search yielded 0 results, use topic-based repo search
		if len(allResults) == 0 {
			topicQueries := []string{
				fmt.Sprintf("%s topic:agent-skill", query),
				fmt.Sprintf("%s topic:claude-skill", query),
				fmt.Sprintf("%s topic:gemini-skill", query),
			}
			allResults = searchRepos(client, topicQueries, seenKeys, 15)
		}
	} else {
		// --- MCP SEARCH: Use GitHub Repository Search API ---
		mcpQueries := []string{
			fmt.Sprintf("%s topic:mcp-server", query),
		}
		allResults = searchRepos(client, mcpQueries, seenKeys, 20)
	}

	if len(allResults) == 0 {
		return nil, fmt.Errorf("no results found on GitHub API")
	}

	return allResults, nil
}

// ScrapeInstallationCommand tries to extract the npx/uvx command from the page or repo
func ScrapeInstallationCommand(pageURL string) (string, error) {
	client := &http.Client{}

	// If it's a GitHub URL, use the GitHub API to fetch the README
	if strings.Contains(pageURL, "github.com") {
		// Extract owner and repo from https://github.com/owner/repo
		cleanURL := strings.TrimRight(pageURL, "/")
		parts := strings.Split(cleanURL, "github.com/")
		if len(parts) == 2 {
			repoPath := parts[1]
			apiURL := fmt.Sprintf("https://api.github.com/repos/%s/readme", repoPath)
			
			req, _ := http.NewRequest("GET", apiURL, nil)
			req.Header.Set("User-Agent", "Muggy-CLI")
			req.Header.Set("Accept", "application/vnd.github.v3+json")
			
			resp, err := client.Do(req)
			if err != nil {
				return "", err
			}
			defer resp.Body.Close()

			if resp.StatusCode == 200 {
				var data struct {
					Content  string `json:"content"`
					Encoding string `json:"encoding"`
				}
				if err := json.NewDecoder(resp.Body).Decode(&data); err == nil {
					if data.Encoding == "base64" {
						decodedBytes, err := base64.StdEncoding.DecodeString(strings.ReplaceAll(data.Content, "\n", ""))
						if err == nil {
							text := string(decodedBytes)
							lines := strings.Split(text, "\n")
							for _, line := range lines {
								if foundCmd := extractCmdIfValid(line); foundCmd != "" {
									return foundCmd, nil
								}
							}
						}
					}
				}
			}
		}
		return "", fmt.Errorf("could not find an installation command (npx/uvx) in the GitHub repository")
	}

	// Original scraping logic for other HTML sites (e.g., skill.fish, mcp market)
	req, err := http.NewRequest("GET", pageURL, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
	resp, err := client.Do(req)

	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("failed to fetch page (status %d) for url %s", resp.StatusCode, pageURL)
	}

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		return "", err
	}

	var foundCmd string
	
	// Check raw text first (good for text sites)
	text := doc.Text()
	lines := strings.Split(text, "\n")
	for _, line := range lines {
		if foundCmd := extractCmdIfValid(line); foundCmd != "" {
			return foundCmd, nil
		}
	}

	// Fallback to HTML parsing for specific code blocks
	doc.Find("code, pre").Each(func(i int, s *goquery.Selection) {
		if foundCmd != "" {
			return // already found
		}
		text := strings.TrimSpace(s.Text())
		lines := strings.Split(text, "\n")
		for _, line := range lines {
			if cmd := extractCmdIfValid(line); cmd != "" {
				foundCmd = cmd
				return // stop inside Each
			}
		}
	})

	if foundCmd != "" {
		return foundCmd, nil
	}

	return "", fmt.Errorf("could not find an installation command (npx/uvx) on the page")
}

// ParseCommand breaks down an npx/uvx string into components for Nix/JSON
func ParseCommand(cmdStr string) (command string, args []string, name string, err error) {
	cmdStr = strings.ReplaceAll(cmdStr, "\\", "")
	cmdStr = strings.ReplaceAll(cmdStr, "\n", " ")
	cmdStr = strings.TrimSpace(cmdStr)
	
	parts := strings.Fields(cmdStr)
	if len(parts) == 0 {
		return "", nil, "", fmt.Errorf("empty command string")
	}
	
	if parts[0] != "npx" && parts[0] != "uvx" {
		return "", nil, "", fmt.Errorf("only npx and uvx are supported currently. Found: %s", parts[0])
	}
	
	command = parts[0]
	// Clean quotes from args
	for _, p := range parts[1:] {
		p = strings.Trim(p, "\"'")
		args = append(args, p)
	}
	
	// Sanitize Smithery/mcp-get wrappers
	for i, a := range args {
		if (a == "@smithery/cli" || a == "mcp-get") && i+2 < len(args) && args[i+1] == "install" {
			pkgName := args[i+2]
			args = []string{pkgName}
			break
		}
	}
	
	// Fast-track auto-confirm flags for npx to avoid interactive stalls
	if command == "npx" {
		hasY := false
		for _, a := range args {
			if a == "-y" || a == "--yes" {
				hasY = true
				break
			}
		}
		if !hasY {
			args = append([]string{"-y"}, args...)
		}
	}
	
	// Try to derive a name from the last argument
	if len(args) > 0 {
		lastArg := args[len(args)-1]
		// e.g. @modelcontextprotocol/server-postgres -> postgres
		n := lastArg
		if idx := strings.LastIndex(n, "/"); idx != -1 {
			n = n[idx+1:]
		}
		n = strings.ReplaceAll(n, "server-", "")
		n = strings.ReplaceAll(n, "@modelcontextprotocol", "")
		n = strings.TrimLeft(n, "-")
		
		// Clean weird chars
		re := regexp.MustCompile(`[^a-zA-Z0-9_-]`)
		name = re.ReplaceAllString(n, "")
	}
	
	if name == "" {
		name = "mcp-server-custom"
	}
	
	return command, args, name, nil
}
