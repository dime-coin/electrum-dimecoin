import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Pane {
    objectName: 'About'

    property string title: qsTr("About Electrum-Dime")

    Flickable {
        anchors.fill: parent
        contentHeight: rootLayout.height
        interactive: height < contentHeight

        GridLayout {
            id: rootLayout
            columns: 2
            width: parent.width

            Item {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.width * 3/4 // reduce height, empty space in png

                Image {
                    id: electrum_logo
                    width: parent.width
                    height: width
                    source: '../../icons/electrum_presplash.png'
                }
            }

            Label {
                text: qsTr('Version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.electrum_version
            }
            Label {
                text: qsTr('Protocol version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.protocol_version
            }
            Label {
                text: qsTr('Qt Version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.qt_version
            }
            Label {
                text: qsTr('PyQt Version')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: BUILD.pyqt_version
            }
            Label {
                text: qsTr('License')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: qsTr('MIT License')
            }
            Label {
                text: qsTr('Homepage')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: qsTr('<a href="https://dimecoinnetwork.com">https://dimecoinnetwork.com</a>')
                textFormat: Text.RichText
                onLinkActivated: Qt.openUrlExternally(link)
            }
                        Label {
                text: qsTr('Documentation')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: qsTr('<a href="https://electrum-docs.dimecoinnetwork.com">Read-the-Docs</a>')
                textFormat: Text.RichText
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Item {
                width: 1
                height: constants.paddingXLarge
                Layout.columnSpan: 2
            }
            Label {
                text: qsTr('Developers')
                Layout.alignment: Qt.AlignRight
            }
            Label {
                text: 'Douglas `Dhop14` Hopping\nSean `Dalamar` Cusack\nJames `Barrystyle` Taylor'
            }
            Item {
                width: 1
                height: constants.paddingXLarge
                Layout.columnSpan: 2
            }
            Label {
                text: qsTr('Distributed by Dimecoin Developers')
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

}
