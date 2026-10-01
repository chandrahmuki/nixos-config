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

    Row {
        anchors.centerIn: parent
        spacing: 3

        PillIcon {
            shell: weatherControl.shell
            hovered: weatherHover.hovered
            glyph: weatherControl.shell.weatherIcon(weatherControl.shell.weatherCode)
            iconColor: weatherControl.shell.weatherCode >= 0
                ? weatherControl.shell.retroCyan : weatherControl.shell.pillMuted
        }
        Text {
            text: weatherControl.shell.weatherTemperature
            color: weatherControl.shell.retroCyan
            font.family: weatherControl.shell.pillFont
            font.pixelSize: 13
            font.bold: true
        }
    }

}
