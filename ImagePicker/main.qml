import QtQuick 2.7
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Image Picker")

    ImagePicker{
        id:gallery
        anchors.fill:parent
        maxDepth:3
        onSelect:{
            console.log(filePath)
        }
    }
}
