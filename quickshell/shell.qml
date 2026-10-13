//@ pragma UseQApplication
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Bluetooth
import "services"
import "windows"

ShellRoot {
    id: root
    // This source is intentionally hot-reloaded from the checkout.

    property bool launcherOpen: false
    property bool themeManagerOpen: false
    // Brand splash on session start: the GIF itself plays once and holds on
    // its settled final frame (-loop -1), so these only drive the card's
    // fade-out (splashVisible) and when the window itself stops existing
    // (splashActive, kept true slightly longer so the fade is visible).
    property bool splashVisible: true
    property bool splashActive: true
    property bool overviewOpen: false
    property bool powerMenuOpen: false
    property bool shortcutsOpen: false

    // Weather has its own service; widgets read it as `shell.weather`.
    property alias weather: weatherService
    WeatherService {
        id: weatherService
    }

    // Network data has its own service; widgets read it as `shell.network`.
    property alias network: networkService
    NetworkService {
        id: networkService
    }

    // Notifications have their own service; widgets read it as `shell.notifications`.
    property alias notifications: notificationService
    NotificationService {
        id: notificationService
        shell: root
    }

    // System audio has its own service; widgets read it as `shell.audio`.
    property alias audio: audioService
    AudioService {
        id: audioService
    }

    // The music player has its own service; widgets read it as `shell.music`.
    property alias music: musicService
    MusicService {
        id: musicService
    }

    // The theme has its own service; widgets read it as `shell.theme`.
    property alias theme: themeService
    // Applying a theme also closes the theme deck, which is shell state.
    function applyShellTheme(themeId): void {
        if (themeService.apply(themeId))
            themeManagerOpen = false;
    }
    ThemeService {
        id: themeService
    }
    property bool fullscreenPillReveal: false
    property bool fullscreenPillOverlayActive: false
    property int fullscreenPillMonitorId: -1
    property int fullscreenStateRevision: 0
    property int powerMenuIndex: 0
    property bool powerMenuConfirming: false
    property string searchText: ""
    property int selectedIndex: 0
    property int overviewIndex: 0
    property int overviewWorkspaceIndex: 0
    property date now: new Date()
    property string networkPanelMonitorName: ""
    // IPC can request the network detail panel without owning a separate
    // layer-shell window. The matching PillWindow consumes this revision.
    property bool networkPanelIpcOpen: false
    property int networkPanelToggleRevision: 0
    readonly property int launcherWidth: 430
    readonly property int launcherHeight: 540
    readonly property var matchingApplications: DesktopEntries.applications.values.filter(function(application) {
        const query = root.searchText.trim().toLowerCase();
        return query.length === 0
            || application.name.toLowerCase().includes(query)
            || application.genericName.toLowerCase().includes(query)
            || application.keywords.join(" ").toLowerCase().includes(query);
    })
    readonly property var overviewWorkspaces: Array.from(Hyprland.workspaces.values).sort(function(left, right) {
        return left.id - right.id;
    })
    readonly property var selectedOverviewWorkspace: overviewWorkspaces[overviewWorkspaceIndex]
    readonly property var connectedHeadset: Bluetooth.devices.values.find(function(device) {
        return device.connected && (device.icon.indexOf("audio") >= 0
            || device.icon.indexOf("headset") >= 0);
    }) || null
    readonly property int musicPanelWidth: 470
    readonly property var overviewToplevels: selectedOverviewWorkspace
        ? Hyprland.toplevels.values.filter(function(toplevel) {
            return toplevel.workspace === selectedOverviewWorkspace;
        }) : []
    // Quickshell 0.3 does not always update an existing toplevel's IPC
    // snapshot after fullscreen changes. Refresh once per Hyprland event;
    // polling created overlapping requests where an old response could win.
    Timer {
        id: fullscreenStateRefreshTimer
        interval: 40
        repeat: false
        onTriggered: {
            Hyprland.refreshMonitors();
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
            root.fullscreenStateRevision++;
        }
    }

    Connections {
        target: Hyprland
        // Used to filter to a specific event allowlist here, but that list
        // had gaps: entering maximized state via the custom Lua bindings in
        // aspects/hyprland.nix (window.fullscreen mode=maximized, then
        // window.fullscreen_state to leave it) still fires Hyprland's
        // "fullscreen" raw event either way, yet the pill could still be
        // found stuck hidden — Quickshell's toplevel IPC snapshot can go
        // stale independently of which named event caused the change (see
        // the comment on fullscreenStateRefreshTimer above; this is a known
        // Quickshell 0.3 gap, not something specific to one event). Refresh
        // on every raw event instead of guessing which ones matter — this
        // timer is a cheap, debounced no-op path when nothing changed.
        function onRawEvent(event) {
            fullscreenStateRefreshTimer.restart();
        }
    }

    Component.onCompleted: fullscreenStateRefreshTimer.restart()

    Timer {
        id: fullscreenPillHideTimer
        interval: 850
        repeat: false
        onTriggered: {
            root.fullscreenPillReveal = false;
            fullscreenPillOverlayDropTimer.restart();
        }
    }

    // Keep the window in Overlay while its upward exit animation is visible.
    Timer {
        id: fullscreenPillOverlayDropTimer
        interval: 190
        repeat: false
        onTriggered: {
            root.fullscreenPillOverlayActive = false;
            root.fullscreenPillMonitorId = -1;
        }
    }

    function revealFullscreenPill(monitorId: int): void {
        if (monitorId < 0)
            return;
        fullscreenPillOverlayDropTimer.stop();
        fullscreenPillMonitorId = monitorId;
        fullscreenPillOverlayActive = true;
        fullscreenPillReveal = true;
        fullscreenPillHideTimer.restart();
    }

    function strictFullscreenFor(monitor): bool {
        // Accessing the revision makes this binding refresh when Hyprland
        // updates fullscreen state inside an existing IPC object.
        const revision = fullscreenStateRevision;
        if (!monitor || !monitor.activeWorkspace)
            return false;

        return Hyprland.toplevels.values.some(function(toplevel) {
            return toplevel.monitor && toplevel.workspace
                && toplevel.monitor.id === monitor.id
                && toplevel.workspace.id === monitor.activeWorkspace.id
                && toplevel.lastIpcObject
                && toplevel.lastIpcObject.visible === true
                && Number(toplevel.lastIpcObject.fullscreen) === 2;
        });
    }

    function hasFullscreenFor(monitor): bool {
        const revision = fullscreenStateRevision;
        if (!monitor || !monitor.activeWorkspace)
            return false;

        return Hyprland.toplevels.values.some(function(toplevel) {
            return toplevel.monitor && toplevel.workspace
                && toplevel.monitor.id === monitor.id
                && toplevel.workspace.id === monitor.activeWorkspace.id
                && toplevel.lastIpcObject
                && toplevel.lastIpcObject.visible === true
                && Number(toplevel.lastIpcObject.fullscreen) > 0;
        });
    }

    function isFullscreenPillRevealedFor(monitorId: int): bool {
        return fullscreenPillReveal && fullscreenPillMonitorId === monitorId;
    }

    function keepFullscreenPillVisible(): void {
        fullscreenPillHideTimer.stop();
    }

    function scheduleFullscreenPillHide(): void {
        if (fullscreenPillReveal)
            fullscreenPillHideTimer.restart();
    }

    function dismissSplash(): void {
        splashVisible = false;
        splashActive = false;
    }

    Timer {
        id: splashFadeTimer
        // The GIF's own animation is ~1.4s; hold a moment on the settled
        // final frame before starting the card's fade-out.
        interval: 2900
        running: true
        onTriggered: root.splashVisible = false
    }

    Timer {
        id: splashDeactivateTimer
        // Gives the fade-out time to finish before the window disappears.
        interval: 3300
        running: true
        onTriggered: root.splashActive = false
    }

    // Temporary runtime probe: it halts the one-shot startup timers, so the
    // splash can never leave the session stuck while it is being reviewed.
    function showSplashForTest(): void {
        splashFadeTimer.stop();
        splashDeactivateTimer.stop();
        splashActive = true;
        splashVisible = true;
    }

    function toggleLauncher(): void {
        launcherOpen = !launcherOpen;
        if (launcherOpen) {
            shortcutsOpen = false;
            themeManagerOpen = false;
            searchText = "";
            selectedIndex = 0;
        }
    }


    function focusToplevel(toplevel): void {
        if (!toplevel)
            return;
        const address = toplevel.address.startsWith("0x")
            ? toplevel.address : "0x" + toplevel.address;
        Qt.callLater(function() {
            if (Hyprland.usingLua)
                Hyprland.dispatch('hl.dsp.focus({ window = "address:' + address + '" })');
            else
                Hyprland.dispatch("focuswindow address:" + address);
        });
    }


    function toggleNetworkApp(): void {
        if (!Hyprland.focusedMonitor)
            return;
        const monitorChanged = networkPanelMonitorName !== Hyprland.focusedMonitor.name;
        networkPanelMonitorName = Hyprland.focusedMonitor.name;
        networkPanelIpcOpen = monitorChanged ? true : !networkPanelIpcOpen;
        if (networkPanelIpcOpen)
            revealFullscreenPill(Hyprland.focusedMonitor.id);
        networkPanelToggleRevision++;
    }





    function localWorkspaceLabel(workspaceId: int): int {
        return workspaceId >= 6 && workspaceId <= 10 ? workspaceId - 5 : workspaceId;
    }

    function workspaceIdForLocalSlot(localSlot: int, monitorName: string): int {
        return monitorName === "HDMI-A-1" ? localSlot + 5 : localSlot;
    }




    function moveSelection(offset: int): void {
        if (matchingApplications.length === 0)
            return;
        selectedIndex = (selectedIndex + offset + matchingApplications.length)
            % matchingApplications.length;
    }

    function launchSelection(): void {
        const application = matchingApplications[selectedIndex];
        if (!application)
            return;

        // Reopening an application from the launcher should return to its
        // existing window, including when it lives on another monitor or
        // local workspace. Calling DesktopEntry.execute() unconditionally
        // starts a second instance and leaves focus wherever Hyprland's
        // default placement rules put it.
        const existing = Hyprland.toplevels.values.find(function(toplevel) {
            return applicationMatchesToplevel(application, toplevel);
        });
        launcherOpen = false;
        if (existing) {
            focusToplevel(existing);
        } else {
            application.execute();
        }
    }

    function toggleOverview(): void {
        overviewOpen = !overviewOpen;
        if (overviewOpen) {
            shortcutsOpen = false;
            const focusedIndex = overviewWorkspaces.indexOf(Hyprland.focusedWorkspace);
            overviewWorkspaceIndex = focusedIndex >= 0 ? focusedIndex : 0;
            overviewIndex = 0;
        }
    }

    function togglePowerMenu(): void {
        powerMenuOpen = !powerMenuOpen;
        if (powerMenuOpen)
            shortcutsOpen = false;
        powerMenuIndex = 0;
        powerMenuConfirming = false;
    }

    function closePowerMenu(): void {
        powerMenuOpen = false;
        powerMenuConfirming = false;
    }

    function movePowerMenuSelection(offset: int): void {
        powerMenuIndex = (powerMenuIndex + offset + 4) % 4;
        powerMenuConfirming = false;
    }

    function activatePowerMenuSelection(): void {
        if (!powerMenuConfirming) {
            powerMenuConfirming = true;
            return;
        }

        executePowerMenuAction(powerMenuIndex);
    }

    function executePowerMenuAction(index: int): void {
        const commands = [
            ["systemctl", "suspend"],
            ["systemctl", "reboot"],
            ["hyprctl", "dispatch", "exit"],
            ["systemctl", "poweroff"]
        ];
        console.log("Power menu action:", commands[index].join(" "));
        powerActionProcess.command = commands[index];
        powerActionProcess.running = true;
        closePowerMenu();
    }

    Process {
        id: powerActionProcess
        command: []
        running: false
        onExited: function(exitCode) {
            if (exitCode !== 0)
                console.warn("Power menu action failed with exit code", exitCode);
        }
        stderr: SplitParser {
            onRead: data => console.warn("Power menu action:", data.trim())
        }
    }

    function moveOverviewSelection(offset: int): void {
        if (overviewToplevels.length === 0)
            return;
        overviewIndex = (overviewIndex + offset + overviewToplevels.length)
            % overviewToplevels.length;
    }

    function moveOverviewWorkspace(offset: int): void {
        if (overviewWorkspaces.length === 0)
            return;
        overviewWorkspaceIndex = (overviewWorkspaceIndex + offset + overviewWorkspaces.length)
            % overviewWorkspaces.length;
        overviewIndex = 0;
    }

    function nextWorkspaceId(): int {
        const usedIds = overviewWorkspaces.map(function(workspace) { return workspace.id; });
        const monitor = Hyprland.focusedMonitor;
        if (!monitor)
            return -1;
        for (let localSlot = 1; localSlot <= 5; localSlot++) {
            const workspaceId = workspaceIdForLocalSlot(localSlot, monitor.name);
            if (!usedIds.includes(workspaceId))
                return workspaceId;
        }
        return -1;
    }

    function focusOverviewWorkspace(workspaceId): void {
        overviewOpen = false;
        Qt.callLater(function() {
            Hyprland.dispatch('hl.dsp.focus({ workspace = ' + workspaceId + ' })');
        });
    }

    function focusWorkspaceOnMonitor(workspaceId, monitorName): void {
        Hyprland.dispatch('hl.dsp.focus({ monitor = "' + monitorName + '" })');
        Hyprland.dispatch('hl.dsp.focus({ workspace = ' + workspaceId + ' })');
    }

    function desktopEntryFor(toplevel): var {
        const ipc = toplevel.lastIpcObject || {};
        const candidates = [ipc.class, ipc.initialClass].filter(function(value) {
            return value && value.length > 0;
        }).map(function(value) {
            return value.toLowerCase();
        });
        return DesktopEntries.applications.values.find(function(application) {
            const id = application.id.toLowerCase();
            const stem = id.endsWith(".desktop") ? id.slice(0, -8) : id;
            return candidates.includes(id) || candidates.includes(stem);
        });
    }

    function applicationMatchesToplevel(application, toplevel): bool {
        if (desktopEntryFor(toplevel) === application)
            return true;

        // Some XWayland clients, notably Parsec, expose no class at all.
        // Their stable application identity is only available through the
        // window title, so use an exact title fallback before launching a
        // duplicate instance.
        const ipc = toplevel.lastIpcObject || {};
        const appName = application.name.toLowerCase();
        return [ipc.title, ipc.initialTitle, toplevel.title, toplevel.initialTitle]
            .filter(function(value) { return value && value.length > 0; })
            .some(function(title) { return title.toLowerCase() === appName; });
    }

    function iconFor(toplevel): string {
        const entry = desktopEntryFor(toplevel);
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }

    function focusOverviewSelection(): void {
        focusOverviewToplevel(overviewToplevels[overviewIndex]);
    }

    function focusOverviewToplevel(toplevel): void {
        if (!toplevel)
            return;
        overviewOpen = false;
        // Releasing the layer-shell focus grab first is essential: otherwise
        // Hyprland can reject a focus request to a window on another monitor.
        focusToplevel(toplevel);
    }

    function toggleThemeManager(): void {
        themeManagerOpen = !themeManagerOpen;
        if (themeManagerOpen) {
            launcherOpen = false;
            shortcutsOpen = false;
        }
    }

    function toggleShortcuts(): void {
        shortcutsOpen = !shortcutsOpen;
        if (shortcutsOpen) {
            launcherOpen = false;
            themeManagerOpen = false;
            overviewOpen = false;
            powerMenuOpen = false;
        }
    }

    function closeShortcuts(): void {
        shortcutsOpen = false;
    }


    IpcHandler {
        target: "shell"
        function toggleLauncher(): void { root.toggleLauncher(); }
        function toggleThemeManager(): void { root.toggleThemeManager(); }
        function applyTheme(themeId: string): void { root.applyShellTheme(themeId); }
        function toggleOverview(): void { root.toggleOverview(); }
        function toggleNetworkApp(): void { root.toggleNetworkApp(); }
        function testShowSplash(): void {
            root.showSplashForTest();
        }
        function testDismissSplash(): void { root.dismissSplash(); }
        function togglePowerMenu(): void { root.togglePowerMenu(); }
        function toggleShortcuts(): void { root.toggleShortcuts(); }
    }

    FullscreenPillRevealWindow {
        shell: root
    }

    PillWindow {
        shell: root
    }

    // Passive notification stack: it stays independent from the pill and
    // never grabs keyboard focus.
    NotificationStackWindow {
        shell: root
    }

    LauncherWindow {
        shell: root
    }

    ThemeManagerWindow {
        shell: root
    }

    BackgroundWindow {
        shell: root
    }

    OverviewWindow {
        shell: root
    }

    // Kept as a window component so the menu can own its overlay focus grab.
    PowerMenuWindow {
        shell: root
    }

    ShortcutsWindow {
        shell: root
    }

    SplashWindow {
        shell: root
    }
}
