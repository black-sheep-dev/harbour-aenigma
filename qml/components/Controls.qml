import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

import "."
import "../."

Item {
    id: controlsPanel
    property int mode: EditMode.Add
    property bool portaitMode: true
    property var sudoku

    //height: Math.max(buttonsGrid.height, numberGrid.height)

    onModeChanged: {
        Global.mode = mode
        switch (mode) {
        case EditMode.Add:
            switchDelete.checked = false
            switchNote.checked = false
            switchHint.checked = false
            break

        case EditMode.Note:
            switchAdd.checked = false
            switchDelete.checked = false
            switchHint.checked = false
            break

        case EditMode.Delete:
            switchAdd.checked = false
            switchNote.checked = false
            switchHint.checked = false
            break

        case EditMode.Hint:
            switchAdd.checked = false
            switchNote.checked = false
            switchDelete.checked = false
            break

        default:
            break
        }
    }

    Grid {
        id: buttonsGrid
        anchors{
            top: parent.top
            left: parent.left
            right: portaitMode ? undefined : parent.right
        }
        rows: portaitMode ? 3 : 1
        columns: portaitMode ? 2 : 6
        spacing: portaitMode ? Theme.paddingMedium : Theme.paddingSmall
        width: switchAdd.width * columns + (columns - 1) * spacing

        IconSwitch {
            id: switchAdd
            enabled: !checked
            checked: true
            source: "image://theme/icon-m-add"
            onCheckedChanged: if (checked) mode = EditMode.Add
        }
        IconSwitch {
            id: switchNote
            enabled: !checked
            source: "image://theme/icon-m-edit"
            onCheckedChanged: if (checked) mode = EditMode.Note
        }
        IconSwitch {
            id: switchDelete
            enabled: !checked
            source: "image://theme/icon-m-delete"
            onCheckedChanged: if (checked) mode = EditMode.Delete
        }
        IconSwitch {
            id: switchHint
            enabled: !checked
            source: "image://theme/icon-m-question"
            onCheckedChanged: if (checked) mode = EditMode.Hint
        }
        IconSwitch {
            highlichtColor: Theme.errorColor
            source: "image://theme/icon-m-cancel"
            onCheckedChanged: Global.showErrors = checked
        }

        IconSwitch {
            enabled: sudoku.gameState !== GameState.Solved && sudoku.undoStepCount > 0
            checkable: false
            source: "image://theme/icon-m-back"
            onCheckedChanged: {
                sudoku.undo()
                sudoku.incrementStepsCount()
            }
        }
    }

    Grid {
        id: numberGrid
        anchors {
            top: portaitMode ? parent.top : buttonsGrid.bottom
            topMargin: portaitMode ? (buttonsGrid.height - height) / 2 : Theme.paddingLarge
            right: parent.right
            left: portaitMode ? buttonsGrid.right : parent.left
            leftMargin: portaitMode ? Theme.paddingLarge : 0
        }
        rows: 3
        columns: 3
        spacing: Theme.paddingMedium

        Repeater {
            model: 9

            Button {
                preferredWidth: (numberGrid.width - 2*numberGrid.spacing) / 3
                text: index + 1
                color: Global.selectedNumber === (index + 1) ? Theme.highlightColor : Theme.primaryColor

                onClicked: {
                    if (Global.selectedNumber === (index + 1)) {
                        Global.selectedNumber = -1
                    } else {
                        Global.selectedNumber = index + 1
                    }
                }

                Rectangle {
                    id: overlayRect
                    visible: false
                    anchors.fill: parent
                    color: Theme.highlightFromColor("#64DD17", Theme.colorScheme)
                    radius: Theme.paddingSmall
                    opacity: 0.4
                }

                Connections {
                    target: sudoku
                    onNumberFinished: {
                        if (number !== (index + 1)) return
                        overlayRect.visible = finished
                    }
                }
            }
        }
    }
}


