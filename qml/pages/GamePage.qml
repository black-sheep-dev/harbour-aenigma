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
        settings.gameStateData = ""
        sudokuGame.reset()
        Global.selectedNumber = -1
        Global.resetCells()
        Global.refrechCells()
    }

    DisplayBlanking {
        preventBlanking: sudokuGame.gameState === GameState.Playing && settings.preventDisplayBlanking && app.visible
    }

    PageBusyIndicator {
        anchors.centerIn: parent
        running: sudokuGame.gameState === GameState.Generating
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
                //% "Statistics"
                text: qsTrId("id-statistics")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("StatisticsPage.qml"))
            }
            MenuItem {
                //% "New game"
                text: qsTrId("id-new-game")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/NewGameDialog.qml"), { "difficulty": settings.lastDifficulty })

                    dialog.accepted.connect(function() {
                        reset()
                        sudokuGame.difficulty = dialog.difficulty
                        settings.lastDifficulty = dialog.difficulty
                        sudokuGame.generate()
                    })
                }
            }
        }

        PushUpMenu {
            visible: sudokuGame.gameState >= GameState.Playing
            MenuItem {
                //% "Reset"
                text: qsTrId("id-reset")
                //% "Reset game"
                onClicked: remorse.execute(qsTrId("id-reset-game"), function() { reset() })
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
                    switch (sudokuGame.gameState) {
                    case GameState.Empty:
                        return ''

                    case GameState.Generating:
                        //% "Generating"
                        return qsTrId("id-generating") + "..."

                    case GameState.Ready:
                    case GameState.Pause:
                    case GameState.Playing:
                        //% "%n cell(s) unsolved"
                        return qsTrId("id-cells-unsolved", sudokuGame.unsolvedCellCount)

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

                Label {
                    visible: sudokuGame.gameState >= GameState.Playing
                    anchors{
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        bottom: parent.bottom
                        bottomMargin: Theme.paddingMedium
                    }
                    color: Theme.highlightColor
                    text: new Date(sudokuGame.elapsedTime * 1000).toISOString().substr(11, 8);
                }
            }

            Item {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: width

                GameBoard {
                    visible: sudokuGame.gameState >= GameState.Ready
                    id: gameBoard
                    anchors.fill: parent


                    opacity: sudokuGame.gameState === GameState.Solved ? 0.1 : 1.0
                    Behavior on opacity { FadeAnimator {} }

                    cellSize: Math.floor((width - 2*spacing) / 9)

                    layer.enabled: true

                    sudoku: sudokuGame
                }

                ResultBoard {
                    visible: sudokuGame.gameState === GameState.Solved
                    anchors.fill: parent

                    elapsedTime: sudokuGame.elapsedTime
                    hints: sudokuGame.hintsCount
                    steps: sudokuGame.stepsCount
                    difficulty: sudokuGame.difficulty
                }
            }

            Controls {
                visible: sudokuGame.gameState >= GameState.Ready
                id: controlsPanel

                x: Theme.horizontalPageMargin
                width: parent.width - 2*x

                sudoku: sudokuGame
            }
        }

        ViewPlaceholder {
            enabled: sudokuGame.gameState === GameState.Empty
            //% "Want to play?"
            text: qsTrId("id-placeholder-text")
            //% "Pull down to start a new game"
            hintText: qsTrId("id-placeholder-hint")
        }
    }

    Connections {
        target: sudokuGame
        onGameStateChanged: if (sudokuGame.gameState === GameState.Solved) DB.addGame(sudokuGame.difficulty, sudokuGame.stepsCount, sudokuGame.hintsCount, sudokuGame.elapsedTime)
    }

    onVisibleChanged: {
        if (visible && sudokuGame.gameState === GameState.Pause) {
            sudokuGame.start()
        } else if (!visible && sudokuGame.gameState === GameState.Playing){
            sudokuGame.stop()
        }
    }

    Component.onCompleted: if (settings.gameStateData.length > 0) sudokuGame.fromBase64(settings.gameStateData)

    Component.onDestruction: {
        if ( sudokuGame.gameState === GameState.Ready
                || sudokuGame.gameState === GameState.Playing
                || sudokuGame.gameState === GameState.Pause
                || sudokuGame.gameState === GameState.NotCorrect ) {

            settings.gameStateData = sudokuGame.toBase64()
        } else {
            settings.gameStateData = ""
        }
    }
}
