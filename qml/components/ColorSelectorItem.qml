import QtQuick 2.0
import Sailfish.Silica 1.0

import "../dialogs"

BackgroundItem {
    property color selectedColor
    property alias title: label.text

    width: parent.width

    Label {
        id: label
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: colorCircle.left
            rightMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        wrapMode: Text.Wrap
        color: parent.selected ? Theme.secondaryHighlightColor : Theme.primaryColor

    }
    Rectangle {
        id: colorCircle
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }

        width: Theme.itemSizeSmall / 2
        height: width
        radius: width / 2
        color: selectedColor
    }

    onClicked: {
        var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/ColorSelectionDialog.qml"))
        dialog.selectedColor = selectedColor

        dialog.accepted.connect(function() { selectedColor = dialog.selectedColor })
    }
}
