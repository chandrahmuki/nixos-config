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
            glyph: weatherControl.shell.weather.icon(weatherControl.shell.weather.code)
            iconColor: weatherControl.shell.weather.code >= 0
                ? weatherControl.shell.theme.retroCyan : weatherControl.shell.theme.pillMuted
        }
        Text {
            text: weatherControl.shell.weather.temperature
            color: weatherControl.shell.theme.retroCyan
            font.family: weatherControl.shell.theme.pillFont
            font.pixelSize: 13
            font.bold: true
        }
    }

}
