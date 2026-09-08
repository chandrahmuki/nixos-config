import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// A narrow Overlay strip is the only always-on-top surface in fullscreen.
// It reveals the ordinary pill temporarily; the pill itself remains on Top
// (and therefore hidden) until the user deliberately reaches this edge.
Variants {
    id: revealWindow
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: edgeTrigger
        required property var modelData
        readonly property var hyprMonitor: Hyprland.monitorFor(modelData)
        readonly property int hyprMonitorId: hyprMonitor ? hyprMonitor.id : -1
        readonly property int fullscreenRevision: revealWindow.shell.fullscreenStateRevision
        readonly property bool strictFullscreen: fullscreenRevision >= 0
            && revealWindow.shell.strictFullscreenFor(hyprMonitor)
        screen: modelData
        anchors { top: true; left: true }
        implicitWidth: Math.min(640, modelData.width - 32)
        margins { left: (modelData.width - implicitWidth) / 2 }
        // Constrained to the pill's width, while still being reachable.
        implicitHeight: 8
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"
        visible: edgeTrigger.hyprMonitorId >= 0
            && edgeTrigger.strictFullscreen
            && !revealWindow.shell.isFullscreenPillRevealedFor(edgeTrigger.hyprMonitorId)

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: revealWindow.shell.revealFullscreenPill(edgeTrigger.hyprMonitorId)
        }
    }
}
