 import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

import "../."

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        PullDownMenu {
            MenuItem {
                //% "Reset settings"
                text: qsTrId("id-reset-settings")
                //% "Resetting settings"
                onClicked: remorse.execute(qsTrId("id-resetting-settings"), function () {
                    settings.reset()
                    pageStack.navigateBack()
                })
            }
        }

        RemorsePopup { id: remorse }

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
                //% "Board style"
                text: qsTrId("id-board-style")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: Text.Wrap
                color: Theme.highlightColor

                //% "Choose a style for you sudoku board."
                text: qsTrId("id-styles-desc")
            }

            ComboBox {
                id: styleSelection
                //% "Style"
                label: qsTrId("id-style")

                menu: ContextMenu {
                    MenuItem {
                        //% "Default"
                        text: qsTrId("id-default")
                    }
                    MenuItem {
                        //% "Black & White"
                        text: qsTrId("id-style-black-and-white")
                    }
                    MenuItem {
                        //% "Paper"
                        text: qsTrId("id-style-paper")
                    }
                    MenuItem {
                        //% "Dark Shadow"
                        text: qsTrId("id-style-dark-shadow")
                    }
                    MenuItem {
                        //% "Custom"
                        text: qsTrId("id-custom")
                    }
                }

                onCurrentIndexChanged: settings.style = currentIndex
                Component.onCompleted: currentIndex = settings.style
            }

            Button {
                visible: styleSelection.currentIndex === Styles.Custom
                anchors.horizontalCenter: parent.horizontalCenter
                //% "Customize"
                text: qsTrId("id-customize")

                onClicked: pageStack.push(Qt.resolvedUrl("CustomizeStylePage.qml"))
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
