import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Settings"
                title: qsTrId("id-settings")
            }

            SectionHeader {
                //% "General"
                text: qsTrId("id-general")
            }

            TextSwitch {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                //% "Prevent display blanking"
                text: qsTrId("id-display-blanking")
                //% "This option prevents display blanking during playing."
                description: qsTrId("id-display-blanking-desc")

                onCheckedChanged: settings.preventDisplayBlanking = checked
                Component.onCompleted: checked = settings.preventDisplayBlanking
            }

            SectionHeader {
                //% "Support tools"
                text: qsTrId("id-support-tools")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: Text.Wrap
                color: Theme.highlightColor

                //% "Choose a highlighting mode to highlight a single cell with the selected number or the row, column and block the selected number affects."
                text: qsTrId("id-highlight-combo-desc")
            }

            ComboBox {
                //% "Highlighting"
                label: qsTrId("id-highlighting")

                menu: ContextMenu {
                    MenuItem {
                        //% "None"
                        text: qsTrId("id-none")
                    }
                    MenuItem {
                        //% "Cell"
                        text: qsTrId("id-cell")
                    }
                    MenuItem {
                        //% "Row / column / block"
                        text: qsTrId("id-row-column-block")
                    }
                }

                onCurrentIndexChanged: settings.highlightMode = currentIndex
                Component.onCompleted: currentIndex = settings.highlightMode
            }

            TextSwitch {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                //% "Auto clean"
                text: qsTrId("id-auto-clean")
                //% "This option enables auto cleaning of notes when a number is added to a cell."
                description: qsTrId("id-auto-clean-desc")

                onCheckedChanged: settings.autoCleanupNotes = checked
                Component.onCompleted: checked = settings.autoCleanupNotes
            }
        }
    }
}
