import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications

// Notification server, the five notifications shown by the stack window, and the
// helpers that open their links or actions and then give the focus back to the
// default browser. The shell exposes it as `shell.notifications`.
Item {
    id: notifications
    required property var shell

    property var active: []
    property string defaultBrowserDesktopId: ""

    NotificationServer {
        id: notificationServer
        // Advertise the capabilities that the shell actually renders. This
        // prevents clients such as Blueman from falling back to a GTK dialog.
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;
            notifications.active = [notification].concat(notifications.active.filter(function(item) {
                return item.id !== notification.id;
            })).slice(0, 5);
        }
    }

    function forget(id: int): void {
        active = active.filter(function(notification) {
            return notification.id !== id;
        });
    }

    function focusDefaultBrowser(): void {
        const browserId = defaultBrowserDesktopId.toLowerCase();
        const browserStem = browserId.replace(/\.desktop$/, "");
        let browser = Hyprland.toplevels.values.find(function(toplevel) {
            const entry = shell.desktopEntryFor(toplevel);
            if (entry) {
                const entryId = entry.id.toLowerCase();
                const entryStem = entryId.replace(/\.desktop$/, "");
                if (entryId === browserId || entryStem === browserStem)
                    return true;
            }

            const ipc = toplevel.lastIpcObject || {};
            return (ipc.class || "").toLowerCase() === browserStem;
        });
        console.log("Focusing browser:", browserId, browser ? browser.address : "not found");
        shell.focusToplevel(browser);
    }

    function openLink(link): void {
        Qt.openUrlExternally(link);
        if (/^https?:/i.test(link))
            browserFocusTimer.restart();
    }

    function linkFor(notification): string {
        const match = notification.body.match(/href\s*=\s*["']([^"']+)["']/i);
        return match ? match[1] : "";
    }

    function invokeAction(action): void {
        action.invoke();
        // Most web notifications call their primary action "open". Give the
        // browser a moment to handle it, then explicitly restore its focus.
        if (action.identifier === "open" || action.identifier === "default")
            browserFocusTimer.restart();
    }

    Timer {
        id: browserFocusTimer
        interval: 180
        onTriggered: notifications.focusDefaultBrowser()
    }

    Process {
        // Keep link focus tied to the user's configured browser, not a
        // hard-coded application class.
        command: ["xdg-settings", "get", "default-web-browser"]
        running: true
        stdout: SplitParser {
            onRead: data => notifications.defaultBrowserDesktopId = data.trim().toLowerCase()
        }
    }
}
