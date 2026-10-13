import QtQuick

Item {
    id: weatherControl
    required property var shell
    width: 48
    height: 44
    signal openRequested()
    signal closeRequested()

    Timer {
        id: weatherOpenTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (weatherHover.hovered)
                weatherControl.openRequested();
        }
    }

    function schedulePanelOpen(): void {
        weatherOpenTimer.restart();
    }

    function schedulePanelClose(): void {
        weatherOpenTimer.stop();
        closeRequested();
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
        anchors.margins: 2
        radius: 6
        color: weatherHover.hovered ? weatherControl.shell.theme.surfaceHover : "transparent"
    }

    // The temperature sits under the icon, inside the same cell.
    Column {
        anchors.centerIn: parent
        spacing: 2

        PixelIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            size: 16
            name: weatherControl.shell.weather.iconName(weatherControl.shell.weather.code)
            color: weatherControl.shell.weather.code >= 0
                ? weatherControl.shell.theme.pillForeground : weatherControl.shell.theme.pillSecondary
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: weatherControl.shell.weather.temperature
            color: weatherControl.shell.theme.pillForeground
            font.family: weatherControl.shell.theme.pillFont
            font.pixelSize: 12
            font.bold: true
        }
    }

}
