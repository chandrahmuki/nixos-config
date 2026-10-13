import QtQuick

// A row of square blocks, `lit` of `count` filled.
Row {
    id: gauge
    required property var shell
    property int count: 10
    property int lit: 0
    property int blockWidth: 8
    property int blockHeight: 10
    spacing: 2

    Repeater {
        model: gauge.count
        delegate: Rectangle {
            required property int index
            width: gauge.blockWidth
            height: gauge.blockHeight
            color: index < gauge.lit ? gauge.shell.theme.retroCyan : gauge.shell.theme.panelFaint
        }
    }
}
