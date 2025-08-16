import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import org.electrum 1.0

import "controls"

ElDialog {
    id: dialog

    signal doPay(address: string, amount: string, message: string)

    title: qsTr('Send Dimecoins')
    iconSource: Qt.resolvedUrl('../../icons/tab_send.png')

    padding: 0
    
    // Center the dialog
    anchors.centerIn: parent
    width: parent.width * 0.9
    height: parent.height * 0.8

    // Add some debugging
    Component.onCompleted: {
        console.log("AndroidSendDialog component completed")
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.topMargin: constants.paddingLarge
            text: qsTr('Enter Payment Details')
            font.pixelSize: constants.fontSizeLarge
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            id: recipientField
            Layout.fillWidth: true
            Layout.leftMargin: constants.paddingLarge
            Layout.rightMargin: constants.paddingLarge
            placeholderText: qsTr('Enter address')
            font.family: FixedFont
            onTextChanged: {
                // Clear status when user types
                statusLabel.text = ""
                
                // Basic address validation
                if (text && text.length > 0) {
                    // Check for common address patterns
                    var isValid = false
                    
                    // Check for common prefixes
                    var validPrefixes = ['1', '3', 'bc1', 'tb1', '7'] // Including Dimecoin prefix
                    isValid = validPrefixes.some(function(prefix) {
                        return text.startsWith(prefix)
                    })
                    
                    // Additional checks for address format
                    if (!isValid) {
                        // Check if it looks like a base58 address (alphanumeric, reasonable length)
                        var base58Pattern = /^[1-9A-HJ-NP-Za-km-z]{26,35}$/
                        isValid = base58Pattern.test(text)
                    }
                    
                    if (!isValid) {
                        statusLabel.text = qsTr("Address format may be invalid")
                        statusLabel.color = Material.color(Material.Orange)
                    }
                    // Only show error messages, not success messages
                }
            }
        }

        TextField {
            id: amountField
            Layout.fillWidth: true
            Layout.leftMargin: constants.paddingLarge
            Layout.rightMargin: constants.paddingLarge
            placeholderText: qsTr('Enter amount')
            font.family: FixedFont
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegularExpressionValidator {
                regularExpression: Config.btcAmountRegex
            }
        }

        TextField {
            id: messageField
            Layout.fillWidth: true
            Layout.leftMargin: constants.paddingLarge
            Layout.rightMargin: constants.paddingLarge
            placeholderText: qsTr('Enter description (optional)')
        }

        // Status display
        Label {
            id: statusLabel
            Layout.fillWidth: true
            Layout.leftMargin: constants.paddingLarge
            Layout.rightMargin: constants.paddingLarge
            Layout.topMargin: constants.paddingMedium
            visible: text !== ""
            color: Material.accentColor
            font.pixelSize: constants.fontSizeMedium
        }

        ButtonContainer {
            Layout.fillWidth: true

            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr('Cancel')
                onClicked: dialog.close()
            }
            FlatButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr('Send')
                enabled: recipientField.text && amountField.text
                onClicked: {
                    console.log("Send button clicked")
                    console.log("Address:", recipientField.text)
                    console.log("Amount:", amountField.text)
                    console.log("Message:", messageField.text)
                    
                    // Validate the data
                    if (recipientField.text && amountField.text) {
                        // Emit the doPay signal with the form data
                        doPay(recipientField.text, amountField.text, messageField.text)
                        console.log("doPay signal emitted")
                    } else {
                        statusLabel.text = qsTr("Please fill in all required fields")
                    }
                }
            }
        }
    }
} 