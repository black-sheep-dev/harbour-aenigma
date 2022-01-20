import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

import "../."
import "../components"

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    SilicaListView {
        PullDownMenu {
            MenuItem {
                //% "Reset"
                text: qsTrId("id-reset")
                //% "Resetting bookmarks"
                onClicked: remorse.execute(qsTrId("id-resetting-bookmarks"), function() {
                    sudokuGame.resetBookmarks()
                    pageStack.navigateBack()
                })
            }
        }

        RemorsePopup { id: remorse }

        header: PageHeader {
            //% "Bookmarks"
            title: qsTrId("id-bookmarks")
        }

        anchors.fill: parent

        model: sudokuGame.bookmarks

        delegate: ListItem {
            id: delegate

            contentHeight: contentColumn.height + 2*Theme.paddingSmall

            menu: ContextMenu {
                MenuItem {
                    //% "Load"
                    text: qsTrId("id-load")
                    //% "Loading bookmarked game state"
                    onClicked: delegate.remorseAction(qsTrId("id-load-bookmarked-state"), function() {
                        sudokuGame.fromBase64(modelData.gameData)
                        pageStack.navigateBack()
                    })
                }
                MenuItem {
                    //% "Delete"
                    text: qsTrId("id-delete")
                    //% "Deleting bookmark"
                    onClicked: delegate.remorseAction(qsTrId("id-deleting-bookmark"), function() {sudokuGame.deleteBookmark(index)})
                }
            }

            Sudoku { id: sudokuPreview }

            Column {
                id: contentColumn
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: Theme.paddingMedium

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingSmall

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-m-clock"
                        width: Theme.iconSizeExtraSmall
                        height: width
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Theme.fontSizeExtraSmall

                        text: new Date(modelData.timestamp).toLocaleString()
                    }

                }

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.75
                    height: width

                    transform: smooth

                    source: StandardPaths.cache + "/bookmarks/" + modelData.uuid + "_" + Math.round(new Date(modelData.timestamp) / 1000) + ".png"
                }
            }

            Component.onCompleted: sudokuPreview.fromBase64(modelData.gameData)
        }

        VerticalScrollDecorator {}
    }
}
