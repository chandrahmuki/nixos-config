import QtQuick
import QtQuick.Layouts

CrtPanel {
    id: weatherPanel
    title: shell.weather.city
    status: "UPDATED " + shell.weather.updated
    statusColor: shell.weather.online ? shell.theme.panelDim : shell.theme.retroCoral

    RowLayout {
        anchors.fill: parent
        spacing: 16

        // Current conditions.
        ColumnLayout {
            Layout.preferredWidth: 105
            Layout.fillHeight: true
            spacing: 4

            Item { Layout.fillHeight: true }
            PixelIcon {
                size: 48
                name: weatherPanel.shell.weather.iconName(weatherPanel.shell.weather.code)
                color: weatherPanel.shell.weather.online
                    ? weatherPanel.shell.theme.retroCyan : weatherPanel.shell.theme.panelDim
            }
            Text {
                text: weatherPanel.shell.weather.temperature
                color: weatherPanel.shell.theme.retroCyan
                font.family: weatherPanel.shell.theme.pillFont
                font.pixelSize: 38
                font.bold: true
            }
            Text {
                Layout.fillWidth: true
                text: weatherPanel.shell.weather.online
                    ? weatherPanel.shell.weather.condition(weatherPanel.shell.weather.code) : "OFFLINE"
                elide: Text.ElideRight
                color: weatherPanel.shell.weather.online
                    ? weatherPanel.shell.theme.panelDim : weatherPanel.shell.theme.retroCoral
                font.family: weatherPanel.shell.theme.pillFont
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 2
            }
            Item { Layout.fillHeight: true }
        }

        // The four readings, as a listing.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Repeater {
                model: [
                    ["FEELS", weatherPanel.shell.weather.feelsLike],
                    ["HUMID", weatherPanel.shell.weather.humidity],
                    ["WIND", weatherPanel.shell.weather.wind],
                    ["RAIN", weatherPanel.shell.weather.rain]
                ]
                delegate: CrtRow {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    shell: weatherPanel.shell
                    label: modelData[0]
                    value: modelData[1]
                }
            }
        }

        // Next three days, each column separated by a dotted rule.
        Row {
            Layout.fillHeight: true
            spacing: 0

            Repeater {
                model: weatherPanel.shell.weather.forecast
                delegate: Item {
                    required property var modelData
                    width: 48
                    height: parent.height

                    Rectangle {
                        width: 2
                        height: parent.height
                        color: weatherPanel.shell.theme.panelFaint
                    }
                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            color: weatherPanel.shell.theme.panelDim
                            font.family: weatherPanel.shell.theme.pillFont
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        PixelIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            size: 16
                            name: weatherPanel.shell.weather.iconName(modelData.code)
                            color: weatherPanel.shell.theme.retroCyan
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.temperature
                            color: weatherPanel.shell.theme.retroCyan
                            font.family: weatherPanel.shell.theme.pillFont
                            font.pixelSize: 15
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
}
