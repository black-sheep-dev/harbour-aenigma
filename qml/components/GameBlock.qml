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

    border.color: Theme.secondaryColor
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

                    if (!settings.highlighting) {
                        highlighted = false
                        return
                    }

                    // highligt cells
                    if (isCurrentNumber()) {
                        highlighted = true
                    }

                    if ( Sudoku.isInArea(row, column, Global.selectedNumber)) {
                        highlighted = true
                        return
                    }

                    highlighted = false
                }

                function resetCell() {
                    noteBlock.notes = Note.None
                }

                width: cellSize
                height: cellSize
                border.color: Theme.primaryColor
                border.width: 1
                color: "transparent"

                NoteBlock { id: noteBlock }

                Rectangle {
                    visible: highlighted || hasError
                    anchors.fill: parent
                    color: hasError ? Theme.errorColor : Theme.highlightBackgroundColor
                    opacity: 0.1
                }

                Text {
                    id: valueLabel

                    function setValue(value) {
                        text = value === 0 ? '' : value
                    }

                    anchors.centerIn: parent
                    color: {
                        if (hasError) return Theme.errorColor
                        if (highlighted && isCurrentNumber()) return Theme.highlightColor
                        return isEditable ? Theme.secondaryHighlightColor : Theme.primaryColor
                    }
                    font.pointSize: Math.max(Math.round(cellSize * 0.5), 1)
                }

                Connections {
                    target: settings

                    onHighlightingChanged: refreshCell()
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

                        if (Global.mode === EditMode.Add) {
                            if (Global.selectedNumber < 0) return
                            var value = 0
                            if (isCurrentNumber()) {
                                Sudoku.setData(row, column, CellData.Value, value)
                            } else {
                                Sudoku.setData(row, column, CellData.Value, Global.selectedNumber)
                                value = Global.selectedNumber
                            }
                            Sudoku.setData(row, column, CellData.Notes, Note.None)
                            Global.refrechCells()
                        } else if (Global.mode === EditMode.Delete) {
                            Sudoku.setData(row, column, CellData.Value, 0)
                            Sudoku.setData(row, column, CellData.Notes, Note.None)
                            Global.refrechCells()
                        } else if (Global.mode === EditMode.Note) {
                            if (Sudoku.data(row, column, CellData.Value) !== 0) return
                            Sudoku.toogleNote(row, column, Sudoku.numberToNote(Global.selectedNumber))
                        } else if (Global.mode === EditMode.Hint) {
                            const value = Sudoku.data(row, column, CellData.Solution)
                            Sudoku.setData(row, column, CellData.Value, value == valueLabel.text ? 0 : value)
                            Global.refrechCells()
                        }
                    }
                }
            }
        }
    }
}
