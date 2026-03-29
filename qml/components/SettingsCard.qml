import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: root
    property string title: ""
    default property alias content: container.data

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + 40
    radius: 16
    color: Material.dialogColor
    border.color: Material.dividerColor

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        width: parent.width - 40
        spacing: 12

        Label {
            text: root.title
            font.weight: Font.Medium
            font.pixelSize: 18
            Layout.bottomMargin: 8
            visible: text !== ""
        }

        ColumnLayout {
            id: container
            Layout.fillWidth: true
            spacing: 16
        }
    }
}
