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
    color: BoardStyles.backgroundColor

    border.color: BoardStyles.secondaryGridColor
    border.width: 2

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
                    var undoId = Sudoku.currentUndoId + 1
                    Sudoku.currentUndoId = undoId
                    return undoId
                }

                function isCurrentNumber() {
                    return Global.selectedNumber == valueLabel.text
                }

                function refreshCell() {
                    // highlight error cells
                    if (Global.showErrors) {
                        hasError = Sudoku.data(row, column, CellData.HasError)
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

                    if (Sudoku.isInArea(row, column, Global.selectedNumber)) {
                        highlighted = true
                        return
                    }

                    highlighted = false
                }

                function resetCell() {
                    noteBlock.notes = Sudoku.data(row, column, CellData.Notes)
                }

                width: cellSize
                height: cellSize
                border.color: BoardStyles.primaryGridColor
                border.width: 1
                color: "transparent"

                NoteBlock { id: noteBlock }

                Rectangle {
                    visible: highlighted || hasError
                    anchors.fill: parent
                    color: hasError ? BoardStyles.errorColor : BoardStyles.cellHighlightColor
                    opacity: 0.1
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
                        return isEditable ? BoardStyles.numberFixedColor : BoardStyles.numberColor
                    }
                    font.pointSize: Math.max(Math.round(cellSize * 0.5), 1)
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
                    target: Sudoku
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
                    onStateChanged: {
                        const value = Sudoku.data(row, column, CellData.Value)
                        valueLabel.setValue(value)
                        noteBlock.notes = Sudoku.data(row, column, CellData.Notes)
                        isEditable = Sudoku.data(row, column, CellData.IsEditable)
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (!isEditable && Global.mode !== EditMode.Hint) return;

                        Sudoku.incrementStepsCount()

                        if (Global.mode === EditMode.Add) {
                            if (Global.selectedNumber < 0) return

                            const undoId = getUndoId()

                            var value = 0
                            if (isCurrentNumber()) {
                                Sudoku.setData(row, column, CellData.Value, value, false, undoId)
                            } else {
                                Sudoku.setData(row, column, CellData.Value, Global.selectedNumber, false, undoId)
                                value = Global.selectedNumber
                            }    
                            Sudoku.setData(row, column, CellData.Notes, Note.None, false, undoId)
                            Global.refrechCells()
                        } else if (Global.mode === EditMode.Delete) {
                            const undoId = getUndoId()
                            Sudoku.setData(row, column, CellData.Value, 0, false, undoId)
                            Sudoku.setData(row, column, CellData.Notes, Note.None, false, undoId)
                            Global.refrechCells()
                        } else if (Global.mode === EditMode.Note) {
                            if (Sudoku.data(row, column, CellData.Value) !== 0) return
                            Sudoku.toogleNote(row, column, Sudoku.numberToNote(Global.selectedNumber))
                        } else if (Global.mode === EditMode.Hint) {
                            const value = Sudoku.data(row, column, CellData.Solution)
                            const undoId = getUndoId()
                            Sudoku.setData(row, column, CellData.Value, value == valueLabel.text ? 0 : value, false, undoId)
                            Sudoku.setData(row, column, CellData.Notes, Note.None, false, undoId)
                            Global.refrechCells()
                        }
                    }
                }
            }
        }
    }
}
