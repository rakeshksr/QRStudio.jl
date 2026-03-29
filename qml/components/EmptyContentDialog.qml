import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: emptyContentDialog
    title: "Empty Content"
    anchors.centerIn: parent
    parent: Overlay.overlay
    modal: true
    standardButtons: Dialog.Ok
    Label {
        text: "Please enter some content to generate a barcode."
        wrapMode: Text.WordWrap
    }
}
