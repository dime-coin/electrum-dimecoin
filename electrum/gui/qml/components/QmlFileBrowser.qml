import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.electrum 1.0

import "controls"

ElDialog {
    id: fileBrowser
    title: qsTr('QML File Browser - Visual Preview')
    width: parent.width * 0.9
    height: parent.height * 0.8
    anchors.centerIn: parent

    property string currentFile: ""
    property var fileList: []
    
    // Create a dummy invoice parser for previews
    property var invoiceParser: Qt.createQmlObject('import org.electrum 1.0; InvoiceParser {}', fileBrowser)

    signal closed()

    Component.onCompleted: {
        loadFileList()
    }

    function loadFileList() {
        // List of QML files in the components directory
        fileList = [
            "WalletMainView.qml",
            "InvoiceDialog.qml", 
            "AndroidSendDialog.qml",
            "SendChoiceDialog.qml",
            "ConfirmPaymentDialog.qml",
            "MessageDialog.qml",
            "ElDialog.qml",
            "main.qml"
        ]
    }

    function previewQmlFile(filename) {
        console.log("Previewing QML file:", filename)
        currentFile = filename
        
        // Clear previous preview
        previewContainer.children = []
        
        try {
            // Get appropriate properties for the QML file
            var previewProperties = getPreviewProperties(filename)
            
            // Create a preview of the QML file
            var component = Qt.createComponent(filename)
            if (component.status === Component.Ready) {
                var preview = component.createObject(previewContainer, previewProperties)
                if (preview) {
                    console.log("Successfully created preview for:", filename)
                } else {
                    console.log("Failed to create preview object for:", filename)
                    showError("Failed to create preview for " + filename)
                }
            } else {
                console.log("Component not ready for:", filename, "Error:", component.errorString())
                showError("Component not ready: " + component.errorString())
            }
        } catch (e) {
            console.log("Error creating preview:", e)
            showError("Error: " + e)
        }
    }

    function getPreviewProperties(filename) {
        var properties = {
            "width": previewContainer.width,
            "height": previewContainer.height,
            "visible": true
        }
        
        switch (filename) {
            case "InvoiceDialog.qml":
                properties = {
                    "invoice": invoiceParser,
                    "payImmediately": false,
                    "width": previewContainer.width,
                    "height": previewContainer.height,
                    "visible": true
                }
                break
                
            case "AndroidSendDialog.qml":
                properties = {
                    "invoiceParser": invoiceParser,
                    "width": previewContainer.width,
                    "height": previewContainer.height,
                    "visible": true
                }
                break
                
            case "SendChoiceDialog.qml":
                properties = {
                    "width": previewContainer.width * 0.8,
                    "height": previewContainer.height * 0.6,
                    "anchors.centerIn": previewContainer,
                    "visible": true
                }
                break
                
            case "ConfirmPaymentDialog.qml":
                properties = {
                    "address": "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
                    "satoshis": 100000,
                    "width": previewContainer.width,
                    "height": previewContainer.height,
                    "visible": true
                }
                break
                
            case "MessageDialog.qml":
                properties = {
                    "title": "Test Message",
                    "text": "This is a test message for preview",
                    "width": previewContainer.width,
                    "height": previewContainer.height,
                    "visible": true
                }
                break
                
            case "ElDialog.qml":
                properties = {
                    "title": "Test Dialog",
                    "width": previewContainer.width,
                    "height": previewContainer.height,
                    "visible": true
                }
                break
                
            default:
                properties = {
                    "width": previewContainer.width,
                    "height": previewContainer.height,
                    "visible": true
                }
                break
        }
        
        return properties
    }

    function showError(message) {
        var errorText = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Text { text: "' + message + '"; color: "red"; anchors.centerIn: parent; font.pixelSize: 14; }', previewContainer)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // File list
        ListView {
            id: fileListView
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.2
            model: fileList
            clip: true

            delegate: Rectangle {
                width: fileListView.width
                height: 50
                color: fileListView.currentIndex === index ? "#e0e0e0" : "transparent"
                
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData
                    font.pixelSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        fileListView.currentIndex = index
                        currentFile = modelData
                        previewQmlFile(modelData)
                    }
                }
            }
        }

        // Preview area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"
            border.color: "#ccc"
            border.width: 1
            radius: 4

            // Preview content
            Item {
                id: previewContainer
                anchors.fill: parent
                anchors.margins: 10

                // Default preview message
                Text {
                    id: previewText
                    anchors.centerIn: parent
                    text: qsTr("Select a QML file from the list above to preview")
                    color: "#666"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    visible: currentFile === ""
                }
            }
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            FlatButton {
                text: qsTr("Refresh Preview")
                onClicked: {
                    if (currentFile !== "") {
                        previewQmlFile(currentFile)
                    }
                }
            }

            Item { Layout.fillWidth: true }

            FlatButton {
                text: qsTr("Close")
                onClicked: {
                    closed()
                }
            }
        }
    }
} 