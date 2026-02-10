import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Pane {

    Material.elevation: 5
    Material.roundedScale: Material.SmallScale

    ColumnLayout {
        anchors {
            left: parent.left
            top: parent.top
            margins: 20
        }
        spacing: 16

        Label {
            text: "Settings"
            font.pixelSize: 24
        }

        RowLayout {
            spacing: 12

            Label {
                text: "Theme"
                Layout.alignment: Qt.AlignVCenter
            }

            ComboBox {
                model: ["System", "Light", "Dark"]
                Component.onCompleted: currentIndex = indexOfValue(appSettings.themeMode)
                Layout.preferredWidth: 150

                onActivated: (index) => {
                    appSettings.themeMode = textAt(index)
                }
            }
        }
        RowLayout {
            spacing: 12

            Label {
                text: "Accent"
                Layout.alignment: Qt.AlignVCenter
            }

            ComboBox {
                id: accentPicker
                model: [
                    "Red", "Pink", "Purple", "DeepPurple", "Indigo", "Blue",
                    "LightBlue", "Cyan", "Teal", "Green", "LightGreen",
                    "Lime", "Yellow", "Amber", "Orange", "DeepOrange",
                    "Brown", "Grey", "BlueGrey"
                ]
                Component.onCompleted: currentIndex = indexOfValue(appSettings.accentColor)
                Layout.preferredWidth: 150
                onActivated: (index) => {
                    appSettings.accentColor = textAt(index)
                }
                delegate: ItemDelegate {
                    width: accentPicker.width

                    contentItem: Text {
                        text: modelData
                        color: Material.color(Material[modelData])
                        font.bold: accentPicker.currentIndex === index
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        // Switch {
        //     text: "Save History Locally"
        // }
    }
}
