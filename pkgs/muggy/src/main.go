package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#FAFAFA")).
			Background(lipgloss.Color("#7D56F4")).
			Padding(0, 1).
			MarginBottom(1)
	
	docStyle = lipgloss.NewStyle().Margin(1, 2)
)

type sessionState int

const (
	stateSearchInput sessionState = iota
	stateSearching
	stateSearchResults
	stateTargetSelection
	stateCustomTargetInput
	stateInstalling
	stateDone
)

type model struct {
	state       sessionState
	searchInput textinput.Model
	resultsList list.Model
	targetList  list.Model
	
	searchQuery    string
	entityType     string // "mcp" or "skill"
	selectedMCP    *MCPResult
	selectedTarget string
	
	destinationInput textinput.Model // For typing the path for skills
	
	installStatus string
	err           error
	
	width  int
	height int
}

type MCPResult struct {
	Name   string
	Desc   string
	Source string
	URL    string
}

func (m MCPResult) Title() string       { return m.Name }
func (m MCPResult) Description() string { return m.Desc + "\n" + m.Source }
func (m MCPResult) FilterValue() string { return m.Name }

func initialModel(entityType string, subcommand string, arg string) model {
	ti := textinput.New()
	ti.Placeholder = fmt.Sprintf("Search for an %s (e.g. nix, python, git)...", strings.ToUpper(entityType))
	ti.CharLimit = 156
	ti.Width = 50

	destInput := textinput.New()
	destInput.Placeholder = "Enter absolute path to install skill (e.g. /home/user/nixos-config/.agent/skills/)..."
	destInput.CharLimit = 256
	destInput.Width = 60

	m := model{
		searchInput:      ti,
		destinationInput: destInput,
		entityType:       entityType,
	}

	if subcommand == "search" && arg != "" {
		m.searchQuery = arg
		m.state = stateSearching
	} else if subcommand == "install" && arg != "" {
        // Fast track install
		m.searchQuery = arg
        
		// Try to create a dummy mcpresult from url
		m.selectedMCP = &MCPResult{
			Name: "Target",
			URL: arg,
			Source: "Direct Install",
		}
        
		m.setupTargetList()
		m.state = stateTargetSelection
	} else {
		m.state = stateSearchInput
		ti.Focus()
	}

	return m
}

