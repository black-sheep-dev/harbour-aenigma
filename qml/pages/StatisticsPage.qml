import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.KeepAlive 1.2

import org.nubecula.aenigma 1.0

import "../."
import "../components/"

Page {
    property var stats

    id: page

    allowedOrientations: Orientation.Portrait

    function refreshStats() { stats = DB.getStatisticOverview() }


    SilicaFlickable {
        visible: stats !== undefined
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                //% "Reset"
                text: qsTrId("id-reset")
                //% "Reset statistics"
                onClicked: remorse.execute(qsTrId("id-reset-statistics"), function() { DB.reset() })
            }
            MenuItem {
                //% "Refresh"
                text: qsTrId("id-refresh")
                onClicked: refreshStats()
            }
        }

        RemorsePopup { id: remorse }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Statistics"
                title: qsTrId("id-statistics")
            }

            SectionHeader {
                //% "Games played"
                text: qsTrId("id-games-played")
            }

            DetailItem {
                //% "Total"
                label: qsTrId("id-total")
                value: stats.total_count
            }

            DetailItem {
                //% "Total time"
                label: qsTrId("id-total-time")
                value: Global.getTimeString(stats.total_time)
            }

            SectionHeader {
                //% "Easy"
                text: qsTrId("id-easy")
            }

            StatisticDetails {
                games: stats.easy.games
                hintsAvg: stats.easy.avg_hints
                hintsMin: stats.easy.min_hints
                stepsAvg: stats.easy.avg_steps
                stepsMin: stats.easy.min_steps
                timeAvg: stats.easy.avg_time
                timeMin: stats.easy.min_time
            }

            SectionHeader {
                //% "Medium"
                text: qsTrId("id-medium")
            }

            StatisticDetails {
                games: stats.medium.games
                hintsAvg: stats.medium.avg_hints
                hintsMin: stats.medium.min_hints
                stepsAvg: stats.medium.avg_steps
                stepsMin: stats.medium.min_steps
                timeAvg: stats.medium.avg_time
                timeMin: stats.medium.min_time
            }

            SectionHeader {
                //% "Hard"
                text: qsTrId("id-hard")
            }

            StatisticDetails {
                games: stats.hard.games
                hintsAvg: stats.hard.avg_hints
                hintsMin: stats.hard.min_hints
                stepsAvg: stats.hard.avg_steps
                stepsMin: stats.hard.min_steps
                timeAvg: stats.hard.avg_time
                timeMin: stats.hard.min_time
            }

            SectionHeader {
                //% "Insane"
                text: qsTrId("id-insane")
            }

            StatisticDetails {
                games: stats.insane.games
                hintsAvg: stats.insane.avg_hints
                hintsMin: stats.insane.min_hints
                stepsAvg: stats.insane.avg_steps
                stepsMin: stats.insane.min_steps
                timeAvg: stats.insane.avg_time
                timeMin: stats.insane.min_time
            }

            Item {
                width: 1
                height: Theme.paddingSmall
            }
        } 
    }

    ViewPlaceholder {
        enabled: stats === undefined
        //% "No statistic data available"
        text: qsTrId("id-no-stat-data")
        //% "Play some games and come back"
        hintText: qsTrId("id-no-stat-data-hint")
    }

    onStatusChanged: if (status === PageStatus.Active) refreshStats()
}
