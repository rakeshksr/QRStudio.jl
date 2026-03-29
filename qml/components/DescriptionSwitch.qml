import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Switch {
    id: sw
    property string description: ""

    topPadding: 12
    bottomPadding: 12
    leftPadding: 0

    contentItem: RowLayout {
        spacing: 0
        width: sw.width

        Item {
            Layout.preferredWidth: 64
            Layout.fillHeight: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: sw.text
                font.pixelSize: 16
                font.weight: sw.checked ? Font.DemiBold : Font.Normal
                color: sw.checked ? Material.accent : Material.foreground

                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Label {
                text: sw.description
                font.pixelSize: 13
                color: Material.secondaryTextColor
                visible: text !== ""

                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.8
            }
        }
    }
}
