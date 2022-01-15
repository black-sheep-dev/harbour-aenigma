import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Dialog {
    property color selectedColor

    allowedOrientations: Orientation.Portrait

    canAccept: colorInput.acceptableInput

    Column {
        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            //% "Choose color"
            title: qsTrId("id-choose-color")
        }

        Row {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            spacing: Theme.paddingMedium

            Label {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.highlightColor
                //% "Color"
                text: qsTrId("id-color")
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall
                radius: width / 2

                color: selectedColor
            }
        }

        TextField {
            id: colorInput
            width: parent.width

            validator: RegExpValidator {
                regExp: /^#([A-Fa-f0-9]{6})$/
            }

            text: selectedColor

            EnterKey.onClicked: if (acceptableInput) selectedColor = text
        }

        ColorWheel {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            height: width

            onRgbChanged: selectedColor = rgb
        }
    }

    onAccepted: {
        if (colorInput.text === selectedColor) return

        selectedColor = colorInput.text
    }
}
