import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import jlqml

Pane {
    id: scanRoot

    Material.elevation: 5
    Material.roundedScale: Material.SmallScale

    property bool showDropZone: true

    function toLocalFile(url) {
        // To-Do remove when QUrl::toLocalFile() avaiable
        return decodeURIComponent(url).replace(/^(file:\/{2,3})/, "");
    }

    function detect(url) {
        const imagePath = toLocalFile(url);
        const res = Julia.detect(imagePath);
        if (res.length === 0) {
            noResultDialog.open()
            return
        }
        showDropZone = false
        uploadImage.source = url
        // To-Do show multiple detects
        contentArea.text = res[0][0]
        formatLabel.text = res[0][1]
    }

    Dialog {
        id: noResultDialog
        title: "Not found"
        anchors.centerIn: parent
        parent: Overlay.overlay
        modal: true
        standardButtons: Dialog.Ok
        ColumnLayout {
            spacing: 12
            Label {
                text: "No Barcodes/Qrcode found"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    FileDialog {
        //  To-Do accept multiple images
        id: fileDialog
        title: "Please choose a barcode image"
        // currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["Image files (*.png *.jpg *.jpeg)"]
        onAccepted: {
            detect(fileDialog.selectedFile)
        }
    }

    Rectangle {
        id: dropZone
        anchors.fill: parent
        color: dropArea.containsDrag ? Qt.alpha(Material.accent, 0.1) : "transparent"
        border.color: dropArea.containsDrag ? Material.accent : Material.hintTextColor
        border.width: 2
        radius: 10

        visible: showDropZone

        TapHandler {
            onTapped: fileDialog.open()
        }

         ColumnLayout {
            anchors.centerIn: parent
            spacing: 10
            Image {
                source: "images/add_photo_alternate.png"
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: dropLabel
                text: dropArea.containsDrag ? "Drop image here" : "Drag an image file here, or click to upload"
                font.pixelSize: 18
                color: dropArea.containsDrag ? Material.accent : Material.secondaryTextColor
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent

            //  To-Do accept multiple images

            function isImageFile(url) {
                return url.toString().toLowerCase().match(/\.(png|jpe?g)$/);
            }

            onEntered: (drag) => {
                if (!drag.hasUrls || drag.urls.length !== 1 || !isImageFile(drag.urls[0])) {
                    drag.accepted = false
                }
            }

            onDropped: (drop) => {
                if (drop.hasUrls && drop.urls.length === 1 && isImageFile(drop.urls[0])) {
                    detect(drop.urls[0])
                    drop.acceptProposedAction()
                } else {
                    drop.accepted = false
                    console.warn("Multiple files or invalid items rejected.")
                }
            }
        }
    }

    Rectangle {
        id: resultZone
        anchors.fill: parent
        visible: !showDropZone
        radius: 8
        color: "transparent"

        ColumnLayout {
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

                Image {
                    id: uploadImage
                    anchors.fill: parent
                    anchors.margins: 10
                    fillMode: Image.PreserveAspectFit
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 20
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                spacing: 20

                RowLayout {
                    spacing: 5
                    Label {
                        text: "Format:"
                        font.bold: true
                        color: "#666666"
                    }
                    Label {
                        id: formatLabel
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                RowLayout {
                    spacing: 5
                    Label {
                        text: "Content:"
                        font.bold: true
                        color: "#666666"
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        TextArea {
                            id: contentArea
                            readOnly: true
                            wrapMode: Text.WordWrap
                            selectByMouse: true
                            padding: 0
                        }
                    }
                }

                Button {
                    icon.source: "images/delete_sweep.png"
                    text: "Clear"
                    highlighted: true
                    Material.background: Material.Orange
                    onClicked: {
                        showDropZone = true
                    }
                }
            }
        }
    }
}
