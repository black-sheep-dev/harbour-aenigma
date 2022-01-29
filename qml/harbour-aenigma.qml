import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0

import org.nubecula.aenigma 1.0

import "."
import "pages"

ApplicationWindow {
    id: app

    Cache { id: cache }

    Sudoku {
        property var bookmarks: []

        function addBookmark(date) {
            const bookmark = {
                uuid: sudokuGame.uuid,
                timestamp: date.toISOString(),
                gameData: sudokuGame.toBase64(),
                description: ""
            }

            var dialog = pageStack.push(Qt.resolvedUrl("dialogs/AddBookmarkDialog.qml"))

            dialog.accepted.connect(function() {
                bookmark.description = dialog.description

                var arr = bookmarks
                arr.push(bookmark)
                bookmarks = arr

                //% "Bookmark added"
                notification.show(qsTrId("id-bookmark-added"))
            })
        }

        function deleteBookmark(index) {
            var arr = bookmarks
            arr.splice(index, 1)
            bookmarks = arr
        }

        function resetBookmarks() {
            bookmarks = []
            cache.cleanBookmarkScreenshots()
        }

        id: sudokuGame

        onBookmarksChanged: settings.bookmarks = JSON.stringify(bookmarks)
    }

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-aenigma"
        synchronous: true

        property bool autoCleanupNotes: false
        property bool autoNotes: false
        property string bookmarks: ""
        property string gameStateData: ""
        property bool highlighting: true
        property int highlightMode: HighlightMode.Complete
        property int lastDifficulty: Difficulty.Medium
        property bool preventDisplayBlanking: true
        property int style: Styles.Default
        property string customStyle: ""

        onAutoCleanupNotesChanged: sudokuGame.autoCleanupNotes = autoCleanupNotes
        onAutoNotesChanged: sudokuGame.autoNotes = autoNotes
        onStyleChanged: {
            if (style === Styles.Custom) {
                loadCustomStyle()
                return
            }
            BoardStyles.setStyle(style)

        }

        function reset() {
            clear()

            // default values
            autoCleanupNotes = false
            autoNotes = false
            bookmarks = ""
            gameStateData = ""
            highlighting = true
            highlightMode = HighlightMode.Complete
            lastDifficulty = Difficulty.Medium
            preventDisplayBlanking = true
            style = Styles.Default
            customStyle = ""

            cache.cleanBookmarkScreenshots()
        }

        function loadBookmarks() {
            if (bookmarks.length === 0) return
            sudokuGame.bookmarks = JSON.parse(bookmarks)
        }

        function loadCustomStyle() {
            if (customStyle.length === 0) return
            var custom = JSON.parse(customStyle)

            BoardStyles.backgroundColor = custom.backgroundColor
            BoardStyles.backgroundHighlightColor = custom.backgroundHighlightColor
            BoardStyles.backgroundOpacity = custom.backgroundOpacity
            BoardStyles.errorColor = custom.errorColor
            BoardStyles.errorHighlightColor = custom.errorHighlightColor
            BoardStyles.errorHighlightOpacity = custom.errorHighlightOpacity
            BoardStyles.gridColor = custom.gridColor
            BoardStyles.highlightOpacity = custom.highlightOpacity
            BoardStyles.notesColor = custom.notesColor
            BoardStyles.numberColor = custom.numberColor
            BoardStyles.numberFixedColor = custom.numberFixedColor
            BoardStyles.numberHighlightColor = custom.numberHighlightColor
        }

        Component.onCompleted: {
            if (style === Styles.Custom) loadCustomStyle()
            loadBookmarks()
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
        target: sudokuGame
        //% "Generation of Sudoku game failed! Please try again!"
        onGeneratorFailed: notification.show(qsTrId("id-generator-failed-msg"))
    }

    initialPage: Component { GamePage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
