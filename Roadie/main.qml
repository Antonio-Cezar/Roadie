import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

ApplicationWindow {
    visible: true
    width: 1200
    height: 700
    title: "Roadie"
    color: "#0a0c11"
    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    RowLayout {
        anchors.fill: parent
        spacing: 16
        padding: 16

        // LEFT: main panel + bottom info tiles
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            // Main detection/video panel
            Rectangle {
                id: detection
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: "#131722"

                layer.enabled: true
                layer.effect: DropShadow { radius: 18; samples: 32; horizontalOffset: 0; verticalOffset: 8; color: "#80000000" }

                Label {
                    anchors.centerIn: parent
                    text: "Forward warning detection"
                    font.pixelSize: 28
                    color: "white"
                    font.bold: true
                }
            }

            // Info tiles row
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                spacing: 16

                function tile(title, value) {
                    return Qt.createComponent("InfoTile.qml").createObject(this, { t: title, v: value });
                }

                Component.onCompleted: {
                    addItem(tile("Google Maps\nSpeed limit", "--"));
                    addItem(tile("AI CAM Detection\nSpeed limit", "--"));
                    addItem(tile("Service connection", "Disconnected"));
                    addItem(tile("Service connection info", "—"));
                }
            }
        }

        // RIGHT: sidebar buttons
        ColumnLayout {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            spacing: 16

            RectButton { text: "(BUTTON)\nWifi Connection" }

            RoundAction { text: "(BUTTON)\nRegister to service" }
            RoundAction { text: "(BUTTON)\nMenu" }
        }
    }
}

// Reusable components
// RectButton
Component {
    id: rectButtonComp
}
pragma ComponentBehavior: Bound

// Rectangular raised button
// file-scoped to keep single-file; convert to separate .qml files if you prefer
Control {
    id: rectButton
    property alias text: label.text
    implicitHeight: 64
    background: Rectangle {
        radius: 12
        color: "#1b2030"
        border.color: "#2a3147"
        layer.enabled: true
        layer.effect: DropShadow { radius: 12; samples: 24; horizontalOffset: 0; verticalOffset: 6; color: "#60000000" }
    }
    contentItem: Label {
        id: label
        text: "(BUTTON)"
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font.bold: true
    }
}
component RectButton: rectButton

// Circular action button
component RoundAction: Control {
    implicitWidth: 260
    implicitHeight: 260
    background: Rectangle {
        radius: width / 2
        color: "#1b2030"
        border.color: "#2a3147"
        layer.enabled: true
        layer.effect: DropShadow { radius: 16; samples: 32; horizontalOffset: 0; verticalOffset: 8; color: "#60000000" }
    }
    contentItem: Label {
        text: "(BUTTON)"
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font.bold: true
    }
}

// Info card (inline component)
component InfoTile: Rectangle {
    property string t: ""
    property string v: ""
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 12
    color: "#111522"
    border.color: "#2a3147"
    layer.enabled: true
    layer.effect: DropShadow { radius: 12; samples: 24; horizontalOffset: 0; verticalOffset: 6; color: "#60000000" }

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4
        Label { text: "(INFO)"; color: "#ffffff"; opacity: 0.9; font.pixelSize: 12 }
        Label { text: t; color: "white"; opacity: 0.9; wrapMode: Text.WordWrap; font.pixelSize: 12 }
        Label { text: v; color: "white"; opacity: 0.9; font.pixelSize: 12 }
    }
}
