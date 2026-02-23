import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtMultimedia

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

    Connections {
        target: wifi
        function onMessage(m) { console.log(m) } // or show on-screen label/snackbar
    }


    // ================= Wi-Fi POPUP =================
    Popup {
        id: wifiPopup
        modal: true
        focus: true
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: 640
        height: 380
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Component.onCompleted: wifi.scan()
        onOpened: wifi.scan()

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

            // Header with status + Rescan + Disconnect
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
                    implicitHeight: 42
                    onClicked: wifi.scan()
                }
            }

            // Empty state (shows if no networks in model)
            Item {
                id: emptyState
                width: parent.width
                height: wifiList.visible ? 0 : 60
                visible: !wifiList.visible
                Text {
                    anchors.centerIn: parent
                    text: "No networks found. Tap Rescan."
                    color: "white"
                    font.pixelSize: 16
                    opacity: 0.8
                }
            }

            // Networks list
            ListView {
                id: wifiList
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height - 110
                clip: true
                spacing: 6
                model: wifi.networks
                visible: (count > 0)

                delegate: Rectangle {
                    width: wifiList.width
                    height: 56
                    radius: 8
                    color: "transparent"
                    border.color: "white"
                    border.width: 1

                    // Access Python dict fields through modelData
                    property var n: modelData   // {ssid, rawSsid, locked, signal, security}

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: ((n.ssid && n.ssid.length) ? n.ssid : "(hidden)") + (n.locked ? "  🔒" : "")
                            color: "white"
                            font.pixelSize: 16
                            elide: Text.ElideRight
                            width: wifiList.width * 0.55
                        }

                        // Simple signal meter (0–100 -> 0–5 bars)
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
                                        color: index < Math.round((n.signal || 0)/20) ? "white" : "#555"
                                        radius: 2
                                    }
                                }
                            }
                        }

                        Item { width: 10; height: 1 }

                        RectButton {
                            id: actionBtn
                            text: (wifi.connected && wifi.connectedSsid === n.ssid) ? "Disconnect" : "Connect"
                            implicitWidth: 120
                            implicitHeight: 38
                            onClicked: {
                                if (wifi.connected && wifi.connectedSsid === n.ssid) {
                                    wifi.disconnect(n.ssid)
                                } else {
                                    if (n.locked) {
                                        passSsid.text = n.ssid && n.ssid.length ? n.ssid : n.rawSsid
                                        passField.text = ""
                                        passDialog.open()
                                    } else {
                                        wifi.connect(n.ssid, "")
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
        width: 400
        height: 200
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
                elide: Text.ElideRight
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
                anchors.fill: parent

                Camera {
                    id: camera
                    cameraDevice: (QtMultimedia.availableCameras.length > 0)
                                ? QtMultimedia.availableCameras[0]
                                : null
                    active: true
                }

                CaptureSession {
                    camera: camera
                    videoOutput: viewfinder
                }

                VideoOutput {
                    id: viewfinder
                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectCrop
                }

                // Show if Qt sees NO camera
                Text {
                    anchors.centerIn: parent
                    visible: QtMultimedia.availableCameras.length === 0
                    text: "No camera detected"
                    color: "white"
                    font.pixelSize: 30
                }

                // Slight dark overlay so white text pops
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.20
                }

                // Overlay title
                Text {
                    anchors.centerIn: parent
                    text: "Forward warning detection"
                    font.pixelSize: 26
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
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

    // ==== RectButton with press/tap animations ====
    component RectButton: Rectangle {
        id: rectBtn
        property alias text: label.text
        signal clicked

        radius: 10
        color: "transparent"
        border.color: "white"
        border.width: 2
        antialiasing: true

        // Press feedback: scale + slight fade
        property real pressedScale: 0.96
        property real normalScale: 1.0
        scale: mouse.pressed ? pressedScale : normalScale
        opacity: mouse.pressed ? 0.9 : 1.0

        // Smooth animation of scale/opacity
        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

        // Tap pulse overlay (brief flash)
        Rectangle {
            id: tapPulse
            anchors.fill: parent
            radius: rectBtn.radius
            color: "white"
            opacity: 0.0
        }

        // Triggered on click: quick flash + spring back (if needed)
        SequentialAnimation {
            id: tapAnim
            running: false
            PropertyAnimation { target: tapPulse; property: "opacity"; from: 0.0; to: 0.18; duration: 70; easing.type: Easing.OutQuad }
            PropertyAnimation { target: tapPulse; property: "opacity"; to: 0.0; duration: 120; easing.type: Easing.InQuad }
        }

        Text {
            id: label
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            color: "white"
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            onClicked: {
                tapAnim.restart()
                rectBtn.clicked()
            }
        }
    }


    // ==== RoundButton with press/tap animations ====
    component RoundButton: Rectangle {
        id: roundBtn
        property alias text: label.text
        property int size: 180
        property real fontScale: 0.15
        signal clicked

        width: size
        height: size
        radius: size / 2
        color: "transparent"
        border.color: "white"
        border.width: 2
        antialiasing: true

        // Press feedback: scale + slight fade
        property real pressedScale: 0.96
        property real normalScale: 1.0
        scale: mouse.pressed ? pressedScale : normalScale
        opacity: mouse.pressed ? 0.9 : 1.0

        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

        // Tap pulse overlay as a ring
        Rectangle {
            id: pulse
            anchors.centerIn: parent
            width: roundBtn.width
            height: roundBtn.height
            radius: width / 2
            border.width: 2
            border.color: "white"
            color: "transparent"
            opacity: 0.0
        }
        SequentialAnimation {
            id: ripple
            running: false
            ParallelAnimation {
                PropertyAnimation { target: pulse; property: "opacity"; from: 0.3; to: 0.0; duration: 160; easing.type: Easing.OutQuad }
                PropertyAnimation { target: pulse; property: "scale"; from: 0.92; to: 1.08; duration: 160; easing.type: Easing.OutQuad }
            }
            onStopped: pulse.scale = 1.0
        }

        Text {
            id: label
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            font.pixelSize: Math.round(size * roundBtn.fontScale)
            color: "white"
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            onClicked: {
                ripple.restart()
                roundBtn.clicked()
            }
        }
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
