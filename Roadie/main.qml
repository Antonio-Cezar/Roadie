import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 480
    visibility: Window.FullScreen

    // Dim background when a modal popup is open
    Overlay.modal: Rectangle {
        anchors.fill: parent
        color: "#000000"        
        opacity: 1.0              
        z: 9999                    
        visible: true

        Behavior on visible {
            SequentialAnimation {
                NumberAnimation { target: parent; property: "opacity"; from: 0; to: 0.9; duration: 200 }
                }   
            }
        }


    // === Background ===
    Rectangle {
        id: background
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0A1A3F" }
            GradientStop { position: 0.5; color: "#852d0bff" }
            GradientStop { position: 1.0; color: "#0A0F1F" }
        }
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.25)
        }
    }

    // === MAIN ===
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
                height: parent.height - infoRow.height - leftCol.spacing - 5
                borderWidth: 2
                borderColor: "white"
            }

            // Bottom info tiles (data-driven)
            Row {
                id: infoRow
                spacing: 10
                anchors.left: parent.left
                anchors.right: parent.right
                height: 130

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

        // RIGHT: sidebar
        Column {
            id: sideBar
            spacing: 10
            width: 170
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            RectButton {
                text: "Wifi Connection"
                width: parent.width
                height: 90
            }

            Item { height: 5 }

            RoundButton {
                text: "Register to \nservice"
                size: parent.width
            }

            RoundButton {
                text: "Menu"
                size: parent.width
                onClicked: menuPopup.open()
            }
        }
    }

    // ================= POPUP MENU =================
    Popup {
        id: menuPopup
        modal: true
        focus: true
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: 550
        height: 250
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            anchors.fill: parent
            color: "black"
            radius: 10
            border.color: "white"
            border.width: 3
        }

        contentItem: Item {
            anchors.fill: parent

            Row {
                anchors.centerIn: parent
                spacing: 30

                RoundButton {
                    text: "Option 1"
                    size: 150
                    onClicked: console.log("Option 1 clicked")
                }

                RoundButton {
                    text: "Option 2"
                    size: 150
                    onClicked: console.log("Option 2 clicked")
                }

                RoundButton {
                    text: "Exit"
                    size: 150
                    onClicked: Qt.quit()
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
            font.pixelSize: size * 0.15
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
