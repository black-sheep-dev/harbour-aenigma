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

    DetailItem {
        //% "Games"
        label: qsTrId("id-games")
        value: games
    }

    DetailItem {
        //% "Average time"
        label: qsTrId("id-average-time")
        value: Global.getTimeString(timeAvg)
    }

    DetailItem {
        //% "Minimum time"
        label: qsTrId("id-minimum-time")
        value: Global.getTimeString(timeMin)
    }

    DetailItem {
        //% "Average steps"
        label: qsTrId("id-average-steps")
        value: stepsAvg
    }

    DetailItem {
        //% "Minimum steps"
        label: qsTrId("id-minimum-steps")
        value: stepsMin
    }

    DetailItem {
        //% "Average hints"
        label: qsTrId("id-average-hints")
        value: hintsAvg
    }

    DetailItem {
        //% "Minimum hints"
        label: qsTrId("id-minimum-hints")
        value: stepsMin
    }
}
