import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications

// Notifications stacked top to bottom at the top right, newest first. The newest
// sits in the strip the pill reserves at the top of the screen (exclusiveZone 74),
// so a single notification never covers a window; older ones are pushed down.
// Each card has its own expiry. Actions appear when the pointer is over a card.
Variants {
    id: notificationStack
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: notificationWindow
        required property var modelData
        readonly property var hyprMonitor: Hyprland.monitorFor(modelData)
        readonly property bool onFocusedMonitor: hyprMonitor
            && Hyprland.focusedMonitor
            && hyprMonitor.id === Hyprland.focusedMonitor.id
        readonly property var queue: notificationStack.shell.notifications.active
        readonly property int maxVisible: 3

        // The pill is centred; keep clear of it (about 276 px each side of the centre).
        readonly property int cardWidth: Math.round(Math.min(400, Math.max(280, modelData.width / 2 - 322)))
        readonly property int cardHeight: 58
        readonly property int cardSpacing: 8

        screen: modelData
        anchors { top: true; right: true }
        // The surface starts at the very top of the screen so a card can drop in
        // from above the edge; the cards sit 8 px down (see listView.y).
        margins { top: 0; right: 18 }
        // Constant size: resizing a layer surface makes Hyprland animate it (bounce).
        // Only the cards inside change; the mask below keeps the rest click-through.
        implicitWidth: cardWidth
        implicitHeight: 8 + maxVisible * cardHeight + (maxVisible - 1) * cardSpacing + 36 + 12
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: false
        color: "transparent"
        visible: hyprMonitor !== null && hyprMonitor !== undefined
        mask: Region { item: hitBox }

        function byId(id) {
            return queue.find(function(item) { return item.id === id; }) || null;
        }

        // Keeps the model in step with the service's list (by notification id) so the
        // list view can animate each card in and out instead of rebuilding all of them.
        function sync() {
            // Beyond the visible count the oldest are dropped, not kept waiting: they
            // were already shown and would otherwise pop back up later.
            if (onFocusedMonitor && queue.length > maxVisible) {
                const overflow = queue.slice(maxVisible);
                for (let k = 0; k < overflow.length; k++)
                    overflow[k].expire();
            }
            const want = onFocusedMonitor
                ? queue.slice(0, maxVisible).map(function(item) { return item.id; }) : [];
            for (let i = cardModel.count - 1; i >= 0; i--) {
                if (want.indexOf(cardModel.get(i).nid) < 0)
                    cardModel.remove(i);
            }
            for (let j = 0; j < want.length; j++) {
                if (j >= cardModel.count || cardModel.get(j).nid !== want[j])
                    cardModel.insert(j, { nid: want[j] });
            }
        }

        onQueueChanged: sync()
        onOnFocusedMonitorChanged: sync()
        Component.onCompleted: sync()

        ListModel { id: cardModel }

        Item {
            id: hitBox
            x: listView.x
            y: listView.y
            width: listView.count > 0 ? listView.width : 0
            height: listView.count > 0 ? Math.min(listView.contentHeight, listView.height) : 0
        }

        ListView {
            id: listView
            x: 0
            y: 8
            width: notificationWindow.cardWidth
            height: notificationWindow.implicitHeight - 8
            interactive: false
            spacing: notificationWindow.cardSpacing
            model: cardModel

            // New card: drops in from above the screen edge with a small bounce.
            add: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "scale"; from: 0.94; to: 1; duration: 360; easing.type: Easing.OutCubic }
                    NumberAnimation {
                        property: "y"
                        from: -(notificationWindow.cardHeight + 12)
                        to: ViewTransition.destination.y
                        duration: 420
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.25
                    }
                }
            }
            // Cards already there slide down to make room.
            displaced: Transition {
                NumberAnimation { property: "y"; duration: 280; easing.type: Easing.OutCubic }
            }
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; to: 0; duration: 240; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "scale"; to: 0.94; duration: 240; easing.type: Easing.OutCubic }
                }
            }

            delegate: Item {
                id: cardItem
                required property int nid
                // Looked up once: the notification leaves the service's list before
                // the remove animation ends, and the card must keep its text until then.
                property var notification: null
                readonly property string link: notification
                    ? notificationStack.shell.notifications.linkFor(notification) : ""
                readonly property bool critical: notification !== null
                    && notification.urgency === NotificationUrgency.Critical
                readonly property var visibleActions: notification ? notification.actions.filter(function(action) {
                    return action.text.length > 0 && action.identifier !== "default";
                }) : []
                readonly property bool expanded: visibleActions.length > 0 && cardHover.hovered

                width: listView.width
                height: card.height
                transformOrigin: Item.Top

                Component.onCompleted: notification = notificationWindow.byId(nid)

                Timer {
                    // D-Bus specifies 0 as persistent. Negative or absent
                    // timeouts use our normal seven-second fallback.
                    running: cardItem.notification !== null
                        && !cardItem.notification.resident && cardItem.notification.expireTimeout !== 0
                    interval: cardItem.notification && cardItem.notification.expireTimeout > 0
                        ? cardItem.notification.expireTimeout : 7000
                    onTriggered: cardItem.notification.expire()
                }

                Connections {
                    target: cardItem.notification
                    function onClosed(): void {
                        notificationStack.shell.notifications.forget(cardItem.notification.id);
                    }
                }

                Rectangle {
                    id: card
                    width: parent.width
                    height: notificationWindow.cardHeight + (cardItem.expanded ? 36 : 0)
                    radius: 14
                    color: notificationStack.shell.theme.pillBackground
                    border.width: cardItem.critical ? 2 : 1
                    border.color: cardItem.critical
                        ? notificationStack.shell.theme.critical : notificationStack.shell.theme.surfaceHover

                    Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                    HoverHandler { id: cardHover }

                    MouseArea {
                        anchors.fill: parent
                        z: 3
                        readonly property var primaryAction: cardItem.notification
                            ? notificationStack.shell.notifications.primaryActionFor(cardItem.notification) : null
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const notification = cardItem.notification;
                            if (!notification)
                                return;
                            // The app's own default action takes us to the exact chat
                            // (Teams web); a plain link is the fallback.
                            if (primaryAction) {
                                notificationStack.shell.notifications.invokeAction(primaryAction, notification.summary);
                                // Invoking the action already closes a normal notification;
                                // dismissing it again hits a destroyed object.
                                if (notification.resident)
                                    notification.dismiss();
                                return;
                            }
                            if (cardItem.link.length > 0)
                                notificationStack.shell.notifications.openLink(cardItem.link);
                            else
                                notificationStack.shell.notifications.focusSender(notification);
                            notification.dismiss();
                        }
                    }

                    RowLayout {
                        id: topRow
                        z: 2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 11
                        height: notificationWindow.cardHeight - 22
                        spacing: 10

                        Item {
                            id: notificationIcon
                            readonly property string iconSource: cardItem.notification
                                ? (cardItem.notification.image.length > 0
                                    ? cardItem.notification.image : cardItem.notification.appIcon) : ""
                            readonly property bool animatedRecorderIcon: cardItem.notification !== null
                                && cardItem.notification.appName === "Muggy Recorder"
                            readonly property bool hasSenderImage: cardItem.notification !== null
                                && cardItem.notification.image.length > 0
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            visible: animatedRecorderIcon || iconSource.length > 0

                            // A sender picture (Teams avatar) is round; app icons stay as is.
                            ClippingRectangle {
                                anchors.fill: parent
                                visible: !notificationIcon.animatedRecorderIcon
                                color: "transparent"
                                radius: notificationIcon.hasSenderImage ? width / 2 : 0

                                Image {
                                    anchors.fill: parent
                                    source: notificationIcon.iconSource
                                    sourceSize.width: 72
                                    sourceSize.height: 72
                                    fillMode: notificationIcon.hasSenderImage
                                        ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                                }
                            }

                            AnimatedImage {
                                anchors.fill: parent
                                visible: notificationIcon.animatedRecorderIcon
                                source: Qt.resolvedUrl("../assets/screen-recorder-animated.gif")
                                playing: visible
                                cache: false
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: cardItem.notification ? cardItem.notification.summary : ""
                                color: notificationStack.shell.theme.foreground
                                font.bold: true
                                font.pixelSize: 16
                                font.family: notificationStack.shell.theme.pillFont
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: cardItem.notification !== null && cardItem.notification.body.length > 0
                                text: cardItem.notification ? cardItem.notification.body : ""
                                textFormat: Text.StyledText
                                color: notificationStack.shell.theme.foreground
                                linkColor: notificationStack.shell.theme.accent
                                opacity: 0.88
                                font.pixelSize: 14
                                font.family: notificationStack.shell.theme.pillFont
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 12
                            color: dismissArea.pressed ? notificationStack.shell.theme.selection : "transparent"
                            z: 4

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: notificationStack.shell.theme.foreground
                                font.pixelSize: 22
                                font.family: notificationStack.shell.theme.pillFont
                            }
                            MouseArea {
                                id: dismissArea
                                anchors.fill: parent
                                onClicked: {
                                    if (cardItem.notification)
                                        cardItem.notification.dismiss();
                                }
                            }
                        }
                    }

                    Row {
                        z: 4
                        anchors.left: parent.left
                        anchors.leftMargin: 11 + (notificationIcon.visible ? 36 + 10 : 0)
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8
                        spacing: 6
                        visible: cardItem.expanded
                        Repeater {
                            model: cardItem.visibleActions
                            delegate: Rectangle {
                                required property var modelData
                                width: actionLabel.implicitWidth + 16
                                height: 26
                                radius: 5
                                color: actionArea.pressed ? notificationStack.shell.theme.surfacePressed : notificationStack.shell.theme.surfaceMuted

                                Text {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: modelData.text
                                    color: notificationStack.shell.theme.accent
                                    font.pixelSize: 16
                                    font.family: notificationStack.shell.theme.pillFont
                                }
                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent
                                    onClicked: notificationStack.shell.notifications.invokeAction(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
