import QtQuick 2.0
import Sailfish.Silica 1.0

import "../."

Column {
    property int games: 0
    property int hintsAvg: 0
    property int hintsMin: 0
    property int stepsAvg: 0
    property int stepsMin: 0
    property int timeAvg: 0
    property int timeMin: 0

    width: parent.width

    Label {
        visible: games === 0
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x

        wrapMode: Text.Wrap
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignHCenter

        //% "No data available"
        text: qsTrId("id-no-data-available")
    }

    DetailItem {
        visible: games > 0
        //% "Games"
        label: qsTrId("id-games")
        value: games
    }

    DetailItem {
        visible: games > 0
        //% "Average time"
        label: qsTrId("id-average-time")
        value: Global.getTimeString(timeAvg)
    }

    DetailItem {
        visible: games > 0
        //% "Minimum time"
        label: qsTrId("id-minimum-time")
        value: Global.getTimeString(timeMin)
    }

    DetailItem {
        visible: games > 0
        //% "Average steps"
        label: qsTrId("id-average-steps")
        value: stepsAvg
    }

    DetailItem {
        visible: games > 0
        //% "Minimum steps"
        label: qsTrId("id-minimum-steps")
        value: stepsMin
    }

    DetailItem {
        visible: games > 0
        //% "Average hints"
        label: qsTrId("id-average-hints")
        value: hintsAvg
    }

    DetailItem {
        visible: games > 0
        //% "Minimum hints"
        label: qsTrId("id-minimum-hints")
        value: hintsMin
    }
}
