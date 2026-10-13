import QtQuick
import QtQuick.Layouts

CrtPanel {
    id: clockPanel
    title: "LOCAL CHRONO"
    status: timeZoneLabel()

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

    RowLayout {
        anchors.fill: parent
        spacing: 16

        // Time, seconds, and date.
        ColumnLayout {
            Layout.preferredWidth: 168
            Layout.fillHeight: true
            spacing: 6

            Item { Layout.fillHeight: true }
            Row {
                spacing: 8
                Text {
                    id: timeText
                    text: Qt.formatTime(clockPanel.shell.now, "HH:mm")
                    color: clockPanel.shell.theme.retroCyan
                    font.family: clockPanel.shell.theme.pillFont
                    font.pixelSize: 46
                    font.bold: true
                }
                Text {
                    anchors.baseline: timeText.baseline
                    text: Qt.formatTime(clockPanel.shell.now, "ss")
                    color: clockPanel.shell.theme.panelDim
                    font.family: clockPanel.shell.theme.pillFont
                    font.pixelSize: 17
                    font.bold: true
                }
            }
            Text {
                text: clockPanel.weekdayLabel(clockPanel.shell.now) + " "
                    + clockPanel.dayMonthLabel(clockPanel.shell.now) + " " + clockPanel.shell.now.getFullYear()
                color: clockPanel.shell.theme.panelDim
                font.family: clockPanel.shell.theme.pillFont
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.5
            }
            Item { Layout.fillHeight: true }
        }

        // Analog clock.
        Canvas {
            id: analogClock
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignVCenter
            onPaint: {
                const context = getContext("2d");
                const center = width / 2;
                const now = clockPanel.shell.now;
                const theme = clockPanel.shell.theme;
                context.reset();
                context.strokeStyle = theme.panelDim;
                context.lineWidth = 2;
                context.beginPath();
                context.arc(center, center, 44, 0, Math.PI * 2);
                context.stroke();
                context.strokeStyle = theme.panelDim;
                for (let index = 0; index < 12; index++) {
                    const angle = index * Math.PI / 6 - Math.PI / 2;
                    const inner = index % 3 === 0 ? 33 : 37;
                    context.beginPath();
                    context.moveTo(center + Math.cos(angle) * inner, center + Math.sin(angle) * inner);
                    context.lineTo(center + Math.cos(angle) * 41, center + Math.sin(angle) * 41);
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
                hand((now.getHours() % 12 + now.getMinutes() / 60) * Math.PI / 6 - Math.PI / 2, 22, 4, theme.retroCyan);
                hand((now.getMinutes() + now.getSeconds() / 60) * Math.PI / 30 - Math.PI / 2, 33, 3, theme.retroCyan);
                hand(now.getSeconds() * Math.PI / 30 - Math.PI / 2, 38, 1, theme.panelDim);
                context.fillStyle = theme.retroCyan;
                context.fillRect(center - 3, center - 3, 6, 6);
            }
            Connections {
                target: clockPanel.shell
                function onNowChanged(): void { analogClock.requestPaint(); }
            }
            Component.onCompleted: requestPaint()
        }

        // Week, day of the year and zone.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            CrtRow {
                Layout.fillWidth: true
                Layout.fillHeight: true
                shell: clockPanel.shell
                label: "WEEK"
                value: String(clockPanel.isoWeek(clockPanel.shell.now)).padStart(2, "0")
            }
            CrtRow {
                Layout.fillWidth: true
                Layout.fillHeight: true
                shell: clockPanel.shell
                label: "DAY"
                value: clockPanel.dayOfYear(clockPanel.shell.now) + "/" + clockPanel.daysInYear(clockPanel.shell.now)
            }
            CrtGauge {
                shell: clockPanel.shell
                count: 20
                lit: Math.round(clockPanel.dayOfYear(clockPanel.shell.now)
                    / clockPanel.daysInYear(clockPanel.shell.now) * 20)
                blockWidth: 7
                blockHeight: 8
            }
            CrtRow {
                Layout.fillWidth: true
                Layout.fillHeight: true
                shell: clockPanel.shell
                label: "ZONE"
                value: clockPanel.timeZoneLabel().replace("LOCAL / ", "")
            }
        }
    }
}
