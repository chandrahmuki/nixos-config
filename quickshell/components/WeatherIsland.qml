import QtQuick
import QtQuick.Layouts

Rectangle {
    id: weatherPanel
    required property var shell
    property bool expanded: false

    visible: opacity > 0
    y: 0
    opacity: expanded ? 1 : 0
    scale: expanded ? 1 : 0.96
    transformOrigin: Item.Center
    radius: 14
    clip: true
    color: shell.pillBackground

    Behavior on opacity { NumberAnimation { duration: 180 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    function openPanel(): void {
        closeTimer.stop();
        expanded = true;
    }

    function closePanel(): void {
        closeTimer.stop();
        expanded = false;
    }

    function scheduleClose(): void {
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (!panelHover.hovered)
                weatherPanel.expanded = false;
        }
    }

    HoverHandler {
        id: panelHover
        enabled: weatherPanel.expanded
        onHoveredChanged: {
            if (hovered)
                closeTimer.stop();
            else
                weatherPanel.scheduleClose();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 15
            spacing: 6

            Rectangle {
                id: statusDot
                width: 5
                height: 5
                radius: 3
                color: weatherPanel.shell.weatherOnline
                    ? weatherPanel.shell.retroCyan : weatherPanel.shell.retroCoral
                SequentialAnimation on opacity {
                    running: weatherPanel.expanded && weatherPanel.shell.weatherOnline
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1; duration: 800; easing.type: Easing.InOutSine }
                }
            }
            Text {
                text: weatherPanel.shell.weatherCity
                color: weatherPanel.shell.pillForeground
                font.family: weatherPanel.shell.pillFont
                font.pixelSize: 12
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "UPDATED " + weatherPanel.shell.weatherUpdated
                color: weatherPanel.shell.retroCyan
                font.family: weatherPanel.shell.pillFont
                font.pixelSize: 9
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: weatherPanel.shell.panelLine
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // HERO: the only large visual, deliberately left-aligned like a
            // small hardware display rather than a stretched dashboard card.
            Column {
                Layout.preferredWidth: 104
                Layout.fillHeight: true
                spacing: 1

                Text {
                    id: heroIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: weatherPanel.shell.weatherIcon(weatherPanel.shell.weatherCode)
                    color: weatherPanel.shell.retroAmber
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 28
                    rotation: 0
                    SequentialAnimation on rotation {
                        running: weatherPanel.expanded && weatherPanel.shell.weatherOnline
                            && weatherPanel.shell.weatherCode === 113
                        loops: Animation.Infinite
                        PauseAnimation { duration: 2600 }
                        NumberAnimation { to: 4; duration: 230; easing.type: Easing.InOutSine }
                        NumberAnimation { to: -3; duration: 360; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0; duration: 230; easing.type: Easing.InOutSine }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: weatherPanel.shell.weatherTemperature
                    color: weatherPanel.shell.pillForeground
                    font.family: weatherPanel.shell.pillFont
                    font.pixelSize: 27
                    font.bold: true
                }
                Text {
                    width: parent.width
                    text: weatherPanel.shell.weatherOnline
                        ? weatherPanel.shell.weatherCondition(weatherPanel.shell.weatherCode) : "OFFLINE"
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    color: weatherPanel.shell.weatherOnline
                        ? weatherPanel.shell.retroAmber : weatherPanel.shell.retroCoral
                    font.family: weatherPanel.shell.pillFont
                    font.pixelSize: 9
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: weatherPanel.shell.panelLine }

            // METRICS: a compact vertical readout, not another card grid.
            Column {
                Layout.preferredWidth: 126
                Layout.fillHeight: true
                spacing: 0

                Repeater {
                    model: [
                        ["FEELS", weatherPanel.shell.weatherFeelsLike],
                        ["HUMID", weatherPanel.shell.weatherHumidity],
                        ["WIND", weatherPanel.shell.weatherWind],
                        ["RAIN", weatherPanel.shell.weatherRain]
                    ]
                    delegate: Row {
                        required property var modelData
                        width: parent.width
                        height: 22
                        Text {
                            width: 45
                            text: modelData[0]
                            color: weatherPanel.shell.retroCyan
                            font.family: weatherPanel.shell.pillFont
                            font.pixelSize: 9
                        }
                        Text {
                            width: parent.width - 45
                            text: modelData[1]
                            elide: Text.ElideRight
                            color: weatherPanel.shell.pillForeground
                            font.family: weatherPanel.shell.pillFont
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: weatherPanel.shell.panelLine }

            // FORECAST: three bounded mini displays use coral only as a
            // temperature/status accent, leaving the rest quiet and legible.
            Row {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                Repeater {
                    model: weatherPanel.shell.weatherForecast
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: 55
                        height: parent.height
                        radius: 3
                        color: weatherPanel.shell.panelSurface
                        border.width: 1
                        border.color: weatherPanel.shell.panelLine

                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                color: weatherPanel.shell.retroCyan
                                font.family: weatherPanel.shell.pillFont
                                font.pixelSize: 9
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: weatherPanel.shell.weatherIcon(modelData.code)
                                color: index === 1 ? weatherPanel.shell.retroCoral : weatherPanel.shell.retroAmber
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 17
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.temperature
                                color: weatherPanel.shell.pillForeground
                                font.family: weatherPanel.shell.pillFont
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
