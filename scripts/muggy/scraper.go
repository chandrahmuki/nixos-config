package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

// SearchSkillfish searches the skill.fish website and parses results.
func SearchSkillfish(query string) ([]MCPResult, error) {
	searchURL := fmt.Sprintf("https://www.skill.fish/?q=%s", url.QueryEscape(query))
	
	client := &http.Client{}
	req, err := http.NewRequest("GET", searchURL, nil)
	if err != nil {
		return nil, err
	}
	
	// Mimic a real browser to avoid 429 Too Many Requests
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
	req.Header.Set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8")
	req.Header.Set("Accept-Language", "en-US,en;q=0.9")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode == 429 {
		// Fallback to a mock for now, later we'll add MCP Market scraper
		return []MCPResult{
			{
				Name:   "rate-limited",
				Desc:   "Skill.fish is rate-limiting us (Error 429). Please try again later or use 'muggy install <url>'.",
				Source: "System",
				URL:    "",
			},
		}, nil
	}

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("skill.fish search failed with status %d", resp.StatusCode)
	}

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		return nil, err
	}

	var results []MCPResult

	doc.Find("a[href^='/skill/']").Each(func(i int, s *goquery.Selection) {
		link, _ := s.Attr("href")
		// Extract name from URL
		parts := strings.Split(link, "/")
		if len(parts) > 0 {
			name := parts[len(parts)-1]
			desc := strings.TrimSpace(s.Text())
			if desc == "" {
				desc = "Skill.fish package: " + name
			}
			
			isDuplicate := false
			for _, r := range results {
				if r.Name == name {
					isDuplicate = true
					break
				}
			}
			
			if !isDuplicate && name != "" {
				results = append(results, MCPResult{
					Name:   name,
					Desc:   desc,
					Source: "Skill.fish",
					URL:    "https://www.skill.fish" + link,
				})
			}
		}
	})

	return results, nil
}

// SearchMCPMarket searches mcpmarket.com
func SearchMCPMarket(query string) ([]MCPResult, error) {
	// Example search pattern, adapting to typical search paths
	searchURL := fmt.Sprintf("https://www.mcpmarket.com/search?q=%s", url.QueryEscape(query))
	
	client := &http.Client{}
	req, err := http.NewRequest("GET", searchURL, nil)
	if err != nil {
		return nil, err
	}
	
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
	req.Header.Set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		// Just fail silently for the market if it throws 404/429 so it doesn't break everything
		return []MCPResult{}, nil
	}

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		return nil, err
	}

	var results []MCPResult

	// Guessing common link structure for MCP market items
	doc.Find("a").Each(func(i int, s *goquery.Selection) {
		link, exists := s.Attr("href")
		// Often they use /mcp/ or just root paths for listings
		if exists && (strings.Contains(link, "/mcp/") || strings.Contains(link, "/server/")) {
			parts := strings.Split(strings.TrimRight(link, "/"), "/")
			if len(parts) > 0 {
				name := parts[len(parts)-1]
				desc := strings.TrimSpace(s.Text())
				if desc == "" {
					desc = "MCP Market package: " + name
				}
				
				isDuplicate := false
				for _, r := range results {
					if r.Name == name {
						isDuplicate = true
						break
					}
				}
				
				baseURL := "https://www.mcpmarket.com"
				if strings.HasPrefix(link, "http") {
					baseURL = ""
				}

				if !isDuplicate && name != "" {
					results = append(results, MCPResult{
						Name:   name,
						Desc:   desc,
						Source: "MCP Market",
						URL:    baseURL + link,
					})
				}
			}
		}
	})

	return results, nil
}

// SearchGitHub provides a reliable fallback by searching GitHub repositories
func SearchGitHub(query string) ([]MCPResult, error) {
	// Search for repositories matching the query and are explicitly mcp servers
	// We use "mcp-server OR mcp in:name,description" + the user's query
	searchQuery := fmt.Sprintf("%s mcp-server in:readme,description,name", query)
	searchURL := fmt.Sprintf("https://api.github.com/search/repositories?q=%s&sort=stars&order=desc&per_page=5", url.QueryEscape(searchQuery))
	
	client := &http.Client{}
	req, err := http.NewRequest("GET", searchURL, nil)
	if err != nil {
		return nil, err
	}
	
	req.Header.Set("User-Agent", "Muggy-CLI")
	req.Header.Set("Accept", "application/vnd.github.v3+json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("github api failed with status %d", resp.StatusCode)
	}

	var data struct {
		Items []struct {
			Name        string `json:"name"`
			FullName    string `json:"full_name"`
			Description string `json:"description"`
			HtmlURL     string `json:"html_url"`
		} `json:"items"`
	}

	decoder := json.NewDecoder(resp.Body)
	if err := decoder.Decode(&data); err != nil {
		return nil, err
	}

	var results []MCPResult
	for _, item := range data.Items {
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

	return results, nil
}

// ScrapeInstallationCommand tries to extract the npx/uvx command from the page
func ScrapeInstallationCommand(pageURL string) (string, error) {
	client := &http.Client{}
	req, err := http.NewRequest("GET", pageURL, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (Muggy/1.0)")

	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("failed to fetch page %s (status %d)", pageURL, resp.StatusCode)
	}

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		return "", err
	}

	var foundCmd string
	
	// First look at JSON-Ld or specific code blocks
	doc.Find("code, pre").Each(func(i int, s *goquery.Selection) {
		text := strings.TrimSpace(s.Text())
		if strings.Contains(text, "npx") || strings.Contains(text, "uvx") {
			// Find the first line with npx or uvx
			lines := strings.Split(text, "\n")
			for _, line := range lines {
				if strings.Contains(line, "npx") || strings.Contains(line, "uvx") {
					foundCmd = strings.TrimSpace(line)
					return // stop inside Each
				}
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
