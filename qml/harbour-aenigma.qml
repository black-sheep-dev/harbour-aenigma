import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "pages"

import org.nubecula.aenigma 1.0

ApplicationWindow {

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-aenigma"
        synchronous: true

        property bool highlighting: true
        property int lastDifficulty: Difficulty.Medium
        property bool preventDisplayBlanking: true
        property bool autoNotes: false

        onAutoNotesChanged: Sudoku.autoNotes = autoNotes
    }

    initialPage: Component { GamePage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
