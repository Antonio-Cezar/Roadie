import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    color: "black"

    // for your 800x480 device (fullscreen will override size)
    width: 800
    height: 480

    // open fullscreen
    visibility: Window.FullScreen
}
