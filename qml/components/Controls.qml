import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

import "."
import "../."

Item {
    id: controlsPanel
    property int mode: EditMode.Add

    height: controlsRow.height + buttonRow.height

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

    Flow {
        id: controlsRow
        anchors.top: parent.top
        width: parent.width
        spacing: Theme.paddingMedium

        IconSwitch {
            id: switchAdd
            checked: true
            source: "image://theme/icon-m-tab-new"
            onCheckedChanged: if (checked) mode = EditMode.Add
        }
        IconSwitch {
            id: switchNote
            source: "image://theme/icon-m-edit"
            onCheckedChanged: if (checked) mode = EditMode.Note
        }
        IconSwitch {
            id: switchDelete
            source: "image://theme/icon-m-delete"
            onCheckedChanged: if (checked) mode = EditMode.Delete
        }
        IconSwitch {
            id: switchHint
            source: "image://theme/icon-m-question"
            onCheckedChanged: if (checked) mode = EditMode.Hint
        }
        IconSwitch {
            highlichtColor: Theme.errorColor
            source: "image://theme/icon-m-warning"
            onCheckedChanged: Global.showErrors = checked
        }

        IconSwitch {
            checkable: false
            source: "image://theme/icon-m-back"
            onCheckedChanged: Sudoku.undo()
        }
    }


    Row {
        id: buttonRow
        anchors.top: controlsRow.bottom
        anchors.topMargin: Theme.paddingLarge
        width: parent.width
        spacing: Theme.paddingSmall

        Repeater {
            model: 9

            Button {
                preferredWidth: (buttonRow.width - 8*buttonRow.spacing) / 9
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
                    target: Sudoku
                    onNumberFinished: {
                        if (number !== (index + 1)) return
                        overlayRect.visible = finished
                    }
                }
            }
        }
    }
}


