import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtQuick.Layouts
import jlqml

Pane {
    id: generateRoot

    Material.elevation: 5
    Material.roundedScale: Material.SmallScale

    FileDialog {
        id: generatedImageSaveDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["PNG files (*.png)"]

        onAccepted: {
            generatedImageDisp.grabToImage(function(result) {
                result.saveToFile(selectedFile)
            })
        }
    }

    Dialog {
        id: emptyContentDialog
        title: "Empty Content"
        anchors.centerIn: parent
        parent: Overlay.overlay
        modal: true
        standardButtons: Dialog.Ok
        ColumnLayout {
            spacing: 12
            Label {
                text: "Content should not be empty"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 80

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Material.color(Material.LightBlue)
                border.width: 2
                radius: 6
            }

            JuliaDisplay {
                id: generatedImageDisp
                anchors.centerIn: parent
                height: 300
                width: 300
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 20
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 20

            ComboBox {
                id: barcodeFormats
                model: [
                    "Aztec", "Codabar", "Code39", "Code93", "Code128",
                    "DataBar", "DataBarExpanded", "DataMatrix", "EAN8",
                    "EAN13", "ITF", "MaxiCode", "PDF417", "QRCode",
                    "UPCA", "UPCE", "MicroQRCode", "RMQRCode", "DXFilmEdge",
                    "DataBarLimited", "LinearCodes", "MatrixCodes",
                ]
                Component.onCompleted: currentIndex = find("QRCode")
                Layout.preferredWidth: 150
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                TextArea {
                    id: generateContentArea
                    wrapMode: Text.WordWrap
                    selectByMouse: true
                    padding: 0
                    placeholderText: "Enter content"
                    Material.containerStyle: Material.Filled
                }
            }
            Button {
                id: qrGenerateButton
                icon.source: "images/qr_code_2.svg"
                text: "Generate"
                highlighted: true
                Material.background: Material.Pink
                onClicked: {
                    const content = generateContentArea.text
                    if (content) {
                        const s = Julia.barcode_display(generatedImageDisp, content, barcodeFormats.currentText)
                        generatedImageDisp.height = s[0]
                        generatedImageDisp.width = s[1]
                        qrDownloadButton.visible = true
                    } else {
                        emptyContentDialog.open()
                    }
                }
            }
            Button {
                id: qrDownloadButton
                icon.source: "images/download.svg"
                text: "Save"
                visible: false
                highlighted: true
                Material.background: Material.Pink
                onClicked: {
                    generatedImageSaveDialog.open()
                }
            }
        }
    }
}
