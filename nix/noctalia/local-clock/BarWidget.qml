import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

Item {
    id: root

    // Plugin API (injected by PluginService)
    property var pluginApi: null

    // Required properties for bar widgets
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    // Per-screen bar properties (for multi-monitor and vertical bar support)
    readonly property string screenName: screen?.name ?? ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

    // Content dimensions (visual capsule size)
    readonly property real contentWidth: content.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: capsuleHeight

    // Widget dimensions (extends to full bar height for better click area)
    implicitWidth: contentWidth
    implicitHeight: contentHeight

    property string currentTime: ""
    readonly property string localTimezoneFile: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/localtimezone"
    property string timezone: "UTC"
    visible: timezone !== "UTC"

    FileView {
        id: localTimezoneFileView
        path: localTimezoneFile
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: {
            timezone = this.text().trim();
        }
    }

    Process {
        id: getTime
        running: true
        command: ["sh", "-c", "TZ=" + timezone + " date +'%Y-%m-%d %I:%M %p %Z'"]
        stdout: StdioCollector {}

        onExited: exitCode => {
            if (exitCode === 0) {
                root.currentTime = stdout.text.trim();
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            getTime.running = true;
        }
    }

    // Visual capsule - centered within the full click area
    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: Style.capsuleColor
        radius: Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        // Your widget content here (centered in visualCapsule)
        RowLayout {
            id: content
            anchors.centerIn: parent
            spacing: Style.marginS

            NText {
                text: currentTime
                color: Color.mOnSurface
                pointSize: barFontSize
            }
        }
    }
}
