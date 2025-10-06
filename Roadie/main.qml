import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    color: "black"

    width: 800
    height: 480

    visibility: Window.FullScreen
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "white"
        border.width: 4   // thickness of the border
    }
}
