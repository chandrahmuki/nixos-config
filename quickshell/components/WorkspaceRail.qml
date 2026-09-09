import QtQuick
import Quickshell.Hyprland

Item {
    id: workspaceRail
    required property var shell
    required property var monitor
    readonly property int cellWidth: 22
    readonly property var slots: [1, 2, 3, 4, 5]
    readonly property int activeWorkspaceIndex: {
        return workspaceRail.monitor && workspaceRail.monitor.activeWorkspace
            ? workspaceRail.shell.localWorkspaceLabel(workspaceRail.monitor.activeWorkspace.id) - 1 : -1;
    }
    implicitWidth: workspaceCells.implicitWidth
    implicitHeight: 26

    Rectangle {
        id: activeWorkspaceSegment
        visible: workspaceRail.activeWorkspaceIndex >= 0
        x: 1 + workspaceRail.activeWorkspaceIndex * workspaceRail.cellWidth
        y: 4
        width: workspaceRail.cellWidth - 2
        height: parent.height - 8
        radius: 3
        color: workspaceRail.shell.retroAmber

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
                    color: active ? workspaceRail.shell.pillBackground
                        : occupied ? workspaceRail.shell.retroCyan : workspaceRail.shell.pillMuted
                    font.family: workspaceRail.shell.pillFont
                    font.pixelSize: active || occupied ? 14 : 11
                    font.bold: occupied
                    style: active ? Text.Outline : Text.Normal
                    styleColor: color
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
