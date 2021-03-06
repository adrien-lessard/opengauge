import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQml 2.11
import QtMultimedia 5.8

import "Theme.js" as Theme;

Window {

    signal checkErrorCodes()
    signal clearErrorCodes()
    signal checkForUpdates()
    signal killApplication()

    id: window
    visible: true
    width: 800
    height: 480
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width
    visibility: Window.FullScreen

    function notifyUI(text) {
        notificationRectangle.notify(text)
    }

    Shortcut {
        sequence: "Escape"
        onActivated: visibility = Window.Windowed
    }

    color: Theme.bgColor
    title: qsTr("Dashboard")

    Image {
        id: splashScreenImage
        x: 0
        y: 0
        z: 100
        opacity: 1
        source: "../img/fire.svg"

        Timer {
            interval: 4000;
            running: true;
            repeat: false;
            onTriggered: splashScreenFadeOutImage.running = true
        }

        OpacityAnimator {
            id: splashScreenFadeOutImage
            target: splashScreenImage
            from: 1;
            to: 0;
            duration: 500
            running: false
            easing.type: Easing.InCubic
        }
    }

    Rectangle {
        id: notificationRectangle
	    width: 200
	    height: 40
	    x: 50
	    y: 360
	    z: 30
	    radius: 20
	    color: '#222222'
        opacity: 0

        function notify(text) {
            opacity = 1
            notificationText.text = text
            notificationTimer.restart()
        }

	    Text {
            id: notificationText
	        anchors.fill: parent
	        text: 'Allo'
	        color: Theme.txColor
	        verticalAlignment: Text.AlignVCenter
	        horizontalAlignment: Text.AlignHCenter
	    }

        Timer {
            id: notificationTimer
            interval: 5000
            running: false
            repeat: false
            onTriggered: notificationRectangle.opacity = 0
        }
    }

    Rectangle {
        id: over9000
        x: 0
        y: 0
        z: 50
        width: window.width
        height: window.height
        property int speedLimit: 120
        property real arg
        opacity: applicationData.speed > speedLimit ? Math.sin(arg) / 2 : 0
        color: "#FF0000"

        NumberAnimation on arg {
            from: 0
            to: Math.PI*2
            duration: 1000
            loops: Animation.Infinite
            running: applicationData.speed > over9000.speedLimit
        }
    }

    Column {
        id: column
        width: 300
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        Text {
            id: speed
            height: 120
            color: Theme.txColor
            text: applicationData.speed
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
            anchors.left: parent.left
            font.pixelSize: 72
        }

        CircularGauge {
            id: rpm
            height: 240
            stepSize: 0
            value: applicationData.rpm / 1000
            maximumValue: 6
            anchors.right: parent.right
            anchors.left: parent.left
            
            Behavior on value{
                NumberAnimation { duration: 230; easing.type: Easing.Linear }
            }

            style: CircularGaugeStyle {
                tickmarkStepSize: 1
            }
        }

        Text {

            function airFlowToConsumption(speed)
            {
                var liter_per_hour_flow = applicationData.airFlow * 3600.0 / (17.4 * 730.0)
                if(speed > 10)
                    return (liter_per_hour_flow * 100.0 / speed).toFixed(2) + " L/100km"
                else
                    return liter_per_hour_flow.toFixed(2) + " L/h"
            }

            id: cons
            height: 120
            color: Theme.txColor
            text: airFlowToConsumption(applicationData.speed)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
            anchors.left: parent.left
            font.pixelSize: 36
        }

    }

    Item {
        id: rightSectionContainer
        x: 300
        y: 0
        width: 500
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        Text {
            id: timeDisplay
            x: 0
            y: 0
            width: parent.width
            height: 40
            color: Theme.txColor
            font.pixelSize: 24
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            function updateTime() {
                text = Qt.formatTime(new Date(),"HH:mm")
            }

            Component.onCompleted: {
                updateTime()
            }

            Timer {
                id: timeUpdateTimer
                interval: 60000;
                running: true;
                repeat: true;
                onTriggered: timeDisplay.updateTime()
            }
        }

        TabBar {
            id: tabBar
            currentIndex: 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            TabButton {
                id: music
                text: qsTr("Music")
            }

            TabButton {
                id: nav
                text: qsTr("Nav")
            }

            TabButton {
                id: trip
                text: qsTr("Trip")
            }

            TabButton {
                id: carstatus
                text: "Status"
            }
        }

        StackLayout {
            id: stackLayout
            x: 0
            y: 40
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.bottomMargin: 40
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            currentIndex: tabBar.currentIndex

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Music {
                    id: musicPage
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Nav {
                    id: navPage
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Trip { 
                    id: tripPage
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Status {
                    id: statusPage
                }
            }
        }
    }
}