func (m model) Init() tea.Cmd {
	var cmds []tea.Cmd
	cmds = append(cmds, textinput.Blink)

	if m.state == stateCustomTargetInput {
		cmds = append(cmds, textinput.Blink)
	}

	if m.state == stateSearching && m.searchQuery != "" {
		cmds = append(cmds, performSearch(m.searchQuery, m.entityType))
	} else if m.state == stateTargetSelection && m.selectedMCP != nil {
        // For direct install we can skip directly to installing if we know the target,
        // but since we don't have a target CLI arg yet, we just show the target list.
    }

	return tea.Batch(cmds...)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmd tea.Cmd
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		// Only Ctrl+C exits globally. Esc is handled per-state for navigation.
		if msg.Type == tea.KeyCtrlC {
			return m, tea.Quit
		}
	case tea.WindowSizeMsg:
		h, v := docStyle.GetFrameSize()
		m.width = msg.Width - h
		m.height = msg.Height - v - 3
		if m.state == stateSearchResults {
			m.resultsList.SetSize(m.width, m.height)
		}
		if m.state == stateTargetSelection {
			m.targetList.SetSize(m.width, m.height)
		}
	}

	switch m.state {
	case stateSearchInput:
		switch msg := msg.(type) {
		case tea.KeyMsg:
			if msg.Type == tea.KeyEsc {
				return m, tea.Quit
			}
			if msg.Type == tea.KeyEnter {
				m.searchQuery = m.searchInput.Value()
				if m.searchQuery != "" {
					m.state = stateSearching
					return m, performSearch(m.searchQuery, m.entityType)
				}
			}
		}
		m.searchInput, cmd = m.searchInput.Update(msg)
		cmds = append(cmds, cmd)

	case stateSearching:
		switch msg := msg.(type) {
		case searchResultsMsg:
			items := make([]list.Item, len(msg.results))
			for i, res := range msg.results {
				items[i] = res
			}
			delegate := list.NewDefaultDelegate()
			w := m.width
			if w == 0 { w = 80 }
			h := m.height
			if h == 0 { h = 20 }
			m.resultsList = list.New(items, delegate, w, h)
			m.resultsList.Title = "Search Results"
			m.resultsList.SetShowStatusBar(false)
			m.resultsList.SetFilteringEnabled(false)
			m.state = stateSearchResults
		case errMsg:
			m.err = msg.err
			m.state = stateDone
		}

	case stateSearchResults:
		switch msg := msg.(type) {
		case tea.KeyMsg:
			if msg.Type == tea.KeyEsc {
				// Go back to search input
				m.state = stateSearchInput
				m.searchInput.SetValue("")
				m.searchInput.Focus()
				return m, textinput.Blink
			}
			if msg.Type == tea.KeyEnter {
				if i, ok := m.resultsList.SelectedItem().(MCPResult); ok {
					m.selectedMCP = &i
					m.setupTargetList()
					m.state = stateTargetSelection
				}
			}
		}
		m.resultsList, cmd = m.resultsList.Update(msg)
		cmds = append(cmds, cmd)
		
	case stateTargetSelection:
		switch msg := msg.(type) {
		case tea.KeyMsg:
			if msg.Type == tea.KeyEsc {
				// Go back to search results
				m.state = stateSearchResults
				return m, nil
			}
			if msg.Type == tea.KeyEnter {
				if i, ok := m.targetList.SelectedItem().(targetItem); ok {
					if i.id == "custom" {
						m.state = stateCustomTargetInput
						m.destinationInput.Focus()
						return m, textinput.Blink
					}
					m.selectedTarget = i.id
					m.state = stateInstalling
					return m, performInstall(*m.selectedMCP, m.selectedTarget, m.entityType)
				}
			}
		}
		
		m.targetList, cmd = m.targetList.Update(msg)
		cmds = append(cmds, cmd)

	case stateCustomTargetInput:
		switch msg := msg.(type) {
		case tea.KeyMsg:
			if msg.Type == tea.KeyEsc {
				// Go back to target selection
				m.state = stateTargetSelection
				return m, nil
			}
			if msg.Type == tea.KeyEnter {
				m.selectedTarget = m.destinationInput.Value()
				if m.selectedTarget != "" {
					m.state = stateInstalling
					return m, performInstall(*m.selectedMCP, m.selectedTarget, m.entityType)
				}
			}
		}
		
		m.destinationInput, cmd = m.destinationInput.Update(msg)
		cmds = append(cmds, cmd)
		
	case stateInstalling:
		switch msg := msg.(type) {
		case installResultMsg:
			m.installStatus = string(msg)
			m.state = stateDone
		case errMsg:
			m.err = msg.err
			m.state = stateDone
		}

	case stateDone:
		switch msg := msg.(type) {
		case tea.KeyMsg:
			if msg.Type == tea.KeyEnter || msg.Type == tea.KeyEsc {
				// Reset and go back to search
				m.state = stateSearchInput
				m.searchInput.SetValue("")
				m.searchInput.Focus()
				m.err = nil
				m.installStatus = ""
				m.selectedMCP = nil
				m.selectedTarget = ""
				return m, textinput.Blink
			}
		}
	}

	return m, tea.Batch(cmds...)
}

func (m model) View() string {
	header := titleStyle.Render("☕ muggy - Declarative MCP Manager") + "\n"

	switch m.state {
	case stateSearchInput:
		return docStyle.Render(header + "\n" + m.searchInput.View() + "\n\n(Enter: search · Esc: quit)")
	case stateSearching:
		return docStyle.Render(header + "\nSearching for '" + m.searchQuery + "'...")
	case stateSearchResults:
		return docStyle.Render(header + "\n" + m.resultsList.View() + "\n(Esc: back to search)")
	case stateTargetSelection:
		msg := fmt.Sprintf("Selected: %s\nWhere do you want to install it?", m.selectedMCP.Name)
		return docStyle.Render(header + "\n" + msg + "\n\n" + m.targetList.View() + "\n(Esc: back to results)")
	case stateCustomTargetInput:
		msg := fmt.Sprintf("Selected: %s\nEnter the absolute path below:", m.selectedMCP.Name)
		return docStyle.Render(header + "\n" + msg + "\n\n" + m.destinationInput.View() + "\n\n(Enter: confirm · Esc: back)")
	case stateInstalling:
		return docStyle.Render(header + "\nInstalling " + m.selectedMCP.Name + "...\nThis may take a moment.")
	case stateDone:
		var output string
		if m.err != nil {
			output = fmt.Sprintf("\n❌ Error: %v\n\nPress Enter for new search · Ctrl+C to quit.", m.err)
		} else {
			output = fmt.Sprintf("\n✅ Installation Complete!\n\n%s\n\nPress Enter for new search · Ctrl+C to quit.", m.installStatus)
		}
		return docStyle.Render(header + output)
	}
	return ""
}

