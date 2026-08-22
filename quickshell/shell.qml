import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    id: root

    property bool launcherOpen: false
    property bool overviewOpen: false
    property string searchText: ""
    property int selectedIndex: 0
    property int overviewIndex: 0
    readonly property int launcherWidth: 620
    readonly property int launcherHeight: 460
    readonly property color background: "#2b3a36" // Stylix base00
    readonly property color surface: "#354742"    // Stylix base01
    readonly property color selection: "#5e3a4d"  // Stylix base02
    readonly property color foreground: "#dfd5cd" // Stylix base05
    readonly property color accent: "#90e0ef"     // Stylix base0D
    readonly property var matchingApplications: DesktopEntries.applications.values.filter(function(application) {
        const query = root.searchText.trim().toLowerCase();
        return query.length === 0
            || application.name.toLowerCase().includes(query)
            || application.genericName.toLowerCase().includes(query)
            || application.keywords.join(" ").toLowerCase().includes(query);
    })
    readonly property var overviewToplevels: Hyprland.toplevels.values.filter(function(toplevel) {
        return toplevel.workspace === Hyprland.focusedWorkspace;
    })

    function toggleLauncher(): void {
        launcherOpen = !launcherOpen;
        if (launcherOpen) {
            searchText = "";
            selectedIndex = 0;
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
        if (overviewOpen)
            overviewIndex = 0;
    }

    function moveOverviewSelection(offset: int): void {
        if (overviewToplevels.length === 0)
            return;
        overviewIndex = (overviewIndex + offset + overviewToplevels.length)
            % overviewToplevels.length;
    }

    function focusOverviewSelection(): void {
        focusOverviewToplevel(overviewToplevels[overviewIndex]);
    }

    function focusOverviewToplevel(toplevel): void {
        if (!toplevel)
            return;
        const address = toplevel.address.startsWith("0x")
            ? toplevel.address : "0x" + toplevel.address;
        if (Hyprland.usingLua)
            Hyprland.dispatch('hl.dsp.focus({ window = "address:' + address + '" })');
        else
            Hyprland.dispatch("focuswindow address:" + address);
        overviewOpen = false;
    }

    IpcHandler {
        target: "shell"
        function toggleLauncher(): void { root.toggleLauncher(); }
        function toggleOverview(): void { root.toggleOverview(); }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 32
            exclusionMode: ExclusionMode.Auto
            color: root.background

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                Text { text: "Hyprland"; color: root.foreground }
                Item { Layout.fillWidth: true }
                Text { text: Qt.formatTime(new Date(), "HH:mm"); color: root.foreground }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: launcherWindow
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            visible: root.launcherOpen
                && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
            onVisibleChanged: if (visible) launcherInput.forceActiveFocus()

            HyprlandFocusGrab {
                windows: [launcherWindow]
                active: launcherWindow.visible
                onCleared: root.launcherOpen = false
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.launcherOpen = false
            }

            Rectangle {
                id: launcherBox
                width: root.launcherWidth
                height: root.launcherHeight
                anchors.centerIn: parent
                radius: 12
                color: root.surface
                border.width: 1
                border.color: root.accent

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    TextField {
                        id: launcherInput
                        Layout.fillWidth: true
                        placeholderText: "Rechercher une application…"
                        placeholderTextColor: root.foreground
                        color: root.foreground
                        focus: true
                        selectByMouse: true
                        text: root.searchText

                        background: Rectangle {
                            radius: 6
                            color: root.background
                            border.width: 1
                            border.color: root.accent
                        }

                        onTextChanged: {
                            root.searchText = text;
                            root.selectedIndex = 0;
                        }
                        Keys.onEscapePressed: root.launcherOpen = false
                        Keys.onUpPressed: root.moveSelection(-1)
                        Keys.onDownPressed: root.moveSelection(1)
                        Keys.onReturnPressed: root.launchSelection()
                        Keys.onEnterPressed: root.launchSelection()
                    }

                    ListView {
                        id: launcherList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: root.matchingApplications
                        currentIndex: root.selectedIndex
                        spacing: 4
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: launcherList.width
                            height: 42

                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: root.selectedIndex === index
                                    ? root.selection : "transparent"

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    width: parent.width - 24
                                    elide: Text.ElideRight
                                    text: modelData.name
                                    color: root.selectedIndex === index
                                        ? root.accent : root.foreground
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: root.selectedIndex = index
                                    onClicked: {
                                        root.selectedIndex = index;
                                        root.launchSelection();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overviewWindow
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            visible: root.overviewOpen
                && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
            onVisibleChanged: if (visible) overviewKeyboard.forceActiveFocus()

            HyprlandFocusGrab {
                windows: [overviewWindow]
                active: overviewWindow.visible
                onCleared: root.overviewOpen = false
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.overviewOpen = false
            }

            Rectangle {
                id: overviewBox
                width: Math.min(780, parent.width - 48)
                height: Math.min(560, parent.height - 80)
                anchors.centerIn: parent
                radius: 12
                color: root.surface
                border.width: 1
                border.color: root.accent

                Item {
                    id: overviewKeyboard
                    anchors.fill: parent
                    focus: true
                    Keys.onEscapePressed: root.overviewOpen = false
                    Keys.onLeftPressed: root.moveOverviewSelection(-1)
                    Keys.onRightPressed: root.moveOverviewSelection(1)
                    Keys.onUpPressed: root.moveOverviewSelection(-2)
                    Keys.onDownPressed: root.moveOverviewSelection(2)
                    Keys.onReturnPressed: root.focusOverviewSelection()
                    Keys.onEnterPressed: root.focusOverviewSelection()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    Text {
                        Layout.fillWidth: true
                        text: "Fenêtres — workspace "
                            + (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "")
                        color: root.foreground
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Flèches pour choisir · Entrée pour ouvrir · Échap pour fermer"
                        color: root.foreground
                        opacity: 0.7
                    }

                    GridView {
                        id: overviewGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: width / 2
                        cellHeight: 112
                        model: root.overviewToplevels
                        currentIndex: root.overviewIndex
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: overviewGrid.cellWidth
                            height: overviewGrid.cellHeight

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 5
                                radius: 8
                                color: root.overviewIndex === index
                                    ? root.selection : root.background
                                border.width: root.overviewIndex === index ? 2 : 1
                                border.color: root.overviewIndex === index
                                    ? root.accent : root.surface

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 12

                                    Image {
                                        readonly property var desktopEntry: DesktopEntries.heuristicLookup(
                                            modelData.lastIpcObject.class || "")
                                        source: desktopEntry
                                            ? Quickshell.iconPath(desktopEntry.icon, true) : ""
                                        sourceSize.width: 32
                                        sourceSize.height: 32
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        visible: source.toString().length > 0
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.title || "Sans titre"
                                            elide: Text.ElideRight
                                            color: root.overviewIndex === index
                                                ? root.accent : root.foreground
                                            font.pixelSize: 16
                                            font.bold: true
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.lastIpcObject.class || "Application"
                                            elide: Text.ElideRight
                                            color: root.foreground
                                            opacity: 0.7
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: root.overviewIndex = index
                                    onClicked: {
                                        root.overviewIndex = index;
                                        root.focusOverviewToplevel(modelData);
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.overviewToplevels.length === 0
                            text: "Aucune fenêtre dans ce workspace"
                            color: root.foreground
                            opacity: 0.7
                        }
                    }
                }
            }
        }
    }
}
