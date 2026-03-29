import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

RowLayout {
    id: root

    property string iconSource: ""
    property color previewColor: "transparent"
    property bool showColorPreview: false
    property string label: ""
    default property alias actionControl: controlContainer.data

    Layout.fillWidth: true
    spacing: 16
    Layout.bottomMargin: 8

    Item {
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24

        Image {
            anchors.fill: parent
            source: root.iconSource
            visible: root.iconSource !== "" && !root.showColorPreview
            opacity: 0.7
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: root.previewColor
            visible: root.showColorPreview
        }
    }

    Label {
        text: root.label
        Layout.fillWidth: true
        font.pixelSize: 15
    }

    Item {
        id: controlContainer
        Layout.preferredWidth: 150
        Layout.preferredHeight: 40
    }
}
