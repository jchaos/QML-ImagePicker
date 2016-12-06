import QtQuick 2.7
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Gallery{
        id:gallery
        anchors.fill:parent
        maxDepth:2
        onSelect:{
            console.log(filePath)
        }
    }
}
