import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Shapes
import jlqml

import "components"

import "js/utils.js" as JsUtils

Pane {
    id: scanRoot

    Material.elevation: 0
    Material.roundedScale: Material.SmallScale

    property bool showDropZone: true
    property int activeIndex: -1
    property bool isProcessing: false

    // Model for all selected images and their detection results
    ListModel {
        id: imagesModel
        // Structure: ListElement { path: "", detections: [] }
    }

    // Model for detections of the currently active image
    ListModel {
        id: detectionsModel
        Component.onCompleted: clear()
    }

    Toast { id: toast }

    LoadingOverlay {
        active: scanRoot.isProcessing
        message: "Analyzing Images..."
    }

    NoResultDialog { id: noResultDialog }

    ScanDetailsDrawer {
        id: detailsDrawer
        detectionData: scanRoot.activeIndex !== -1 ? detectionsModel.get(scanRoot.activeIndex) : null
        onCopyRequested: (txt) => {
            tempClipboard.text = txt
            tempClipboard.selectAll()
            tempClipboard.copy()
            toast.show("Copied to clipboard")
        }
    }

    function detect(urls) {
        JsUtils.detectImages(urls, scanRoot, imagesModel, detectionsModel, Julia, noResultDialog);
    }

    FileDialog {
        id: fileDialog
        title: "Please choose barcode image(s)"
        // currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["Image files (*.png *.jpg *.jpeg)"]
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            detect(fileDialog.selectedFiles)
        }
    }

    Rectangle {
        id: dropZone
        anchors.fill: parent
        color: dropArea.containsDrag ? Qt.alpha(Material.accent, 0.1) : "transparent"
        border.color: Material.accent
        border.width: 2
        radius: 10

        visible: showDropZone

        TapHandler {
            onTapped: fileDialog.open()
        }

         RowLayout {
            anchors.centerIn: parent
            spacing: 10
            Image {
                source: "images/add_photo_alternate.svg"
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: dropLabel
                text: dropArea.containsDrag ? "Drop images here" : "Drag an image files here, or click to upload"
                font.pixelSize: 18
                color: dropArea.containsDrag ? Material.accent : Material.secondaryTextColor
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent

            onEntered: (drag) => {
                if (drag.hasUrls) {
                    let hasValidImage = false;
                    for (const dragUrl of drag.urls) {
                        if (JsUtils.isImageFile(dragUrl)) {
                            hasValidImage = true;
                            break;
                        }
                    }
                    drag.accepted = hasValidImage;
                } else {
                    drag.accepted = false;
                }
            }

            onDropped: (drop) => {
                if (drop.hasUrls) {
                    let validUrls = [];
                    for (const dropUrl of drop.urls){
                        if(JsUtils.isImageFile(dropUrl)) {
                            validUrls.push(dropUrl);
                        }
                    }
                    if(validUrls.length > 0) {
                        detect(validUrls);
                        drop.acceptProposedAction();
                    } else {
                        drop.accepted = false;
                        toast.show("No valid image files found in selection.");
                    }
                }
            }
        }
    }

    Rectangle {
        id: resultZone
        anchors.fill: parent
        visible: !showDropZone
        radius: 8
        color: Qt.alpha(Material.accent, 0.03)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                SwipeView {
                    id: swipeView
                    anchors.fill: parent
                    onCurrentIndexChanged: JsUtils.updateActiveDetections(swipeView.currentIndex, imagesModel, detectionsModel, scanRoot, detailsDrawer)

                    Repeater {
                        model: imagesModel
                        CarouselPage {
                            imagePath: model.path
                            detectionsModel: model.detections
                            currentIndex: swipeView.currentIndex
                            pageIndex: index
                            activeDetectionIndex: scanRoot.activeIndex
                        }
                    }
                }

                NavButton {
                    anchors.left: parent.left
                    anchors.verticalCenter: swipeView.verticalCenter
                    anchors.leftMargin: 5
                    visible: swipeView.currentIndex > 0
                    onClicked: swipeView.decrementCurrentIndex()
                }

                NavButton {
                    isRight: true
                    anchors.right: parent.right
                    anchors.verticalCenter: swipeView.verticalCenter
                    anchors.rightMargin: 5
                    visible: swipeView.currentIndex < imagesModel.count - 1
                    onClicked: swipeView.incrementCurrentIndex()
                }
            }

            PageStatusIndicator {
                count: swipeView.count
                currentIndex: swipeView.currentIndex
                Layout.alignment: Qt.AlignHCenter
                visible: count > 1
                onRequestIndex: (idx) => swipeView.currentIndex = idx
            }

            Button {
                icon.source: "images/delete_sweep.svg"
                text: qsTr("Clear All")
                highlighted: true
                Material.background: Material.Orange
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    showDropZone = true;
                    imagesModel.clear();
                    detectionsModel.clear();
                    scanRoot.activeIndex = -1;
                    detailsDrawer.close();
                }
            }
        }
    }

    TextEdit {
        id: tempClipboard
        visible: false
    }
}
