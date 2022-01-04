import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0

import org.nubecula.aenigma 1.0

import "."
import "pages"

ApplicationWindow {
    id: app

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-aenigma"
        synchronous: true

        property bool autoCleanupNotes: false
        property bool autoNotes: false
        property string gameStateData: ""
        property bool highlighting: true
        property int highlightMode: HighlightMode.Complete
        property int lastDifficulty: Difficulty.Medium
        property bool preventDisplayBlanking: true
        property int style: Styles.Default

        onAutoCleanupNotesChanged: Sudoku.autoCleanupNotes = autoCleanupNotes
        onAutoNotesChanged: Sudoku.autoNotes = autoNotes
        onStyleChanged: BoardStyles.setStyle(style)

        function reset() {
            clear()

            // default values
            autoCleanupNotes = false
            autoNotes = false
            gameStateData = ""
            highlighting = true
            highlightMode = HighlightMode.Complete
            lastDifficulty = Difficulty.Medium
            preventDisplayBlanking = true
            style = Styles.Default
        }
    }

    Notification {
        function show(message) {
            replacesId = 0
            previewSummary = ""
            previewBody = message
            icon = "/usr/share/icons/hicolor/86x86/apps/harbour-aenigma.png"
            publish()
        }

        id: notification
        appName: "Aenigma"
        expireTimeout: 3000
    }

    Connections {
        target: Sudoku
        //% "Generation of Sudoku game failed! Please try again!"
        onGeneratorFailed: notification.show(qsTrId("id-generator-failed-msg"))
    }

    initialPage: Component { GamePage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
