import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

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

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: appearanceLayout.height + 40
                radius: 16
                color: Material.dialogColor
                border.color: Material.dividerColor

                ColumnLayout {
                    id: appearanceLayout
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 20

                    Label {
                        text: "Appearance"
                        font.weight: Font.Medium
                        font.pixelSize: 18
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        Image {
                                source: "images/routine.svg"
                            Layout.preferredWidth: 24; Layout.preferredHeight: 24
                            opacity: 0.7
                        }
                        Label {
                            text: "Theme Mode"
                            Layout.fillWidth: true
                        }
                        ComboBox {
                            id: themePicker
                            model: ["System", "Light", "Dark"]
                            Layout.preferredWidth: 150
                            Component.onCompleted: currentIndex = indexOfValue(appSettings.themeMode)
                            onActivated: (index) => appSettings.themeMode = textAt(index)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: Material.accent
                        }
                        Label {
                            text: "Accent Color"
                            Layout.fillWidth: true
                        }
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
            }

            Rectangle {
                enabled: false
                Layout.fillWidth: true
                implicitHeight: behaviorLayout.implicitHeight + 40
                radius: 16
                color: Material.dialogColor
                border.color: Material.dividerColor

                ColumnLayout {
                    id: behaviorLayout
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 12

                    Label {
                        text: "Behavior(Feature in Progress)"
                        font.weight: Font.Medium
                        font.pixelSize: 18
                        Layout.bottomMargin: 8
                    }

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

    component DescriptionSwitch : Switch {
        id: sw
        property string description: ""

        topPadding: 12
        bottomPadding: 12
        leftPadding: 0

        contentItem: RowLayout {
            spacing: 0
            width: sw.width

            Item {
                Layout.preferredWidth: 64
                Layout.fillHeight: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    text: sw.text
                    font.pixelSize: 16
                    font.weight: sw.checked ? Font.DemiBold : Font.Normal
                    color: sw.checked ? Material.accent : Material.foreground

                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Label {
                    text: sw.description
                    font.pixelSize: 13
                    color: Material.secondaryTextColor
                    visible: text !== ""

                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    opacity: 0.8
                }
            }
        }
    }
}
