import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

MenuBar {
    id: root

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

    Dialog {
        id: aboutDialog
        title: "About QRStudio.jl"
        anchors.centerIn: parent
        parent: Overlay.overlay
        modal: true
        standardButtons: Dialog.Ok

        ColumnLayout {
            spacing: 15
            anchors.fill: parent

            Label {
                text: "QRStudio.jl"
                font.pixelSize: 20
                font.bold: true
                // color: Material.accent
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Version 0.1.0\nProfessional QR Code Tool\nPowered by Julia, QML.jl & ZXingCPP.jl"
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
