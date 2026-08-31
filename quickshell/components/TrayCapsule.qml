import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: trayCapsule
    required property var shell
    implicitWidth: trayRow.implicitWidth + 10
    implicitHeight: 28
    radius: height / 2
    color: "#171717"
    border.width: 1
    border.color: "#d8d8d8"

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4
    Repeater {
        model: SystemTray.items
        delegate: Item {
            id: trayItem
            required property var modelData
            width: 24
            height: 24
            visible: modelData.status !== Status.Passive
            property bool menuOpen: false
            property var submenuEntry: null

            Timer {
                id: trayMenuCloseTimer
                interval: 220
                repeat: false
                onTriggered: {
                    trayItem.menuOpen = false;
                    trayItem.submenuEntry = null;
                }
            }

            Timer {
                id: trayMenuOpenTimer
                interval: 180
                repeat: false
                onTriggered: {
                    if (trayMouse.containsMouse)
                        trayItem.openMenu();
                }
            }

            function openMenu(): void {
                if (!modelData.hasMenu)
                    return;

                trayMenuCloseTimer.stop();
                submenuEntry = null;
                menuOpen = true;
            }

            function scheduleMenuOpen(): void {
                if (modelData.hasMenu)
                    trayMenuOpenTimer.restart();
            }

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: modelData.id === "remmina-icon"
                    ? "file:///home/david/.local/share/icons/catppuccin-mono-light/status/scalable/remmina-status.svg"
                    : modelData.id === "blueman"
                        ? "file:///home/david/.local/share/icons/catppuccin-mono-light/status/scalable/blueman-active.svg"
                        : modelData.icon
                sourceSize.width: width
                sourceSize.height: height
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onEntered: trayItem.scheduleMenuOpen()
                onExited: {
                    trayMenuOpenTimer.stop();
                    trayMenuCloseTimer.restart();
                }
                onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                            trayItem.openMenu();
                        } else if (mouse.button === Qt.LeftButton) {
                            if (modelData.onlyMenu && modelData.hasMenu)
                                trayItem.openMenu();
                            else
                                modelData.activate();
                    }
                }
            }

            PopupWindow {
                id: trayMenuPopup
                visible: trayItem.menuOpen
                implicitWidth: 240
                implicitHeight: 260
                anchor {
                    item: trayItem
                    edges: Edges.Bottom | Edges.Left
                    gravity: Edges.Bottom | Edges.Right
                    rect.x: trayItem.width / 2 - trayMenuPopup.width / 2
                    margins.top: 12
                }
                color: "transparent"

                QsMenuOpener {
                    id: trayPopupEntries
                    menu: modelData.menu
                }

                QsMenuOpener {
                    id: traySubmenuEntries
                    menu: trayItem.submenuEntry
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "#111111"
                    border.width: 1
                    border.color: "#d8d8d8"

                    HoverHandler {
                        onHoveredChanged: {
                            if (hovered)
                                trayMenuCloseTimer.stop();
                            else
                                trayMenuCloseTimer.restart();
                        }
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 2

                        Item {
                            visible: trayItem.submenuEntry !== null
                            width: parent.width
                            height: visible ? 28 : 0

                            Rectangle {
                                anchors.fill: parent
                                radius: 7
                                color: trayBackHover.hovered ? "#2a2a2a" : "transparent"
                            }
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 9
                                anchors.verticalCenter: parent.verticalCenter
                                text: "‹  BACK"
                                color: trayCapsule.shell.pillForeground
                                font.family: trayCapsule.shell.pillFont
                                font.pixelSize: 13
                                font.bold: true
                            }
                            HoverHandler { id: trayBackHover }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: trayItem.submenuEntry = null
                            }
                        }

                        Repeater {
                            model: trayItem.submenuEntry
                                ? traySubmenuEntries.children : trayPopupEntries.children
                            delegate: Item {
                                required property var modelData
                                width: parent.width
                                height: modelData.isSeparator ? 7 : 30

                                Rectangle {
                                    visible: modelData.isSeparator
                                    anchors.centerIn: parent
                                    width: parent.width - 12
                                    height: 1
                                    color: "#484848"
                                }
                                Rectangle {
                                    visible: !modelData.isSeparator
                                    anchors.fill: parent
                                    radius: 7
                                    color: trayOptionHover.hovered
                                        ? "#2a2a2a" : "transparent"
                                }
                                Text {
                                    visible: !modelData.isSeparator
                                    anchors.left: parent.left
                                    anchors.leftMargin: 9
                                    anchors.right: parent.right
                                    anchors.rightMargin: 22
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.text
                                    elide: Text.ElideRight
                                    color: modelData.enabled
                                        ? trayCapsule.shell.pillForeground : "#686868"
                                    font.family: trayCapsule.shell.pillFont
                                    font.pixelSize: 13
                                }
                                Text {
                                    visible: !modelData.isSeparator && modelData.hasChildren
                                    anchors.right: parent.right
                                    anchors.rightMargin: 9
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "›"
                                    color: "#bdbdbd"
                                    font.pixelSize: 18
                                }
                                HoverHandler { id: trayOptionHover }
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: !modelData.isSeparator && modelData.enabled
                                    onClicked: {
                                        if (modelData.hasChildren) {
                                            trayItem.submenuEntry = modelData;
                                        } else {
                                            modelData.triggered();
                                            trayItem.menuOpen = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }
}
}
