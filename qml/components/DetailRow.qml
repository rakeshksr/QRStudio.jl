import QtQuick
import QtQuick.Controls.Material

Row {
    property string label: ""
    property string value: ""
    spacing: 10

    Text {
        text: label + ":"
        color: "#888"
        width: 100
        font.pixelSize: 14
    }
    Text {
        text: value
        color: Material.accent
        font.bold: true
        font.pixelSize: 14
    }
}
