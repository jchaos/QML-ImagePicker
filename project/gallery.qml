import QtQuick 2.7
import DjangoX.Gallery 1.0
import QtQuick.Controls 2.0

Item{
    id: root
    anchors.fill: parent
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
                    width: (root.width - 5 * flow.spacing) / 4
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
                    }
                    Rectangle{
                        id:mask
                        anchors.bottom: parent.bottom
                        color:"black"
                        width:parent.width
                        height:pathName.height
                        opacity: 0.5

                        Text{
                            id: pathName
                            anchors.right: parent.right
                            elide: Text.ElideLeft
                            width: parent.width
                            text: path
                            color: "white"
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
                    width: (root.width - 5 * fileflow.spacing) / 4
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
                    }
                    MouseArea{
                        anchors.fill: parent
                        onReleased: {
                            root.select(path);
                        }
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

