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

            // Bottom info tiles
            Row {
                id: infoRow
                spacing: 10
                anchors.left: parent.left
                anchors.right: parent.right
                height: 130

                ListModel {
                    id: infoModel
                    ListElement { title: "Google Maps\nSpeed"; value: "Disconnected" }
                    ListElement { title: "AI CAM Detection\nSpeed"; value: "Disconnected" }
                    ListElement { title: "Service connection"; value: "Disconnected" }
                    ListElement { title: "Service connection"; value: "Disconnected" }
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
            id: wifiBtn
            text: wifi.connected ? "Wifi: " + wifi.connectedSsid : "Wifi: Disconnected"
            width: parent.width
            height: 90
            onClicked: {
                wifiPopup.open()
                wifi.scan()
            }
        }


            Item { height: 5 }

            RoundButton {
                text: "Register to \nservice"
                size: parent.width
                onClicked: regPopup.open()
            }

            RoundButton {
                text: "Menu"
                size: parent.width
                onClicked: menuPopup.open()
            }
        }
    }

    // ================= POPUP WIFI =================
        Popup {
        id: wifiPopup
        modal: true
        focus: true
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: 640
        height: 380
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            anchors.fill: parent
            color: "black"
            radius: 12
            border.color: "white"
            border.width: 2
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Header with refresh + current status
            Row {
                width: parent.width
                spacing: 10
                Text {
                    text: wifi.connected ? "Connected: " + wifi.connectedSsid : "Not connected"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    width: parent.width - refreshBtn.implicitWidth - 20
                }
                RectButton {
                    id: refreshBtn
                    text: "Rescan"
                    implicitWidth: 110
                    implicitHeight: 38
                    onClicked: wifi.scan()
                }
            }

            // Networks list
            ListView {
                id: list
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height - 110
                clip: true
                spacing: 6
                model: wifi.networks   // list<dict> from Python

                delegate: Rectangle {
                    width: list.width
                    height: 52
                    radius: 8
                    color: "transparent"
                    border.color: "white"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // SSID + lock icon
                        Text {
                            text: (ssid.length ? ssid : "(hidden)") + (locked ? "  🔒" : "")
                            color: "white"
                            font.pixelSize: 16
                            elide: Text.ElideRight
                            width: list.width * 0.55
                        }

                        // Signal bars
                        Rectangle {
                            width: 100; height: 8; radius: 4
                            border.color: "white"; color: "transparent"
                            Row {
                                anchors.fill: parent; anchors.margins: 2; spacing: 4
                                Repeater {
                                    model: 5
                                    delegate: Rectangle {
                                        width: (parent.width - 4*4)/5
                                        height: parent.height
                                        color: index < Math.round(signal/20) ? "white" : "#555"
                                        radius: 2
                                    }
                                }
                            }
                        }

                        Item { width: 10; height: 1 }

                        // Connect / Disconnect button
                        RectButton {
                            id: actionBtn
                            text: wifi.connected && wifi.connectedSsid === ssid ? "Disconnect" : "Connect"
                            implicitWidth: 120
                            implicitHeight: 38
                            onClicked: {
                                if (wifi.connected && wifi.connectedSsid === ssid) {
                                    wifi.disconnect(ssid)
                                } else {
                                    if (locked) {
                                        passSsid.text = ssid
                                        passField.text = ""
                                        passDialog.open()
                                    } else {
                                        wifi.connect(ssid, "")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Footer: Close
            Row {
                width: parent.width
                spacing: 10
                RectButton {
                    text: "Close"
                    width: 120
                    height: 40
                    onClicked: wifiPopup.close()
                }
            }
        }
    }

    // Password prompt
    Dialog {
        id: passDialog
        modal: true
        focus: true
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: 360
        title: "Enter Wi-Fi Password"
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            anchors.fill: parent
            color: "black"
            radius: 10
            border.color: "white"; border.width: 2
        }

        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            Text {
                id: passSsid
                text: ""
                color: "white"
                font.pixelSize: 16
            }
            TextField {
                id: passField
                placeholderText: "Password"
                echoMode: TextInput.Password
                selectByMouse: true
                color: "white"
                background: Rectangle { radius: 6; color: "transparent"; border.color: "white"; border.width: 1 }
            }
        }

        footer: Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            spacing: 10
            RectButton {
                text: "Cancel"
                implicitWidth: 110; implicitHeight: 40
                onClicked: passDialog.close()
            }
            RectButton {
                text: "Connect"
                implicitWidth: 110; implicitHeight: 40
                onClicked: {
                    wifi.connect(passSsid.text, passField.text)
                    passDialog.close()
                }
            }
        }
    }


    // ================= POPUP REGISTER =================
    Popup {
        id: regPopup
        focus: true
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: 620
        height: 300
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
                    text: "Google Maps \nRoad warning"
                    size: 170
                    fontScale: 0.12     // smaller text only here
                }

                RoundButton {
                    text: "Politikontroll \nregister"
                    size: 170
                    fontScale: 0.12
                }

                RoundButton {
                    text: "Logg last 20s \nAI cam"
                    size: 170
                    fontScale: 0.12
                }
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
                    onClicked: confirmExit.open()
                }
            }
        }
    }

    // ================= CONFIRM EXIT DIALOG =================
    Dialog {
        id: confirmExit
        modal: true
        focus: true
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: 360
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        title: "Confirm exit"

        contentItem: Label {
            text: "Are you sure you want to exit?"
            wrapMode: Text.WordWrap
            padding: 16
            color: "white"
        }

        background: Rectangle {
            anchors.fill: parent
            color: "black"
            radius: 10
            border.color: "white"
            border.width: 2
        }

        footer: DialogButtonBox {
            standardButtons: DialogButtonBox.Yes | DialogButtonBox.No
            onAccepted: Qt.quit()
            onRejected: confirmExit.close()
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
                    text: "Forward warning detection \n(Disconnected)"
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

    // === UPDATED RoundButton with fontScale property ===
    component RoundButton: Rectangle {
        id: roundBtn
        property alias text: label.text
        property int size: 180
        property real fontScale: 0.15   // default text size scale
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
            font.pixelSize: Math.round(size * roundBtn.fontScale)
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
            Text { text: ""; color: "white"; opacity: 0.85; font.pixelSize: 12 }
            Text { text: title; color: "white"; wrapMode: Text.WordWrap; font.pixelSize: 12 }
            Text { text: value; color: "white"; font.pixelSize: 12 }
        }
    }
}
