import QtQuick
import QtQuick.Controls.Basic

TextField {
    id: control
    color: "white"
    placeholderTextColor: "gray"
    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30
        color: activeFocus ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(0, 0, 0, 0.4)
        border.color: Qt.rgba(1, 1, 1, 0.4)
        radius: 3

        Behavior on color {
            PropertyAnimation { duration: 150 }
        }
    }
}
