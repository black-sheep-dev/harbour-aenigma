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

    onPortaitModeChanged: {
        if (portaitMode) {
            buttonsGrid.anchors.top = parent.top
            buttonsGrid.anchors.left = none
            numberGrid.anchors.top = buttonsGrid.top
            numberGrid.anchors.topMargin = Theme.paddingLarge
        } else {

        }
    }

    height: Math.max(buttonsGrid.height, numberGrid.height)

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
        anchors.left: parent.left
        rows: 3
        columns: 2
        spacing: Theme.paddingMedium

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
            right: parent.right
            left: buttonsGrid.right
            leftMargin: Theme.paddingLarge
            verticalCenter: buttonsGrid.verticalCenter
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


