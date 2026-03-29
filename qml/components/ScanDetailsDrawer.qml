import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Drawer {
    id: root
    property var detectionData: null
    signal copyRequested(string text)

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
                icon.source: "../images/close.svg"
                onClicked: root.close()
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
                value: root.detectionData ? root.detectionData.format : "Unknown"
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
                    text: root.detectionData ? root.detectionData.content : ""
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
            enabled: root.detectionData !== null
            icon.source: "../images/content_copy.svg"
            onClicked: root.copyRequested(root.detectionData.content)
        }
    }
}
