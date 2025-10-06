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

            // Main panel (forward warning)
            ForwardWarningPanel {
                id: fwdPanel
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height - infoRow.height - leftCol.spacing
                borderWidth: 2
                borderColor: "white"
                radius: 0
                // Later from Python/QML: fwdPanel.mode = "warning" / "error" / etc.
            }

            // Bottom info tiles (data-driven)
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

        // RIGHT: sidebar
        Column {
            id: sideBar
            spacing: 10
            width: 170
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            RectButton {
                id: wifiBtn
                text: "(BUTTON)\nWifi Connection"
                width: parent.width
                height: 90
                onClicked: console.log("wifiBtn clicked")
            }

            // Small spacer
            Item { width: 0.5; height: 0.5 }

            RoundButton {
                id: registerBtn
                text: "(BUTTON)\nRegister to service"
                size: parent.width
                onClicked: console.log("register clicked")
            }

            RoundButton {
                id: menuBtn
                text: "(BUTTON)\nMenu"
                size: parent.width
                onClicked: console.log("menu clicked")
            }
        }
    }

    // ================== Components ==================

    // Forward warning panel: switchable "cases" via `mode`
    component ForwardWarningPanel: Rectangle {
        id: panel
        property string mode: "idle"   // "idle" | "warning" | "error" | add more later
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

    // Rectangular button
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

    // Round button
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

    // Info tile
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
