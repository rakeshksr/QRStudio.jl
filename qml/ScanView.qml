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

    ListModel {
        id: detectionsModel

        ListElement {
            content: ""
            format: ""
            topLeftX: 0
            topLeftY: 0
            topRightX: 0
            topRightY: 0
            bottomRightX: 0
            bottomRightY: 0
            bottomLeftX: 0
            bottomLeftY: 0
        }

        Component.onCompleted: clear()
    }

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
        detectionsModel.clear();
        scanRoot.activeIndex = -1;

        // To-Do replace res array with julia struct
        for (var i = 0; i < res.length; i++) {
            detectionsModel.append({
                "content": res[i][0],
                "format": res[i][1],
                "topLeftX": res[i][2],
                "topLeftY": res[i][3],
                "topRightX": res[i][4],
                "topRightY": res[i][5],
                "bottomRightX": res[i][6],
                "bottomRightY": res[i][7],
                "bottomLeftX": res[i][8],
                "bottomLeftY": res[i][9]
            });
        }

        showDropZone = false
        uploadImage.source = url
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

                    Item {
                        id: canvas
                        x: (uploadImage.width - uploadImage.paintedWidth) / 2
                        y: (uploadImage.height - uploadImage.paintedHeight) / 2
                        width: uploadImage.paintedWidth
                        height: uploadImage.paintedHeight

                        readonly property real scaleX: width / uploadImage.sourceSize.width
                        readonly property real scaleY: height / uploadImage.sourceSize.height

                        Repeater {
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

                                    PathLine { x: model.topRightX * canvas.scaleX; y: model.topRightY * canvas.scaleY }
                                    PathLine { x: model.bottomRightX * canvas.scaleX; y: model.bottomRightY * canvas.scaleY }
                                    PathLine { x: model.bottomLeftX * canvas.scaleX; y: model.bottomLeftY * canvas.scaleY }
                                    PathLine { x: model.topLeftX * canvas.scaleX; y: model.topLeftY * canvas.scaleY }
                                }
                            }
                        }
                    }

                    HoverHandler {
                        id: globalHover
                        onPointChanged: {
                            if (detailsDrawer.opened) return;

                            // let pos = point.position
                            let pos = uploadImage.mapToItem(canvas, point.position.x, point.position.y);

                            let foundIndex = -1
                            for (let i = detectionsModel.count - 1; i >= 0; i--) {
                                if (isPointInPolygon(pos.x, pos.y, detectionsModel.get(i))) {
                                    foundIndex = i
                                    break
                                }
                            }
                            scanRoot.activeIndex = foundIndex
                        }
                    }

                    TapHandler {
                        onTapped: {
                            if (scanRoot.activeIndex !== -1) {
                                detailsDrawer.open()
                            }
                        }
                    }

                    ToolTip {
                        visible: scanRoot.activeIndex !== -1 && !detailsDrawer.opened
                        text: scanRoot.activeIndex !== -1 ? detectionsModel.get(scanRoot.activeIndex).content : ""
                        x: globalHover.point.position.x
                        y: globalHover.point.position.y - 35
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 20
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                spacing: 20

                Button {
                    icon.source: "images/delete_sweep.png"
                    text: "Clear"
                    highlighted: true
                    Material.background: Material.Orange
                    onClicked: {
                        showDropZone = true
                        detectionsModel.clear()
                        scanRoot.activeIndex = -1
                        uploadImage.source = ""
                    }
                }
            }
        }
    }

    Drawer {
        id: detailsDrawer
        width: 350
        height: parent.height
        edge: Qt.RightEdge
        background: Rectangle { color: "#252525"; border.color: "#333" }


        property var d: scanRoot.activeIndex !== -1 ? detectionsModel.get(scanRoot.activeIndex) : null

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Label {
                text: "Object Details"
                font.pixelSize: 24
                color: "white"
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#444"
            }

            Column {
                Layout.fillWidth: true
                spacing: 15

                DetailRow {
                    label: "Type"
                    value: detailsDrawer.d ? detailsDrawer.d.format : "-"
                }

                Label {
                    text: "Decoded Content:"
                    color: "#888"
                    topPadding: 10
                }

                ScrollView {
                    width: parent.width
                    // Layout.fillWidth: true
                    height: 200
                    clip: true

                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    TextArea {
                        id: detailsText
                        text: detailsDrawer.d ? detailsDrawer.d.content : ""
                        readOnly: true
                        wrapMode: Text.WordWrap
                        color: "cyan"
                        font.family: "Monospace"
                        font.pixelSize: 13

                        verticalAlignment: Text.AlignTop

                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10

                        background: Rectangle { color: "#1a1a1a"; radius: 4 }
                        padding: 10
                        selectByMouse: true
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "Copy Content"
                Layout.fillWidth: true
                highlighted: true
                enabled: detailsDrawer.d !== null
                onClicked: {
                    tempClipboard.text = detailsDrawer.d.content
                    tempClipboard.selectAll()
                    tempClipboard.copy()
                    toast.show("Content copied to clipboard")
                }
            }

            Button {
                text: "Close"
                Layout.fillWidth: true
                onClicked: detailsDrawer.close()
            }
        }
    }

    function isPointInPolygon(px, py, item) {
        const x = [
            item.topLeftX * canvas.scaleX,
            item.topRightX * canvas.scaleX,
            item.bottomRightX * canvas.scaleX,
            item.bottomLeftX * canvas.scaleX
        ];
        const y = [
            item.topLeftY * canvas.scaleY,
            item.topRightY * canvas.scaleY,
            item.bottomRightY * canvas.scaleY,
            item.bottomLeftY * canvas.scaleY
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

    TextEdit { id: tempClipboard; visible: false }

    Popup {
        id: toast
        x: (parent.width - width) / 2; y: parent.height - 60
        width: 300; height: 40
        background: Rectangle { color: "#333"; radius: 20; border.color: "cyan" }
        contentItem: Label { id: tText; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        function show(m) { tText.text = m; open(); tTimer.restart(); }
        Timer { id: tTimer; interval: 2500; onTriggered: toast.close() }
    }

    component DetailRow : Row {
        property string label: ""
        property string value: ""
        spacing: 10
        Text { text: label + ":"; color: "#888"; width: 100; font.pixelSize: 14 }
        Text { text: value; color: "white"; font.bold: true; font.pixelSize: 14 }
    }
}
