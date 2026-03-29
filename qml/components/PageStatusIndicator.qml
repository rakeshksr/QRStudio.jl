import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

PageIndicator {
    id: controlIndicator
    signal requestIndex(int idx)
    spacing: 12

    delegate: Rectangle {
        implicitWidth: 12
        implicitHeight: 12
        radius: 6
        color: index === controlIndicator.currentIndex ? Material.accent : Material.hintTextColor
        opacity: index === controlIndicator.currentIndex ? 1.0 : 0.3

        Behavior on opacity { OpacityAnimator { duration: 150 }}
        Behavior on color { ColorAnimation { duration: 150 }}

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                controlIndicator.requestIndex(index)
            }
        }
    }
}
