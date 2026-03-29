import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

ToolButton {
    id: navBtn
    property bool isRight: false

    icon.source: isRight ? "images/arrow_forward_ios.svg" : "images/arrow_back_ios.svg"
    z: 10
    Material.background: Qt.rgba(0, 0, 0, 0.5)

    opacity: visible ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 150 } }
}
