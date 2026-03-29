import QtQuick
import QtQuick.Controls.Material

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
