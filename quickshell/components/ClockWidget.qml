import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: clockControl
    required property var shell
    width: 54
    height: 24
    property bool panelOpen: false
    property date currentDate: shell.now

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
        const offset = -currentDate.getTimezoneOffset() / 60;
        return "LOCAL / UTC" + (offset >= 0 ? "+" : "") + offset;
    }

    Timer {
        id: closeTimer
        interval: 220
        repeat: false
        onTriggered: clockControl.panelOpen = false
    }

    Timer {
        id: openTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (clockHover.hovered)
                clockControl.keepPanelOpen();
        }
    }

    function keepPanelOpen(): void {
        closeTimer.stop();
        openTimer.stop();
        panelOpen = true;
    }

    function schedulePanelOpen(): void {
        closeTimer.stop();
        openTimer.restart();
    }

    function schedulePanelClose(): void {
        openTimer.stop();
        closeTimer.restart();
    }

    HoverHandler {
        id: clockHover
        onHoveredChanged: {
            if (hovered)
                clockControl.schedulePanelOpen();
            else
                clockControl.schedulePanelClose();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: clockHover.hovered ? "#202020" : "transparent"
    }

    Text {
        anchors.centerIn: parent
        text: Qt.formatTime(clockControl.shell.now, "HH:mm")
        color: clockControl.shell.pillForeground
        font.bold: true
        font.pixelSize: 17
        font.family: clockControl.shell.pillFont
    }

    PopupWindow {
        id: clockPopup
        visible: clockControl.panelOpen
        implicitWidth: 322
        implicitHeight: 158
        anchor {
            item: clockControl
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            rect.x: clockControl.width / 2 - clockPopup.width / 2
            margins.top: 12
        }
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: clockControl.shell.pillBackground
            border.width: 1
            border.color: "#d8d8d8"

            HoverHandler {
                onHoveredChanged: {
                    if (hovered)
                        clockControl.keepPanelOpen();
                    else
                        clockControl.schedulePanelClose();
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 13

                ColumnLayout {
                    Layout.preferredWidth: 74
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 3
                    Text {
                        text: clockControl.weekdayLabel(clockControl.currentDate)
                        color: clockControl.shell.pillForeground
                        font.family: clockControl.shell.pillFont
                        font.pixelSize: 24
                        font.bold: true
                    }
                    Text {
                        text: clockControl.dayMonthLabel(clockControl.currentDate)
                        color: "#d6d6d6"
                        font.family: clockControl.shell.pillFont
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Text {
                        text: String(clockControl.currentDate.getFullYear())
                        color: "#898989"
                        font.family: clockControl.shell.pillFont
                        font.pixelSize: 12
                    }
                }

                Canvas {
                    id: analogClock
                    Layout.preferredWidth: 66
                    Layout.preferredHeight: 66
                    Layout.alignment: Qt.AlignVCenter
                    onPaint: {
                        const context = getContext("2d");
                        const size = width;
                        const center = size / 2;
                        const now = clockControl.currentDate;
                        context.reset();
                        context.strokeStyle = "#d8d8d8";
                        context.lineWidth = 1.5;
                        context.beginPath();
                        context.arc(center, center, 28, 0, Math.PI * 2);
                        context.stroke();
                        for (let index = 0; index < 12; index++) {
                            const angle = index * Math.PI / 6 - Math.PI / 2;
                            const outer = 25;
                            const inner = index % 3 === 0 ? 20 : 22;
                            context.beginPath();
                            context.moveTo(center + Math.cos(angle) * inner, center + Math.sin(angle) * inner);
                            context.lineTo(center + Math.cos(angle) * outer, center + Math.sin(angle) * outer);
                            context.stroke();
                        }
                        function hand(angle, length, width, color) {
                            context.strokeStyle = color;
                            context.lineWidth = width;
                            context.beginPath();
                            context.moveTo(center, center);
                            context.lineTo(center + Math.cos(angle) * length, center + Math.sin(angle) * length);
                            context.stroke();
                        }
                        hand((now.getHours() % 12 + now.getMinutes() / 60) * Math.PI / 6 - Math.PI / 2, 15, 2.5, "#f2f2f2");
                        hand((now.getMinutes() + now.getSeconds() / 60) * Math.PI / 30 - Math.PI / 2, 22, 1.5, "#f2f2f2");
                        hand(now.getSeconds() * Math.PI / 30 - Math.PI / 2, 24, 1, "#00f5d4");
                        context.fillStyle = "#00f5d4";
                        context.beginPath();
                        context.arc(center, center, 2.5, 0, Math.PI * 2);
                        context.fill();
                    }
                    Connections {
                        target: clockControl.shell
                        function onNowChanged(): void { analogClock.requestPaint(); }
                    }
                    Component.onCompleted: requestPaint()
                }

                Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: "#4b4b4b" }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 7
                    Text {
                        text: "WEEK " + clockControl.isoWeek(clockControl.currentDate)
                        color: clockControl.shell.pillForeground
                        font.family: clockControl.shell.pillFont
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Text {
                        text: "DAY " + clockControl.dayOfYear(clockControl.currentDate) + " / " + clockControl.daysInYear(clockControl.currentDate)
                        color: "#c2c2c2"
                        font.family: clockControl.shell.pillFont
                        font.pixelSize: 12
                    }
                    Text {
                        text: clockControl.timeZoneLabel()
                        color: "#00f5d4"
                        font.family: clockControl.shell.pillFont
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }
    }
}
