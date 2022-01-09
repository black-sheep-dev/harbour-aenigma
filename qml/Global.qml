pragma Singleton
import QtQuick 2.0

import org.nubecula.aenigma 1.0

QtObject {
    property int selectedNumber: -1
    property int mode: EditMode.Add
    property bool showErrors: false

    signal refrechCells()
    signal resetCells()

    function getTimeString(value) {
        const secs = Number(value);

        if (secs === 0) return 0

        var d = Math.floor(secs / (3600*24));
        var h = Math.floor(secs % (3600*24) / 3600);
        var m = Math.floor(secs % 3600 / 60);
        var s = Math.floor(secs % 60);

        var dDisplay = d > 0 ? d + " d " : "";
        var hDisplay = h > 0 ? h + " h " : "";
        var mDisplay = m > 0 ? m + " m " : "";
        var sDisplay = s > 0 ? s + " s" : "";

        return dDisplay + hDisplay + mDisplay + sDisplay;
    }
}
