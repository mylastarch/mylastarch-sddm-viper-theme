import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control

    contentItem: Text {
        text: control.text
        font: control.font
        color: "#efefef"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30
        color: control.down ? Qt.rgba(0, 0, 0, 0.7) : Qt.rgba(0, 0, 0, 0.5)
        radius: 5

        Behavior on color {
            PropertyAnimation { duration: 150 }
        }
    }
}
