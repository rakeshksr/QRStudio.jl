import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Shapes
import jlqml

Pane {
    id: scanRoot

    Material.elevation: 5
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

    function toLocalFile(url) {
        // To-Do remove when QUrl::toLocalFile() avaiable
        return decodeURIComponent(url).replace(/^(file:\/{2,3})/, "");
    }

    function detect(urls) {
        if (urls.length === 0) return;
        scanRoot.isProcessing = true;

        Qt.callLater(() => {
            imagesModel.clear();
            detectionsModel.clear();
            scanRoot.activeIndex = -1;

            for (const url of urls) {
                const imagePath = toLocalFile(url);
                const detections = Julia.detect(imagePath);
                let imageDetections = [];
                 // To-Do replace detections array with julia struct
                for (const detection of detections) {
                    imageDetections.push({
                        "content": detection[0],
                        "format": detection[1],
                        "topLeftX": detection[2],
                        "topLeftY": detection[3],
                        "topRightX": detection[4],
                        "topRightY": detection[5],
                        "bottomRightX": detection[6],
                        "bottomRightY": detection[7],
                        "bottomLeftX": detection[8],
                        "bottomLeftY": detection[9]
                    });
                }
                imagesModel.append({
                    "path": url,
                    "detections": imageDetections
                });
            }

            scanRoot.isProcessing = false;

            let totalDetections = 0;
            for (let k = 0; k < imagesModel.count; k++) {
                totalDetections += imagesModel.get(k).detections.count;
            }

            if (totalDetections === 0) {
                noResultDialog.open();
                imagesModel.clear();
                return;
            }
            showDropZone = false;
        });
    }

    function loadActiveImageDetections(imageIndex) {
        detectionsModel.clear();
        scanRoot.activeIndex = -1;
        detailsDrawer.close();

        if (imageIndex >= 0 && imageIndex < imagesModel.count) {
            const currentItem = imagesModel.get(imageIndex);
            for (let i = 0; i < currentItem.detections.count; i++) {
                detectionsModel.append(currentItem.detections.get(i));
            }
        }
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
        border.color: dropArea.containsDrag ? Material.accent : Material.hintTextColor
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

            function isImageFile(url) {
                return url.toString().toLowerCase().match(/\.(png|jpe?g)$/);
            }

            onEntered: (drag) => {
                if (drag.hasUrls) {
                    let hasValidImage = false;
                    for (const dragUrl of drag.urls) {
                        if (isImageFile(dragUrl)) {
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
                        if(isImageFile(dropUrl)) {
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
        color: "transparent"

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
                    clip: true

                    onCurrentIndexChanged: {
                        loadActiveImageDetections(swipeView.currentIndex);
                    }

                    Repeater {
                        id: imageRepeater
                        model: imagesModel

                        Item {
                            id: carouselPageRoot
                            readonly property real distance: Math.abs(index - swipeView.currentIndex)
                            readonly property real relativePosition: Math.min(distance, 1.0)
                            Image {
                                id: uploadImage
                                anchors.fill: parent
                                anchors.margins: 40
                                fillMode: Image.PreserveAspectFit
                                source: model.path

                                // Carousel Visuals
                                scale: 1.0 - (relativePosition * 0.15)
                                opacity: 1.0 - (relativePosition * 0.6)
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                Behavior on opacity { NumberAnimation { duration: 200 } }

                                ToolTip {
                                    id: detectionToolTip
                                    visible: (swipeView.currentIndex === index) && (scanRoot.activeIndex !== -1) && (!detailsDrawer.opened)
                                    parent: canvas
                                    text: scanRoot.activeIndex !== -1 ? detectionsModel.get(scanRoot.activeIndex).content : ""

                                    property var mappedPos: uploadImage.mapToItem(canvas, globalHover.point.position.x, globalHover.point.position.y)
                                    x: mappedPos.x
                                    y: mappedPos.y - 40
                                    z: 100

                                    enter: Transition {
                                        NumberAnimation {
                                            property: "opacity"
                                            from: 0
                                            to: 1
                                            duration: 100
                                        }
                                    }
                                    exit: Transition {
                                        NumberAnimation {
                                            property: "opacity"
                                            from: 1
                                            to: 0
                                            duration: 100
                                        }
                                    }
                                }

                                Item {
                                    id: canvas
                                    x: (uploadImage.width - uploadImage.paintedWidth) / 2
                                    y: (uploadImage.height - uploadImage.paintedHeight) / 2
                                    width: uploadImage.paintedWidth
                                    height: uploadImage.paintedHeight

                                    readonly property real scaleX: width / uploadImage.sourceSize.width
                                    readonly property real scaleY: height / uploadImage.sourceSize.height

                                    Repeater {
                                        id: polygonRepeater
                                        model: detectionsModel
                                        Shape {
                                            anchors.fill: parent
                                            layer.enabled: true
                                            layer.samples: 4

                                            readonly property bool isActive: index === scanRoot.activeIndex

                                            ShapePath {
                                                strokeColor: isActive ? "yellow" : "cyan"
                                                strokeWidth: isActive ? 4 : 2
                                                fillColor: isActive ? Qt.rgba(1, 1, 0, 0.3) : Qt.rgba(0, 1, 1, 0.1)

                                                startX: model.topLeftX * canvas.scaleX
                                                startY: model.topLeftY * canvas.scaleY

                                                PathLine {
                                                    x: model.topRightX * canvas.scaleX
                                                    y: model.topRightY * canvas.scaleY
                                                }
                                                PathLine {
                                                    x: model.bottomRightX * canvas.scaleX
                                                    y: model.bottomRightY * canvas.scaleY
                                                }
                                                PathLine {
                                                    x: model.bottomLeftX * canvas.scaleX
                                                    y: model.bottomLeftY * canvas.scaleY
                                                }
                                                PathLine {
                                                    x: model.topLeftX * canvas.scaleX
                                                    y: model.topLeftY * canvas.scaleY
                                                }
                                            }
                                        }
                                    }
                                }

                                HoverHandler {
                                    id: globalHover
                                    onPointChanged: {
                                        if (detailsDrawer.opened) return;

                                        let pos = uploadImage.mapToItem(canvas, point.position.x, point.position.y);

                                        let foundIndex = -1;
                                        for (let i = detectionsModel.count - 1; i >= 0; i--) {
                                            if (isPointInPolygon(pos.x, pos.y, detectionsModel.get(i), canvas)) {
                                                foundIndex = i;
                                                break;
                                            }
                                        }
                                        scanRoot.activeIndex = foundIndex;
                                    }
                                }

                                TapHandler {
                                    onTapped: {
                                        if (scanRoot.activeIndex !== -1) {
                                            detailsDrawer.open();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ToolButton {
                    id: leftArrow
                    anchors.left: parent.left
                    anchors.verticalCenter: swipeView.verticalCenter
                    anchors.leftMargin: 5
                    icon.source: "images/arrow_back_ios.svg"
                    z: 10
                    visible: swipeView.currentIndex > 0
                    onClicked: swipeView.decrementCurrentIndex()
                    Material.background: Qt.rgba(0,0,0,0.5)
                }

                ToolButton {
                    id: rightArrow
                    anchors.right: parent.right
                    anchors.verticalCenter: swipeView.verticalCenter
                    anchors.rightMargin: 5
                    icon.source: "images/arrow_forward_ios.svg"
                    z: 10
                    visible: swipeView.currentIndex < imagesModel.count - 1
                    onClicked: swipeView.incrementCurrentIndex()
                    Material.background: Qt.rgba(0,0,0,0.5)
                }
            }

            PageIndicator {
                id: controlIndicator
                count: swipeView.count
                currentIndex: swipeView.currentIndex
                Layout.alignment: Qt.AlignHCenter
                visible: count > 1
                contentItem: Row {
                    spacing: 12
                    Repeater {
                        model: controlIndicator.count
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: index === controlIndicator.currentIndex ? Material.accent : Material.hintTextColor
                            opacity: index === controlIndicator.currentIndex ? 1.0 : 0.3

                            Behavior on opacity { OpacityAnimator { duration: 150 }}
                            Behavior on color { ColorAnimation { duration: 150 }}

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    swipeView.currentIndex = index
                                }
                            }
                        }
                    }
                }
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

    Drawer {
        id: detailsDrawer
        width: Math.min(400, parent.width * 0.9)
        height: parent.height
        edge: Qt.RightEdge

        background: Rectangle {
            color: Material.dialogColor
            Rectangle {
                anchors.left: parent.left
                width: 1
                height: parent.height
                color: Qt.rgba(1, 1, 1, 0.1)
            }
        }

        property var d: scanRoot.activeIndex !== -1 ? detectionsModel.get(scanRoot.activeIndex) : null

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Detection Details"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: Material.accent
                    Layout.fillWidth: true
                }
                ToolButton {
                    icon.source: "images/close.svg"
                    onClicked: detailsDrawer.close()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Material.dividerColor
                opacity: 0.5
            }

            Column {
                Layout.fillWidth: true
                spacing: 15

                DetailRow {
                    label: "Type"
                    value: detailsDrawer.d ? detailsDrawer.d.format : "Unknown"
                }

                Label {
                    text: "Decoded Content:"
                    font.weight: Font.Medium
                    color: Material.secondaryTextColor
                    topPadding: 10
                }

                ScrollView {
                    width: parent.width
                    height: 250
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    TextArea {
                        id: detailsText
                        text: detailsDrawer.d ? detailsDrawer.d.content : ""
                        readOnly: true
                        wrapMode: Text.WordWrap
                        color: Material.accent
                        font.family: "JetBrains Mono, Cascadia Code, Monospace"
                        font.pixelSize: 14
                        selectByMouse: true

                        verticalAlignment: Text.AlignTop
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10
                        padding: 10

                        background: Rectangle {
                            color: Qt.alpha(Material.accent, 0.05)
                            radius: 12
                            border.color: Qt.alpha(Material.accent, 0.2)
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "Copy to Clipboard"
                Layout.fillWidth: true
                highlighted: true
                enabled: detailsDrawer.d !== null
                icon.source: "images/content_copy.svg"
                onClicked: {
                    tempClipboard.text = detailsDrawer.d.content
                    tempClipboard.selectAll()
                    tempClipboard.copy()
                    toast.show("Copied to clipboard")
                }
            }
        }
    }

    function isPointInPolygon(px, py, item, currentCanvas) {
        const x = [
            item.topLeftX * currentCanvas.scaleX,
            item.topRightX * currentCanvas.scaleX,
            item.bottomRightX * currentCanvas.scaleX,
            item.bottomLeftX * currentCanvas.scaleX
        ];
        const y = [
            item.topLeftY * currentCanvas.scaleY,
            item.topRightY * currentCanvas.scaleY,
            item.bottomRightY * currentCanvas.scaleY,
            item.bottomLeftY * currentCanvas.scaleY
        ];

        let inside = false;
        for (let i = 0, j = 3; i < 4; j = i++) {
            const xi = x[i], yi = y[i];
            const xj = x[j], yj = y[j];

            const intersect = ((yi > py) !== (yj > py)) &&
                              (px < (xj - xi) * (py - yi) / (yj - yi) + xi);

            if (intersect) inside = !inside;
        }
        return inside;
    }

    TextEdit {
        id: tempClipboard
        visible: false
    }

    Popup {
        id: toast
        x: (parent.width - width) / 2
        y: parent.height - 60
        width: 300
        height: 40
        background: Rectangle {
            color: "#333"
            radius: 20
            border.color: "cyan"
        }
        contentItem: Label {
            id: tText
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        function show(m) {
            tText.text = m;
            open();
            tTimer.restart();
        }
        Timer {
            id: tTimer;
            interval: 2500;
            onTriggered: toast.close()
        }
    }

    Rectangle {
        id: loadingIndicator
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
        visible: scanRoot.isProcessing
        z: 2000

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15

            BusyIndicator {
                id: progressCircle
                running: scanRoot.isProcessing
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Analyzing Images..."
                color: "white"
                font.pixelSize: 16
                font.weight: Font.Medium
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    component DetailRow : Row {
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
}
