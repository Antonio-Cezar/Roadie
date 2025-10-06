import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    color: "black"
    width: 800
    height: 480
    visibility: Window.FullScreen

    Row {
        id: mainRow
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // LEFT: main panel + info tiles
        Column {
            id: leftCol
            spacing: 10
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width - sideBar.width - mainRow.spacing

            ForwardWarningPanel {
                id: fwdPanel
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height - infoRow.height - leftCol.spacing
                borderWidth: 2
                borderColor: "white"
                radius: 0
            }

            // Info tiles
            Row {
                id: infoRow
                spacing: 10
                anchors.left: parent.left
                anchors.right: parent.right
                height: 90

                ListModel {
                    id: infoModel
                    ListElement { title: "Google Maps\nSpeed limit"; value: "--" }
                    ListElement { title: "AI CAM Detection\nSpeed limit"; value: "--" }
                    ListElement { title: "Service connection"; value: "Disconnected" }
                    ListElement { title: "Service connection info"; value: "—" }
                }

                Repeater {
                    model: infoModel
                    delegate: InfoTile {
                        width: (infoRow.width - (infoModel.count - 1) * infoRow.spacing) / infoModel.count
                        height: infoRow.height
                        title: model.title
                        value: model.value
                    }
                }
            }
        }

        // RIGHT SIDEBAR
        Column {
            id: sideBar
            spacing: 10
            width: 170
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            RectButton {
                text: "(BUTTON)\nWifi Connection"
                width: parent.width
                height: 90
            }

            Item { width: 0.5; height: 0.5 }

            RoundButton {
                text: "(BUTTON)\nRegister to service"
                size: parent.width
            }

            RoundButton {
                text: "(BUTTON)\nMenu"
                size: parent.width
                onClicked: {
                    console.log("Menu opened")
                    menuPopup.open()
                }
            }
        }
    }

    // ================= POPUP MENU =================
    Window {
        id: menuPopup
        width: 500
        height: 180
        color: "black"
        flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        modality: Qt.ApplicationModal
        visible: false
        title: "Menu"

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "white"
            border.width: 3
            radius: 10
        }

        Row {
            anchors.centerIn: parent
            spacing: 30

            RoundButton {
                text: "Option 1"
                size: 100
                onClicked: console.log("Option 1 clicked")
            }

            RoundButton {
                text: "Option 2"
                size: 100
                onClicked: console.log("Option 2 clicked")
            }

            RoundButton {
                text: "Exit"
                size: 100
                onClicked: {
                    console.log("Exit clicked")
                    Qt.quit()  // ✅ closes entire app
                }
            }
        }
    }

    // ================= COMPONENTS =================
    component ForwardWarningPanel: Rectangle {
        id: panel
        property string mode: "idle"
        property color borderColor: "white"
        property int borderWidth: 2
        radius: 0
        color: "transparent"
        border.color: borderColor
        border.width: borderWidth

        Loader {
            anchors.fill: parent
            sourceComponent: mode === "warning" ? warningCase
                             : mode === "error"  ? errorCase
                             : idleCase
        }

        Component {
            id: idleCase
            Item {
                Text {
                    anchors.centerIn: parent
                    text: "Forward warning detection"
                    font.pixelSize: 26
                    font.bold: true
                    color: "white"
                }
            }
        }

        Component {
            id: warningCase
            Item {
                Rectangle { anchors.fill: parent; color: "transparent"; border.color: "white"; border.width: 2 }
                Text {
                    anchors.centerIn: parent
                    text: "WARNING\nObject ahead"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 28
                    font.bold: true
                    color: "white"
                }
            }
        }

        Component {
            id: errorCase
            Item {
                Text {
                    anchors.centerIn: parent
                    text: "ERROR\n(no camera / no data)"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 22
                    font.bold: true
                    color: "white"
                }
            }
        }
    }

    component RectButton: Rectangle {
        id: rectBtn
        property alias text: label.text
        signal clicked
        radius: 6
        color: "transparent"
        border.color: "white"
        border.width: 2

        Text {
            id: label
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            color: "white"
        }

        MouseArea { anchors.fill: parent; onClicked: rectBtn.clicked() }
    }

    component RoundButton: Rectangle {
        id: roundBtn
        property alias text: label.text
        property int size: 180
        signal clicked

        width: size
        height: size
        radius: size / 2
        color: "transparent"
        border.color: "white"
        border.width: 2

        Text {
            id: label
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            color: "white"
        }

        MouseArea { anchors.fill: parent; onClicked: roundBtn.clicked() }
    }

    component InfoTile: Rectangle {
        id: tile
        property string title: ""
        property string value: ""
        color: "transparent"
        radius: 6
        border.color: "white"
        border.width: 2

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4
            Text { text: "(INFO)"; color: "white"; opacity: 0.85; font.pixelSize: 12 }
            Text { text: title; color: "white"; wrapMode: Text.WordWrap; font.pixelSize: 12 }
            Text { text: value; color: "white"; font.pixelSize: 12 }
        }
    }
}
