import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Variants {
    id: powerMenu
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: powerMenuWindow
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "muggynix-power-menu"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"
        visible: powerMenu.shell.powerMenuOpen
            && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
        onVisibleChanged: if (visible) powerMenuKeyboard.forceActiveFocus()

        HyprlandFocusGrab {
            windows: [powerMenuWindow]
            active: powerMenuWindow.visible
            onCleared: powerMenu.shell.closePowerMenu()
        }

        // A single translucent forest-green veil covers the entire focused
        // display; Hyprland's namespace-specific layer rule blurs the scene
        // below it while the black action controls stay crisp above.
        Rectangle {
            anchors.fill: parent
            color: powerMenu.shell.background
            opacity: 0.82
        }

        MouseArea {
            anchors.fill: parent
            onClicked: powerMenu.shell.closePowerMenu()
        }

        Item {
            id: powerMenuKeyboard
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: powerMenu.shell.closePowerMenu()
            Keys.onLeftPressed: powerMenu.shell.movePowerMenuSelection(-1)
            Keys.onUpPressed: powerMenu.shell.movePowerMenuSelection(-1)
            Keys.onRightPressed: powerMenu.shell.movePowerMenuSelection(1)
            Keys.onDownPressed: powerMenu.shell.movePowerMenuSelection(1)
            Keys.onReturnPressed: powerMenu.shell.activatePowerMenuSelection()
            Keys.onEnterPressed: powerMenu.shell.activatePowerMenuSelection()

            readonly property var actions: [
                { label: "SUSPEND", icon: "󰖔", accent: powerMenu.shell.active },
                { label: "RESTART", icon: "󰜉", accent: powerMenu.shell.pillForeground },
                { label: "LOG OUT", icon: "󰍃", accent: powerMenu.shell.pillForeground },
                { label: "POWER OFF", icon: "󰐥", accent: "#ffc2d4" }
            ]

            Item {
                id: actionConstellation
                width: Math.min(560, parent.width - 48)
                height: Math.min(480, parent.height - 80)
                anchors.centerIn: parent

                Repeater {
                    model: powerMenuKeyboard.actions

                    delegate: Item {
                        id: actionToken
                        required property var modelData
                        required property int index
                        readonly property bool selected: powerMenu.shell.powerMenuIndex === index
                        readonly property bool confirming: selected && powerMenu.shell.powerMenuConfirming
                        property bool holding: false
                        property real holdProgress: 0
                        readonly property real actionX: index === 0 ? actionConstellation.width / 2 - width / 2
                            : index === 1 ? 30 : index === 2 ? actionConstellation.width - width - 30
                            : actionConstellation.width / 2 - width / 2
                        readonly property real actionY: index === 0 ? 0 : index === 3 ? actionConstellation.height - height
                            : actionConstellation.height / 2 - height / 2
                        x: actionX
                        y: actionY
                        width: 132
                        height: 158
                        z: 1

                        onHoldingChanged: {
                            if (holding) {
                                holdProgress = 0;
                                holdAnimation.restart();
                            } else {
                                holdAnimation.stop();
                                holdProgress = 0;
                            }
                        }
                        onHoldProgressChanged: holdRing.requestPaint()

                        NumberAnimation {
                            id: holdAnimation
                            target: actionToken
                            property: "holdProgress"
                            to: 1
                            duration: 900
                            easing.type: Easing.Linear
                            onFinished: {
                                if (actionToken.holding)
                                    powerMenu.shell.executePowerMenuAction(index);
                            }
                        }

                        Rectangle {
                            id: actionButton
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 104
                            height: 104
                            radius: width / 2
                            color: "#111111"
                            border.width: selected ? 2 : 1
                            border.color: selected ? modelData.accent : "#e1e1e1"

                            Behavior on border.color { ColorAnimation { duration: 120 } }
                            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                            scale: selected ? 1.06 : 1

                            Canvas {
                                id: holdRing
                                anchors.centerIn: parent
                                width: parent.width + 18
                                height: parent.height + 18
                                visible: parent.parent.holdProgress > 0
                                onPaint: {
                                    const context = getContext("2d");
                                    const center = width / 2;
                                    context.reset();
                                    context.strokeStyle = modelData.accent;
                                    context.lineWidth = 3;
                                    context.lineCap = "round";
                                    context.beginPath();
                                    context.arc(center, center, center - 3, -Math.PI / 2,
                                        -Math.PI / 2 + Math.PI * 2 * parent.parent.holdProgress);
                                    context.stroke();
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width + 12
                                height: parent.height + 12
                                radius: width / 2
                                color: "transparent"
                                border.width: selected ? 1 : 0
                                border.color: modelData.accent
                                opacity: selected ? 0.58 : 0
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: "#f2f2f2"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 42
                            }
                        }

                        Rectangle {
                            anchors.top: actionButton.bottom
                            anchors.topMargin: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.max(96, labelText.implicitWidth + 24)
                            height: 27
                            radius: height / 2
                            color: "#111111"
                            border.width: 1
                            border.color: selected ? modelData.accent : "#6a6a6a"

                            Text {
                                id: labelText
                                anchors.centerIn: parent
                                text: confirming ? "CONFIRM" : modelData.label
                                color: selected ? modelData.accent : powerMenu.shell.pillForeground
                                font.family: powerMenu.shell.pillFont
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                powerMenu.shell.powerMenuIndex = index;
                                powerMenu.shell.powerMenuConfirming = false;
                            }
                            onPressed: {
                                powerMenu.shell.powerMenuIndex = index;
                                powerMenu.shell.powerMenuConfirming = false;
                                actionToken.holding = true;
                            }
                            onReleased: actionToken.holding = false
                            onCanceled: actionToken.holding = false
                        }

                    }
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Math.max(34, parent.height * 0.09)
                width: helpText.implicitWidth + 26
                height: 27
                radius: height / 2
                color: "#111111"
                border.width: 1
                border.color: "#5a5a5a"
                z: 2

                Text {
                    id: helpText
                    anchors.centerIn: parent
                    text: powerMenu.shell.powerMenuConfirming
                        ? "ENTER AGAIN TO CONFIRM · ESC CANCEL"
                        : "HOLD CLICK · ARROWS · ENTER · ESC"
                    color: "#dedede"
                    font.family: powerMenu.shell.pillFont
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }
    }
}
