import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: weatherControl
    required property var shell
    width: 56
    height: 24
    property bool panelOpen: false

    Timer {
        id: weatherCloseTimer
        interval: 220
        repeat: false
        onTriggered: weatherControl.panelOpen = false
    }

    Timer {
        id: weatherOpenTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (weatherHover.hovered)
                weatherControl.keepPanelOpen();
        }
    }

    function keepPanelOpen(): void {
        weatherCloseTimer.stop();
        weatherOpenTimer.stop();
        panelOpen = true;
    }

    function schedulePanelOpen(): void {
        weatherCloseTimer.stop();
        weatherOpenTimer.restart();
    }

    function schedulePanelClose(): void {
        weatherOpenTimer.stop();
        weatherCloseTimer.restart();
    }

    HoverHandler {
        id: weatherHover
        onHoveredChanged: {
            if (hovered)
                weatherControl.schedulePanelOpen();
            else
                weatherControl.schedulePanelClose();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: weatherHover.hovered ? "#202020" : "transparent"
    }

    Row {
        anchors.centerIn: parent
        spacing: 3

        Text {
            text: weatherControl.shell.weatherIcon(weatherControl.shell.weatherCode)
            color: weatherControl.shell.weatherCode >= 0 ? weatherControl.shell.pillForeground : "#777777"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 17
        }
        Text {
            text: weatherControl.shell.weatherTemperature
            color: weatherControl.shell.pillForeground
            font.family: weatherControl.shell.pillFont
            font.pixelSize: 13
            font.bold: true
        }
    }

    PopupWindow {
        id: weatherPopup
        visible: weatherControl.panelOpen
        implicitWidth: 310
        implicitHeight: 246
        anchor {
            item: weatherControl
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            rect.x: weatherControl.width / 2 - weatherPopup.width / 2
            margins.top: 12
        }
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: weatherControl.shell.pillBackground
            border.width: 1
            border.color: "#d8d8d8"

            HoverHandler {
                onHoveredChanged: {
                    if (hovered)
                        weatherControl.keepPanelOpen();
                    else
                        weatherControl.schedulePanelClose();
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: weatherControl.shell.weatherCity
                        color: weatherControl.shell.pillForeground
                        font.family: weatherControl.shell.pillFont
                        font.pixelSize: 15
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "UPDATED " + weatherControl.shell.weatherUpdated
                        color: "#969696"
                        font.family: weatherControl.shell.pillFont
                        font.pixelSize: 11
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#505050" }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54
                    Text {
                        text: weatherControl.shell.weatherTemperature
                        color: weatherControl.shell.pillForeground
                        font.family: weatherControl.shell.pillFont
                        font.pixelSize: 38
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: weatherControl.shell.weatherOnline
                            ? weatherControl.shell.weatherCondition(weatherControl.shell.weatherCode) : "OFFLINE"
                        color: "#d7d7d7"
                        font.family: weatherControl.shell.pillFont
                        font.pixelSize: 14
                    }
                    Text {
                        text: weatherControl.shell.weatherIcon(weatherControl.shell.weatherCode)
                        color: weatherControl.shell.pillForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 30
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: 7
                    rowSpacing: 0

                    Repeater {
                        model: [
                            ["FEELS", weatherControl.shell.weatherFeelsLike],
                            ["HUMID", weatherControl.shell.weatherHumidity],
                            ["WIND", weatherControl.shell.weatherWind],
                            ["RAIN", weatherControl.shell.weatherRain]
                        ]
                        delegate: Column {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                text: modelData[0]
                                color: "#979797"
                                font.family: weatherControl.shell.pillFont
                                font.pixelSize: 10
                            }
                            Text {
                                width: parent.width
                                text: modelData[1]
                                elide: Text.ElideRight
                                color: weatherControl.shell.pillForeground
                                font.family: weatherControl.shell.pillFont
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#505050" }

                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: weatherControl.shell.weatherForecast
                        delegate: Column {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                color: "#979797"
                                font.family: weatherControl.shell.pillFont
                                font.pixelSize: 11
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: weatherControl.shell.weatherIcon(modelData.code)
                                color: weatherControl.shell.pillForeground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.temperature
                                color: weatherControl.shell.pillForeground
                                font.family: weatherControl.shell.pillFont
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
