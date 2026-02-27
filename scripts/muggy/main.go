package main

import (
	"fmt"
	"os"

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
	stateInstalling
	stateDone
)

type model struct {
	state       sessionState
	searchInput textinput.Model
	resultsList list.Model
	targetList  list.Model
	
	searchQuery string
	selectedMCP *MCPResult
	selectedTarget string
	
	installStatus string
	err           error
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

func initialModel(subcommand string, arg string) model {
	ti := textinput.New()
	ti.Placeholder = "Search for an MCP (e.g. nix, python, postgres)..."
	ti.CharLimit = 156
	ti.Width = 50

	m := model{
		searchInput: ti,
	}

	if subcommand == "search" && arg != "" {
		m.searchQuery = arg
		m.state = stateSearching
	} else if subcommand == "install" && arg != "" {
        // Fast track install
		m.searchQuery = arg
        
        // Try to create a dummy mcpresult from url
        m.selectedMCP = &MCPResult{
            Name: "MCP Target",
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

	if m.state == stateSearching && m.searchQuery != "" {
		cmds = append(cmds, performSearch(m.searchQuery))
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
		if msg.Type == tea.KeyCtrlC || msg.Type == tea.KeyEsc {
			return m, tea.Quit
		}
	}

	switch m.state {
	case stateSearchInput:
		switch msg := msg.(type) {
		case tea.KeyMsg:
			if msg.Type == tea.KeyEnter {
				m.searchQuery = m.searchInput.Value()
				if m.searchQuery != "" {
					m.state = stateSearching
					return m, performSearch(m.searchQuery)
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
			m.resultsList = list.New(items, delegate, 0, 0)
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
			if msg.Type == tea.KeyEnter {
				if i, ok := m.resultsList.SelectedItem().(MCPResult); ok {
					m.selectedMCP = &i
					m.setupTargetList()
					m.state = stateTargetSelection
				}
			}
		case tea.WindowSizeMsg:
			h, v := docStyle.GetFrameSize()
			m.resultsList.SetSize(msg.Width-h, msg.Height-v-3) // Adjust for title
		}
		m.resultsList, cmd = m.resultsList.Update(msg)
		cmds = append(cmds, cmd)
		
	case stateTargetSelection:
		switch msg := msg.(type) {
		case tea.KeyMsg:
			if msg.Type == tea.KeyEnter {
				if i, ok := m.targetList.SelectedItem().(targetItem); ok {
					m.selectedTarget = i.id
					m.state = stateInstalling
					return m, performInstall(*m.selectedMCP, m.selectedTarget)
				}
			}
		case tea.WindowSizeMsg:
			h, v := docStyle.GetFrameSize()
			m.targetList.SetSize(msg.Width-h, msg.Height-v-3)
		}
		m.targetList, cmd = m.targetList.Update(msg)
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
	}

	return m, tea.Batch(cmds...)
}

func (m model) View() string {
	if m.err != nil {
		return fmt.Sprintf("\nError: %v\n\nPress Esc to quit.\n", m.err)
	}

	header := titleStyle.Render("☕ muggy - Declarative MCP Manager") + "\n"

	switch m.state {
	case stateSearchInput:
		return docStyle.Render(header + "\n" + m.searchInput.View() + "\n\n(Press Enter to search, Esc to quit)")
	case stateSearching:
		return docStyle.Render(header + "\nSearching for '" + m.searchQuery + "'...")
	case stateSearchResults:
		return docStyle.Render(header + "\n" + m.resultsList.View())
	case stateTargetSelection:
		msg := fmt.Sprintf("Selected: %s\nWhere do you want to install it?", m.selectedMCP.Name)
		return docStyle.Render(header + "\n" + msg + "\n\n" + m.targetList.View())
	case stateInstalling:
		return docStyle.Render(header + "\nInstalling " + m.selectedMCP.Name + "...\nThis may take a moment.")
	case stateDone:
		var output string
		if m.err != nil {
			output = fmt.Sprintf("Installation failed: %v", m.err)
		} else {
			output = fmt.Sprintf("\n✅ Installation Complete!\n\n%s\n\nPress Esc to exit.", m.installStatus)
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

func (m *model) setupTargetList() {
	items := []list.Item{
		targetItem{id: "both", title: "Both (Recommended)", desc: "Install in Gemini CLI and Antigravity IDE"},
		targetItem{id: "gemini", title: "Gemini CLI", desc: "Install only in modules/gemini.nix"},
		targetItem{id: "antigravity", title: "Antigravity IDE", desc: "Install only in .agent/mcp_config.json"},
	}
	delegate := list.NewDefaultDelegate()
	m.targetList = list.New(items, delegate, 0, 0)
	m.targetList.Title = "Select Target Profile"
	m.targetList.SetShowStatusBar(false)
	m.targetList.SetFilteringEnabled(false)
}

// --- Commands ---

type searchResultsMsg struct {
	results []MCPResult
}

type installResultMsg string
type errMsg struct{ err error }

func performSearch(query string) tea.Cmd {
	return func() tea.Msg {
		results, err := SearchSkillfish(query)
		if err != nil {
			return errMsg{err}
		}
		if len(results) == 0 {
			// Provide fallback if scraping fails
			results = []MCPResult{
				{Name: "nix-cleanup", Desc: "Code formatting and linting for Nix (deadnix/statix)", Source: "Skill.fish", URL: "https://www.skill.fish/skill/nix-ci-code-cleanup"},
			}
		}
		return searchResultsMsg{results: results}
	}
}

func performInstall(mcp MCPResult, target string) tea.Cmd {
	return func() tea.Msg {
		status, err := InstallMCP(mcp, target)
		if err != nil {
			return errMsg{err} // Send error as msg!
		}
		return installResultMsg(status)
	}
}

func main() {
	subcmd := ""
	arg := ""

	if len(os.Args) >= 2 {
		subcmd = os.Args[1]
	}
	if len(os.Args) >= 3 {
		arg = os.Args[2]
	}

	p := tea.NewProgram(initialModel(subcmd, arg), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
