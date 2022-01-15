import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

import "."
import "../."

Rectangle {    
    property int cellSize
    property int blockNumber

    width: cellSize * 3
    height: cellSize * 3

    color: "transparent"

    border.color: BoardStyles.gridColor
    border.width: 2

    Rectangle {
        anchors.fill: parent
        color: BoardStyles.backgroundColor
        opacity: BoardStyles.backgroundOpacity
    }

    Grid {
        rows: 3
        columns: 3
        spacing: 0

        Repeater {
            model: 9

            Rectangle {
                id: cell
                property int row:    Math.floor(blockNumber / 3) * 3 + Math.floor(index / 3)
                property int column: (blockNumber % 3) * 3 + (index % 3)
                property bool isEditable: false
                property bool highlighted: false
                property bool hasError: false

                function getUndoId() {
                    var undoId = sudoku.currentUndoId + 1
                    sudoku.currentUndoId = undoId
                    return undoId
                }

                function isCurrentNumber() {
                    return Global.selectedNumber == valueLabel.text
                }

                function refreshCell() {
                    // highlight error cells
                    if (Global.showErrors || sudoku.gameState === GameState.NotCorrect) {
                        hasError = sudoku.data(row, column, CellData.HasError)
                    } else {
                        hasError = false
                    }

                    if (settings.highlightMode === HighlightMode.None) {
                        highlighted = false
                        return
                    }

                    // highligt cells
                    if (isCurrentNumber()) {
                        highlighted = true
                    } else if (settings.highlightMode !== HighlightMode.Complete) {
                        highlighted = false
                        return;
                    }

                    if (sudoku.isInArea(row, column, Global.selectedNumber)) {
                        highlighted = true
                        return
                    }

                    highlighted = false
                }

                function resetCell() {
                    noteBlock.notes = sudoku.data(row, column, CellData.Notes)
                }

                width: cellSize
                height: cellSize
                border.color: BoardStyles.gridColor
                border.width: 1
                color: "transparent"

                NoteBlock { id: noteBlock }

                Rectangle {
                    visible: highlighted || hasError
                    anchors.fill: parent
                    color: hasError ? BoardStyles.errorColor : BoardStyles.backgroundHighlightColor
                    opacity: hasError ? BoardStyles.errorHighlightColor : BoardStyles.highlightOpacity
                }

                Text {
                    id: valueLabel

                    function setValue(value) {
                        text = value === 0 ? '' : value
                    }

                    anchors.centerIn: parent
                    color: {
                        if (hasError) return BoardStyles.errorColor
                        if (highlighted && isCurrentNumber()) return BoardStyles.numberHighlightColor
                        return isEditable ? BoardStyles.numberColor : BoardStyles.numberFixedColor
                    }
                    font.pointSize: Math.max(cellSize * 0.5, 1)
                    font.bold: true
                }

                Connections {
                    target: settings

                    onHighlightModeChanged: refreshCell()
                }

                Connections {
                    target: Global
                    onRefrechCells: refreshCell()
                    onResetCells: resetCell()
                    onSelectedNumberChanged: refreshCell()
                    onShowErrorsChanged: refreshCell()
                }

                Connections {
                    target: sudoku
                    onDataChanged: {
                        if (row !== cell.row || column !== cell.column) return;

                        switch (role) {
                        case CellData.Notes:
                            noteBlock.notes = data
                            break

                        case CellData.Value:
                            valueLabel.setValue(data)
                            break

                        default:
                            break

                        }

                        Global.refrechCells()
                    }
                    onGameStateChanged: {
                        if (sudoku.gameState === GameState.Ready || sudoku.gameState === GameState.Playing) {
                            const value = sudoku.data(row, column, CellData.Value)
                            valueLabel.setValue(value)
                            noteBlock.notes = sudoku.data(row, column, CellData.Notes)
                            isEditable = sudoku.data(row, column, CellData.IsEditable)
                        }

                        refreshCell()
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (!isEditable && Global.mode !== EditMode.Hint) return;

                        sudoku.incrementStepsCount()

                        if (Global.mode === EditMode.Add) {
                            if (Global.selectedNumber < 0) return

                            const undoId = getUndoId()

                            var value = 0
                            if (isCurrentNumber()) {
                                sudoku.setData(row, column, CellData.Value, value, false, undoId)
                            } else {
                                sudoku.setData(row, column, CellData.Value, Global.selectedNumber, false, undoId)
                                value = Global.selectedNumber
                            }    
                            sudoku.setData(row, column, CellData.Notes, Note.None, false, undoId)
                        } else if (Global.mode === EditMode.Delete) {
                            const undoId = getUndoId()
                            sudoku.setData(row, column, CellData.Value, 0, false, undoId)
                            sudoku.setData(row, column, CellData.Notes, Note.None, false, undoId)
                        } else if (Global.mode === EditMode.Note) {
                            if (sudoku.data(row, column, CellData.Value) !== 0) return
                            sudoku.toogleNote(row, column, sudoku.numberToNote(Global.selectedNumber))
                        } else if (Global.mode === EditMode.Hint) {
                            const value = sudoku.data(row, column, CellData.Solution)
                            const undoId = getUndoId()
                            sudoku.setData(row, column, CellData.Value, value == valueLabel.text ? 0 : value, false, undoId)
                            sudoku.setData(row, column, CellData.Notes, Note.None, false, undoId)
                            sudoku.incrementHintsCount()
                        }
                        refreshCell()
                    }
                }
            }
        }
    }
}
