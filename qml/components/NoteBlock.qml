import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

import "../."

Grid {
    id: noteGrid

    property int notes: Note.None

    function numberPresent(index) {
        switch (index) {
        case 0:
            return notes & Note.One

        case 1:
            return notes & Note.Two

        case 2:
            return notes & Note.Three

        case 3:
            return notes & Note.Four

        case 4:
            return notes & Note.Five

        case 5:
            return notes & Note.Six

        case 6:
            return notes & Note.Seven

        case 7:
            return notes & Note.Eight

        case 8:
            return notes & Note.Nine

        default:
            return false

        }
    }

    rows: 3
    columns: 3

    anchors.fill: parent

    visible: notes !== Note.None

    Repeater {
        model: 9

        Rectangle {
            width: noteGrid.width / 3
            height: noteGrid.width / 3
            color: "transparent"
            border.width: 0

            Rectangle {
                anchors.fill: parent
                color: BoardStyles.backgroundHighlightColor
                opacity: (index + 1) === Global.selectedNumber && numberPresent(index) ? BoardStyles.highlightOpacity : 0.0
            }

            Text {
                id: valueLabel
                anchors.centerIn: parent
                color: (index + 1) === Global.selectedNumber ? BoardStyles.numberHighlightColor : BoardStyles.notesColor
                font.pointSize: Math.max(parent.width * 0.8, 1)

                text: {
                    if (index === 0 && (notes & Note.One)) return 1
                    if (index === 1 && (notes & Note.Two)) return 2
                    if (index === 2 && (notes & Note.Three)) return 3
                    if (index === 3 && (notes & Note.Four)) return 4
                    if (index === 4 && (notes & Note.Five)) return 5
                    if (index === 5 && (notes & Note.Six)) return 6
                    if (index === 6 && (notes & Note.Seven)) return 7
                    if (index === 7 && (notes & Note.Eight)) return 8
                    if (index === 8 && (notes & Note.Nine)) return 9

                    return ''
                }
            }
        }
    }
}
