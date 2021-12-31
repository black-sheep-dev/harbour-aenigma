import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.KeepAlive 1.2

import org.nubecula.aenigma 1.0

import "../."
import "../components"

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    function reset() {
        Sudoku.reset()
        Global.selectedNumber = -1
        Global.resetCells()
        Global.refrechCells()
    }

    DisplayBlanking {
        preventBlanking: Sudoku.state === GameState.Playing && settings.preventDisplayBlanking && app.visible
    }

    PageBusyIndicator {
        anchors.centerIn: parent
        running: Sudoku.state === GameState.Generating
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                //% "About"
                text: qsTrId("id-about")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                //% "Settings"
                text: qsTrId("id-settings")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SettingsPage.qml"))
            }

            MenuItem {
                enabled: Sudoku.state >= GameState.Playing
                //% "Reset"
                text: qsTrId("id-reset")
                //% "Reset game"
                onClicked: remorse.execute(qsTrId("id-reset-game"), function() { reset() })
            }
            MenuItem {
                //% "New game"
                text: qsTrId("id-new-game")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/NewGameDialog.qml"), { "difficulty": settings.lastDifficulty })

                    dialog.accepted.connect(function() {
                        reset()
                        Sudoku.difficulty = dialog.difficulty
                        settings.lastDifficulty = dialog.difficulty
                        Sudoku.generate()
                    })
                }
            }
        }

        RemorsePopup { id: remorse }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Sudoku board"
                title: qsTrId("id-sudoku-board")
                description: {
                    switch (Sudoku.state) {
                    case GameState.Empty:
                        return ''

                    case GameState.Generating:
                        //% "Generating"
                        return qsTrId("id-generating") + "..."

                    case GameState.Ready:
                    case GameState.Playing:
                        //% "%n cell(s) unsolved"
                        return qsTrId("id-cells-unsolved", Sudoku.unsolvedCellCount)

                    case GameState.NotCorrect:
                        //% "There are errors"
                        return qsTrId("id-has-errors")

                    case GameState.Solved:
                        //% "Solved"
                        return qsTrId("id-solved")

                    default:
                        return ""
                    }
                }
            }

            GameBoard {
                //visible: Sudoku.state >= GameState.Ready
                id: gameBoard
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: width

                opacity: Sudoku.state > GameState.Playing ? 0.1 : 1.0
                Behavior on opacity { FadeAnimator {} }

                cellSize: (width - 2*spacing) / 9
            }

            Controls {
                visible: Sudoku.state >= GameState.Ready
                id: controlsPanel

                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
            }
        }

//        ViewPlaceholder {
//            enabled: Sudoku.state === GameState.Empty
//            //% "Want to play?"
//            text: qsTrId("id-placeholder-text")
//            //% "Pull down to start a new game"
//            hintText: qsTrId("id-placeholder-hint")
//        }
    }
}
