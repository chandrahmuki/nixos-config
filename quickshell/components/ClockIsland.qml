import QtQuick
import QtQuick.Layouts

Rectangle {
    id: clockPanel
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

    function weekdayLabel(date: date): string {
        return ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][date.getDay()];
    }

    function dayMonthLabel(date: date): string {
        return String(date.getDate()).padStart(2, "0") + " "
            + ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"][date.getMonth()];
    }

    function dayOfYear(date: date): int {
        return Math.floor((Date.UTC(date.getFullYear(), date.getMonth(), date.getDate())
            - Date.UTC(date.getFullYear(), 0, 1)) / 86400000) + 1;
    }

    function daysInYear(date: date): int {
        const year = date.getFullYear();
        return year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0) ? 366 : 365;
    }

    function isoWeek(date: date): int {
        const utc = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
        const weekday = utc.getUTCDay() || 7;
        utc.setUTCDate(utc.getUTCDate() + 4 - weekday);
        return Math.ceil((((utc.getTime() - Date.UTC(utc.getUTCFullYear(), 0, 1)) / 86400000) + 1) / 7);
    }

    function timeZoneLabel(): string {
        const offset = -shell.now.getTimezoneOffset() / 60;
        return "LOCAL / UTC" + (offset >= 0 ? "+" : "") + offset;
    }

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
                clockPanel.expanded = false;
        }
    }

    HoverHandler {
        id: panelHover
        enabled: clockPanel.expanded
        onHoveredChanged: {
            if (hovered)
                closeTimer.stop();
            else
                clockPanel.scheduleClose();
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
                width: 5; height: 5; radius: 3
                color: clockPanel.shell.retroCyan
                SequentialAnimation on opacity {
                    running: clockPanel.expanded
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 500 }
                    NumberAnimation { to: 1; duration: 500 }
                }
            }
            Text {
                text: "LOCAL CHRONO"
                color: clockPanel.shell.pillForeground
                font.family: clockPanel.shell.pillFont
                font.pixelSize: 12
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: clockPanel.timeZoneLabel()
                color: clockPanel.shell.retroCyan
                font.family: clockPanel.shell.pillFont
                font.pixelSize: 9
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: clockPanel.shell.panelLine }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Column {
                Layout.preferredWidth: 148
                Layout.fillHeight: true
                spacing: 0
                Text {
                    width: parent.width
                    text: Qt.formatTime(clockPanel.shell.now, "HH:mm")
                    color: clockPanel.shell.pillForeground
                    font.family: clockPanel.shell.pillFont
                    font.pixelSize: 33
                    font.bold: true
                }
                Row {
                    spacing: 5
                    Text {
                        text: Qt.formatTime(clockPanel.shell.now, "ss") + " SEC"
                        color: clockPanel.shell.retroCoral
                        font.family: clockPanel.shell.pillFont
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        text: clockPanel.weekdayLabel(clockPanel.shell.now) + " / " + clockPanel.dayMonthLabel(clockPanel.shell.now)
                        color: clockPanel.shell.retroAmber
                        font.family: clockPanel.shell.pillFont
                        font.pixelSize: 10
                    }
                }
                Text {
                    text: String(clockPanel.shell.now.getFullYear())
                    color: clockPanel.shell.pillMuted
                    font.family: clockPanel.shell.pillFont
                    font.pixelSize: 10
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: clockPanel.shell.panelLine }

            Canvas {
                id: analogClock
                Layout.preferredWidth: 78
                Layout.preferredHeight: 78
                Layout.alignment: Qt.AlignVCenter
                onPaint: {
                    const context = getContext("2d");
                    const center = width / 2;
                    const now = clockPanel.shell.now;
                    context.reset();
                    context.strokeStyle = clockPanel.shell.panelLine;
                    context.lineWidth = 1;
                    context.beginPath();
                    context.arc(center, center, 34, 0, Math.PI * 2);
                    context.stroke();
                    for (let index = 0; index < 12; index++) {
                        const angle = index * Math.PI / 6 - Math.PI / 2;
                        const inner = index % 3 === 0 ? 25 : 28;
                        context.beginPath();
                        context.moveTo(center + Math.cos(angle) * inner, center + Math.sin(angle) * inner);
                        context.lineTo(center + Math.cos(angle) * 31, center + Math.sin(angle) * 31);
                        context.stroke();
                    }
                    function hand(angle, length, lineWidth, color) {
                        context.strokeStyle = color;
                        context.lineWidth = lineWidth;
                        context.beginPath();
                        context.moveTo(center, center);
                        context.lineTo(center + Math.cos(angle) * length, center + Math.sin(angle) * length);
                        context.stroke();
                    }
                    hand((now.getHours() % 12 + now.getMinutes() / 60) * Math.PI / 6 - Math.PI / 2, 17, 3, clockPanel.shell.retroAmber);
                    hand((now.getMinutes() + now.getSeconds() / 60) * Math.PI / 30 - Math.PI / 2, 25, 2, clockPanel.shell.pillForeground);
                    hand(now.getSeconds() * Math.PI / 30 - Math.PI / 2, 29, 1, clockPanel.shell.retroCoral);
                    context.fillStyle = clockPanel.shell.retroCyan;
                    context.beginPath();
                    context.arc(center, center, 2.5, 0, Math.PI * 2);
                    context.fill();
                }
                Connections {
                    target: clockPanel.shell
                    function onNowChanged(): void { analogClock.requestPaint(); }
                }
                Component.onCompleted: requestPaint()
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: clockPanel.shell.panelLine }

            Column {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                Repeater {
                    model: [
                        ["WEEK", String(clockPanel.isoWeek(clockPanel.shell.now)).padStart(2, "0")],
                        ["DAY", clockPanel.dayOfYear(clockPanel.shell.now) + " / " + clockPanel.daysInYear(clockPanel.shell.now)],
                        ["ZONE", clockPanel.timeZoneLabel()]
                    ]
                    delegate: Row {
                        required property var modelData
                        width: parent.width
                        Text { width: 42; text: modelData[0]; color: clockPanel.shell.retroCyan; font.family: clockPanel.shell.pillFont; font.pixelSize: 9 }
                        Text { text: modelData[1]; color: clockPanel.shell.pillForeground; font.family: clockPanel.shell.pillFont; font.pixelSize: 11; font.bold: true }
                    }
                }
            }
        }
    }
}
