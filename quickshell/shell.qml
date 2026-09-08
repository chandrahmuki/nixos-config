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
    property bool networkAppOpen: false
    property string networkPanelMonitorName: ""
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
    readonly property int launcherWidth: 350
    readonly property int launcherHeight: 430
    readonly property color background: "#2b3a36" // Stylix base00
    readonly property color surface: "#354742"    // Stylix base01
    readonly property color selection: "#5e3a4d"  // Stylix base02
    readonly property color muted: "#6d877f"      // Stylix base03
    readonly property color foreground: "#dfd5cd" // Stylix base05
    readonly property color accent: "#90e0ef"     // Stylix base0D
    readonly property color active: "#00f5d4"     // Stylix base0B
    readonly property color pillBackground: "#161616"
    readonly property color pillForeground: "#f2f2f2"
    readonly property color pillMuted: "#4b4b4b"
    readonly property color pillActive: "#ffffff"
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
    // Chromium exposes MPRIS controls but ignores its Volume setter. Its
    // actual per-application volume is the Helium PipeWire stream instead.
    property real pipewireBrowserVolume: 1
    readonly property bool activePlayerUsesPipeWireVolume: activePlayer
        && (activePlayer.dbusName.toLowerCase().indexOf("chromium") >= 0
            || activePlayer.desktopEntry.toLowerCase().indexOf("helium") >= 0)
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
        function onRawEvent(event) {
            if (event.name === "fullscreen" || event.name === "workspacev2"
                    || event.name === "focusedmon" || event.name === "openwindow"
                    || event.name === "closewindow")
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

    Timer {
        // The GIF's own animation is ~1.4s; hold a moment on the settled
        // final frame before starting the card's fade-out.
        interval: 2900
        running: true
        onTriggered: root.splashVisible = false
    }

    Timer {
        // Gives the fade-out time to finish before the window disappears.
        interval: 3300
        running: true
        onTriggered: root.splashActive = false
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

    Timer {
        id: networkCloseTimer
        interval: 220
        repeat: false
        onTriggered: root.networkAppOpen = false
    }

    Timer {
        id: networkOpenTimer
        interval: 180
        repeat: false
        onTriggered: root.networkAppOpen = true
    }

    function keepNetworkAppOpen(): void {
        networkCloseTimer.stop();
        networkOpenTimer.stop();
        networkAppOpen = true;
    }

    function toggleNetworkApp(): void {
        networkAppOpen = !networkAppOpen;
        if (networkAppOpen && Hyprland.focusedMonitor)
            networkPanelMonitorName = Hyprland.focusedMonitor.name;
    }

    function scheduleNetworkAppOpen(monitorName: string): void {
        networkCloseTimer.stop();
        networkPanelMonitorName = monitorName;
        networkOpenTimer.restart();
    }

    function scheduleNetworkAppClose(): void {
        networkOpenTimer.stop();
        networkCloseTimer.restart();
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
            setBrowserPlayerVolumeProcess.running = true;
            return;
        }

        if (activePlayer.volumeSupported)
            activePlayer.volume = volume;
    }

    Process {
        id: setBrowserPlayerVolumeProcess
        property real requestedVolume: 1
        // Helium's numeric stream IDs change after restarts. Restrict the
        // lookup to its active playback streams; matching its client would
        // select a non-volume node, and matching every process would include
        // its microphone stream.
        command: ["bash", "-c", "wpctl status | awk '/Streams:/ { streams = 1; next } /Video/ { streams = 0 } streams && /^[[:space:]]*[0-9]+\\. PipeWire ALSA \\[helium\\]/ { id = $1; print substr(id, 1, length(id) - 1) }' | while read -r stream; do wpctl set-volume $stream $1; done", "--", requestedVolume.toFixed(3)]
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
                    root.weatherWind = current.winddir16Point + " " + current.windsKmph + " KM/H";
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
        application.execute();
        launcherOpen = false;
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

    IpcHandler {
        target: "shell"
        function toggleLauncher(): void { root.toggleLauncher(); }
        function toggleOverview(): void { root.toggleOverview(); }
        function toggleNetworkApp(): void { root.toggleNetworkApp(); }
        function togglePowerMenu(): void { root.togglePowerMenu(); }
    }

    FullscreenPillRevealWindow {
        shell: root
    }

    PillWindow {
        shell: root
    }

    NetworkPanelWindow {
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
