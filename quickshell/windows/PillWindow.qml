import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "../components"

Variants {
    id: pillRoot
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: pillWindow
        property string caffeineInhibitors: ""
        readonly property bool caffeineActive: caffeineInhibitors.split(",").includes("sleep")
        readonly property bool caffeineDisplay: caffeineInhibitors.split(",").includes("idle")
        readonly property bool caffeineAny: caffeineActive || caffeineDisplay
        Process {
            id: caffeineStatus
            command: ["sh", "-c", "systemd-inhibit --list --no-legend | awk '$1 == \"HyprCaffeine\" {print $6}' | paste -sd, -"]
            stdout: SplitParser {
                onRead: line => pillWindow.caffeineInhibitors = line.trim()
            }
        }
        Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: if (!caffeineStatus.running) caffeineStatus.running = true
        }
        required property var modelData
        readonly property var hyprMonitor: Hyprland.monitorFor(modelData)
        readonly property int hyprMonitorId: hyprMonitor ? hyprMonitor.id : -1
        readonly property int fullscreenRevision: pillRoot.shell.fullscreenStateRevision
        readonly property bool strictFullscreen: fullscreenRevision >= 0
            && pillRoot.shell.strictFullscreenFor(hyprMonitor)
        readonly property bool revealTarget: hyprMonitorId >= 0
            && pillRoot.shell.isFullscreenPillRevealedFor(hyprMonitorId)
        screen: modelData
        anchors { top: true; left: true; right: true }
        // Fixed at the tall size, always. This is a real layer-shell surface:
        // Hyprland's own "layers" animation (bezier "default", which has a
        // slight overshoot) animates any resize of it, producing a visible
        // bounce we don't control from QML. Keeping it constant means only
        // the QML content underneath (islandShape / musicPanel) ever changes
        // size — cheap, and never touches the compositor's own animation.
        // exclusiveZone (not this) is what actually reserves bar space, so
        // this doesn't push other windows down.
        implicitHeight: 214
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 74
        WlrLayershell.layer: revealTarget
            || (pillRoot.shell.fullscreenPillOverlayActive
                && pillRoot.shell.fullscreenPillMonitorId === hyprMonitorId)
            ? WlrLayer.Overlay : WlrLayer.Top
        color: "transparent"
        mask: Region {
            item: islandShape
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: pillRoot.shell.now = new Date()
        }

        Rectangle {
            id: islandShape
            // The actual pill background — this is the shape that morphs,
            // like ChillPill-Shell's "box". Target sizes are plain ternaries;
            // Behavior does the smoothing, same technique they use.
            readonly property real compactWidth: Math.min(baseRow.implicitWidth + 32, parent.width - 32)
            readonly property real expandedWidth: Math.min(pillRoot.shell.musicPanelWidth, parent.width - 32)
            readonly property bool detailPanelExpanded: musicPanel.expanded || weatherPanel.expanded
                || clockPanel.expanded || networkPanel.expanded || audioPanel.expanded || caffeinePanel.expanded
            width: detailPanelExpanded ? expandedWidth : compactWidth
            height: detailPanelExpanded ? 186 : 60
            radius: detailPanelExpanded ? 6 : 18
            x: (parent.width - width) / 2
            y: pillWindow.strictFullscreen
                && !pillWindow.revealTarget ? -height : 7
            visible: !pillWindow.strictFullscreen || pillWindow.revealTarget
            clip: true
            color: pillRoot.shell.theme.pillBackground
            Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutExpo } }
            Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutExpo } }
            Behavior on radius { NumberAnimation { duration: 260; easing.type: Easing.OutExpo } }
            Behavior on y {
                NumberAnimation {
                    duration: 190
                    easing.type: Easing.OutCubic
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered)
                        pillRoot.shell.keepFullscreenPillVisible();
                    else
                        pillRoot.shell.scheduleFullscreenPillHide();
                }
            }

            function closeDetailPanels(exceptPanel): void {
                if (exceptPanel !== musicPanel)
                    musicPanel.closePanel();
                if (exceptPanel !== weatherPanel)
                    weatherPanel.closePanel();
                if (exceptPanel !== clockPanel)
                    clockPanel.closePanel();
                if (exceptPanel !== networkPanel)
                    networkPanel.closePanel();
                if (exceptPanel !== audioPanel)
                    audioPanel.closePanel();
                if (exceptPanel !== caffeinePanel)
                    caffeinePanel.closePanel();
            }

            RowLayout {
                id: baseRow
                // Pinned to the compact pill's own fixed center (top + 30),
                // not centerIn islandShape: islandShape grows downward from a
                // fixed top edge, so centering on its moving middle would
                // drag this content (and its hover target) down mid-morph.
                anchors.horizontalCenter: parent.horizontalCenter
                y: 30 - height / 2
                spacing: 12
                opacity: islandShape.detailPanelExpanded ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 100 } }

                // Four groups, left to right: workspaces, music (only while a
                // player exists), time and weather, then the system.
                WorkspaceRail {
                    shell: pillRoot.shell
                    monitor: pillWindow.hyprMonitor
                }

                PillCapsule {
                    shell: pillRoot.shell
                    padding: 0
                    visible: pillRoot.shell.music.player

                    Item {
                        width: 56
                        height: 44

                        // The four CAVA bars rise from a common baseline.
                        Row {
                            anchors.centerIn: parent
                            spacing: 4
                            Repeater {
                                model: 4
                                delegate: Item {
                                    required property int index
                                    width: 4
                                    height: 28

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: pillRoot.shell.music.player && pillRoot.shell.music.player.isPlaying
                                            ? 4 + pillRoot.shell.music.cavaLevels[index] * 0.24 : 4
                                        color: pillRoot.shell.theme.retroCyan
                                        Behavior on height { NumberAnimation { duration: 45; easing.type: Easing.OutQuad } }
                                    }
                                }
                            }
                        }

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered) {
                                    islandShape.closeDetailPanels(musicPanel);
                                    musicPanel.openPanel();
                                } else {
                                    musicPanel.scheduleClose();
                                }
                            }
                        }
                    }
                }

                PillCapsule {
                    shell: pillRoot.shell

                    ClockWidget {
                        shell: pillRoot.shell
                        onOpenRequested: {
                            islandShape.closeDetailPanels(clockPanel);
                            clockPanel.openPanel();
                        }
                        onCloseRequested: clockPanel.scheduleClose()
                    }

                    Item {
                        width: 2
                        height: 44

                        Rectangle {
                            anchors.centerIn: parent
                            width: 2
                            height: 24
                            color: pillRoot.shell.theme.panelLine
                        }
                    }

                    WeatherWidget {
                        shell: pillRoot.shell
                        onOpenRequested: {
                            islandShape.closeDetailPanels(weatherPanel);
                            weatherPanel.openPanel();
                        }
                        onCloseRequested: weatherPanel.scheduleClose()
                    }
                }

                // Network, headset and volume first; the tray, whose length
                // depends on the running applications, has its own capsule
                // and closes the pill.
                PillCapsule {
                    shell: pillRoot.shell

                    NetworkIndicator {
                        shell: pillRoot.shell
                        monitor: pillWindow.hyprMonitor
                        onOpenRequested: {
                            islandShape.closeDetailPanels(networkPanel);
                            networkPanel.openPanel();
                        }
                        onCloseRequested: networkPanel.scheduleClose()
                    }
                    BluetoothHeadset { shell: pillRoot.shell; device: pillRoot.shell.connectedHeadset }
                    Item {
                        id: caffeineButton
                        width: 40
                        height: 44
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: 6
                            color: caffeineHover.hovered ? pillRoot.shell.theme.surfaceHover : "transparent"
                        }
                        PixelIcon {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 1
                            anchors.verticalCenterOffset: -3
                            name: "caffeine"
                            imageCache: false
                            color: pillWindow.caffeineAny
                                ? pillRoot.shell.theme.pillForeground : pillRoot.shell.theme.pillSecondary
                        }
                        Rectangle {
                            visible: pillWindow.caffeineAny
                            x: parent.width - width - 5
                            y: 5
                            width: 6
                            height: 6
                            color: pillRoot.shell.theme.retroCyan
                        }
                        Timer {
                            id: caffeineOpenTimer
                            interval: 180
                            onTriggered: {
                                if (caffeineHover.hovered) {
                                    islandShape.closeDetailPanels(caffeinePanel);
                                    caffeinePanel.openPanel();
                                }
                            }
                        }
                        HoverHandler {
                            id: caffeineHover
                            onHoveredChanged: {
                                if (hovered) caffeineOpenTimer.restart();
                                else { caffeineOpenTimer.stop(); caffeinePanel.scheduleClose(); }
                            }
                        }
                    }
                    AudioIndicator {
                        shell: pillRoot.shell
                        onOpenRequested: {
                            islandShape.closeDetailPanels(audioPanel);
                            audioPanel.openPanel();
                        }
                        onCloseRequested: audioPanel.scheduleClose()
                    }
                }

                PillCapsule {
                    shell: pillRoot.shell
                    visible: trayItems.activeCount > 0

                    TrayCapsule { id: trayItems; shell: pillRoot.shell }
                }
            }

            // Nested inside islandShape (not a sibling): inherits its clip,
            // so the fixed-size card can never visually bleed past whatever
            // (possibly still-growing) bounds are actually clickable, and it
            // inherits islandShape's visible/position, so it can't stay
            // floating on screen if strict fullscreen hides the pill while
            // the panel happens to be open.
            MusicIsland {
                id: musicPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 186
                anchors.horizontalCenter: parent.horizontalCenter
            }

            WeatherIsland {
                id: weatherPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 186
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ClockIsland {
                id: clockPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 186
                anchors.horizontalCenter: parent.horizontalCenter
            }

            NetworkIsland {
                id: networkPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 186
                anchors.horizontalCenter: parent.horizontalCenter
            }

            AudioIsland {
                id: audioPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 186
                anchors.horizontalCenter: parent.horizontalCenter
            }

            CrtPanel {
                id: caffeinePanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 186
                anchors.horizontalCenter: parent.horizontalCenter
                title: "CAFFEINE / VEILLE"
                status: pillWindow.caffeineActive ? "ACTIF" : "INACTIF"
                statusColor: pillWindow.caffeineActive ? shell.theme.retroCyan : shell.theme.panelDim

                RowLayout {
                    anchors.fill: parent
                    spacing: 12
                    ColumnLayout {
                        Layout.preferredWidth: 110
                        Layout.fillHeight: true
                        PixelIcon { name: "caffeine"; color: pillWindow.caffeineActive ? pillRoot.shell.theme.retroCyan : pillRoot.shell.theme.panelDim }
                        Text {
                            text: pillWindow.caffeineActive ? "ÉVEILLÉ" : "VEILLE AUTO"
                            color: pillWindow.caffeineActive ? pillRoot.shell.theme.retroCyan : pillRoot.shell.theme.panelDim
                            font.family: pillRoot.shell.theme.pillFont
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 3
                        columnSpacing: 6
                        rowSpacing: 6
                        Repeater {
                            model: [["15 MIN", "on", "15m"], ["30 MIN", "on", "30m"], ["1 HEURE", "on", "1h"], ["2 HEURES", "on", "2h"], ["ILLIMITÉ", "on", "infinite"], ["ARRÊTER", "off"], [pillWindow.caffeineDisplay ? "ÉCRAN : ON" : "ÉCRAN : AUTO", "monitor", "toggle"]]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: caffeineAction.containsMouse ? pillRoot.shell.theme.surfaceHover : "transparent"
                                border.width: 1
                                border.color: pillRoot.shell.theme.panelFaint
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData[0]
                                    color: pillRoot.shell.theme.pillForeground
                                    font.family: pillRoot.shell.theme.pillFont
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                MouseArea {
                                    id: caffeineAction
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["hyprcaffeine"].concat(parent.modelData.slice(1)))
                                }
                            }
                        }
                    }
                }
            }

            Connections {
                target: pillRoot.shell
                function onNetworkPanelToggleRevisionChanged(): void {
                    if (!pillWindow.hyprMonitor
                            || pillRoot.shell.networkPanelMonitorName !== pillWindow.hyprMonitor.name)
                        return;
                    if (pillRoot.shell.networkPanelIpcOpen) {
                        islandShape.closeDetailPanels(networkPanel);
                        networkPanel.openPanel();
                        pillRoot.shell.keepFullscreenPillVisible();
                    } else {
                        networkPanel.closePanel();
                        pillRoot.shell.scheduleFullscreenPillHide();
                    }
                }
            }
        }
    }
}
