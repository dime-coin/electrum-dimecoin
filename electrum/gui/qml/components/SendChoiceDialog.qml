import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import org.electrum 1.0

import "controls"

ElDialog {
    id: dialog

    signal scanQrClicked
    signal manualEntryClicked

    title: qsTr('Send Dimecoins')
    iconSource: Qt.resolvedUrl('../../icons/tab_send.png')

    padding: 0

    // Center the dialog
    anchors.centerIn: parent

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.topMargin: constants.paddingLarge
            Layout.leftMargin: constants.paddingLarge
            Layout.rightMargin: constants.paddingLarge
            text: qsTr('Choose how you want to send:')
            font.pixelSize: constants.fontSizeLarge
            color: Material.foreground
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            Layout.fillHeight: true
        }

        ButtonContainer {
            Layout.fillWidth: true

            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr('Scan QR Code')
                icon.source: '../../icons/camera.png'
                onClicked: {
                    dialog.close()
                    scanQrClicked()
                }
            }
            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr('Manual Entry')
                // Removed icon to make it text-only
                onClicked: {
                    dialog.close()
                    manualEntryClicked()
                }
            }
        }
    }
} 