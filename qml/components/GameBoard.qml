import QtQuick 2.0
import Sailfish.Silica 1.0

import "."
import "../."

Item {
    id: gameBoard
    property int cellSize
    property int spacing: 5

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
        anchors.bottom: parent.bottom
        x: 3*cellSize
        width: spacing
        color: BoardStyles.secondaryGridColor
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: 6*cellSize + spacing
        width: spacing
        color: BoardStyles.secondaryGridColor
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        y: 3*cellSize
        height: spacing
        color: BoardStyles.secondaryGridColor
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        y: 6*cellSize + spacing
        height: spacing
        color: BoardStyles.secondaryGridColor
    }
}


