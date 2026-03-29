import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: root

    property bool active: false
    property string message: "Processing..."

    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.4)
    visible: active
    opacity: active ? 1.0 : 0.0
    z: 2000

    MouseArea {
        anchors.fill: parent
        enabled: root.active
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 15

        BusyIndicator {
            id: progressCircle
            running: root.active
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: root.message
            color: "white"
            font.pixelSize: 16
            font.weight: Font.Medium
            Layout.alignment: Qt.AlignHCenter
        }
    }

}
