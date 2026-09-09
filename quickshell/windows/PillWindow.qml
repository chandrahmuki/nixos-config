import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../components"

Variants {
    id: pillRoot
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: pillWindow
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
        implicitHeight: 182
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 54
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
                || clockPanel.expanded || networkPanel.expanded
            width: detailPanelExpanded ? expandedWidth : compactWidth
            height: detailPanelExpanded ? 164 : 40
            radius: detailPanelExpanded ? 14 : 20
            x: (parent.width - width) / 2
            y: pillWindow.strictFullscreen
                && !pillWindow.revealTarget ? -height : 7
            visible: !pillWindow.strictFullscreen || pillWindow.revealTarget
            clip: true
            color: pillRoot.shell.pillBackground
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
            }

            RowLayout {
                id: baseRow
                // Pinned to the compact pill's own fixed center (top + 20),
                // not centerIn islandShape: islandShape grows downward from a
                // fixed top edge, so centering on its moving middle would
                // drag this content (and its hover target) down mid-morph.
                anchors.horizontalCenter: parent.horizontalCenter
                y: 20 - height / 2
                spacing: 8
                opacity: islandShape.detailPanelExpanded ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 100 } }

                WorkspaceRail {
                    shell: pillRoot.shell
                    monitor: pillWindow.hyprMonitor
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 18
                    color: pillRoot.shell.panelLine
                    opacity: 0.7
                }

                Row {
                    id: mediaSystemGroup
                    spacing: 3

                    Item {
                        width: pillRoot.shell.activePlayer ? 32 : 0
                        height: 26
                        visible: pillRoot.shell.activePlayer

                        Row {
                            anchors.centerIn: parent
                            spacing: 3
                            Repeater {
                                model: 4
                                delegate: Rectangle {
                                    required property int index
                                    width: 3
                                    height: pillRoot.shell.activePlayer && pillRoot.shell.activePlayer.isPlaying
                                        ? 3 + pillRoot.shell.cavaLevels[index] * 0.14 : 3
                                    radius: 1.5
                                    color: pillRoot.shell.retroCyan
                                    Behavior on height { NumberAnimation { duration: 45; easing.type: Easing.OutQuad } }
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

                    SystemVolumeControl { shell: pillRoot.shell }
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
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 18
                    color: pillRoot.shell.panelLine
                    opacity: 0.7
                }

                Row {
                    id: contextGroup
                    spacing: 2
                    WeatherWidget {
                        id: weatherWidget
                        shell: pillRoot.shell
                        onOpenRequested: {
                            islandShape.closeDetailPanels(weatherPanel);
                            weatherPanel.openPanel();
                        }
                        onCloseRequested: {
                            weatherPanel.scheduleClose();
                        }
                    }
                    ClockWidget {
                        shell: pillRoot.shell
                        onOpenRequested: {
                            islandShape.closeDetailPanels(clockPanel);
                            clockPanel.openPanel();
                        }
                        onCloseRequested: clockPanel.scheduleClose()
                    }
                    // Status icons finish the pill instead of interrupting the
                    // weather/time readout.
                    TrayCapsule { shell: pillRoot.shell }
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
                height: 164
                anchors.horizontalCenter: parent.horizontalCenter
            }

            WeatherIsland {
                id: weatherPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 164
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ClockIsland {
                id: clockPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 164
                anchors.horizontalCenter: parent.horizontalCenter
            }

            NetworkIsland {
                id: networkPanel
                shell: pillRoot.shell
                width: islandShape.expandedWidth
                height: 164
                anchors.horizontalCenter: parent.horizontalCenter
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
