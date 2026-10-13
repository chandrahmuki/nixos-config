import QtQuick
import QtQuick.Layouts

// "LABEL ........ value", the line of a terminal listing.
RowLayout {
    id: crtRow
    required property var shell
    property string label: ""
    property string value: ""
    property int valueSize: 14
    spacing: 6

    Text {
        text: crtRow.label
        color: crtRow.shell.theme.panelDim
        font.family: crtRow.shell.theme.pillFont
        font.pixelSize: 11
        font.bold: true
        font.letterSpacing: 1
    }
    CrtDots {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignBottom
        Layout.bottomMargin: 3
        color: crtRow.shell.theme.panelFaint
    }
    Text {
        text: crtRow.value
        color: crtRow.shell.theme.retroCyan
        font.family: crtRow.shell.theme.pillFont
        font.pixelSize: crtRow.valueSize
        font.bold: true
    }
}
