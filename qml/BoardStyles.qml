pragma Singleton
import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

QtObject {
    property string backgroundColor: "transparent"
    property string backgroundHighlightColor: Theme.highlightBackgroundColor
    property real backgroundOpacity: 1.0
    property string errorColor: Theme.errorColor
    property string errorHighlightColor: Theme.errorColor
    property real errorHighlightOpacity: 0.2
    property string gridColor: Theme.primaryColor
    property real highlightOpacity: 0.2
    property string notesColor: Theme.secondaryHighlightColor
    property string numberColor: Theme.primaryColor
    property string numberFixedColor: Theme.secondaryHighlightColor
    property string numberHighlightColor: Theme.highlightColor

    function setStyle(style) {
        switch (style) {
        case Styles.BlackAndWhite:
            backgroundColor = "white"
            backgroundHighlightColor = "black"
            backgroundOpacity= 1.0
            errorColor = Theme.errorColor
            errorHighlightColor = Theme.errorColor
            errorHighlightOpacity = 0.1
            gridColor = "black"
            highlightOpacity = 0.1
            notesColor = "black"
            numberColor = "black"
            numberFixedColor = Theme.secondaryHighlightColor
            numberHighlightColor = "grey"
            break

        case Styles.Paper:
            backgroundColor = "#F6F2E7"
            backgroundOpacity= 1.0
            backgroundHighlightColor = Theme.highlightBackgroundColor
            errorColor = Theme.errorColor
            errorHighlightColor = Theme.errorColor
            errorHighlightOpacity = 0.1
            gridColor = "#867F69"
            highlightOpacity = 0.1
            notesColor = "#5A5446"
            numberColor = "#706A58"
            numberFixedColor = "#433F35"
            numberHighlightColor = Theme.highlightBackgroundColor
            break

        case Styles.DarkShadow:
            backgroundColor = Theme.overlayBackgroundColor
            backgroundHighlightColor = Theme.highlightBackgroundColor
            backgroundOpacity= Theme.opacityLow
            errorColor = Theme.errorColor
            errorHighlightColor = Theme.errorColor
            errorHighlightOpacity = 0.3
            gridColor = Theme.primaryColor
            highlightOpacity = 0.3
            notesColor = Theme.secondaryHighlightColor
            numberColor = Theme.primaryColor
            numberFixedColor = Theme.secondaryHighlightColor
            numberHighlightColor = Theme.highlightColor
            break

        default:
            backgroundColor = "transparent"
            backgroundHighlightColor = Theme.highlightBackgroundColor
            backgroundOpacity= 1.0
            errorColor = Theme.errorColor
            errorHighlightColor = Theme.errorColor
            errorHighlightOpacity = 0.2
            gridColor = Theme.primaryColor
            highlightOpacity = 0.2
            notesColor = Theme.secondaryHighlightColor
            numberColor = Theme.primaryColor
            numberFixedColor = Theme.secondaryHighlightColor
            numberHighlightColor = Theme.highlightColor
            break
        }
    }
}
