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
import "windows"

ShellRoot {
    id: root
    // This source is intentionally hot-reloaded from the checkout.

    property bool launcherOpen: false
    property bool themeManagerOpen: false
    property string activeThemeId: "muggy"
    // Which Matugen colour-scheme algorithm generates the live palette from
    // the chosen wallpaper — independent of which wallpaper/theme is
    // selected. Session-only: resets to the punchiest default on restart
    // rather than persisting, since it's a taste knob, not identity like
    // activeThemeId.
    property string matugenScheme: "scheme-vibrant"
    readonly property var matugenSchemes: [
        { id: "scheme-tonal-spot", name: "TONAL" },
        { id: "scheme-vibrant", name: "VIBRANT" },
        { id: "scheme-rainbow", name: "RAINBOW" },
        { id: "scheme-expressive", name: "EXPRESSIF" },
        { id: "scheme-neutral", name: "NEUTRE" }
    ]
    // Replaced atomically after Matugen has analysed the selected wallpaper.
    // The static profile remains the safe visual fallback if generation fails.
    property var generatedPalette: ({})
    // Brand splash on session start: the GIF itself plays once and holds on
    // its settled final frame (-loop -1), so these only drive the card's
    // fade-out (splashVisible) and when the window itself stops existing
    // (splashActive, kept true slightly longer so the fade is visible).
    property bool splashVisible: true
    property bool splashActive: true
    property bool overviewOpen: false
    property bool powerMenuOpen: false
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
    property var activeNotifications: []
    property string defaultBrowserDesktopId: ""
    property real systemVolume: 0
    property bool systemMuted: false
    property string networkPanelMonitorName: ""
    // IPC can request the network detail panel without owning a separate
    // layer-shell window. The matching PillWindow consumes this revision.
    property bool networkPanelIpcOpen: false
    property int networkPanelToggleRevision: 0
    property string networkType: ""
    property string networkConnectionName: ""
    property string networkDevice: ""
    property string networkAddress: "—"
    property string networkGateway: "—"
    property string networkDns: "—"
    property real downloadRate: 0
    property real uploadRate: 0
    property var downloadHistory: Array(18).fill(0)
    property var uploadHistory: Array(18).fill(0)
    property string weatherCity: "LOCALISATION…"
    // IP geolocation can resolve to a nearby town, so keep the weather view
    // tied to the user's actual city instead.
    readonly property string weatherLocation: "Gänserndorf"
    property string weatherTemperature: "—"
    property string weatherFeelsLike: "—"
    property string weatherHumidity: "—"
    property string weatherWind: "—"
    property string weatherRain: "—"
    property int weatherCode: -1
    property string weatherUpdated: "—"
    property var weatherForecast: []
    property bool weatherOnline: false
    readonly property int launcherWidth: 430
    readonly property int launcherHeight: 540
    readonly property var themeProfiles: [
        { id: "muggy", name: "MUGGY // NEON", description: "Le wallpaper NixOS néon, cyan et rose sur fond profond.", wallpaper: "muggy.png", background: "#293d39", surface: "#344b46", selection: "#3d5b56", muted: "#71918a", foreground: "#e9e1dc", accent: "#00dfc1", active: "#f5b6c8", pillBackground: "#172522", pillForeground: "#f3efec", pillMuted: "#65817b", pillActive: "#10201d", panelSurface: "#223530", panelLine: "#44645d", retroAmber: "#e3b264", retroCyan: "#00dfc1", retroCoral: "#f27d9a" },
        { id: "gnome-lines", name: "GNOME // LINES", description: "Le wallpaper GNOME aux bandes cyan, bleues, ambre et roses.", wallpaper: "gnome-lines.png", background: "#252a3d", surface: "#343b55", selection: "#414b6b", muted: "#8996c4", foreground: "#edf0ff", accent: "#72d8ca", active: "#f27a96", pillBackground: "#171b2b", pillForeground: "#edf0ff", pillMuted: "#69769f", pillActive: "#171b2b", panelSurface: "#29314a", panelLine: "#526285", retroAmber: "#e5b261", retroCyan: "#72d8ca", retroCoral: "#f27a96" },
        { id: "gnome-gradient", name: "GNOME // GRADIENT", description: "Le wallpaper GNOME texturé, turquoise, prune et ivoire.", wallpaper: "gnome-gradient.png", background: "#1f302d", surface: "#30423f", selection: "#43534f", muted: "#829b95", foreground: "#f5eee6", accent: "#00e2d2", active: "#efcfc6", pillBackground: "#15211f", pillForeground: "#f5eee6", pillMuted: "#6c837e", pillActive: "#15211f", panelSurface: "#263a36", panelLine: "#4a615b", retroAmber: "#e9d2b9", retroCyan: "#00e2d2", retroCoral: "#a8547d" }
    ]
    readonly property var activeTheme: themeProfiles.find(function(theme) { return theme.id === activeThemeId; }) || themeProfiles[0]
    function generatedColor(role, fallback) {
        return generatedPalette[role] || fallback;
    }
    // Not readonly: Behavior below needs write access to animate these when
    // the bindings recompute (readonly properties reject Behavior entirely).
    property color background: generatedColor("background", activeTheme.background)
    property color surface: generatedColor("surface_container", activeTheme.surface)
    property color selection: generatedColor("surface_container_highest", activeTheme.selection)
    property color muted: generatedColor("outline", activeTheme.muted)
    property color foreground: generatedColor("on_surface", activeTheme.foreground)
    property color accent: generatedColor("primary", activeTheme.accent)
    property color active: generatedColor("primary_fixed", activeTheme.active)
    property color pillBackground: generatedColor("surface_container_lowest", activeTheme.pillBackground)
    property color pillForeground: generatedColor("on_surface", activeTheme.pillForeground)
    property color pillMuted: generatedColor("outline_variant", activeTheme.pillMuted)
    property color pillActive: generatedColor("on_primary", activeTheme.pillActive)
    // Shared micro-console language for expandable pill panels.  Keep the
    // accents deliberately sparse so future panels read as one system.
    property color panelSurface: generatedColor("surface_container_low", activeTheme.panelSurface)
    property color panelLine: generatedColor("outline_variant", activeTheme.panelLine)
    property color retroAmber: generatedColor("secondary", activeTheme.retroAmber)
    property color retroCyan: generatedColor("primary", activeTheme.retroCyan)
    property color retroCoral: generatedColor("tertiary", activeTheme.retroCoral)
    // Semantic roles shared by every overlay and micro-panel.  Components
    // must consume these roles instead of inventing a second hard-coded
    // palette, otherwise a wallpaper change only recolours the pill.
    property color onAccent: generatedColor("on_primary", pillActive)
    property color surfaceHover: generatedColor("surface_container_high", selection)
    property color surfacePressed: generatedColor("surface_container_highest", selection)
    property color surfaceMuted: generatedColor("surface_container_low", panelSurface)
    property color borderStrong: generatedColor("outline", muted)
    property color borderMuted: generatedColor("outline_variant", panelLine)
    property color iconMuted: generatedColor("on_surface_variant", muted)
    property color critical: generatedColor("error", active)
    property color warning: generatedColor("secondary", retroAmber)
    property color success: generatedColor("tertiary", retroCyan)
    property color overlayScrim: "#000000"
    // Applying a theme flips activeTheme immediately, then generatedPalette
    // arrives moments later once Matugen finishes analysing the wallpaper.
    // Animate every derived colour so both steps read as one smooth
    // transition across the whole shell instead of two abrupt snaps.
    Behavior on background { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on surface { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on selection { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on muted { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on foreground { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on accent { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on active { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillBackground { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillForeground { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillMuted { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on pillActive { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on panelSurface { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on panelLine { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on retroAmber { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on retroCyan { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    Behavior on retroCoral { ColorAnimation { duration: 900; easing.type: Easing.OutCubic } }
    readonly property string pillFont: "Cozette"
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
    property var activePlayer: null
    readonly property var connectedHeadset: Bluetooth.devices.values.find(function(device) {
        return device.connected && (device.icon.indexOf("audio") >= 0
            || device.icon.indexOf("headset") >= 0);
    }) || null
    // Some players expose an MPRIS volume property without applying it to
    // their actual PipeWire stream. Route those known players to PipeWire.
    property real pipewireBrowserVolume: 1
    readonly property string activePlayerPipeWireStreamMatch: {
        if (!activePlayer)
            return "";
        const dbusName = activePlayer.dbusName.toLowerCase();
        const desktopEntry = activePlayer.desktopEntry.toLowerCase();
        if (dbusName.indexOf("cliamp") >= 0 || desktopEntry.indexOf("cliamp") >= 0)
            return "cliamp";
        if (dbusName.indexOf("chromium") >= 0 || desktopEntry.indexOf("helium") >= 0)
            return "helium";
        return "";
    }
    readonly property bool activePlayerUsesPipeWireVolume: activePlayerPipeWireStreamMatch.length > 0
    readonly property real activePlayerVolume: activePlayerUsesPipeWireVolume
        ? pipewireBrowserVolume
        : activePlayer && activePlayer.volumeSupported ? activePlayer.volume : 0
    readonly property int musicPanelWidth: 470
    property var cavaLevels: [0, 0, 0, 0]
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
            searchText = "";
            selectedIndex = 0;
        }
    }

    NotificationServer {
        id: notificationServer
        // Advertise the capabilities that the shell actually renders. This
        // prevents clients such as Blueman from falling back to a GTK dialog.
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;
            root.activeNotifications = [notification].concat(root.activeNotifications.filter(function(item) {
                return item.id !== notification.id;
            })).slice(0, 5);
        }
    }

    function forgetNotification(id: int): void {
        activeNotifications = activeNotifications.filter(function(notification) {
            return notification.id !== id;
        });
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

    function focusDefaultBrowser(): void {
        const browserId = defaultBrowserDesktopId.toLowerCase();
        const browserStem = browserId.replace(/\.desktop$/, "");
        let browser = Hyprland.toplevels.values.find(function(toplevel) {
            const entry = desktopEntryFor(toplevel);
            if (entry) {
                const entryId = entry.id.toLowerCase();
                const entryStem = entryId.replace(/\.desktop$/, "");
                if (entryId === browserId || entryStem === browserStem)
                    return true;
            }

            const ipc = toplevel.lastIpcObject || {};
            return (ipc.class || "").toLowerCase() === browserStem;
        });
        console.log("Focusing browser:", browserId, browser ? browser.address : "not found");
        focusToplevel(browser);
    }

    function openNotificationLink(link): void {
        Qt.openUrlExternally(link);
        if (/^https?:/i.test(link))
            browserFocusTimer.restart();
    }

    function linkForNotification(notification): string {
        const match = notification.body.match(/href\s*=\s*["']([^"']+)["']/i);
        return match ? match[1] : "";
    }

    function invokeNotificationAction(action): void {
        action.invoke();
        // Most web notifications call their primary action "open". Give the
        // browser a moment to handle it, then explicitly restore its focus.
        if (action.identifier === "open" || action.identifier === "default")
            browserFocusTimer.restart();
    }

    Timer {
        id: browserFocusTimer
        interval: 180
        onTriggered: root.focusDefaultBrowser()
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

    Process {
        id: applyThemeProcess
        command: ["muggy-theme", "apply", "muggy"]
        running: false
        onExited: function(exitCode) {
            // Replacing a theme while Matugen is still running intentionally
            // terminates the previous process (SIGTERM is reported as 15).
            // That is a normal latest-selection-wins transition, not a
            // backend failure.
            if (exitCode !== 0 && exitCode !== 15)
                console.warn("Matugen theme application failed with exit code", exitCode);
        }
        stderr: SplitParser {
            onRead: data => console.warn("Matugen theme:", data.trim())
        }
        stdout: SplitParser {
            onRead: data => {
                try {
                    const report = JSON.parse(data.trim());
                    root.setMatugenPalette(report.colors);
                } catch (error) {
                    console.warn("Matugen returned an invalid palette:", error);
                }
            }
        }
    }

    Process {
        id: restoreThemeProcess
        command: ["muggy-theme", "current"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const themeId = data.trim();
                if (themeId.length > 0)
                    root.applyShellTheme(themeId);
            }
        }
    }

    Process {
        // Keep link focus tied to the user's configured browser, not a
        // hard-coded application class.
        command: ["xdg-settings", "get", "default-web-browser"]
        running: true
        stdout: SplitParser {
            onRead: data => root.defaultBrowserDesktopId = data.trim().toLowerCase()
        }
    }

    Process {
        id: volumeStatusProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Volume:\s+([0-9.]+)/);
                if (match)
                    root.systemVolume = Math.max(0, Math.min(1, Number(match[1])));
                root.systemMuted = data.includes("MUTED");
            }
        }
    }

    Process {
        id: networkStatusProcess
        command: ["bash", "-c",
            "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | grep -E '^[^:]+:(wifi|ethernet):connected:' | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const fields = data.split(":");
                root.networkDevice = fields[0] || "";
                root.networkType = fields[1] || "";
                root.networkConnectionName = fields.slice(3).join(":") || "";
                if (!networkDetailsProcess.running && root.networkDevice.length > 0)
                    networkDetailsProcess.running = true;
            }
        }
    }

    Process {
        id: networkDetailsProcess
        property int fieldIndex: 0
        command: ["nmcli", "-g", "IP4.ADDRESS,IP4.GATEWAY,IP4.DNS", "device", "show", root.networkDevice]
        running: false
        onRunningChanged: if (running) fieldIndex = 0
        stdout: SplitParser {
            onRead: data => {
                const value = data.trim().replace(/\/\d+$/, "");
                if (networkDetailsProcess.fieldIndex === 0)
                    root.networkAddress = value || "—";
                else if (networkDetailsProcess.fieldIndex === 1)
                    root.networkGateway = value || "—";
                else if (networkDetailsProcess.fieldIndex === 2)
                    root.networkDns = value || "—";
                networkDetailsProcess.fieldIndex++;
            }
        }
    }

    Process {
        id: networkTrafficProcess
        property int fieldIndex: 0
        property real sampledRx: 0
        property real lastRx: -1
        property real lastTx: -1
        command: ["cat", "/sys/class/net/" + root.networkDevice + "/statistics/rx_bytes",
            "/sys/class/net/" + root.networkDevice + "/statistics/tx_bytes"]
        running: false
        onRunningChanged: if (running) fieldIndex = 0
        stdout: SplitParser {
            onRead: data => {
                const value = Number(data.trim()) || 0;
                if (networkTrafficProcess.fieldIndex === 0)
                    networkTrafficProcess.sampledRx = value;
                else {
                    const down = networkTrafficProcess.lastRx < 0 ? 0
                        : Math.max(0, networkTrafficProcess.sampledRx - networkTrafficProcess.lastRx);
                    const up = networkTrafficProcess.lastTx < 0 ? 0
                        : Math.max(0, value - networkTrafficProcess.lastTx);
                    root.downloadRate = down;
                    root.uploadRate = up;
                    root.downloadHistory = root.downloadHistory.slice(1).concat([Math.min(1, down / 12500000)]);
                    root.uploadHistory = root.uploadHistory.slice(1).concat([Math.min(1, up / 2500000)]);
                    networkTrafficProcess.lastRx = networkTrafficProcess.sampledRx;
                    networkTrafficProcess.lastTx = value;
                }
                networkTrafficProcess.fieldIndex++;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!volumeStatusProcess.running)
                volumeStatusProcess.running = true;
            if (!networkStatusProcess.running)
                networkStatusProcess.running = true;
        }
    }

    Timer {
        interval: 1000
        running: root.networkDevice.length > 0
        repeat: true
        onTriggered: {
            if (!networkTrafficProcess.running)
                networkTrafficProcess.running = true;
        }
    }

    Process {
        id: setVolumeProcess
        property real requestedVolume: 0
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
            Math.round(requestedVolume * 100) + "%"]
        running: false
    }

    function setSystemVolume(value: real): void {
        systemVolume = Math.max(0, Math.min(1, value));
        systemMuted = false;
        setVolumeProcess.requestedVolume = systemVolume;
        setVolumeProcess.running = true;
    }

    function setActivePlayerVolume(value: real): void {
        if (!activePlayer)
            return;

        const volume = Math.max(0, Math.min(1, value));
        if (activePlayerUsesPipeWireVolume) {
            pipewireBrowserVolume = volume;
            setBrowserPlayerVolumeProcess.requestedVolume = volume;
            setBrowserPlayerVolumeProcess.streamMatch = activePlayerPipeWireStreamMatch;
            setBrowserPlayerVolumeProcess.running = true;
            return;
        }

        if (activePlayer.volumeSupported)
            activePlayer.volume = volume;
    }

    Process {
        id: setBrowserPlayerVolumeProcess
        property real requestedVolume: 1
        property string streamMatch: ""
        // Stream IDs change after restarts. Match only the active playback
        // stream for the current player, never an input/monitor stream.
        command: ["bash", "-c", "wpctl status | awk -v needle=\"$2\" '/Streams:/ { streams = 1; next } /Video/ { streams = 0 } streams && /^[[:space:]]*[0-9]+\\. PipeWire ALSA/ && index(tolower($0), needle) { id = $1; sub(/\\.$/, \"\", id); print id }' | while read -r stream; do wpctl set-volume $stream $1; done", "--", requestedVolume.toFixed(3), streamMatch]
        running: false
    }

    function localWorkspaceLabel(workspaceId: int): int {
        return workspaceId >= 6 && workspaceId <= 10 ? workspaceId - 5 : workspaceId;
    }

    function workspaceIdForLocalSlot(localSlot: int, monitorName: string): int {
        return monitorName === "HDMI-A-1" ? localSlot + 5 : localSlot;
    }

    function rateLabel(bytesPerSecond: real): string {
        if (bytesPerSecond >= 1000000)
            return (bytesPerSecond / 1000000).toFixed(1) + " MB/s";
        if (bytesPerSecond >= 1000)
            return (bytesPerSecond / 1000).toFixed(1) + " KB/s";
        return Math.round(bytesPerSecond) + " B/s";
    }

    function weatherIcon(code: int): string {
        if (code === 113)
            return "󰖙";
        if (code === 116)
            return "󰖕";
        if (code === 119 || code === 122)
            return "󰖐";
        if ([143, 248, 260].includes(code))
            return "󰖑";
        if ([200, 386, 389, 392, 395].includes(code))
            return "󰖓";
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(code))
            return "󰖘";
        if ([176, 182, 185, 263, 266, 281, 284, 293, 296, 299, 302, 305, 308,
            311, 314, 317, 320, 350, 353, 356, 359, 362, 365, 374, 377].includes(code))
            return "󰖖";
        return "󰖐";
    }

    function weatherCondition(code: int): string {
        if (code === 113)
            return "CLEAR";
        if (code === 116)
            return "PARTLY CLOUDY";
        if (code === 119 || code === 122)
            return "CLOUDY";
        if ([143, 248, 260].includes(code))
            return "FOG";
        if ([200, 386, 389, 392, 395].includes(code))
            return "THUNDER";
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(code))
            return "SNOW";
        if ([176, 182, 185, 263, 266, 281, 284, 293, 296, 299, 302, 305, 308,
            311, 314, 317, 320, 350, 353, 356, 359, 362, 365, 374, 377].includes(code))
            return "RAIN";
        return "CLOUDY";
    }

    function weatherDayLabel(date: string): string {
        const names = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return names[new Date(date + "T12:00:00").getDay()];
    }


    function setWeatherOffline(): void {
        weatherOnline = false;
        weatherCity = "WEATHER OFFLINE";
        weatherTemperature = "—";
        weatherFeelsLike = "—";
        weatherHumidity = "—";
        weatherWind = "—";
        weatherRain = "—";
        weatherCode = -1;
        weatherUpdated = "OFFLINE";
        weatherForecast = [];
    }

    function selectFallbackPlayer(): void {
        activePlayer = Mpris.players.values.find(function(player) {
            return player.isPlaying;
        }) || null;
    }

    Process {
        id: cavaProcess
        // CAVA emits one semicolon-delimited frame per line. Keeping it here
        // avoids a second daemon and makes the pill own its visualizer.
        command: ["bash", "-c", "printf '%s\\n' '[general]' 'bars = 4' 'framerate = 15' 'autosens = 1' '[input]' 'method = pulse' 'source = auto' '[output]' 'method = raw' 'raw_target = /dev/stdout' 'data_format = ascii' 'ascii_max_range = 100' 'bar_delimiter = 59' 'frame_delimiter = 10' | cava -p /dev/stdin"]
        // No music means no visualizer process or frame parsing.
        running: root.activePlayer && root.activePlayer.isPlaying

        stdout: SplitParser {
            onRead: data => {
                var frame = data.trim().split(";").filter(function(value) {
                    return value.length > 0;
                });
                if (frame.length !== 4)
                    return;

                root.cavaLevels = frame.map(function(value) {
                    return Math.max(0, Math.min(100, Number(value) || 0));
                });
            }
        }
    }

    Process {
        id: weatherProcess
        // wttr.in needs no API key. A fixed city is more reliable than an
        // IP-derived location, which can resolve to a nearby town.
        command: ["bash", "-o", "pipefail", "-c", "curl --fail --silent --show-error --max-time 8 'https://wttr.in/G%C3%A4nserndorf?format=j1' | tr -d '\\n'; printf '\\n'"]
        running: true
        onExited: function(exitCode) {
            if (exitCode !== 0)
                root.setWeatherOffline();
        }
        stdout: SplitParser {
            onRead: data => {
                try {
                    const report = JSON.parse(data.trim());
                    const current = report.current_condition[0];
                    root.weatherOnline = true;
                    root.weatherCity = root.weatherLocation.toUpperCase();
                    root.weatherTemperature = current.temp_C + "°";
                    root.weatherFeelsLike = current.FeelsLikeC + "°";
                    root.weatherHumidity = current.humidity + "%";
                    root.weatherWind = current.winddir16Point + " " + current.windspeedKmph + " KM/H";
                    root.weatherRain = current.precipMM + " MM";
                    root.weatherCode = Number(current.weatherCode);
                    root.weatherUpdated = Qt.formatTime(new Date(), "HH:mm");
                    root.weatherForecast = report.weather.slice(0, 3).map(function(day) {
                        const hourly = day.hourly[Math.floor(day.hourly.length / 2)];
                        return {
                            label: root.weatherDayLabel(day.date),
                            temperature: day.maxtempC + "°",
                            code: Number(hourly.weatherCode)
                        };
                    });
                } catch (error) {
                    console.warn("Weather update failed:", error);
                    root.setWeatherOffline();
                }
            }
        }
    }

    Timer {
        interval: 1200000
        running: true
        repeat: true
        onTriggered: {
            if (!weatherProcess.running)
                weatherProcess.running = true;
        }
    }

    Instantiator {
        model: Mpris.players

        delegate: Connections {
            required property var modelData
            target: modelData

            Component.onCompleted: {
                if (modelData.isPlaying)
                    root.activePlayer = modelData;
            }

            function onIsPlayingChanged(): void {
                if (modelData.isPlaying)
                    root.activePlayer = modelData;
                else if (root.activePlayer === modelData)
                    root.selectFallbackPlayer();
            }
        }
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
            const focusedIndex = overviewWorkspaces.indexOf(Hyprland.focusedWorkspace);
            overviewWorkspaceIndex = focusedIndex >= 0 ? focusedIndex : 0;
            overviewIndex = 0;
        }
    }

    function togglePowerMenu(): void {
        powerMenuOpen = !powerMenuOpen;
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
    }

    function applyShellTheme(themeId): void {
        if (!themeProfiles.some(function(theme) { return theme.id === themeId; }))
            return;
        playThemeTransition(activeThemeId, themeId);
        // generatedPalette still holds the OUTGOING theme's Matugen colours,
        // and generatedColor() prefers it over the fallback — so without
        // clearing it here the UI would keep showing the old palette (no
        // visible change at all) until Matugen finishes on the new
        // wallpaper, seconds later. Clearing it lets every generatedColor()
        // fall back to the new theme's static profile immediately, so the
        // Behaviors above animate right away; the later Matugen result then
        // refines colours with a second, subtler animated step.
        generatedPalette = {};
        activeThemeId = themeId;
        applyMatugenScheme(matugenScheme, themeId);
        themeManagerOpen = false;
    }

    // A scheme click is an immediate preview/apply action, not just a
    // selection marker. Keep the deck open so the result can be compared.
    function applyMatugenScheme(schemeId, themeId = activeThemeId): void {
        if (!matugenSchemes.some(function(scheme) { return scheme.id === schemeId; }))
            return;
        matugenScheme = schemeId;
        if (activeThemeId !== themeId) {
            playThemeTransition(activeThemeId, themeId);
            activeThemeId = themeId;
        }
        generatedPalette = {};
        applyThemeProcess.running = false;
        applyThemeProcess.command = ["muggy-theme", "apply", themeId, schemeId];
        applyThemeProcess.running = true;
    }

    // Full-screen wallpaper reveal (ThemeTransitionWindow), à la Omarchy: a
    // circular mask grows from the centre of every monitor to swap the old
    // wallpaper for the new one, instead of the theme deck's own confirm
    // ripple staying confined to its small panel.
    property string themeTransitionFromId: ""
    property string themeTransitionToId: ""
    property real themeTransitionProgress: 1
    function playThemeTransition(fromId, toId): void {
        themeTransitionFromId = fromId;
        themeTransitionToId = toId;
        themeTransitionProgress = 0;
        themeTransitionAnim.restart();
    }
    NumberAnimation {
        id: themeTransitionAnim
        target: root
        property: "themeTransitionProgress"
        from: 0
        to: 1
        duration: 750
        easing.type: Easing.InOutCubic
        onFinished: {
            root.themeTransitionFromId = "";
            root.themeTransitionToId = "";
        }
    }

    function setMatugenPalette(colors): void {
        if (!colors)
            return;

        const next = {};
        for (const role in colors) {
            const shade = colors[role] && colors[role].dark;
            if (shade && shade.color)
                next[role] = shade.color;
        }
        if (Object.keys(next).length > 0)
            generatedPalette = next;
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

    SplashWindow {
        shell: root
    }
}
