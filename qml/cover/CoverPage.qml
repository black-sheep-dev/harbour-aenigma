import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: headerLabel
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Theme.paddingLarge
        }
        horizontalAlignment: Text.AlignHCenter
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        text: "AENIGMA"
    }

    Image {
        anchors.centerIn: parent
        width: parent.width
        height: sourceSize.height * width / sourceSize.width
        smooth: true
        source: "/usr/share/harbour-aenigma/images/cover-background.svg"
        opacity: 0.1
    }
}
