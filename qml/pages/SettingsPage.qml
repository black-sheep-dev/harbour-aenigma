import QtQuick 2.0
import Sailfish.Silica 1.0

import org.nubecula.aenigma 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Settings"
                title: qsTrId("id-settings")
            }

            SectionHeader {
                //% "Support tools"
                text: qsTrId("id-support-tools")
            }

            TextSwitch {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                //% "Highlighting"
                text: qsTrId("id-highlighting")
                //% "This option enables highlighting of rows, columns and boxes already blocked by the selected number."
                description: qsTrId("id-highlighting-desc")

                onCheckedChanged: settings.highlighting = checked

                Component.onCompleted: checked = settings.highlighting
            }
        }
    }
}
