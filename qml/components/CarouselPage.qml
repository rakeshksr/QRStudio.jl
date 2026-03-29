import QtQuick
import QtQuick.Shapes
import QtQuick.Controls.Material

import "../js/utils.js" as JsUtils

Item {
    id: root
    property string imagePath: ""
    property var detectionsModel: null
    property int currentIndex: 0
    property var hoverPoint: null
    property bool isCurrentPage: false
    property int pageIndex: 0
    property int activeDetectionIndex: -1
    property real scaleX: canvas.scaleX
    property real scaleY: canvas.scaleY

    property point hoverPos: Qt.point(0,0)
    readonly property bool isCurrent: currentIndex === pageIndex

    readonly property real distance: Math.abs(pageIndex - currentIndex)
    readonly property real relativePosition: Math.min(distance, 1.0)

    Image {
        id: uploadImage
        anchors.fill: parent
        anchors.margins: 40
        fillMode: Image.PreserveAspectFit
        source: root.imagePath

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

            visible: root.isCurrent && (root.activeDetectionIndex !== -1) && (!detailsDrawer.opened)
            parent: uploadImage
			text: (visible && root.detectionsModel && root.activeDetectionIndex !== -1)
                ? root.detectionsModel.get(root.activeDetectionIndex).content : ""

            x: localHover.point.position.x - (width / 2)
            y: localHover.point.position.y - 40
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
            x: (parent.width - parent.paintedWidth) / 2
            y: (parent.height - parent.paintedHeight) / 2
            width: parent.paintedWidth
            height: parent.paintedHeight

            readonly property real scaleX: width / uploadImage.sourceSize.width
            readonly property real scaleY: height / uploadImage.sourceSize.height

            Repeater {
				id: polygonRepeater
                model: root.detectionsModel
                Shape {
                    anchors.fill: parent
                    layer.enabled: true
                    layer.samples: 4
                    readonly property bool isActive: index === root.activeDetectionIndex

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
            id: localHover
            enabled: root.isCurrent && !detailsDrawer.opened
            onPointChanged: {
				if (detailsDrawer.opened) return;
                let pos = uploadImage.mapToItem(canvas, point.position.x, point.position.y);
                let foundIndex = -1;
				for (let i = root.detectionsModel.count - 1; i >= 0; i--) {
					if (JsUtils.isPointInPolygon(pos.x, pos.y, root.detectionsModel.get(i), canvas)) {
						foundIndex = i;
						break;
					}
				}
                scanRoot.activeIndex = foundIndex;
            }
        }

        TapHandler {
            onTapped: {
				if (root.activeDetectionIndex !== -1) {
					detailsDrawer.open();
				}
			}
        }
    }
}
