pragma Singleton
import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

QtObject {
    property color backgroundColor: "transparent"
    property color cellHighlightColor: Theme.highlightBackgroundColor
    property color errorColor: Theme.errorColor
    property color errorHighlightColor: Theme.errorColor
    property color notesColor: Theme.secondaryHighlightColor
    property color numberColor: Theme.primaryColor
    property color numberFixedColor: Theme.secondaryHighlightColor
    property color numberHighlightColor: Theme.highlightColor
    property color primaryGridColor: Theme.primaryColor
    property color secondaryGridColor: Theme.secondaryColor

    function setStyle(style) {
        switch (style) {
        case Styles.BlackAndWhite:
            backgroundColor = "white"
            cellHighlightColor = "black"
            errorColor = Theme.errorColor
            errorHighlightColor = Theme.errorColor
            primaryGridColor = "black"
            notesColor = "black"
            numberColor = "black"
            numberFixedColor = Theme.secondaryHighlightColor
            numberHighlightColor = "grey"
            secondaryGridColor = "black"
            break

        case Styles.Paper:
            backgroundColor = "#F6F2E7"
            cellHighlightColor = Theme.highlightBackgroundColor
            errorColor = Theme.errorColor
            errorHighlightColor = Theme.errorColor
            notesColor = "#5A5446"
            numberColor = "#706A58"
            numberFixedColor = "#433F35"
            numberHighlightColor = "#8A8885"
            primaryGridColor = "#867F69"
            secondaryGridColor = "#867F69"
            break

        default:
            backgroundColor = "transparent"
            cellHighlightColor = Theme.highlightBackgroundColor
            errorColor = Theme.errorColor
            errorHighlightColor = Theme.errorColor
            notesColor = Theme.secondaryHighlightColor
            numberColor = Theme.primaryColor
            numberFixedColor = Theme.secondaryHighlightColor
            numberHighlightColor = Theme.highlightColor
            primaryGridColor = Theme.primaryColor
            secondaryGridColor = Theme.secondaryColor
            break
        }
    }
}
