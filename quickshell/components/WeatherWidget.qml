import QtQuick

Item {
    id: weatherControl
    required property var shell
    width: 56
    height: 24
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

}
