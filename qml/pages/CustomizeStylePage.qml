import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

import "../."
import "../components"

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    Sudoku {
        id: sudokuPreview
        difficulty: Difficulty.Medium
        autoNotes: true

        Component.onCompleted: {
            sudokuPreview.generate()
            Global.selectedNumber = 1
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: columnContent.height

        Column {
            id: columnContent
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Customize style"
                title: qsTrId("id-customize-style")
            }

            SectionHeader {
                //% "Preview"
                text: qsTrId("id-preview")
            }

            GameBoard {
                enabled: false
                id: gameBoard

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width / 2
                height: width

                cellSize: Math.floor((width - 2*spacing) / 9)

                layer.enabled: true

                sudoku: sudokuPreview
            }

            SectionHeader {
                //% "Background"
                text: qsTrId("id-background")
            }

            ColorSelectorItem {
                //% "Background color"
                title: qsTrId("id-background-color")

                onSelectedColorChanged: BoardStyles.backgroundColor = selectedColor
                Component.onCompleted:  selectedColor = BoardStyles.backgroundColor
            }

            Slider {
                width: parent.width
                minimumValue: 0
                maximumValue: 1
                //% "opacity"
                valueText: Math.floor(value * 100) + "% " + qsTrId("id-opacity")

                onValueChanged: BoardStyles.backgroundOpacity = value
                Component.onCompleted: value = BoardStyles.backgroundOpacity
            }

            SectionHeader {
                //% "Grid"
                text: qsTrId("id-grid")
            }

            ColorSelectorItem {
                //% "Grid color"
                title: qsTrId("id-grid-color")

                onSelectedColorChanged: BoardStyles.gridColor = selectedColor
                Component.onCompleted:  selectedColor = BoardStyles.gridColor
            }

            SectionHeader {
                //% "Highlighting"
                text: qsTrId("id-highlighting")
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    //% "Cell preview"
                    text: qsTrId("id-cell-preview")
                    color: Theme.highlightColor
                }

                CellPreviewItem {
                    anchors.verticalCenter: parent.verticalCenter
                    highlighted: true
                }
            }

            ColorSelectorItem {
                //% "Background color"
                title: qsTrId("id-background-color")

                onSelectedColorChanged: BoardStyles.backgroundHighlightColor = selectedColor

                Component.onCompleted:  selectedColor = BoardStyles.backgroundHighlightColor
            }

            ColorSelectorItem {
                //% "Number color"
                title: qsTrId("id-number-color")

                onSelectedColorChanged: BoardStyles.numberHighlightColor = selectedColor

                Component.onCompleted:  selectedColor = BoardStyles.numberHighlightColor
            }

            Slider {
                width: parent.width
                minimumValue: 0
                maximumValue: 1
                //% "opacity"
                valueText: Math.floor(value * 100) + "% " + qsTrId("id-opacity")

                onValueChanged: BoardStyles.highlightOpacity = value

                Component.onCompleted: value = BoardStyles.highlightOpacity
            }

            SectionHeader {
                //% "Error highlighting"
                text: qsTrId("id-error-highlighting")
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    //% "Cell preview"
                    text: qsTrId("id-cell-preview")
                    color: Theme.highlightColor
                }

                CellPreviewItem {
                    anchors.verticalCenter: parent.verticalCenter
                    error: true
                }
            }

            ColorSelectorItem {
                //% "Background color"
                title: qsTrId("id-background-color")

                onSelectedColorChanged: BoardStyles.errorHighlightColor = selectedColor

                Component.onCompleted:  selectedColor = BoardStyles.errorHighlightColor
            }

            ColorSelectorItem {
                //% "Number color"
                title: qsTrId("id-number-color")

                onSelectedColorChanged: BoardStyles.errorColor = selectedColor

                Component.onCompleted:  selectedColor = BoardStyles.errorColor
            }

            Slider {
                width: parent.width
                minimumValue: 0
                maximumValue: 1
                //% "opacity"
                valueText: Math.floor(value * 100) + "% " + qsTrId("id-opacity")

                onValueChanged: BoardStyles.errorHighlightOpacity = value

                Component.onCompleted: value = BoardStyles.errorHighlightOpacity
            }

            SectionHeader {
                //% "Inserted number"
                text: qsTrId("id-inserted-number")
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    //% "Cell preview"
                    text: qsTrId("id-cell-preview")
                    color: Theme.highlightColor
                }

                CellPreviewItem { anchors.verticalCenter: parent.verticalCenter }
            }

            ColorSelectorItem {
                //% "Number color"
                title: qsTrId("id-number-color")

                onSelectedColorChanged: BoardStyles.numberColor = selectedColor

                Component.onCompleted:  selectedColor = BoardStyles.numberColor
            }

            SectionHeader {
                //% "Fixed number"
                text: qsTrId("id-fixed-number")
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    //% "Cell preview"
                    text: qsTrId("id-cell-preview")
                    color: Theme.highlightColor
                }

                CellPreviewItem {
                    anchors.verticalCenter: parent.verticalCenter
                    fixed: true
                }
            }

            ColorSelectorItem {
                //% "Number color"
                title: qsTrId("id-number-color")

                onSelectedColorChanged: BoardStyles.numberFixedColor = selectedColor

                Component.onCompleted:  selectedColor = BoardStyles.numberFixedColor
            }

            SectionHeader {
                //% "Notes"
                text: qsTrId("id-notes")
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    //% "Cell preview"
                    text: qsTrId("id-cell-preview")
                    color: Theme.highlightColor
                }

                CellPreviewItem {
                    anchors.verticalCenter: parent.verticalCenter
                    showNotes: true
                }
            }

            ColorSelectorItem {
                //% "Number color"
                title: qsTrId("id-number-color")

                onSelectedColorChanged: BoardStyles.notesColor = selectedColor

                Component.onCompleted:  selectedColor = BoardStyles.notesColor
            }

            Item {
                width: 1
                height: Theme.paddingMedium
            }
        }
    }

    onStatusChanged: {
        if (status !== PageStatus.Deactivating) return

        settings.customStyle = JSON.stringify({
                                                  backgroundColor: BoardStyles.backgroundColor,
                                                  backgroundHighlightColor: BoardStyles.backgroundHighlightColor,
                                                  backgroundOpacity: BoardStyles.backgroundOpacity,
                                                  errorColor: BoardStyles.errorColor,
                                                  errorHighlightColor: BoardStyles.errorHighlightColor,
                                                  errorHighlightOpacity: BoardStyles.errorHighlightOpacity,
                                                  gridColor: BoardStyles.gridColor,
                                                  highlightOpacity: BoardStyles.highlightOpacity,
                                                  notesColor: BoardStyles.notesColor,
                                                  numberColor: BoardStyles.numberColor,
                                                  numberFixedColor: BoardStyles.numberFixedColor,
                                                  numberHighlightColor: BoardStyles.numberHighlightColor
                                              })
    }
}
