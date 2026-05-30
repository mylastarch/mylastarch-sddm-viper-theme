import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import SddmComponents

import "SimpleControls" as Simple

Rectangle {
    id: root

    readonly property color backgroundColor: Qt.rgba(0, 0, 0, 0.5)
    readonly property color hoverBackgroundColor: Qt.rgba(0, 0, 0, 0.7)

    color: "black"
    width: 640
    height: 480
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants { id: textConstants }
    
    Connections {
        target: sddm
        
        function onLoginSucceeded() {}
        
        function onLoginFailed() {
            pw_entry.clear()
            pw_entry.focus = true
            
            errorMsgContainer.visible = true
        }
    }
    
    Image {
        id: background
    
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        source: config.background
    
        onStatusChanged: (status) => {
            if (status == Image.Error && source != config.defaultBackground) {
               source = config.defaultBackground
            }
        }
    
        states: State {
            name: "loaded"; when: background.status == Image.Ready
            PropertyChanges { background.opacity: 1 }
        }
    
        transitions: Transition {
            NumberAnimation {
                properties: "opacity"
                easing.type: Easing.InOutQuad
                duration: 200
            }
        }
    }

    Item {
        id: maskItem
        anchors.fill: background
        layer.enabled: true
        layer.smooth: true
        visible: false
    
        Rectangle {
            x: container.x
            y: container.y
            width: container.width
            height: container.height
            radius: container.radius
        }
    }
    
    MultiEffect {
        anchors.fill: parent
        source: background
        autoPaddingEnabled: false
        maskEnabled: true
        maskSource: maskItem
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        blurEnabled: true
        blurMax: 80
        blur: 1.0
        saturation: -0.1
        brightness: 0.1
        visible: false
    }

    Rectangle {
        id: container

        anchors.centerIn: parent
        color: Qt.rgba(0, 0, 0, 0)
        radius: 10

        height: 120
        width: 300

        opacity: 1

        ColumnLayout {
            id: loginColumnLayout

            anchors.fill: parent
            anchors.margins: 20
            spacing: 5

            Text {
                id: timelb
                color: Qt.rgba(229, 229, 229, 0.8)
                font.pointSize: 22
                font.bold: true
                text: Qt.formatTime(new Date(), "HH:mm")
                visible: false
            }

            Simple.ComboBox {
                id: user_entry
                model: userModel
                currentIndex: userModel.lastIndex
                textRole: "realName"
                KeyNavigation.backtab: session
                KeyNavigation.tab: pw_entry
                Layout.fillWidth: true
            }

            Simple.TextField {
                id: pw_entry
                echoMode: TextInput.Password
                focus: true
                placeholderText: ""
                onAccepted: sddm.login(user_entry.getValue(), pw_entry.text, session.currentIndex)
                KeyNavigation.backtab: user_entry
                KeyNavigation.tab: session
                Layout.fillWidth: true
            }

            Simple.ComboBox {
                id: session
                currentIndex: sessionModel.lastIndex
                model: sessionModel
                textRole: "name"
                visible: false
                Layout.fillWidth: true
                KeyNavigation.backtab: pw_entry
                KeyNavigation.tab: suspend
            }

            Rectangle {
                id: errorMsgContainer
                color: "#F44336"
                clip: true
                visible: false
                radius: 5
                Layout.fillWidth: true
   
                Label {
                    anchors.centerIn: parent
                    text: textConstants.loginFailed
                    color: "white"
                    font.bold: true
                    elide: Qt.locale().textDirection == Qt.RightToLeft ? Text.ElideLeft : Text.ElideRight
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
        }
    }

    Rectangle {
        id: powerContainer
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        color: Qt.rgba(0, 0, 0, 0.6)
        height: powerRowLayout.height + 20
        width: powerRowLayout.width + 20
        radius: 5
        visible: restart.visible || shutdown.visible || suspend.visible || hibernate.visible
    }

    RowLayout {
        id: powerRowLayout
        anchors.centerIn: powerContainer
        spacing: 10
        
        Simple.Button {
            id: suspend
            text: textConstants.suspend
            onClicked: sddm.suspend()
            visible: false
            KeyNavigation.backtab: session
            KeyNavigation.tab: hibernate
        }

        Simple.Button {
            id: hibernate
            text: textConstants.hibernate
            onClicked: sddm.hibernate()
            visible: false
            KeyNavigation.backtab: suspend
            KeyNavigation.tab: restart
        }
        
        Simple.Button {
            id: restart
            text: textConstants.reboot
            onClicked: sddm.reboot()
            visible: false
            KeyNavigation.backtab: suspend; KeyNavigation.tab: shutdown
        }
        
        Simple.Button {
            id: shutdown
            text: textConstants.shutdown
            onClicked: sddm.powerOff()
            visible: false
            KeyNavigation.backtab: restart; KeyNavigation.tab: user_entry
        }
    }

    Timer {
        id: timetr
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            timelb.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }
}
