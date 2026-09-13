import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// A one-shot MuggyNix brand splash, shown once when the Hyprland/Quickshell
// session starts. The GIF itself plays once and holds on its settled final
// frame (built with -loop -1), so only the card's fade-out and the window's
// eventual disappearance need to be driven from here.
Variants {
    id: splash
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: splashWindow
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        focusable: false
        color: "transparent"
        visible: splash.shell.splashActive
            && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor

        Rectangle {
            // The splash owns the whole screen; the original pixel logo stays
            // centered as the only focal element.
            anchors.fill: parent
            radius: 0
            color: splash.shell.background
            opacity: splash.shell.splashVisible ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 380; easing.type: Easing.InOutQuad }
            }

            AnimatedImage {
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.5, 1440)
                height: width * 360 / 960
                // Same original animated pixel logo, with only its opaque
                // navy canvas keyed out so it belongs to the full-screen
                // MuggyNix background.
                source: "../assets/muggynix-intro-transparent.gif"
                playing: true
                cache: false
                fillMode: Image.PreserveAspectFit
                // The source is deliberately pixelated; smoothing would blur
                // the sprite edges instead of keeping them crisp.
                smooth: false
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: splash.shell.dismissSplash()
            }
        }
    }
}
