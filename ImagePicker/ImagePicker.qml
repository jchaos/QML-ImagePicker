import QtQuick 2.7
import DjangoX.Gallery 1.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.2

Rectangle{
    id: root
    anchors.fill: parent
    color: "#222"
    property int maxDepth: 2
    property int imageIndex: 0
    property string loadingImage:""
    property string checkImage: ""
    property int checkedIndex:-1
    signal select(string filePath);
    signal itemCheked(int newIndex);

    onItemCheked: {
        if(checkedIndex != -1)
        {
            fileRepeater.itemAt(checkedIndex).checkImg = false
            fileRepeater.itemAt(checkedIndex).imageOpacity = 1
        }
        fileRepeater.itemAt(newIndex).checkImg = true
        fileRepeater.itemAt(newIndex).imageOpacity = 0.5
        checkedIndex = newIndex;
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

        onAllDone:{
            timer.repeat = true;
            root.imageIndex = 0;
            timer.start();
        }

        onOutPut: {
            fileRepeater.itemAt(index).source = "file:///"+newName;
            galleryManager.restore(currentDirModel.get(index).path, newName);
        }
    }

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
                    color:"#444"

                    MouseArea{
                        anchors.fill: parent
                        onReleased: {
                            flickableDir.visible = false
                            flickableFile.visible = true
                            returnToDirButton.visible = true
                            selectButton.visible = true
                            galleryManager.scanImageByPath(path);
                        }
                    }
                    Image{
                        id: pathCover
                        //source: "qrc:/imagepicker/loading"
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
                id: fileRepeater
                model: currentDirModel
                Rectangle{
                    id: fileRect
                    width: (root.width - 6 * fileflow.spacing) / 5
                    height: width
                    clip: true
                    color:"#444"
                    property alias source: imgFileLoading.source
                    property alias checkImg: checkImg.visible;
                    property alias imageOpacity: imgFileLoading.opacity
                    Image{
                        id: imgFileLoading
                        //source: "file:///"+path
                        source: loadingImage
                        width: parent.width
                        height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        onStatusChanged: {
                            if(status == Image.Error)
                            {
                                //currentDirModel.remove(index);
                                galleryManager.reformat(index, path);
                            }
                            if(status == Image.Ready)
                            {
                                state = "aft"
                            }
                        }
                        state:"pre"
                        states:[
                            State{
                                name:"pre"
                                PropertyChanges{
                                    target:imgFileLoading
                                    opacity:0
                                }
                            },
                            State{
                                name:"aft"
                                PropertyChanges{
                                    target:imgFileLoading
                                    opacity:1
                                }
                            }
                        ]
                        transitions: [
                            Transition{
                                from:"aft"
                                to:"pre"
                                NumberAnimation{
                                    property: "opacity"
                                    duration: 100
                                }
                            },
                            Transition{
                                from:"pre"
                                to:"aft"
                                NumberAnimation{
                                    property: "opacity"
                                    duration: 100
                                }
                            }
                        ]
                    }

                    Image{
                        id: checkImg
                        width: Screen.pixelDensity*10
                        height:width
                        anchors.centerIn: parent
                        source:checkImage
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        z:1
                    }

                    MouseArea{
                        anchors.fill: parent
                        onPressed: {
                            if(root.checkedIndex == index)
                            {
                                checkImg.visible = false
                                root.checkedIndex = -1
                                imgFileLoading.opacity = 1
                            }
                            else
                            {
                                root.itemCheked(index);
                            }
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
            timer.stop()
            flickableDir.visible = true
            flickableFile.visible = false
            returnToDirButton.visible = false
            selectButton.visible = false
            currentDirModel.clear()
        }
    }

    Button{
        id:selectButton
        text:"select"
        visible:false
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            if(root.checkedIndex != -1)
            {
                root.select(currentDirModel.get(root.checkedIndex).path);
                fileRepeater.itemAt(checkedIndex).checkImg = false
                fileRepeater.itemAt(checkedIndex).imageOpacity = 1
                root.checkedIndex = -1;
            }
            else
            {
                console.log("you didn't select any image")
            }
        }
    }

    Timer {
        id:timer
        interval: 10;
        repeat: true

        onTriggered: {
            fileRepeater.itemAt(parent.imageIndex).source = "file:///"+currentDirModel.get(parent.imageIndex).path
            parent.imageIndex++;
            if(parent.imageIndex >= currentDirModel.count)
            {
                repeat = false;
                stop();
            }
        }
    }
}

