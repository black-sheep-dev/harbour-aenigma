import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property int elapsedTime
    property int hints
    property int steps

    width: parent.width
    height: width

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: Theme.paddingLarge

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor

            //% "Puzzle solved!"
            text: qsTrId("id-puzzle-solved")
        }

        DetailItem {
            //% "Steps required"
            label: qsTrId("id-steps-required")
            value: steps
        }

        DetailItem {
            //% "Time required"
            label: qsTrId("id-time-required")
            value: new Date(elapsedTime * 1000).toISOString().substr(11, 8);
        }

        DetailItem {
            //% "Hints used"
            label: qsTrId("id-hints-used")
            value: hints
        }
    }
}
