import QtQuick 2.7
import DjangoX.Gallery 1.0
import QtQuick.Controls 2.0

Rectangle{
    id: root
    anchors.fill: parent
    color: "#222"
    property int maxDepth: 2
    signal select(string filePath);

    ListModel{
        id: pathModel
    }

    ListModel{
        id: currentDirModel
    }

    Flickable {
        id:flickableDir
        width: parent.width;
        height:parent.height
        clip:true
        contentHeight: flow.height + flow.spacing * 2
        maximumFlickVelocity: 8000

        Flow{
            id:flow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: spacing
            width: parent.width - spacing * 2
            spacing: 10
            Repeater{
                model: pathModel
                Rectangle{
                    id: pathRect
                    width: (root.width - 4 * flow.spacing) / 3
                    height: width
                    clip: true

                    MouseArea{
                        anchors.fill: parent
                        onReleased: {
                            flickableDir.visible = false
                            flickableFile.visible = true
                            returnToDirButton.visible = true
                            galleryManager.scanImageByPath(path);
                        }
                    }
                    Image{
                        id: pathCover
                        source: "file:///"+cover
                        width: parent.width
                        height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        onStatusChanged: {
                            if(status == Image.Error)
                            {
                                pathModel.remove(index)
                            }

                        }
                    }
                    Rectangle{
                        id:mask
                        anchors.bottom: parent.bottom
                        color:"#444"
                        width:parent.width
                        height:pathName.height
                        opacity: 0.8

                        Text{
                            id: pathName
                            anchors.right: parent.right
                            anchors.rightMargin: flow.spacing
                            elide: Text.ElideLeft
                            width: parent.width - 2*flow.spacing
                            text: path
                            color: "white"
                            lineHeight: 1.5
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    Flickable {
        id:flickableFile
        width: parent.width;
        height:parent.height - returnToDirButton.height
        clip:true
        contentHeight: fileflow.height + fileflow.spacing * 2
        maximumFlickVelocity: 8000
        visible:false
        Flow{
            id:fileflow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: spacing
            width: parent.width - spacing * 2
            spacing: 10
            Repeater{
                model: currentDirModel
                Rectangle{
                    id: fileRect
                    width: (root.width - 4 * fileflow.spacing) / 3
                    height: width
                    clip: true
                    Image{
                        id: img
                        source: "file:///"+path
                        width: parent.width
                        height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        onStatusChanged: {
                            if(status == Image.Error)
                            {
                                currentDirModel.remove(index)
                            }
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        onReleased: {
                            root.select(path);
                        }
                    }
                }
            }
            add: Transition {
                SequentialAnimation {
                    NumberAnimation {
                        properties: "scale";
                        from: 0.6
                        to:1
                        duration: 100;
                        easing.type:Easing.OutBack
                    }
                }
            }
        }
    }

    Button{
        id:returnToDirButton
        text:"return"
        visible:false
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: {
            flickableDir.visible = true
            flickableFile.visible = false
            returnToDirButton.visible = false
            currentDirModel.clear()
        }
    }

    GalleryManager {
        id: galleryManager

        Component.onCompleted: {
            galleryManager.scanPathAndCover(galleryManager.getGalleryRootPath(), maxDepth);
        }

        onGetOneDir: {
            pathModel.append({"path":path, "cover":cover})
        }

        onGetOneImage: {
            currentDirModel.append({"path":path, "fileName":fileName})
        }
    }
}

