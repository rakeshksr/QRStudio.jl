import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import "components"

Pane {
    id: settingsRoot
    padding: 0
    Material.elevation: 0

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: Math.min(600, parent.width - 40)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            spacing: 24

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "Settings"
                    font.pixelSize: 32
                    font.weight: Font.DemiBold
                    Material.foreground: Material.accent
                }
                Label {
                    text: "Customize the appearance and behavior of Application"
                    font.pixelSize: 14
                    color: Material.secondaryTextColor
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            SettingsCard {
                title: "Appearance"

                SettingItem {
                    label: "Theme Mode"
                    iconSource: "../images/routine.svg"

                    ComboBox {
                        id: themePicker
                        model: ["System", "Light", "Dark"]
                        Layout.preferredWidth: 150
                        Component.onCompleted: currentIndex = indexOfValue(appSettings.themeMode)
                        onActivated: (index) => appSettings.themeMode = textAt(index)
                    }
                }

                SettingItem {
                    label: "Accent Color"
                    showColorPreview: true
                    previewColor: Material.accent

                    ComboBox {
                        id: accentPicker
                        model: [
                            "Red", "Pink", "Purple", "DeepPurple", "Indigo", "Blue",
                            "LightBlue", "Cyan", "Teal", "Green", "LightGreen",
                            "Lime", "Yellow", "Amber", "Orange", "DeepOrange",
                            "Brown", "Grey", "BlueGrey"
                        ]
                        Layout.preferredWidth: 150
                        Component.onCompleted: currentIndex = indexOfValue(appSettings.accentColor)
                        onActivated: (index) => appSettings.accentColor = textAt(index)

                        delegate: ItemDelegate {
                            width: accentPicker.width
                            contentItem: RowLayout {
                                spacing: 10
                                Rectangle {
                                    width: 12; height: 12; radius: 6
                                    color: Material.color(Material[modelData])
                                }
                                Text {
                                    text: modelData
                                    color: accentPicker.currentIndex === index ? Material.accent : Material.foreground
                                    font.bold: accentPicker.currentIndex === index
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            SettingsCard {
                title: "Behavior (Feature in Progress)"
                enabled: false

                DescriptionSwitch {
                    text: "Save Scan History"
                    Layout.fillWidth: true
                    checked: false
                    description: "Keep a local record of detected codes."
                }

                DescriptionSwitch {
                    text: "Auto-detect URLs"
                    Layout.fillWidth: true
                    checked: false
                    description: "Automatically open links in browser when scanned."
                }
            }
        }
    }
}
