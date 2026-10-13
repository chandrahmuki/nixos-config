import QtQuick
import Quickshell.Hyprland

Item {
    id: workspaceRail
    required property var shell
    required property var monitor
    readonly property int cellWidth: 36
    readonly property var slots: [1, 2, 3, 4, 5]
    readonly property int activeWorkspaceIndex: {
        return workspaceRail.monitor && workspaceRail.monitor.activeWorkspace
            ? workspaceRail.shell.localWorkspaceLabel(workspaceRail.monitor.activeWorkspace.id) - 1 : -1;
    }
    implicitWidth: workspaceCells.implicitWidth
    implicitHeight: 44

    Rectangle {
        id: activeWorkspaceSegment
        visible: workspaceRail.activeWorkspaceIndex >= 0
        x: 2 + workspaceRail.activeWorkspaceIndex * workspaceRail.cellWidth
        y: (parent.height - height) / 2
        width: workspaceRail.cellWidth - 4
        height: 32
        radius: 6
        color: workspaceRail.shell.theme.retroCyan

        Behavior on x {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: workspaceCells
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: workspaceRail.slots
            delegate: Item {
                required property int modelData
                readonly property int workspaceId: workspaceRail.shell.workspaceIdForLocalSlot(
                    modelData, workspaceRail.monitor ? workspaceRail.monitor.name : "")
                readonly property bool active: modelData - 1
                    === workspaceRail.activeWorkspaceIndex
                readonly property bool occupied: Hyprland.toplevels.values.some(function(toplevel) {
                    return toplevel.workspace && toplevel.workspace.id === workspaceId;
                })
                width: workspaceRail.cellWidth
                height: workspaceRail.height

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: active ? workspaceRail.shell.theme.pillBackground
                        : occupied ? workspaceRail.shell.theme.pillForeground : workspaceRail.shell.theme.pillSecondary
                    font.family: workspaceRail.shell.theme.pillFont
                    font.pixelSize: active || occupied ? 18 : 16
                    font.bold: active || occupied
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!workspaceRail.monitor)
                            return;
                        workspaceRail.shell.focusWorkspaceOnMonitor(
                            workspaceRail.shell.workspaceIdForLocalSlot(
                                modelData, workspaceRail.monitor.name),
                            workspaceRail.monitor.name);
                    }
                }
            }
        }
    }
}
