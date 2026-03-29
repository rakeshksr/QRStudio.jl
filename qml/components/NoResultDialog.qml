import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    title: "Not found"
    anchors.centerIn: parent
    parent: Overlay.overlay
    modal: true
    standardButtons: Dialog.Ok
    ColumnLayout {
        spacing: 12
        Label {
            text: "No Barcode/Qrcodes found"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
