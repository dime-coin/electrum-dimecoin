import QtQuick 2.6
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.1
import QtQml 2.6

import org.electrum 1.0

import "controls"

Pane {
    id: root
    objectName: 'ReceiveRequests'

    ColumnLayout {
        anchors.fill: parent

        Heading {
            text: qsTr('Receive requests')
        }

        Frame {
            background: PaneInsetBackground {}

            verticalPadding: 0
            horizontalPadding: 0
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: listview
                anchors.fill: parent
                clip: true

                model: DelegateModel {
                    id: delegateModel
                    model: Daemon.currentWallet.requestModel
                    delegate: InvoiceDelegate {
                        onClicked: {
                            // TODO: only open unpaid?
                            if (model.status == Invoice.Unpaid) {
                                app.stack.getRoot().openRequest(model.key)
                            }
                        }
                    }
                }

                add: Transition {
                    NumberAnimation { properties: 'scale'; from: 0.75; to: 1; duration: 500 }
                    NumberAnimation { properties: 'opacity'; from: 0; to: 1; duration: 500 }
                }
                addDisplaced: Transition {
                    SpringAnimation { properties: 'y'; duration: 200; spring: 5; damping: 0.5; mass: 2 }
                }

                remove: Transition {
                    NumberAnimation { properties: 'scale'; to: 0.75; duration: 300 }
                    NumberAnimation { properties: 'opacity'; to: 0; duration: 300 }
                }
                removeDisplaced: Transition {
                    SequentialAnimation {
                        PauseAnimation { duration: 200 }
                        SpringAnimation { properties: 'y'; duration: 100; spring: 5; damping: 0.5; mass: 2 }
                    }
                }

                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }
}