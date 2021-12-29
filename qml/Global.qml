pragma Singleton
import QtQuick 2.0

import org.nubecula.aenigma 1.0

QtObject {
    property int selectedNumber: -1
    property int mode: EditMode.Add
    property bool showErrors: false

    signal refrechCells()
}
