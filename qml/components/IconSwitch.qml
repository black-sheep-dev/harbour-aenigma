import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property bool checkable: true
    property bool checked: false
    property string highlichtColor: Theme.highlightColor
    property string source

    width: Theme.itemSizeSmall
    height: Theme.itemSizeSmall

    Icon {
        id: switchIcon
        anchors.centerIn: parent
        source: parent.source + (checkable ? "?" + (checked ? highlichtColor : Theme.primaryColor) : "")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: checked = !checked
    }
}
