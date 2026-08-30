import QtQuick
import Quickshell
import Quickshell.Hyprland

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
        focusable: false
        color: "transparent"
        visible: splash.shell.splashActive
            && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor

        Rectangle {
            anchors.centerIn: parent
            width: 900
            height: 380
            radius: 20
            color: splash.shell.background
            border.width: 1
            border.color: splash.shell.active
            opacity: splash.shell.splashVisible ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 380; easing.type: Easing.InOutQuad }
            }

            AnimatedImage {
                anchors.centerIn: parent
                width: 840
                height: width * 360 / 960
                source: "../assets/muggynix-intro.gif"
                playing: true
                cache: false
                fillMode: Image.PreserveAspectFit
                // The source is already deliberately pixelated; smoothing
                // would blur the sprite edges instead of keeping them crisp.
                smooth: false
            }
        }
    }
}
