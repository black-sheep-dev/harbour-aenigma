import QtQuick 2.0
import Sailfish.Silica 1.0

import "../."

Rectangle {
    property bool highlighted: false
    property bool error: false
    property bool fixed: false
    property bool showNotes: false

    width: Theme.itemSizeExtraSmall
    height: Theme.itemSizeExtraSmall

    color: BoardStyles.backgroundColor
    border.color: BoardStyles.gridColor
    border.width: 2

    Rectangle {
        anchors.fill: parent
        color: {
            if (highlighted) {
                return BoardStyles.backgroundHighlightColor
            } else if (error) {
                return BoardStyles.errorHighlightColor
            } else {
                return "transparent"
            }
        }
        opacity: BoardStyles.highlightOpacity
    }

    Grid {
        visible: showNotes
        rows: 3
        columns: 3

        anchors.fill: parent

        Repeater {
            model: 9

            Rectangle {
                width:  parent.width / 3
                height: width
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    color: BoardStyles.notesColor
                    font.pointSize: Math.max(parent.width * 0.6, 1)
                    text: index
                }
            }
        }
    }

    Text {
        visible: !showNotes
        anchors.centerIn: parent
        font.pointSize: Math.max(parent.width * 0.5, 1)
        font.bold: true

        color: {
            if (highlighted) {
                return BoardStyles.numberHighlightColor
            } else if (error) {
                return BoardStyles.errorColor
            } else if (fixed) {
                return BoardStyles.numberFixedColor
            } else {
                return BoardStyles.numberColor
            }
        }

        text: "1"
    }
}
