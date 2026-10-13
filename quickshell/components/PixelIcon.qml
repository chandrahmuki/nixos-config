import QtQuick
import QtQuick.Effects

// A 16x16 pixel-art icon of assets/icons (drawn by scripts/pill-icons.py), tinted with
// `color`. Use a size that is a multiple of 16 so that the pixels stay crisp.
Item {
    id: pixelIcon
    property string name: ""
    property color color: "white"
    property int size: 32
    width: size
    height: size

    Image {
        id: image
        anchors.fill: parent
        source: pixelIcon.name.length > 0 ? Qt.resolvedUrl("../assets/icons/" + pixelIcon.name + ".svg") : ""
        sourceSize: Qt.size(pixelIcon.size, pixelIcon.size)
        smooth: false
        visible: false
    }

    MultiEffect {
        anchors.fill: image
        source: image
        colorization: 1
        colorizationColor: pixelIcon.color
    }
}