// --- Target List Types ---

type targetItem struct {
	id, title, desc string
}

func (t targetItem) Title() string       { return t.title }
func (t targetItem) Description() string { return t.desc }
func (t targetItem) FilterValue() string { return t.title }

func discoverTargets(entityType string) []string {
	home, _ := os.UserHomeDir()

	// Scan the entire home directory
	searchDirs := []string{home}

	var results []string
	seenResults := make(map[string]bool)

	for _, root := range searchDirs {
		filepath.WalkDir(root, func(path string, d os.DirEntry, err error) error {
			if err != nil {
				return nil
			}
			if d.IsDir() {
				// Skip noisy directories
				if d.Name() == ".git" || d.Name() == "node_modules" || d.Name() == "result" {
					return filepath.SkipDir
				}
				// Limit depth
				rel, _ := filepath.Rel(root, path)
				if strings.Count(rel, string(os.PathSeparator)) > 4 {
					return filepath.SkipDir
				}
				// For skills: match any directory literally named "skills"
				if entityType == "skill" && d.Name() == "skills" {
					if !seenResults[path] {
						results = append(results, path)
						seenResults[path] = true
					}
					return filepath.SkipDir // Don't recurse inside
				}
			} else {
				// For MCPs: match known config filenames
				if entityType == "mcp" {
					if d.Name() == "mcp_config.json" || d.Name() == "gemini.nix" || d.Name() == "claude_desktop_config.json" {
						if !seenResults[path] {
							results = append(results, path)
							seenResults[path] = true
						}
					}
				}
			}
			return nil
		})
	}

	return results
}

func (m *model) setupTargetList() {
	targets := discoverTargets(m.entityType)
	var items []list.Item
	
	for _, t := range targets {
		desc := "Detected config file"
		if m.entityType == "skill" {
			desc = "Detected skills directory"
		}
		items = append(items, targetItem{
			id:    t,
			title: t,
			desc:  desc,
		})
	}
	
	items = append(items, targetItem{
		id:    "custom",
		title: "Enter custom path...",
		desc:  "Manually type the absolute path",
	})

	delegate := list.NewDefaultDelegate()
	w := m.width
	if w == 0 { w = 80 }
	h := m.height
	if h == 0 { h = 20 }
	m.targetList = list.New(items, delegate, w, h)
	if m.entityType == "skill" {
		m.targetList.Title = "Select Skill Installation Directory"
	} else {
		m.targetList.Title = "Select MCP Configuration File"
	}
	m.targetList.SetShowStatusBar(false)
	m.targetList.SetFilteringEnabled(true)
}

// --- Commands ---

type searchResultsMsg struct {
	results []MCPResult
}

type installResultMsg string
type errMsg struct{ err error }

func performSearch(query string, entityType string) tea.Cmd {
	return func() tea.Msg {
		var combined []MCPResult
		
		githubResults, err := SearchGitHub(query, entityType)

		if err == nil {
			combined = append(combined, githubResults...)
		}

		if len(combined) == 0 {
			errText := "No results found for your query."
			if err != nil { errText = fmt.Sprintf("%v", err) }
			return errMsg{fmt.Errorf(errText)}
		}
		return searchResultsMsg{results: combined}
	}
}

func performInstall(mcp MCPResult, target string, entityType string) tea.Cmd {
	return func() tea.Msg {
		status, err := InstallMCP(mcp, target, entityType)
		if err != nil {
			return errMsg{err} // Send error as msg!
		}
		return installResultMsg(status)
	}
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: muggy [search|install] <query|url> [--mcp|--skill]")
		os.Exit(1)
	}

	entityType := "mcp" // Default
	var positionalArgs []string

	// Custom parser to allow flags anywhere (before, middle, or end)
	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		if arg == "--mcp" {
			entityType = "mcp"
		} else if arg == "--skill" {
			entityType = "skill"
		} else {
			positionalArgs = append(positionalArgs, arg)
		}
	}

	if len(positionalArgs) < 1 {
		fmt.Println("Usage: muggy [search|install] <query|url> [--mcp|--skill]")
		os.Exit(1)
	}

	subcmd := positionalArgs[0]
	queryArg := ""

	if len(positionalArgs) >= 2 {
		// Join all remaining positional args as the search query/URL 
		// (allows searching multiple words without quotes)
		queryArg = strings.Join(positionalArgs[1:], " ")
	}

	p := tea.NewProgram(initialModel(entityType, subcmd, queryArg), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
