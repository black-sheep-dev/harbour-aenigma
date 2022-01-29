import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property alias description: descriptionText.text

    Column {
        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            //% "Add bookmark"
            title: qsTrId("id-add-bookmark")

            //% "Add"
            acceptText: qsTrId("id-add")
        }

        TextArea {
            id: descriptionText
            width: parent.width
            //% "Enter description"
            placeholderText: qsTrId("id-enter-description")
            focus: true
        }
    }
}
