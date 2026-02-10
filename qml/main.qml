import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
    id: window
    visible: true
    visibility: ApplicationWindow.Maximized // Opens in full size
    title: "QRStudio.jl"

    readonly property bool _setEnv: {
        Qt.application.organization = "com.rakeshksr"
        Qt.application.name = "QRStudio"
        return true
    }

    Settings {
        id: appSettings
        property string themeMode: "System"
        property string accentColor: "Pink"
        // property bool saveHistory: true
    }


    Material.theme: Material[appSettings.themeMode]
    Material.accent: Material[appSettings.accentColor] || Material.Pink

    menuBar: AppMenuBar{}

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Material.elevation: 3
            Layout.fillWidth: true
            Layout.margins: 10
            TabButton {
                text: "Scan"
                icon.source: "images/qr_code_scanner.png"
            }
            TabButton {
                text: "Generate"
                icon.source: "images/qr_code_2_add.png"
            }
            TabButton {
                text: "Settings"
                icon.source: "images/settings.png"
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.margins: 10

            currentIndex: tabBar.currentIndex

            ScanView {}
            GenerateView {}
            SettingsView {}
        }
    }
}
