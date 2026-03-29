import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtQuick.Layouts
import jlqml

import "components"

Pane {
    id: generateRoot
    Material.elevation: 0
    padding: 20

    property bool hasImage: false

    EmptyContentDialog { id: emptyContentDialog }
    Toast { id: toast }

    FileDialog {
        id: generatedImageSaveDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["PNG files (*.png)"]

        onAccepted: {
            generatedImageDisp.grabToImage(function(result) {
                result.saveToFile(selectedFile);
                toast.show("Barcode saved successfully!")
            })
        }
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        Rectangle {
            id: previewContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 320

            color: Qt.alpha(Material.accent, 0.03)
            radius: 16
            border.color: Material.dividerColor
            border.width: 1

            Label {
                anchors.centerIn: parent
                text: "Your barcode will appear here"
                color: Material.hintTextColor
                visible: !generateRoot.hasImage
                font.pixelSize: 16
            }

            JuliaDisplay {
                id: generatedImageDisp
                anchors.centerIn: parent
                // The size is dynamically set by Julia
                opacity: generateRoot.hasImage ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            color: Material.dialogColor
            radius: 16
            border.color: Material.dividerColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                RowLayout {
                    spacing: 16

                    ComboBox {
                        id: barcodeFormats
                        Layout.preferredWidth: 200
                        enabled: !generateRoot.hasImage
                        model: [
                            "Aztec", "Codabar", "Code39", "Code93", "Code128",
                            "DataBar", "DataBarExpanded", "DataMatrix", "EAN8",
                            "EAN13", "ITF", "MaxiCode", "PDF417", "QRCode",
                            "UPCA", "UPCE", "MicroQRCode", "RMQRCode", "DXFilmEdge",
                            "DataBarLimited", "LinearCodes", "MatrixCodes",
                        ]
                        Component.onCompleted: currentIndex = find("QRCode")
                    }

                    ScrollView {
                        enabled: !generateRoot.hasImage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        TextArea {
                            id: generateContentArea
                            placeholderText: "Type content here..."
                            // enabled: !generateRoot.hasImage
                            wrapMode: Text.WordWrap
                            selectByMouse: true
                            font.pixelSize: 14
                            leftPadding: 12
                            rightPadding: 12
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Item { Layout.fillWidth: true } // Spacer

                    Button {
                        id: barcodeClearButton
                        text: "Clear"
                        visible: generateRoot.hasImage
                        highlighted: true
                        Material.background: Material.Orange
                        icon.source: "images/close.svg"
                        onClicked: {
                            Julia.clear_julia_display(generatedImageDisp)
                            generateContentArea.text = ""
                            generateRoot.hasImage = false
                        }
                    }

                    Button {
                        id: barcodeDownloadButton
                        text: "Save Image"
                        visible: generateRoot.hasImage
                        highlighted: true
                        Material.background: Material.Teal
                        icon.source: "images/download.svg"
                        onClicked: generatedImageSaveDialog.open()
                    }

                    Button {
                        id: barcodeGenerateButton
                        text: "Generate"
                        visible: !generateRoot.hasImage
                        highlighted: true
                        Material.background: Material.accent
                        icon.source: "images/qr_code_2.svg"
                        onClicked: {
                            if (generateContentArea.text) {
                                const s = Julia.barcode_display(generatedImageDisp, generateContentArea.text, barcodeFormats.currentText)
                                generatedImageDisp.height = s[0]
                                generatedImageDisp.width = s[1]
                                generateRoot.hasImage = true
                            } else {
                                emptyContentDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }
}
