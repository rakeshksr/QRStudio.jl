import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import "components"

MenuBar {
    id: root

    AboutDialog { id: aboutDialog }

    Menu {
        title: qsTr("&File")
        Action {
            text: qsTr("&Exit")
            onTriggered: Qt.quit()
        }
    }

    Menu {
        title: qsTr("&Help")
        Action {
            text: qsTr("&About")
            onTriggered: aboutDialog.open()
        }
    }
}
