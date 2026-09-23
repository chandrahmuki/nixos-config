import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

// The desktop wallpaper itself, replacing hyprpaper. Quickshell now owns
// the Background layer exclusively on every monitor, which is what lets a
// theme switch animate the wallpaper directly instead of racing a second,
// independent client (hyprpaper) for the same layer — that race is why the
// circular reveal never reliably showed up when it lived in a separate,
// transient overlay window.
//
// Base image always shows the settled current theme's wallpaper; the two
// layers above it only exist while shell.themeTransitionToId is set, and
// grow a circular mask (shell.themeTransitionProgress, driven from
// shell.qml's playThemeTransition) from the centre of the screen to reveal
// the incoming wallpaper over the outgoing one — Omarchy's own technique.
Variants {
    id: background
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: bgWindow
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "muggy-background"
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        visible: true

        function wallpaperUrl(themeId) {
            const theme = background.shell.themeProfiles.find(function(profile) {
                return profile.id === themeId;
            });
            return theme ? "../assets/wallpapers/" + theme.wallpaper : "";
        }

        readonly property bool transitioning: background.shell.themeTransitionToId !== ""

        // Small bundled assets, not arbitrary user photos, so a synchronous
        // decode costs a few ms at most — worth it to guarantee content is
        // actually painted before a transition's reveal animation finishes.
        Image {
            anchors.fill: parent
            source: bgWindow.wallpaperUrl(background.shell.activeThemeId)
            fillMode: Image.PreserveAspectCrop
            asynchronous: false
            cache: true
            smooth: true
            mipmap: true
        }

        Image {
            anchors.fill: parent
            visible: bgWindow.transitioning
            source: bgWindow.wallpaperUrl(background.shell.themeTransitionFromId)
            fillMode: Image.PreserveAspectCrop
            asynchronous: false
            cache: true
            smooth: true
            mipmap: true
        }

        Item {
            id: incomingLayer
            anchors.fill: parent
            visible: bgWindow.transitioning
            layer.enabled: bgWindow.transitioning
            layer.smooth: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: revealMask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 0.04
            }

            Image {
                anchors.fill: parent
                source: bgWindow.wallpaperUrl(background.shell.themeTransitionToId)
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                cache: true
                smooth: true
                mipmap: true
            }
        }

        Item {
            id: revealMask
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                readonly property real reach: Math.sqrt(Math.pow(revealMask.width / 2, 2) + Math.pow(revealMask.height / 2, 2)) + 8
                anchors.centerIn: parent
                width: reach * 2 * background.shell.themeTransitionProgress
                height: width
                radius: width / 2
                color: "white"
            }
        }
    }
}
