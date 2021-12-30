import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

Dialog {
    property int difficulty

    Column {
        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            //% "New game"
            title: qsTrId("id-new-game")

            //% "Generate"
            acceptText: qsTrId("id-generate")
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            wrapMode: Text.Wrap
            color: Theme.highlightColor

            //% "You can select a level of difficulty for your Sudoku puzzle."
            text: qsTrId("id-dialog-new-game-info")
        }

        SectionHeader {
            //% "Level of difficulty"
            text: qsTrId("id-level-of-difficulty")
        }

        ComboBox {
            id: difficultiySelect

            //% "Level"
            label: qsTrId("id-level")
            currentIndex: difficulty

            menu: ContextMenu {
                MenuItem {
                    //% "Easy"
                    text: qsTrId("id-easy")
                }
                MenuItem {
                    //% "Medium"
                    text: qsTrId("id-medium")
                }
                MenuItem {
                    //% "Hard"
                    text: qsTrId("id-hard")
                }
                MenuItem {
                    //% "Insane"
                    text: qsTrId("id-insane")
                }
            }
        }

        SectionHeader {
            //% "Support tools"
            text: qsTrId("id-support-tools")
        }

        TextSwitch {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            //% "Auto notes"
            text: qsTrId("id-auto-notes")
            //% "This option automatically adds all notes to a new sudoku puzzle."
            description: qsTrId("id-auto-notes-desc")

            onCheckedChanged: settings.autoNotes = checked

            Component.onCompleted: checked = settings.autoNotes
        }
    }

    onAccepted: difficulty = difficultiySelect.currentIndex
}
