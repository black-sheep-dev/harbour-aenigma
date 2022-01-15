import QtQuick 2.0
import Sailfish.Silica 1.0

import "."
import "../."

Item {
    id: gameBoard
    property int cellSize
    property int spacing: 5
    property var sudoku

    Grid {
        rows: 3
        columns: 3
        spacing: gameBoard.spacing

        anchors.fill: parent

        Repeater {
            model: 9

            GameBlock {
                cellSize: gameBoard.cellSize
                blockNumber: index
            }
        }
    } 

    Rectangle {
        anchors.top: parent.top
        x: 3*cellSize
        width: spacing
        height: 9*cellSize + 2*spacing
        color: BoardStyles.gridColor
    }

    Rectangle {
        anchors.top: parent.top
        x: 6*cellSize + spacing
        width: spacing
        height: 9*cellSize + 2*spacing
        color: BoardStyles.gridColor
    }

    Rectangle {
        anchors.left: parent.left
        y: 3*cellSize
        height: spacing
        width: 9*cellSize + 2*spacing
        color: BoardStyles.gridColor
    }

    Rectangle {
        anchors.left: parent.left
        y: 6*cellSize + spacing
        height: spacing
        width: 9*cellSize + 2*spacing
        color: BoardStyles.gridColor
    }
}


