import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQml 2.11
import QtMultimedia 5.8
import Qt.labs.settings 1.0

ScrollView {
    id: statusScroll
    objectName: "StatusPage"
    clip: true
    anchors.fill: parent

    Column {
        id: statusColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10
        padding: 10

        Button {
            id: stopButton
            text: qsTr("STOP")
            visible: true
            anchors.horizontalCenter: parent.horizontalCenter
            
            onClicked: {
                killApplication()
            }
        }

        Column {
            id: canCheckCodes
            width: 500 - 2*parent.padding
            visible: speed.text == 0
            spacing: parent.spacing
            
            Button {
                id: checkForUpdatesButton
                text: qsTr("Check for updates")
                visible: true
                anchors.horizontalCenter: parent.horizontalCenter
                
                onClicked: {
                    checkForUpdates()
                }
            }

            Button {
                id: checkErrorCodeButton
                text: qsTr("Check for error codes")
                visible: true
                anchors.horizontalCenter: parent.horizontalCenter
                
                onClicked: {
                    checkErrorCodes()
                }
            }

            Text {
                id: errorCodeResponseText
                color: "#c4c4c4"
                text: qsTr("Check engine is ON\nError code(s):\n\nC1600")
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: 12
                visible: false
            }

            Button {
                id: clearErrorCodesButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Clear error codes")
                visible: false

                onClicked: {
                    messageDialog.open()
                }
            }
            
            MessageDialog {
                id: messageDialog
                title: "Confirm error code removal"
                text: "If you erase the error codes, you will not be able to query them anymore. Confirm removal?"
                standardButtons: StandardButton.Yes | StandardButton.No
                onYes: {
                    clearErrorCodes()
                }
            }
        }

        AllPIDs { }
    }
}
