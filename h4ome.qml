import QtQuick 2.6
import QtQuick 2.0

import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0
import Qt.labs.settings 1.0

import QtQuick.Dialogs 1.2
import 'services/'
import 'ui/'


import QtCanvas3D 1.0
import "noomap.js" as GLCode


ApplicationWindow {
    id: window
    title: qsTr("H⁴OME")
    visible: true

    Settings {
        id: settings
        property string style: "Universal"
    }

    header: ToolBar {
        Material.foreground: "white"

        RowLayout {
            spacing: 20
            anchors.fill: parent


            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/drawer.png"
                }
                onClicked: drawer.open()
            }

            Label {
                id: titleLabel
                text: title
                font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/menu.png"
                }
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    MenuItem {
                        text: qsTr("Load ~me.larky")
                        onTriggered: holarchy.loadHolon('me.larky')
                    }
                    MenuItem {
                        text: qsTr("Exit")
                        onTriggered: Qt.quit();
                    }
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: Math.min(window.width, window.height) / 2
        height: window.height

        ListView {
            id: listView
            currentIndex: -1
            anchors.fill: parent

            delegate: ItemDelegate {
                width: parent.width
                text: model.title
                highlighted: ListView.isCurrentItem
                onClicked: {
                    if (listView.currentIndex != index) {
                        listView.currentIndex = index
                        titleLabel.text = model.title
                        holarchy.loadHolon(model.name)
                    }
                    drawer.close()
                }
            }

            model: ListModel {
                ListElement { title: "/home/nico"; name: "me.lucksus" }
                ListElement { title: "/home/chris"; name: "me.larky" }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    Popup {
        id: messageDialog
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2

        Column {
            id: messageDialogColumn
            spacing: 20

            Label {
                text: "Holon data received!"
                font.bold: true
            }

            Label {
                id: popupLabel
                width: messageDialog.availableWidth
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }
        }

        function show(holarchy) {
            popupLabel.text = 'Got ' + holarchy.holons.length + ' holons and ' +
                    holarchy.links.length + ' links!';
            messageDialog.open();
        }
    }

    Holarchy {
        id: holarchy
        onLoaded: messageDialog.show(holarchy)
    }

    NoomapInterface {
        id: noomap_interface
        holarchy: holarchy
        anchors.fill: parent
    }

    Component.onCompleted: {
        holarchy.loadHolon('me.lucksus');
        holarchy.loaded.connect(holarchyUpdate);
    }

    function holarchyUpdate() {
        GLCode.holarchyUpdate(holarchy);
    }

    Canvas3D {
        id: canvas3d
        anchors.fill: parent

        onInitializeGL: {
            GLCode.initializeGL(canvas3d, eventSource, window);
        }
        onPaintGL: {
            GLCode.paintGL(canvas3d);
            //fpsDisplay.fps = canvas3d.fps;
        }

        onResizeGL: {
            GLCode.onResizeGL(canvas3d);
        }

        ControlEventSource {
            anchors.fill: parent
            focus: true
            id: eventSource
        }

    }

}
