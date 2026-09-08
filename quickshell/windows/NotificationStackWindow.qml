import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications

Variants {
    id: notificationStack
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: notificationWindow
        required property var modelData
        readonly property var hyprMonitor: Hyprland.monitorFor(modelData)
        screen: modelData
        anchors { top: true; right: true }
        implicitWidth: 360
        implicitHeight: Math.min(notificationList.contentHeight + 24, 720)
        margins { top: 66; right: 18 }
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: false
        color: "transparent"
        visible: notificationWindow.hyprMonitor
            && Hyprland.focusedMonitor
            && notificationWindow.hyprMonitor.id === Hyprland.focusedMonitor.id
            && notificationStack.shell.activeNotifications.length > 0

        ListView {
            id: notificationList
            anchors.fill: parent
            anchors.margins: 12
            clip: true
            spacing: 9
            model: notificationStack.shell.activeNotifications
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; to: 0; duration: 180 }
                    NumberAnimation { property: "scale"; to: 0.96; duration: 180 }
                }
            }

            delegate: Rectangle {
                id: notificationCard
                required property var modelData
                readonly property var notification: modelData
                readonly property string link: notificationStack.shell.linkForNotification(notification)
                // D-Bus expiration timeouts are already expressed in ms.
                readonly property int timeout: notification.expireTimeout > 0
                    ? notification.expireTimeout : 7000
                width: notificationList.width
                height: notificationContent.implicitHeight + 28
                radius: 14
                scale: 1
                color: notificationStack.shell.pillBackground
                border.width: notification.urgency === NotificationUrgency.Critical ? 2 : 1
                border.color: notification.urgency === NotificationUrgency.Critical
                    ? "#ff6b6b" : "#303030"

                MouseArea {
                    anchors.fill: parent
                    z: 3
                    enabled: notificationCard.link.length > 0
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        notificationStack.shell.openNotificationLink(notificationCard.link);
                        notification.dismiss();
                    }
                }

                Timer {
                    // D-Bus specifies 0 as persistent. Negative or absent
                    // timeouts use our normal seven-second fallback.
                    running: !notification.resident && notification.expireTimeout !== 0
                    interval: notificationCard.timeout
                    onTriggered: notification.expire()
                }

                Connections {
                    target: notification
                    function onClosed(): void {
                        notificationStack.shell.forgetNotification(notification.id);
                    }
                }

                RowLayout {
                    id: notificationContent
                    z: 2
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 11

                    Image {
                        readonly property string iconSource: notification.image.length > 0
                            ? notification.image : notification.appIcon
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        visible: iconSource.length > 0
                        source: iconSource
                        sourceSize.width: 84
                        sourceSize.height: 84
                        fillMode: Image.PreserveAspectFit
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: notification.summary
                            color: notificationStack.shell.foreground
                            font.bold: true
                            font.pixelSize: 20
                            font.family: notificationStack.shell.pillFont
                            wrapMode: Text.Wrap
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: notification.body.length > 0
                            text: notification.body
                            textFormat: Text.RichText
                            color: notificationStack.shell.foreground
                            linkColor: notificationStack.shell.accent
                            opacity: 0.88
                            font.pixelSize: 18
                            font.family: notificationStack.shell.pillFont
                            wrapMode: Text.Wrap
                            onLinkActivated: link => notificationStack.shell.openNotificationLink(link)
                        }

                        Row {
                            spacing: 6
                            visible: notification.actions.length > 0
                            Repeater {
                                model: notification.actions
                                delegate: Rectangle {
                                    required property var modelData
                                    width: actionLabel.implicitWidth + 16
                                    height: 26
                                    radius: 5
                                    color: actionArea.pressed ? "#303030" : "#1d1d1d"

                                    Text {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        color: notificationStack.shell.accent
                                        font.pixelSize: 16
                                        font.family: notificationStack.shell.pillFont
                                    }
                                    MouseArea {
                                        id: actionArea
                                        anchors.fill: parent
                                        onClicked: notificationStack.shell.invokeNotificationAction(modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    z: 4
                    width: 24
                    height: 24
                    radius: 12
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 9
                    color: dismissOverlay.pressed ? notificationStack.shell.selection : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: notificationStack.shell.foreground
                        font.pixelSize: 22
                        font.family: notificationStack.shell.pillFont
                    }
                    MouseArea {
                        id: dismissOverlay
                        anchors.fill: parent
                        onClicked: notification.dismiss()
                    }
                }
            }
        }
    }
}
